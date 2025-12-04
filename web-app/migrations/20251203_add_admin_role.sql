-- Add admin role to profiles table
-- This allows ryan@homeypocket.ai to access both agent and client portals + dev tools

-- Add is_admin column
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;

-- Add comment
COMMENT ON COLUMN profiles.is_admin IS 'Super admin flag - grants access to all portals and dev tools';

-- Set ryan@homeypocket.ai as admin
-- This will work once the user signs up
UPDATE profiles
SET is_admin = TRUE
WHERE email = 'ryan@homeypocket.ai';

-- Create a function to automatically set admin status on signup for this email
CREATE OR REPLACE FUNCTION set_admin_on_signup()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if the new user is the admin email
  IF NEW.email = 'ryan@homeypocket.ai' THEN
    NEW.is_admin = TRUE;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to run on profile creation
DROP TRIGGER IF EXISTS trigger_set_admin_on_signup ON profiles;
CREATE TRIGGER trigger_set_admin_on_signup
  BEFORE INSERT ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION set_admin_on_signup();

-- Also create an index for faster admin checks
CREATE INDEX IF NOT EXISTS idx_profiles_is_admin ON profiles(is_admin) WHERE is_admin = TRUE;
