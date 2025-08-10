# Clodonic API

Hono-based API running on Cloudflare Workers for the Clodonic pattern repository.

## Development

```bash
npm install
npm run dev        # Start at http://localhost:8787
```

## Deployment

```bash
wrangler deploy    # Manual deployment
# OR
git push           # Auto-deploy via GitHub integration
```

## Architecture

### Validation System (3-Tier)
- **BLOCK**: Spam, phishing, malicious instructions
- **WARN**: Dangerous patterns with warning badges
- **ALLOW**: Safe content passes through

### Key Components
- `/src/index.ts` - Main API routes
- `/src/validation.ts` - Content security validation
- `/src/contentValidators.ts` - Type-specific validators (YAML, shell, etc.)
- `/src/schemas.ts` - Zod input validation
- `/src/auth.ts` - GitHub OAuth implementation

### Database
- **D1 (SQLite)** - Cloudflare's edge database
- **Curated tags** - 135 pre-defined tags across 9 categories
- **Warning tracking** - Patterns with warnings get badges

### Rate Limiting
- Pattern submissions: 30/hour
- Voting: 10/minute

### Frontend
- Client-side filtering for instant UX
- No page refreshes on filter changes
- Toggle filters on/off by clicking twice