-- =====================================================
-- HOMEY Agent Portal - Minimal Schema (Works Standalone)
-- No external table dependencies
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. AGENT PROFILES
-- =====================================================
CREATE TABLE IF NOT EXISTS agent_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE,

  -- Professional Info
  license_number TEXT,
  brokerage_name TEXT,
  professional_phone TEXT,
  bio TEXT,
  profile_image_url TEXT,

  -- Service Areas
  service_neighborhoods TEXT[],

  -- Stats
  total_sales INTEGER DEFAULT 0,
  verified BOOLEAN DEFAULT FALSE,
  accepting_new_clients BOOLEAN DEFAULT TRUE,

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_agent_profiles_user_id ON agent_profiles(user_id);

-- =====================================================
-- 2. AGENT-CLIENT CONNECTIONS (Core Relationship)
-- =====================================================
CREATE TABLE IF NOT EXISTS agent_client_connections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  agent_id UUID NOT NULL REFERENCES agent_profiles(id) ON DELETE CASCADE,
  client_id UUID NOT NULL,

  -- Status
  status TEXT NOT NULL DEFAULT 'pending',
  connection_type TEXT DEFAULT 'buyer',

  -- Client Search Criteria
  budget_min INTEGER,
  budget_max INTEGER,
  bedrooms_min INTEGER,
  target_neighborhoods TEXT[],

  -- Notes
  agent_notes TEXT,
  invitation_message TEXT,
  accepted_at TIMESTAMP,

  -- Tracking
  last_interaction_at TIMESTAMP DEFAULT NOW(),

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  UNIQUE(agent_id, client_id)
);

CREATE INDEX IF NOT EXISTS idx_connections_agent ON agent_client_connections(agent_id);
CREATE INDEX IF NOT EXISTS idx_connections_client ON agent_client_connections(client_id);
CREATE INDEX IF NOT EXISTS idx_connections_status ON agent_client_connections(status);

-- =====================================================
-- 3. MESSAGES
-- =====================================================
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL REFERENCES agent_client_connections(id) ON DELETE CASCADE,

  sender_id UUID NOT NULL,
  sender_type TEXT NOT NULL,

  message_type TEXT NOT NULL DEFAULT 'text',
  content TEXT NOT NULL,

  -- Optional property reference (just store ID as text for now)
  listing_id TEXT,

  read_at TIMESTAMP,

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_messages_connection ON messages(connection_id);
CREATE INDEX IF NOT EXISTS idx_messages_created ON messages(created_at DESC);

-- =====================================================
-- 4. SHARED DOCUMENTS
-- =====================================================
CREATE TABLE IF NOT EXISTS shared_documents (
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

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_documents_connection ON shared_documents(connection_id);

-- =====================================================
-- 5. PROPERTY RECOMMENDATIONS
-- =====================================================
CREATE TABLE IF NOT EXISTS property_recommendations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL REFERENCES agent_client_connections(id) ON DELETE CASCADE,
  agent_id UUID NOT NULL REFERENCES agent_profiles(id) ON DELETE CASCADE,
  client_id UUID NOT NULL,
  listing_id TEXT NOT NULL,

  recommendation_reason TEXT NOT NULL,
  highlights TEXT[],

  client_viewed BOOLEAN DEFAULT FALSE,
  client_viewed_at TIMESTAMP,
  client_response TEXT,

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_recommendations_connection ON property_recommendations(connection_id);
CREATE INDEX IF NOT EXISTS idx_recommendations_agent ON property_recommendations(agent_id);
CREATE INDEX IF NOT EXISTS idx_recommendations_client ON property_recommendations(client_id);

-- =====================================================
-- 6. SHOWING REQUESTS
-- =====================================================
CREATE TABLE IF NOT EXISTS showing_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL REFERENCES agent_client_connections(id) ON DELETE CASCADE,
  listing_id TEXT NOT NULL,

  requested_by UUID NOT NULL,
  requester_type TEXT NOT NULL,

  preferred_date_1 TIMESTAMP NOT NULL,
  preferred_date_2 TIMESTAMP,
  confirmed_date TIMESTAMP,

  status TEXT NOT NULL DEFAULT 'pending',

  post_showing_notes TEXT,

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_showings_connection ON showing_requests(connection_id);
CREATE INDEX IF NOT EXISTS idx_showings_status ON showing_requests(status);

-- =====================================================
-- TRIGGERS FOR updated_at
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

DO $$
BEGIN
  DROP TRIGGER IF EXISTS update_agent_profiles_updated_at ON agent_profiles;
  CREATE TRIGGER update_agent_profiles_updated_at
    BEFORE UPDATE ON agent_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

  DROP TRIGGER IF EXISTS update_connections_updated_at ON agent_client_connections;
  CREATE TRIGGER update_connections_updated_at
    BEFORE UPDATE ON agent_client_connections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

  DROP TRIGGER IF EXISTS update_messages_updated_at ON messages;
  CREATE TRIGGER update_messages_updated_at
    BEFORE UPDATE ON messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

  DROP TRIGGER IF EXISTS update_documents_updated_at ON shared_documents;
  CREATE TRIGGER update_documents_updated_at
    BEFORE UPDATE ON shared_documents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

  DROP TRIGGER IF EXISTS update_recommendations_updated_at ON property_recommendations;
  CREATE TRIGGER update_recommendations_updated_at
    BEFORE UPDATE ON property_recommendations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

  DROP TRIGGER IF EXISTS update_showings_updated_at ON showing_requests;
  CREATE TRIGGER update_showings_updated_at
    BEFORE UPDATE ON showing_requests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
END $$;
