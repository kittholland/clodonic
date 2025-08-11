# Clodonic MCP Implementation Plan

## Overview
The Clodonic MCP server acts as a "package manager instruction generator" that returns structured, actionable responses for Claude Code to execute using its native file manipulation tools.

## Core Architecture

### MCP Tool Responsibilities
- **Search patterns** - Query the Clodonic API
- **Fetch pattern details** - Retrieve full pattern content
- **Generate installation instructions** - Return structured, type-specific plans
- **Track installations** - Provide manifest entries for tracking

### Claude Code Responsibilities
- **Execute file operations** - Use Write/Edit tools to create/modify files
- **Apply immediate patterns** - Use prompts in current context
- **Handle user confirmation** - Ask before making changes
- **Manage restarts** - Instruct user when restart is needed

## Pattern Types & Installation Strategies

### 1. 📝 claude_md (Instructions Package)
**What**: Persistent behavioral rules for Claude
**Installation**: Append to CLAUDE.md with markers
**Activation**: Immediate (loaded at session start)
**Restart Required**: No

```markdown
<!-- BEGIN CLODONIC: pattern-slug (ID: 42) -->
<!-- Installed: 2025-08-11 | Version: 1.0.0 -->
Pattern content here...
<!-- END CLODONIC: pattern-slug -->
```

### 2. 🤖 agent (Capability Package)
**What**: Specialized sub-agents for delegation
**Installation**: Create YAML + register in claude.json
**Activation**: After restart
**Restart Required**: Yes

Files created:
- `.claude/agents/clodonic-{slug}.yaml` - Agent definition
- `.claude/claude.json` - Registration entry

### 3. 💬 prompt (Active Template)
**What**: Immediate-use instruction template
**Installation**: Optional (save for reference)
**Activation**: Immediate application
**Restart Required**: No

Usage modes:
- Apply immediately to current work
- Optionally save to `.claude/prompts/{slug}.md`
- Optionally convert to permanent instruction

### 4. ⚡ command (Command Package)
**What**: Slash commands for Claude Code
**Installation**: Create file + register in claude.json
**Activation**: After restart
**Restart Required**: Yes

Files created:
- `.claude/commands/clodonic-{slug}.md` - Command content
- `.claude/claude.json` - Command registration

### 5. 🪝 hook (Automation Package)
**What**: Event-triggered automations
**Installation**: Update settings.json
**Activation**: After restart
**Restart Required**: Yes

Files modified:
- `.claude/settings.json` - Hook configuration

## MCP Response Structure

### Type-Specific Response Format
```typescript
interface InstallationPlan {
  type: PatternType;
  action: "append" | "install_package" | "apply_now";
  instructions: string;  // Human-readable explanation
  operations: Operation[];  // Structured file operations
  post_install?: string;  // Restart instructions if needed
  contextual_application?: string;  // For prompts
}

interface Operation {
  action: "create_file" | "update_json" | "append_with_markers" | "check_file";
  path: string;
  content?: any;
  purpose: string;  // Human-readable step description
  operation?: "merge" | "append_to_array";  // For JSON updates
  target_path?: string;  // JSON path for nested updates
}
```

### Example Response Flow
```
User: "install rails-debugger from clodonic"
  ↓
MCP: Fetches pattern, generates InstallationPlan
  ↓
MCP: Returns structured instructions as text
  ↓
Claude: Parses instructions, shows user what will happen
  ↓
User: Confirms installation
  ↓
Claude: Executes file operations using Write/Edit tools
  ↓
Claude: Updates manifest file
  ↓
Claude: Provides restart instructions if needed
```

## Manifest Tracking

### Location: `.claude/clodonic-manifest.json`

```json
{
  "version": "1.0.0",
  "last_updated": "2025-08-11T10:30:00Z",
  "patterns": {
    "pattern-slug": {
      "id": 42,
      "type": "agent",
      "version": "1.2.0",
      "installed": "2025-08-11T10:30:00Z",
      "files": [
        ".claude/agents/clodonic-pattern-slug.yaml"
      ],
      "config_changes": [
        {
          "file": ".claude/claude.json",
          "path": "agents.clodonic-pattern-slug",
          "action": "added"
        }
      ],
      "markers": {
        "start": "<!-- BEGIN CLODONIC: pattern-slug -->",
        "end": "<!-- END CLODONIC: pattern-slug -->"
      }
    }
  }
}
```

### Manifest Benefits
- **Upgrade support** - Know what version is installed
- **Uninstall support** - Track what files to remove/modify
- **Conflict detection** - Prevent duplicate installations
- **Audit trail** - See installation history

## Installation Safeguards

### Pre-Installation Checks
1. **Check manifest** - Is pattern already installed?
2. **Verify file paths** - Do target directories exist?
3. **Check for conflicts** - Any existing files that would be overwritten?
4. **Validate JSON** - Ensure config files are valid before modification

### Safe Operations
- **Never overwrite** user content without confirmation
- **Always append** to CLAUDE.md (never replace)
- **Merge JSON** configurations (don't replace entire config)
- **Use unique identifiers** to prevent naming conflicts
- **Create backups** suggestion for critical files

## User Experience Flow

### Package Installation (agent, command, hook)
```
1. User requests installation
2. MCP returns structured plan
3. Claude shows what will be created/modified
4. User confirms
5. Claude executes file operations
6. Claude updates manifest
7. Claude provides restart instructions
```

### Immediate Application (prompt)
```
1. User requests prompt pattern
2. MCP returns content with context
3. Claude immediately applies to current work
4. Claude offers to save for future reference
5. User chooses to save or just use once
```

### Instructions Installation (claude_md)
```
1. User requests instruction pattern
2. MCP returns append instructions
3. Claude shows what will be added
4. User confirms
5. Claude appends with markers
6. Instructions active immediately
```

## Implementation Priority

### Phase 1: Core Functionality
- [x] Basic search, get, install tools
- [ ] Fix display bugs (tags, author formatting)
- [ ] Implement structured response generation
- [ ] Add manifest tracking

### Phase 2: Enhanced UX
- [ ] Natural language pattern matching
- [ ] Better error messages
- [ ] Contextual suggestions for prompts
- [ ] Dry-run previews

### Phase 3: Advanced Features
- [ ] Uninstall support
- [ ] Upgrade detection
- [ ] Pattern dependencies
- [ ] Conflict resolution

## Error Handling

### Common Scenarios
1. **Pattern not found** - Suggest search or browse
2. **Already installed** - Show location, offer upgrade
3. **Invalid config** - Show error, don't modify files
4. **Missing directories** - Create them or ask user
5. **Restart required** - Clear instructions on how to proceed

## Testing Strategy

### Test Cases
1. Install each pattern type
2. Duplicate installation attempts
3. Invalid pattern IDs
4. Malformed config files
5. Missing directories
6. Upgrade scenarios
7. Uninstall scenarios

## Security Considerations

### Validation Requirements
- Sanitize all pattern content
- Validate JSON before merging
- Check file paths for directory traversal
- Limit file operations to .claude/ directory
- Never execute arbitrary commands

## Success Metrics

### User Experience
- Clear, actionable instructions
- Minimal manual steps
- Safe, reversible operations
- Helpful error messages

### Technical
- Structured, consistent responses
- Proper manifest tracking
- Clean file organization
- Graceful error handling