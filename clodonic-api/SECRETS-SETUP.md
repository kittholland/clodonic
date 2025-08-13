# Secrets Configuration Guide

## Overview
As of August 2025, Cloudflare Workers best practice is to use encrypted secrets instead of environment variables for sensitive data. This provides:
- Encryption at rest
- No exposure in logs or source code
- Secure runtime access only
- Separate management from code

## Required Secrets

### 1. `GITHUB_CLIENT_ID`
Your GitHub OAuth application's Client ID.
- Get from: https://github.com/settings/developers
- Example: `Iv1.8a61f9b3a7aba766`

### 2. `GITHUB_CLIENT_SECRET`
Your GitHub OAuth application's Client Secret.
- Get from: https://github.com/settings/developers
- Example: `308f9d3f9dc6e329b6f9b3a766798a61f9b3a7ab`
- **NEVER commit this to git!**

### 3. `SESSION_SECRET`
A random string used to encrypt session data with AES-256-GCM.
- Generate with: `openssl rand -base64 32`
- Example: `K7gNU3sdo+OL0wNhqoVWhr3g6s1xYv72ol/pe/Unols=`
- **Must be the same across all environments**

## Setup Instructions

### Automated Setup (Recommended)
```bash
cd clodonic-api
./setup-secrets.sh
```

### Manual Setup
```bash
# For local development
echo "your-github-client-id" | wrangler secret put GITHUB_CLIENT_ID
echo "your-github-client-secret" | wrangler secret put GITHUB_CLIENT_SECRET
echo "your-session-secret" | wrangler secret put SESSION_SECRET

# For production (add --remote flag)
echo "your-github-client-id" | wrangler secret put GITHUB_CLIENT_ID --remote
echo "your-github-client-secret" | wrangler secret put GITHUB_CLIENT_SECRET --remote
echo "your-session-secret" | wrangler secret put SESSION_SECRET --remote
```

### Verify Secrets
```bash
# List local secrets
wrangler secret list

# List production secrets
wrangler secret list --remote
```

## Security Notes

1. **Never put secrets in wrangler.toml** - Use `wrangler secret` command
2. **Use different secrets per environment** - Don't share production secrets with dev
3. **Rotate secrets regularly** - Especially if exposed
4. **Keep SESSION_SECRET consistent** - Or existing sessions will fail to decrypt

## Migration from Environment Variables

If you previously used environment variables in `wrangler.toml`:
1. Remove them from `wrangler.toml`
2. Add them as secrets using the commands above
3. The code automatically uses secrets (no changes needed)

## Troubleshooting

### "Secret not found" errors
- Ensure you've set the secret for the correct environment (local vs remote)
- Check spelling matches exactly (case-sensitive)

### Session decryption failures
- SESSION_SECRET must be the same as when sessions were created
- Old sessions may need to be cleared after changing the secret

### OAuth login failures
- Verify GitHub OAuth app settings match your environment
- Check callback URLs are correct for your domain