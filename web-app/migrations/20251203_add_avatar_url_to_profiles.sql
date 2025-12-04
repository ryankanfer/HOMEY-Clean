-- Add avatar_url column to profiles table
-- This stores user-uploaded avatar images or AI-generated avatar URLs

ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- Add comment to document the column
COMMENT ON COLUMN profiles.avatar_url IS 'URL to user avatar image (uploaded or AI-generated)';

-- Optional: Create index for faster lookups if needed
-- CREATE INDEX IF NOT EXISTS idx_profiles_avatar_url ON profiles(avatar_url) WHERE avatar_url IS NOT NULL;
