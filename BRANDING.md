# Clodonic Brand Guide

## Visual Identity

### Logo Concept
```
[c] clodonic
```
- Simple bracketed 'c' suggesting code blocks
- No complex graphics
- Text-based, works everywhere

### Color Palette

#### Primary
- **Claude Orange**: #FF6600 (HN orange, familiar to tech audience)
- **Pure Black**: #000000 (high contrast text)
- **Background Beige**: #F6F6EF (HN background, easy on eyes)

#### Secondary  
- **Muted Gray**: #828282 (metadata, secondary text)
- **Code Background**: #F8F8F8 (slight gray for code blocks)
- **Success Green**: #27AE60 (sparingly, for success states)
- **Error Red**: #CC0000 (sparingly, for errors)

### Typography

#### Headers
- System font stack: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto
- Bold weight for emphasis
- Size: 16px (h1), 14px (h2), 13px (h3)

#### Body Text
- Same system font stack
- Regular weight
- Size: 14px (standard), 13px (compact lists)
- Line height: 1.6

#### Code
- Monospace stack: 'SF Mono', Monaco, 'Cascadia Code', monospace
- Size: 13px
- Background: #F8F8F8
- Padding: 2px 4px (inline), 12px (blocks)

### Layout Principles

#### Grid
- Single column primary content
- Max width: 1200px (list views), 800px (detail views)
- Padding: 10px mobile, 20px desktop
- No sidebars (focus on content)

#### Spacing
- Compact but readable
- 4px between list items
- 8px between sections
- 16px between major blocks

#### Responsive Breakpoints
- Mobile: < 640px (stack navigation)
- Tablet: 640-1024px (default layout)
- Desktop: > 1024px (optimal experience)

### UI Components

#### Navigation Bar
```
[c] clodonic    CLAUDE.md  Agents  Prompts  Hooks  Commands    [Submit]
```
- Fixed height: 32px
- Orange background
- Black text, no underlines
- Hover: underline

#### List Item
```
▲ 234  Rails Development CLAUDE.md
       2.3KB • ruby, rails • 3 days ago • anonymous
```
- Vote arrow: 8px triangle
- Title: black, turns gray when visited
- Metadata: smaller, gray
- Compact single or two-line layout

#### Detail View
```
Rails Development CLAUDE.md
━━━━━━━━━━━━━━━━━━━━━━━━━
▲ 234 ▼ 12

Description:
Comprehensive rules for Rails apps with Claude Code,
including testing patterns and deployment workflows.

Tags: ruby, rails, testing, deployment

[View Raw] [Download] [Copy] [Install via CLI]

═══ Content ═══
[Displayed in monospace]
```

### Interaction States

#### Hover
- Links: underline
- Buttons: darken 10%
- Vote arrows: change to orange

#### Active/Pressed
- Buttons: darken 20%
- Brief scale(0.98) transform

#### Focus
- 2px orange outline
- No outline removal (accessibility)

#### Visited Links
- Pattern titles: #828282 (gray)
- Navigation: no change

### Icons & Symbols

Minimal icon use:
- ▲ Upvote (Unicode triangle)
- ▼ Downvote (if implemented)
- ★ Favorite (future)
- 🔗 External link (sparingly)

No icon fonts or SVG libraries.

### Error & Success States

#### Success
- Green background: #E8F5E9
- Green border: #27AE60
- Black text

#### Error
- Red background: #FFEBEE
- Red border: #CC0000
- Black text

#### Warning
- Orange background: #FFF3E0
- Orange border: #FF6600
- Black text

### Page Templates

#### Homepage
- Header with navigation
- Filter bar (Hot/Top/New)
- List of patterns
- Load more button at bottom

#### Detail Page
- Breadcrumb: Home > Type > Pattern
- Title and vote count
- Description
- Action buttons
- Content display
- Related patterns

#### Submit Page
- Simple form
- Live preview (optional)
- Clear validation messages
- Submit/Cancel buttons

### Copy & Microcopy

#### Button Labels
- "Submit" not "Submit Pattern"
- "Vote" not "Upvote this"
- "Copy" not "Copy to Clipboard"

#### Empty States
- "No patterns yet. Be the first to submit."
- "No results. Try different keywords."
- "Nothing here. Check back later."

#### Error Messages
- "Title required"
- "Content too large (max 10KB)"
- "Duplicate content exists [link]"

### Animation & Transitions

Minimal, functional only:
- No page transitions
- No loading spinners (too fast to need them)
- Subtle hover states (100ms ease)
- Vote count increment (200ms ease)

### Accessibility

- Semantic HTML
- ARIA labels where needed
- Keyboard navigation
- High contrast ratios (WCAG AA)
- Works without JavaScript
- Screen reader tested

### Brand Application Examples

#### Social Sharing
```
Title: Pattern Name | Clodonic
Description: [First 150 chars of description]
Image: Simple text card with pattern title
```

#### CLI Output
```
$ claude install clodonic://prompts/445
✓ Installed "Parallel-Safe Analysis Prompt"
```

#### Email (if needed)
- Plain text preferred
- Same color scheme if HTML
- No marketing graphics

## What Clodonic is NOT

- Not a social network
- Not a code hosting platform
- Not a Claude Code replacement
- Not a commercial product
- Not tracking-heavy
- Not JavaScript-dependent
- Not animated or playful
- Not cluttered

## Inspiration & References

- **HackerNews**: Minimalism, orange, community-driven
- **lobste.rs**: Tag system, quality focus
- **man pages**: Dense information, no fluff
- **curl.se**: Simple, fast, focused
- **Python PEPs**: Authoritative pattern documentation

## Implementation Notes

1. Start with pure HTML/CSS
2. Add minimal JS for interactions
3. Progressive enhancement only
4. Test on slow connections
5. Validate with screen readers
6. Monitor Core Web Vitals

The goal: When someone visits Clodonic, they should immediately understand it's a serious, useful tool for Claude Code users, not another flashy dev tool site.