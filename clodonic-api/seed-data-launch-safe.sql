-- Clodonic Pattern Repository - Safe Seed Data Update
-- This version preserves existing users and their votes
-- Only updates the seed patterns to have realistic vote counts

-- First, check if we need to create the system user
INSERT OR IGNORE INTO users (provider_id, username, email, auth_provider) VALUES
  ('system', 'clodonic-system', 'system@clodonic.ai', 'system');

-- Update existing seed patterns to have realistic vote counts
-- Only update patterns submitted by clodonic-system
UPDATE items 
SET votes_up = 0, votes_down = 0 
WHERE submitter_id = (SELECT id FROM users WHERE username = 'clodonic-system');

-- Set a few patterns to have 1-3 votes for variety
UPDATE items SET votes_up = 2 
WHERE file_hash = 'seed_claude_md_001_fullstack_web';

UPDATE items SET votes_up = 1 
WHERE file_hash = 'seed_claude_md_002_python_data_science';

UPDATE items SET votes_up = 1 
WHERE file_hash = 'seed_claude_md_004_react_native';

UPDATE items SET votes_up = 3 
WHERE file_hash = 'seed_claude_md_006_security';

UPDATE items SET votes_up = 1 
WHERE file_hash = 'seed_agent_002_db_migration';

UPDATE items SET votes_up = 2 
WHERE file_hash = 'seed_agent_004_performance';

UPDATE items SET votes_up = 1 
WHERE file_hash = 'seed_prompt_002_refactoring';

UPDATE items SET votes_up = 2 
WHERE file_hash = 'seed_prompt_004_user_story';

UPDATE items SET votes_up = 1 
WHERE file_hash = 'seed_hook_001_precommit';

UPDATE items SET votes_up = 1 
WHERE file_hash = 'seed_command_002_docker_dev';

UPDATE items SET votes_up = 2 
WHERE file_hash = 'seed_command_003_git_cleanup';

UPDATE items SET votes_up = 1 
WHERE file_hash = 'seed_command_005_npm_security';