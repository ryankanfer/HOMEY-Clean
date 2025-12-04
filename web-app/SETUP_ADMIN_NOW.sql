-- ========================================
-- ADMIN SETUP FOR RYAN@HOMEYPOCKET.AI
-- Run this in Supabase SQL Editor
-- ========================================

-- Step 1: Ensure is_admin column exists
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;

-- Step 2: Set ryan@homeypocket.ai as admin
UPDATE profiles
SET is_admin = TRUE
WHERE email = 'ryan@homeypocket.ai';

-- Step 3: Create trigger function to auto-set admin on signup
CREATE OR REPLACE FUNCTION set_admin_on_signup()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.email = 'ryan@homeypocket.ai' THEN
    NEW.is_admin = TRUE;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 4: Create trigger
DROP TRIGGER IF EXISTS trigger_set_admin_on_signup ON profiles;
CREATE TRIGGER trigger_set_admin_on_signup
  BEFORE INSERT ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION set_admin_on_signup();

-- Step 5: Create index for fast admin lookups
CREATE INDEX IF NOT EXISTS idx_profiles_is_admin
ON profiles(is_admin)
WHERE is_admin = TRUE;

-- Step 6: Verify it worked
SELECT
  id,
  email,
  full_name,
  is_admin,
  created_at
FROM profiles
WHERE email = 'ryan@homeypocket.ai';

-- You should see is_admin = true in the results!
