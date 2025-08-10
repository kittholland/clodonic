# Cloudflare Workers Git Integration Setup

## Overview
This guide sets up automatic deployments using Cloudflare's native Workers Builds system - no GitHub Actions needed!

## Quick Setup (5 minutes)

### Step 1: Connect GitHub Repository

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com) → **Workers & Pages**
2. Find `clodonic-api` worker
3. Click **Settings** → **Builds**
4. Click **Connect** button
5. Choose **GitHub** and authorize Cloudflare
6. Select repository: `kittholland/clodonic`
7. Configure build settings:
   - **Production branch**: `main`
   - **Root directory**: `/clodonic-api`
   - **Build command**: Leave empty (we don't need a build step)
   - **Build output directory**: Leave empty
8. Click **Save and Deploy**

### Step 2: Verify Worker Name Match

**IMPORTANT**: The worker name in Cloudflare dashboard (`clodonic-api`) MUST match the name in `wrangler.jsonc`:
```json
{
  "name": "clodonic-api",  // This must match!
  ...
}
```

### Step 3: Set Production Secrets

1. In Cloudflare Dashboard → **Workers & Pages** → `clodonic-api`
2. Go to **Settings** → **Environment variables**
3. Add production secrets:
   - `GITHUB_CLIENT_ID`: Your GitHub OAuth App ID
   - `GITHUB_CLIENT_SECRET`: Your GitHub OAuth App Secret (encrypt this one!)

### Step 4: Configure GitHub OAuth App

If not already done:
1. Go to GitHub → Settings → Developer settings → OAuth Apps
2. Create new OAuth App:
   - **Application name**: Clodonic
   - **Homepage URL**: `https://clodonic.ai`
   - **Authorization callback URL**: `https://clodonic.ai/auth/github/callback`

## How It Works

### Automatic Deployments
- **Push to main** → Automatically deploys to production
- **Open PR** → Creates preview deployment with unique URL
- **Merge PR** → Deploys to production

### Build Comments
Cloudflare automatically comments on PRs with:
- Build status
- Preview URL for testing
- Deployment logs link

### Version History
Every deployment creates a version you can:
- View in dashboard under **Deployments**
- Roll back instantly if needed
- Compare changes between versions

## Deployment Configuration

### Current Setup (`wrangler.jsonc`)
```json
{
  "name": "clodonic-api",
  "main": "src/index.ts",
  "compatibility_date": "2025-08-10",
  "assets": {
    "binding": "ASSETS",
    "directory": "./public"
  },
  "d1_databases": [{
    "binding": "DB",
    "database_name": "clodonic-db",
    "database_id": "3539acb6-6a74-4d45-9d2b-18f59ab561c0"
  }],
  "routes": [
    { "pattern": "clodonic.ai", "custom_domain": true },
    { "pattern": "www.clodonic.ai", "custom_domain": true }
  ]
}
```

### Environment Variables
- **Public vars** (in `wrangler.jsonc`): Non-sensitive config
- **Secrets** (in dashboard): OAuth credentials, API keys

## Monitoring Deployments

### View Build Status
1. **In Cloudflare**: Workers & Pages → `clodonic-api` → **Deployments**
2. **In GitHub**: Check runs on commits and PRs
3. **Build logs**: Click any deployment to see detailed logs

### Preview Deployments
Each PR gets a unique preview URL like:
```
https://[hash].clodonic-api.workers.dev
```

### Rollback Process
1. Go to **Deployments** tab
2. Find previous good version
3. Click **⋮** menu → **Rollback to this version**
4. Instant rollback (no rebuild needed!)

## Troubleshooting

### Build Fails: "Worker name mismatch"
- Ensure `wrangler.jsonc` name matches dashboard worker name
- Both must be `clodonic-api`

### Build Fails: "Cannot find module"
- Check `package.json` dependencies
- Ensure all imports are installed

### Preview URL not working
- Check if PR is from a fork (security restriction)
- Verify build completed successfully

### Secrets not available
- Secrets must be set in dashboard, not in `wrangler.jsonc`
- Use **Settings** → **Environment variables**

### Git integration disconnected
1. Go to **Settings** → **Builds**
2. Click **Manage** → **Reconnect**
3. Re-authorize if needed

## Manual Deployment (Backup)

If Git integration has issues:
```bash
# Deploy from local machine
wrangler deploy

# Deploy specific version
wrangler deploy --compatibility-date 2025-08-10

# View deployment history
wrangler deployments list

# Rollback
wrangler rollback [deployment-id]
```

## Security Best Practices

### Branch Protection
1. Go to GitHub repo → **Settings** → **Branches**
2. Add rule for `main`:
   - Require PR reviews
   - Require status checks (Cloudflare build)
   - Include administrators

### Secret Management
- **Never** commit secrets to `wrangler.jsonc`
- Use dashboard for all sensitive values
- Rotate OAuth secrets quarterly

### Preview Isolation
- Each preview runs in isolation
- Uses same D1 database (be careful with migrations!)
- Secrets are not exposed to previews by default

## Advanced Configuration

### Multiple Environments
Create `wrangler.staging.jsonc`:
```json
{
  "name": "clodonic-api-staging",
  "extends": "./wrangler.jsonc",
  "routes": [
    { "pattern": "staging.clodonic.ai", "custom_domain": true }
  ]
}
```

### Build Scripts
Add to `package.json` if you need build steps:
```json
{
  "scripts": {
    "build": "tsc",
    "deploy": "wrangler deploy"
  }
}
```

### Custom Domains
Already configured for:
- `clodonic.ai`
- `www.clodonic.ai`

Add more in dashboard → **Workers Routes**

## Monitoring & Logs

### Real-time Logs
```bash
wrangler tail

# Or in dashboard:
# Workers & Pages → clodonic-api → Logs
```

### Analytics
Dashboard shows:
- Request count
- Error rate
- CPU time
- Data transfer

### Alerts
Set up in dashboard → **Analytics** → **Notifications**:
- Error rate > 1%
- CPU time > 50ms
- 500 errors

## Cost Optimization

### Current Usage (Free Tier)
- 100,000 requests/day included
- 10ms CPU time per request
- Unlimited preview deployments

### Monitor Usage
Dashboard → **Analytics** → **Usage**

### Optimization Tips
- Cache API responses (we use Cloudflare Cache API)
- Minimize D1 queries
- Use static assets for images

## Team Collaboration

### Adding Team Members
1. Cloudflare Dashboard → **Manage Account** → **Members**
2. Invite with appropriate role:
   - **Administrator**: Full access
   - **Developer**: Deploy but not delete
   - **Read-only**: View only

### PR Workflow
1. Create feature branch
2. Push changes
3. Cloudflare comments with preview URL
4. Team reviews with live preview
5. Merge to deploy

## Next Steps

1. **Connect Git Integration**:
   - Follow Step 1 above in Cloudflare Dashboard
   - Takes ~2 minutes

2. **Set Secrets**:
   - Add `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET`
   - In dashboard under Environment variables

3. **Test Deployment**:
   ```bash
   git checkout -b test-deploy
   echo "# Test" >> README.md
   git add . && git commit -m "Test deployment"
   git push origin test-deploy
   ```
   - Create PR and check for Cloudflare comment

4. **Enable Monitoring**:
   - Set up alerts for errors
   - Review analytics weekly

---

**Last Updated**: 2025-08-10
**Documentation**: [Cloudflare Workers Builds](https://developers.cloudflare.com/workers/ci-cd/builds/)
**Support**: Cloudflare Dashboard → Support