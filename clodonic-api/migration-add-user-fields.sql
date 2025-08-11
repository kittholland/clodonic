-- Add avatar_url and display_name to users table
ALTER TABLE users ADD COLUMN avatar_url TEXT;
ALTER TABLE users ADD COLUMN display_name TEXT;
EOF < /dev/null