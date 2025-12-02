-- ========================================
-- RLS Policies for agent_client_connections
-- ========================================
-- This fixes the invitation acceptance flow

-- Drop existing problematic policies
DROP POLICY IF EXISTS "Users can accept their own invitations" ON agent_client_connections;
DROP POLICY IF EXISTS "Clients can accept their own invitations" ON agent_client_connections;

-- ========================================
-- SELECT policies
-- ========================================

-- Allow agents to view their own connections
CREATE POLICY "Agents can view their connections"
ON agent_client_connections
FOR SELECT
TO authenticated
USING (
  agent_id IN (
    SELECT id FROM agent_profiles WHERE user_id = auth.uid()
  )
);

-- Allow clients to view their own connections
CREATE POLICY "Clients can view their connections"
ON agent_client_connections
FOR SELECT
TO authenticated
USING (client_id = auth.uid());

-- Allow users to view invitations sent to their email (even if not yet connected)
CREATE POLICY "Users can view invitations sent to their email"
ON agent_client_connections
FOR SELECT
TO authenticated
USING (
  invited_email IS NOT NULL
  AND invited_email = (SELECT email FROM auth.users WHERE id = auth.uid())
);

-- ========================================
-- UPDATE policies
-- ========================================

-- Allow users to accept invitations sent to their email
-- This is the critical policy for invitation acceptance
CREATE POLICY "Users can accept invitations sent to their email"
ON agent_client_connections
FOR UPDATE
TO authenticated
USING (
  -- User can update if invitation was sent to their email
  status = 'pending'
  AND invited_email IS NOT NULL
  AND invited_email = (SELECT email FROM auth.users WHERE id = auth.uid())
)
WITH CHECK (
  -- Only allow setting client_id to the current user and status to active
  client_id = auth.uid()
  AND status = 'active'
);

-- Allow agents to update their own connections (for notes, status changes, etc.)
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

-- ========================================
-- INSERT policies
-- ========================================

-- Allow agents to create new connections
CREATE POLICY "Agents can create connections"
ON agent_client_connections
FOR INSERT
TO authenticated
WITH CHECK (
  agent_id IN (
    SELECT id FROM agent_profiles WHERE user_id = auth.uid()
  )
);

-- ========================================
-- DELETE policies
-- ========================================

-- Allow agents to delete their own connections
CREATE POLICY "Agents can delete their connections"
ON agent_client_connections
FOR DELETE
TO authenticated
USING (
  agent_id IN (
    SELECT id FROM agent_profiles WHERE user_id = auth.uid()
  )
);

-- Allow clients to delete their own connections
CREATE POLICY "Clients can delete their connections"
ON agent_client_connections
FOR DELETE
TO authenticated
USING (client_id = auth.uid());
