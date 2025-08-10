-- Sample data for Clodonic.ai
-- Note: Curated tags are seeded via curated-tags.sql
-- This file contains sample patterns to showcase the platform

-- Insert sample items with curated tags
INSERT INTO items (type, title, description, content, file_hash) VALUES
  ('prompt', 'Parallel-Safe Analysis Pattern', 
   'Never lose 700 task results again. This prompt ensures all parallel operations are read-only and safe to interrupt.',
   'analyze all [targets] for [issue type] using parallel tasks (read-only operations only, no modifications)',
   'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2'),
  
  ('claude_md', 'Rails TDD Configuration',
   'Complete Rails setup with RSpec, FactoryBot, and 90% coverage requirements. Enforces TDD practices and prevents deployment without tests.',
   '# Rails Development Rules
- Minimum 90% test coverage required
- All PRs must include tests
- Use RSpec exclusively
- FactoryBot for fixtures
- Never skip tests in CI',
   'f2e1d0c9b8a7z6y5x4w3v2u1t0s9r8q7p6o5n4m3l2k1j0i9h8g7f6e5d4c3b2a1'),
  
  ('agent', 'Database Migration Validator',
   'Read-only agent that validates database migrations before execution. Checks for destructive operations and suggests safer alternatives.',
   'name: migration-validator
tools: [Read, Grep]
safety: read-only
description: Validates migrations for safety before execution',
   'z9y8x7w6v5u4t3s2r1q0p9o8n7m6l5k4j3i2h1g0f9e8d7c6b5a4z3y2x1w0v9u8');

-- Link items to curated tags (using tag names, backend will resolve IDs)
-- Pattern 1: Parallel-Safe Analysis → analysis, parallel (purpose), safe (safety)
INSERT INTO item_tags (item_id, tag_id) VALUES
  (1, (SELECT id FROM tags WHERE name = 'analysis')),
  (1, (SELECT id FROM tags WHERE name = 'safe')),
  (1, (SELECT id FROM tags WHERE name = 'performance'));

-- Pattern 2: Rails TDD → ruby, rails, testing, safe
INSERT INTO item_tags (item_id, tag_id) VALUES
  (2, (SELECT id FROM tags WHERE name = 'ruby')),
  (2, (SELECT id FROM tags WHERE name = 'rails')),
  (2, (SELECT id FROM tags WHERE name = 'testing')),
  (2, (SELECT id FROM tags WHERE name = 'safe'));

-- Pattern 3: Database Migration Validator → validation, safe
INSERT INTO item_tags (item_id, tag_id) VALUES
  (3, (SELECT id FROM tags WHERE name = 'validation')),
  (3, (SELECT id FROM tags WHERE name = 'safe'));