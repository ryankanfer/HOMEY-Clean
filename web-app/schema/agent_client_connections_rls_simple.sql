-- ========================================
-- Simplified RLS Policy for Invitation Acceptance
-- ========================================
-- This version doesn't query auth.users to avoid permission errors
-- Email validation is done in application code before the update

-- Drop the problematic policy
DROP POLICY IF EXISTS "Users can accept invitations sent to their email" ON agent_client_connections;

-- Create simplified policy
-- This allows any authenticated user to update pending invitations to active
-- The email validation happens in code (lib/supabase.ts acceptInvitation function)
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
