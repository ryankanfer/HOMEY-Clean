-- Agent Invitation System
-- This script creates the infrastructure for agent invitations with shareable codes/links/QR

-- =====================================================
-- AGENT INVITATION CODES TABLE
-- =====================================================

-- Create table for agent invitation codes
CREATE TABLE IF NOT EXISTS agent_invitation_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES profiles(id) NOT NULL,
    invitation_code TEXT UNIQUE NOT NULL,
    invitation_type TEXT CHECK (invitation_type IN ('code', 'link', 'qr')) DEFAULT 'code',
    max_uses INTEGER DEFAULT 1,
    current_uses INTEGER DEFAULT 0,
    expires_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT valid_agent_role CHECK (
        EXISTS (
            SELECT 1 FROM profiles p 
            WHERE p.id = agent_id AND p.role = 'agent'
        )
    )
);

-- Enable RLS on agent_invitation_codes table
ALTER TABLE agent_invitation_codes ENABLE ROW LEVEL SECURITY;

-- Agents can manage their own invitation codes
CREATE POLICY "agents_manage_own_invitations" ON agent_invitation_codes
    FOR ALL
    USING (auth.uid() = agent_id)
    WITH CHECK (auth.uid() = agent_id);

-- Anyone can view active invitation codes for joining (read-only for validation)
CREATE POLICY "public_view_active_invitations" ON agent_invitation_codes
    FOR SELECT
    USING (is_active = TRUE AND (expires_at IS NULL OR expires_at > NOW()));

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_agent_invitation_codes_agent_id ON agent_invitation_codes(agent_id);
CREATE INDEX IF NOT EXISTS idx_agent_invitation_codes_code ON agent_invitation_codes(invitation_code);
CREATE INDEX IF NOT EXISTS idx_agent_invitation_codes_active ON agent_invitation_codes(is_active);
CREATE INDEX IF NOT EXISTS idx_agent_invitation_codes_expires ON agent_invitation_codes(expires_at);

-- Create updated_at trigger
CREATE TRIGGER update_agent_invitation_codes_updated_at 
    BEFORE UPDATE ON agent_invitation_codes 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- INVITATION USAGE TRACKING TABLE
-- =====================================================

-- Create table to track invitation usage
CREATE TABLE IF NOT EXISTS invitation_usage_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invitation_id UUID REFERENCES agent_invitation_codes(id) NOT NULL,
    client_id UUID REFERENCES profiles(id),
    client_email TEXT,
    ip_address INET,
    user_agent TEXT,
    used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    success BOOLEAN DEFAULT FALSE,
    error_message TEXT,
    metadata JSONB DEFAULT '{}'
);

-- Enable RLS on invitation_usage_log table
ALTER TABLE invitation_usage_log ENABLE ROW LEVEL SECURITY;

-- Agents can view usage logs for their invitations
CREATE POLICY "agents_view_invitation_usage" ON invitation_usage_log
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM agent_invitation_codes aic
            WHERE aic.id = invitation_usage_log.invitation_id
            AND aic.agent_id = auth.uid()
        )
    );

-- Clients can view their own usage logs
CREATE POLICY "clients_view_own_usage" ON invitation_usage_log
    FOR SELECT
    USING (auth.uid() = client_id);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_invitation_usage_log_invitation_id ON invitation_usage_log(invitation_id);
CREATE INDEX IF NOT EXISTS idx_invitation_usage_log_client_id ON invitation_usage_log(client_id);
CREATE INDEX IF NOT EXISTS idx_invitation_usage_log_used_at ON invitation_usage_log(used_at);

-- =====================================================
-- INVITATION SYSTEM FUNCTIONS
-- =====================================================

-- Function to generate a unique invitation code
CREATE OR REPLACE FUNCTION generate_invitation_code()
RETURNS TEXT AS $$
DECLARE
    code TEXT;
    exists_check BOOLEAN;
BEGIN
    LOOP
        -- Generate 8-character alphanumeric code
        code := upper(substring(md5(random()::text) from 1 for 8));
        
        -- Check if code already exists
        SELECT EXISTS(SELECT 1 FROM agent_invitation_codes WHERE invitation_code = code) INTO exists_check;
        
        -- Exit loop if code is unique
        IF NOT exists_check THEN
            EXIT;
        END IF;
    END LOOP;
    
    RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Function to create agent invitation
CREATE OR REPLACE FUNCTION create_agent_invitation(
    agent_uuid UUID,
    invitation_type TEXT DEFAULT 'code',
    max_uses INTEGER DEFAULT 1,
    expires_in_hours INTEGER DEFAULT 168, -- 7 days default
    invitation_metadata JSONB DEFAULT '{}'
)
RETURNS TABLE (
    invitation_id UUID,
    invitation_code TEXT,
    invitation_url TEXT,
    qr_data TEXT,
    expires_at TIMESTAMP WITH TIME ZONE
) AS $$
DECLARE
    new_code TEXT;
    new_invitation_id UUID;
    expiry_time TIMESTAMP WITH TIME ZONE;
    base_url TEXT := 'https://your-app-domain.com/join/'; -- Update with your actual domain
BEGIN
    -- Verify agent exists and has correct role
    IF NOT EXISTS (SELECT 1 FROM profiles WHERE id = agent_uuid AND role = 'agent') THEN
        RAISE EXCEPTION 'Invalid agent ID or user is not an agent';
    END IF;
    
    -- Generate unique code
    new_code := generate_invitation_code();
    
    -- Calculate expiry time
    expiry_time := NOW() + (expires_in_hours || ' hours')::INTERVAL;
    
    -- Insert invitation
    INSERT INTO agent_invitation_codes (
        agent_id,
        invitation_code,
        invitation_type,
        max_uses,
        expires_at,
        metadata
    ) VALUES (
        agent_uuid,
        new_code,
        invitation_type,
        max_uses,
        expiry_time,
        invitation_metadata
    ) RETURNING id INTO new_invitation_id;
    
    -- Return invitation details
    RETURN QUERY
    SELECT 
        new_invitation_id,
        new_code,
        base_url || new_code,
        jsonb_build_object(
            'type', 'agent_invitation',
            'code', new_code,
            'url', base_url || new_code,
            'agent_id', agent_uuid,
            'expires_at', expiry_time
        )::TEXT,
        expiry_time;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION create_agent_invitation(UUID, TEXT, INTEGER, INTEGER, JSONB) TO authenticated;

-- Function to validate and use invitation code
CREATE OR REPLACE FUNCTION use_invitation_code(
    invitation_code_input TEXT,
    client_uuid UUID DEFAULT NULL,
    client_email_input TEXT DEFAULT NULL,
    client_ip INET DEFAULT NULL,
    client_user_agent TEXT DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    agent_id UUID,
    agent_name TEXT,
    agent_email TEXT,
    company_name TEXT,
    error_message TEXT,
    invitation_id UUID
) AS $$
DECLARE
    invitation_record RECORD;
    agent_record RECORD;
    usage_log_id UUID;
    error_msg TEXT := NULL;
    is_success BOOLEAN := FALSE;
BEGIN
    -- Find the invitation
    SELECT * INTO invitation_record
    FROM agent_invitation_codes
    WHERE invitation_code = invitation_code_input
    AND is_active = TRUE;
    
    -- Check if invitation exists
    IF invitation_record IS NULL THEN
        error_msg := 'Invalid or inactive invitation code';
    -- Check if invitation has expired
    ELSIF invitation_record.expires_at IS NOT NULL AND invitation_record.expires_at < NOW() THEN
        error_msg := 'Invitation code has expired';
    -- Check if invitation has reached max uses
    ELSIF invitation_record.current_uses >= invitation_record.max_uses THEN
        error_msg := 'Invitation code has reached maximum uses';
    ELSE
        -- Get agent information
        SELECT * INTO agent_record
        FROM profiles
        WHERE id = invitation_record.agent_id;
        
        -- Update invitation usage count
        UPDATE agent_invitation_codes
        SET current_uses = current_uses + 1,
            updated_at = NOW()
        WHERE id = invitation_record.id;
        
        -- Create agent-client link if client_uuid is provided
        IF client_uuid IS NOT NULL THEN
            INSERT INTO agent_client_links (
                agent_id,
                client_id,
                status,
                invitation_code_used,
                created_at
            ) VALUES (
                invitation_record.agent_id,
                client_uuid,
                'active',
                invitation_code_input,
                NOW()
            ) ON CONFLICT (agent_id, client_id) DO UPDATE SET
                status = 'active',
                invitation_code_used = invitation_code_input,
                updated_at = NOW();
        END IF;
        
        is_success := TRUE;
    END IF;
    
    -- Log the usage attempt
    INSERT INTO invitation_usage_log (
        invitation_id,
        client_id,
        client_email,
        ip_address,
        user_agent,
        success,
        error_message
    ) VALUES (
        invitation_record.id,
        client_uuid,
        client_email_input,
        client_ip,
        client_user_agent,
        is_success,
        error_msg
    ) RETURNING id INTO usage_log_id;
    
    -- Return result
    RETURN QUERY
    SELECT 
        is_success,
        CASE WHEN is_success THEN agent_record.id ELSE NULL END,
        CASE WHEN is_success THEN CONCAT(agent_record.first_name, ' ', agent_record.last_name) ELSE NULL END,
        CASE WHEN is_success THEN agent_record.email ELSE NULL END,
        CASE WHEN is_success THEN agent_record.company_name ELSE NULL END,
        error_msg,
        invitation_record.id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated and anonymous users
GRANT EXECUTE ON FUNCTION use_invitation_code(TEXT, UUID, TEXT, INET, TEXT) TO authenticated, anon;

-- Function to get agent's invitation codes
CREATE OR REPLACE FUNCTION get_agent_invitations(agent_uuid UUID)
RETURNS TABLE (
    invitation_id UUID,
    invitation_code TEXT,
    invitation_type TEXT,
    max_uses INTEGER,
    current_uses INTEGER,
    is_active BOOLEAN,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE,
    invitation_url TEXT,
    usage_count INTEGER
) AS $$
DECLARE
    base_url TEXT := 'https://your-app-domain.com/join/'; -- Update with your actual domain
BEGIN
    RETURN QUERY
    SELECT 
        aic.id,
        aic.invitation_code,
        aic.invitation_type,
        aic.max_uses,
        aic.current_uses,
        aic.is_active,
        aic.expires_at,
        aic.created_at,
        base_url || aic.invitation_code,
        (SELECT COUNT(*)::INTEGER FROM invitation_usage_log iul WHERE iul.invitation_id = aic.id)
    FROM agent_invitation_codes aic
    WHERE aic.agent_id = agent_uuid
    ORDER BY aic.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_agent_invitations(UUID) TO authenticated;

-- Function to deactivate invitation code
CREATE OR REPLACE FUNCTION deactivate_invitation_code(
    invitation_code_input TEXT,
    agent_uuid UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    updated_rows INTEGER;
BEGIN
    UPDATE agent_invitation_codes
    SET is_active = FALSE,
        updated_at = NOW()
    WHERE invitation_code = invitation_code_input
    AND agent_id = agent_uuid;
    
    GET DIAGNOSTICS updated_rows = ROW_COUNT;
    
    RETURN updated_rows > 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION deactivate_invitation_code(TEXT, UUID) TO authenticated;

-- =====================================================
-- INVITATION ANALYTICS FUNCTIONS
-- =====================================================

-- Function to get invitation usage statistics
CREATE OR REPLACE FUNCTION get_invitation_analytics(
    agent_uuid UUID,
    days_back INTEGER DEFAULT 30
)
RETURNS TABLE (
    total_invitations INTEGER,
    active_invitations INTEGER,
    total_uses INTEGER,
    successful_uses INTEGER,
    failed_uses INTEGER,
    conversion_rate DECIMAL(5,2),
    recent_activity JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*)::INTEGER FROM agent_invitation_codes WHERE agent_id = agent_uuid),
        (SELECT COUNT(*)::INTEGER FROM agent_invitation_codes WHERE agent_id = agent_uuid AND is_active = TRUE),
        (SELECT COUNT(*)::INTEGER FROM invitation_usage_log iul 
         INNER JOIN agent_invitation_codes aic ON aic.id = iul.invitation_id 
         WHERE aic.agent_id = agent_uuid),
        (SELECT COUNT(*)::INTEGER FROM invitation_usage_log iul 
         INNER JOIN agent_invitation_codes aic ON aic.id = iul.invitation_id 
         WHERE aic.agent_id = agent_uuid AND iul.success = TRUE),
        (SELECT COUNT(*)::INTEGER FROM invitation_usage_log iul 
         INNER JOIN agent_invitation_codes aic ON aic.id = iul.invitation_id 
         WHERE aic.agent_id = agent_uuid AND iul.success = FALSE),
        CASE 
            WHEN (SELECT COUNT(*) FROM invitation_usage_log iul 
                  INNER JOIN agent_invitation_codes aic ON aic.id = iul.invitation_id 
                  WHERE aic.agent_id = agent_uuid) > 0 
            THEN 
                ROUND(
                    (SELECT COUNT(*)::DECIMAL FROM invitation_usage_log iul 
                     INNER JOIN agent_invitation_codes aic ON aic.id = iul.invitation_id 
                     WHERE aic.agent_id = agent_uuid AND iul.success = TRUE) * 100.0 /
                    (SELECT COUNT(*) FROM invitation_usage_log iul 
                     INNER JOIN agent_invitation_codes aic ON aic.id = iul.invitation_id 
                     WHERE aic.agent_id = agent_uuid), 2
                )
            ELSE 0.00
        END,
        (SELECT jsonb_agg(
            jsonb_build_object(
                'date', DATE(iul.used_at),
                'uses', COUNT(*),
                'successful', COUNT(*) FILTER (WHERE iul.success = TRUE)
            )
        ) FROM invitation_usage_log iul 
         INNER JOIN agent_invitation_codes aic ON aic.id = iul.invitation_id 
         WHERE aic.agent_id = agent_uuid 
         AND iul.used_at >= NOW() - (days_back || ' days')::INTERVAL
         GROUP BY DATE(iul.used_at)
         ORDER BY DATE(iul.used_at) DESC);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_invitation_analytics(UUID, INTEGER) TO authenticated;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check if tables were created successfully
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('agent_invitation_codes', 'invitation_usage_log');

-- Check if RLS is enabled
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('agent_invitation_codes', 'invitation_usage_log');

-- Check if functions were created successfully
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN (
    'generate_invitation_code',
    'create_agent_invitation',
    'use_invitation_code',
    'get_agent_invitations',
    'deactivate_invitation_code',
    'get_invitation_analytics'
);