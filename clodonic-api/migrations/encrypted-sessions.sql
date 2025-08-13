-- Migration to add encrypted session columns
-- 2025-08-13: Enhanced security with AES-256-GCM encryption

-- Add new columns for encrypted session data
ALTER TABLE sessions ADD COLUMN hashed_id TEXT;
ALTER TABLE sessions ADD COLUMN encrypted_data TEXT;
ALTER TABLE sessions ADD COLUMN encrypted_iv TEXT;
ALTER TABLE sessions ADD COLUMN encrypted_salt TEXT;

-- Create index on hashed_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_sessions_hashed_id ON sessions(hashed_id);

-- Note: Existing sessions will continue to work with backward compatibility
-- New sessions will use encryption