-- Fix hook patterns to store just the configuration, not the metadata wrapper
-- The content should be the actual hook configuration that goes in settings.json

-- Delete existing hooks
DELETE FROM item_tags WHERE item_id IN (
  SELECT id FROM items WHERE type = 'hook'
);
DELETE FROM item_metadata WHERE item_id IN (
  SELECT id FROM items WHERE type = 'hook'
);
DELETE FROM items WHERE type = 'hook';

-- Insert hooks with proper structure for Claude Code settings.json
INSERT INTO items (type, title, description, content, file_hash, submitter_id, votes_up, votes_down, created_at) VALUES
('hook', 'Prevent Dangerous Commands',
 'PreToolUse hook that blocks destructive bash commands like rm -rf',
 '{
  "matcher": "Bash",
  "hooks": [
    {
      "type": "command",
      "command": "#!/bin/bash\\n# Block dangerous commands\\nPAYLOAD=$(echo \\"$CLAUDE_HOOK_PAYLOAD\\" | jq -r ''.command'')\\nif echo \\"$PAYLOAD\\" | grep -qE ''rm -rf|rm -fr|:>|dd if=/dev/zero|chmod -R 777''; then\\n  echo \\"🚫 Blocked dangerous command: $PAYLOAD\\"\\n  exit 1\\nfi\\nexit 0"
    }
  ]
}',
 'seed_hook_001_prevent_dangerous',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 1, 0, datetime('now', '-24 days')),

('hook', 'Auto-Format Code on Save',
 'PostToolUse hook that automatically formats code after file edits',
 '{
  "matcher": "Write|Edit|MultiEdit",
  "hooks": [
    {
      "type": "command",
      "command": "#!/bin/bash\\n# Auto-format based on file extension\\nFILE=$(echo \\"$CLAUDE_HOOK_PAYLOAD\\" | jq -r ''.file_path'')\\nif [[ -n \\"$FILE\\" ]]; then\\n  case \\"$FILE\\" in\\n    *.py) black \\"$FILE\\" 2>/dev/null || true ;;\\n    *.js|*.jsx) prettier --write \\"$FILE\\" 2>/dev/null || true ;;\\n    *.ts|*.tsx) prettier --write \\"$FILE\\" 2>/dev/null || true ;;\\n    *.go) gofmt -w \\"$FILE\\" 2>/dev/null || true ;;\\n  esac\\nfi\\nexit 0"
    }
  ]
}',
 'seed_hook_002_auto_format',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 0, 0, datetime('now', '-19 days')),

('hook', 'Audit Log All Tool Usage',
 'PostToolUse hook that logs all Claude Code actions for compliance',
 '{
  "hooks": [
    {
      "type": "command",
      "command": "#!/bin/bash\\n# Log tool usage with timestamp\\nLOG_FILE=\\"$HOME/.claude-audit.log\\"\\nTIMESTAMP=$(date -u +\\"%Y-%m-%d %H:%M:%S UTC\\")\\nTOOL_NAME=$(echo \\"$CLAUDE_HOOK_PAYLOAD\\" | jq -r ''.tool_name // \\"unknown\\"'')\\nSESSION_ID=$(echo \\"$CLAUDE_HOOK_PAYLOAD\\" | jq -r ''.session_id // \\"unknown\\"'')\\nCWD=$(echo \\"$CLAUDE_HOOK_PAYLOAD\\" | jq -r ''.cwd // \\"unknown\\"'')\\n\\necho \\"[$TIMESTAMP] Tool: $TOOL_NAME | Session: $SESSION_ID | Dir: $CWD\\" >> \\"$LOG_FILE\\"\\nexit 0"
    }
  ]
}',
 'seed_hook_003_audit_log',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 0, 0, datetime('now', '-11 days')),

('hook', 'Enforce Test-First Development',
 'PreToolUse hook that ensures tests exist before allowing code changes',
 '{
  "matcher": "Write|Edit|MultiEdit",
  "hooks": [
    {
      "type": "command",
      "command": "#!/bin/bash\\n# Check if test file exists for source file\\nFILE=$(echo \\"$CLAUDE_HOOK_PAYLOAD\\" | jq -r ''.file_path'')\\n\\n# Skip if editing test files themselves\\nif [[ \\"$FILE\\" == *test* ]] || [[ \\"$FILE\\" == *spec* ]]; then\\n  exit 0\\nfi\\n\\n# Determine test file path\\nTEST_FILE=\\"\\"\\ncase \\"$FILE\\" in\\n  *.py) TEST_FILE=\\"${FILE%.py}_test.py\\" ;;\\n  *.js) TEST_FILE=\\"${FILE%.js}.test.js\\" ;;\\n  *.ts) TEST_FILE=\\"${FILE%.ts}.test.ts\\" ;;\\n  *) exit 0 ;; # Skip for other file types\\nesac\\n\\n# Check if test exists\\nif [[ ! -f \\"$TEST_FILE\\" ]]; then\\n  echo \\"❌ Test file required: $TEST_FILE\\"\\n  echo \\"Create tests first (TDD)\\"\\n  exit 1\\nfi\\nexit 0"
    }
  ]
}',
 'seed_hook_004_tdd_enforce',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 2, 0, datetime('now', '-8 days')),

('hook', 'Context Injection for Project Standards',
 'UserPromptSubmit hook that adds project context to every request',
 '{
  "hooks": [
    {
      "type": "command",
      "command": "#!/bin/bash\\n# Inject project context if CLAUDE.md exists\\nif [[ -f \\"CLAUDE.md\\" ]]; then\\n  echo \\"📋 Project context from CLAUDE.md loaded\\"\\n  cat CLAUDE.md\\nfi\\n\\n# Add any runtime context\\necho \\"\\"\\necho \\"📦 Current environment:\\"\\necho \\"- Node version: $(node -v 2>/dev/null || echo ''N/A'')\\"\\necho \\"- Python version: $(python --version 2>/dev/null || echo ''N/A'')\\"\\necho \\"- Git branch: $(git branch --show-current 2>/dev/null || echo ''N/A'')\\"\\nexit 0"
    }
  ]
}',
 'seed_hook_005_context_injection',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 1, 0, datetime('now', '-5 days'));

-- Add metadata for hooks with event types
INSERT INTO item_metadata (item_id, event_type, safety_level, dependencies)
SELECT id, 'PreToolUse', 'read-only', '["jq"]'
FROM items WHERE file_hash = 'seed_hook_001_prevent_dangerous';

INSERT INTO item_metadata (item_id, event_type, safety_level, dependencies)
SELECT id, 'PostToolUse', 'modifies-files', '["black", "prettier", "gofmt"]'
FROM items WHERE file_hash = 'seed_hook_002_auto_format';

INSERT INTO item_metadata (item_id, event_type, safety_level, dependencies)
SELECT id, 'PostToolUse', 'read-only', '["jq"]'
FROM items WHERE file_hash = 'seed_hook_003_audit_log';

INSERT INTO item_metadata (item_id, event_type, safety_level, dependencies)
SELECT id, 'PreToolUse', 'read-only', '["jq"]'
FROM items WHERE file_hash = 'seed_hook_004_tdd_enforce';

INSERT INTO item_metadata (item_id, event_type, safety_level, dependencies)
SELECT id, 'UserPromptSubmit', 'read-only', '["git", "node", "python"]'
FROM items WHERE file_hash = 'seed_hook_005_context_injection';

-- Update tag associations
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_hook_001_prevent_dangerous'),
  id FROM tags WHERE name IN ('hooks', 'security', 'safety', 'protection');

INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_hook_002_auto_format'),
  id FROM tags WHERE name IN ('hooks', 'formatting', 'automation', 'quality');

INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_hook_003_audit_log'),
  id FROM tags WHERE name IN ('hooks', 'logging', 'audit', 'automation');

INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_hook_004_tdd_enforce'),
  id FROM tags WHERE name IN ('hooks', 'testing', 'tdd', 'quality');

INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_hook_005_context_injection'),
  id FROM tags WHERE name IN ('hooks', 'context', 'automation', 'workflow');