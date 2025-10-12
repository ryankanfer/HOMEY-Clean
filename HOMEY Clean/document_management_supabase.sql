-- Document Management with Supabase Storage
-- This script enhances the documents table and creates functions for Supabase Storage integration

-- =====================================================
-- ENHANCE DOCUMENTS TABLE
-- =====================================================

-- Add missing columns to documents table if they don't exist
DO $$ 
BEGIN
    -- Add storage_path for Supabase Storage
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'documents' AND column_name = 'storage_path') THEN
        ALTER TABLE documents ADD COLUMN storage_path TEXT;
    END IF;
    
    -- Add storage_bucket for Supabase Storage bucket name
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'documents' AND column_name = 'storage_bucket') THEN
        ALTER TABLE documents ADD COLUMN storage_bucket TEXT DEFAULT 'documents';
    END IF;
    
    -- Add file_size in bytes
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'documents' AND column_name = 'file_size') THEN
        ALTER TABLE documents ADD COLUMN file_size BIGINT;
    END IF;
    
    -- Add mime_type
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'documents' AND column_name = 'mime_type') THEN
        ALTER TABLE documents ADD COLUMN mime_type TEXT;
    END IF;
    
    -- Add document_category
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'documents' AND column_name = 'document_category') THEN
        ALTER TABLE documents ADD COLUMN document_category TEXT CHECK (
            document_category IN (
                'property_listing', 'contract', 'inspection_report', 
                'financial_document', 'identification', 'insurance', 
                'mortgage_document', 'legal_document', 'photo', 'other'
            )
        );
    END IF;
    
    -- Add document_status
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'documents' AND column_name = 'document_status') THEN
        ALTER TABLE documents ADD COLUMN document_status TEXT CHECK (
            document_status IN ('uploaded', 'processing', 'processed', 'error', 'archived')
        ) DEFAULT 'uploaded';
    END IF;
    
    -- Add is_public flag
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'documents' AND column_name = 'is_public') THEN
        ALTER TABLE documents ADD COLUMN is_public BOOLEAN DEFAULT FALSE;
    END IF;
    
    -- Add access_permissions JSONB for fine-grained permissions
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'documents' AND column_name = 'access_permissions') THEN
        ALTER TABLE documents ADD COLUMN access_permissions JSONB DEFAULT '{}';
    END IF;
    
    -- Add metadata JSONB for additional document information
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'documents' AND column_name = 'metadata') THEN
        ALTER TABLE documents ADD COLUMN metadata JSONB DEFAULT '{}';
    END IF;
    
    -- Add thumbnail_path for document previews
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'documents' AND column_name = 'thumbnail_path') THEN
        ALTER TABLE documents ADD COLUMN thumbnail_path TEXT;
    END IF;
    
    -- Add download_count for analytics
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'documents' AND column_name = 'download_count') THEN
        ALTER TABLE documents ADD COLUMN download_count INTEGER DEFAULT 0;
    END IF;
    
    -- Add last_accessed_at for analytics
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'documents' AND column_name = 'last_accessed_at') THEN
        ALTER TABLE documents ADD COLUMN last_accessed_at TIMESTAMP WITH TIME ZONE;
    END IF;
END $$;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_documents_user_id ON documents(user_id);
CREATE INDEX IF NOT EXISTS idx_documents_category ON documents(document_category);
CREATE INDEX IF NOT EXISTS idx_documents_status ON documents(document_status);
CREATE INDEX IF NOT EXISTS idx_documents_storage_path ON documents(storage_path);
CREATE INDEX IF NOT EXISTS idx_documents_created_at ON documents(created_at);
CREATE INDEX IF NOT EXISTS idx_documents_is_public ON documents(is_public);

-- =====================================================
-- DOCUMENT ACCESS LOG TABLE
-- =====================================================

-- Create table to track document access
CREATE TABLE IF NOT EXISTS document_access_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID REFERENCES documents(id) NOT NULL,
    accessed_by UUID REFERENCES profiles(id) NOT NULL,
    access_type TEXT CHECK (access_type IN ('view', 'download', 'share', 'delete')) NOT NULL,
    ip_address INET,
    user_agent TEXT,
    accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'
);

-- Enable RLS on document_access_log table
ALTER TABLE document_access_log ENABLE ROW LEVEL SECURITY;

-- Users can view access logs for their own documents
CREATE POLICY "users_view_own_document_access" ON document_access_log
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM documents d
            WHERE d.id = document_access_log.document_id
            AND d.user_id = auth.uid()
        )
    );

-- Users can view their own access history
CREATE POLICY "users_view_own_access_history" ON document_access_log
    FOR SELECT
    USING (auth.uid() = accessed_by);

-- System can insert access logs
CREATE POLICY "system_insert_access_logs" ON document_access_log
    FOR INSERT
    WITH CHECK (TRUE);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_document_access_log_document_id ON document_access_log(document_id);
CREATE INDEX IF NOT EXISTS idx_document_access_log_accessed_by ON document_access_log(accessed_by);
CREATE INDEX IF NOT EXISTS idx_document_access_log_accessed_at ON document_access_log(accessed_at);
CREATE INDEX IF NOT EXISTS idx_document_access_log_access_type ON document_access_log(access_type);

-- =====================================================
-- DOCUMENT SHARING TABLE
-- =====================================================

-- Create table for document sharing
CREATE TABLE IF NOT EXISTS document_shares (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID REFERENCES documents(id) NOT NULL,
    shared_by UUID REFERENCES profiles(id) NOT NULL,
    shared_with UUID REFERENCES profiles(id),
    shared_with_email TEXT,
    share_token TEXT UNIQUE,
    permissions JSONB DEFAULT '{"view": true, "download": false}',
    expires_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT share_target_check CHECK (
        (shared_with IS NOT NULL) OR (shared_with_email IS NOT NULL) OR (share_token IS NOT NULL)
    )
);

-- Enable RLS on document_shares table
ALTER TABLE document_shares ENABLE ROW LEVEL SECURITY;

-- Users can manage shares for their own documents
CREATE POLICY "users_manage_own_document_shares" ON document_shares
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM documents d
            WHERE d.id = document_shares.document_id
            AND d.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM documents d
            WHERE d.id = document_shares.document_id
            AND d.user_id = auth.uid()
        )
    );

-- Users can view shares directed to them
CREATE POLICY "users_view_shared_documents" ON document_shares
    FOR SELECT
    USING (
        auth.uid() = shared_with OR
        (shared_with_email IS NOT NULL AND 
         EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND email = shared_with_email))
    );

-- Public access for share tokens (anonymous users)
CREATE POLICY "public_access_share_tokens" ON document_shares
    FOR SELECT
    USING (share_token IS NOT NULL AND is_active = TRUE AND (expires_at IS NULL OR expires_at > NOW()));

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_document_shares_document_id ON document_shares(document_id);
CREATE INDEX IF NOT EXISTS idx_document_shares_shared_by ON document_shares(shared_by);
CREATE INDEX IF NOT EXISTS idx_document_shares_shared_with ON document_shares(shared_with);
CREATE INDEX IF NOT EXISTS idx_document_shares_token ON document_shares(share_token);
CREATE INDEX IF NOT EXISTS idx_document_shares_active ON document_shares(is_active);

-- Create updated_at trigger
CREATE TRIGGER update_document_shares_updated_at 
    BEFORE UPDATE ON document_shares 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- DOCUMENT MANAGEMENT FUNCTIONS
-- =====================================================

-- Function to create document record
CREATE OR REPLACE FUNCTION create_document_record(
    user_uuid UUID,
    file_name TEXT,
    storage_path_input TEXT,
    storage_bucket_input TEXT DEFAULT 'documents',
    file_size_input BIGINT DEFAULT NULL,
    mime_type_input TEXT DEFAULT NULL,
    document_category_input TEXT DEFAULT 'other',
    is_public_input BOOLEAN DEFAULT FALSE,
    document_metadata JSONB DEFAULT '{}'
)
RETURNS UUID AS $$
DECLARE
    document_id UUID;
BEGIN
    INSERT INTO documents (
        user_id,
        file_name,
        storage_path,
        storage_bucket,
        file_size,
        mime_type,
        document_category,
        document_status,
        is_public,
        metadata,
        created_at,
        updated_at
    ) VALUES (
        user_uuid,
        file_name,
        storage_path_input,
        storage_bucket_input,
        file_size_input,
        mime_type_input,
        document_category_input,
        'uploaded',
        is_public_input,
        document_metadata,
        NOW(),
        NOW()
    ) RETURNING id INTO document_id;
    
    RETURN document_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION create_document_record(UUID, TEXT, TEXT, TEXT, BIGINT, TEXT, TEXT, BOOLEAN, JSONB) TO authenticated;

-- Function to get user documents
CREATE OR REPLACE FUNCTION get_user_documents(
    user_uuid UUID,
    category_filter TEXT DEFAULT NULL,
    limit_count INTEGER DEFAULT 50,
    offset_count INTEGER DEFAULT 0
)
RETURNS TABLE (
    document_id UUID,
    file_name TEXT,
    storage_path TEXT,
    storage_bucket TEXT,
    file_size BIGINT,
    mime_type TEXT,
    document_category TEXT,
    document_status TEXT,
    is_public BOOLEAN,
    download_count INTEGER,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    last_accessed_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.id,
        d.file_name,
        d.storage_path,
        d.storage_bucket,
        d.file_size,
        d.mime_type,
        d.document_category,
        d.document_status,
        d.is_public,
        d.download_count,
        d.created_at,
        d.updated_at,
        d.last_accessed_at,
        d.metadata
    FROM documents d
    WHERE d.user_id = user_uuid
    AND (category_filter IS NULL OR d.document_category = category_filter)
    ORDER BY d.created_at DESC
    LIMIT limit_count
    OFFSET offset_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_user_documents(UUID, TEXT, INTEGER, INTEGER) TO authenticated;

-- Function to get accessible documents (including shared)
CREATE OR REPLACE FUNCTION get_accessible_documents(
    user_uuid UUID,
    include_shared BOOLEAN DEFAULT TRUE
)
RETURNS TABLE (
    document_id UUID,
    file_name TEXT,
    storage_path TEXT,
    storage_bucket TEXT,
    file_size BIGINT,
    mime_type TEXT,
    document_category TEXT,
    document_status TEXT,
    is_public BOOLEAN,
    owner_id UUID,
    owner_name TEXT,
    is_shared BOOLEAN,
    share_permissions JSONB,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    -- User's own documents
    SELECT 
        d.id,
        d.file_name,
        d.storage_path,
        d.storage_bucket,
        d.file_size,
        d.mime_type,
        d.document_category,
        d.document_status,
        d.is_public,
        d.user_id,
        CONCAT(p.first_name, ' ', p.last_name),
        FALSE,
        '{}'::JSONB,
        d.created_at
    FROM documents d
    INNER JOIN profiles p ON p.id = d.user_id
    WHERE d.user_id = user_uuid
    
    UNION ALL
    
    -- Shared documents (if include_shared is true)
    SELECT 
        d.id,
        d.file_name,
        d.storage_path,
        d.storage_bucket,
        d.file_size,
        d.mime_type,
        d.document_category,
        d.document_status,
        d.is_public,
        d.user_id,
        CONCAT(p.first_name, ' ', p.last_name),
        TRUE,
        ds.permissions,
        d.created_at
    FROM documents d
    INNER JOIN profiles p ON p.id = d.user_id
    INNER JOIN document_shares ds ON ds.document_id = d.id
    WHERE include_shared = TRUE
    AND ds.is_active = TRUE
    AND (ds.expires_at IS NULL OR ds.expires_at > NOW())
    AND (ds.shared_with = user_uuid OR 
         (ds.shared_with_email IS NOT NULL AND 
          EXISTS (SELECT 1 FROM profiles WHERE id = user_uuid AND email = ds.shared_with_email)))
    
    ORDER BY created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_accessible_documents(UUID, BOOLEAN) TO authenticated;

-- Function to share document
CREATE OR REPLACE FUNCTION share_document(
    document_uuid UUID,
    shared_by_uuid UUID,
    shared_with_uuid UUID DEFAULT NULL,
    shared_with_email_input TEXT DEFAULT NULL,
    share_permissions JSONB DEFAULT '{"view": true, "download": false}',
    expires_in_hours INTEGER DEFAULT NULL
)
RETURNS TABLE (
    share_id UUID,
    share_token TEXT,
    expires_at TIMESTAMP WITH TIME ZONE
) AS $$
DECLARE
    new_share_id UUID;
    new_share_token TEXT;
    expiry_time TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Verify user owns the document
    IF NOT EXISTS (SELECT 1 FROM documents WHERE id = document_uuid AND user_id = shared_by_uuid) THEN
        RAISE EXCEPTION 'Document not found or access denied';
    END IF;
    
    -- Generate share token if sharing publicly
    IF shared_with_uuid IS NULL AND shared_with_email_input IS NULL THEN
        new_share_token := encode(gen_random_bytes(32), 'base64url');
    END IF;
    
    -- Calculate expiry time
    IF expires_in_hours IS NOT NULL THEN
        expiry_time := NOW() + (expires_in_hours || ' hours')::INTERVAL;
    END IF;
    
    -- Insert share record
    INSERT INTO document_shares (
        document_id,
        shared_by,
        shared_with,
        shared_with_email,
        share_token,
        permissions,
        expires_at
    ) VALUES (
        document_uuid,
        shared_by_uuid,
        shared_with_uuid,
        shared_with_email_input,
        new_share_token,
        share_permissions,
        expiry_time
    ) RETURNING id INTO new_share_id;
    
    RETURN QUERY
    SELECT 
        new_share_id,
        new_share_token,
        expiry_time;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION share_document(UUID, UUID, UUID, TEXT, JSONB, INTEGER) TO authenticated;

-- Function to log document access
CREATE OR REPLACE FUNCTION log_document_access(
    document_uuid UUID,
    accessed_by_uuid UUID,
    access_type_input TEXT,
    ip_address_input INET DEFAULT NULL,
    user_agent_input TEXT DEFAULT NULL,
    access_metadata JSONB DEFAULT '{}'
)
RETURNS BOOLEAN AS $$
BEGIN
    -- Insert access log
    INSERT INTO document_access_log (
        document_id,
        accessed_by,
        access_type,
        ip_address,
        user_agent,
        metadata
    ) VALUES (
        document_uuid,
        accessed_by_uuid,
        access_type_input,
        ip_address_input,
        user_agent_input,
        access_metadata
    );
    
    -- Update document statistics
    UPDATE documents
    SET 
        download_count = CASE 
            WHEN access_type_input = 'download' THEN download_count + 1
            ELSE download_count
        END,
        last_accessed_at = NOW()
    WHERE id = document_uuid;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION log_document_access(UUID, UUID, TEXT, INET, TEXT, JSONB) TO authenticated;

-- Function to get document access analytics
CREATE OR REPLACE FUNCTION get_document_analytics(
    user_uuid UUID,
    days_back INTEGER DEFAULT 30
)
RETURNS TABLE (
    total_documents INTEGER,
    total_downloads INTEGER,
    total_views INTEGER,
    most_accessed_document JSONB,
    recent_activity JSONB,
    storage_usage BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*)::INTEGER FROM documents WHERE user_id = user_uuid),
        (SELECT COALESCE(SUM(download_count), 0)::INTEGER FROM documents WHERE user_id = user_uuid),
        (SELECT COUNT(*)::INTEGER FROM document_access_log dal 
         INNER JOIN documents d ON d.id = dal.document_id 
         WHERE d.user_id = user_uuid AND dal.access_type = 'view'),
        (SELECT jsonb_build_object(
            'document_id', d.id,
            'file_name', d.file_name,
            'access_count', COUNT(dal.id)
        ) FROM documents d
         LEFT JOIN document_access_log dal ON dal.document_id = d.id
         WHERE d.user_id = user_uuid
         GROUP BY d.id, d.file_name
         ORDER BY COUNT(dal.id) DESC
         LIMIT 1),
        (SELECT jsonb_agg(
            jsonb_build_object(
                'date', DATE(dal.accessed_at),
                'views', COUNT(*) FILTER (WHERE dal.access_type = 'view'),
                'downloads', COUNT(*) FILTER (WHERE dal.access_type = 'download')
            )
        ) FROM document_access_log dal 
         INNER JOIN documents d ON d.id = dal.document_id 
         WHERE d.user_id = user_uuid 
         AND dal.accessed_at >= NOW() - (days_back || ' days')::INTERVAL
         GROUP BY DATE(dal.accessed_at)
         ORDER BY DATE(dal.accessed_at) DESC),
        (SELECT COALESCE(SUM(file_size), 0) FROM documents WHERE user_id = user_uuid);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_document_analytics(UUID, INTEGER) TO authenticated;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check if new columns were added to documents table
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'documents'
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Check if new tables were created successfully
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('document_access_log', 'document_shares');

-- Check if functions were created successfully
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN (
    'create_document_record',
    'get_user_documents',
    'get_accessible_documents',
    'share_document',
    'log_document_access',
    'get_document_analytics'
);