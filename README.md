# Clodonic

> Idiomatic patterns for Claude Code

A minimalist pattern repository for Claude Code best practices, making idiomatic usage discoverable and shareable.

## 🚀 Live Site

[clodonic.ai](https://clodonic.ai) (deployment pending)

## 📦 Features

- **Pattern Types**: CLAUDE.md files, Agents, Prompts, Hooks, Commands
- **GitHub Authentication**: Sign in with GitHub for voting and attribution
- **Smart Filtering**: Browse by type, sort by trending/top/new
- **Duplicate Detection**: SHA256 hashing prevents duplicate submissions
- **Minimalist Design**: Fast, accessible, works without JavaScript

## 🛠 Tech Stack

- **Frontend**: Static HTML/CSS with minimal JS
- **Backend**: Cloudflare Workers with Hono
- **Database**: Cloudflare D1 (SQLite)
- **Auth**: GitHub OAuth
- **Deployment**: Cloudflare Workers with Git integration

## 🏃‍♂️ Local Development

```bash
# Install dependencies
cd clodonic-api
npm install

# Set up local database
wrangler d1 execute clodonic-db --local --file=schema.sql

# Start dev server
npm run dev

# Open browser
open http://localhost:8787
```

## 🚢 Deployment

See [DEPLOYMENT-2025.md](./DEPLOYMENT-2025.md) for detailed deployment instructions.

Quick steps:
1. Create GitHub OAuth app
2. Push to GitHub
3. Connect Cloudflare Workers to GitHub
4. Configure secrets
5. Deploy automatically on push

## 📁 Project Structure

```
/clodonic
  /clodonic-api         # API and frontend
    /src
      - index.ts        # Main API routes
      - auth.ts         # OAuth logic
    /public
      - index.html      # Frontend
    - schema.sql        # Database schema
    - wrangler.jsonc    # Cloudflare config
  - REQUIREMENTS.md     # Full requirements spec
  - DEPLOYMENT-2025.md  # Deployment guide
  - CLAUDE.md          # Project context for Claude
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-pattern`)
3. Commit your changes (`git commit -m 'Add amazing pattern'`)
4. Push to the branch (`git push origin feature/amazing-pattern`)
5. Open a Pull Request

## 📜 License

MIT

## 🙏 Acknowledgments

Built with Claude Code for the Claude Code community.