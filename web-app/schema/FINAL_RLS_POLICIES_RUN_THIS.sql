-- ========================================
-- FINAL RLS POLICIES - RUN THIS IN SUPABASE
-- ========================================
-- This file contains ALL the RLS policies needed for agent-client connections
-- Run this entire file in Supabase SQL Editor

-- ========================================
-- 1. PROFILES TABLE POLICIES
-- ========================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own profile
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
CREATE POLICY "Users can read own profile"
ON profiles
FOR SELECT
TO authenticated
USING (id = auth.uid());

-- Allow clients to read their connected agent's profile
DROP POLICY IF EXISTS "Clients can read connected agents profiles" ON profiles;
CREATE POLICY "Clients can read connected agents profiles"
ON profiles
FOR SELECT
TO authenticated
USING (
  id IN (
    SELECT ap.user_id
    FROM agent_profiles ap
    INNER JOIN agent_client_connections acc ON acc.agent_id = ap.id
    WHERE acc.client_id = auth.uid()
    AND acc.status = 'active'
  )
);

-- Allow agents to read their clients' profiles
DROP POLICY IF EXISTS "Agents can read connected clients profiles" ON profiles;
CREATE POLICY "Agents can read connected clients profiles"
ON profiles
FOR SELECT
TO authenticated
USING (
  id IN (
    SELECT acc.client_id
    FROM agent_client_connections acc
    INNER JOIN agent_profiles ap ON ap.id = acc.agent_id
    WHERE ap.user_id = auth.uid()
    AND acc.status = 'active'
  )
);

-- Allow users to update their own profile
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile"
ON profiles
FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Allow users to insert their own profile (for signup)
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
CREATE POLICY "Users can insert own profile"
ON profiles
FOR INSERT
TO authenticated
WITH CHECK (id = auth.uid());

-- ========================================
-- 2. AGENT_CLIENT_CONNECTIONS TABLE POLICIES
-- ========================================

ALTER TABLE agent_client_connections ENABLE ROW LEVEL SECURITY;

-- SELECT policies
DROP POLICY IF EXISTS "Agents can view their connections" ON agent_client_connections;
CREATE POLICY "Agents can view their connections"
ON agent_client_connections
FOR SELECT
TO authenticated
USING (
  agent_id IN (
    SELECT id FROM agent_profiles WHERE user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Clients can view their connections" ON agent_client_connections;
CREATE POLICY "Clients can view their connections"
ON agent_client_connections
FOR SELECT
TO authenticated
USING (client_id = auth.uid());

DROP POLICY IF EXISTS "Users can view invitations sent to their email" ON agent_client_connections;
CREATE POLICY "Users can view invitations sent to their email"
ON agent_client_connections
FOR SELECT
TO authenticated
USING (
  invited_email IS NOT NULL
  AND invited_email = (SELECT email FROM profiles WHERE id = auth.uid())
);

-- UPDATE policies
DROP POLICY IF EXISTS "Allow updating pending invitations to active" ON agent_client_connections;
CREATE POLICY "Allow updating pending invitations to active"
ON agent_client_connections
FOR UPDATE
TO authenticated
USING (
  status = 'pending'
)
WITH CHECK (
  status = 'active'
  AND client_id = auth.uid()
);

DROP POLICY IF EXISTS "Agents can update their connections" ON agent_client_connections;
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
DROP POLICY IF EXISTS "Agents can create connections" ON agent_client_connections;
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
DROP POLICY IF EXISTS "Agents can delete their connections" ON agent_client_connections;
CREATE POLICY "Agents can delete their connections"
ON agent_client_connections
FOR DELETE
TO authenticated
USING (
  agent_id IN (
    SELECT id FROM agent_profiles WHERE user_id = auth.uid()
  )
);

DROP POLICY IF EXISTS "Clients can delete their connections" ON agent_client_connections;
CREATE POLICY "Clients can delete their connections"
ON agent_client_connections
FOR DELETE
TO authenticated
USING (client_id = auth.uid());

-- ========================================
-- VERIFICATION QUERIES
-- ========================================
-- Run these after to verify policies are created

-- Check profiles policies
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE tablename = 'profiles'
ORDER BY cmd, policyname;

-- Check agent_client_connections policies
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE tablename = 'agent_client_connections'
ORDER BY cmd, policyname;

-- ========================================
-- SUCCESS MESSAGE
-- ========================================
-- If you see policy lists above with no errors, you're all set!
-- Refresh your app and "Minerva McGonagall" should appear!
