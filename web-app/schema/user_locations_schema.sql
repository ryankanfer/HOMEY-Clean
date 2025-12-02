-- User Saved Locations Table
-- Stores user's important locations for commute calculations

CREATE TABLE IF NOT EXISTS user_locations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('work', 'gym', 'favorite', 'school', 'custom')),
  address TEXT NOT NULL,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  icon TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_locations_user_id ON user_locations(user_id);
CREATE INDEX IF NOT EXISTS idx_user_locations_type ON user_locations(type);

-- RLS Policies
ALTER TABLE user_locations ENABLE ROW LEVEL SECURITY;

-- Users can view their own locations
CREATE POLICY "Users can view own locations"
  ON user_locations
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Users can insert their own locations
CREATE POLICY "Users can insert own locations"
  ON user_locations
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own locations
CREATE POLICY "Users can update own locations"
  ON user_locations
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own locations
CREATE POLICY "Users can delete own locations"
  ON user_locations
  FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_user_locations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_locations_updated_at
  BEFORE UPDATE ON user_locations
  FOR EACH ROW
  EXECUTE FUNCTION update_user_locations_updated_at();
