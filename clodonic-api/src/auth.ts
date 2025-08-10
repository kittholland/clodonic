import { Context } from 'hono';
import { getCookie } from 'hono/cookie';

export interface User {
  id: number;
  provider_id: string;
  username: string;
  email?: string;
  auth_provider: string;
}

export interface Session {
  userId: number;
  username: string;
  createdAt: number;
}

// Simple session store (in production, use KV or D1)
const sessions = new Map<string, Session>();

export function generateSessionId(): string {
  return crypto.randomUUID();
}

export function createSession(userId: number, username: string): string {
  const sessionId = generateSessionId();
  sessions.set(sessionId, {
    userId,
    username,
    createdAt: Date.now()
  });
  return sessionId;
}

export function getSession(sessionId: string): Session | null {
  const session = sessions.get(sessionId);
  if (!session) return null;
  
  // Check if session is expired (24 hours)
  if (Date.now() - session.createdAt > 24 * 60 * 60 * 1000) {
    sessions.delete(sessionId);
    return null;
  }
  
  return session;
}

export function deleteSession(sessionId: string): void {
  sessions.delete(sessionId);
}

export function getUserFromRequest(c: Context): Session | null {
  const sessionId = c.req.header('X-Session-Id') || 
                   getCookie(c, 'session_id');
  
  if (!sessionId) return null;
  return getSession(sessionId);
}

// GitHub OAuth configuration
export function getGitHubAuthUrl(state: string, clientId: string, redirectUri: string): string {
  const params = new URLSearchParams({
    client_id: clientId,
    redirect_uri: redirectUri,
    scope: 'read:user user:email',
    state
  });
  
  return `https://github.com/login/oauth/authorize?${params}`;
}

export async function exchangeGitHubCode(
  code: string, 
  clientId: string, 
  clientSecret: string
): Promise<string> {
  const response = await fetch('https://github.com/login/oauth/access_token', {
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      client_id: clientId,
      client_secret: clientSecret,
      code
    })
  });
  
  const data = await response.json();
  return data.access_token;
}

export async function getGitHubUser(accessToken: string): Promise<any> {
  const response = await fetch('https://api.github.com/user', {
    headers: {
      'Authorization': `token ${accessToken}`,
      'Accept': 'application/json'
    }
  });
  
  return response.json();
}