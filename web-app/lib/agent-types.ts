/**
 * TypeScript types for HOMEY Agent Portal
 * Matches schema/agent_portal_schema.sql
 */

export interface AgentProfile {
  id: string;
  user_id: string;

  // Professional Information
  license_number?: string;
  license_state?: string;
  brokerage_name?: string;
  brokerage_address?: string;
  years_experience?: number;
  specialties?: string[];

  // Contact & Branding
  professional_phone?: string;
  professional_email?: string;
  website_url?: string;
  bio?: string;
  profile_image_url?: string;
  cover_image_url?: string;

  // Service Areas
  service_neighborhoods?: string[];
  service_zip_codes?: string[];
  service_radius_miles?: number;

  // Stats & Verification
  total_sales?: number;
  average_rating?: number;
  verified?: boolean;
  verification_date?: string;

  // Settings
  accepting_new_clients?: boolean;
  auto_respond_enabled?: boolean;
  availability_status?: 'available' | 'busy' | 'away';

  created_at: string;
  updated_at: string;
}

export interface AgentClientConnection {
  id: string;
  agent_id: string;
  client_id: string;

  // Connection Status
  status: 'pending' | 'active' | 'paused' | 'completed' | 'terminated';
  connection_type?: 'buyer' | 'seller' | 'both';

  // How they connected
  source?: 'agent_invite' | 'client_request' | 'platform_match' | 'referral';
  invitation_message?: string;
  accepted_at?: string;

  // Client Preferences & Notes
  client_preferences?: Record<string, any>;
  agent_notes?: string;
  priority_level?: 'low' | 'medium' | 'high';

  // Search Criteria
  budget_min?: number;
  budget_max?: number;
  bedrooms_min?: number;
  bedrooms_max?: number;
  target_neighborhoods?: string[];
  must_have_amenities?: string[];

  // Transaction Info
  transaction_stage?: 'searching' | 'viewing' | 'offering' | 'under_contract' | 'closed';
  expected_close_date?: string;
  commission_percentage?: number;

  // Communication Preferences
  preferred_contact_method?: 'app' | 'email' | 'phone' | 'sms';
  notification_frequency?: 'immediate' | 'daily_digest' | 'weekly_summary';

  // Activity Tracking
  last_interaction_at?: string;
  total_properties_viewed?: number;
  total_showings_scheduled?: number;

  created_at: string;
  updated_at: string;
}

export interface Message {
  id: string;
  connection_id: string;

  // Sender Info
  sender_id: string;
  sender_type: 'agent' | 'client';

  // Message Content
  message_type: 'text' | 'property_share' | 'document_share' | 'showing_request' | 'system';
  content: string;
  metadata?: Record<string, any>;

  // Property Reference
  listing_id?: string;

  // Status
  read_at?: string;
  read_by?: string;

  // Reactions
  reactions?: Record<string, string[]>;

  // Threading
  reply_to_message_id?: string;

  created_at: string;
  updated_at: string;
}

export interface SharedDocument {
  id: string;
  connection_id: string;

  // Document Info
  document_name: string;
  document_type: 'contract' | 'disclosure' | 'inspection_report' | 'appraisal' | 'pre_approval' | 'other';
  file_url: string;
  file_size_bytes?: number;
  mime_type?: string;

  // Upload Info
  uploaded_by: string;
  uploader_type: 'agent' | 'client';

  // Document Metadata
  description?: string;
  listing_id?: string;

  // Status & Tracking
  requires_signature?: boolean;
  signed_at?: string;
  signed_by?: string;
  signature_url?: string;

  viewed_by_client?: boolean;
  viewed_by_agent?: boolean;
  client_viewed_at?: string;
  agent_viewed_at?: string;

  // Expiration
  expires_at?: string;

  created_at: string;
  updated_at: string;
}

export interface PropertyRecommendation {
  id: string;
  connection_id: string;
  agent_id: string;
  client_id: string;
  listing_id: string;

  // Recommendation Details
  recommendation_reason: string;
  highlights?: string[];
  potential_concerns?: string[];

  // Priority
  priority?: 'low' | 'medium' | 'high' | 'urgent';

  // Client Response
  client_viewed?: boolean;
  client_viewed_at?: string;
  client_response?: 'interested' | 'not_interested' | 'maybe' | 'scheduled_showing';
  client_feedback?: string;
  client_responded_at?: string;

  // Follow-up
  agent_followed_up?: boolean;
  follow_up_count?: number;
  last_follow_up_at?: string;

  created_at: string;
  updated_at: string;
}

export interface ClientFeedback {
  id: string;
  connection_id: string;
  client_id: string;
  agent_id: string;

  // Feedback Type
  feedback_type: 'property_feedback' | 'service_feedback' | 'showing_feedback' | 'general';

  // Property-specific feedback
  listing_id?: string;
  property_rating?: number; // 1-5
  property_likes?: string[];
  property_dislikes?: string[];

  // Service feedback
  agent_rating?: number; // 1-5
  communication_rating?: number; // 1-5
  responsiveness_rating?: number; // 1-5

  // Detailed Feedback
  comments?: string;
  preferred_changes?: string;

  // Agent Response
  agent_acknowledged?: boolean;
  agent_response?: string;
  agent_responded_at?: string;

  created_at: string;
  updated_at: string;
}

export interface ShowingRequest {
  id: string;
  connection_id: string;
  listing_id: string;

  // Request Details
  requested_by: string;
  requester_type: 'agent' | 'client';

  // Scheduling
  preferred_date_1: string;
  preferred_date_2?: string;
  preferred_date_3?: string;
  confirmed_date?: string;
  duration_minutes?: number;

  // Status
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled' | 'rescheduled';
  cancellation_reason?: string;
  cancelled_by?: string;
  cancelled_at?: string;

  // Meeting Details
  meeting_location?: string;
  meeting_instructions?: string;
  attendees?: string[];

  // Follow-up
  completed_at?: string;
  client_showed_up?: boolean;
  post_showing_notes?: string;
  client_post_showing_feedback?: string;

  // Reminders
  reminder_sent_24h?: boolean;
  reminder_sent_1h?: boolean;

  created_at: string;
  updated_at: string;
}

export interface AgentActivityLog {
  id: string;
  agent_id: string;

  // Activity Details
  activity_type: string;
  entity_type?: 'client' | 'listing' | 'document' | 'message';
  entity_id?: string;

  // Context
  connection_id?: string;
  description?: string;
  metadata?: Record<string, any>;

  created_at: string;
}

export interface AgentListing {
  id: string;
  agent_id: string;
  listing_id: string;

  // Agent Role
  role: 'listing_agent' | 'buyer_agent' | 'dual_agent';

  // Commission
  commission_percentage?: number;
  commission_amount?: number;

  // Status
  is_primary_agent?: boolean;

  created_at: string;
  updated_at: string;
}

// Extended User type with role
export interface User {
  id: string;
  email: string;
  role: 'consumer' | 'agent' | 'admin';
  // ... other user fields from auth.users
}

// Joined types for common queries
export interface AgentClientConnectionWithDetails extends AgentClientConnection {
  agent?: AgentProfile;
  client?: User;
  unread_messages?: number;
  latest_message?: Message;
}

export interface MessageWithSender extends Message {
  sender?: User;
}

export interface PropertyRecommendationWithListing extends PropertyRecommendation {
  listing?: any; // Use your existing Listing type
  agent?: AgentProfile;
}

export interface ShowingRequestWithListing extends ShowingRequest {
  listing?: any; // Use your existing Listing type
  connection?: AgentClientConnection;
}

export interface SharedDocumentWithDetails extends SharedDocument {
  uploader?: User;
  listing?: any; // Use your existing Listing type
}
