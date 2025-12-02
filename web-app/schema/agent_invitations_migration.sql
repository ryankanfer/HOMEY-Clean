-- =====================================================
-- Agent Invitations Migration
-- Adds support for pending invitations with email
-- =====================================================

-- Step 1: Add invited_email column for pending invitations
ALTER TABLE agent_client_connections
ADD COLUMN IF NOT EXISTS invited_email TEXT;

-- Step 2: Make client_id nullable to support pending invitations
ALTER TABLE agent_client_connections
ALTER COLUMN client_id DROP NOT NULL;

-- Step 3: Add a check constraint to ensure either client_id OR invited_email is set
ALTER TABLE agent_client_connections
ADD CONSTRAINT client_id_or_email_required
CHECK (
  (client_id IS NOT NULL) OR
  (invited_email IS NOT NULL AND status = 'pending')
);

-- Step 4: Update the unique constraint to handle both cases
ALTER TABLE agent_client_connections
DROP CONSTRAINT IF EXISTS agent_client_connections_agent_id_client_id_key;

-- Add a partial unique index for accepted connections (with client_id)
CREATE UNIQUE INDEX IF NOT EXISTS unique_agent_client_connection
ON agent_client_connections(agent_id, client_id)
WHERE client_id IS NOT NULL;

-- Add a partial unique index for pending invitations (with email)
CREATE UNIQUE INDEX IF NOT EXISTS unique_agent_client_invitation
ON agent_client_connections(agent_id, invited_email)
WHERE invited_email IS NOT NULL AND status = 'pending';

-- =====================================================
-- Migration Complete
-- Run this in Supabase SQL Editor
-- =====================================================
