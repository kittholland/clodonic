# Clodonic Security & Rate Limiting Configuration

## Overview
This document defines all security rules, rate limiting policies, and protective measures for clodonic.ai.

## Rate Limiting Rules

### API Endpoints

| Endpoint | Limit | Window | Key | Reason |
|----------|-------|---------|-----|--------|
| `POST /api/items` | 30 requests | 1 hour | IP-based | Prevent spam pattern submissions |
| `POST /api/items/:id/vote` | 10 requests | 1 minute | IP-based | Prevent vote manipulation |
| `GET /api/search` | 60 requests | 1 minute | IP-based | Prevent search abuse |
| `GET /api/items` | 100 requests | 1 minute | IP-based | General browsing protection |

### Authentication Endpoints

| Endpoint | Limit | Window | Key | Reason |
|----------|-------|---------|-----|--------|
| `/auth/github` | 5 attempts | 15 minutes | IP-based | Prevent OAuth abuse |
| `/auth/github/callback` | 10 attempts | 15 minutes | IP-based | Prevent callback flooding |
| `POST /api/auth/logout` | 10 requests | 1 minute | Session-based | Prevent logout spam |

### Rate Limit Headers
All rate-limited endpoints return these headers:
- `X-RateLimit-Limit`: Maximum requests allowed
- `X-RateLimit-Remaining`: Requests remaining in current window
- `X-RateLimit-Reset`: Unix timestamp when the limit resets
- `Retry-After`: Seconds to wait (only on 429 responses)

### Error Response (429)
```json
{
  "error": "Too many requests. Please try again later.",
  "retryAfter": "30"
}
```

## Content Validation Rules

### Pattern Submission Limits

| Type | Max Size | Validation |
|------|----------|------------|
| `claude_md` | 10,240 chars | Markdown format |
| `agent` | 5,120 chars | YAML/JSON structure |
| `prompt` | 500 chars | Plain text |
| `hook` | 5,120 chars | Shell script format |
| `command` | 2,048 chars | CLI command format |

### Other Limits
- **Title**: Max 100 characters
- **Description**: Max 300 characters
- **Tags**: Max 5 per pattern, 20 chars each
- **Duplicate Detection**: SHA-256 hash comparison

## Security Policies

### Authentication
- **Session Duration**: 24 hours
- **Cookie Settings**: HttpOnly, Secure, SameSite=Lax
- **OAuth State**: CSRF protection with random UUID
- **Session Storage**: In-memory (consider Redis for production scale)

### Input Sanitization
- All user inputs are escaped for HTML
- SQL parameters use prepared statements
- JSON parsing with error handling
- File hash validation for duplicates

### CORS Policy
- Origin: Allow all (API is public)
- Methods: GET, POST, OPTIONS
- Headers: Content-Type, Authorization
- Credentials: Include

### CSRF Protection
- Applied to all `/api/*` POST endpoints
- Token validation on state-changing operations
- Exempt: Public read endpoints

## Cloudflare Protection Layers

### Automatic (No Configuration)
1. **DDoS Protection**: L3/L4/L7 automatic mitigation
2. **SSL/TLS**: Automatic HTTPS enforcement
3. **IPv6 Support**: Dual-stack networking

### Dashboard Configuration (Recommended)

#### Bot Fight Mode
- **Status**: Enable in Cloudflare Dashboard
- **Path**: Security > Bots
- **Level**: "Fight Mode" for basic protection

#### Security Level
- **Setting**: Medium
- **Path**: Security > Settings
- **Effect**: Challenge suspicious visitors

#### Challenge Passage
- **Duration**: 30 minutes
- **Path**: Security > Settings
- **Effect**: Remember validated users

### Advanced Rules (Future)

#### WAF Custom Rules
Consider adding for production:
```
# Block excessive pattern content
(http.request.uri.path eq "/api/items" and http.request.method eq "POST" and http.request.body.size > 10240)

# Block rapid tag creation
(http.request.uri.path contains "/api/items" and cf.threat_score > 30)
```

#### Rate Limiting Rules (Dashboard)
Alternative to code-based limiting:
```
# Pattern submission abuse
Path: /api/items
Method: POST
Requests: 30 per hour per IP
Action: Block for 1 hour

# Vote manipulation
Path: /api/items/*/vote
Method: POST  
Requests: 10 per minute per IP
Action: Challenge
```

## Monitoring & Alerts

### Key Metrics to Track
1. **Rate Limit Hits**: Monitor 429 response rates
2. **Authentication Failures**: Track failed OAuth attempts
3. **Slow Queries**: Queries exceeding 100ms
4. **Error Rates**: 4xx and 5xx responses
5. **Submission Patterns**: Unusual submission volumes

### Log Patterns for Alerts
```json
// Rate limit exceeded
{"level":"WARN","message":"Rate limit exceeded","key":"upload","count":11}

// Authentication failure
{"level":"WARN","message":"OAuth state mismatch"}

// Slow query
{"level":"METRIC","metric":"slow_query","value":150,"unit":"ms"}

// Duplicate submission attempt
{"level":"WARN","message":"Duplicate pattern submission blocked"}
```

### Cloudflare Analytics
Monitor in dashboard:
- **Requests**: Total, cached, uncached
- **Bandwidth**: Data transfer patterns
- **Threats**: Blocked requests by type
- **Performance**: Origin response time

## Incident Response

### Rate Limit Exceeded
1. Check logs for IP pattern
2. Identify if legitimate user or abuse
3. Consider temporary IP allowlist if legitimate
4. Adjust limits if needed globally

### Suspected Attack
1. Enable "Under Attack Mode" in Cloudflare
2. Review WAF events in dashboard
3. Add custom firewall rules if pattern identified
4. Consider temporary rate limit reduction

### Performance Degradation
1. Check slow query logs
2. Review database query patterns
3. Enable Cloudflare caching if not active
4. Consider read replicas for D1 (when available)

## Future Enhancements

### Short Term (Next Sprint)
- [ ] Implement refresh tokens for sessions
- [ ] Add captcha for unauthenticated submissions
- [ ] Create admin dashboard for monitoring
- [ ] Add IP allowlist for known good actors

### Medium Term (Next Quarter)
- [ ] Migrate session storage to Durable Objects
- [ ] Implement user reputation scoring
- [ ] Add content moderation webhooks
- [ ] Create tiered rate limits by user type

### Long Term (Next Year)
- [ ] Machine learning for anomaly detection
- [ ] Geographic rate limiting rules
- [ ] API key system for power users
- [ ] Distributed rate limiting with Workers KV

## Configuration Updates

### How to Modify Rate Limits
1. Edit `/src/cfRateLimit.ts` middleware calls
2. Test in development: `npm run dev`
3. Deploy: `wrangler deploy`
4. Monitor logs for impact

### Emergency Overrides
```typescript
// Temporary disable rate limiting (emergency only)
const RATE_LIMIT_ENABLED = env.RATE_LIMIT_ENABLED !== 'false';

if (RATE_LIMIT_ENABLED) {
  app.use(cfRateLimitMiddleware(...));
}
```

### Environment Variables
```bash
# Add to wrangler.toml for overrides
[vars]
RATE_LIMIT_MULTIPLIER = "1"  # Multiply all limits
ENABLE_STRICT_MODE = "false"  # Stricter validation
```

## Testing

### Load Testing Rate Limits
```bash
# Test pattern submission limit
for i in {1..15}; do
  curl -X POST https://clodonic.ai/api/items \
    -H "Content-Type: application/json" \
    -d '{"type":"prompt","title":"Test","description":"Test","content":"test"}'
  sleep 1
done

# Check rate limit headers
curl -I https://clodonic.ai/api/items
```

### Monitoring Commands
```bash
# Watch rate limit logs
wrangler tail --format=json | grep "rate_limit"

# Monitor 429 responses
wrangler tail --status=429

# Check slow queries
wrangler tail --format=json | grep "slow_query"
```

## Compliance & Privacy

### Data Retention
- Logs: 30 days (Cloudflare default)
- Rate limit cache: Duration of window
- Session data: 24 hours
- IP addresses: Hashed for privacy

### GDPR Considerations
- IP addresses are considered PII
- User can request data deletion
- Anonymous submissions allowed
- No tracking cookies for visitors

### Security Headers
Currently implemented:
- CORS restrictions
- CSRF tokens
- Secure cookies

To be added:
- Content-Security-Policy
- X-Frame-Options
- X-Content-Type-Options

---

**Last Updated**: 2025-08-10
**Review Schedule**: Monthly
**Owner**: Platform Team
**Contact**: security@clodonic.ai (future)