# Clodonic Project Context

## Project Overview
Building a minimalist pattern repository for Claude Code best practices at clodonic.ai

## Tech Stack
- **Frontend**: Static HTML/CSS with minimal JS
- **Backend**: Cloudflare Workers with Hono
- **Database**: Cloudflare D1 (SQLite)
- **Auth**: GitHub OAuth (extensible to other providers)
- **Deployment**: Cloudflare Workers with Git integration

## Project Structure
```
/clodonic
  /clodonic-api          - Hono API on Workers
    /src                 - API source code
      - index.ts         - Main API routes
      - auth.ts          - OAuth logic
    /public              - Static frontend files
    - schema.sql         - D1 database schema
    - wrangler.jsonc     - Cloudflare config
  - REQUIREMENTS.md      - Full requirements spec
  - DEPLOYMENT-2025.md   - Current deployment guide
  - BRANDING.md          - Design system
  - README.md            - Project overview
```

## Current Status
- [x] Domain registered and DNS configured (clodonic.ai)
- [x] MVP complete with all core features
- [x] GitHub OAuth implemented
- [x] Database deployed to production with sample data
- [x] Worker deployed with Custom Domains
- [x] Git repository at github.com/kittholland/clodonic
- [x] Production logging and monitoring implemented
- [x] Rate limiting (30 patterns/hr, 10 votes/min)
- [x] All error handling fixed (vote endpoint 500 → 401)
- [x] Enhanced validation system for instructional content security
- [x] Cloudflare Workers GitHub app installed and configured

## Development Commands
```bash
# Local development
npm run dev              # Start at http://localhost:8787

# Database
wrangler d1 execute clodonic-db --local --file=schema.sql   # Local DB
wrangler d1 execute clodonic-db --remote --file=schema.sql  # Prod DB

# Deployment
wrangler deploy          # Deploy to production
wrangler tail            # View production logs
```

## Key Learnings (2025)
- **Workers over Pages**: Cloudflare recommends Workers for new projects
- **Custom Domains**: Automatically handles DNS setup (no manual A records)
- **Git Integration**: Workers Builds enables auto-deploy on push
- **Playwright MCP**: Added via `claude mcp add playwright`
- **Auth Design**: Keep extensible for multiple providers, not just GitHub

## Documentation
- **DEPLOYMENT-2025.md**: Step-by-step deployment guide
- **REQUIREMENTS.md**: Full feature specifications
- **BRANDING.md**: Design system and visual guidelines

## Production Details
- **URL**: https://clodonic.ai
- **GitHub**: https://github.com/kittholland/clodonic
- **OAuth**: Configured for production callbacks