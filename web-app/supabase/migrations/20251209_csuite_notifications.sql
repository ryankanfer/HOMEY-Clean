-- C-Suite Integration: Notifications Table
-- This table stores notifications from the HOMEY app to c-suite agents

CREATE TABLE IF NOT EXISTS csuite_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Agent Info
  agent_id TEXT NOT NULL, -- References c-suite agent ID (e.g., 'tech-cody', 'pm-bridget')

  -- Notification Content
  title TEXT NOT NULL,
  context_type TEXT NOT NULL CHECK (context_type IN ('code', 'feedback', 'database')),
  context_content TEXT NOT NULL,
  context_metadata JSONB DEFAULT '{}'::jsonb,

  -- Priority & Status
  priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_csuite_notifications_agent_id ON csuite_notifications(agent_id);
CREATE INDEX IF NOT EXISTS idx_csuite_notifications_read ON csuite_notifications(read);
CREATE INDEX IF NOT EXISTS idx_csuite_notifications_created_at ON csuite_notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_csuite_notifications_priority ON csuite_notifications(priority);

-- Composite index for common query pattern (agent + unread)
CREATE INDEX IF NOT EXISTS idx_csuite_notifications_agent_unread
  ON csuite_notifications(agent_id, read, created_at DESC);

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_csuite_notifications_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER csuite_notifications_updated_at
  BEFORE UPDATE ON csuite_notifications
  FOR EACH ROW
  EXECUTE FUNCTION update_csuite_notifications_updated_at();

-- RLS Policies (if needed - depends on your security model)
-- For now, we'll allow service role access only
ALTER TABLE csuite_notifications ENABLE ROW LEVEL SECURITY;

-- Allow service role to do everything
CREATE POLICY "Service role has full access to csuite_notifications"
  ON csuite_notifications
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Optional: Allow admins to view notifications
CREATE POLICY "Admins can view csuite_notifications"
  ON csuite_notifications
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid()
      AND profiles.is_admin = true
    )
  );

-- Comment
COMMENT ON TABLE csuite_notifications IS 'Stores notifications from HOMEY app to c-suite AI agents';
COMMENT ON COLUMN csuite_notifications.agent_id IS 'C-Suite agent identifier (e.g., tech-cody, pm-bridget, the-boardroom)';
COMMENT ON COLUMN csuite_notifications.context_type IS 'Type of context: code, feedback, or database';
COMMENT ON COLUMN csuite_notifications.context_content IS 'Formatted content for the agent';
COMMENT ON COLUMN csuite_notifications.context_metadata IS 'Additional metadata about the notification';
