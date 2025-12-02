-- =============================================
-- MESSAGES SCHEMA - Agent-Client Messaging
-- =============================================
-- Run this in Supabase SQL Editor

-- Drop existing table if needed
DROP TABLE IF EXISTS messages CASCADE;

-- Messages table
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID REFERENCES agent_client_connections(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  sender_type TEXT CHECK (sender_type IN ('agent', 'client')),
  message TEXT NOT NULL,
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_messages_connection ON messages(connection_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_created ON messages(created_at DESC);
CREATE INDEX idx_messages_unread ON messages(read) WHERE read = false;

-- Enable RLS
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Users can view messages in their connections
CREATE POLICY "Users can view their messages"
ON messages
FOR SELECT
TO authenticated
USING (
  connection_id IN (
    SELECT id FROM agent_client_connections
    WHERE client_id = auth.uid()
    OR agent_id IN (
      SELECT id FROM agent_profiles WHERE user_id = auth.uid()
    )
  )
);

-- Users can send messages in their connections
CREATE POLICY "Users can send messages"
ON messages
FOR INSERT
TO authenticated
WITH CHECK (
  sender_id = auth.uid()
  AND connection_id IN (
    SELECT id FROM agent_client_connections
    WHERE client_id = auth.uid()
    OR agent_id IN (
      SELECT id FROM agent_profiles WHERE user_id = auth.uid()
    )
  )
);

-- Users can mark their received messages as read
CREATE POLICY "Users can update message read status"
ON messages
FOR UPDATE
TO authenticated
USING (
  connection_id IN (
    SELECT id FROM agent_client_connections
    WHERE client_id = auth.uid()
    OR agent_id IN (
      SELECT id FROM agent_profiles WHERE user_id = auth.uid()
    )
  )
)
WITH CHECK (
  connection_id IN (
    SELECT id FROM agent_client_connections
    WHERE client_id = auth.uid()
    OR agent_id IN (
      SELECT id FROM agent_profiles WHERE user_id = auth.uid()
    )
  )
);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_messages_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at
CREATE TRIGGER messages_updated_at
BEFORE UPDATE ON messages
FOR EACH ROW
EXECUTE FUNCTION update_messages_updated_at();

-- Verification query
SELECT
  tablename,
  policyname,
  cmd
FROM pg_policies
WHERE tablename = 'messages'
ORDER BY cmd, policyname;
