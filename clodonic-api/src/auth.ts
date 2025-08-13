import { Context } from 'hono';
import { getCookie } from 'hono/cookie';
import { GitHub } from 'arctic';
import { encryptSession, decryptSession, generateSessionId, hashValue } from './crypto';

// Session interface
interface Session {
  userId: number;
  username: string;
  createdAt: number;
}

// Encrypted session data structure
interface EncryptedSessionData {
  userId: number;
  username: string;
  createdAt: number;
  ip?: string;
  userAgent?: string;
}

// Create encrypted session in D1 (2025 security enhancement)
export async function createSession(
  db: D1Database,
  userId: number, 
  username: string,
  sessionSecret: string,
  ip?: string,
  userAgent?: string
): Promise<string> {
  const sessionId = generateSessionId();
  const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 days
  
  // Create session data object
  const sessionData: EncryptedSessionData = {
    userId,
    username,
    createdAt: Date.now(),
    ip,
    userAgent
  };
  
  // Encrypt session data using AES-256-GCM
  const encrypted = await encryptSession(
    JSON.stringify(sessionData),
    sessionSecret
  );
  
  // Store encrypted session with hashed ID for lookup
  const hashedId = await hashValue(sessionId);
  
  await db.prepare(
    `INSERT INTO sessions (id, hashed_id, encrypted_data, encrypted_iv, encrypted_salt, expires_at) 
     VALUES (?, ?, ?, ?, ?, ?)`
  ).bind(
    sessionId, // Store plain ID for backwards compatibility
    hashedId,  // Hash for secure lookups
    encrypted.ciphertext,
    encrypted.iv,
    encrypted.salt,
    expiresAt.toISOString()
  ).run();
  
  return sessionId;
}

// Get and decrypt session from D1 (2025 security enhancement)
export async function getSession(
  db: D1Database,
  sessionId: string,
  sessionSecret: string
): Promise<Session | null> {
  // Try to get session by encrypted data first (new format)
  let session = await db.prepare(
    `SELECT encrypted_data, encrypted_iv, encrypted_salt 
     FROM sessions 
     WHERE id = ? AND expires_at > datetime('now')`
  ).bind(sessionId).first();
  
  // If encrypted data exists, decrypt it
  if (session && session.encrypted_data) {
    try {
      const decrypted = await decryptSession(
        {
          ciphertext: session.encrypted_data as string,
          iv: session.encrypted_iv as string,
          salt: session.encrypted_salt as string
        },
        sessionSecret
      );
      
      const sessionData: EncryptedSessionData = JSON.parse(decrypted);
      return {
        userId: sessionData.userId,
        username: sessionData.username,
        createdAt: sessionData.createdAt
      };
    } catch (error) {
      console.error('Failed to decrypt session:', error);
      return null;
    }
  }
  
  // Fallback to old format for backward compatibility
  session = await db.prepare(
    `SELECT user_id, username, created_at 
     FROM sessions 
     WHERE id = ? AND expires_at > datetime('now')`
  ).bind(sessionId).first();
  
  if (!session || !session.user_id) return null;
  
  return {
    userId: session.user_id as number,
    username: session.username as string,
    createdAt: new Date(session.created_at as string).getTime()
  };
}

// Delete session from D1
export async function deleteSession(
  db: D1Database,
  sessionId: string
): Promise<void> {
  await db.prepare('DELETE FROM sessions WHERE id = ?')
    .bind(sessionId)
    .run();
}

// Clean up expired sessions (call periodically)
export async function cleanupSessions(db: D1Database): Promise<void> {
  await db.prepare(
    `DELETE FROM sessions WHERE expires_at <= datetime('now')`
  ).run();
}

// Get user from request with encrypted session support
export async function getUserFromRequest(c: Context): Promise<Session | null> {
  const sessionId = c.req.header('X-Session-Id') || 
                   getCookie(c, 'session_id');
  
  if (!sessionId) return null;
  
  // Access D1 and session secret from context
  const db = c.env.DB as D1Database;
  const sessionSecret = c.env.SESSION_SECRET || c.env.GITHUB_CLIENT_SECRET; // Fallback for now
  
  return getSession(db, sessionId, sessionSecret);
}

// Create GitHub OAuth client
export function createGitHubClient(
  clientId: string, 
  clientSecret: string,
  redirectUri?: string
): GitHub {
  // GitHub requires redirect URI if multiple are configured
  // Pass null if not provided to use the default
  return new GitHub(clientId, clientSecret, redirectUri || null);
}

// Generate authorization URL
export function getGitHubAuthUrl(
  github: GitHub, 
  state: string
): string {
  // Arctic handles redirect_uri internally when the GitHub client is created
  const url = github.createAuthorizationURL(state, {
    scopes: ["read:user", "user:email"]
  });
  
  return url.toString();
}

// Exchange code for tokens
export async function exchangeGitHubCode(
  github: GitHub,
  code: string
): Promise<{ accessToken: string }> {
  try {
    const tokens = await github.validateAuthorizationCode(code);
    // Arctic returns OAuth2Tokens object - accessToken() is a method!
    const accessToken = tokens.accessToken();
    return { accessToken };
  } catch (error) {
    console.error('GitHub token exchange failed:', error);
    throw error;
  }
}

// Get GitHub user
export async function getGitHubUser(accessToken: string): Promise<any> {
  const response = await fetch('https://api.github.com/user', {
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Accept': 'application/json',
      'User-Agent': 'Clodonic-OAuth'
    }
  });
  
  if (!response.ok) {
    throw new Error(`GitHub API error: ${response.status}`);
  }
  
  return response.json();
}