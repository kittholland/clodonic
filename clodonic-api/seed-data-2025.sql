-- Clodonic Pattern Repository Seed Data
-- Generated: August 2025
-- Based on current Claude Code best practices and community patterns

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
 142, 3, datetime('now', '-30 days')),

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
 89, 2, datetime('now', '-25 days')),

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
 76, 1, datetime('now', '-20 days')),

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

# Platform Guidelines
- Design for both iOS and Android
- Use Platform.select() for platform-specific code
- Test on physical devices before release
- Follow platform-specific design patterns

# Performance
- Optimize images and bundle size
- Use FlatList for long lists
- Implement proper loading states
- Profile with Flipper for debugging',
 'seed_claude_md_004_react_native',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 63, 2, datetime('now', '-18 days')),

('claude_md', 'Enterprise Java Spring Boot Application',
 'Corporate Java application with Spring Boot, security, and microservices architecture',
 '# Tech Stack
- Java 21 + Spring Boot 3.2
- Database: PostgreSQL with JPA/Hibernate
- Security: Spring Security + JWT
- Testing: JUnit 5 + TestContainers

# Commands
- `./mvnw spring-boot:run`: Start application
- `./mvnw test`: Run unit tests
- `./mvnw verify`: Run integration tests
- `./mvnw spotless:apply`: Format code

# Code Standards
- Follow Google Java Style Guide
- Use constructor injection over field injection
- Write comprehensive JavaDoc
- Validate inputs with Bean Validation

# Architecture
- Clean Architecture with distinct layers
- RESTful APIs with OpenAPI documentation
- Database migrations with Flyway
- Centralized error handling and logging',
 'seed_claude_md_005_java_spring',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 54, 1, datetime('now', '-15 days')),

('claude_md', 'Next.js SaaS Application Development',
 'Modern SaaS application with Next.js, authentication, payments, and deployment',
 '# Tech Stack
- Next.js 14 with App Router
- Authentication: NextAuth.js
- Database: Prisma + PostgreSQL
- Payments: Stripe integration
- Deployment: Vercel

# Commands
- `npm run dev`: Development server
- `npx prisma db push`: Update database schema
- `npx prisma studio`: Database GUI
- `npm run build`: Production build

# SaaS Features
- Multi-tenant architecture support
- Subscription management with Stripe
- Role-based access control
- Email notifications with Resend

# Security & Performance
- HTTPS only in production
- Input validation and sanitization  
- Rate limiting on API routes
- Image optimization and lazy loading
- SEO optimization for marketing pages',
 'seed_claude_md_006_nextjs_saas',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 98, 3, datetime('now', '-12 days'));

-- =====================================
-- AGENT PATTERNS (Subagents)
-- =====================================

INSERT INTO items (type, title, description, content, file_hash, submitter_id, votes_up, votes_down, created_at) VALUES
('agent', 'Frontend React Specialist', 
 'Expert React developer for components, hooks, state management, and modern frontend patterns',
 '---
name: frontend-react-specialist
description: Expert React developer. Use PROACTIVELY for any React/frontend work.
tools: [Read, Edit, MultiEdit, Glob, Grep, Bash]
model: sonnet
---

You are a senior React frontend developer with expertise in:

## Core Skills
- Modern React (hooks, context, suspense, concurrent features)
- TypeScript integration and type safety
- State management (React Query, Zustand, Redux Toolkit)
- Component architecture and reusability
- Performance optimization
- CSS-in-JS and Tailwind CSS
- Testing with Jest and React Testing Library

## Approach
1. Component First: Think in reusable, composable components
2. Type Safety: Ensure proper TypeScript types
3. Performance: Implement memoization appropriately
4. Accessibility: Follow WCAG guidelines
5. Modern Patterns: Use custom hooks effectively

## Best Practices
- Prefer functional components and hooks
- Use React.StrictMode and error boundaries
- Follow "lift state up" principle
- Implement proper loading and error states
- Use React DevTools for debugging

Always consider mobile-first responsive design.',
 'seed_agent_001_react_specialist',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 187, 5, datetime('now', '-28 days')),

('agent', 'Backend API Architect',
 'Design and implement robust REST APIs, GraphQL endpoints, and microservice architectures',
 '---
name: backend-api-architect
description: Design robust APIs and backend systems. Use PROACTIVELY for backend work.
tools: [Read, Edit, MultiEdit, Glob, Grep, Bash]
model: sonnet
---

You are a senior backend architect specializing in:

## Core Expertise
- RESTful API design and GraphQL
- Database design (SQL and NoSQL)
- Microservices architecture
- Authentication & authorization
- Caching strategies
- Message queues and event-driven architecture

## Technology Stack
- Node.js, Python, Go
- PostgreSQL, MongoDB, Redis
- AWS, GCP, Azure

## Design Principles
1. API-First Design
2. Security by Default
3. Scalability
4. Observability
5. Error Handling

## Best Practices
- Use proper HTTP status codes
- Implement rate limiting
- Design for idempotency
- Use database transactions appropriately
- Follow 12-factor app methodology

Always consider performance, security, and maintainability.',
 'seed_agent_002_backend_architect',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 156, 4, datetime('now', '-26 days')),

('agent', 'Code Security Auditor',
 'Comprehensive security analysis for vulnerabilities and compliance',
 '---
name: code-security-auditor
description: Security vulnerability analysis. MUST BE USED for security-critical code.
tools: [Read, Grep, Glob, Bash]
model: opus
---

You are a cybersecurity expert specializing in:

## Security Focus Areas
- Input validation and injection prevention
- Authentication and authorization flaws
- Sensitive data exposure
- Dependency vulnerabilities
- Compliance (OWASP Top 10, SOC2)

## Analysis Approach
1. Static Analysis
2. Dependency Scanning
3. Configuration Review
4. Data Flow Analysis
5. Access Control Verification

## Common Vulnerabilities
- SQL/NoSQL injection
- XSS and CSRF
- Insecure object references
- Security misconfigurations
- Insecure cryptographic storage

## Reporting Standards
- Categorize by severity
- Provide remediation steps
- Include secure code examples
- Reference OWASP guidelines

Always assume hostile input and design defenses accordingly.',
 'seed_agent_003_security_auditor',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 134, 2, datetime('now', '-22 days')),

('agent', 'Test Automation Engineer',
 'Comprehensive testing strategy including unit, integration, and E2E testing',
 '---
name: test-automation-engineer
description: Testing strategy and automation. Use PROACTIVELY when writing code.
tools: [Read, Edit, MultiEdit, Glob, Grep, Bash]
model: sonnet
---

You are a senior test automation engineer with expertise in:

## Testing Pyramid
- Unit Tests: Fast, isolated tests
- Integration Tests: Component interactions
- E2E Tests: Full user journeys
- Contract Tests: API validation

## Technology Stack
- Jest, Vitest, pytest, JUnit
- React Testing Library
- Playwright, Cypress
- K6, JMeter for performance

## Testing Strategy
1. Test-Driven Development
2. Behavior-Driven Development
3. Risk-Based Testing
4. Continuous Testing
5. Test Data Management

## Best Practices
- Follow AAA pattern
- Write descriptive test names
- Keep tests independent
- Use proper test doubles
- Maintain 80%+ coverage for critical paths

Always write reliable, maintainable tests.',
 'seed_agent_004_test_automation',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 112, 3, datetime('now', '-19 days')),

('agent', 'DevOps Infrastructure Specialist',
 'Cloud infrastructure, CI/CD pipelines, and containerization expertise',
 '---
name: devops-infrastructure-specialist
description: Infrastructure and deployment. Use PROACTIVELY for DevOps work.
tools: [Read, Edit, MultiEdit, Glob, Grep, Bash]
model: sonnet
---

You are a senior DevOps engineer specializing in:

## Core Infrastructure
- Cloud platforms (AWS, GCP, Azure)
- Infrastructure as Code (Terraform)
- Container orchestration (Docker, Kubernetes)
- Serverless computing

## CI/CD Excellence
- GitHub Actions, GitLab CI
- GitOps workflows
- Progressive delivery
- Infrastructure provisioning

## Monitoring & Observability
- Prometheus, Grafana
- ELK stack
- Distributed tracing
- Error tracking

## Best Practices
1. Everything as Code
2. Immutable Infrastructure
3. Security First
4. Automation
5. Comprehensive Monitoring

Focus on reliability, scalability, and security.',
 'seed_agent_005_devops_specialist',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 95, 2, datetime('now', '-16 days'));

-- =====================================
-- PROMPT PATTERNS (Reusable Prompts)
-- =====================================

INSERT INTO items (type, title, description, content, file_hash, submitter_id, votes_up, votes_down, created_at) VALUES
('prompt', 'Analyze Codebase and Create Implementation Plan',
 'Systematically explores relevant files and creates a detailed implementation plan before coding',
 'First, read all relevant files for this task - don''t write any code yet, just gather context. Then:

1. Analyze the current codebase structure and identify the files/components involved
2. Look for existing patterns, naming conventions, and architectural decisions
3. Check for any related tests or documentation
4. Create a step-by-step implementation plan that includes:
   - Which files need to be modified or created
   - Dependencies and integrations required
   - Testing approach
   - Any potential breaking changes or risks

Only after presenting this plan and getting approval should you proceed with implementation.',
 'seed_prompt_001_analyze_plan',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 165, 6, datetime('now', '-27 days')),

('prompt', 'Perform Security-Focused Code Review',
 'Conducts thorough code review focusing on bugs, security vulnerabilities, and performance',
 'As a senior developer with 20+ years of experience, perform a comprehensive code review focusing on:

**Priority Issues:**
- Bugs and logical errors
- Security vulnerabilities (injection, XSS, auth bypass, etc.)
- Performance bottlenecks

**Secondary Review:**
- Code readability and maintainability
- Architectural consistency
- Error handling completeness

Be concise but thorough. For each issue found:
1. Explain the problem clearly
2. Show the problematic code
3. Provide a specific fix with example code
4. Explain why this fix improves the codebase

Skip minor style issues unless they impact functionality.',
 'seed_prompt_002_security_review',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 143, 3, datetime('now', '-24 days')),

('prompt', 'Smart Git Operations and PR Creation',
 'Handles git operations, creates commits with proper messages, and generates pull requests',
 'Handle git operations intelligently:

1. **Before any commits:**
   - Run git status to see current state
   - Review all changes with git diff
   - Check recent commit history for message patterns

2. **For commits:**
   - Create descriptive commit messages following the existing pattern
   - Focus on "why" not just "what"
   - Stage only relevant files
   - Include co-author attribution

3. **For pull requests:**
   - Analyze all commits that will be included
   - Create clear title and summary
   - Include test plan and verification steps
   - Return the PR URL when complete

Always ask before pushing to remote unless explicitly requested.',
 'seed_prompt_003_git_workflow',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 128, 2, datetime('now', '-21 days')),

('prompt', 'Systematic Bug Investigation and Fix',
 'Methodically investigates errors, reproduces issues, and implements robust fixes',
 'Systematically debug this issue:

**1. Understand the Problem:**
- Read error messages and stack traces carefully
- Identify when/where the issue occurs
- Gather reproduction steps if not provided
- Check logs and monitoring data

**2. Investigate Root Cause:**
- Trace the code path leading to the error
- Identify the specific line or function causing issues
- Check related code, dependencies, and configuration
- Look for similar issues in commit history

**3. Develop Solution:**
- Create minimal reproduction case if possible
- Design fix that addresses root cause, not just symptoms
- Consider edge cases and potential side effects
- Write/update tests to prevent regression

**4. Validate Fix:**
- Test the fix thoroughly
- Run full test suite
- Verify no new issues introduced
- Document the fix and its reasoning

Show your investigation process and get approval for the fix approach.',
 'seed_prompt_004_debug_systematic',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 87, 1, datetime('now', '-11 days'));

-- =====================================
-- COMMAND PATTERNS (Slash Commands)
-- =====================================

INSERT INTO items (type, title, description, content, file_hash, submitter_id, votes_up, votes_down, created_at) VALUES
('command', '/dev:code-review',
 'Comprehensive code review focusing on best practices, security, and maintainability',
 '# Code Review

Perform a thorough code review of the current changes or specified files. Focus on:

## Review Areas
- **Code Quality**: Style, readability, and maintainability
- **Security**: Potential vulnerabilities and security best practices
- **Performance**: Efficiency and optimization opportunities
- **Testing**: Test coverage and quality
- **Architecture**: Design patterns and structure

## Instructions
1. Analyze the code changes using git diff or specified files
2. Identify issues categorized by severity (Critical, Major, Minor)
3. Provide specific, actionable suggestions with code examples
4. Highlight positive patterns and good practices
5. Suggest improvements for documentation if needed

Arguments: $ARGUMENTS (optional file paths or git refs)',
 'seed_command_001_code_review',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 154, 4, datetime('now', '-29 days')),

('command', '/test:generate',
 'Generate comprehensive unit and integration tests for specified code',
 '# Test Generation

Generate comprehensive test cases for the specified code or module.

## Test Strategy
- **Unit Tests**: Individual function/method testing
- **Integration Tests**: Component interaction testing
- **Edge Cases**: Boundary conditions and error scenarios
- **Mock Setup**: External dependencies mocking

## Instructions
1. Analyze the target code structure and dependencies
2. Create test files following project conventions
3. Generate test cases covering:
   - Happy path scenarios
   - Edge cases and error conditions
   - Input validation
   - State changes and side effects
4. Include setup/teardown as needed
5. Add descriptive test names and comments

Arguments: $ARGUMENTS (required - file path or function name)',
 'seed_command_002_test_generate',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 139, 3, datetime('now', '-23 days')),

('command', '/docs:generate',
 'Generate comprehensive documentation for code, APIs, or project structure',
 '# Documentation Generator

Generate comprehensive documentation for specified code or project components.

## Documentation Types
- **API Documentation**: Endpoints, parameters, responses
- **Code Documentation**: Function/class documentation
- **README Updates**: Project overview and usage
- **Architecture Docs**: System design and data flow

## Instructions
1. Analyze the target code or project structure
2. Generate appropriate documentation format (JSDoc, OpenAPI, etc.)
3. Include:
   - Purpose and functionality descriptions
   - Usage examples with code snippets
   - Parameter and return value documentation
   - Error handling and edge cases
4. Follow project documentation standards
5. Ensure examples are tested and accurate

Arguments: $ARGUMENTS (required - files, modules, or ''project'' for full docs)',
 'seed_command_003_docs_generate',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 82, 1, datetime('now', '-8 days'));

-- =====================================
-- HOOK PATTERNS (Automation)
-- =====================================

INSERT INTO items (type, title, description, content, file_hash, submitter_id, votes_up, votes_down, created_at) VALUES
('hook', 'Auto-Format Python Code After Edits',
 'Automatically formats Python files with Black and Ruff after any code changes',
 '#!/bin/bash
FILES=$(echo "$CLAUDE_FILE_PATHS" | tr '','' ''\n'' | grep ''\.py$'')
if [ -n "$FILES" ]; then
  echo "$FILES" | xargs -r ruff check --fix --quiet
  echo "$FILES" | xargs -r black --quiet
  echo "✅ Python files formatted"
fi',
 'seed_hook_001_python_format',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 134, 3, datetime('now', '-26 days')),

('hook', 'Block Dangerous File Operations',
 'Prevents modifications to sensitive files like .env, package-lock.json, and git files',
 '#!/usr/bin/env python3
import json, sys, os
data = json.load(sys.stdin)
file_path = data.get(''tool_input'', {}).get(''file_path'', '''')
dangerous_patterns = [''.env'', ''package-lock.json'', ''.git/'', ''node_modules/'', ''*.pem'', ''*.key'']
if any(pattern in file_path for pattern in dangerous_patterns):
    print(f"🚫 BLOCKED: Cannot modify sensitive file: {os.path.basename(file_path)}", file=sys.stderr)
    sys.exit(2)',
 'seed_hook_002_block_dangerous',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 118, 2, datetime('now', '-22 days')),

('hook', 'Run Tests After Code Changes',
 'Automatically runs project tests in the background after code modifications',
 '#!/bin/bash
if [[ "$CLAUDE_FILE_PATHS" =~ \.(js|ts|py|rb|go|rs)$ ]]; then
  echo "🧪 Running tests in background..."
  if [ -f "package.json" ]; then
    npm test --silent &
  elif [ -f "pytest.ini" ] || [ -f "pyproject.toml" ]; then
    pytest --quiet &
  elif [ -f "Gemfile" ]; then
    bundle exec rspec --format progress &
  fi
  echo "✅ Tests started"
fi',
 'seed_hook_003_run_tests',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 102, 1, datetime('now', '-18 days')),

('hook', 'Add Session Context',
 'Loads recent git changes and project status at the beginning of each session',
 '#!/bin/bash
echo "📋 Loading project context..."
if [ -d ".git" ]; then
  echo "Recent commits:" && git log --oneline -5
  echo "Current status:" && git status --porcelain
  echo "Current branch:" && git branch --show-current
fi
if [ -f "package.json" ]; then
  echo "Node.js project detected"
fi
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  echo "Python project detected"
fi
echo "✅ Context loaded"',
 'seed_hook_004_session_context',
 (SELECT id FROM users WHERE username = 'clodonic-system'),
 71, 1, datetime('now', '-10 days'));

-- =====================================
-- COMPLETE TAG ASSOCIATIONS (3-5 tags per pattern)
-- Model of proper tagging for seeded patterns
-- =====================================

-- CLAUDE.MD PATTERNS
-- Full-Stack Web Application Development Guide
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_claude_md_001_fullstack_web'
AND t.name IN ('typescript', 'react', 'nodejs', 'full-stack');

-- Python Data Science Project Guide
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_claude_md_002_python_data_science'
AND t.name IN ('python', 'data-science', 'testing');

-- DevOps and Infrastructure Management
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_claude_md_003_devops_infrastructure'
AND t.name IN ('devops', 'docker', 'kubernetes', 'infrastructure');

-- React Native Mobile Development
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_claude_md_004_react_native'
AND t.name IN ('react-native', 'mobile', 'typescript');

-- Enterprise Java Spring Boot Application
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_claude_md_005_java_spring'
AND t.name IN ('java', 'spring-boot', 'database', 'api');

-- Next.js SaaS Application Development
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_claude_md_006_nextjs_saas'
AND t.name IN ('nextjs', 'saas', 'typescript', 'authentication');

-- AGENT PATTERNS
-- Frontend React Specialist
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_agent_001_react_specialist'
AND t.name IN ('react', 'frontend', 'typescript', 'performance');

-- Backend API Architect
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_agent_002_backend_architect'
AND t.name IN ('backend', 'api', 'architecture', 'nodejs');

-- Code Security Auditor
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_agent_003_security_auditor'
AND t.name IN ('security', 'validation', 'quality', 'code-review');

-- Test Automation Engineer
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_agent_004_test_automation'
AND t.name IN ('testing', 'automation', 'tdd', 'ci-cd');

-- DevOps Infrastructure Specialist
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_agent_005_devops_specialist'
AND t.name IN ('devops', 'kubernetes', 'ci-cd', 'infrastructure');

-- PROMPT PATTERNS
-- Analyze Codebase and Create Implementation Plan
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_prompt_001_analyze_plan'
AND t.name IN ('planning', 'architecture', 'workflow');

-- Perform Security-Focused Code Review
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_prompt_002_security_review'
AND t.name IN ('security', 'code-review', 'quality');

-- Smart Git Operations and PR Creation
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_prompt_003_git_workflow'
AND t.name IN ('git', 'workflow', 'automation');

-- Systematic Bug Investigation and Fix
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_prompt_004_debug_systematic'
AND t.name IN ('debugging', 'testing', 'workflow');

-- COMMAND PATTERNS
-- /dev:code-review
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_command_001_code_review'
AND t.name IN ('code-review', 'quality', 'security');

-- /test:generate
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_command_002_test_generate'
AND t.name IN ('testing', 'automation', 'tdd');

-- /docs:generate
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_command_003_docs_generate'
AND t.name IN ('documentation', 'api', 'automation');

-- HOOK PATTERNS
-- Auto-Format Python Code After Edits
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_hook_001_python_format'
AND t.name IN ('python', 'formatting', 'automation', 'hooks');

-- Block Dangerous File Operations
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_hook_002_block_dangerous'
AND t.name IN ('security', 'validation', 'hooks');

-- Run Tests After Code Changes
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_hook_003_run_tests'
AND t.name IN ('testing', 'automation', 'ci-cd', 'hooks');

-- Add Session Context
INSERT INTO item_tags (item_id, tag_id)
SELECT i.id, t.id FROM items i, tags t
WHERE i.file_hash = 'seed_hook_004_session_context'
AND t.name IN ('git', 'workflow', 'hooks');

-- Verify data insertion
SELECT type, COUNT(*) as count FROM items GROUP BY type;
SELECT COUNT(*) as total_patterns FROM items;
SELECT COUNT(*) as total_tags FROM tags;
SELECT username, COUNT(*) as patterns_submitted FROM users u JOIN items i ON u.id = i.submitter_id GROUP BY username;

-- Verify tagging (3-5 tags per pattern)
SELECT i.title, i.type, GROUP_CONCAT(t.name) as tags, COUNT(t.id) as tag_count
FROM items i
LEFT JOIN item_tags it ON i.id = it.item_id
LEFT JOIN tags t ON it.tag_id = t.id
WHERE i.submitter_id = (SELECT id FROM users WHERE username = 'clodonic-system')
GROUP BY i.id
ORDER BY i.type, i.title;