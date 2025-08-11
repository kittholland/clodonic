-- Clodonic Pattern Repository Seed Data for Launch
-- Generated: August 2025
-- Purpose: Seed high-quality patterns with realistic initial state

-- Clear existing test data (optional - comment out if preserving data)
DELETE FROM item_tags;
DELETE FROM items;
DELETE FROM tags;
DELETE FROM users WHERE username = 'clodonic-system';

-- Create system user for seeded patterns
INSERT INTO users (provider_id, username, email, auth_provider) VALUES
  ('system', 'clodonic-system', 'system@clodonic.ai', 'system');

-- Insert tags first (comprehensive list for proper categorization)
INSERT INTO tags (name) VALUES
  -- Languages
  ('react'), ('typescript'), ('javascript'), ('python'), 
  ('java'), ('nodejs'), ('go'), ('ruby'), ('rust'),
  
  -- Frontend/Backend
  ('frontend'), ('backend'), ('full-stack'), ('api'), 
  ('database'), ('sql'),
  
  -- Frameworks & Libraries
  ('nextjs'), ('react-native'), ('spring-boot'), ('express'),
  ('prisma'), ('tailwind'), ('jest'), ('pytest'), ('rspec'),
  
  -- Cloud & Infrastructure
  ('devops'), ('kubernetes'), ('docker'), ('ci-cd'),
  ('aws'), ('gcp'), ('azure'), ('cloudflare'), ('vercel'),
  ('terraform'), ('grafana'), ('prometheus'), ('infrastructure'),
  
  -- Quality & Testing
  ('testing'), ('security'), ('performance'), ('quality'),
  ('code-review'), ('debugging'), ('validation'), ('tdd'),
  ('e2e'), ('unit-testing'), ('integration-testing'),
  
  -- Tools & Automation
  ('git'), ('automation'), ('workflow'), ('formatting'),
  ('linting'), ('black'), ('ruff'), ('eslint'), ('prettier'),
  ('playwright'), ('cypress'),
  
  -- Concepts & Architecture
  ('architecture'), ('microservices'), ('graphql'), ('rest'),
  ('mvc'), ('solid'), ('clean-code'), ('best-practices'),
  ('owasp'), ('responsive'), ('accessibility'),
  
  -- Documentation & Planning
  ('documentation'), ('planning'), ('agile'), ('refactoring'),
  
  -- Data & ML
  ('data-science'), ('machine-learning'), ('jupyter'), 
  ('pandas'), ('numpy'),
  
  -- Business & Features
  ('saas'), ('authentication'), ('logging'), ('optimization'),
  ('enterprise'), ('startup'), ('components'), ('state-management'),
  ('stripe'),
  
  -- Pattern Types
  ('hooks'), ('commands'), ('agents'), ('prompts'), ('claude-md'),
  ('patterns'),
  
  -- Mobile
  ('mobile'), ('expo'),
  
  -- Web Development
  ('web-development'),
  
  -- Specific Use Cases
  ('pr'), ('troubleshooting'), ('fix'), ('audit'), 
  ('vulnerability'), ('context'), ('session'), ('background'),
  ('protection'), ('safety'), ('markdown');

-- =====================================
-- CLAUDE_MD PATTERNS (Instructions)
-- Starting with 0-2 votes for realistic launch state
-- =====================================

INSERT INTO items (type, title, description, content, file_hash, submitter_id, votes_up, votes_down, created_at) VALUES
('claude_md', 'Full-Stack Web Application Development Guide', 
 'Complete project context for modern web applications with TypeScript, React, and Node.js',
 '# Tech Stack
- Frontend: React 18 + TypeScript + Tailwind CSS
- Backend: Node.js + Express + TypeScript  
- Database: PostgreSQL with Prisma ORM
- Testing: Jest + React Testing Library

# Commands
- `npm run dev`: Start development servers (frontend + backend)
- `npm run build`: Build for production
- `npm run test`: Run all tests
- `npm run lint`: ESLint + Prettier check

# Code Style
- Use TypeScript strict mode
- Prefer function components with hooks
- Use ES modules (import/export)
- Follow REST API conventions for endpoints

# Workflow
- Branch naming: `feature/description` or `fix/description`
- Commit after tests pass
- Never commit directly to main',
 'seed_claude_md_001_fullstack_web', 
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 2, 0, datetime('now', '-30 days')),

('claude_md', 'Python Data Science Project Guide',
 'Instructions for Python projects focused on data analysis, machine learning, and scientific computing',
 '# Tech Stack
- Python 3.11+ with Poetry for dependencies
- Data: pandas, numpy, scikit-learn
- Visualization: matplotlib, seaborn, plotly
- Notebooks: Jupyter Lab

# Commands
- `poetry install`: Install dependencies
- `poetry run pytest`: Run tests
- `poetry run jupyter lab`: Start Jupyter
- `poetry run python -m mypy .`: Type checking

# Code Style  
- Follow PEP 8 and use Black formatter
- Type hints required for functions
- Docstrings for all public functions
- Prefer pathlib over os.path

# Project Structure
- `src/`: Main source code
- `notebooks/`: Jupyter notebooks for exploration
- `tests/`: Unit tests with pytest
- `data/`: Raw and processed datasets',
 'seed_claude_md_002_python_data_science',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 1, 0, datetime('now', '-25 days')),

('claude_md', 'DevOps and Infrastructure Management',
 'Guidelines for infrastructure-as-code projects with Docker, Kubernetes, and CI/CD',
 '# Tech Stack
- Infrastructure: Terraform + AWS/GCP
- Containers: Docker + Kubernetes
- CI/CD: GitHub Actions
- Monitoring: Prometheus + Grafana

# Commands
- `terraform plan`: Preview infrastructure changes
- `terraform apply`: Deploy infrastructure
- `docker-compose up -d`: Start local services
- `kubectl apply -f k8s/`: Deploy to cluster

# Security Rules
- Never commit secrets or API keys
- Use environment variables for configuration
- Scan images for vulnerabilities before deploy
- Follow principle of least privilege

# Workflow
- Test locally with docker-compose first
- Deploy to staging before production
- Tag releases with semantic versioning
- Document all infrastructure changes',
 'seed_claude_md_003_devops_infrastructure',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 0, 0, datetime('now', '-20 days')),

('claude_md', 'React Native Mobile Development',
 'Cross-platform mobile app development with React Native and modern tooling',
 '# Tech Stack
- React Native 0.74 with Expo SDK 51
- TypeScript for type safety
- Navigation: React Navigation 6
- State: Redux Toolkit + RTK Query

# Commands
- `npx expo start`: Start development server
- `npx expo run:ios`: Run iOS simulator
- `npx expo run:android`: Run Android emulator
- `npm run test`: Jest + React Native Testing Library

# Code Style
- Use functional components with hooks
- TypeScript strict mode enabled
- Follow React Native best practices
- Optimize for both platforms

# Workflow
- Test on both iOS and Android
- Use EAS Build for production builds
- Profile performance with Flipper',
 'seed_claude_md_004_react_native',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 1, 0, datetime('now', '-18 days')),

('claude_md', 'Claude Code Workflow Optimization',
 'Best practices for working efficiently with Claude Code',
 '# Claude Code Best Practices
- Use TodoWrite for complex multi-step tasks
- Read files before editing to maintain context
- Use Grep/Glob for searching across codebases
- Batch related operations for efficiency

# Commands
- `npm run lint`: Check code style
- `npm run typecheck`: TypeScript validation
- `npm run test:changed`: Test only modified files
- `npm run format`: Auto-fix formatting

# Workflow Rules
- Always run lint/typecheck after changes
- Use planning mode for complex features
- Create comprehensive test coverage
- Document decisions in code comments

# Multi-File Operations
- Use MultiEdit for batch changes
- Search before modifying imports
- Update tests alongside implementation
- Keep consistent code style',
 'seed_claude_md_005_claude_workflow',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 0, 0, datetime('now', '-15 days')),

('claude_md', 'Security-First Development',
 'Security guidelines for modern application development with focus on OWASP Top 10',
 '# Security Requirements
- Input validation on all user data
- Use parameterized queries (no string concatenation)
- Implement rate limiting
- Enable CSP headers

# Authentication
- Use industry-standard OAuth 2.0
- Store passwords with bcrypt/scrypt
- Implement MFA where possible
- Session timeout after inactivity

# Commands
- `npm audit`: Check for vulnerabilities
- `npm audit fix`: Auto-fix issues
- Run SAST tools in CI pipeline
- Regular dependency updates

# Never Do
- Log sensitive data
- Commit secrets or API keys
- Trust user input
- Use eval() or similar',
 'seed_claude_md_006_security',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 3, 0, datetime('now', '-12 days'));

-- =====================================
-- AGENT PATTERNS
-- =====================================

INSERT INTO items (type, title, description, content, file_hash, submitter_id, votes_up, votes_down, created_at) VALUES
('agent', 'Multi-File Refactoring Assistant',
 'Helps refactor code across multiple files while maintaining consistency',
 'name: multi-file-refactor
description: Assists with complex refactoring across multiple files
instructions: |
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
 'name: db-migration-helper
description: Helps create and validate database migrations
instructions: |
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
 'name: api-documenter
description: Creates OpenAPI/Swagger documentation from code
instructions: |
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
 'name: performance-profiler
description: Analyzes code for performance issues
instructions: |
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

-- =====================================
-- PROMPT PATTERNS
-- =====================================

INSERT INTO items (type, title, description, content, file_hash, submitter_id, votes_up, votes_down, created_at) VALUES
('prompt', 'Comprehensive Bug Report Analysis',
 'Analyze bug reports to identify root causes and suggest fixes',
 'Analyze this bug report and provide:

1. **Root Cause Analysis**: Identify the most likely cause
2. **Affected Components**: List potentially affected parts
3. **Reproduction Steps**: Clarify or expand the steps
4. **Priority Assessment**: Rate severity (Critical/High/Medium/Low)
5. **Fix Suggestions**: Provide specific code changes
6. **Test Cases**: Suggest tests to prevent regression

Bug Report: [INSERT BUG DESCRIPTION]

Focus on actionable insights and be specific about file locations and code changes needed.',
 'seed_prompt_001_bug_analysis',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 0, 0, datetime('now', '-26 days')),

('prompt', 'Refactoring Complex Functions',
 'Guide for breaking down complex functions into smaller, testable units',
 'Help me refactor this function following these principles:

1. **Single Responsibility**: Each function does one thing
2. **Pure Functions**: Minimize side effects
3. **Testability**: Easy to unit test
4. **Readability**: Self-documenting code
5. **Performance**: Maintain or improve efficiency

Current function:
```
[PASTE YOUR FUNCTION HERE]
```

Provide:
- Refactored version with smaller functions
- Explanation of each extracted function
- Unit test examples for new functions
- Performance considerations',
 'seed_prompt_002_refactoring',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 1, 0, datetime('now', '-21 days')),

('prompt', 'Architecture Decision Record',
 'Template for documenting important architectural decisions',
 'Create an Architecture Decision Record (ADR) for:

**Context**: [Describe the situation and problem]
**Decision**: [What technology/approach to use]

Include:
1. **Status**: Proposed/Accepted/Deprecated
2. **Context**: Business and technical context
3. **Decision**: The chosen solution
4. **Consequences**: Positive and negative outcomes
5. **Alternatives**: Other options considered
6. **References**: Links to relevant resources

Make it concise but comprehensive for future reference.',
 'seed_prompt_003_adr',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 0, 0, datetime('now', '-14 days')),

('prompt', 'User Story to Technical Tasks',
 'Convert user stories into actionable technical tasks',
 'Break down this user story into technical tasks:

User Story: [INSERT USER STORY]

Provide:
1. **Frontend Tasks**: UI components, state management
2. **Backend Tasks**: APIs, business logic, database
3. **Testing Tasks**: Unit, integration, E2E tests
4. **DevOps Tasks**: Deployment, monitoring
5. **Documentation**: API docs, user guides
6. **Acceptance Criteria**: Specific, measurable goals

Estimate effort (hours) for each task.
Identify dependencies between tasks.',
 'seed_prompt_004_user_story',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 2, 0, datetime('now', '-8 days'));

-- =====================================
-- HOOK PATTERNS
-- =====================================

INSERT INTO items (type, title, description, content, file_hash, submitter_id, votes_up, votes_down, created_at) VALUES
('hook', 'Pre-commit Code Quality Check',
 'Comprehensive pre-commit hook for code quality and security',
 '#!/bin/bash
# Pre-commit hook for code quality

# Run formatters
echo "🎨 Formatting code..."
npm run format:check || exit 1

# Run linters
echo "🔍 Linting code..."
npm run lint || exit 1

# Run type checking
echo "📝 Type checking..."
npm run typecheck || exit 1

# Run tests for changed files
echo "🧪 Running tests..."
npm run test:changed || exit 1

# Security audit
echo "🔒 Security check..."
npm audit --audit-level=high || exit 1

echo "✅ All checks passed!"',
 'seed_hook_001_precommit',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 1, 0, datetime('now', '-24 days')),

('hook', 'Auto-generate PR Description',
 'Automatically generates PR descriptions from commits and changes',
 '#!/bin/bash
# Generate PR description from commits

BRANCH=$(git branch --show-current)
BASE_BRANCH="main"

echo "## Changes"
echo ""

# List all commits
git log $BASE_BRANCH..$BRANCH --oneline | while read line; do
  echo "- $line"
done

echo ""
echo "## Files Changed"
git diff --stat $BASE_BRANCH..$BRANCH

echo ""
echo "## Checklist"
echo "- [ ] Tests pass"
echo "- [ ] Documentation updated"
echo "- [ ] No console.logs"
echo "- [ ] Follows code style"',
 'seed_hook_002_pr_description',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 0, 0, datetime('now', '-19 days')),

('hook', 'Database Backup Before Migration',
 'Automatically backup database before running migrations',
 '#!/bin/bash
# Backup database before migrations

DB_NAME=${DB_NAME:-"production"}
BACKUP_DIR=${BACKUP_DIR:-"./backups"}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "📦 Backing up database..."
mkdir -p $BACKUP_DIR

# Create backup
pg_dump $DB_NAME > "$BACKUP_DIR/backup_$TIMESTAMP.sql"

if [ $? -eq 0 ]; then
  echo "✅ Backup created: backup_$TIMESTAMP.sql"
  # Keep only last 5 backups
  ls -t $BACKUP_DIR/*.sql | tail -n +6 | xargs rm -f
else
  echo "❌ Backup failed! Aborting migration."
  exit 1
fi',
 'seed_hook_003_db_backup',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 0, 0, datetime('now', '-11 days'));

-- =====================================
-- COMMAND PATTERNS
-- =====================================

INSERT INTO items (type, title, description, content, file_hash, submitter_id, votes_up, votes_down, created_at) VALUES
('command', 'Quick Project Setup',
 'Initialize a new project with all standard configurations',
 '# Create new TypeScript project with all configs
npx create-next-app@latest my-app --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" && cd my-app && npm install -D prettier @types/node && npx prettier --write . && git add . && git commit -m "Initial setup with TypeScript, Tailwind, ESLint, and Prettier"',
 'seed_command_001_project_setup',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 0, 0, datetime('now', '-27 days')),

('command', 'Docker Development Environment',
 'Spin up complete development environment with Docker',
 '# Start full dev environment with database, cache, and app
docker-compose up -d postgres redis && sleep 5 && npm run db:migrate && npm run db:seed && docker-compose up app',
 'seed_command_002_docker_dev',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 1, 0, datetime('now', '-23 days')),

('command', 'Git Branch Cleanup',
 'Clean up merged branches and prune remote references',
 '# Delete merged branches and clean remotes
git branch --merged | grep -v "\\*\\|main\\|master\\|develop" | xargs -n 1 git branch -d && git remote prune origin && git gc --aggressive',
 'seed_command_003_git_cleanup',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 2, 0, datetime('now', '-17 days')),

('command', 'Production Deploy with Rollback',
 'Deploy to production with automatic rollback on failure',
 '# Deploy with health check and auto-rollback
PREVIOUS=$(git rev-parse HEAD) && git pull && npm ci && npm run build && npm run test && npm run deploy && sleep 30 && curl -f ${HEALTH_URL:-http://localhost:3000/health} || (echo "Deploy failed, rolling back..." && git reset --hard $PREVIOUS && npm run deploy)',
 'seed_command_004_deploy_rollback',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 0, 0, datetime('now', '-13 days')),

('command', 'Find and Fix NPM Vulnerabilities',
 'Audit and automatically fix npm security vulnerabilities',
 '# Comprehensive npm security check and fix
npm audit --json > audit.json && npm audit fix && npm dedupe && npm prune && rm audit.json && echo "Run npm audit fix --force manually if critical updates needed"',
 'seed_command_005_npm_security',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 1, 0, datetime('now', '-9 days')),

('command', 'Database Performance Analysis',
 'Analyze slow queries and generate index recommendations',
 '# PostgreSQL performance analysis
psql -c "SELECT query, calls, mean_exec_time, total_exec_time FROM pg_stat_statements WHERE mean_exec_time > 100 ORDER BY mean_exec_time DESC LIMIT 10;" && psql -c "SELECT schemaname, tablename, indexname, idx_scan FROM pg_stat_user_indexes ORDER BY idx_scan LIMIT 10;"',
 'seed_command_006_db_performance',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 0, 0, datetime('now', '-7 days'));

-- =====================================
-- TAG ASSOCIATIONS
-- =====================================

-- Full-Stack Web App Guide
INSERT INTO item_tags (item_id, tag_id) 
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_claude_md_001_fullstack_web'),
  id FROM tags WHERE name IN ('react', 'typescript', 'nodejs', 'frontend', 'backend', 'full-stack', 'testing', 'web-development', 'claude-md');

-- Python Data Science Guide
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_claude_md_002_python_data_science'),
  id FROM tags WHERE name IN ('python', 'data-science', 'jupyter', 'pandas', 'numpy', 'machine-learning', 'testing', 'claude-md');

-- DevOps Infrastructure
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_claude_md_003_devops_infrastructure'),
  id FROM tags WHERE name IN ('devops', 'docker', 'kubernetes', 'terraform', 'aws', 'gcp', 'ci-cd', 'infrastructure', 'security', 'claude-md');

-- React Native Mobile
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_claude_md_004_react_native'),
  id FROM tags WHERE name IN ('react-native', 'mobile', 'typescript', 'expo', 'frontend', 'testing', 'claude-md');

-- Claude Code Workflow Optimization
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_claude_md_005_claude_workflow'),
  id FROM tags WHERE name IN ('claude-md', 'workflow', 'best-practices', 'patterns', 'automation');

-- Security First Development
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_claude_md_006_security'),
  id FROM tags WHERE name IN ('security', 'authentication', 'owasp', 'best-practices', 'validation', 'claude-md');

-- Multi-File Refactoring Agent
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_agent_001_refactor'),
  id FROM tags WHERE name IN ('refactoring', 'quality', 'claude-md', 'best-practices', 'agents');

-- Database Migration Helper
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_agent_002_db_migration'),
  id FROM tags WHERE name IN ('database', 'sql', 'backend', 'agents');

-- API Documentation Generator
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_agent_003_api_docs'),
  id FROM tags WHERE name IN ('documentation', 'api', 'backend', 'agents');

-- Performance Profiler
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_agent_004_performance'),
  id FROM tags WHERE name IN ('performance', 'optimization', 'react', 'agents');

-- Bug Report Analysis Prompt
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_prompt_001_bug_analysis'),
  id FROM tags WHERE name IN ('debugging', 'troubleshooting', 'quality', 'prompts');

-- Refactoring Complex Functions
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_prompt_002_refactoring'),
  id FROM tags WHERE name IN ('refactoring', 'clean-code', 'best-practices', 'prompts');

-- Architecture Decision Record
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_prompt_003_adr'),
  id FROM tags WHERE name IN ('architecture', 'documentation', 'planning', 'prompts');

-- User Story to Tasks
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_prompt_004_user_story'),
  id FROM tags WHERE name IN ('planning', 'agile', 'frontend', 'backend', 'prompts');

-- Pre-commit Hook
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_hook_001_precommit'),
  id FROM tags WHERE name IN ('git', 'quality', 'automation', 'hooks', 'formatting', 'linting');

-- PR Description Generator
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_hook_002_pr_description'),
  id FROM tags WHERE name IN ('git', 'pr', 'automation', 'hooks');

-- Database Backup Hook
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_hook_003_db_backup'),
  id FROM tags WHERE name IN ('database', 'backup', 'automation', 'hooks');

-- Quick Project Setup Command
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_command_001_project_setup'),
  id FROM tags WHERE name IN ('nextjs', 'typescript', 'tailwind', 'commands');

-- Docker Dev Environment
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_command_002_docker_dev'),
  id FROM tags WHERE name IN ('docker', 'devops', 'commands');

-- Git Branch Cleanup
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_command_003_git_cleanup'),
  id FROM tags WHERE name IN ('git', 'commands');

-- Production Deploy with Rollback
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_command_004_deploy_rollback'),
  id FROM tags WHERE name IN ('devops', 'ci-cd', 'commands');

-- NPM Security Fix
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_command_005_npm_security'),
  id FROM tags WHERE name IN ('security', 'nodejs', 'commands');

-- Database Performance Analysis
INSERT INTO item_tags (item_id, tag_id)
SELECT 
  (SELECT id FROM items WHERE file_hash = 'seed_command_006_db_performance'),
  id FROM tags WHERE name IN ('database', 'performance', 'sql', 'commands');