import { Context } from 'hono';
import { getLogger } from './logger';

// Cloudflare Workers Rate Limiting using the Cache API
// This is more efficient than database-based rate limiting

interface RateLimitConfig {
  key: string;           // Unique key for this rate limit
  limit: number;         // Max requests
  windowMs: number;      // Time window in milliseconds
  message?: string;      // Custom error message
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
  
  // Create a unique key for this client and action
  const rateLimitKey = `rate_limit:${config.key}:${ip}`;
  
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
    
    // Check if limit exceeded
    if (count >= config.limit) {
      logger.warn('Rate limit exceeded', {
        ip,
        cfRay,
        key: config.key,
        count,
        limit: config.limit,
        resetTime: new Date(resetTime).toISOString()
      });
      
      // Set rate limit headers
      c.header('X-RateLimit-Limit', config.limit.toString());
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
    
    // Set rate limit headers for successful requests
    c.header('X-RateLimit-Limit', config.limit.toString());
    c.header('X-RateLimit-Remaining', (config.limit - count).toString());
    c.header('X-RateLimit-Reset', resetTime.toString());
    
    // Log if approaching limit
    if (count > config.limit * 0.8) {
      logger.info('Rate limit warning', {
        ip,
        cfRay,
        key: config.key,
        count,
        limit: config.limit,
        remaining: config.limit - count
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

// Cloudflare also supports these built-in protections we should document:
// 1. DDoS Protection - Automatic, no config needed
// 2. Bot Fight Mode - Can be enabled in dashboard
// 3. IP Access Rules - Can be configured in dashboard
// 4. Rate Limiting Rules - Can be configured in dashboard for more complex scenarios
// 5. Firewall Rules - Custom rules based on various criteria

// For production, consider using Cloudflare's Rate Limiting Rules in the dashboard
// for more sophisticated rate limiting without code changes