-- User Profiles Table
-- Stores AI-learned insights from document extraction
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Financial Profile (from bank statements, paystubs, pre-approvals)
  monthly_income DECIMAL(12, 2),
  max_budget DECIMAL(12, 2),
  pre_approval_amount DECIMAL(12, 2),
  loan_type TEXT,

  -- Housing Preferences (from leases, swipes, searches)
  budget_min DECIMAL(12, 2),
  budget_max DECIMAL(12, 2),
  preferred_neighborhoods TEXT[], -- Array of neighborhood names
  min_bedrooms INTEGER,
  min_bathrooms DECIMAL(3, 1),
  pet_friendly BOOLEAN,
  smoking_policy TEXT,
  move_in_date DATE,

  -- Current Lease Info
  current_lease_address TEXT,
  current_lease_end_date DATE,
  current_monthly_rent DECIMAL(12, 2),

  -- AI-Derived Insights
  financial_capacity TEXT CHECK (financial_capacity IN ('low', 'medium', 'high')),
  urgency TEXT CHECK (urgency IN ('low', 'medium', 'high')),
  ready_to_buy BOOLEAN DEFAULT false,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Ensure one profile per user
  UNIQUE(user_id)
);

-- Enable RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can read own profile"
  ON user_profiles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
  ON user_profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
  ON user_profiles
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_user_profile_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_user_profile_updated_at();

-- Create index for faster lookups
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);

COMMENT ON TABLE user_profiles IS 'AI-learned user profiles from document extraction and app usage';
