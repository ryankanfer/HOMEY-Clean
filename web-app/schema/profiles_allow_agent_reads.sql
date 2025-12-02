-- ========================================
-- Allow clients to read their connected agent's profile
-- ========================================

-- This allows clients to see their agent's name and info
CREATE POLICY "Clients can read connected agents profiles"
ON profiles
FOR SELECT
TO authenticated
USING (
  -- Allow if this profile belongs to an agent connected to the current user
  id IN (
    SELECT ap.user_id
    FROM agent_profiles ap
    INNER JOIN agent_client_connections acc ON acc.agent_id = ap.id
    WHERE acc.client_id = auth.uid()
    AND acc.status = 'active'
  )
);

-- Also allow agents to read their clients' profiles
CREATE POLICY "Agents can read connected clients profiles"
ON profiles
FOR SELECT
TO authenticated
USING (
  -- Allow if this profile belongs to a client connected to the current user's agent profile
  id IN (
    SELECT acc.client_id
    FROM agent_client_connections acc
    INNER JOIN agent_profiles ap ON ap.id = acc.agent_id
    WHERE ap.user_id = auth.uid()
    AND acc.status = 'active'
  )
);
