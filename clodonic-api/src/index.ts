import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { csrf } from 'hono/csrf';
import { getCookie, setCookie } from 'hono/cookie';
import { 
  createSession, 
  getUserFromRequest, 
  createGitHubClient,
  getGitHubAuthUrl,
  exchangeGitHubCode,
  getGitHubUser,
  deleteSession
} from './auth';
import { loggerMiddleware, getLogger } from './logger';
import { cfRateLimitMiddleware } from './cfRateLimit';
import { validateContent } from './validation';
import { parseSubmission } from './schemas';
import { validateContentStructure } from './contentValidators';

type Bindings = {
  DB: D1Database;
  BUCKET: R2Bucket;
  ASSETS: any;
  GITHUB_CLIENT_ID: string;
  GITHUB_CLIENT_SECRET: string;
  SITE_URL?: string;
};

const app = new Hono<{ Bindings: Bindings }>();

// Middleware
app.use('*', loggerMiddleware());
app.use('*', cors());
app.use('/api/*', csrf());

// Health check
app.get('/api/health', (c) => {
  return c.json({ status: 'ok', timestamp: new Date().toISOString() });
});


// List items
app.get('/api/items', async (c) => {
  const logger = getLogger(c);
  const { type, sort = 'hot', limit = '30', offset = '0', user, tag, timeframe } = c.req.query();
  const queryStart = Date.now();
  
  let query = `
    SELECT i.*, 
           u.username as submitter_name,
           GROUP_CONCAT(t.name) as tag_names
    FROM items i
    LEFT JOIN users u ON i.submitter_id = u.id
    LEFT JOIN item_tags it ON i.id = it.item_id
    LEFT JOIN tags t ON it.tag_id = t.id
  `;
  
  const conditions: string[] = [];
  const params: any[] = [];
  
  if (type) {
    conditions.push('i.type = ?');
    params.push(type);
  }
  
  if (user) {
    conditions.push('u.username = ?');
    params.push(user);
  }
  
  if (tag) {
    conditions.push('t.name = ?');
    params.push(tag);
  }
  
  if (timeframe && sort === 'top') {
    const now = new Date();
    let dateFilter;
    switch (timeframe) {
      case 'day':
        dateFilter = new Date(now.getTime() - 24 * 60 * 60 * 1000);
        break;
      case 'week':
        dateFilter = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case 'month':
        dateFilter = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        break;
    }
    if (dateFilter) {
      conditions.push('i.created_at >= ?');
      params.push(dateFilter.toISOString());
    }
  }
  
  if (conditions.length > 0) {
    query += ' WHERE ' + conditions.join(' AND ');
  }
  
  query += ' GROUP BY i.id';
  
  // Sorting
  switch (sort) {
    case 'top':
      query += ' ORDER BY i.votes_up DESC';
      break;
    case 'new':
      query += ' ORDER BY i.created_at DESC';
      break;
    case 'hot':
    default:
      // Simple hot algorithm: recent items with votes
      query += ' ORDER BY (i.votes_up - i.votes_down) DESC, i.created_at DESC';
  }
  
  query += ' LIMIT ? OFFSET ?';
  params.push(parseInt(limit), parseInt(offset));
  
  const result = await c.env.DB.prepare(query).bind(...params).all();
  
  const queryTime = Date.now() - queryStart;
  if (queryTime > 100) {
    logger.metric('slow_query', queryTime, 'ms', { 
      endpoint: '/api/items',
      filters: { type, sort, tag, user }
    });
  }
  
  // Parse tag names
  const items = result.results?.map((item: any) => ({
    ...item,
    tags: item.tag_names ? item.tag_names.split(',') : [],
    submitter_name: item.submitter_name || 'anonymous'
  })) || [];
  
  return c.json({
    items,
    total: result.meta.rows_read,
  });
});

// Get single item
app.get('/api/items/:id', async (c) => {
  const id = c.req.param('id');
  
  const item = await c.env.DB.prepare(
    'SELECT * FROM items WHERE id = ?'
  ).bind(id).first();
  
  if (!item) {
    return c.json({ error: 'Item not found' }, 404);
  }
  
  // Get tags
  const tags = await c.env.DB.prepare(`
    SELECT t.name, t.category 
    FROM tags t 
    JOIN item_tags it ON t.id = it.tag_id 
    WHERE it.item_id = ?
  `).bind(id).all();
  
  return c.json({
    ...item,
    tags: tags.results,
  });
});

// Upload item (anonymous allowed)
app.post('/api/items', 
  cfRateLimitMiddleware(
    'upload',
    30,                      // 30 submissions
    60 * 60 * 1000,         // per hour
    'Too many pattern submissions. Please wait before submitting again.'
  ),
  async (c) => {
  const logger = getLogger(c);
  
  // Robust JSON parsing and validation with Zod
  let rawBody;
  try {
    rawBody = await c.req.json();
  } catch (error) {
    logger.warn('Invalid JSON in submission', { error: error.message });
    return c.json({ error: 'Invalid JSON format in request body' }, 400);
  }
  
  // Comprehensive input validation with Zod
  const validation = parseSubmission(rawBody);
  if (!validation.success) {
    logger.warn('Submission validation failed', { 
      error: validation.error,
      hasData: !!rawBody 
    });
    return c.json({ error: validation.error }, 400);
  }
  
  const { type, title, description, content, tags } = validation.data;
  
  // Get user from session if authenticated
  const session = await getUserFromRequest(c);
  const userId = session?.userId || null;
  
  try {
    logger.info('Pattern submission attempt', { type, userId, tagCount: tags.length });
    
    // Content validation (3-tier security system)
    const contentValidation = validateContent(content, type, title, description, c);
    
    if (contentValidation.status === 'BLOCK') {
      logger.warn('Pattern submission blocked', { 
        reason: contentValidation.reason,
        category: contentValidation.category,
        type,
        userId 
      });
      return c.json({ 
        error: contentValidation.reason,
        blocked: true 
      }, 400);
    }
    
    // Structured content validation (YAML, shell syntax, etc.)
    const structureValidation = validateContentStructure(content, type);
    
    if (!structureValidation.valid) {
      logger.warn('Content structure validation failed', {
        type,
        error: structureValidation.error,
        userId
      });
      return c.json({ 
        error: structureValidation.error,
        validation_type: 'structure' 
      }, 400);
    }
    
    // Collect all warnings (security + structure)
    const allWarnings: string[] = [];
    if (contentValidation.status === 'WARN' && contentValidation.reason) {
      allWarnings.push(`Security: ${contentValidation.reason}`);
    }
    if (structureValidation.warnings && structureValidation.warnings.length > 0) {
      allWarnings.push(`Structure: ${structureValidation.warnings.join(', ')}`);
    }
  
  // Generate hash for deduplication
  const encoder = new TextEncoder();
  const data = encoder.encode(content);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const fileHash = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  
  // Check for duplicates
  const existing = await c.env.DB.prepare(
    'SELECT id FROM items WHERE file_hash = ? AND type = ?'
  ).bind(fileHash, type).first();
  
  if (existing) {
    logger.warn('Duplicate pattern submission blocked', { 
      existingId: existing.id, 
      fileHash 
    });
    return c.json({ 
      error: 'Duplicate content already exists',
      existing_id: existing.id 
    }, 409);
  }
  
  // Prepare warning data
  const hasWarnings = allWarnings.length > 0 ? 1 : 0;
  const warningFlags = hasWarnings ? JSON.stringify(allWarnings) : null;

  // Start transaction
  const tx = await c.env.DB.batch([
    c.env.DB.prepare(
      `INSERT INTO items (type, title, description, content, file_hash, submitter_id, has_warnings, warning_flags) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`
    ).bind(type, title, description, content, fileHash, userId, hasWarnings, warningFlags)
  ]);
  
  const itemId = tx[0].meta.last_row_id;
  
  // Handle tags - validate against curated list only
  if (tags.length > 0) {
    // Validate all tags exist in curated list
    const validTags: string[] = [];
    for (const tagName of tags.slice(0, 5)) { // Max 5 tags
      const tag = await c.env.DB.prepare(
        'SELECT id FROM tags WHERE name = ?'
      ).bind(tagName).first();
      
      if (tag) {
        validTags.push(tagName);
        await c.env.DB.prepare(
          'INSERT INTO item_tags (item_id, tag_id) VALUES (?, ?)'
        ).bind(itemId, tag.id).run();
      } else {
        logger.warn('Invalid tag submitted', { tagName, itemId });
      }
    }
    
    if (validTags.length === 0 && tags.length > 0) {
      logger.warn('No valid tags provided', { submittedTags: tags, itemId });
    }
  }
  
  logger.info('Pattern created successfully', { 
    itemId, 
    type, 
    userId,
    tagCount: tags.length,
    hasWarnings: allWarnings.length > 0,
    warningCount: allWarnings.length
  });
  
  const response: any = {
    id: itemId,
    message: 'Item created successfully',
  };
  
  // Include warnings for security and structure issues
  if (allWarnings.length > 0) {
    response.warning = allWarnings.join(' | ');
    response.warning_category = contentValidation.status === 'WARN' ? contentValidation.category : 'structure';
    response.warning_count = allWarnings.length;
    
    logger.info('Pattern created with warnings', { 
      itemId, 
      warnings: allWarnings,
      securityWarning: contentValidation.status === 'WARN',
      structureWarnings: structureValidation.warnings?.length || 0
    });
  }
  
  return c.json(response, 201);
  } catch (error) {
    logger.error('Pattern submission failed', error, { 
      type, 
      userId,
      hasTitle: !!title,
      hasContent: !!content 
    });
    return c.json({ 
      error: 'Internal server error. Please try again.' 
    }, 500);
  }
});

// Search
app.get('/api/search', async (c) => {
  const { q, type, tags } = c.req.query();
  
  if (!q) {
    return c.json({ error: 'Query parameter required' }, 400);
  }
  
  let query = `
    SELECT DISTINCT i.* 
    FROM items i
    LEFT JOIN item_tags it ON i.id = it.item_id
    LEFT JOIN tags t ON it.tag_id = t.id
    WHERE (i.title LIKE ? OR i.description LIKE ?)
  `;
  
  const searchTerm = `%${q}%`;
  const params: any[] = [searchTerm, searchTerm];
  
  if (type) {
    query += ' AND i.type = ?';
    params.push(type);
  }
  
  if (tags) {
    const tagList = tags.split(',');
    query += ` AND t.name IN (${tagList.map(() => '?').join(',')})`;
    params.push(...tagList);
  }
  
  query += ' ORDER BY i.votes_up DESC LIMIT 30';
  
  const result = await c.env.DB.prepare(query).bind(...params).all();
  
  return c.json({
    results: result.results,
    query: q,
  });
});

// Vote on item
app.post('/api/items/:id/vote', 
  cfRateLimitMiddleware(
    'vote',
    10,              // 10 votes
    60 * 1000,      // per minute
    'Voting too quickly. Please slow down.'
  ),
  async (c) => {
  const logger = getLogger(c);
  const itemId = c.req.param('id');
  
  try {
    const session = await getUserFromRequest(c);
    const userId = session?.userId;
    
    if (!userId) {
      logger.info('Vote attempt without auth', { itemId });
      return c.json({ error: 'Authentication required' }, 401);
    }
    
    let vote: number;
    try {
      const body = await c.req.json();
      vote = body.vote;
    } catch (error) {
      logger.warn('Invalid vote request body', { itemId, error: error.message });
      return c.json({ error: 'Invalid request body' }, 400);
    }
  
  if (vote !== 1 && vote !== -1) {
    return c.json({ error: 'Invalid vote value' }, 400);
  }
  
  // Check existing vote
  const existing = await c.env.DB.prepare(
    'SELECT vote FROM votes WHERE user_id = ? AND item_id = ?'
  ).bind(userId, itemId).first();
  
  if (existing) {
    if (existing.vote === vote) {
      // Remove vote
      await c.env.DB.prepare(
        'DELETE FROM votes WHERE user_id = ? AND item_id = ?'
      ).bind(userId, itemId).run();
    } else {
      // Update vote
      await c.env.DB.prepare(
        'UPDATE votes SET vote = ? WHERE user_id = ? AND item_id = ?'
      ).bind(vote, userId, itemId).run();
    }
  } else {
    // New vote
    await c.env.DB.prepare(
      'INSERT INTO votes (user_id, item_id, vote) VALUES (?, ?, ?)'
    ).bind(userId, itemId, vote).run();
  }
  
  // Update item vote counts
  const voteSum = await c.env.DB.prepare(
    'SELECT SUM(CASE WHEN vote = 1 THEN 1 ELSE 0 END) as up, SUM(CASE WHEN vote = -1 THEN 1 ELSE 0 END) as down FROM votes WHERE item_id = ?'
  ).bind(itemId).first();
  
  await c.env.DB.prepare(
    'UPDATE items SET votes_up = ?, votes_down = ? WHERE id = ?'
  ).bind(voteSum?.up || 0, voteSum?.down || 0, itemId).run();
  
  logger.info('Vote recorded', { 
    itemId, 
    userId, 
    vote,
    newTotal: (voteSum?.up || 0) - (voteSum?.down || 0)
  });
  
  return c.json({ 
    votes_up: voteSum?.up || 0,
    votes_down: voteSum?.down || 0
  });
  } catch (error) {
    logger.error('Vote endpoint error', error, { itemId });
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// Get popular tags
app.get('/api/tags', async (c) => {
  const result = await c.env.DB.prepare(`
    SELECT t.name, COUNT(it.item_id) as count
    FROM tags t
    JOIN item_tags it ON t.id = it.tag_id
    GROUP BY t.id
    ORDER BY count DESC
    LIMIT 20
  `).all();
  
  return c.json(result.results);
});

// Auth endpoints
app.get('/api/auth/status', async (c) => {
  const session = await getUserFromRequest(c);
  if (!session) {
    return c.json({ authenticated: false });
  }
  
  return c.json({ 
    authenticated: true,
    username: session.username,
    userId: session.userId
  });
});

app.get('/api/auth/user', async (c) => {
  const session = await getUserFromRequest(c);
  if (!session) {
    return c.json({ error: 'Not authenticated' }, 401);
  }
  
  // Get full user info from database
  const user = await c.env.DB.prepare(
    'SELECT id, username, email, avatar_url, display_name FROM users WHERE id = ?'
  ).bind(session.userId).first();
  
  if (!user) {
    return c.json({ error: 'User not found' }, 404);
  }
  
  return c.json({ 
    id: user.id,
    username: user.username,
    email: user.email,
    avatar_url: user.avatar_url,
    display_name: user.display_name,
    // For frontend compatibility
    name: user.display_name
  });
});

app.get('/api/auth/github', (c) => {
  const state = crypto.randomUUID();
  const siteUrl = c.env.SITE_URL || 'http://localhost:8787';
  const redirectUri = `${siteUrl}/api/auth/github/callback`;
  
  const github = createGitHubClient(
    c.env.GITHUB_CLIENT_ID,
    c.env.GITHUB_CLIENT_SECRET,
    redirectUri
  );
  
  const authUrl = getGitHubAuthUrl(github, state);
  
  // Store state in cookie for CSRF protection
  setCookie(c, 'oauth_state', state, {
    httpOnly: true,
    secure: siteUrl.startsWith('https'),
    sameSite: 'Lax',
    maxAge: 600 // 10 minutes
  });
  
  return c.redirect(authUrl);
});

app.get('/api/auth/github/callback', async (c) => {
  const logger = getLogger(c);
  const code = c.req.query('code');
  const state = c.req.query('state');
  const storedState = getCookie(c, 'oauth_state');
  
  // Verify state
  if (!state || state !== storedState) {
    logger.warn('OAuth state mismatch', { state, storedState });
    return c.redirect('/?error=invalid_state');
  }
  
  if (!code) {
    logger.warn('OAuth callback without code');
    return c.redirect('/?error=no_code');
  }
  
  try {
    const siteUrl = c.env.SITE_URL || 'http://localhost:8787';
    const redirectUri = `${siteUrl}/api/auth/github/callback`;
    
    const github = createGitHubClient(
      c.env.GITHUB_CLIENT_ID,
      c.env.GITHUB_CLIENT_SECRET,
      redirectUri
    );
    
    // Exchange code for access token
    const { accessToken } = await exchangeGitHubCode(
      github,
      code
    );
    
    // Get user info from GitHub
    const githubUser = await getGitHubUser(accessToken);
    
    // Check if user exists in database
    let user = await c.env.DB.prepare(
      'SELECT * FROM users WHERE provider_id = ? AND auth_provider = ?'
    ).bind(String(githubUser.id), 'github').first();
    
    if (!user) {
      // Create new user with GitHub profile info
      const result = await c.env.DB.prepare(
        `INSERT INTO users (provider_id, username, email, auth_provider, avatar_url, display_name) 
         VALUES (?, ?, ?, ?, ?, ?)`
      ).bind(
        String(githubUser.id),
        githubUser.login,
        githubUser.email,
        'github',
        githubUser.avatar_url,
        githubUser.name || githubUser.login
      ).run();
      
      user = {
        id: result.meta.last_row_id,
        username: githubUser.login,
        email: githubUser.email,
        auth_provider: 'github',
        avatar_url: githubUser.avatar_url,
        display_name: githubUser.name || githubUser.login
      };
    } else {
      // Update existing user's profile info
      await c.env.DB.prepare(
        `UPDATE users SET avatar_url = ?, display_name = ? WHERE id = ?`
      ).bind(
        githubUser.avatar_url,
        githubUser.name || githubUser.login,
        user.id
      ).run();
      
      // Update user object with latest info
      user.avatar_url = githubUser.avatar_url;
      user.display_name = githubUser.name || githubUser.login;
    }
    
    // Create session in D1
    const sessionId = await createSession(c.env.DB, user.id as number, user.username as string);
    
    // Set session cookie
    setCookie(c, 'session_id', sessionId, {
      httpOnly: true,
      secure: true,
      sameSite: 'Lax',
      maxAge: 86400 // 24 hours
    });
    
    logger.info('User authenticated successfully', { 
      userId: user.id as number,
      username: user.username as string,
      newUser: !user
    });
    
    return c.redirect('/');
  } catch (error) {
    logger.error('OAuth authentication failed', error);
    return c.redirect('/?error=auth_failed');
  }
});

app.post('/api/auth/logout', async (c) => {
  const sessionId = getCookie(c, 'session_id');
  if (sessionId) {
    await deleteSession(c.env.DB, sessionId);
  }
  
  setCookie(c, 'session_id', '', {
    httpOnly: true,
    secure: true,
    sameSite: 'Lax',
    maxAge: 0
  });
  
  return c.json({ success: true });
});

// Static frontend with client-side routing support
app.get('/pattern/:id', async (c) => {
  // Serve pattern.html for pattern detail pages
  const url = new URL(c.req.url);
  url.pathname = '/pattern.html';
  return c.env.ASSETS.fetch(new Request(url.toString()));
});

app.get('/*', async (c) => {
  return c.env.ASSETS.fetch(c.req.raw);
});

export default app;