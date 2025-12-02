-- Allow anyone to read agent profiles (needed for invitation acceptance page)
-- This is safe because agent profiles are public-facing information

-- Enable RLS on agent_profiles if not already enabled
ALTER TABLE agent_profiles ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read agent profiles
CREATE POLICY "Anyone can read agent profiles"
ON agent_profiles
FOR SELECT
TO anon, authenticated
USING (true);

-- Enable RLS on profiles if not already enabled
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read profiles (basic public info)
CREATE POLICY "Anyone can read profiles"
ON profiles
FOR SELECT
TO anon, authenticated
USING (true);

-- Allow authenticated users to update their own profile
CREATE POLICY "Users can update their own profile"
ON profiles
FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Allow authenticated users to insert their own profile
CREATE POLICY "Users can insert their own profile"
ON profiles
FOR INSERT
TO authenticated
WITH CHECK (id = auth.uid());
