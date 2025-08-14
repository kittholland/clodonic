-- Clodonic Pattern Repository - Refined Seed Data
-- Based on community best practices and real-world usage patterns
-- Generated: August 2025

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
  ('protection'), ('safety'), ('markdown'), ('mcp'),
  
  -- New practical tags
  ('context-management'), ('memory'), ('large-codebase'), ('monorepo'),
  ('error-recovery'), ('rate-limiting'), ('observability');

-- =====================================
-- CLAUDE_MD PATTERNS (Instructions)
-- =====================================

INSERT INTO items (type, title, description, content, file_hash, submitter_id, votes_up, votes_down, created_at) VALUES
('claude_md', 'Context-Aware Large Codebase Setup', 
 'Optimized CLAUDE.md for large projects with intelligent context management and memory usage',
 '# Project Context Management
## Critical Files First
Read these files before any task:
- src/core/config.ts - Core configuration
- src/types/index.ts - Type definitions
- docs/ARCHITECTURE.md - System design

## Commands
- `npm run dev` - Start development (port 3000)
- `npm run test:watch` - Test in watch mode
- `npm run typecheck` - Type validation
- `npm run lint:fix` - Auto-fix issues

## Context Preservation Rules
1. Use Read selectively - avoid reading entire directories
2. Use Grep/Glob for searching before reading files
3. Clear context with /clear between unrelated tasks
4. Use subagents for isolated investigations

## Memory Management
@.claude/memory/project-patterns.md
@.claude/memory/common-issues.md

## Code Patterns
- Prefer composition over inheritance
- Use dependency injection for services
- All async operations must have error boundaries
- Database queries must use parameterized statements

## Known Issues & Solutions
- Large bundle? Check dynamic imports in src/pages
- Type errors? Run `npm run typecheck` first
- Test failures? Ensure test DB is migrated',
 'refined_claude_md_001_context_aware', 
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 8, 0, datetime('now', '-30 days')),

('claude_md', 'Test-Driven Development Workflow',
 'Enforces TDD practices with automatic test generation and coverage requirements',
 '# TDD Workflow Configuration

## Development Cycle
1. **RED**: Write failing test first
2. **GREEN**: Implement minimal code to pass
3. **REFACTOR**: Improve code maintaining tests

## Test Requirements
- Minimum 80% coverage for new code
- All PRs must include tests
- E2E tests for critical user paths

## Test Commands
```bash
npm run test:unit       # Unit tests only
npm run test:e2e        # E2E with Playwright
npm run test:coverage   # Coverage report
npm run test:watch      # TDD mode
```

## Auto Test Generation
When implementing new features:
1. Generate test skeleton first
2. Define test cases with expected behavior
3. Implement feature to satisfy tests
4. Add edge cases after basic implementation

## Testing Patterns
- Use test.each for parameterized tests
- Mock external services with MSW
- Use fixtures for consistent test data
- Keep tests isolated and fast

## Coverage Rules
- Statements: 80%
- Branches: 75%
- Functions: 80%
- Lines: 80%

Hook configured to block commits below threshold.',
 'refined_claude_md_002_tdd_workflow',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 5, 0, datetime('now', '-28 days')),

('claude_md', 'Production-Ready TypeScript API',
 'Enterprise patterns for TypeScript backend with error handling, logging, and monitoring',
 '# Production TypeScript API Standards

## Architecture Layers
```
src/
  /controllers   # Request handling, validation
  /services      # Business logic
  /repositories  # Data access layer
  /middlewares   # Cross-cutting concerns
  /utils         # Shared utilities
```

## Error Handling Protocol
- All errors extend BaseError class
- Structured error codes (APP_XXX, DB_XXX, API_XXX)
- Error tracking with correlation IDs
- Graceful degradation for external services

## Observability Setup
- Structured logging with winston
- OpenTelemetry for distributed tracing
- Prometheus metrics on /metrics
- Health checks on /health

## Security Checklist
☐ Input validation with Joi/Zod
☐ Rate limiting per endpoint
☐ SQL injection prevention (Prisma/TypeORM)
☐ JWT with refresh tokens
☐ CORS properly configured
☐ Secrets in environment variables
☐ Security headers (Helmet.js)

## Performance Guidelines
- Database queries use indexes
- Implement caching strategy (Redis)
- Pagination for list endpoints
- Connection pooling configured
- Async operations properly handled

## Deployment Ready
- Dockerfile optimized for size
- Health checks implemented
- Graceful shutdown handling
- Environment-specific configs
- Database migrations automated',
 'refined_claude_md_003_production_api',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 7, 1, datetime('now', '-25 days')),

('claude_md', 'React Component Library Development',
 'Modern React patterns with Storybook, testing, and accessibility built-in',
 '# React Component Library Standards

## Component Structure
```tsx
ComponentName/
  index.tsx           # Main component
  ComponentName.tsx   # Logic
  styles.module.css   # Styles
  types.ts           # TypeScript types
  stories.tsx        # Storybook
  test.tsx           # Tests
```

## Development Workflow
1. Create story first (design in Storybook)
2. Implement with TypeScript
3. Add unit tests with RTL
4. Check accessibility with axe
5. Document props with JSDoc

## Component Checklist
- [ ] TypeScript props interface
- [ ] Forwarded refs when needed
- [ ] Keyboard navigation support
- [ ] ARIA labels and roles
- [ ] Loading and error states
- [ ] Responsive design
- [ ] Dark mode support
- [ ] Memoization where appropriate

## Testing Standards
- Test user interactions, not implementation
- Use userEvent over fireEvent
- Test accessibility with jest-axe
- Visual regression with Chromatic
- Coverage minimum: 90%

## Performance Rules
- Lazy load heavy components
- Use React.memo for pure components
- Virtualize long lists
- Optimize re-renders with DevTools
- Bundle size tracking

## Documentation
- Props table auto-generated
- Usage examples in stories
- Accessibility notes
- Browser compatibility',
 'refined_claude_md_004_component_library',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 4, 0, datetime('now', '-22 days')),

('claude_md', 'Monorepo Management with Turborepo',
 'Efficient monorepo setup with shared configs, optimized builds, and cross-package development',
 '# Monorepo Configuration

## Structure
```
apps/
  web/          # Next.js frontend
  api/          # Express backend
  mobile/       # React Native
packages/
  ui/           # Shared components
  config/       # ESLint, TSConfig
  utils/        # Shared utilities
  types/        # TypeScript types
```

## Commands (Turborepo)
```bash
pnpm dev          # All apps in dev mode
pnpm build        # Cached parallel builds
pnpm test         # Run all tests
pnpm lint         # Lint all packages
pnpm add [pkg] --filter=[app]  # Add dependency
```

## Development Rules
1. Changes to packages trigger app rebuilds
2. Use workspace protocol for local packages
3. Shared dependencies in root package.json
4. App-specific deps in app package.json

## CI/CD Optimization
- Turborepo remote caching enabled
- Only affected packages rebuilt
- Parallel test execution
- Docker layer caching

## Cross-Package Development
- Use `pnpm link` for local development
- TypeScript project references configured
- Hot reload works across packages
- Shared ESLint/Prettier configs

## Version Management
- Changesets for versioning
- Automated changelog generation
- Coordinated package releases
- Semantic versioning enforced',
 'refined_claude_md_005_monorepo',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 3, 0, datetime('now', '-20 days'));

-- =====================================
-- AGENT PATTERNS (Subagents)
-- =====================================

INSERT INTO items (type, title, description, content, file_hash, submitter_id, votes_up, votes_down, created_at) VALUES
('agent', 'TDD Test Generator', 
 'Generates comprehensive test suites following TDD principles with edge cases and mocks',
 '---
name: tdd-test-generator
description: Generate comprehensive tests. Use BEFORE implementing features.
tools: [Read, Write, MultiEdit, Grep, Bash]
model: sonnet
---

You are a Test-Driven Development specialist who generates comprehensive test suites BEFORE implementation.

## Test Generation Process
1. Analyze requirements and acceptance criteria
2. Generate test file structure
3. Write failing tests first (RED phase)
4. Include edge cases and error scenarios
5. Set up proper mocks and fixtures

## Test Categories to Generate
- **Happy Path**: Normal successful operations
- **Edge Cases**: Boundary conditions, empty inputs
- **Error Cases**: Invalid inputs, exceptions
- **Integration**: Component interactions
- **Performance**: Response time, memory usage

## Testing Patterns
- AAA Pattern (Arrange, Act, Assert)
- Given-When-Then for BDD
- Test data builders for complex objects
- Snapshot testing for UI components
- Property-based testing where applicable

## Mock Strategy
- Mock external dependencies
- Use test doubles appropriately
- Prefer integration tests over heavy mocking
- Mock at architectural boundaries

## Coverage Requirements
Ensure tests cover:
- All public methods/functions
- Error handling paths
- State transitions
- Async operations
- Event handlers

Always write tests that fail initially and guide implementation.',
 'refined_agent_001_tdd_generator',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 12, 1, datetime('now', '-29 days')),

('agent', 'Performance Optimization Analyst',
 'Identifies and fixes performance bottlenecks in web applications with metrics-driven approach',
 '---
name: performance-analyst
description: Optimize performance bottlenecks. Use when app feels slow.
tools: [Read, Edit, Grep, Bash, WebSearch]
model: sonnet
---

You are a performance optimization expert focused on measurable improvements.

## Analysis Approach
1. **Measure First**: Establish baseline metrics
2. **Profile**: Identify actual bottlenecks
3. **Optimize**: Apply targeted fixes
4. **Verify**: Measure improvements

## Web Performance Focus Areas
- Initial page load time
- Time to Interactive (TTI)
- First Contentful Paint (FCP)
- Largest Contentful Paint (LCP)
- Cumulative Layout Shift (CLS)
- Bundle size optimization

## Common Optimizations
### Frontend
- Code splitting and lazy loading
- Image optimization (WebP, responsive images)
- Resource hints (preload, prefetch)
- Service worker caching
- Virtual scrolling for long lists
- Debouncing/throttling

### Backend
- Database query optimization
- N+1 query prevention
- Caching strategies (Redis, CDN)
- Connection pooling
- Async operation optimization
- Response compression

## Tools to Use
- Chrome DevTools Performance tab
- Lighthouse CI
- Bundle analyzers
- React DevTools Profiler
- Database query analyzers

Always provide before/after metrics to demonstrate improvements.',
 'refined_agent_002_performance',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 6, 0, datetime('now', '-27 days')),

('agent', 'Security Vulnerability Scanner',
 'Comprehensive security audit focusing on OWASP Top 10 with remediation steps',
 '---
name: security-scanner
description: Security audit for vulnerabilities. MUST USE before deployment.
tools: [Read, Grep, Bash]
model: opus
---

You are a cybersecurity expert specializing in secure code review and vulnerability assessment.

## Security Audit Checklist

### Authentication & Authorization
- [ ] Password complexity requirements
- [ ] Account lockout mechanisms
- [ ] Session management security
- [ ] JWT implementation review
- [ ] Role-based access control

### Input Validation
- [ ] SQL injection prevention
- [ ] XSS protection
- [ ] Command injection prevention
- [ ] Path traversal protection
- [ ] File upload validation

### Data Protection
- [ ] Encryption at rest
- [ ] Encryption in transit (TLS)
- [ ] Sensitive data masking
- [ ] PII handling compliance
- [ ] Secure key management

### Configuration Security
- [ ] Security headers (CSP, HSTS)
- [ ] CORS configuration
- [ ] Environment variables for secrets
- [ ] Dependency vulnerability scanning
- [ ] Container security

## Vulnerability Reporting Format
1. **Severity**: Critical/High/Medium/Low
2. **Description**: What is the vulnerability
3. **Impact**: Potential damage
4. **Proof of Concept**: How to exploit
5. **Remediation**: Specific fix with code
6. **References**: OWASP, CWE links

## Tools Integration
- npm audit / yarn audit
- Snyk vulnerability scanning
- SAST tool results
- Dependency check reports

Focus on exploitable vulnerabilities with clear remediation paths.',
 'refined_agent_003_security',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 9, 2, datetime('now', '-24 days')),

('agent', 'Database Migration Specialist',
 'Handles complex database migrations with zero downtime strategies',
 '---
name: db-migration-specialist
description: Database migrations and schema changes. Use for any DB modifications.
tools: [Read, Write, Edit, Bash]
model: sonnet
---

You are a database expert specializing in safe, zero-downtime migrations.

## Migration Strategy
1. **Analyze** current schema and data
2. **Plan** migration with rollback strategy
3. **Test** on staging environment
4. **Execute** with monitoring
5. **Verify** data integrity

## Zero-Downtime Patterns
- Expand-Contract for schema changes
- Blue-Green deployments
- Rolling migrations
- Backward compatible changes
- Feature flags for gradual rollout

## Migration Types
### Schema Changes
- Add columns with defaults
- Create indexes CONCURRENTLY
- Rename in multiple steps
- Drop columns safely

### Data Migrations
- Batch processing for large datasets
- Idempotent operations
- Progress tracking
- Data validation

## Safety Checklist
- [ ] Backup before migration
- [ ] Test rollback procedure
- [ ] Monitor query performance
- [ ] Check foreign key constraints
- [ ] Validate data integrity
- [ ] Update ORM models
- [ ] Document changes

## Tools by Database
- PostgreSQL: psql, pg_dump
- MySQL: mysqldump, pt-online-schema-change
- MongoDB: mongodump, change streams
- Redis: BGSAVE, AOF

Always include rollback scripts and test on production-like data.',
 'refined_agent_004_database',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 5, 0, datetime('now', '-21 days')),

('agent', 'API Documentation Generator',
 'Creates comprehensive API documentation with examples, schemas, and testing endpoints',
 '---
name: api-doc-generator
description: Generate API documentation. Use after API changes.
tools: [Read, Write, MultiEdit, Grep]
model: haiku
---

You are a technical writer specializing in API documentation.

## Documentation Components
1. **Overview**: Purpose and architecture
2. **Authentication**: How to authenticate
3. **Endpoints**: Complete reference
4. **Examples**: Curl, JavaScript, Python
5. **Errors**: Error codes and handling
6. **Changelog**: Version history

## Endpoint Documentation Format
```markdown
### [METHOD] /path/to/endpoint

**Description**: What this endpoint does

**Authentication**: Required/Optional

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| param | string | Yes | Parameter description |

**Request Body**:
```json
{
  "field": "value"
}
```

**Response**:
```json
{
  "success": true,
  "data": {}
}
```

**Example**:
```bash
curl -X POST https://api.example.com/endpoint \
  -H "Authorization: Bearer TOKEN" \
  -d \'{"field": "value"}\'
```
```

## OpenAPI/Swagger Integration
- Generate from code annotations
- Include request/response schemas
- Add example values
- Configure authentication
- Enable try-it-out feature

## Best Practices
- Version your API
- Include rate limiting info
- Document deprecations
- Provide SDKs/clients
- Add troubleshooting section

Always test examples against actual API.',
 'refined_agent_005_api_docs',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 2, 0, datetime('now', '-18 days'));

-- =====================================
-- PROMPT PATTERNS (Reusable Prompts)
-- =====================================

INSERT INTO items (type, title, description, content, file_hash, submitter_id, votes_up, votes_down, created_at) VALUES
('prompt', 'Context-Preserving Investigation',
 'Efficiently explores large codebases while preserving context for main task',
 'I need to investigate something specific without losing our main conversation context. Please:

1. **Use Grep/Glob first** to find relevant files
2. **Read only the specific sections** needed (use offset/limit for large files)
3. **Summarize findings concisely** (bullet points preferred)
4. **Return to main task** with minimal context usage

Investigation focus: [SPECIFY WHAT TO INVESTIGATE]

Key questions to answer:
- Where is this implemented?
- What patterns are used?
- Any potential issues or dependencies?

Do NOT read entire directories or large files. Be surgical in your exploration.',
 'refined_prompt_001_context_investigation',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 14, 1, datetime('now', '-30 days')),

('prompt', 'Incremental Feature Implementation',
 'Builds features incrementally with testing and validation at each step',
 'Implement this feature using an incremental approach:

## Step 1: Scaffolding
- Create file structure
- Set up basic types/interfaces
- Add placeholder functions

## Step 2: Core Logic
- Implement main functionality
- Add error handling
- Include logging

## Step 3: Testing
- Write unit tests
- Add integration tests
- Verify edge cases

## Step 4: Integration
- Connect to existing code
- Update documentation
- Run full test suite

## Step 5: Polish
- Optimize performance
- Add comments where needed
- Final code review

**After each step**: 
- Show me what you did
- Run relevant tests
- Get confirmation before proceeding

This ensures we catch issues early and can adjust course if needed.',
 'refined_prompt_002_incremental',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 8, 0, datetime('now', '-28 days')),

('prompt', 'Production Deployment Checklist',
 'Comprehensive pre-deployment validation ensuring production readiness',
 'Before deploying to production, complete this checklist:

## Code Quality
- [ ] All tests passing
- [ ] Type checking passes
- [ ] Linting passes
- [ ] No console.logs in production code
- [ ] Error handling implemented

## Security
- [ ] Environment variables configured
- [ ] Secrets not in code
- [ ] Dependencies updated
- [ ] Security scan passed
- [ ] API rate limiting enabled

## Performance
- [ ] Bundle size acceptable
- [ ] Database queries optimized
- [ ] Caching configured
- [ ] Load testing completed

## Infrastructure
- [ ] Health checks implemented
- [ ] Monitoring configured
- [ ] Logging in place
- [ ] Rollback plan ready
- [ ] Database migrations tested

## Documentation
- [ ] README updated
- [ ] API docs current
- [ ] Changelog updated
- [ ] Team notified

Show me the status of each item and fix any issues found.',
 'refined_prompt_003_deployment',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 11, 0, datetime('now', '-25 days')),

('prompt', 'Debug with Scientific Method',
 'Systematic debugging approach using hypothesis testing and isolation',
 'Debug this issue using the scientific method:

## 1. Observation
- What is the expected behavior?
- What is the actual behavior?
- When does it occur?
- Error messages/logs?

## 2. Hypothesis Formation
List potential causes:
- [ ] Recent code changes
- [ ] Environment differences
- [ ] External dependencies
- [ ] Race conditions
- [ ] Edge cases

## 3. Experiment Design
For each hypothesis:
- How to test it
- What would confirm/refute it
- Minimal reproduction case

## 4. Testing
- Start with most likely cause
- Use debugger/logging
- Isolate the problem
- Test in different environments

## 5. Analysis
- What did we learn?
- Is the root cause identified?
- Are there related issues?

## 6. Solution
- Fix the root cause
- Add tests to prevent regression
- Document the issue and fix

Show your reasoning at each step.',
 'refined_prompt_004_debug_scientific',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 7, 1, datetime('now', '-23 days')),

('prompt', 'Refactor for Maintainability',
 'Systematic refactoring to improve code quality without changing functionality',
 'Refactor this code for better maintainability:

## Analysis Phase
1. Identify code smells:
   - Long functions
   - Duplicate code
   - Complex conditionals
   - Poor naming
   - Tight coupling

2. Measure current state:
   - Cyclomatic complexity
   - Test coverage
   - Dependencies

## Refactoring Strategy
1. **Extract Method**: Break down long functions
2. **Extract Variable**: Clarify complex expressions
3. **Replace Magic Numbers**: Use named constants
4. **Introduce Parameter Object**: Group related parameters
5. **Replace Conditional with Polymorphism**: Simplify complex if/else

## Safety Rules
- Run tests after each change
- Make one change at a time
- Keep commits atomic
- Preserve all functionality
- Update tests if needed

## Quality Metrics
Track improvements in:
- Function length (< 20 lines)
- Cyclomatic complexity (< 10)
- Test coverage (> 80%)
- Type safety
- Documentation

Show before/after comparisons for each refactoring.',
 'refined_prompt_005_refactor',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 4, 0, datetime('now', '-20 days'));

-- =====================================
-- COMMAND PATTERNS (Slash Commands)
-- =====================================

INSERT INTO items (type, title, description, content, file_hash, submitter_id, votes_up, votes_down, created_at) VALUES
('command', '/check-all',
 'Comprehensive code quality check including tests, types, lint, and security',
 '---
description: Run all quality checks
model: haiku
---

# Comprehensive Quality Check

Running all quality checks for the codebase...

## 1. Type Checking
```bash
npm run typecheck || npx tsc --noEmit
```

## 2. Linting
```bash
npm run lint || npx eslint . --ext .ts,.tsx,.js,.jsx
```

## 3. Tests
```bash
npm test || npm run test:ci
```

## 4. Security Audit
```bash
npm audit || yarn audit
```

## 5. Bundle Size
```bash
npm run build && npm run analyze
```

## 6. Documentation
Check for:
- Missing JSDoc comments
- Outdated README sections
- API documentation gaps

## Results Summary
- [ ] Types: PASS/FAIL
- [ ] Lint: PASS/FAIL  
- [ ] Tests: PASS/FAIL
- [ ] Security: PASS/FAIL
- [ ] Bundle: Size KB
- [ ] Docs: Complete/Incomplete

Arguments: $ARGUMENTS (optional: specific directory)',
 'refined_command_001_check_all',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 10, 0, datetime('now', '-29 days')),

('command', '/quick-fix',
 'Rapidly diagnose and fix common development issues',
 '---
description: Quick fixes for common issues
model: sonnet
---

# Quick Fix Assistant

Diagnosing and fixing common issues...

## Common Fixes

### TypeScript Errors
- Run `npm run typecheck` to see all errors
- Common fix: Add type annotations
- Check tsconfig.json settings

### Test Failures
- Run failing test in isolation
- Check recent changes with `git diff`
- Verify test database state

### Build Errors
- Clear cache: `rm -rf node_modules/.cache`
- Reinstall deps: `rm -rf node_modules && npm install`
- Check for version conflicts

### Performance Issues
- Check for infinite loops
- Look for unnecessary re-renders
- Profile with Chrome DevTools

### Git Problems
- Merge conflicts: Use `git status` to identify
- Stash changes: `git stash` before pulling
- Reset to clean state: `git reset --hard HEAD`

## Automated Diagnosis
1. Checking for type errors...
2. Running tests...
3. Checking dependencies...
4. Analyzing recent changes...

Arguments: $ARGUMENTS (describe the issue)',
 'refined_command_002_quick_fix',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 13, 1, datetime('now', '-26 days')),

('command', '/pr-ready',
 'Prepares code for pull request with formatting, tests, and documentation',
 '---
description: Prepare code for PR submission
model: sonnet
---

# Pull Request Preparation

Getting your code PR-ready...

## Pre-PR Checklist

### 1. Code Quality
- [ ] Format code with Prettier
- [ ] Fix linting issues
- [ ] Remove console.logs
- [ ] Add necessary comments

### 2. Testing
- [ ] All tests passing
- [ ] New tests for new features
- [ ] Coverage meets threshold

### 3. Documentation
- [ ] Update README if needed
- [ ] Add JSDoc comments
- [ ] Update CHANGELOG

### 4. Git Hygiene
- [ ] Squash/organize commits
- [ ] Write descriptive commit messages
- [ ] Update from main branch

### 5. Review Preparation
- [ ] Self-review changes
- [ ] Check for sensitive data
- [ ] Verify no debug code

## Automated Steps
```bash
# Format and lint
npm run format && npm run lint:fix

# Run all tests
npm test

# Update from main
git fetch origin main && git rebase origin/main

# Check bundle size
npm run build
```

## PR Description Template
```markdown
## What
Brief description of changes

## Why
Problem this solves

## How
Technical approach

## Testing
How to verify changes

## Screenshots
If UI changes
```

Arguments: $ARGUMENTS (optional: target branch)',
 'refined_command_003_pr_ready',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 6, 0, datetime('now', '-22 days'));

-- =====================================
-- HOOK PATTERNS (Automation)
-- =====================================

INSERT INTO items (type, title, description, content, file_hash, submitter_id, votes_up, votes_down, created_at) VALUES
('hook', 'Smart Auto-Formatter for Multiple Languages',
 'Automatically formats code based on file type with proper tooling',
 '#!/bin/bash
# Smart formatter that detects language and uses appropriate formatter

format_files() {
  local files="$1"
  local ext="$2"
  
  if [ -z "$files" ]; then
    return 0
  fi
  
  case "$ext" in
    "js"|"jsx"|"ts"|"tsx")
      if command -v prettier &> /dev/null; then
        echo "$files" | xargs -r prettier --write --loglevel silent
        echo "✅ Formatted JavaScript/TypeScript files"
      fi
      ;;
    "py")
      if command -v black &> /dev/null; then
        echo "$files" | xargs -r black --quiet
      fi
      if command -v ruff &> /dev/null; then
        echo "$files" | xargs -r ruff check --fix --quiet
      fi
      echo "✅ Formatted Python files"
      ;;
    "go")
      if command -v gofmt &> /dev/null; then
        echo "$files" | xargs -r gofmt -w
        echo "✅ Formatted Go files"
      fi
      ;;
    "rs")
      if command -v rustfmt &> /dev/null; then
        echo "$files" | xargs -r rustfmt --quiet
        echo "✅ Formatted Rust files"
      fi
      ;;
  esac
}

# Process each file type
for ext in js jsx ts tsx py go rs; do
  FILES=$(echo "$CLAUDE_FILE_PATHS" | tr "," "\n" | grep "\.${ext}$")
  format_files "$FILES" "$ext"
done',
 'refined_hook_001_smart_formatter',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 15, 2, datetime('now', '-28 days')),

('hook', 'Git Safety Pre-Commit Validator',
 'Prevents committing sensitive data, broken tests, or invalid code',
 '#!/usr/bin/env python3
import json
import sys
import re
import subprocess

def check_secrets(file_path):
    """Check for potential secrets in file."""
    patterns = [
        r"(?i)(api[_-]?key|apikey|secret|password|token|auth)['\"]?\s*[:=]\s*['\"][^'\"]{8,}",
        r"(?i)bearer\s+[a-z0-9]{20,}",
        r"(?i)aws[_-]?access[_-]?key[_-]?id",
        r"(?i)private[_-]?key",
        r"ghp_[a-zA-Z0-9]{36}",  # GitHub token
    ]
    
    try:
        with open(file_path, "r") as f:
            content = f.read()
            for pattern in patterns:
                if re.search(pattern, content):
                    return False
    except:
        pass
    return True

def run_tests():
    """Run quick unit tests."""
    if subprocess.run(["npm", "test", "--", "--passWithNoTests"], 
                     capture_output=True, timeout=30).returncode != 0:
        return False
    return True

# Main validation
data = json.load(sys.stdin)
file_path = data.get("tool_input", {}).get("file_path", "")

# Check for sensitive files
blocked_files = [".env", ".env.local", "*.pem", "*.key", ".git/"]
if any(pattern in file_path for pattern in blocked_files):
    print(f"🚫 BLOCKED: Cannot modify sensitive file: {file_path}", file=sys.stderr)
    sys.exit(2)

# Check for secrets
if not check_secrets(file_path):
    print(f"⚠️ WARNING: Potential secret detected in {file_path}", file=sys.stderr)
    print("Please use environment variables instead", file=sys.stderr)
    sys.exit(1)

print(f"✅ Pre-commit validation passed for {file_path}")',
 'refined_hook_002_git_safety',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 8, 1, datetime('now', '-24 days')),

('hook', 'Intelligent Test Runner',
 'Runs only affected tests based on changed files for faster feedback',
 '#!/bin/bash
# Intelligently run only affected tests based on changed files

get_test_files() {
  local changed_file="$1"
  local test_file=""
  
  # Convert source file to test file path
  if [[ "$changed_file" =~ \.tsx?$ ]]; then
    # TypeScript/React: Look for .test.ts, .spec.ts, or .test.tsx
    test_file="${changed_file%.*}.test.${changed_file##*.}"
    if [ ! -f "$test_file" ]; then
      test_file="${changed_file%.*}.spec.${changed_file##*.}"
    fi
  elif [[ "$changed_file" =~ \.py$ ]]; then
    # Python: Look for test_ prefix or _test suffix
    dir=$(dirname "$changed_file")
    base=$(basename "$changed_file" .py)
    test_file="$dir/test_$base.py"
    if [ ! -f "$test_file" ]; then
      test_file="$dir/${base}_test.py"
    fi
  fi
  
  echo "$test_file"
}

# Collect test files to run
TEST_FILES=""
IFS="," read -ra FILES <<< "$CLAUDE_FILE_PATHS"
for file in "${FILES[@]}"; do
  test_file=$(get_test_files "$file")
  if [ -f "$test_file" ]; then
    TEST_FILES="$TEST_FILES $test_file"
  fi
done

# Run tests if any found
if [ -n "$TEST_FILES" ]; then
  echo "🧪 Running affected tests..."
  
  if [ -f "package.json" ]; then
    npx jest $TEST_FILES --passWithNoTests &
  elif [ -f "pyproject.toml" ]; then
    pytest $TEST_FILES --quiet &
  fi
  
  echo "✅ Tests started in background (use 'ps aux | grep test' to check)"
else
  echo "ℹ️ No specific tests found for changed files"
fi',
 'refined_hook_003_smart_tests',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 5, 0, datetime('now', '-20 days')),

('hook', 'Session Context Loader with Git History',
 'Loads rich project context including recent changes, TODOs, and branch status',
 '#!/bin/bash
# Load comprehensive project context at session start

echo "📋 Loading enhanced project context..."

# Git context
if [ -d ".git" ]; then
  echo -e "\n🔀 Git Status:"
  echo "Branch: $(git branch --show-current)"
  echo "Upstream: $(git rev-parse --abbrev-ref @{u} 2>/dev/null || echo "not set")"
  
  # Show uncommitted changes
  CHANGES=$(git status --porcelain | wc -l)
  if [ "$CHANGES" -gt 0 ]; then
    echo "⚠️ Uncommitted changes: $CHANGES files"
    git status --short
  fi
  
  echo -e "\n📝 Recent commits:"
  git log --oneline --graph -5
  
  # Show current work based on commit messages
  CURRENT_WORK=$(git log -1 --pretty=%B | head -1)
  echo -e "\n🎯 Last work: $CURRENT_WORK"
fi

# Project type detection
echo -e "\n🔧 Project Setup:"
if [ -f "package.json" ]; then
  echo "Node.js project ($(node -v 2>/dev/null || echo "node not found"))"
  echo "Package manager: $([ -f "yarn.lock" ] && echo "yarn" || [ -f "pnpm-lock.yaml" ] && echo "pnpm" || echo "npm")"
fi

if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  echo "Python project ($(python3 --version 2>/dev/null || echo "python not found"))"
fi

if [ -f "go.mod" ]; then
  echo "Go project ($(go version 2>/dev/null || echo "go not found"))"
fi

# Check for TODOs
TODO_COUNT=$(grep -r "TODO\|FIXME\|HACK" --exclude-dir=node_modules --exclude-dir=.git . 2>/dev/null | wc -l)
if [ "$TODO_COUNT" -gt 0 ]; then
  echo -e "\n📌 Found $TODO_COUNT TODO/FIXME/HACK comments"
fi

# Check for .claude directory
if [ -d ".claude" ]; then
  echo -e "\n🤖 Claude configuration found:"
  [ -d ".claude/commands" ] && echo "  - Custom commands: $(ls .claude/commands/*.md 2>/dev/null | wc -l)"
  [ -d ".claude/agents" ] && echo "  - Custom agents: $(ls .claude/agents/*.md 2>/dev/null | wc -l)"
fi

echo -e "\n✅ Context loaded. Ready to start!"',
 'refined_hook_004_context_loader',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 11, 0, datetime('now', '-16 days')),

('hook', 'Type Safety Enforcer',
 'Blocks edits that introduce TypeScript errors maintaining type safety',
 '#!/bin/bash
# Enforce TypeScript type safety on file changes

# Only check TypeScript files
TS_FILES=$(echo "$CLAUDE_FILE_PATHS" | tr "," "\n" | grep -E "\.(ts|tsx)$")

if [ -n "$TS_FILES" ]; then
  echo "🔍 Checking TypeScript types..."
  
  # Run TypeScript compiler in check mode
  if command -v tsc &> /dev/null; then
    # Check only changed files for faster feedback
    ERROR_OUTPUT=$(echo "$TS_FILES" | xargs npx tsc --noEmit --skipLibCheck 2>&1)
    
    if [ $? -ne 0 ]; then
      echo "❌ TypeScript errors detected:" >&2
      echo "$ERROR_OUTPUT" | head -10 >&2
      echo "Please fix type errors before continuing" >&2
      exit 1
    fi
    
    echo "✅ TypeScript types valid"
  else
    echo "⚠️ TypeScript not found, skipping type check"
  fi
fi',
 'refined_hook_005_type_safety',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 3, 0, datetime('now', '-12 days'));

-- =====================================
-- COMPLETE TAG ASSOCIATIONS
-- =====================================

-- CLAUDE.MD PATTERNS
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_claude_md_001_context_aware'
AND t.name IN ('context-management', 'large-codebase', 'memory', 'claude-md');

INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_claude_md_002_tdd_workflow'
AND t.name IN ('testing', 'tdd', 'workflow', 'claude-md');

INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_claude_md_003_production_api'
AND t.name IN ('typescript', 'api', 'production', 'observability', 'claude-md');

INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_claude_md_004_component_library'
AND t.name IN ('react', 'components', 'accessibility', 'testing', 'claude-md');

INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_claude_md_005_monorepo'
AND t.name IN ('monorepo', 'architecture', 'ci-cd', 'claude-md');

-- AGENT PATTERNS
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_agent_001_tdd_generator'
AND t.name IN ('testing', 'tdd', 'automation', 'agents');

INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_agent_002_performance'
AND t.name IN ('performance', 'optimization', 'debugging', 'agents');

INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_agent_003_security'
AND t.name IN ('security', 'vulnerability', 'owasp', 'agents');

INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_agent_004_database'
AND t.name IN ('database', 'migration', 'sql', 'agents');

INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_agent_005_api_docs'
AND t.name IN ('documentation', 'api', 'automation', 'agents');

-- PROMPT PATTERNS
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_prompt_001_context_investigation'
AND t.name IN ('context-management', 'large-codebase', 'workflow', 'prompts');

INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_prompt_002_incremental'
AND t.name IN ('workflow', 'testing', 'best-practices', 'prompts');

INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_prompt_003_deployment'
AND t.name IN ('deployment', 'ci-cd', 'production', 'prompts');

INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_prompt_004_debug_scientific'
AND t.name IN ('debugging', 'troubleshooting', 'workflow', 'prompts');

INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_prompt_005_refactor'
AND t.name IN ('refactoring', 'clean-code', 'quality', 'prompts');

-- COMMAND PATTERNS
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_command_001_check_all'
AND t.name IN ('quality', 'testing', 'automation', 'commands');

INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_command_002_quick_fix'
AND t.name IN ('debugging', 'troubleshooting', 'workflow', 'commands');

INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_command_003_pr_ready'
AND t.name IN ('git', 'pr', 'workflow', 'commands');

-- HOOK PATTERNS
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_hook_001_smart_formatter'
AND t.name IN ('formatting', 'automation', 'hooks');

INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_hook_002_git_safety'
AND t.name IN ('security', 'git', 'validation', 'hooks');

INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_hook_003_smart_tests'
AND t.name IN ('testing', 'automation', 'performance', 'hooks');

INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_hook_004_context_loader'
AND t.name IN ('context', 'git', 'workflow', 'hooks');

INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'refined_hook_005_type_safety'
AND t.name IN ('typescript', 'validation', 'safety', 'hooks');

-- Verify data insertion
SELECT type, COUNT(*) as count FROM items GROUP BY type;
SELECT COUNT(*) as total_patterns FROM items;
SELECT COUNT(*) as total_tags FROM tags;
