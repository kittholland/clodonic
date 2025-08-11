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
  /clodonic-api          - Full-stack Hono app (API + UI)
    /src                 - API source code
      - index.ts         - Main API routes
      - auth.ts          - OAuth logic  
    /public              - Frontend files (HTML/CSS/JS)
    - schema.sql         - D1 database schema
    - seed-data-2025.sql - Production seed data
    - wrangler.jsonc     - Cloudflare config
  /clodonic-mcp-server   - MCP server for Claude Code
    /src                 - MCP implementation
      - index.ts         - Pattern tools (search/install)
    - wrangler.jsonc     - MCP server config
  - REQUIREMENTS.md      - Full requirements spec
  - DEPLOYMENT-2025.md   - Current deployment guide
  - BRANDING.md          - Design system
  - README.md            - Project overview
```

## Current Status
- [x] Domain registered and DNS configured (clodonic.ai)
- [x] MVP complete with all core features
- [x] GitHub OAuth implemented
- [x] Database deployed with comprehensive seed data (22 patterns)
- [x] Full-stack Worker deployed with Custom Domains
- [x] MCP server deployed at mcp.clodonic.ai for Claude Code integration
- [x] Git repository at github.com/kittholland/clodonic
- [x] Production logging and monitoring implemented
- [x] Rate limiting (30 patterns/hr, 10 votes/min)
- [x] Enhanced validation system for instructional content security
- [x] Monorepo auto-deployment with watch paths configured
- [x] Improved homepage UX with MCP hero section and expandable code blocks
- [x] Comprehensive tag system (108 tags) with proper associations

## Development Commands
```bash
# Local development (API + UI)
cd clodonic-api && npm run dev              # Start at http://localhost:8787

# Local development (MCP server)  
cd clodonic-mcp-server && wrangler dev      # Start MCP server locally

# Database
wrangler d1 execute clodonic-db --remote --file=schema.sql       # Reset schema
wrangler d1 execute clodonic-db --remote --file=seed-data-2025.sql # Load seed data

# Manual deployment (auto-deploy preferred)
cd clodonic-api && wrangler deploy          # Deploy main app
cd clodonic-mcp-server && wrangler deploy   # Deploy MCP server
wrangler tail                               # View production logs

# MCP integration
claude mcp add https://mcp.clodonic.ai      # Install MCP server in Claude Code

# Playwright/Browser issues - DO NOT kill all Chrome processes!
# If you get "browser is already in use" error:
ps aux | grep "ms-playwright\|mcp-chrome" | grep -v grep  # Find ONLY Playwright processes
# Look for the main Chrome process (not renderer/helper) with --user-data-dir=.../ms-playwright/mcp-chrome
# Kill only that specific PID: kill <PID>
```

## Key Learnings (2025)
- **Workers over Pages**: Cloudflare recommends Workers for new projects
- **Custom Domains**: Automatically handles DNS setup (no manual A records)
- **Git Integration**: Workers Builds enables auto-deploy on push (install GitHub app first!)
- **Playwright MCP**: Added via `claude mcp add playwright`
- **Auth Design**: Keep extensible for multiple providers, not just GitHub
- **Validation**: 3-tier system (BLOCK/WARN/ALLOW) for both code and instructions
- **Tag System**: Curated tags prevent typos and trolling vs user-submitted
- **UX**: Client-side filtering > server-side for instant response

## Documentation
- **DEPLOYMENT-2025.md**: Step-by-step deployment guide
- **REQUIREMENTS.md**: Full feature specifications
- **BRANDING.md**: Design system and visual guidelines

## Production Details
- **URL**: https://clodonic.ai
- **GitHub**: https://github.com/kittholland/clodonic
- **OAuth**: Configured for production callbacks