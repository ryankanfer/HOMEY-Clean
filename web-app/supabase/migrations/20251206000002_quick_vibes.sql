-- Quick Vibes: Real-time "what's happening now" updates
-- These are ephemeral posts that expire after 24 hours

CREATE TABLE IF NOT EXISTS quick_vibes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  neighborhood VARCHAR(255) NOT NULL,
  text TEXT NOT NULL,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '24 hours')
);

-- Index for efficient querying of non-expired vibes
CREATE INDEX IF NOT EXISTS idx_quick_vibes_expires_at ON quick_vibes(expires_at);
CREATE INDEX IF NOT EXISTS idx_quick_vibes_created_at ON quick_vibes(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_quick_vibes_neighborhood ON quick_vibes(neighborhood);

-- RLS Policies
ALTER TABLE quick_vibes ENABLE ROW LEVEL SECURITY;

-- Anyone can view non-expired quick vibes
CREATE POLICY "Quick vibes are viewable by everyone"
  ON quick_vibes FOR SELECT
  USING (expires_at > NOW());

-- Users can insert their own quick vibes
CREATE POLICY "Users can create quick vibes"
  ON quick_vibes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own quick vibes
CREATE POLICY "Users can delete their own quick vibes"
  ON quick_vibes FOR DELETE
  USING (auth.uid() = user_id);

-- Function to automatically clean up expired quick vibes (optional, can be run via cron)
CREATE OR REPLACE FUNCTION delete_expired_quick_vibes()
RETURNS void AS $$
BEGIN
  DELETE FROM quick_vibes WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql;
