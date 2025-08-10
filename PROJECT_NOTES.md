# Clodonic Project Notes

## Quick Start Commands
```bash
# Start local dev server
cd clodonic-api
npm run dev

# Open local site
open http://localhost:8787

# Deploy to production
npm run deploy

# Check deployment
open https://clodonic.ai
```

## Critical Decisions Made
1. **No R2 for MVP** - Store patterns directly in D1 as text (simpler)
2. **Auth can wait** - Launch with anonymous-only, add auth in week 2
3. **No comments** - Not a discussion forum, just a pattern library
4. **Unified feed** - All pattern types in one stream (not separate tabs)
5. **Display names only** - No user profiles, avatars, or social features

## Known Issues
- R2 not enabled yet (not needed for MVP)
- D1 free tier limits start Feb 10, 2025 (watch usage)
- Remote database not created yet (using local for now)

## MVP Checklist (Priority Order)
1. [ ] Create homepage with pattern list
2. [ ] Add submit form (anonymous only)
3. [ ] Implement search
4. [ ] Add copy button functionality
5. [ ] Deploy to clodonic.ai
6. [ ] Seed with 5-10 patterns from your analysis
7. [ ] Test on mobile
8. [ ] Launch on Reddit r/ClaudeAI

## Post-MVP Features (Week 2)
- GitHub OAuth
- Voting system
- User attribution
- MCP server
- Download tracking

## Seed Content Ideas (From Your Analysis)
1. "Never Use Parallel Tasks for Writes" (prompt)
2. "Read-Only Task Pattern" (CLAUDE.md)
3. "No Sleep Commands" (hook)
4. "Python FastAPI + Testing" (CLAUDE.md)
5. "Git Commit Without Push" (prompt)
6. "Prevent Large File Commits" (hook)
7. "Database Migration Validator" (agent)

## Security Reminders
- Sanitize all HTML output
- Use parameterized queries (D1 does this)
- Rate limit by IP (Cloudflare will handle)
- No eval() or Function() constructor
- Content size limits enforced

## API Endpoints Needed
```
GET  /api/items?type=&sort=&limit=30
GET  /api/items/:id
POST /api/items
GET  /api/search?q=

Later:
POST /api/auth/github
POST /api/vote/:id
GET  /api/user/:username/items
```

## Database Quick Reference
```sql
-- Main tables
items (id, type, title, description, content, file_hash, votes_up, votes_down)
tags (id, name, category)
item_tags (item_id, tag_id)

-- After auth added
users (id, email, display_name, auth_provider)
votes (user_id, item_id, vote)
```

## Deployment Notes
- Domain: clodonic.ai (already registered)
- Cloudflare account: kittholland@gmail.com
- Project ID: Will be created on first deploy
- Don't forget to set up custom domain after deploy

## Marketing Plan
1. Soft launch with 10 patterns
2. Post on r/ClaudeAI: "I analyzed 700 lost Claude Code tasks and built a pattern library"
3. Cross-post to r/LocalLLaMA if well received
4. Submit to HN after 50+ patterns (better chance of traction)

## Revenue Ideas (Future)
- Keep it free forever for community
- Maybe add "Pro" badge for supporters ($3/month)
- Never add ads
- Consider GitHub Sponsors

## Remember
- You're building this because you lost 700 task results
- Every pattern should solve a real problem
- Quality > Quantity
- Ship fast, iterate based on feedback

## Contact for Issues
- GitHub: Create anthropics/claude-code issue and mention patterns
- Reddit: Post in r/ClaudeAI
- Email: Save for DMCA only

Ready to build! When you restart, just:
1. cd clodonic/clodonic-api
2. npm run dev
3. Start with the homepage HTML