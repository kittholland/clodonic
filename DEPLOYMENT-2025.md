# Deployment Guide for Clodonic (2025 Workers Approach)

## Overview
As of 2025, Cloudflare recommends using **Workers** for new projects (not Pages). This guide uses Workers with Git integration for automated deployments.

## Prerequisites
1. GitHub repository for your project
2. Cloudflare account
3. Domain configured in Cloudflare (clodonic.ai)

## Step 1: Create GitHub OAuth App
1. Go to https://github.com/settings/applications/new
2. Fill in:
   - Application name: `Clodonic`
   - Homepage URL: `https://clodonic.ai`
   - Authorization callback URL: `https://clodonic.ai/auth/github/callback`
3. Save the Client ID and Client Secret

## Step 2: Set Up Git Repository
```bash
cd /Users/kittholland/clodonic/clodonic-api
git init
git add .
git commit -m "Initial commit - Clodonic MVP"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/clodonic.git
git push -u origin main
```

## Step 3: Connect Workers to Git (Workers Builds)

### Option A: Via Cloudflare Dashboard (Easiest)
1. Go to Cloudflare Dashboard > Workers & Pages
2. Click "Create" > "Workers" 
3. Choose "Deploy from GitHub"
4. Authorize Cloudflare to access your GitHub
5. Select your repository and branch
6. Configure build settings:
   - Build command: `npm install`
   - Build output directory: `dist` (or leave empty for TS)
   - Root directory: `clodonic-api`

### Option B: Via Wrangler CLI
```bash
# Login to Cloudflare
wrangler login

# Initialize git integration
wrangler init --from-dash clodonic-api

# Connect to GitHub
wrangler deploy --dispatch-namespace github
```

## Step 4: Configure Environment Variables & Secrets

### Via Dashboard:
1. Go to Workers & Pages > your worker > Settings > Variables
2. Add environment variables:
   - `SITE_URL`: `https://clodonic.ai`
3. Add encrypted secrets:
   - `GITHUB_CLIENT_ID`: Your GitHub OAuth Client ID
   - `GITHUB_CLIENT_SECRET`: Your GitHub OAuth Client Secret

### Via CLI:
```bash
# Set secrets (encrypted)
wrangler secret put GITHUB_CLIENT_ID
wrangler secret put GITHUB_CLIENT_SECRET

# Set variables (plain text)
wrangler deploy --var SITE_URL:https://clodonic.ai
```

## Step 5: Configure D1 Database for Production

```bash
# The database already exists from local dev
# Just ensure it's bound in wrangler.jsonc

# Run migrations on remote database
wrangler d1 execute clodonic-db --remote --file=schema.sql

# Verify database
wrangler d1 execute clodonic-db --remote --command="SELECT name FROM sqlite_master WHERE type='table'"
```

## Step 6: Configure Custom Domain

1. Go to Cloudflare Dashboard > Workers & Pages
2. Select your worker (`clodonic-api`)
3. Go to Settings > Triggers > Custom Domains
4. Add:
   - `clodonic.ai`
   - `www.clodonic.ai` (redirect to apex)

## Step 7: Deployment Workflow

With Git integration enabled, deployments are automatic:

### Production Deployments:
- Push to `main` branch → Automatic production deployment
- Every commit creates a new version
- Automatic rollback available if issues occur

### Preview Deployments:
- Push to any other branch → Preview deployment
- Get unique preview URL for testing
- Comments on PRs with preview links

### Manual Deployment (if needed):
```bash
wrangler deploy --env production
```

## Step 8: Monitoring & Rollback

### View Logs:
```bash
# Real-time logs
wrangler tail

# Via dashboard
# Workers & Pages > your worker > Logs
```

### Rollback if needed:
```bash
# List all deployments
wrangler deployments list

# Rollback to previous
wrangler rollback

# Or via dashboard: Settings > Deployments > Rollback
```

## Deployment Checklist

- [ ] GitHub repository created and code pushed
- [ ] Workers connected to GitHub via dashboard or CLI
- [ ] GitHub OAuth app created with correct URLs
- [ ] Secrets configured (GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET)
- [ ] D1 database migrated to production
- [ ] Custom domain configured
- [ ] Test authentication flow
- [ ] Test pattern submission
- [ ] Verify API endpoints

## Ongoing Deployment

After initial setup, deployment is automatic:
1. Make changes locally
2. Commit and push to GitHub
3. Cloudflare automatically builds and deploys
4. Monitor via dashboard or `wrangler tail`

## Environment-Specific Configuration

The app automatically detects environment:
- Local dev: Uses `http://localhost:8787`
- Production: Uses `SITE_URL` variable (`https://clodonic.ai`)

## Security Notes

- Never commit secrets to git
- Use Cloudflare secrets for sensitive data
- Enable 2FA on GitHub and Cloudflare accounts
- Regularly rotate OAuth credentials
- Monitor for unusual activity via Cloudflare Analytics

## Cost Optimization

- Workers Free Tier: 100,000 requests/day
- D1 Free Tier: 5GB storage, 5M rows read/day
- Static assets served free (no request charges)
- Monitor usage in Cloudflare Dashboard

## Troubleshooting

### Build Failures:
- Check build logs in Cloudflare Dashboard
- Ensure `package.json` and dependencies are correct
- Verify `wrangler.jsonc` configuration

### Auth Issues:
- Verify GitHub OAuth app settings
- Check secrets are properly set
- Ensure redirect URLs match exactly

### Database Issues:
- Verify D1 binding in `wrangler.jsonc`
- Check migrations ran successfully
- Use `wrangler d1 execute` to debug

## Additional Resources

- [Cloudflare Workers Builds Documentation](https://developers.cloudflare.com/workers/ci-cd/builds/)
- [Git Integration Guide](https://developers.cloudflare.com/workers/ci-cd/builds/git-integration/)
- [D1 Documentation](https://developers.cloudflare.com/d1/)
- [Workers Best Practices](https://developers.cloudflare.com/workers/best-practices/)