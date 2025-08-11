-- Clodonic.ai Database Schema

-- Users table (for authenticated users)
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  provider_id TEXT NOT NULL, -- GitHub ID, Google ID, etc.
  username TEXT UNIQUE NOT NULL, -- GitHub username, Google email prefix, etc.
  email TEXT,
  auth_provider TEXT NOT NULL, -- 'github', 'google', etc.
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(provider_id, auth_provider)
);

-- Items table (main content)
CREATE TABLE IF NOT EXISTS items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL, -- 'claude_md', 'agent', 'prompt', 'hook', 'command'
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  content TEXT NOT NULL,
  file_hash TEXT NOT NULL, -- SHA256 for deduplication
  submitter_id INTEGER, -- NULL for anonymous
  votes_up INTEGER DEFAULT 0,
  votes_down INTEGER DEFAULT 0,
  install_count INTEGER DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (submitter_id) REFERENCES users(id),
  UNIQUE(file_hash, type)
);

-- Tags table
CREATE TABLE IF NOT EXISTS tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE NOT NULL,
  category TEXT -- 'language', 'framework', 'purpose', 'safety'
);

-- Item tags junction table
CREATE TABLE IF NOT EXISTS item_tags (
  item_id INTEGER NOT NULL,
  tag_id INTEGER NOT NULL,
  PRIMARY KEY (item_id, tag_id),
  FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE,
  FOREIGN KEY (tag_id) REFERENCES tags(id)
);

-- Votes table (track who voted)
CREATE TABLE IF NOT EXISTS votes (
  user_id INTEGER NOT NULL,
  item_id INTEGER NOT NULL,
  vote INTEGER NOT NULL, -- 1 or -1
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, item_id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
);

-- Item metadata (type-specific fields)
CREATE TABLE IF NOT EXISTS item_metadata (
  item_id INTEGER PRIMARY KEY,
  tools_required TEXT, -- JSON array for agents
  safety_level TEXT, -- 'read-only', 'modifies-files', 'deploys'
  event_type TEXT, -- for hooks: 'pre-commit', 'post-merge', etc
  shell_type TEXT, -- for hooks: 'bash', 'zsh', etc
  char_length INTEGER, -- for prompts
  command_trigger TEXT, -- for commands
  dependencies TEXT, -- JSON array
  FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
);

-- Rate limiting handled by Cloudflare Cache API
-- No database table needed for rate limiting

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_items_type ON items(type);
CREATE INDEX IF NOT EXISTS idx_items_votes ON items(votes_up DESC, votes_down);
CREATE INDEX IF NOT EXISTS idx_items_created ON items(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_item_tags_item ON item_tags(item_id);
CREATE INDEX IF NOT EXISTS idx_item_tags_tag ON item_tags(tag_id);
CREATE INDEX IF NOT EXISTS idx_votes_item ON votes(item_id);

-- Sessions table for OAuth
CREATE TABLE IF NOT EXISTS sessions (
  id TEXT PRIMARY KEY,
  user_id INTEGER NOT NULL,
  username TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_sessions_expires ON sessions(expires_at);