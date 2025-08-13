#!/bin/bash

# Setup script for Cloudflare Workers secrets (2025 security best practice)
# This moves sensitive values from environment variables to encrypted secrets

echo "🔒 Setting up Cloudflare Workers secrets for enhanced security..."
echo ""
echo "This script will prompt you to enter sensitive values that will be"
echo "stored as encrypted secrets in Cloudflare Workers."
echo ""
echo "Required secrets:"
echo "1. GITHUB_CLIENT_ID - Your GitHub OAuth App Client ID"
echo "2. GITHUB_CLIENT_SECRET - Your GitHub OAuth App Client Secret"
echo "3. SESSION_SECRET - A random string for encrypting session data (we'll generate one if not provided)"
echo ""

# Function to generate a secure random secret
generate_secret() {
    openssl rand -base64 32 2>/dev/null || head -c 32 /dev/urandom | base64
}

# Check if we're in production or local
read -p "Are you setting up for production? (y/n): " IS_PROD

if [ "$IS_PROD" = "y" ] || [ "$IS_PROD" = "Y" ]; then
    REMOTE_FLAG="--remote"
    echo "Setting up PRODUCTION secrets..."
else
    REMOTE_FLAG=""
    echo "Setting up LOCAL development secrets..."
fi

# GitHub OAuth credentials
echo ""
echo "GitHub OAuth Setup:"
read -p "Enter your GitHub Client ID: " GITHUB_CLIENT_ID
read -s -p "Enter your GitHub Client Secret: " GITHUB_CLIENT_SECRET
echo ""

# Session encryption secret
echo ""
echo "Session Encryption:"
read -p "Enter a session secret (or press Enter to generate one): " SESSION_SECRET

if [ -z "$SESSION_SECRET" ]; then
    SESSION_SECRET=$(generate_secret)
    echo "Generated session secret: $SESSION_SECRET"
    echo "⚠️  Save this secret securely! You'll need it for other environments."
fi

# Set the secrets using wrangler
echo ""
echo "Setting secrets in Cloudflare Workers..."

echo "$GITHUB_CLIENT_ID" | wrangler secret put GITHUB_CLIENT_ID $REMOTE_FLAG
echo "$GITHUB_CLIENT_SECRET" | wrangler secret put GITHUB_CLIENT_SECRET $REMOTE_FLAG
echo "$SESSION_SECRET" | wrangler secret put SESSION_SECRET $REMOTE_FLAG

echo ""
echo "✅ Secrets have been configured successfully!"
echo ""
echo "Note: These secrets are now encrypted and stored securely in Cloudflare."
echo "They will be available to your Worker at runtime but not visible in logs or code."
echo ""
echo "To verify your secrets are set, run:"
echo "  wrangler secret list $REMOTE_FLAG"