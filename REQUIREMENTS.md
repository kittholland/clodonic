# Clodonic - Requirements & Design Document

## Mission Statement
A minimalist pattern repository for Claude Code best practices, making idiomatic usage discoverable and shareable.

## Core Requirements

### 1. Content Types
- **CLAUDE.md files** - Project context and rules
- **Agent definitions** - Reusable subagent configurations
- **Prompts** - Tested, effective prompts
- **Hooks** - Shell scripts for Claude Code events
- **Commands** - Custom slash commands

### 2. User Actions

#### Anonymous Users Can:
- Browse all content
- Search patterns
- Download/copy patterns
- Upload new patterns
- View user-filtered content (/?user=username)

#### Authenticated Users Can Additionally:
- Upvote/downvote patterns
- Get attribution for submissions
- Edit their submissions (time-limited)
- Have a unique display name
- View their submissions list

### 3. Core Features

#### Discovery
- Browse by type (unified feed with type filters)
- Sort by: Trending (default), Top (all-time), New
- Search by keyword
- Filter by tags (language, framework, purpose, safety level)
- Filter by user (click username to see their patterns)
- Time filters for Top: Today, Week, Month, All Time
- "Works well with" relationships (future)

#### Submission
- Title (required, 100 char max)
- Description (required, markdown, 500 char max)
- Content (required, type-specific limits)
- Tags (at least 1 required, max 5)
- Anonymous by default, attribution if logged in

#### Quality Control
- Duplicate detection via content hashing
- Size limits per type
- Basic validation (YAML for agents, shellcheck for hooks)
- Community voting
- Flag for review (authenticated only)

#### Integration
- Direct install URLs for each pattern
- MCP server for Claude to access patterns
- Copy-to-clipboard for all patterns
- Raw download links

### 4. Technical Constraints

#### Security
- Rate limiting on all endpoints
- CSRF protection
- Content sanitization
- No execution of uploaded code
- Cloudflare DDoS protection
- Username validation and filtering
- Shadow-ban capability for subtle abuse

#### Performance
- Static HTML, minimal JS
- Server-side rendering
- Edge caching
- < 100ms response times

#### Limits
- CLAUDE.md: 10KB max
- Agents: 5KB max
- Prompts: 500 chars max
- Hooks: 5KB max
- Commands: 2KB max

## Non-Functional Requirements

### Design Principles
1. **Pattern Library Aesthetic** - Card-based, not news-feed style
2. **Fast** - Instant page loads, no spinners
3. **Accessible** - Works without JS, screen reader friendly
4. **Mobile-friendly** - Responsive but desktop-first
5. **Unified Feed** - All pattern types in one stream with filtering
6. **Preview-Rich** - Show enough content to judge quality without clicking

### Scalability
- Handle Reddit/HN traffic spikes
- Cost < $50/month even when viral
- Zero-downtime deployments

### Community
- Open source on GitHub
- Accept PRs for patterns
- Transparent moderation
- No ads, tracking minimal

## MVP Scope (Launch)

### Must Have
- Browse patterns by type
- Search functionality
- Anonymous upload
- Voting (with simple auth)
- Basic anti-spam measures

### Nice to Have (Post-Launch)
- MCP server integration
- GitHub SSO
- Edit/delete own submissions
- Advanced search filters
- API for tools

### Out of Scope (For Now)
- Comments/discussions
- User profiles
- Private patterns
- Version history
- Pattern forking

## Success Metrics
- 100+ patterns in first month
- 1000+ weekly active users
- < 5% spam/low-quality submissions
- Becomes referenced in Claude Code discussions

## Branding Notes

### Name: Clodonic
- Play on "Pythonic" - immediately understood by developers
- Suggests "the idiomatic way to use Claude"
- Memorable, unique, searchable

### Tagline Options
- "Idiomatic Claude Code patterns"
- "The Claude Code cookbook"
- "How to Claude, properly"
- "Community patterns for Claude Code"

### Voice & Tone
- **Technical but approachable** - Assume technical audience
- **Concise** - No fluff, get to the point
- **Helpful** - Focus on solving real problems
- **Neutral** - Let patterns speak for themselves

### Visual Identity
- **Colors**: Orange (#ff6600) + grayscale
- **Typography**: System fonts, monospace for code
- **Layout**: Single column, generous whitespace
- **Icons**: Minimal, only where necessary (▲ for upvote)

## User Stories

### Discoverer
"As a Claude Code user, I want to find proven patterns for my use case, so I can avoid common pitfalls"

### Contributor  
"As someone who's found a great pattern, I want to share it with the community, so others benefit from my experience"

### Learner
"As a new Claude Code user, I want to see examples of idiomatic usage, so I can learn best practices"

### Tool Builder
"As a tool developer, I want to access patterns programmatically, so I can integrate them into my Claude Code workflow"

## Authentication & User System

### Auth Providers
- GitHub OAuth (primary - developer focused)
- Google OAuth (secondary)
- Email/password (future, if needed)

### User Model
- Minimal profile - just display name
- No avatars, bios, or social features
- Display name: unique, 3-20 chars, alphanumeric + underscore
- One-time setup after first OAuth login
- Change display name allowed once per 30 days

### Username Validation
- **Profanity filtering** via bad-words npm package
- **Reserved names** via reserved-usernames package
- **Custom banned patterns**:
  - System names (admin, clodonic, system, api)
  - Misleading names (anon*, deleted*, user123 patterns)
  - Impersonation attempts (*_official, admin_*)
- **Homograph detection** for lookalike characters
- **Shadow-ban capability** for subtle trolls

### Auth UI/UX
- Minimal header: "Sign In" when logged out, display name when logged in
- Vote prompts: Inline modal when anonymous user tries to vote
- User filtering: Click any username to see their submissions (/?user=username)
- No separate profile pages - just filtered pattern lists

## Metrics & Tracking

### What We Track
- **Pattern count** - Total and by type
- **Vote counts** - Up/down per pattern
- **Download/Copy clicks** - Per pattern
- **View counts** - Pattern detail views
- **MCP fetches** - API calls from Claude
- **CLI downloads** - Direct curl/wget access
- **User submissions** - Patterns per user
- **Auth methods** - GitHub vs Google vs anon

### What We Display
- Total patterns
- New today/this week
- Downloads/uses this week
- Vote counts per pattern
- Contributor count
- MCP usage (once meaningful)

### What We Don't Track/Display
- Success rates (impossible to measure)
- "Installs" (misleading term)
- User reputation scores
- Following/followers
- Complex analytics

## Technical Decisions

### Why Cloudflare?
- Native MCP support (unique in 2025)
- Built-in DDoS protection
- Edge performance
- Cost-effective at scale
- One-click deploys

### Why Hono?
- Lightweight (perfect for Workers)
- TypeScript-first
- Fast routing
- Good middleware ecosystem

### Why D1 + R2?
- D1 for metadata (SQL queries)
- R2 for file storage (if needed later)
- Both included in Cloudflare
- No egress fees

### Why Minimal Frontend?
- Fastest possible loads
- Works everywhere
- Less to break
- Focus on content, not chrome