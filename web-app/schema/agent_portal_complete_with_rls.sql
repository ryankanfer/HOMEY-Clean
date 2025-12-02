-- =====================================================
-- HOMEY Agent Portal - Complete Schema with RLS
-- Includes all fields needed for agent registration
-- =====================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- STEP 1: Drop existing tables (if needed)
-- =====================================================

DROP TABLE IF EXISTS showing_requests CASCADE;
DROP TABLE IF EXISTS property_recommendations CASCADE;
DROP TABLE IF EXISTS shared_documents CASCADE;
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS agent_client_connections CASCADE;
DROP TABLE IF EXISTS agent_listings CASCADE;
DROP TABLE IF EXISTS agent_profiles CASCADE;

-- =====================================================
-- STEP 2: Create agent_profiles table
-- =====================================================

CREATE TABLE agent_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE,

  -- License & Brokerage
  license_number TEXT,
  license_state TEXT,
  brokerage_name TEXT,

  -- Professional Details
  specialties TEXT[],
  professional_phone TEXT,
  professional_email TEXT,
  bio TEXT,
  profile_image_url TEXT,
  cover_image_url TEXT,

  -- Service Area
  service_neighborhoods TEXT[],
  service_radius_miles INTEGER DEFAULT 25,

  -- Stats & Verification
  total_sales INTEGER DEFAULT 0,
  average_rating DECIMAL(3,2) DEFAULT 0.00,
  verified BOOLEAN DEFAULT FALSE,
  verification_date TIMESTAMP,

  -- Settings
  accepting_new_clients BOOLEAN DEFAULT TRUE,
  auto_respond_enabled BOOLEAN DEFAULT TRUE,
  availability_status TEXT DEFAULT 'available',

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- STEP 3: Create other agent portal tables
-- =====================================================

CREATE TABLE agent_client_connections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  agent_id UUID NOT NULL REFERENCES agent_profiles(id) ON DELETE CASCADE,
  client_id UUID NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  connection_type TEXT DEFAULT 'buyer',
  invitation_message TEXT,
  agent_notes TEXT,
  budget_min INTEGER,
  budget_max INTEGER,
  bedrooms_min INTEGER,
  target_neighborhoods TEXT[],
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(agent_id, client_id)
);

CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL REFERENCES agent_client_connections(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL,
  sender_type TEXT NOT NULL,
  message_type TEXT DEFAULT 'text',
  content TEXT NOT NULL,
  listing_id TEXT,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE shared_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL REFERENCES agent_client_connections(id) ON DELETE CASCADE,
  document_name TEXT NOT NULL,
  document_type TEXT NOT NULL,
  file_url TEXT NOT NULL,
  uploaded_by UUID NOT NULL,
  uploader_type TEXT NOT NULL,
  listing_id TEXT,
  viewed_by_client BOOLEAN DEFAULT FALSE,
  viewed_by_agent BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE property_recommendations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL REFERENCES agent_client_connections(id) ON DELETE CASCADE,
  agent_id UUID NOT NULL REFERENCES agent_profiles(id) ON DELETE CASCADE,
  client_id UUID NOT NULL,
  listing_id TEXT NOT NULL,
  recommendation_reason TEXT NOT NULL,
  highlights TEXT[],
  priority TEXT DEFAULT 'medium',
  client_viewed BOOLEAN DEFAULT FALSE,
  client_response TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE showing_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL REFERENCES agent_client_connections(id) ON DELETE CASCADE,
  listing_id TEXT NOT NULL,
  requested_by UUID NOT NULL,
  requester_type TEXT NOT NULL,
  preferred_date_1 TIMESTAMP NOT NULL,
  preferred_date_2 TIMESTAMP,
  confirmed_date TIMESTAMP,
  status TEXT DEFAULT 'pending',
  post_showing_notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE agent_listings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  agent_id UUID NOT NULL REFERENCES agent_profiles(id) ON DELETE CASCADE,
  listing_id TEXT NOT NULL,
  role TEXT NOT NULL,
  is_primary_agent BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(agent_id, listing_id, role)
);

-- =====================================================
-- STEP 4: Create indexes
-- =====================================================

CREATE INDEX idx_agent_profiles_user_id ON agent_profiles(user_id);
CREATE INDEX idx_connections_agent ON agent_client_connections(agent_id);
CREATE INDEX idx_connections_client ON agent_client_connections(client_id);
CREATE INDEX idx_messages_connection ON messages(connection_id);
CREATE INDEX idx_documents_connection ON shared_documents(connection_id);
CREATE INDEX idx_recommendations_connection ON property_recommendations(connection_id);
CREATE INDEX idx_showings_connection ON showing_requests(connection_id);
CREATE INDEX idx_agent_listings_agent ON agent_listings(agent_id);

-- =====================================================
-- STEP 5: Row Level Security (RLS) Policies
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE agent_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_client_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE shared_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE property_recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE showing_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_listings ENABLE ROW LEVEL SECURITY;

-- Agent Profiles Policies
CREATE POLICY "Agents can view their own profile"
  ON agent_profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Agents can update their own profile"
  ON agent_profiles FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Agents can insert their own profile"
  ON agent_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Public can view verified agent profiles"
  ON agent_profiles FOR SELECT
  USING (verified = true);

-- Agent-Client Connections Policies
CREATE POLICY "Agents can view their own connections"
  ON agent_client_connections FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM agent_profiles
      WHERE agent_profiles.id = agent_client_connections.agent_id
      AND agent_profiles.user_id = auth.uid()
    )
  );

CREATE POLICY "Clients can view their own connections"
  ON agent_client_connections FOR SELECT
  USING (client_id::text = auth.uid()::text);

CREATE POLICY "Agents can insert connections"
  ON agent_client_connections FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM agent_profiles
      WHERE agent_profiles.id = agent_client_connections.agent_id
      AND agent_profiles.user_id = auth.uid()
    )
  );

CREATE POLICY "Agents can update their connections"
  ON agent_client_connections FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM agent_profiles
      WHERE agent_profiles.id = agent_client_connections.agent_id
      AND agent_profiles.user_id = auth.uid()
    )
  );

-- Messages Policies
CREATE POLICY "Users can view messages in their connections"
  ON messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM agent_client_connections
      WHERE agent_client_connections.id = messages.connection_id
      AND (
        agent_client_connections.client_id::text = auth.uid()::text
        OR EXISTS (
          SELECT 1 FROM agent_profiles
          WHERE agent_profiles.id = agent_client_connections.agent_id
          AND agent_profiles.user_id = auth.uid()
        )
      )
    )
  );

CREATE POLICY "Users can send messages in their connections"
  ON messages FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM agent_client_connections
      WHERE agent_client_connections.id = messages.connection_id
      AND (
        agent_client_connections.client_id::text = auth.uid()::text
        OR EXISTS (
          SELECT 1 FROM agent_profiles
          WHERE agent_profiles.id = agent_client_connections.agent_id
          AND agent_profiles.user_id = auth.uid()
        )
      )
    )
  );

-- Documents Policies
CREATE POLICY "Users can view documents in their connections"
  ON shared_documents FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM agent_client_connections
      WHERE agent_client_connections.id = shared_documents.connection_id
      AND (
        agent_client_connections.client_id::text = auth.uid()::text
        OR EXISTS (
          SELECT 1 FROM agent_profiles
          WHERE agent_profiles.id = agent_client_connections.agent_id
          AND agent_profiles.user_id = auth.uid()
        )
      )
    )
  );

CREATE POLICY "Users can upload documents in their connections"
  ON shared_documents FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM agent_client_connections
      WHERE agent_client_connections.id = shared_documents.connection_id
      AND (
        agent_client_connections.client_id::text = auth.uid()::text
        OR EXISTS (
          SELECT 1 FROM agent_profiles
          WHERE agent_profiles.id = agent_client_connections.agent_id
          AND agent_profiles.user_id = auth.uid()
        )
      )
    )
  );

-- Recommendations Policies
CREATE POLICY "Users can view recommendations in their connections"
  ON property_recommendations FOR SELECT
  USING (
    client_id::text = auth.uid()::text
    OR EXISTS (
      SELECT 1 FROM agent_profiles
      WHERE agent_profiles.id = property_recommendations.agent_id
      AND agent_profiles.user_id = auth.uid()
    )
  );

CREATE POLICY "Agents can create recommendations"
  ON property_recommendations FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM agent_profiles
      WHERE agent_profiles.id = property_recommendations.agent_id
      AND agent_profiles.user_id = auth.uid()
    )
  );

-- Showing Requests Policies
CREATE POLICY "Users can view showings in their connections"
  ON showing_requests FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM agent_client_connections
      WHERE agent_client_connections.id = showing_requests.connection_id
      AND (
        agent_client_connections.client_id::text = auth.uid()::text
        OR EXISTS (
          SELECT 1 FROM agent_profiles
          WHERE agent_profiles.id = agent_client_connections.agent_id
          AND agent_profiles.user_id = auth.uid()
        )
      )
    )
  );

CREATE POLICY "Users can create showings in their connections"
  ON showing_requests FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM agent_client_connections
      WHERE agent_client_connections.id = showing_requests.connection_id
      AND (
        agent_client_connections.client_id::text = auth.uid()::text
        OR EXISTS (
          SELECT 1 FROM agent_profiles
          WHERE agent_profiles.id = agent_client_connections.agent_id
          AND agent_profiles.user_id = auth.uid()
        )
      )
    )
  );

-- Agent Listings Policies
CREATE POLICY "Agents can view their own listings"
  ON agent_listings FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM agent_profiles
      WHERE agent_profiles.id = agent_listings.agent_id
      AND agent_profiles.user_id = auth.uid()
    )
  );

CREATE POLICY "Agents can manage their listings"
  ON agent_listings FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM agent_profiles
      WHERE agent_profiles.id = agent_listings.agent_id
      AND agent_profiles.user_id = auth.uid()
    )
  );

-- =====================================================
-- SUCCESS!
-- =====================================================
-- All tables created with complete schema and RLS policies
