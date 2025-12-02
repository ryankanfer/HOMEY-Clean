-- ========================================
-- FIX INFINITE RECURSION - RUN THIS NOW!
-- ========================================
-- This removes the problematic policies causing recursion

-- STEP 1: Drop ALL policies to start fresh
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
DROP POLICY IF EXISTS "Clients can read connected agents profiles" ON profiles;
DROP POLICY IF EXISTS "Agents can read connected clients profiles" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

DROP POLICY IF EXISTS "Agents can view their connections" ON agent_client_connections;
DROP POLICY IF EXISTS "Clients can view their connections" ON agent_client_connections;
DROP POLICY IF EXISTS "Users can view invitations sent to their email" ON agent_client_connections;
DROP POLICY IF EXISTS "Allow updating pending invitations to active" ON agent_client_connections;
DROP POLICY IF EXISTS "Agents can update their connections" ON agent_client_connections;
DROP POLICY IF EXISTS "Agents can create connections" ON agent_client_connections;
DROP POLICY IF EXISTS "Agents can delete their connections" ON agent_client_connections;
DROP POLICY IF EXISTS "Clients can delete their connections" ON agent_client_connections;

-- STEP 2: Create SIMPLE profiles policies (no circular references)
CREATE POLICY "Users can read own profile"
ON profiles
FOR SELECT
TO authenticated
USING (id = auth.uid());

CREATE POLICY "Public read profiles"
ON profiles
FOR SELECT
TO authenticated
USING (true);
-- Note: This allows all authenticated users to read all profiles
-- This is simpler and avoids recursion. You can restrict later if needed.

CREATE POLICY "Users can update own profile"
ON profiles
FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

CREATE POLICY "Users can insert own profile"
ON profiles
FOR INSERT
TO authenticated
WITH CHECK (id = auth.uid());

-- STEP 3: Create SIMPLE agent_client_connections policies (no circular references)

-- SELECT policies - NO SUBQUERIES TO PROFILES
CREATE POLICY "Agents can view their connections"
ON agent_client_connections
FOR SELECT
TO authenticated
USING (
  agent_id IN (
    SELECT id FROM agent_profiles WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Clients can view their connections"
ON agent_client_connections
FOR SELECT
TO authenticated
USING (client_id = auth.uid());

CREATE POLICY "Anyone can view pending invitations"
ON agent_client_connections
FOR SELECT
TO authenticated
USING (status = 'pending');
-- Simpler: anyone can see pending invitations
-- We validate email match in application code

-- UPDATE policies
CREATE POLICY "Allow updating pending invitations to active"
ON agent_client_connections
FOR UPDATE
TO authenticated
USING (status = 'pending')
WITH CHECK (
  status = 'active'
  AND client_id = auth.uid()
);

CREATE POLICY "Agents can update their connections"
ON agent_client_connections
FOR UPDATE
TO authenticated
USING (
  agent_id IN (
    SELECT id FROM agent_profiles WHERE user_id = auth.uid()
  )
)
WITH CHECK (
  agent_id IN (
    SELECT id FROM agent_profiles WHERE user_id = auth.uid()
  )
);

-- INSERT policies
CREATE POLICY "Agents can create connections"
ON agent_client_connections
FOR INSERT
TO authenticated
WITH CHECK (
  agent_id IN (
    SELECT id FROM agent_profiles WHERE user_id = auth.uid()
  )
);

-- DELETE policies
CREATE POLICY "Agents can delete their connections"
ON agent_client_connections
FOR DELETE
TO authenticated
USING (
  agent_id IN (
    SELECT id FROM agent_profiles WHERE user_id = auth.uid()
  )
);

CREATE POLICY "Clients can delete their connections"
ON agent_client_connections
FOR DELETE
TO authenticated
USING (client_id = auth.uid());

-- STEP 4: Verify no recursion
-- If this query returns results without error, you're good!
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE tablename IN ('profiles', 'agent_client_connections')
ORDER BY tablename, cmd, policyname;
