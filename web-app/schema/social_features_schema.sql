-- =============================================
-- SOCIAL FEATURES SCHEMA
-- Property sharing and friend connections
-- =============================================

-- Property Shares Table
CREATE TABLE IF NOT EXISTS property_shares (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  recipient_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  listing_id UUID NOT NULL,
  message TEXT,
  viewed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_property_shares_sender ON property_shares(sender_id);
CREATE INDEX idx_property_shares_recipient ON property_shares(recipient_id);
CREATE INDEX idx_property_shares_listing ON property_shares(listing_id);
CREATE INDEX idx_property_shares_created ON property_shares(created_at DESC);

-- Enable RLS
ALTER TABLE property_shares ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view shares they sent"
ON property_shares
FOR SELECT
TO authenticated
USING (sender_id = auth.uid());

CREATE POLICY "Users can view shares they received"
ON property_shares
FOR SELECT
TO authenticated
USING (recipient_id = auth.uid());

CREATE POLICY "Users can send shares"
ON property_shares
FOR INSERT
TO authenticated
WITH CHECK (sender_id = auth.uid());

CREATE POLICY "Recipients can mark as viewed"
ON property_shares
FOR UPDATE
TO authenticated
USING (recipient_id = auth.uid())
WITH CHECK (recipient_id = auth.uid());

-- Friend Connections Table (simple version)
CREATE TABLE IF NOT EXISTS friend_connections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  friend_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT CHECK (status IN ('pending', 'accepted', 'blocked')) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, friend_id)
);

-- Indexes
CREATE INDEX idx_friend_connections_user ON friend_connections(user_id);
CREATE INDEX idx_friend_connections_friend ON friend_connections(friend_id);
CREATE INDEX idx_friend_connections_status ON friend_connections(status);

-- Enable RLS
ALTER TABLE friend_connections ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their friend connections"
ON friend_connections
FOR SELECT
TO authenticated
USING (user_id = auth.uid() OR friend_id = auth.uid());

CREATE POLICY "Users can create friend connections"
ON friend_connections
FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their friend connections"
ON friend_connections
FOR UPDATE
TO authenticated
USING (user_id = auth.uid() OR friend_id = auth.uid())
WITH CHECK (user_id = auth.uid() OR friend_id = auth.uid());

-- Function to get mutual loves between users
CREATE OR REPLACE FUNCTION get_mutual_loves(user1_id UUID, user2_id UUID)
RETURNS INTEGER AS $$
DECLARE
  mutual_count INTEGER;
BEGIN
  SELECT COUNT(DISTINCT us1.listing_id) INTO mutual_count
  FROM user_swipes us1
  INNER JOIN user_swipes us2 ON us1.listing_id = us2.listing_id
  WHERE us1.user_id = user1_id
    AND us2.user_id = user2_id
    AND us1.action = 'love'
    AND us2.action = 'love';

  RETURN COALESCE(mutual_count, 0);
END;
$$ LANGUAGE plpgsql;

-- Function to get friend activity (recent loves/likes)
CREATE OR REPLACE FUNCTION get_friend_activity(p_user_id UUID, p_limit INTEGER DEFAULT 20)
RETURNS TABLE (
  friend_id UUID,
  friend_name TEXT,
  friend_avatar TEXT,
  listing_id UUID,
  action TEXT,
  swipe_timestamp TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    fc.friend_id,
    p.full_name,
    p.avatar_url,
    us.listing_id,
    us.action,
    us.created_at
  FROM friend_connections fc
  INNER JOIN profiles p ON p.id = fc.friend_id
  INNER JOIN user_swipes us ON us.user_id = fc.friend_id
  WHERE fc.user_id = p_user_id
    AND fc.status = 'accepted'
    AND us.action IN ('like', 'love')
  ORDER BY us.created_at DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Verification queries
SELECT
  tablename,
  policyname,
  cmd
FROM pg_policies
WHERE tablename IN ('property_shares', 'friend_connections')
ORDER BY tablename, cmd, policyname;
