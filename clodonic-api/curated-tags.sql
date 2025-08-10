-- Curated tag system for Clodonic
-- Clear existing tags and recreate with curated list

-- Clear existing tags (we'll migrate the 10 current tags to closest matches)
DELETE FROM item_tags;
DELETE FROM tags;

-- Programming Languages (30 tags)
INSERT INTO tags (name, category) VALUES
-- Web Languages
('javascript', 'languages'),
('typescript', 'languages'),
('html', 'languages'),
('css', 'languages'),
('php', 'languages'),

-- Systems Languages
('rust', 'languages'),
('go', 'languages'),
('c', 'languages'),
('cpp', 'languages'),
('zig', 'languages'),

-- Enterprise Languages
('java', 'languages'),
('csharp', 'languages'),
('kotlin', 'languages'),
('scala', 'languages'),

-- Scripting Languages
('python', 'languages'),
('ruby', 'languages'),
('bash', 'languages'),
('shell', 'languages'),
('powershell', 'languages'),
('perl', 'languages'),

-- Functional Languages
('haskell', 'languages'),
('elixir', 'languages'),
('clojure', 'languages'),
('fsharp', 'languages'),

-- Mobile Languages
('swift', 'languages'),
('dart', 'languages'),
('objectivec', 'languages'),

-- Other Languages
('r', 'languages'),
('matlab', 'languages'),
('lua', 'languages'),
('sql', 'languages');

-- Frontend Frameworks (15 tags)
INSERT INTO tags (name, category) VALUES
-- React Ecosystem
('react', 'frontend'),
('nextjs', 'frontend'),
('remix', 'frontend'),
('gatsby', 'frontend'),

-- Vue Ecosystem
('vue', 'frontend'),
('nuxt', 'frontend'),
('quasar', 'frontend'),

-- Other Frontend
('angular', 'frontend'),
('svelte', 'frontend'),
('sveltekit', 'frontend'),
('solid', 'frontend'),
('lit', 'frontend'),
('alpine', 'frontend'),
('htmx', 'frontend'),
('jquery', 'frontend');

-- Backend Frameworks (20 tags)
INSERT INTO tags (name, category) VALUES
-- Python Backend
('django', 'backend'),
('flask', 'backend'),
('fastapi', 'backend'),
('pyramid', 'backend'),

-- JavaScript Backend
('express', 'backend'),
('nestjs', 'backend'),
('koa', 'backend'),
('hapi', 'backend'),

-- Java Backend
('spring', 'backend'),
('springboot', 'backend'),
('quarkus', 'backend'),

-- Ruby Backend
('rails', 'backend'),
('sinatra', 'backend'),

-- PHP Backend
('laravel', 'backend'),
('symfony', 'backend'),
('codeigniter', 'backend'),

-- Other Backend
('gin', 'backend'),
('echo', 'backend'),
('actix', 'backend'),
('axum', 'backend');

-- Databases & Storage (15 tags)
INSERT INTO tags (name, category) VALUES
-- Relational Databases
('postgresql', 'database'),
('mysql', 'database'),
('sqlite', 'database'),
('oracle', 'database'),
('sqlserver', 'database'),

-- NoSQL Databases
('mongodb', 'database'),
('redis', 'database'),
('elasticsearch', 'database'),
('cassandra', 'database'),
('dynamodb', 'database'),

-- Graph Databases
('neo4j', 'database'),
('arangodb', 'database'),

-- Time Series Databases
('influxdb', 'database'),
('timescaledb', 'database'),

-- Storage
('s3', 'database');

-- Cloud & DevOps (25 tags)
INSERT INTO tags (name, category) VALUES
-- Cloud Platforms
('aws', 'cloud'),
('azure', 'cloud'),
('gcp', 'cloud'),
('cloudflare', 'cloud'),
('vercel', 'cloud'),
('netlify', 'cloud'),

-- Containers
('docker', 'devops'),
('kubernetes', 'devops'),
('helm', 'devops'),
('podman', 'devops'),

-- CI/CD
('github-actions', 'devops'),
('gitlab-ci', 'devops'),
('jenkins', 'devops'),
('circleci', 'devops'),

-- Infrastructure
('terraform', 'devops'),
('ansible', 'devops'),
('chef', 'devops'),
('puppet', 'devops'),

-- Monitoring
('prometheus', 'devops'),
('grafana', 'devops'),
('datadog', 'devops'),
('newrelic', 'devops'),

-- Web Servers
('nginx', 'devops'),
('apache', 'devops'),
('caddy', 'devops');

-- Purpose/Intent (15 tags)
INSERT INTO tags (name, category) VALUES
('testing', 'purpose'),
('debugging', 'purpose'),
('analysis', 'purpose'),
('validation', 'purpose'),
('refactoring', 'purpose'),
('documentation', 'purpose'),
('automation', 'purpose'),
('security', 'purpose'),
('performance', 'purpose'),
('migration', 'purpose'),
('deployment', 'purpose'),
('monitoring', 'purpose'),
('backup', 'purpose'),
('logging', 'purpose'),
('caching', 'purpose');

-- Difficulty/Safety (6 tags)
INSERT INTO tags (name, category) VALUES
('beginner', 'safety'),
('intermediate', 'safety'),
('advanced', 'safety'),
('experimental', 'safety'),
('safe', 'safety'),
('production-ready', 'safety');

-- Domain/Application (8 tags)
INSERT INTO tags (name, category) VALUES
('web', 'domain'),
('api', 'domain'),
('mobile', 'domain'),
('desktop', 'domain'),
('cli', 'domain'),
('ml', 'domain'),
('ai', 'domain'),
('fullstack', 'domain');

-- Database is reset, so no existing patterns to re-tag