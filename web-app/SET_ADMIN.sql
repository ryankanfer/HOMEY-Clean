-- Quick command to set ryan@homeypocket.ai as admin
-- Run this in Supabase SQL Editor RIGHT NOW

-- First, add the is_admin column if it doesn't exist
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;

-- Set ryan@homeypocket.ai as admin
UPDATE profiles
SET is_admin = TRUE
WHERE email = 'ryan@homeypocket.ai';

-- Verify it worked
SELECT id, email, full_name, is_admin
FROM profiles
WHERE email = 'ryan@homeypocket.ai';
