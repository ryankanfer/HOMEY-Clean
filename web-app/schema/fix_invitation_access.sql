-- Allow unauthenticated users to read pending invitations
-- This is needed so they can view the invitation page before signing up/logging in

-- First, enable RLS on agent_client_connections if not already enabled
ALTER TABLE agent_client_connections ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read pending invitations (needed for the invitation acceptance page)
CREATE POLICY "Anyone can read pending invitations"
ON agent_client_connections
FOR SELECT
TO anon, authenticated
USING (status = 'pending');

-- Allow authenticated users to update their own pending invitations (when accepting)
CREATE POLICY "Users can accept their own invitations"
ON agent_client_connections
FOR UPDATE
TO authenticated
USING (invited_email = auth.jwt() ->> 'email' AND status = 'pending')
WITH CHECK (status = 'active');

-- Allow agents to insert new invitations
CREATE POLICY "Agents can create invitations"
ON agent_client_connections
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM agent_profiles
    WHERE agent_profiles.id = agent_client_connections.agent_id
    AND agent_profiles.user_id = auth.uid()
  )
);

-- Allow agents to read their own connections
CREATE POLICY "Agents can read their own connections"
ON agent_client_connections
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM agent_profiles
    WHERE agent_profiles.id = agent_client_connections.agent_id
    AND agent_profiles.user_id = auth.uid()
  )
);

-- Allow clients to read their own connections
CREATE POLICY "Clients can read their own connections"
ON agent_client_connections
FOR SELECT
TO authenticated
USING (client_id = auth.uid());
