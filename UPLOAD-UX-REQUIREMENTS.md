# Upload UX & Metadata Requirements

## Current State Analysis
- We have an `item_metadata` table with proper columns
- Seed data populates metadata (especially event_type for hooks)
- BUT: API doesn't read/write metadata at all
- MCP server guesses event_type from description (unreliable)
- Upload form doesn't collect critical metadata

## Critical Issues to Fix

### 1. Hook Event Type (HIGHEST PRIORITY)
**Problem:** Hooks MUST have event_type (PreToolUse/PostToolUse/UserPromptSubmit) to install correctly
**Current:** MCP server guesses from description - often wrong
**Solution:** 
- Add event type selector to upload form for hooks
- Store in item_metadata.event_type
- MCP server reads from metadata instead of guessing

### 2. API Metadata Support
**Problem:** API completely ignores item_metadata table
**Required Changes:**

#### POST /api/items (Create)
```javascript
// After inserting item, also insert metadata
if (type === 'hook' && metadata.eventType) {
  await db.prepare(
    'INSERT INTO item_metadata (item_id, event_type) VALUES (?, ?)'
  ).bind(itemId, metadata.eventType).run();
}

if (type === 'agent' && metadata.tools) {
  await db.prepare(
    'INSERT INTO item_metadata (item_id, tools_required) VALUES (?, ?)'
  ).bind(itemId, JSON.stringify(metadata.tools)).run();
}

if (type === 'command' && metadata.supportsArgs !== undefined) {
  await db.prepare(
    'INSERT INTO item_metadata (item_id, command_trigger) VALUES (?, ?)'
  ).bind(itemId, metadata.supportsArgs ? 'arguments' : 'fixed').run();
}
```

#### GET /api/items (List)
```sql
-- Join metadata when fetching items
SELECT 
  i.*,
  m.event_type,
  m.tools_required,
  m.command_trigger
FROM items i
LEFT JOIN item_metadata m ON i.id = m.item_id
```

### 3. Submit Form Updates

#### Required Form Fields by Type:

**HOOKS:**
- Event Type dropdown (REQUIRED)
  - PreToolUse - Before tool execution
  - PostToolUse - After tool execution  
  - UserPromptSubmit - On user input
- Auto-extract matcher from JSON content
- Show in title: "PreToolUse Hook for Bash"

**AGENTS:**
- Auto-extract tools from YAML `tools:` field
- Display as: "Requires: Read, Write, Bash" or "All tools"

**COMMANDS:**
- Auto-detect $ARGUMENTS usage
- Show indicator if arguments supported

### 4. MCP Server Updates

```typescript
// In generateHookInstructions()
// Instead of guessing:
const hookType = pattern.metadata?.event_type || 'PostToolUse';

// Instead of extractHookType(), use:
const eventType = pattern.metadata?.event_type;
if (!eventType) {
  throw new Error('Hook missing required event_type metadata');
}
```

### 5. Display Updates

#### Pattern Cards Should Show:
- Hooks: Event type badge (PreToolUse/PostToolUse/etc)
- Agents: Tool requirements
- Commands: "Supports arguments" indicator

## Implementation Priority

### Phase 1: Critical Hook Fix (MUST HAVE)
1. Add event_type dropdown to submit form for hooks
2. Update API POST /api/items to save event_type to metadata
3. Update API GET to include metadata in response
4. Update MCP server to use metadata.event_type

### Phase 2: Complete Metadata Support
1. Add agent tools extraction/display
2. Add command arguments detection
3. Update pattern cards to show metadata

### Phase 3: Enhanced UX
1. Add hook extractor tool (already created)
2. Add format templates/examples (already created)
3. Add "Where to find" helper section
4. Better title extraction for all types

## Database Migration Needed

```sql
-- Ensure metadata table exists (already in schema.sql)
-- No schema changes needed, just need to use it!

-- Clean up event_type values if needed
UPDATE item_metadata 
SET event_type = 'PreToolUse' 
WHERE event_type IN ('pre-tool-use', 'pretooluse', 'pre_tool_use');

UPDATE item_metadata 
SET event_type = 'PostToolUse' 
WHERE event_type IN ('post-tool-use', 'posttooluse', 'post_tool_use');

UPDATE item_metadata 
SET event_type = 'UserPromptSubmit' 
WHERE event_type IN ('user-prompt-submit', 'userpromptsubmit', 'user_prompt_submit');
```

## Testing Requirements

1. Upload a hook and verify event_type is saved
2. Install hook via MCP and verify correct event placement
3. Verify pattern cards show metadata badges
4. Test that old patterns without metadata still work

## Success Criteria

- [ ] Hooks can be uploaded with explicit event type
- [ ] MCP server installs hooks to correct event (no guessing)
- [ ] Pattern cards show relevant metadata
- [ ] API properly reads/writes item_metadata table
- [ ] Existing patterns continue working

## Notes for Implementation

- Keep metadata minimal - only functional requirements
- Use tags for discovery/categorization  
- Event type is CRITICAL for hooks - should be required field
- Tools for agents can be auto-extracted from YAML
- Command args can be auto-detected from $ARGUMENTS

## Files to Modify

1. `/clodonic-api/src/index.ts` - Add metadata support to API
2. `/clodonic-api/public/submit.html` - Add event type selector
3. `/clodonic-api/public/index.html` - Show metadata on pattern cards
4. `/clodonic-mcp-server/src/index.ts` - Use metadata instead of guessing
5. `/clodonic-api/src/types.ts` - Add metadata types if needed

## Example User Flow

1. User selects "Hook" pattern type
2. Form shows "Event Type" dropdown (required)
3. User selects "PreToolUse"
4. User pastes hook JSON configuration
5. On submit: event_type saved to item_metadata
6. Pattern card shows "PreToolUse" badge
7. MCP install uses event_type from metadata
8. Hook installs to correct section of settings.json

This ensures hooks work correctly first time, every time!