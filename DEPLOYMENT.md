# Deployment Guide for Clodonic

## Prerequisites
1. Cloudflare account with Workers enabled
2. Domain configured in Cloudflare (clodonic.ai)
3. GitHub OAuth App created

## Step 1: Create GitHub OAuth App
1. Go to https://github.com/settings/applications/new
2. Fill in:
   - Application name: `Clodonic`
   - Homepage URL: `https://clodonic.ai`
   - Authorization callback URL: `https://clodonic.ai/auth/github/callback`
3. Save the Client ID and Client Secret

## Step 2: Configure Cloudflare Secrets
```bash
# Set GitHub OAuth credentials as secrets
wrangler secret put GITHUB_CLIENT_ID
# Enter your GitHub Client ID when prompted

wrangler secret put GITHUB_CLIENT_SECRET
# Enter your GitHub Client Secret when prompted
```

## Step 3: Create Production Database
```bash
# Create the D1 database in Cloudflare
wrangler d1 create clodonic-db

# Update wrangler.jsonc with the new database_id from the output

# Run migrations on production database
wrangler d1 execute clodonic-db --remote --file=schema.sql
```

## Step 4: Deploy to Cloudflare Workers
```bash
cd clodonic-api

# Deploy to production
npm run deploy

# Or use wrangler directly
wrangler deploy
```

## Step 5: Configure Custom Domain
1. Go to Cloudflare Dashboard > Workers & Pages
2. Select your `clodonic-api` worker
3. Go to Settings > Triggers
4. Add custom domain: `clodonic.ai`
5. Add www redirect: `www.clodonic.ai` → `clodonic.ai`

## Step 6: Seed Initial Data (Optional)
```bash
# Add sample patterns via API
curl -X POST https://clodonic.ai/api/items \
  -H "Content-Type: application/json" \
  -d @seed-data.json
```

## Step 7: Verify Deployment
- Visit https://clodonic.ai
- Test pattern submission
- Test GitHub authentication
- Check API endpoints

## Environment Variables
The following need to be configured:
- `GITHUB_CLIENT_ID` - GitHub OAuth App Client ID
- `GITHUB_CLIENT_SECRET` - GitHub OAuth App Client Secret

## Monitoring
- Cloudflare Dashboard: Workers Analytics
- Wrangler tail for real-time logs: `wrangler tail`

## Rollback
```bash
# List deployments
wrangler deployments list

# Rollback to previous version
wrangler rollback
```