-- Fix the hook patterns to be actual Claude Code hooks, not git hooks

-- Delete the incorrect hook patterns
DELETE FROM item_tags WHERE item_id IN (
  SELECT id FROM items WHERE type = 'hook'
);
DELETE FROM items WHERE type = 'hook';

-- Insert correct Claude Code hook patterns
INSERT INTO items (type, title, description, content, file_hash, submitter_id, votes_up, votes_down, created_at) VALUES
('hook', 'Prevent Accidental File Deletions',
 'PreToolUse hook that blocks rm -rf and other dangerous commands',
 '{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "echo \"$CLAUDE_HOOK_PAYLOAD\" | grep -E \"rm -rf|rm -fr|:>|dd if=\" && exit 1 || exit 0"
          }
        ]
      }
    ]
  }
}',
 'seed_hook_001_prevent_deletion',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 1, 0, datetime('now', '-24 days')),

('hook', 'Auto-Format on File Write',
 'PostToolUse hook that runs formatters after editing files',
 '{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command", 
            "command": "if [[ \"$CLAUDE_HOOK_PAYLOAD\" == *.py ]]; then black \"$CLAUDE_HOOK_PAYLOAD\" 2>/dev/null; elif [[ \"$CLAUDE_HOOK_PAYLOAD\" == *.js || \"$CLAUDE_HOOK_PAYLOAD\" == *.ts ]]; then prettier --write \"$CLAUDE_HOOK_PAYLOAD\" 2>/dev/null; fi; exit 0"
          }
        ]
      }
    ]
  }
}',
 'seed_hook_002_auto_format',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 0, 0, datetime('now', '-19 days')),

('hook', 'Log All Tool Usage',
 'Notification hook that logs all Claude Code actions to a file',
 '{
  "hooks": {
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo \"[$(date)] Tool: $CLAUDE_TOOL_NAME in $PWD\" >> ~/.claude-code-audit.log"
          }
        ]
      }
    ]
  }
}',
 'seed_hook_003_audit_log',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 0, 0, datetime('now', '-11 days'));

-- Update tag associations for new hooks
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_hook_001_prevent_deletion'),
  id FROM tags WHERE name IN ('hooks', 'security', 'safety', 'automation');

INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_hook_002_auto_format'),
  id FROM tags WHERE name IN ('hooks', 'formatting', 'automation', 'quality');

INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_hook_003_audit_log'),
  id FROM tags WHERE name IN ('hooks', 'logging', 'audit', 'automation');