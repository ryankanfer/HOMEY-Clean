-- =====================================================
-- HOMEY Agent Portal - Final Working Version
-- All tables, simple indexes only
-- =====================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. AGENT PROFILES
-- =====================================================
CREATE TABLE IF NOT EXISTS agent_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE,
  license_number TEXT,
  license_state TEXT,
  brokerage_name TEXT,
  brokerage_address TEXT,
  years_experience INTEGER,
  specialties TEXT[],
  professional_phone TEXT,
  professional_email TEXT,
  website_url TEXT,
  bio TEXT,
  profile_image_url TEXT,
  cover_image_url TEXT,
  service_neighborhoods TEXT[],
  service_zip_codes TEXT[],
  service_radius_miles INTEGER DEFAULT 25,
  total_sales INTEGER DEFAULT 0,
  average_rating DECIMAL(3,2) DEFAULT 0.00,
  verified BOOLEAN DEFAULT FALSE,
  verification_date TIMESTAMP,
  accepting_new_clients BOOLEAN DEFAULT TRUE,
  auto_respond_enabled BOOLEAN DEFAULT TRUE,
  availability_status TEXT DEFAULT 'available',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 2. AGENT-CLIENT CONNECTIONS
-- =====================================================
CREATE TABLE IF NOT EXISTS agent_client_connections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  agent_id UUID NOT NULL REFERENCES agent_profiles(id) ON DELETE CASCADE,
  client_id UUID NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  connection_type TEXT DEFAULT 'buyer',
  source TEXT,
  invitation_message TEXT,
  accepted_at TIMESTAMP,
  client_preferences JSONB,
  agent_notes TEXT,
  priority_level TEXT DEFAULT 'medium',
  budget_min INTEGER,
  budget_max INTEGER,
  bedrooms_min INTEGER,
  bedrooms_max INTEGER,
  target_neighborhoods TEXT[],
  must_have_amenities TEXT[],
  transaction_stage TEXT DEFAULT 'searching',
  expected_close_date DATE,
  commission_percentage DECIMAL(5,2),
  preferred_contact_method TEXT DEFAULT 'app',
  notification_frequency TEXT DEFAULT 'immediate',
  last_interaction_at TIMESTAMP DEFAULT NOW(),
  total_properties_viewed INTEGER DEFAULT 0,
  total_showings_scheduled INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(agent_id, client_id)
);

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
  metadata JSONB,
  listing_id TEXT,
  read_at TIMESTAMP,
  read_by UUID,
  reactions JSONB DEFAULT '{}',
  reply_to_message_id UUID REFERENCES messages(id) ON DELETE SET NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 4. SHARED DOCUMENTS
-- =====================================================
CREATE TABLE IF NOT EXISTS shared_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL REFERENCES agent_client_connections(id) ON DELETE CASCADE,
  document_name TEXT NOT NULL,
  document_type TEXT NOT NULL,
  file_url TEXT NOT NULL,
  file_size_bytes BIGINT,
  mime_type TEXT,
  uploaded_by UUID NOT NULL,
  uploader_type TEXT NOT NULL,
  description TEXT,
  listing_id TEXT,
  requires_signature BOOLEAN DEFAULT FALSE,
  signed_at TIMESTAMP,
  signed_by UUID,
  signature_url TEXT,
  viewed_by_client BOOLEAN DEFAULT FALSE,
  viewed_by_agent BOOLEAN DEFAULT FALSE,
  client_viewed_at TIMESTAMP,
  agent_viewed_at TIMESTAMP,
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

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
  potential_concerns TEXT[],
  priority TEXT DEFAULT 'medium',
  client_viewed BOOLEAN DEFAULT FALSE,
  client_viewed_at TIMESTAMP,
  client_response TEXT,
  client_feedback TEXT,
  client_responded_at TIMESTAMP,
  agent_followed_up BOOLEAN DEFAULT FALSE,
  follow_up_count INTEGER DEFAULT 0,
  last_follow_up_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 6. CLIENT FEEDBACK
-- =====================================================
CREATE TABLE IF NOT EXISTS client_feedback (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL REFERENCES agent_client_connections(id) ON DELETE CASCADE,
  client_id UUID NOT NULL,
  agent_id UUID NOT NULL REFERENCES agent_profiles(id) ON DELETE CASCADE,
  feedback_type TEXT NOT NULL,
  listing_id TEXT,
  property_rating INTEGER CHECK (property_rating >= 1 AND property_rating <= 5),
  property_likes TEXT[],
  property_dislikes TEXT[],
  agent_rating INTEGER CHECK (agent_rating >= 1 AND agent_rating <= 5),
  communication_rating INTEGER CHECK (communication_rating >= 1 AND communication_rating <= 5),
  responsiveness_rating INTEGER CHECK (responsiveness_rating >= 1 AND responsiveness_rating <= 5),
  comments TEXT,
  preferred_changes TEXT,
  agent_acknowledged BOOLEAN DEFAULT FALSE,
  agent_response TEXT,
  agent_responded_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 7. SHOWING REQUESTS
-- =====================================================
CREATE TABLE IF NOT EXISTS showing_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL REFERENCES agent_client_connections(id) ON DELETE CASCADE,
  listing_id TEXT NOT NULL,
  requested_by UUID NOT NULL,
  requester_type TEXT NOT NULL,
  preferred_date_1 TIMESTAMP NOT NULL,
  preferred_date_2 TIMESTAMP,
  preferred_date_3 TIMESTAMP,
  confirmed_date TIMESTAMP,
  duration_minutes INTEGER DEFAULT 30,
  status TEXT NOT NULL DEFAULT 'pending',
  cancellation_reason TEXT,
  cancelled_by UUID,
  cancelled_at TIMESTAMP,
  meeting_location TEXT,
  meeting_instructions TEXT,
  attendees TEXT[],
  completed_at TIMESTAMP,
  client_showed_up BOOLEAN,
  post_showing_notes TEXT,
  client_post_showing_feedback TEXT,
  reminder_sent_24h BOOLEAN DEFAULT FALSE,
  reminder_sent_1h BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 8. AGENT ACTIVITY LOG
-- =====================================================
CREATE TABLE IF NOT EXISTS agent_activity_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  agent_id UUID NOT NULL REFERENCES agent_profiles(id) ON DELETE CASCADE,
  activity_type TEXT NOT NULL,
  entity_type TEXT,
  entity_id UUID,
  connection_id UUID REFERENCES agent_client_connections(id) ON DELETE SET NULL,
  description TEXT,
  metadata JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- 9. AGENT LISTINGS
-- =====================================================
CREATE TABLE IF NOT EXISTS agent_listings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  agent_id UUID NOT NULL REFERENCES agent_profiles(id) ON DELETE CASCADE,
  listing_id TEXT NOT NULL,
  role TEXT NOT NULL,
  commission_percentage DECIMAL(5,2),
  commission_amount DECIMAL(12,2),
  is_primary_agent BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(agent_id, listing_id, role)
);

-- =====================================================
-- INDEXES (Simple ones only)
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_agent_profiles_user_id ON agent_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_connections_agent ON agent_client_connections(agent_id);
CREATE INDEX IF NOT EXISTS idx_connections_client ON agent_client_connections(client_id);
CREATE INDEX IF NOT EXISTS idx_connections_status ON agent_client_connections(status);
CREATE INDEX IF NOT EXISTS idx_messages_connection ON messages(connection_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_documents_connection ON shared_documents(connection_id);
CREATE INDEX IF NOT EXISTS idx_recommendations_connection ON property_recommendations(connection_id);
CREATE INDEX IF NOT EXISTS idx_recommendations_agent ON property_recommendations(agent_id);
CREATE INDEX IF NOT EXISTS idx_feedback_connection ON client_feedback(connection_id);
CREATE INDEX IF NOT EXISTS idx_showings_connection ON showing_requests(connection_id);
CREATE INDEX IF NOT EXISTS idx_activity_agent ON agent_activity_log(agent_id);
CREATE INDEX IF NOT EXISTS idx_agent_listings_agent ON agent_listings(agent_id);
