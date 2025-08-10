# Clodonic Operations Runbook

## Quick Reference

### Service URLs
- **Production**: https://clodonic.ai
- **Worker**: https://clodonic-api.kittholland.workers.dev
- **GitHub**: https://github.com/kittholland/clodonic

### Critical Commands
```bash
# Deploy to production
wrangler deploy

# View live logs
wrangler tail

# Check service health
curl https://clodonic.ai/api/health

# Database operations
wrangler d1 execute clodonic-db --remote --command="SELECT COUNT(*) FROM items"
```

## Common Operations

### 📊 Monitoring

#### View Real-time Logs
```bash
# All logs
wrangler tail

# JSON format for parsing
wrangler tail --format=json

# Filter by status code
wrangler tail --status=500

# Filter by IP
wrangler tail --ip=1.2.3.4

# Save logs to file
wrangler tail --format=json > logs.json
```

#### Check System Health
```bash
# API health check
curl https://clodonic.ai/api/health | jq

# Database item count
wrangler d1 execute clodonic-db --remote --command="SELECT COUNT(*) as total FROM items"

# Check rate limit cache (in browser console)
await caches.default.match(new Request('https://ratelimit.local/rate_limit:upload:1.2.3.4'))
```

### 🚨 Incident Response

#### High Traffic / DDoS
1. **Immediate**: Enable "Under Attack Mode"
   ```
   Cloudflare Dashboard > Security > Under Attack Mode: ON
   ```

2. **Investigate**: Check logs for patterns
   ```bash
   wrangler tail --format=json | grep "rate_limit"
   ```

3. **Mitigate**: Add firewall rules in Cloudflare Dashboard

#### Database Issues
```bash
# Check database size
wrangler d1 execute clodonic-db --remote --command="SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size()"

# View recent submissions
wrangler d1 execute clodonic-db --remote --command="SELECT id, title, created_at FROM items ORDER BY created_at DESC LIMIT 10"

# Emergency: Clear rate limit table (if using DB rate limiting)
wrangler d1 execute clodonic-db --remote --command="DELETE FROM rate_limits WHERE window_start < datetime('now', '-1 hour')"
```

#### 500 Errors
1. Check recent deployments
   ```bash
   wrangler deployments list
   ```

2. View error logs
   ```bash
   wrangler tail --format=json | jq 'select(.level=="ERROR")'
   ```

3. Rollback if needed
   ```bash
   wrangler rollback [deployment-id]
   ```

### 🔧 Maintenance Tasks

#### Deploy Updates
```bash
# Test locally first
npm run dev

# Deploy to production
wrangler deploy

# Verify deployment
curl https://clodonic.ai/api/health
```

#### Database Maintenance
```bash
# Backup data (export)
wrangler d1 execute clodonic-db --remote --command="SELECT * FROM items" > backup.json

# Clean old rate limits (if using DB)
wrangler d1 execute clodonic-db --remote --command="DELETE FROM rate_limits WHERE window_start < datetime('now', '-7 days')"

# View database schema
wrangler d1 execute clodonic-db --remote --command="SELECT sql FROM sqlite_master WHERE type='table'"
```

#### Clear Suspicious Content
```bash
# Find pattern by ID
wrangler d1 execute clodonic-db --remote --command="SELECT * FROM items WHERE id = 123"

# Soft delete (add deleted_at column first if needed)
wrangler d1 execute clodonic-db --remote --command="UPDATE items SET deleted_at = datetime('now') WHERE id = 123"

# Hard delete (careful!)
wrangler d1 execute clodonic-db --remote --command="DELETE FROM items WHERE id = 123"
```

### 📈 Analytics & Reporting

#### Usage Statistics
```bash
# Daily submissions
wrangler d1 execute clodonic-db --remote --command="
  SELECT DATE(created_at) as date, COUNT(*) as submissions 
  FROM items 
  GROUP BY DATE(created_at) 
  ORDER BY date DESC 
  LIMIT 7"

# Popular patterns
wrangler d1 execute clodonic-db --remote --command="
  SELECT title, votes_up, install_count 
  FROM items 
  ORDER BY votes_up DESC 
  LIMIT 10"

# Active users
wrangler d1 execute clodonic-db --remote --command="
  SELECT COUNT(DISTINCT submitter_id) as users 
  FROM items 
  WHERE submitter_id IS NOT NULL"
```

#### Performance Metrics
```bash
# Find slow queries in logs
wrangler tail --format=json | jq 'select(.metric=="slow_query")'

# Rate limit hits
wrangler tail --format=json | jq 'select(.message | contains("Rate limit"))'
```

### 🔑 Authentication Issues

#### OAuth Problems
```bash
# Check OAuth configuration
wrangler secret list

# View auth errors
wrangler tail --format=json | jq 'select(.message | contains("OAuth"))'

# Test OAuth flow (development)
curl http://localhost:8787/auth/github
```

#### Session Issues
```bash
# Current implementation uses in-memory sessions
# Sessions are lost on worker restart
# Future: Migrate to Durable Objects or KV

# Check for session-related errors
wrangler tail --format=json | jq 'select(.message | contains("session"))'
```

### 🚀 Performance Optimization

#### Enable Caching
```yaml
# In wrangler.toml
[site]
bucket = "./public"

[build]
command = "npm run build"

[[kv_namespaces]]
binding = "CACHE"
id = "your-kv-namespace-id"
```

#### Monitor Performance
```bash
# Check response times
wrangler tail --format=json | jq '.duration' | stats

# Find slow endpoints
wrangler tail --format=json | jq 'select(.duration > 1000)'
```

### 🔐 Security Checks

#### Review Rate Limits
```bash
# Test rate limiting
for i in {1..12}; do 
  curl -X POST https://clodonic.ai/api/items \
    -H "Content-Type: application/json" \
    -d '{"type":"prompt","title":"Test","description":"Test","content":"test"}' \
    -w "\nStatus: %{http_code}, Headers: %{header_json}\n"
done
```

#### Audit Logs
```bash
# Find suspicious activity
wrangler tail --format=json | jq 'select(.ip=="suspicious.ip.here")'

# Check for failed auth attempts
wrangler tail --format=json | jq 'select(.message | contains("Auth") and .level=="WARN")'
```

## Emergency Contacts

### Escalation Path
1. **On-call Developer**: Check rotation schedule
2. **Platform Team**: security@clodonic.ai (future)
3. **Cloudflare Support**: Enterprise support ticket

### Key Services
- **Cloudflare Dashboard**: https://dash.cloudflare.com
- **GitHub Status**: https://www.githubstatus.com
- **Worker Status**: https://www.cloudflarestatus.com

## Troubleshooting Guide

### Common Issues

#### "Rate limit exceeded"
- Check SECURITY-CONFIG.md for limits
- Identify source IP in logs
- Consider temporary allowlist if legitimate

#### "Authentication required" (401)
- Expected for voting without login
- User should use GitHub OAuth to sign in
- Check session cookie if user claims to be logged in

#### "Database locked"
- D1 has concurrent write limitations
- Implement retry logic in application
- Consider read replicas for heavy read loads

#### "Worker exceeded CPU limits"
- Check for infinite loops
- Optimize database queries
- Consider caching frequent requests

### Debug Mode
```typescript
// Add to development environment
const DEBUG = env.DEBUG === 'true';

if (DEBUG) {
  console.log('Request:', {
    method: c.req.method,
    path: c.req.path,
    headers: Object.fromEntries(c.req.headers)
  });
}
```

## Deployment Checklist

### Pre-deployment
- [ ] Run tests locally: `npm test`
- [ ] Check TypeScript: `npm run typecheck`
- [ ] Test rate limits: See security checks above
- [ ] Review logs for errors: `wrangler tail`

### Deployment
- [ ] Deploy: `wrangler deploy`
- [ ] Verify health: `curl https://clodonic.ai/api/health`
- [ ] Check logs: `wrangler tail`
- [ ] Test critical paths: Submit, vote, search

### Post-deployment
- [ ] Monitor error rates for 15 minutes
- [ ] Check performance metrics
- [ ] Verify rate limiting works
- [ ] Document any issues

## Rollback Procedure

```bash
# List recent deployments
wrangler deployments list

# Rollback to previous version
wrangler rollback [deployment-id]

# Or deploy specific version
wrangler deploy --compatibility-date=2024-08-01

# Verify rollback
curl https://clodonic.ai/api/health
```

---

**Last Updated**: 2025-08-10
**Next Review**: 2025-09-10
**Maintainer**: Platform Team