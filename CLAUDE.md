# Clodonic Project Context

## Project Overview
Building a minimalist pattern repository for Claude Code best practices at clodonic.ai

## Tech Stack
- **Frontend**: Static HTML/CSS with minimal JS
- **Backend**: Cloudflare Workers with Hono
- **Database**: Cloudflare D1 (SQLite)
- **Storage**: Cloudflare R2 (when enabled)
- **Auth**: GitHub/Google OAuth
- **Deployment**: Cloudflare Pages + Workers

## Project Structure
```
/clodonic
  /clodonic-api      - Hono API on Workers
    /src             - API source code
    /public          - Static frontend files
  REQUIREMENTS.md    - Full requirements spec
  BRANDING.md       - Design system
  schema.sql        - D1 database schema
```

## Current Status
- [x] Domain registered (clodonic.ai)
- [x] Requirements defined
- [x] Branding established
- [x] Database schema created
- [x] Basic API structure
- [ ] R2 bucket (awaiting activation)
- [ ] Frontend implementation
- [ ] Auth system
- [ ] MCP server
- [ ] Deploy to production

## Development Commands
```bash
# Local development
cd clodonic-api
npm run dev

# Deploy to Cloudflare
npm run deploy

# Database migrations
wrangler d1 execute clodonic-db --local --file=../schema.sql
wrangler d1 execute clodonic-db --remote --file=../schema.sql
```

## Key Decisions
- Unified feed (not separate charts per type)
- Minimal auth (just display names, no profiles)
- Card-based design (not HN clone)
- Focus on quality patterns over social features

## Next Steps
1. Build the MVP frontend
2. Implement core API endpoints
3. Add basic auth with GitHub OAuth
4. Deploy to clodonic.ai
5. Seed with initial patterns
6. Launch on Reddit/HN