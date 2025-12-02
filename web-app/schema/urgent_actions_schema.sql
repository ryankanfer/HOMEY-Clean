-- Urgent Actions Tracking Table
-- This table tracks time-sensitive actions that need user attention

CREATE TABLE IF NOT EXISTS urgent_actions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Action details
  action_type VARCHAR(50) NOT NULL CHECK (action_type IN (
    'sign_disclosure',
    'sign_lease',
    'submit_application',
    'confirm_tour',
    'payment_due',
    'deadline_approaching'
  )),
  title VARCHAR(200) NOT NULL,
  description TEXT,
  action_text VARCHAR(100) NOT NULL, -- e.g., "Sign Now", "Confirm", "Pay Now"

  -- Priority and status
  priority VARCHAR(20) NOT NULL CHECK (priority IN ('critical', 'urgent', 'high')),
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'dismissed', 'expired')),

  -- Routing
  href VARCHAR(500) NOT NULL, -- Where to navigate when clicked

  -- Related entity IDs (nullable, depending on action type)
  related_listing_id UUID REFERENCES listings(id) ON DELETE CASCADE,
  related_document_id UUID, -- For vault documents
  related_tour_id UUID, -- For calendar tours

  -- Timing
  deadline TIMESTAMPTZ, -- When this action must be completed by
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  dismissed_at TIMESTAMPTZ,

  -- Constraints
  UNIQUE(user_id, action_type, related_listing_id, related_document_id) -- Prevent duplicate urgent actions
);

-- Indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_urgent_actions_user_id ON urgent_actions(user_id);
CREATE INDEX IF NOT EXISTS idx_urgent_actions_status ON urgent_actions(status);
CREATE INDEX IF NOT EXISTS idx_urgent_actions_priority ON urgent_actions(priority);
CREATE INDEX IF NOT EXISTS idx_urgent_actions_deadline ON urgent_actions(deadline);
CREATE INDEX IF NOT EXISTS idx_urgent_actions_created_at ON urgent_actions(created_at);

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_urgent_actions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at
DROP TRIGGER IF EXISTS trigger_urgent_actions_updated_at ON urgent_actions;
CREATE TRIGGER trigger_urgent_actions_updated_at
  BEFORE UPDATE ON urgent_actions
  FOR EACH ROW
  EXECUTE FUNCTION update_urgent_actions_updated_at();

-- Function to automatically expire old urgent actions
CREATE OR REPLACE FUNCTION expire_old_urgent_actions()
RETURNS void AS $$
BEGIN
  UPDATE urgent_actions
  SET status = 'expired'
  WHERE status = 'pending'
    AND deadline IS NOT NULL
    AND deadline < NOW();
END;
$$ LANGUAGE plpgsql;

-- Function to get highest priority urgent action for a user
CREATE OR REPLACE FUNCTION get_top_urgent_action(p_user_id UUID)
RETURNS TABLE (
  id UUID,
  action_type VARCHAR(50),
  title VARCHAR(200),
  description TEXT,
  action_text VARCHAR(100),
  priority VARCHAR(20),
  href VARCHAR(500),
  deadline TIMESTAMPTZ
) AS $$
BEGIN
  -- First, expire any old actions
  PERFORM expire_old_urgent_actions();

  -- Return highest priority pending action
  RETURN QUERY
  SELECT
    ua.id,
    ua.action_type,
    ua.title,
    ua.description,
    ua.action_text,
    ua.priority,
    ua.href,
    ua.deadline
  FROM urgent_actions ua
  WHERE ua.user_id = p_user_id
    AND ua.status = 'pending'
    AND (ua.deadline IS NULL OR ua.deadline > NOW())
  ORDER BY
    CASE ua.priority
      WHEN 'critical' THEN 1
      WHEN 'urgent' THEN 2
      WHEN 'high' THEN 3
    END,
    ua.created_at ASC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Function to mark urgent action as completed
CREATE OR REPLACE FUNCTION complete_urgent_action(p_action_id UUID, p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  rows_updated INTEGER;
BEGIN
  UPDATE urgent_actions
  SET
    status = 'completed',
    completed_at = NOW()
  WHERE id = p_action_id
    AND user_id = p_user_id
    AND status = 'pending';

  GET DIAGNOSTICS rows_updated = ROW_COUNT;
  RETURN rows_updated > 0;
END;
$$ LANGUAGE plpgsql;

-- Function to dismiss urgent action
CREATE OR REPLACE FUNCTION dismiss_urgent_action(p_action_id UUID, p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  rows_updated INTEGER;
BEGIN
  UPDATE urgent_actions
  SET
    status = 'dismissed',
    dismissed_at = NOW()
  WHERE id = p_action_id
    AND user_id = p_user_id
    AND status = 'pending';

  GET DIAGNOSTICS rows_updated = ROW_COUNT;
  RETURN rows_updated > 0;
END;
$$ LANGUAGE plpgsql;

-- Enable RLS
ALTER TABLE urgent_actions ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own urgent actions"
  ON urgent_actions FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own urgent actions"
  ON urgent_actions FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own urgent actions"
  ON urgent_actions FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own urgent actions"
  ON urgent_actions FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON urgent_actions TO authenticated;
GRANT EXECUTE ON FUNCTION get_top_urgent_action(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION complete_urgent_action(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION dismiss_urgent_action(UUID, UUID) TO authenticated;
