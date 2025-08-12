-- Migration: Add user_favorites table
-- Created: 2025-08-12
-- Description: Adds table to track which patterns users have favorited

-- UP Migration
CREATE TABLE IF NOT EXISTS user_favorites (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    item_id INTEGER NOT NULL,
    created_at TEXT DEFAULT (datetime('now')),
    
    -- Foreign key constraints
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE,
    
    -- Unique constraint to prevent duplicate favorites
    UNIQUE(user_id, item_id)
);

-- Create indexes for performance
CREATE INDEX idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX idx_user_favorites_item_id ON user_favorites(item_id);
CREATE INDEX idx_user_favorites_created_at ON user_favorites(created_at);

-- Add comment for documentation
-- This table tracks user favorites with CASCADE delete to maintain referential integrity