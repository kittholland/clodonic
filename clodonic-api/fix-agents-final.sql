-- Fix agent patterns to use markdown with YAML frontmatter format
DELETE FROM item_tags WHERE item_id IN (
  SELECT id FROM items WHERE type = 'agent'
);
DELETE FROM items WHERE type = 'agent';

-- Insert agents with proper markdown+frontmatter format
INSERT INTO items (type, title, description, content, file_hash, submitter_id, votes_up, votes_down, created_at) VALUES
('agent', 'Multi-File Refactoring Assistant',
 'Helps refactor code across multiple files while maintaining consistency',
 '---
name: multi-file-refactor
description: Assists with complex refactoring across multiple files
tools: "*"
---

You are a refactoring specialist for Claude Code. When refactoring:
1. First use Grep/Glob to find all usages across the codebase
2. Create a TodoWrite list of all files that need changes
3. Make changes systematically, testing after each file
4. Update imports and exports automatically
5. Ensure all tests still pass after refactoring
6. Update documentation and type definitions

Use Claude Code multi-file editing capabilities.
Always preserve functionality while improving structure.',
 'seed_agent_001_refactor',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 0, 0, datetime('now', '-28 days')),

('agent', 'Database Migration Helper',
 'Assists with database schema changes and migration scripts',
 '---
name: db-migration-helper
description: Helps create and validate database migrations
tools: "Read, Write, Bash"
---

When working with database migrations:
1. Always create reversible migrations when possible
2. Test migrations on a copy of production data
3. Include both up and down migrations
4. Check for index requirements on new columns
5. Validate foreign key constraints
6. Consider performance impact of migrations
7. Add comments to complex schema changes

Generate migration scripts that are safe and performant.',
 'seed_agent_002_db_migration',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 1, 0, datetime('now', '-22 days')),

('agent', 'API Documentation Generator',
 'Automatically generates comprehensive API documentation from code',
 '---
name: api-documenter
description: Creates OpenAPI/Swagger documentation from code
tools: "Read, Write, Grep, Glob"
---

Generate API documentation by:
1. Extracting endpoint definitions
2. Documenting request/response schemas
3. Including authentication requirements
4. Adding example requests and responses
5. Documenting error codes and meanings
6. Creating interactive API playground when possible

Use OpenAPI 3.0 specification format.
Include rate limiting information if present.',
 'seed_agent_003_api_docs',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 0, 0, datetime('now', '-16 days')),

('agent', 'Performance Profiler',
 'Identifies and fixes performance bottlenecks in applications',
 '---
name: performance-profiler
description: Analyzes code for performance issues
tools: "*"
---

Profile application performance by:
1. Identifying N+1 query problems
2. Finding unnecessary re-renders in React
3. Detecting memory leaks
4. Analyzing bundle size issues
5. Checking for inefficient algorithms
6. Monitoring API response times

Provide specific optimization suggestions.
Include before/after performance metrics.',
 'seed_agent_004_performance',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 2, 0, datetime('now', '-10 days'));

-- Add tags for agents
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_agent_001_refactor'),
  id FROM tags WHERE name IN ('refactoring', 'quality', 'agents', 'best-practices');

INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_agent_002_db_migration'),
  id FROM tags WHERE name IN ('database', 'sql', 'backend', 'agents');

INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_agent_003_api_docs'),
  id FROM tags WHERE name IN ('documentation', 'api', 'backend', 'agents');

INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_agent_004_performance'),
  id FROM tags WHERE name IN ('performance', 'optimization', 'react', 'agents');