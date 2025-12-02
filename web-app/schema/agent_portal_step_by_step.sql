-- =====================================================
-- HOMEY Agent Portal - Step by Step Approach
-- Creates tables first, then adds constraints
-- =====================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- STEP 1: Create all tables WITHOUT foreign keys
-- =====================================================

-- 1. Agent Profiles
CREATE TABLE IF NOT EXISTS agent_profiles (
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
CREATE TABLE IF NOT EXISTS agent_client_connections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  agent_id UUID NOT NULL,
  client_id UUID NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  connection_type TEXT DEFAULT 'buyer',
  invitation_message TEXT,
  accepted_at TIMESTAMP,
  agent_notes TEXT,
  budget_min INTEGER,
  budget_max INTEGER,
  bedrooms_min INTEGER,
  target_neighborhoods TEXT[],
  last_interaction_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(agent_id, client_id)
);

-- 3. Messages
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL,
  sender_id UUID NOT NULL,
  sender_type TEXT NOT NULL,
  message_type TEXT NOT NULL DEFAULT 'text',
  content TEXT NOT NULL,
  listing_id TEXT,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 4. Shared Documents
CREATE TABLE IF NOT EXISTS shared_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL,
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

-- 5. Property Recommendations
CREATE TABLE IF NOT EXISTS property_recommendations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL,
  agent_id UUID NOT NULL,
  client_id UUID NOT NULL,
  listing_id TEXT NOT NULL,
  recommendation_reason TEXT NOT NULL,
  highlights TEXT[],
  priority TEXT DEFAULT 'medium',
  client_viewed BOOLEAN DEFAULT FALSE,
  client_response TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 6. Showing Requests
CREATE TABLE IF NOT EXISTS showing_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL,
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

-- =====================================================
-- STEP 2: Add foreign key constraints
-- =====================================================

-- Add FK for agent_client_connections -> agent_profiles
ALTER TABLE agent_client_connections
  DROP CONSTRAINT IF EXISTS fk_agent_client_connections_agent,
  ADD CONSTRAINT fk_agent_client_connections_agent
  FOREIGN KEY (agent_id) REFERENCES agent_profiles(id) ON DELETE CASCADE;

-- Add FK for messages -> agent_client_connections
ALTER TABLE messages
  DROP CONSTRAINT IF EXISTS fk_messages_connection,
  ADD CONSTRAINT fk_messages_connection
  FOREIGN KEY (connection_id) REFERENCES agent_client_connections(id) ON DELETE CASCADE;

-- Add FK for shared_documents -> agent_client_connections
ALTER TABLE shared_documents
  DROP CONSTRAINT IF EXISTS fk_documents_connection,
  ADD CONSTRAINT fk_documents_connection
  FOREIGN KEY (connection_id) REFERENCES agent_client_connections(id) ON DELETE CASCADE;

-- Add FK for property_recommendations -> agent_client_connections
ALTER TABLE property_recommendations
  DROP CONSTRAINT IF EXISTS fk_recommendations_connection,
  ADD CONSTRAINT fk_recommendations_connection
  FOREIGN KEY (connection_id) REFERENCES agent_client_connections(id) ON DELETE CASCADE;

-- Add FK for property_recommendations -> agent_profiles
ALTER TABLE property_recommendations
  DROP CONSTRAINT IF EXISTS fk_recommendations_agent,
  ADD CONSTRAINT fk_recommendations_agent
  FOREIGN KEY (agent_id) REFERENCES agent_profiles(id) ON DELETE CASCADE;

-- Add FK for showing_requests -> agent_client_connections
ALTER TABLE showing_requests
  DROP CONSTRAINT IF EXISTS fk_showings_connection,
  ADD CONSTRAINT fk_showings_connection
  FOREIGN KEY (connection_id) REFERENCES agent_client_connections(id) ON DELETE CASCADE;

-- =====================================================
-- STEP 3: Create indexes
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_agent_profiles_user_id ON agent_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_connections_agent ON agent_client_connections(agent_id);
CREATE INDEX IF NOT EXISTS idx_connections_client ON agent_client_connections(client_id);
CREATE INDEX IF NOT EXISTS idx_connections_status ON agent_client_connections(status);
CREATE INDEX IF NOT EXISTS idx_messages_connection ON messages(connection_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_documents_connection ON shared_documents(connection_id);
CREATE INDEX IF NOT EXISTS idx_recommendations_connection ON property_recommendations(connection_id);
CREATE INDEX IF NOT EXISTS idx_showings_connection ON showing_requests(connection_id);
