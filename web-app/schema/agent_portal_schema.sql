-- =====================================================
-- HOMEY Agent Portal Database Schema
-- Focus: Agent-Client Connection & Communication
-- =====================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. AGENT PROFILES
-- Extended profile information for real estate agents
-- =====================================================
CREATE TABLE IF NOT EXISTS agent_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Professional Information
  license_number TEXT,
  license_state TEXT,
  brokerage_name TEXT,
  brokerage_address TEXT,
  years_experience INTEGER,
  specialties TEXT[], -- e.g., ['first-time buyers', 'luxury homes', 'investment properties']

  -- Contact & Branding
  professional_phone TEXT,
  professional_email TEXT,
  website_url TEXT,
  bio TEXT,
  profile_image_url TEXT,
  cover_image_url TEXT,

  -- Service Areas
  service_neighborhoods TEXT[], -- neighborhoods they serve
  service_zip_codes TEXT[],
  service_radius_miles INTEGER DEFAULT 25,

  -- Stats & Verification
  total_sales INTEGER DEFAULT 0,
  average_rating DECIMAL(3,2) DEFAULT 0.00,
  verified BOOLEAN DEFAULT FALSE,
  verification_date TIMESTAMP,

  -- Settings
  accepting_new_clients BOOLEAN DEFAULT TRUE,
  auto_respond_enabled BOOLEAN DEFAULT TRUE,
  availability_status TEXT DEFAULT 'available', -- 'available', 'busy', 'away'

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Index for quick lookups
CREATE INDEX idx_agent_profiles_user_id ON agent_profiles(user_id);
CREATE INDEX idx_agent_profiles_service_neighborhoods ON agent_profiles USING GIN(service_neighborhoods);

-- =====================================================
-- 2. AGENT-CLIENT CONNECTIONS
-- The core relationship between agents and clients
-- =====================================================
CREATE TABLE IF NOT EXISTS agent_client_connections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  agent_id UUID NOT NULL REFERENCES agent_profiles(id) ON DELETE CASCADE,
  client_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Connection Status
  status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'active', 'paused', 'completed', 'terminated'
  connection_type TEXT DEFAULT 'buyer', -- 'buyer', 'seller', 'both'

  -- How they connected
  source TEXT, -- 'agent_invite', 'client_request', 'platform_match', 'referral'
  invitation_message TEXT,
  accepted_at TIMESTAMP,

  -- Client Preferences & Notes (agent's perspective)
  client_preferences JSONB, -- price range, bedrooms, neighborhoods, etc.
  agent_notes TEXT,
  priority_level TEXT DEFAULT 'medium', -- 'low', 'medium', 'high'

  -- Search Criteria
  budget_min INTEGER,
  budget_max INTEGER,
  bedrooms_min INTEGER,
  bedrooms_max INTEGER,
  target_neighborhoods TEXT[],
  must_have_amenities TEXT[],

  -- Transaction Info
  transaction_stage TEXT DEFAULT 'searching', -- 'searching', 'viewing', 'offering', 'under_contract', 'closed'
  expected_close_date DATE,
  commission_percentage DECIMAL(5,2),

  -- Communication Preferences
  preferred_contact_method TEXT DEFAULT 'app', -- 'app', 'email', 'phone', 'sms'
  notification_frequency TEXT DEFAULT 'immediate', -- 'immediate', 'daily_digest', 'weekly_summary'

  -- Activity Tracking
  last_interaction_at TIMESTAMP DEFAULT NOW(),
  total_properties_viewed INTEGER DEFAULT 0,
  total_showings_scheduled INTEGER DEFAULT 0,

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  -- Ensure one agent-client pair
  UNIQUE(agent_id, client_id)
);

-- Indexes for efficient queries
CREATE INDEX idx_agent_client_connections_agent_id ON agent_client_connections(agent_id);
CREATE INDEX idx_agent_client_connections_client_id ON agent_client_connections(client_id);
CREATE INDEX idx_agent_client_connections_status ON agent_client_connections(status);

-- =====================================================
-- 3. MESSAGES
-- Real-time messaging between agents and clients
-- =====================================================
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL REFERENCES agent_client_connections(id) ON DELETE CASCADE,

  -- Sender Info
  sender_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  sender_type TEXT NOT NULL, -- 'agent' or 'client'

  -- Message Content
  message_type TEXT NOT NULL DEFAULT 'text', -- 'text', 'property_share', 'document_share', 'showing_request', 'system'
  content TEXT NOT NULL,
  metadata JSONB, -- For property shares, document refs, etc.

  -- Property Reference (if sharing a property)
  listing_id UUID REFERENCES listings(id) ON DELETE SET NULL,

  -- Status
  read_at TIMESTAMP,
  read_by UUID REFERENCES auth.users(id),

  -- Reactions/Engagement
  reactions JSONB DEFAULT '{}', -- e.g., {"❤️": ["user_id_1"], "👍": ["user_id_2"]}

  -- Threading
  reply_to_message_id UUID REFERENCES messages(id) ON DELETE SET NULL,

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for real-time chat performance
CREATE INDEX idx_messages_connection_id ON messages(connection_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_listing_id ON messages(listing_id) WHERE listing_id IS NOT NULL;

-- =====================================================
-- 4. SHARED DOCUMENTS
-- Documents shared between agents and clients
-- =====================================================
CREATE TABLE IF NOT EXISTS shared_documents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL REFERENCES agent_client_connections(id) ON DELETE CASCADE,

  -- Document Info
  document_name TEXT NOT NULL,
  document_type TEXT NOT NULL, -- 'contract', 'disclosure', 'inspection_report', 'appraisal', 'pre_approval', 'other'
  file_url TEXT NOT NULL, -- Supabase Storage URL
  file_size_bytes BIGINT,
  mime_type TEXT,

  -- Upload Info
  uploaded_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  uploader_type TEXT NOT NULL, -- 'agent' or 'client'

  -- Document Metadata
  description TEXT,
  listing_id UUID REFERENCES listings(id) ON DELETE SET NULL, -- If document is property-specific

  -- Status & Tracking
  requires_signature BOOLEAN DEFAULT FALSE,
  signed_at TIMESTAMP,
  signed_by UUID REFERENCES auth.users(id),
  signature_url TEXT, -- URL to signed document

  viewed_by_client BOOLEAN DEFAULT FALSE,
  viewed_by_agent BOOLEAN DEFAULT FALSE,
  client_viewed_at TIMESTAMP,
  agent_viewed_at TIMESTAMP,

  -- Expiration
  expires_at TIMESTAMP,

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_shared_documents_connection_id ON shared_documents(connection_id);
CREATE INDEX idx_shared_documents_listing_id ON shared_documents(listing_id) WHERE listing_id IS NOT NULL;
CREATE INDEX idx_shared_documents_document_type ON shared_documents(document_type);

-- =====================================================
-- 5. PROPERTY RECOMMENDATIONS
-- Properties agents specifically recommend to clients
-- =====================================================
CREATE TABLE IF NOT EXISTS property_recommendations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL REFERENCES agent_client_connections(id) ON DELETE CASCADE,
  agent_id UUID NOT NULL REFERENCES agent_profiles(id) ON DELETE CASCADE,
  client_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,

  -- Recommendation Details
  recommendation_reason TEXT NOT NULL, -- Agent's note on why they're recommending
  highlights TEXT[], -- Key selling points agent wants to emphasize
  potential_concerns TEXT[], -- Things to be aware of

  -- Priority
  priority TEXT DEFAULT 'medium', -- 'low', 'medium', 'high', 'urgent'

  -- Client Response
  client_viewed BOOLEAN DEFAULT FALSE,
  client_viewed_at TIMESTAMP,
  client_response TEXT, -- 'interested', 'not_interested', 'maybe', 'scheduled_showing'
  client_feedback TEXT,
  client_responded_at TIMESTAMP,

  -- Follow-up
  agent_followed_up BOOLEAN DEFAULT FALSE,
  follow_up_count INTEGER DEFAULT 0,
  last_follow_up_at TIMESTAMP,

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_property_recommendations_connection_id ON property_recommendations(connection_id);
CREATE INDEX idx_property_recommendations_agent_id ON property_recommendations(agent_id);
CREATE INDEX idx_property_recommendations_client_id ON property_recommendations(client_id);
CREATE INDEX idx_property_recommendations_listing_id ON property_recommendations(listing_id);
CREATE INDEX idx_property_recommendations_client_response ON property_recommendations(client_response);

-- =====================================================
-- 6. CLIENT FEEDBACK
-- Feedback clients provide to agents
-- =====================================================
CREATE TABLE IF NOT EXISTS client_feedback (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL REFERENCES agent_client_connections(id) ON DELETE CASCADE,
  client_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  agent_id UUID NOT NULL REFERENCES agent_profiles(id) ON DELETE CASCADE,

  -- Feedback Type
  feedback_type TEXT NOT NULL, -- 'property_feedback', 'service_feedback', 'showing_feedback', 'general'

  -- Property-specific feedback
  listing_id UUID REFERENCES listings(id) ON DELETE SET NULL,
  property_rating INTEGER CHECK (property_rating >= 1 AND property_rating <= 5),
  property_likes TEXT[],
  property_dislikes TEXT[],

  -- Service feedback
  agent_rating INTEGER CHECK (agent_rating >= 1 AND agent_rating <= 5),
  communication_rating INTEGER CHECK (communication_rating >= 1 AND communication_rating <= 5),
  responsiveness_rating INTEGER CHECK (responsiveness_rating >= 1 AND responsiveness_rating <= 5),

  -- Detailed Feedback
  comments TEXT,
  preferred_changes TEXT, -- What client wants to see differently

  -- Agent Response
  agent_acknowledged BOOLEAN DEFAULT FALSE,
  agent_response TEXT,
  agent_responded_at TIMESTAMP,

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_client_feedback_connection_id ON client_feedback(connection_id);
CREATE INDEX idx_client_feedback_agent_id ON client_feedback(agent_id);
CREATE INDEX idx_client_feedback_client_id ON client_feedback(client_id);
CREATE INDEX idx_client_feedback_listing_id ON client_feedback(listing_id) WHERE listing_id IS NOT NULL;

-- =====================================================
-- 7. SHOWING REQUESTS
-- Property showing scheduling between agents and clients
-- =====================================================
CREATE TABLE IF NOT EXISTS showing_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL REFERENCES agent_client_connections(id) ON DELETE CASCADE,
  listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,

  -- Request Details
  requested_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  requester_type TEXT NOT NULL, -- 'agent' or 'client'

  -- Scheduling
  preferred_date_1 TIMESTAMP NOT NULL,
  preferred_date_2 TIMESTAMP,
  preferred_date_3 TIMESTAMP,
  confirmed_date TIMESTAMP,
  duration_minutes INTEGER DEFAULT 30,

  -- Status
  status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'confirmed', 'completed', 'cancelled', 'rescheduled'
  cancellation_reason TEXT,
  cancelled_by UUID REFERENCES auth.users(id),
  cancelled_at TIMESTAMP,

  -- Meeting Details
  meeting_location TEXT, -- If not at property address
  meeting_instructions TEXT,
  attendees TEXT[], -- Additional people attending

  -- Follow-up
  completed_at TIMESTAMP,
  client_showed_up BOOLEAN,
  post_showing_notes TEXT, -- Agent's notes after showing
  client_post_showing_feedback TEXT,

  -- Reminders
  reminder_sent_24h BOOLEAN DEFAULT FALSE,
  reminder_sent_1h BOOLEAN DEFAULT FALSE,

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_showing_requests_connection_id ON showing_requests(connection_id);
CREATE INDEX idx_showing_requests_listing_id ON showing_requests(listing_id);
CREATE INDEX idx_showing_requests_confirmed_date ON showing_requests(confirmed_date) WHERE confirmed_date IS NOT NULL;
CREATE INDEX idx_showing_requests_status ON showing_requests(status);

-- =====================================================
-- 8. AGENT ACTIVITY LOG
-- Track all agent actions for analytics and compliance
-- =====================================================
CREATE TABLE IF NOT EXISTS agent_activity_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  agent_id UUID NOT NULL REFERENCES agent_profiles(id) ON DELETE CASCADE,

  -- Activity Details
  activity_type TEXT NOT NULL, -- 'client_contacted', 'property_recommended', 'document_shared', 'showing_scheduled', etc.
  entity_type TEXT, -- 'client', 'listing', 'document', 'message'
  entity_id UUID, -- ID of the related entity

  -- Context
  connection_id UUID REFERENCES agent_client_connections(id) ON DELETE SET NULL,
  description TEXT,
  metadata JSONB,

  created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_agent_activity_log_agent_id ON agent_activity_log(agent_id);
CREATE INDEX idx_agent_activity_log_created_at ON agent_activity_log(created_at DESC);
CREATE INDEX idx_agent_activity_log_activity_type ON agent_activity_log(activity_type);

-- =====================================================
-- 9. UPDATE USERS TABLE
-- Add role column to existing users table
-- =====================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='role') THEN
    ALTER TABLE users ADD COLUMN role TEXT DEFAULT 'consumer';
  END IF;
END $$;

-- Add index on role for filtering
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- =====================================================
-- 10. AGENT LISTINGS RELATIONSHIP
-- Track which agents manage which listings
-- =====================================================
CREATE TABLE IF NOT EXISTS agent_listings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  agent_id UUID NOT NULL REFERENCES agent_profiles(id) ON DELETE CASCADE,
  listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,

  -- Agent Role
  role TEXT NOT NULL, -- 'listing_agent', 'buyer_agent', 'dual_agent'

  -- Commission
  commission_percentage DECIMAL(5,2),
  commission_amount DECIMAL(12,2),

  -- Status
  is_primary_agent BOOLEAN DEFAULT TRUE,

  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  -- Ensure unique agent-listing-role combination
  UNIQUE(agent_id, listing_id, role)
);

-- Indexes
CREATE INDEX idx_agent_listings_agent_id ON agent_listings(agent_id);
CREATE INDEX idx_agent_listings_listing_id ON agent_listings(listing_id);

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

-- Apply to all tables with updated_at
CREATE TRIGGER update_agent_profiles_updated_at BEFORE UPDATE ON agent_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_agent_client_connections_updated_at BEFORE UPDATE ON agent_client_connections FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_shared_documents_updated_at BEFORE UPDATE ON shared_documents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_property_recommendations_updated_at BEFORE UPDATE ON property_recommendations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_client_feedback_updated_at BEFORE UPDATE ON client_feedback FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_showing_requests_updated_at BEFORE UPDATE ON showing_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_agent_listings_updated_at BEFORE UPDATE ON agent_listings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- COMMENTS FOR DOCUMENTATION
-- =====================================================
COMMENT ON TABLE agent_profiles IS 'Extended profile information for real estate agents';
COMMENT ON TABLE agent_client_connections IS 'Core relationship table between agents and their clients';
COMMENT ON TABLE messages IS 'Real-time messaging between agents and clients with support for property sharing';
COMMENT ON TABLE shared_documents IS 'Documents shared between agents and clients including contracts and disclosures';
COMMENT ON TABLE property_recommendations IS 'Properties that agents specifically recommend to their clients';
COMMENT ON TABLE client_feedback IS 'Feedback clients provide about properties and agent service';
COMMENT ON TABLE showing_requests IS 'Property showing scheduling and management';
COMMENT ON TABLE agent_activity_log IS 'Audit log of all agent activities for analytics and compliance';
COMMENT ON TABLE agent_listings IS 'Relationship between agents and the listings they manage';
