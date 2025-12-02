-- =====================================================
-- Allow Agents to Read Their Clients' Profiles
-- =====================================================
-- This policy allows agents to read the profiles of users
-- they have active connections with
-- =====================================================

-- Add policy to allow agents to read their clients' profiles
CREATE POLICY "Agents can read their clients' profiles"
ON profiles
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM agent_client_connections acc
    INNER JOIN agent_profiles ap ON ap.id = acc.agent_id
    WHERE acc.client_id = profiles.id
    AND ap.user_id = auth.uid()
    AND acc.status = 'active'
  )
);

-- =====================================================
-- VERIFICATION
-- =====================================================
-- After running this, verify the policy was created:
--
-- SELECT policyname, permissive, roles, cmd, qual
-- FROM pg_policies
-- WHERE tablename = 'profiles'
-- AND policyname = 'Agents can read their clients'' profiles';
--
-- Test by logging in as an agent and querying:
-- SELECT * FROM profiles WHERE id IN (
--   SELECT client_id FROM agent_client_connections
--   WHERE agent_id = (SELECT id FROM agent_profiles WHERE user_id = auth.uid())
--   AND status = 'active'
-- );
-- =====================================================
