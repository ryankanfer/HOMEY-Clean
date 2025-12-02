-- =====================================================
-- HOMEY Agent Portal - Clean Install
-- Drops existing tables first, then creates fresh
-- =====================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- STEP 1: Drop all existing tables (in reverse order)
-- =====================================================

DROP TABLE IF EXISTS showing_requests CASCADE;
DROP TABLE IF EXISTS property_recommendations CASCADE;
DROP TABLE IF EXISTS shared_documents CASCADE;
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS agent_client_connections CASCADE;
DROP TABLE IF EXISTS agent_profiles CASCADE;

-- =====================================================
-- STEP 2: Create all tables fresh
-- =====================================================

-- 1. Agent Profiles
CREATE TABLE agent_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE,
  license_number TEXT,
  brokerage_name TEXT,
  professional_phone TEXT,
  bio TEXT,
  profile_image_url TEXT,
  service_neighborhoods TEXT[],
  total_sales INTEGER DEFAULT 0,
  verified BOOLEAN DEFAULT FALSE,
  accepting_new_clients BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. Agent-Client Connections
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

-- 3. Messages
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

-- 4. Shared Documents
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

-- 5. Property Recommendations
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

-- 6. Showing Requests
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

-- =====================================================
-- STEP 3: Create indexes
-- =====================================================

CREATE INDEX idx_agent_profiles_user_id ON agent_profiles(user_id);
CREATE INDEX idx_connections_agent ON agent_client_connections(agent_id);
CREATE INDEX idx_connections_client ON agent_client_connections(client_id);
CREATE INDEX idx_messages_connection ON messages(connection_id);
CREATE INDEX idx_documents_connection ON shared_documents(connection_id);
CREATE INDEX idx_recommendations_connection ON property_recommendations(connection_id);
CREATE INDEX idx_showings_connection ON showing_requests(connection_id);
