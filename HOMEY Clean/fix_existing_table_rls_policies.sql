-- RLS Policies for Existing Database Tables Only
-- Execute these commands in Supabase SQL Editor to secure existing tables
-- Based on table existence check: agent_client_links, preferences, documents, messages, showing_requests, client_agent_links, profiles

-- =====================================================
-- PROFILES TABLE POLICIES (Fix existing RLS issues)
-- =====================================================

-- Enable RLS on profiles table
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "agents_view_client_profiles" ON profiles;

-- Users can manage their own profile
CREATE POLICY "users_manage_own_profile" ON profiles
    FOR ALL
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Agents can view profiles of their assigned clients
CREATE POLICY "agents_view_client_profiles" ON profiles
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM agent_client_links acl
            WHERE acl.agent_id = auth.uid()
            AND acl.client_id = profiles.id
            AND acl.status = 'active'
        )
    );

-- =====================================================
-- AGENT_CLIENT_LINKS TABLE POLICIES
-- =====================================================

-- Enable RLS on agent_client_links table
ALTER TABLE agent_client_links ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "agents_manage_own_links" ON agent_client_links;
DROP POLICY IF EXISTS "clients_view_own_links" ON agent_client_links;
DROP POLICY IF EXISTS "users_insert_own_links" ON agent_client_links;

-- Agents can view and manage links where they are the agent
CREATE POLICY "agents_manage_own_links" ON agent_client_links
    FOR ALL
    USING (auth.uid() = agent_id)
    WITH CHECK (auth.uid() = agent_id);

-- Clients can view links where they are the client
CREATE POLICY "clients_view_own_links" ON agent_client_links
    FOR SELECT
    USING (auth.uid() = client_id);

-- Allow authenticated users to create links (for invite system)
CREATE POLICY "users_insert_own_links" ON agent_client_links
    FOR INSERT
    WITH CHECK (auth.uid() = invited_by);

-- =====================================================
-- PREFERENCES TABLE POLICIES
-- =====================================================

-- Enable RLS on preferences table
ALTER TABLE preferences ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "users_manage_own_preferences" ON preferences;
DROP POLICY IF EXISTS "agents_view_client_preferences" ON preferences;

-- Users can manage their own preferences
CREATE POLICY "users_manage_own_preferences" ON preferences
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Agents can view preferences of their assigned clients
CREATE POLICY "agents_view_client_preferences" ON preferences
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM agent_client_links acl
            WHERE acl.agent_id = auth.uid()
            AND acl.client_id = preferences.user_id
            AND acl.status = 'active'
        )
    );

-- =====================================================
-- DOCUMENTS TABLE POLICIES
-- =====================================================

-- Enable RLS on documents table
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "users_manage_own_documents" ON documents;
DROP POLICY IF EXISTS "agents_view_client_documents" ON documents;

-- Users can manage their own documents
CREATE POLICY "users_manage_own_documents" ON documents
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Agents can view documents of their assigned clients
CREATE POLICY "agents_view_client_documents" ON documents
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM agent_client_links acl
            WHERE acl.agent_id = auth.uid()
            AND acl.client_id = documents.user_id
            AND acl.status = 'active'
        )
    );

-- =====================================================
-- MESSAGES TABLE POLICIES
-- =====================================================

-- Enable RLS on messages table
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "users_manage_own_messages" ON messages;
DROP POLICY IF EXISTS "conversation_participants_access" ON messages;

-- Users can manage messages they sent
CREATE POLICY "users_manage_own_messages" ON messages
    FOR ALL
    USING (auth.uid() = sender_id)
    WITH CHECK (auth.uid() = sender_id);

-- Users can view messages in conversations they're part of
CREATE POLICY "conversation_participants_access" ON messages
    FOR SELECT
    USING (
        auth.uid() = sender_id OR 
        auth.uid() = recipient_id OR
        EXISTS (
            SELECT 1 FROM agent_client_links acl
            WHERE (
                (acl.agent_id = auth.uid() AND acl.client_id = messages.sender_id) OR
                (acl.agent_id = auth.uid() AND acl.client_id = messages.recipient_id) OR
                (acl.client_id = auth.uid() AND acl.agent_id = messages.sender_id) OR
                (acl.client_id = auth.uid() AND acl.agent_id = messages.recipient_id)
            )
            AND acl.status = 'active'
        )
    );

-- =====================================================
-- SHOWING_REQUESTS TABLE POLICIES
-- =====================================================

-- Enable RLS on showing_requests table
ALTER TABLE showing_requests ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "clients_manage_own_requests" ON showing_requests;
DROP POLICY IF EXISTS "agents_view_client_requests" ON showing_requests;

-- Clients can manage their own showing requests
CREATE POLICY "clients_manage_own_requests" ON showing_requests
    FOR ALL
    USING (auth.uid() = client_id)
    WITH CHECK (auth.uid() = client_id);

-- Agents can view showing requests from their assigned clients
CREATE POLICY "agents_view_client_requests" ON showing_requests
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM agent_client_links acl
            WHERE acl.agent_id = auth.uid()
            AND acl.client_id = showing_requests.client_id
            AND acl.status = 'active'
        )
    );

-- =====================================================
-- CLIENT_AGENT_LINKS TABLE POLICIES (for invite system)
-- =====================================================

-- Enable RLS on client_agent_links table
ALTER TABLE client_agent_links ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "users_manage_invite_links" ON client_agent_links;
DROP POLICY IF EXISTS "public_read_invite_codes" ON client_agent_links;

-- Users can manage invite links they created
CREATE POLICY "users_manage_invite_links" ON client_agent_links
    FOR ALL
    USING (auth.uid() = client_user_id)
    WITH CHECK (auth.uid() = client_user_id);

-- Allow reading invite links by code (for acceptance flow)
CREATE POLICY "public_read_invite_codes" ON client_agent_links
    FOR SELECT
    USING (true);



-- =====================================================
-- UTILITY FUNCTIONS
-- =====================================================

-- Test function to verify RLS policies are working
CREATE OR REPLACE FUNCTION test_rls_policies()
RETURNS TABLE (
    table_name TEXT,
    test_type TEXT,
    result TEXT,
    details TEXT
) AS $$
BEGIN
    -- Test profiles table
    RETURN QUERY
    SELECT 'profiles'::TEXT, 'anonymous_select'::TEXT,
           CASE WHEN (SELECT COUNT(*) FROM profiles) = 0 THEN 'PASS' ELSE 'FAIL' END,
           'Anonymous users should not be able to select from profiles table'::TEXT;
    
    -- Add more test cases as needed
    RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION test_rls_policies() TO authenticated;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check if RLS is enabled on all tables
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN (
    'profiles',
    'agent_client_links', 
    'preferences', 
    'documents', 
    'messages', 
    'showing_requests', 
    'client_agent_links'
)
ORDER BY tablename;

-- View all policies created
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    permissive, 
    roles, 
    cmd, 
    qual 
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename IN (
    'profiles',
    'agent_client_links', 
    'preferences', 
    'documents', 
    'messages', 
    'showing_requests',
    'client_agent_links'
)
ORDER BY tablename, policyname;