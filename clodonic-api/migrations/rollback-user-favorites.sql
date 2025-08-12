-- Rollback Migration: Remove user_favorites table
-- Created: 2025-08-12
-- Description: Rollback script to remove user_favorites table and its indexes

-- DOWN Migration
-- Drop indexes first
DROP INDEX IF EXISTS idx_user_favorites_user_id;
DROP INDEX IF EXISTS idx_user_favorites_item_id;
DROP INDEX IF EXISTS idx_user_favorites_created_at;

-- Drop the table
DROP TABLE IF EXISTS user_favorites;

-- Note: This is a destructive operation that will lose all favorite data
-- Ensure data is backed up before running this rollback