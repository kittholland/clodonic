/**
 * Session encryption utilities using Web Crypto API
 * Implements AES-256-GCM encryption for session data (2025 best practice)
 */

export interface EncryptedData {
  ciphertext: string;
  iv: string;
  salt: string;
}

/**
 * Derive an AES-GCM key from a password using PBKDF2
 * @param password - The password to derive from
 * @param salt - Salt for key derivation
 */
async function deriveKey(password: string, salt: Uint8Array): Promise<CryptoKey> {
  const encoder = new TextEncoder();
  const keyMaterial = await crypto.subtle.importKey(
    'raw',
    encoder.encode(password),
    'PBKDF2',
    false,
    ['deriveBits', 'deriveKey']
  );

  return crypto.subtle.deriveKey(
    {
      name: 'PBKDF2',
      salt,
      iterations: 100000, // 2025 recommended iteration count
      hash: 'SHA-256'
    },
    keyMaterial,
    { name: 'AES-GCM', length: 256 },
    false,
    ['encrypt', 'decrypt']
  );
}

/**
 * Encrypt session data using AES-256-GCM
 * @param data - The data to encrypt
 * @param password - The encryption password (should be from env.SESSION_SECRET)
 */
export async function encryptSession(data: string, password: string): Promise<EncryptedData> {
  const encoder = new TextEncoder();
  
  // Generate random salt and IV for this encryption
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const iv = crypto.getRandomValues(new Uint8Array(12)); // 96-bit IV for GCM
  
  // Derive key from password
  const key = await deriveKey(password, salt);
  
  // Encrypt the data
  const encrypted = await crypto.subtle.encrypt(
    {
      name: 'AES-GCM',
      iv
    },
    key,
    encoder.encode(data)
  );
  
  // Return base64-encoded values for storage
  return {
    ciphertext: btoa(String.fromCharCode(...new Uint8Array(encrypted))),
    iv: btoa(String.fromCharCode(...iv)),
    salt: btoa(String.fromCharCode(...salt))
  };
}

/**
 * Decrypt session data using AES-256-GCM
 * @param encryptedData - The encrypted data object
 * @param password - The decryption password (should be from env.SESSION_SECRET)
 */
export async function decryptSession(encryptedData: EncryptedData, password: string): Promise<string> {
  const decoder = new TextDecoder();
  
  // Decode base64 values
  const ciphertext = Uint8Array.from(atob(encryptedData.ciphertext), c => c.charCodeAt(0));
  const iv = Uint8Array.from(atob(encryptedData.iv), c => c.charCodeAt(0));
  const salt = Uint8Array.from(atob(encryptedData.salt), c => c.charCodeAt(0));
  
  // Derive key from password
  const key = await deriveKey(password, salt);
  
  // Decrypt the data
  const decrypted = await crypto.subtle.decrypt(
    {
      name: 'AES-GCM',
      iv
    },
    key,
    ciphertext
  );
  
  return decoder.decode(decrypted);
}

/**
 * Generate a secure session ID
 */
export function generateSessionId(): string {
  const bytes = crypto.getRandomValues(new Uint8Array(32));
  return btoa(String.fromCharCode(...bytes))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
}

/**
 * Hash a value using SHA-256 (for session lookups)
 */
export async function hashValue(value: string): Promise<string> {
  const encoder = new TextEncoder();
  const hash = await crypto.subtle.digest('SHA-256', encoder.encode(value));
  return btoa(String.fromCharCode(...new Uint8Array(hash)))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
}