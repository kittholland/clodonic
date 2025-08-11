import { Context } from 'hono';
import { getCookie } from 'hono/cookie';
import { GitHub } from 'arctic';

// Session interface
interface Session {
  userId: number;
  username: string;
  createdAt: number;
}

// Create session in D1
export async function createSession(
  db: D1Database,
  userId: number, 
  username: string
): Promise<string> {
  const sessionId = crypto.randomUUID();
  const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours
  
  await db.prepare(
    `INSERT INTO sessions (id, user_id, username, expires_at) 
     VALUES (?, ?, ?, ?)`
  ).bind(
    sessionId,
    userId,
    username,
    expiresAt.toISOString()
  ).run();
  
  return sessionId;
}

// Get session from D1
export async function getSession(
  db: D1Database,
  sessionId: string
): Promise<Session | null> {
  const session = await db.prepare(
    `SELECT user_id, username, created_at 
     FROM sessions 
     WHERE id = ? AND expires_at > datetime('now')`
  ).bind(sessionId).first();
  
  if (!session) return null;
  
  return {
    userId: session.user_id as number,
    username: session.username as string,
    createdAt: new Date(session.created_at as string).getTime()
  };
}

// Delete session from D1
export async function deleteSession(
  db: D1Database,
  sessionId: string
): Promise<void> {
  await db.prepare('DELETE FROM sessions WHERE id = ?')
    .bind(sessionId)
    .run();
}

// Clean up expired sessions (call periodically)
export async function cleanupSessions(db: D1Database): Promise<void> {
  await db.prepare(
    `DELETE FROM sessions WHERE expires_at <= datetime('now')`
  ).run();
}

// Get user from request
export async function getUserFromRequest(c: Context): Promise<Session | null> {
  const sessionId = c.req.header('X-Session-Id') || 
                   getCookie(c, 'session_id');
  
  if (!sessionId) return null;
  
  // Access D1 from context
  const db = c.env.DB as D1Database;
  return getSession(db, sessionId);
}

// Create GitHub OAuth client
export function createGitHubClient(
  clientId: string, 
  clientSecret: string,
  redirectUri?: string
): GitHub {
  // GitHub requires redirect URI if multiple are configured
  // Pass null if not provided to use the default
  return new GitHub(clientId, clientSecret, redirectUri || null);
}

// Generate authorization URL
export function getGitHubAuthUrl(
  github: GitHub, 
  state: string
): string {
  // Arctic handles redirect_uri internally when the GitHub client is created
  const url = github.createAuthorizationURL(state, {
    scopes: ["read:user", "user:email"]
  });
  
  return url.toString();
}

// Exchange code for tokens
export async function exchangeGitHubCode(
  github: GitHub,
  code: string
): Promise<{ accessToken: string }> {
  try {
    const tokens = await github.validateAuthorizationCode(code);
    // Arctic returns OAuth2Tokens object - accessToken() is a method!
    const accessToken = tokens.accessToken();
    return { accessToken };
  } catch (error) {
    console.error('GitHub token exchange failed:', error);
    throw error;
  }
}

// Get GitHub user
export async function getGitHubUser(accessToken: string): Promise<any> {
  const response = await fetch('https://api.github.com/user', {
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Accept': 'application/json',
      'User-Agent': 'Clodonic-OAuth'
    }
  });
  
  if (!response.ok) {
    throw new Error(`GitHub API error: ${response.status}`);
  }
  
  return response.json();
}