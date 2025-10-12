-- Unified Profiles Migration Script
-- This script migrates all user, client, and agent data operations to the new profiles table

-- =====================================================
-- PROFILES TABLE ENHANCEMENT
-- =====================================================

-- Add any missing columns to profiles table if they don't exist
DO $$ 
BEGIN
    -- Add role column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'role') THEN
        ALTER TABLE profiles ADD COLUMN role TEXT CHECK (role IN ('client', 'agent', 'admin')) DEFAULT 'client';
    END IF;
    
    -- Add company_name for agents
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'company_name') THEN
        ALTER TABLE profiles ADD COLUMN company_name TEXT;
    END IF;
    
    -- Add company_license for agents
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'company_license') THEN
        ALTER TABLE profiles ADD COLUMN company_license TEXT;
    END IF;
    
    -- Add phone number
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'phone') THEN
        ALTER TABLE profiles ADD COLUMN phone TEXT;
    END IF;
    
    -- Add profile completion status
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'profile_complete') THEN
        ALTER TABLE profiles ADD COLUMN profile_complete BOOLEAN DEFAULT FALSE;
    END IF;
    
    -- Add onboarding completion status
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'onboarding_complete') THEN
        ALTER TABLE profiles ADD COLUMN onboarding_complete BOOLEAN DEFAULT FALSE;
    END IF;
    
    -- Add metadata for flexible data storage
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'metadata') THEN
        ALTER TABLE profiles ADD COLUMN metadata JSONB DEFAULT '{}';
    END IF;
    
    -- Add status column
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'status') THEN
        ALTER TABLE profiles ADD COLUMN status TEXT CHECK (status IN ('active', 'inactive', 'pending', 'suspended')) DEFAULT 'pending';
    END IF;
END $$;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_status ON profiles(status);
CREATE INDEX IF NOT EXISTS idx_profiles_company_name ON profiles(company_name);
CREATE INDEX IF NOT EXISTS idx_profiles_onboarding_complete ON profiles(onboarding_complete);

-- =====================================================
-- UNIFIED USER CREATION FUNCTIONS
-- =====================================================

-- Create or update user profile with comprehensive data
CREATE OR REPLACE FUNCTION create_user_profile(
    user_id UUID,
    email TEXT,
    first_name TEXT DEFAULT NULL,
    last_name TEXT DEFAULT NULL,
    role TEXT DEFAULT 'client',
    company_name TEXT DEFAULT NULL,
    phone TEXT DEFAULT NULL,
    metadata JSONB DEFAULT '{}'::JSONB
)
RETURNS UUID AS $$
DECLARE
    profile_id UUID;
BEGIN
    -- Insert or update profile
    INSERT INTO profiles (
        id, email, first_name, last_name, role, 
        company_name, phone, metadata, profile_complete, 
        onboarding_complete, status, created_at, updated_at
    ) VALUES (
        user_id, email, first_name, last_name, role,
        company_name, phone, metadata, false,
        false, 'active', NOW(), NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        first_name = COALESCE(EXCLUDED.first_name, profiles.first_name),
        last_name = COALESCE(EXCLUDED.last_name, profiles.last_name),
        role = COALESCE(EXCLUDED.role, profiles.role),
        company_name = COALESCE(EXCLUDED.company_name, profiles.company_name),
        phone = COALESCE(EXCLUDED.phone, profiles.phone),
        metadata = profiles.metadata || EXCLUDED.metadata,
        updated_at = NOW()
    RETURNING id INTO profile_id;

    RETURN profile_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION create_user_profile(UUID, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, JSONB) TO authenticated;

-- =====================================================
-- TESTING FUNCTIONS
-- =====================================================

-- Test the profile functions
SELECT 'Testing profile functions...' as test_status;

-- Test creating a client profile
SELECT create_user_profile(
    gen_random_uuid(),
    'test.client@example.com',
    'Test',
    'Client',
    'client',
    NULL,
    '+1234567890',
    '{"test": true}'::JSONB
) as client_profile_id;

-- Test creating an agent profile
SELECT create_user_profile(
    gen_random_uuid(),
    'test.agent@example.com',
    'Test',
    'Agent',
    'agent',
    'Test Realty Co',
    '+0987654321',
    '{"license": "ABC123"}'::JSONB
) as agent_profile_id;

-- =====================================================
-- PROFILE UPDATE FUNCTIONS
-- =====================================================

-- Function to update user profile
CREATE OR REPLACE FUNCTION update_user_profile(
    user_uuid UUID,
    profile_data JSONB
)
RETURNS BOOLEAN AS $$
DECLARE
    current_role TEXT;
BEGIN
    -- Get current role
    SELECT role INTO current_role FROM profiles WHERE id = user_uuid;
    
    IF current_role IS NULL THEN
        RAISE EXCEPTION 'Profile not found for user: %', user_uuid;
    END IF;
    
    -- Update profiles table
    UPDATE profiles SET
        first_name = COALESCE((profile_data->>'first_name')::TEXT, first_name),
        last_name = COALESCE((profile_data->>'last_name')::TEXT, last_name),
        phone = COALESCE((profile_data->>'phone')::TEXT, phone),
        company_name = CASE 
            WHEN current_role = 'agent' THEN COALESCE((profile_data->>'company_name')::TEXT, company_name)
            ELSE company_name
        END,
        company_license = CASE 
            WHEN current_role = 'agent' THEN COALESCE((profile_data->>'company_license')::TEXT, company_license)
            ELSE company_license
        END,
        metadata = COALESCE(metadata, '{}') || COALESCE(profile_data->'metadata', '{}'),
        profile_complete = COALESCE((profile_data->>'profile_complete')::BOOLEAN, profile_complete),
        status = COALESCE((profile_data->>'status')::TEXT, status),
        updated_at = NOW()
    WHERE id = user_uuid;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION update_user_profile(UUID, JSONB) TO authenticated;

-- =====================================================
-- PROFILE RETRIEVAL FUNCTIONS
-- =====================================================

-- Get comprehensive user profile information
CREATE OR REPLACE FUNCTION get_user_profile(user_id UUID)
RETURNS TABLE (
    id UUID,
    email TEXT,
    first_name TEXT,
    last_name TEXT,
    role TEXT,
    company_name TEXT,
    phone TEXT,
    profile_complete BOOLEAN,
    onboarding_complete BOOLEAN,
    status TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.email,
        p.first_name,
        p.last_name,
        p.role,
        p.company_name,
        p.phone,
        p.profile_complete,
        p.onboarding_complete,
        p.status,
        p.metadata,
        p.created_at,
        p.updated_at
    FROM profiles p
    WHERE p.id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_user_profile(UUID) TO authenticated;

-- =====================================================
-- AGENT-CLIENT RELATIONSHIP FUNCTIONS
-- =====================================================

-- Function to get agent's clients
CREATE OR REPLACE FUNCTION get_agent_clients(agent_uuid UUID)
RETURNS TABLE (
    client_id UUID,
    client_email TEXT,
    client_name TEXT,
    client_phone TEXT,
    client_type TEXT,
    budget DECIMAL(12,2),
    neighborhood_preference TEXT,
    property_types TEXT[],
    bedrooms INTEGER,
    bathrooms DECIMAL(3,1),
    move_in_date DATE,
    contact_preference TEXT,
    relationship_status TEXT,
    relationship_created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.email,
        CONCAT(p.first_name, ' ', p.last_name),
        p.phone,
        avcd.client_type,
        avcd.budget,
        avcd.neighborhood_preference,
        avcd.property_types,
        avcd.bedrooms,
        avcd.bathrooms,
        avcd.move_in_date,
        avcd.contact_preference,
        acl.status,
        acl.created_at
    FROM profiles p
    INNER JOIN agent_client_links acl ON acl.client_id = p.id
    LEFT JOIN agent_viewable_client_data avcd ON avcd.user_id = p.id
    WHERE acl.agent_id = agent_uuid
    AND p.role = 'client'
    ORDER BY acl.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_agent_clients(UUID) TO authenticated;

-- Function to get client's agents
CREATE OR REPLACE FUNCTION get_client_agents(client_uuid UUID)
RETURNS TABLE (
    agent_id UUID,
    agent_email TEXT,
    agent_name TEXT,
    agent_phone TEXT,
    company_name TEXT,
    company_license TEXT,
    relationship_status TEXT,
    relationship_created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.email,
        CONCAT(p.first_name, ' ', p.last_name),
        p.phone,
        p.company_name,
        p.company_license,
        acl.status,
        acl.created_at
    FROM profiles p
    INNER JOIN agent_client_links acl ON acl.agent_id = p.id
    WHERE acl.client_id = client_uuid
    AND p.role = 'agent'
    ORDER BY acl.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_client_agents(UUID) TO authenticated;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check if all required columns exist in profiles table
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'profiles'
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Check if functions were created successfully
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN (
    'create_user_profile',
    'update_user_profile', 
    'get_user_profile',
    'get_agent_clients',
    'get_client_agents'
);