-- Add warning tracking to items table
ALTER TABLE items ADD COLUMN warning_flags TEXT; -- JSON array of warning types
ALTER TABLE items ADD COLUMN has_warnings INTEGER DEFAULT 0; -- Boolean for quick filtering