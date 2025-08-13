import { Context } from 'hono';
import { getLogger } from './logger';

// Cloudflare Workers Rate Limiting using the Cache API
// This is more efficient than database-based rate limiting

interface RateLimitConfig {
  key: string;           // Unique key for this rate limit
  limit: number;         // Max requests
  windowMs: number;      // Time window in milliseconds
  message?: string;      // Custom error message
  userId?: number;       // Optional user ID for user-based limits (2025 enhancement)
  userMultiplier?: number; // Multiplier for authenticated users (e.g., 2 = double the limit)
}

export async function checkCFRateLimit(
  c: Context,
  config: RateLimitConfig
): Promise<boolean> {
  const logger = getLogger(c);
  
  // Get client identifier (IP from Cloudflare headers)
  const ip = c.req.header('CF-Connecting-IP') || 
             c.req.header('X-Real-IP') ||
             c.req.header('X-Forwarded-For')?.split(',')[0] || 
             'unknown';
  
  // For Cloudflare Workers, we can also use CF-Ray for more granular tracking
  const cfRay = c.req.header('CF-Ray');
  
  // Enhanced rate limiting (2025): Support user-based limits
  let rateLimitKey: string;
  let effectiveLimit = config.limit;
  
  if (config.userId) {
    // User-based rate limiting - each user gets their own bucket
    rateLimitKey = `rate_limit:${config.key}:user:${config.userId}`;
    
    // Authenticated users can get higher limits
    if (config.userMultiplier) {
      effectiveLimit = Math.floor(config.limit * config.userMultiplier);
    }
    
    logger.info('User-based rate limit check', {
      userId: config.userId,
      key: config.key,
      limit: effectiveLimit
    });
  } else {
    // IP-based rate limiting (default)
    rateLimitKey = `rate_limit:${config.key}:ip:${ip}`;
  }
  
  try {
    // Use Cloudflare's Cache API for rate limiting
    // This is distributed and fast
    const cache = caches.default;
    const cacheKey = new Request(`https://ratelimit.local/${rateLimitKey}`);
    
    // Try to get existing rate limit data
    const existingResponse = await cache.match(cacheKey);
    
    let count = 0;
    let resetTime = Date.now() + config.windowMs;
    
    if (existingResponse) {
      const data = await existingResponse.json() as { count: number, resetTime: number };
      
      // Check if window has expired
      if (Date.now() > data.resetTime) {
        // Reset the counter
        count = 0;
        resetTime = Date.now() + config.windowMs;
      } else {
        count = data.count;
        resetTime = data.resetTime;
      }
    }
    
    // Check if limit exceeded (use effective limit for user-based)
    if (count >= effectiveLimit) {
      logger.warn('Rate limit exceeded', {
        ip,
        cfRay,
        key: config.key,
        count,
        limit: effectiveLimit,
        isUserLimit: !!config.userId,
        userId: config.userId,
        resetTime: new Date(resetTime).toISOString()
      });
      
      // Set rate limit headers
      c.header('X-RateLimit-Limit', effectiveLimit.toString());
      c.header('X-RateLimit-Remaining', '0');
      c.header('X-RateLimit-Reset', resetTime.toString());
      c.header('Retry-After', Math.ceil((resetTime - Date.now()) / 1000).toString());
      
      return false;
    }
    
    // Increment counter
    count++;
    
    // Store updated count in cache
    const response = new Response(JSON.stringify({ count, resetTime }), {
      headers: {
        'Cache-Control': `max-age=${Math.ceil(config.windowMs / 1000)}`,
        'Content-Type': 'application/json',
      }
    });
    
    await cache.put(cacheKey, response);
    
    // Set rate limit headers for successful requests (use effective limit)
    c.header('X-RateLimit-Limit', effectiveLimit.toString());
    c.header('X-RateLimit-Remaining', (effectiveLimit - count).toString());
    c.header('X-RateLimit-Reset', resetTime.toString());
    
    // Log if approaching limit
    if (count > effectiveLimit * 0.8) {
      logger.info('Rate limit warning', {
        ip,
        cfRay,
        key: config.key,
        count,
        limit: effectiveLimit,
        remaining: effectiveLimit - count,
        isUserLimit: !!config.userId,
        userId: config.userId
      });
    }
    
    return true;
  } catch (error) {
    // Log error but don't block the request
    logger.error('Rate limit check failed', error, { 
      key: config.key,
      ip 
    });
    return true;
  }
}

// Middleware factory for rate limiting
export function cfRateLimitMiddleware(
  key: string,
  limit: number,
  windowMs: number,
  message?: string
) {
  return async (c: Context, next: () => Promise<void>) => {
    const allowed = await checkCFRateLimit(c, {
      key,
      limit,
      windowMs,
      message
    });
    
    if (!allowed) {
      return c.json({ 
        error: message || 'Too many requests. Please try again later.',
        retryAfter: c.res.headers.get('Retry-After')
      }, 429);
    }
    
    await next();
  };
}

// Enhanced middleware for user-aware rate limiting (2025 security enhancement)
export function userAwareRateLimitMiddleware(
  key: string,
  anonymousLimit: number,
  authenticatedMultiplier: number, // e.g., 2 = authenticated users get 2x the limit
  windowMs: number,
  message?: string
) {
  return async (c: Context, next: () => Promise<void>) => {
    // Try to get user session
    const { getUserFromRequest } = await import('./auth');
    const session = await getUserFromRequest(c);
    
    const config: RateLimitConfig = {
      key,
      limit: anonymousLimit,
      windowMs,
      message
    };
    
    // Apply user-based rate limiting if authenticated
    if (session?.userId) {
      config.userId = session.userId;
      config.userMultiplier = authenticatedMultiplier;
    }
    
    const allowed = await checkCFRateLimit(c, config);
    
    if (!allowed) {
      const errorMessage = session?.userId 
        ? `Rate limit exceeded for user ${session.username}. ${message || 'Please wait before trying again.'}`
        : message || 'Too many requests. Please try again later or sign in for higher limits.';
        
      return c.json({ 
        error: errorMessage,
        retryAfter: c.res.headers.get('Retry-After'),
        authenticated: !!session?.userId
      }, 429);
    }
    
    await next();
  };
}

// Cloudflare also supports these built-in protections we should document:
// 1. DDoS Protection - Automatic, no config needed
// 2. Bot Fight Mode - Can be enabled in dashboard
// 3. IP Access Rules - Can be configured in dashboard
// 4. Rate Limiting Rules - Can be configured in dashboard for more complex scenarios
// 5. Firewall Rules - Custom rules based on various criteria

// For production, consider using Cloudflare's Rate Limiting Rules in the dashboard
// for more sophisticated rate limiting without code changes