-- The Pulse: Community vibe logs and neighborhood data
-- Migration: 20251206_pulse_tables.sql

-- Table: vibe_logs
-- Stores community posts/logs about neighborhoods
CREATE TABLE IF NOT EXISTS vibe_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  neighborhood VARCHAR(255) NOT NULL,
  text TEXT NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  tags TEXT[] DEFAULT '{}',
  likes INTEGER DEFAULT 0,
  liked_by UUID[] DEFAULT '{}', -- Array of user IDs who liked this log
  is_featured BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: neighborhood_pulse
-- Stores real-time neighborhood vibe data
CREATE TABLE IF NOT EXISTS neighborhood_pulse (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  neighborhood_id VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  image_url TEXT,
  vibe_score INTEGER DEFAULT 50 CHECK (vibe_score >= 0 AND vibe_score <= 100),
  current_mood VARCHAR(100),
  mood_emoji VARCHAR(10),
  trending_status VARCHAR(20) CHECK (trending_status IN ('Up', 'Down', 'Stable')),
  new_openings INTEGER DEFAULT 0,
  logs_today INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: vibe_playlists
-- Curated collections of vibe logs by theme
CREATE TABLE IF NOT EXISTS vibe_playlists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  emoji VARCHAR(10),
  tag_filter VARCHAR(100), -- Filter logs by this tag
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_vibe_logs_user ON vibe_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_vibe_logs_neighborhood ON vibe_logs(neighborhood);
CREATE INDEX IF NOT EXISTS idx_vibe_logs_created ON vibe_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_vibe_logs_tags ON vibe_logs USING GIN(tags);
CREATE INDEX IF NOT EXISTS idx_neighborhood_pulse_id ON neighborhood_pulse(neighborhood_id);

-- Row Level Security (RLS) Policies

-- vibe_logs: Anyone can read, only authenticated users can insert
ALTER TABLE vibe_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view vibe logs"
  ON vibe_logs FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can create vibe logs"
  ON vibe_logs FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own vibe logs"
  ON vibe_logs FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own vibe logs"
  ON vibe_logs FOR DELETE
  USING (auth.uid() = user_id);

-- neighborhood_pulse: Public read, admin write
ALTER TABLE neighborhood_pulse ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view neighborhood pulse"
  ON neighborhood_pulse FOR SELECT
  USING (true);

-- vibe_playlists: Public read
ALTER TABLE vibe_playlists ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view playlists"
  ON vibe_playlists FOR SELECT
  USING (true);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_vibe_logs_updated_at
  BEFORE UPDATE ON vibe_logs
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_neighborhood_pulse_updated_at
  BEFORE UPDATE ON neighborhood_pulse
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Insert default playlists
INSERT INTO vibe_playlists (name, emoji, tag_filter, description, display_order)
VALUES
  ('All Vibes', '🔁', NULL, 'See everything happening in your neighborhood', 0),
  ('Best Coffee Workspaces', '☕', 'Coffee', 'Great spots to work with caffeine', 1),
  ('Quiet Parks', '🌳', 'Quiet', 'Peaceful outdoor spaces', 2),
  ('Late-Night Walks', '🌙', 'Nightlife', 'Safe and scenic evening strolls', 3),
  ('Holiday Streets', '🎄', 'Holiday', 'Seasonal decorations and events', 4)
ON CONFLICT DO NOTHING;
