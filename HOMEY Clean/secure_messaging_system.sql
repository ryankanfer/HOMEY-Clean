-- Secure Messaging System
-- This script enhances the messages table and creates functions for secure messaging

-- =====================================================
-- ENHANCE MESSAGES TABLE
-- =====================================================

-- Add missing columns to messages table if they don't exist
DO $$ 
BEGIN
    -- Add message_type for different types of messages
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'messages' AND column_name = 'message_type') THEN
        ALTER TABLE messages ADD COLUMN message_type TEXT CHECK (
            message_type IN ('text', 'image', 'document', 'system', 'notification', 'property_update')
        ) DEFAULT 'text';
    END IF;
    
    -- Add message_status for delivery tracking
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'messages' AND column_name = 'message_status') THEN
        ALTER TABLE messages ADD COLUMN message_status TEXT CHECK (
            message_status IN ('sent', 'delivered', 'read', 'failed')
        ) DEFAULT 'sent';
    END IF;
    
    -- Add thread_id for message threading
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'messages' AND column_name = 'thread_id') THEN
        ALTER TABLE messages ADD COLUMN thread_id UUID;
    END IF;
    
    -- Add reply_to_id for message replies
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'messages' AND column_name = 'reply_to_id') THEN
        ALTER TABLE messages ADD COLUMN reply_to_id UUID REFERENCES messages(id);
    END IF;
    
    -- Add attachments JSONB for file attachments
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'messages' AND column_name = 'attachments') THEN
        ALTER TABLE messages ADD COLUMN attachments JSONB DEFAULT '[]';
    END IF;
    
    -- Add metadata JSONB for additional message data
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'messages' AND column_name = 'metadata') THEN
        ALTER TABLE messages ADD COLUMN metadata JSONB DEFAULT '{}';
    END IF;
    
    -- Add is_encrypted flag
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'messages' AND column_name = 'is_encrypted') THEN
        ALTER TABLE messages ADD COLUMN is_encrypted BOOLEAN DEFAULT FALSE;
    END IF;
    
    -- Add read_at timestamp
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'messages' AND column_name = 'read_at') THEN
        ALTER TABLE messages ADD COLUMN read_at TIMESTAMP WITH TIME ZONE;
    END IF;
    
    -- Add delivered_at timestamp
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'messages' AND column_name = 'delivered_at') THEN
        ALTER TABLE messages ADD COLUMN delivered_at TIMESTAMP WITH TIME ZONE;
    END IF;
    
    -- Add priority level
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'messages' AND column_name = 'priority') THEN
        ALTER TABLE messages ADD COLUMN priority TEXT CHECK (
            priority IN ('low', 'normal', 'high', 'urgent')
        ) DEFAULT 'normal';
    END IF;
END $$;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_recipient_id ON messages(recipient_id);
CREATE INDEX IF NOT EXISTS idx_messages_thread_id ON messages(thread_id);
CREATE INDEX IF NOT EXISTS idx_messages_reply_to_id ON messages(reply_to_id);
CREATE INDEX IF NOT EXISTS idx_messages_message_type ON messages(message_type);
CREATE INDEX IF NOT EXISTS idx_messages_message_status ON messages(message_status);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);
CREATE INDEX IF NOT EXISTS idx_messages_read_at ON messages(read_at);
CREATE INDEX IF NOT EXISTS idx_messages_priority ON messages(priority);

-- =====================================================
-- MESSAGE THREADS TABLE
-- =====================================================

-- Create table for message threads
CREATE TABLE IF NOT EXISTS message_threads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT,
    participants UUID[] NOT NULL,
    thread_type TEXT CHECK (thread_type IN ('direct', 'group', 'system')) DEFAULT 'direct',
    created_by UUID REFERENCES profiles(id) NOT NULL,
    last_message_id UUID REFERENCES messages(id),
    last_message_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT participants_not_empty CHECK (array_length(participants, 1) > 0)
);

-- Enable RLS on message_threads table
ALTER TABLE message_threads ENABLE ROW LEVEL SECURITY;

-- Users can view threads they participate in
CREATE POLICY "users_view_participating_threads" ON message_threads
    FOR SELECT
    USING (auth.uid() = ANY(participants));

-- Users can create threads
CREATE POLICY "users_create_threads" ON message_threads
    FOR INSERT
    WITH CHECK (auth.uid() = created_by AND auth.uid() = ANY(participants));

-- Users can update threads they created or participate in
CREATE POLICY "users_update_participating_threads" ON message_threads
    FOR UPDATE
    USING (auth.uid() = created_by OR auth.uid() = ANY(participants))
    WITH CHECK (auth.uid() = created_by OR auth.uid() = ANY(participants));

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_message_threads_participants ON message_threads USING GIN(participants);
CREATE INDEX IF NOT EXISTS idx_message_threads_created_by ON message_threads(created_by);
CREATE INDEX IF NOT EXISTS idx_message_threads_last_message_at ON message_threads(last_message_at);
CREATE INDEX IF NOT EXISTS idx_message_threads_thread_type ON message_threads(thread_type);
CREATE INDEX IF NOT EXISTS idx_message_threads_is_active ON message_threads(is_active);

-- Create updated_at trigger
CREATE TRIGGER update_message_threads_updated_at 
    BEFORE UPDATE ON message_threads 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- MESSAGE READ RECEIPTS TABLE
-- =====================================================

-- Create table for message read receipts
CREATE TABLE IF NOT EXISTS message_read_receipts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID REFERENCES messages(id) NOT NULL,
    user_id UUID REFERENCES profiles(id) NOT NULL,
    read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(message_id, user_id)
);

-- Enable RLS on message_read_receipts table
ALTER TABLE message_read_receipts ENABLE ROW LEVEL SECURITY;

-- Users can manage their own read receipts
CREATE POLICY "users_manage_own_read_receipts" ON message_read_receipts
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Message senders can view read receipts for their messages
CREATE POLICY "senders_view_message_receipts" ON message_read_receipts
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM messages m
            WHERE m.id = message_read_receipts.message_id
            AND m.sender_id = auth.uid()
        )
    );

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_message_read_receipts_message_id ON message_read_receipts(message_id);
CREATE INDEX IF NOT EXISTS idx_message_read_receipts_user_id ON message_read_receipts(user_id);
CREATE INDEX IF NOT EXISTS idx_message_read_receipts_read_at ON message_read_receipts(read_at);

-- =====================================================
-- MESSAGE REACTIONS TABLE
-- =====================================================

-- Create table for message reactions
CREATE TABLE IF NOT EXISTS message_reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID REFERENCES messages(id) NOT NULL,
    user_id UUID REFERENCES profiles(id) NOT NULL,
    reaction_type TEXT NOT NULL, -- emoji or reaction type
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(message_id, user_id, reaction_type)
);

-- Enable RLS on message_reactions table
ALTER TABLE message_reactions ENABLE ROW LEVEL SECURITY;

-- Users can manage their own reactions
CREATE POLICY "users_manage_own_reactions" ON message_reactions
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Users can view reactions on messages they can see
CREATE POLICY "users_view_message_reactions" ON message_reactions
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM messages m
            WHERE m.id = message_reactions.message_id
            AND (m.sender_id = auth.uid() OR m.recipient_id = auth.uid())
        )
    );

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_message_reactions_message_id ON message_reactions(message_id);
CREATE INDEX IF NOT EXISTS idx_message_reactions_user_id ON message_reactions(user_id);
CREATE INDEX IF NOT EXISTS idx_message_reactions_type ON message_reactions(reaction_type);

-- =====================================================
-- MESSAGING FUNCTIONS
-- =====================================================

-- Function to send a message
CREATE OR REPLACE FUNCTION send_message(
    sender_uuid UUID,
    recipient_uuid UUID,
    message_content TEXT,
    message_type_input TEXT DEFAULT 'text',
    thread_uuid UUID DEFAULT NULL,
    reply_to_uuid UUID DEFAULT NULL,
    attachments_input JSONB DEFAULT '[]',
    priority_input TEXT DEFAULT 'normal',
    message_metadata JSONB DEFAULT '{}'
)
RETURNS TABLE (
    message_id UUID,
    thread_id UUID,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
DECLARE
    new_message_id UUID;
    new_thread_id UUID;
    thread_participants UUID[];
BEGIN
    -- Verify sender exists
    IF NOT EXISTS (SELECT 1 FROM profiles WHERE id = sender_uuid) THEN
        RAISE EXCEPTION 'Sender not found';
    END IF;
    
    -- Verify recipient exists
    IF NOT EXISTS (SELECT 1 FROM profiles WHERE id = recipient_uuid) THEN
        RAISE EXCEPTION 'Recipient not found';
    END IF;
    
    -- Verify agent-client relationship exists
    IF NOT EXISTS (
        SELECT 1 FROM agent_client_links acl
        WHERE (acl.agent_id = sender_uuid AND acl.client_id = recipient_uuid)
        OR (acl.agent_id = recipient_uuid AND acl.client_id = sender_uuid)
        AND acl.status = 'active'
    ) THEN
        RAISE EXCEPTION 'No active relationship between sender and recipient';
    END IF;
    
    -- Handle thread creation or retrieval
    IF thread_uuid IS NULL THEN
        -- Create new thread or find existing direct thread
        SELECT id INTO new_thread_id
        FROM message_threads
        WHERE thread_type = 'direct'
        AND participants @> ARRAY[sender_uuid, recipient_uuid]
        AND array_length(participants, 1) = 2
        LIMIT 1;
        
        -- Create new thread if none exists
        IF new_thread_id IS NULL THEN
            thread_participants := ARRAY[sender_uuid, recipient_uuid];
            
            INSERT INTO message_threads (
                participants,
                thread_type,
                created_by
            ) VALUES (
                thread_participants,
                'direct',
                sender_uuid
            ) RETURNING id INTO new_thread_id;
        END IF;
    ELSE
        new_thread_id := thread_uuid;
        
        -- Verify user is participant in the thread
        IF NOT EXISTS (
            SELECT 1 FROM message_threads
            WHERE id = new_thread_id
            AND sender_uuid = ANY(participants)
        ) THEN
            RAISE EXCEPTION 'Sender is not a participant in this thread';
        END IF;
    END IF;
    
    -- Insert the message
    INSERT INTO messages (
        sender_id,
        recipient_id,
        content,
        message_type,
        message_status,
        thread_id,
        reply_to_id,
        attachments,
        priority,
        metadata,
        delivered_at
    ) VALUES (
        sender_uuid,
        recipient_uuid,
        message_content,
        message_type_input,
        'delivered',
        new_thread_id,
        reply_to_uuid,
        attachments_input,
        priority_input,
        message_metadata,
        NOW()
    ) RETURNING id, created_at INTO new_message_id, created_at;
    
    -- Update thread with last message info
    UPDATE message_threads
    SET 
        last_message_id = new_message_id,
        last_message_at = NOW(),
        updated_at = NOW()
    WHERE id = new_thread_id;
    
    RETURN QUERY
    SELECT new_message_id, new_thread_id, created_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION send_message(UUID, UUID, TEXT, TEXT, UUID, UUID, JSONB, TEXT, JSONB) TO authenticated;

-- Function to mark message as read
CREATE OR REPLACE FUNCTION mark_message_read(
    message_uuid UUID,
    reader_uuid UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    message_record RECORD;
BEGIN
    -- Get message details and verify access
    SELECT * INTO message_record
    FROM messages
    WHERE id = message_uuid
    AND (sender_id = reader_uuid OR recipient_id = reader_uuid);
    
    IF message_record IS NULL THEN
        RAISE EXCEPTION 'Message not found or access denied';
    END IF;
    
    -- Only recipients can mark messages as read
    IF message_record.recipient_id != reader_uuid THEN
        RETURN FALSE;
    END IF;
    
    -- Update message read status
    UPDATE messages
    SET 
        message_status = 'read',
        read_at = NOW()
    WHERE id = message_uuid
    AND read_at IS NULL;
    
    -- Insert read receipt
    INSERT INTO message_read_receipts (message_id, user_id)
    VALUES (message_uuid, reader_uuid)
    ON CONFLICT (message_id, user_id) DO UPDATE SET
        read_at = NOW();
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION mark_message_read(UUID, UUID) TO authenticated;

-- Function to get conversation messages
CREATE OR REPLACE FUNCTION get_conversation_messages(
    user_uuid UUID,
    other_user_uuid UUID,
    limit_count INTEGER DEFAULT 50,
    offset_count INTEGER DEFAULT 0
)
RETURNS TABLE (
    message_id UUID,
    sender_id UUID,
    sender_name TEXT,
    recipient_id UUID,
    recipient_name TEXT,
    content TEXT,
    message_type TEXT,
    message_status TEXT,
    thread_id UUID,
    reply_to_id UUID,
    attachments JSONB,
    priority TEXT,
    metadata JSONB,
    is_encrypted BOOLEAN,
    read_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE,
    reactions JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.id,
        m.sender_id,
        CONCAT(sp.first_name, ' ', sp.last_name),
        m.recipient_id,
        CONCAT(rp.first_name, ' ', rp.last_name),
        m.content,
        m.message_type,
        m.message_status,
        m.thread_id,
        m.reply_to_id,
        m.attachments,
        m.priority,
        m.metadata,
        m.is_encrypted,
        m.read_at,
        m.delivered_at,
        m.created_at,
        COALESCE(
            (SELECT jsonb_agg(
                jsonb_build_object(
                    'user_id', mr.user_id,
                    'user_name', CONCAT(mrp.first_name, ' ', mrp.last_name),
                    'reaction_type', mr.reaction_type,
                    'created_at', mr.created_at
                )
            ) FROM message_reactions mr
             INNER JOIN profiles mrp ON mrp.id = mr.user_id
             WHERE mr.message_id = m.id),
            '[]'::JSONB
        ) as reactions
    FROM messages m
    INNER JOIN profiles sp ON sp.id = m.sender_id
    INNER JOIN profiles rp ON rp.id = m.recipient_id
    WHERE ((m.sender_id = user_uuid AND m.recipient_id = other_user_uuid) OR
           (m.sender_id = other_user_uuid AND m.recipient_id = user_uuid))
    ORDER BY m.created_at DESC
    LIMIT limit_count
    OFFSET offset_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_conversation_messages(UUID, UUID, INTEGER, INTEGER) TO authenticated;

-- Function to get user's message threads
CREATE OR REPLACE FUNCTION get_user_threads(
    user_uuid UUID,
    limit_count INTEGER DEFAULT 20
)
RETURNS TABLE (
    thread_id UUID,
    title TEXT,
    thread_type TEXT,
    participants JSONB,
    last_message_content TEXT,
    last_message_sender TEXT,
    last_message_at TIMESTAMP WITH TIME ZONE,
    unread_count INTEGER,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        mt.id,
        mt.title,
        mt.thread_type,
        (SELECT jsonb_agg(
            jsonb_build_object(
                'user_id', p.id,
                'name', CONCAT(p.first_name, ' ', p.last_name),
                'email', p.email,
                'role', p.role
            )
        ) FROM profiles p WHERE p.id = ANY(mt.participants)) as participants,
        lm.content,
        CONCAT(lmp.first_name, ' ', lmp.last_name),
        mt.last_message_at,
        (SELECT COUNT(*)::INTEGER FROM messages m
         WHERE m.thread_id = mt.id
         AND m.recipient_id = user_uuid
         AND m.read_at IS NULL) as unread_count,
        mt.created_at
    FROM message_threads mt
    LEFT JOIN messages lm ON lm.id = mt.last_message_id
    LEFT JOIN profiles lmp ON lmp.id = lm.sender_id
    WHERE user_uuid = ANY(mt.participants)
    AND mt.is_active = TRUE
    ORDER BY mt.last_message_at DESC NULLS LAST
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_user_threads(UUID, INTEGER) TO authenticated;

-- Function to add reaction to message
CREATE OR REPLACE FUNCTION add_message_reaction(
    message_uuid UUID,
    user_uuid UUID,
    reaction_type_input TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
    -- Verify user can access the message
    IF NOT EXISTS (
        SELECT 1 FROM messages
        WHERE id = message_uuid
        AND (sender_id = user_uuid OR recipient_id = user_uuid)
    ) THEN
        RAISE EXCEPTION 'Message not found or access denied';
    END IF;
    
    -- Insert or update reaction
    INSERT INTO message_reactions (message_id, user_id, reaction_type)
    VALUES (message_uuid, user_uuid, reaction_type_input)
    ON CONFLICT (message_id, user_id, reaction_type) DO NOTHING;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION add_message_reaction(UUID, UUID, TEXT) TO authenticated;

-- Function to get messaging analytics
CREATE OR REPLACE FUNCTION get_messaging_analytics(
    user_uuid UUID,
    days_back INTEGER DEFAULT 30
)
RETURNS TABLE (
    total_messages_sent INTEGER,
    total_messages_received INTEGER,
    total_threads INTEGER,
    unread_messages INTEGER,
    most_active_contact JSONB,
    daily_activity JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*)::INTEGER FROM messages WHERE sender_id = user_uuid),
        (SELECT COUNT(*)::INTEGER FROM messages WHERE recipient_id = user_uuid),
        (SELECT COUNT(*)::INTEGER FROM message_threads WHERE user_uuid = ANY(participants)),
        (SELECT COUNT(*)::INTEGER FROM messages WHERE recipient_id = user_uuid AND read_at IS NULL),
        (SELECT jsonb_build_object(
            'user_id', contact_id,
            'name', contact_name,
            'message_count', message_count
        ) FROM (
            SELECT 
                CASE 
                    WHEN m.sender_id = user_uuid THEN m.recipient_id
                    ELSE m.sender_id
                END as contact_id,
                CASE 
                    WHEN m.sender_id = user_uuid THEN CONCAT(rp.first_name, ' ', rp.last_name)
                    ELSE CONCAT(sp.first_name, ' ', sp.last_name)
                END as contact_name,
                COUNT(*) as message_count
            FROM messages m
            LEFT JOIN profiles sp ON sp.id = m.sender_id
            LEFT JOIN profiles rp ON rp.id = m.recipient_id
            WHERE m.sender_id = user_uuid OR m.recipient_id = user_uuid
            GROUP BY contact_id, contact_name
            ORDER BY message_count DESC
            LIMIT 1
        ) most_active),
        (SELECT jsonb_agg(
            jsonb_build_object(
                'date', DATE(m.created_at),
                'sent', COUNT(*) FILTER (WHERE m.sender_id = user_uuid),
                'received', COUNT(*) FILTER (WHERE m.recipient_id = user_uuid)
            )
        ) FROM messages m
         WHERE (m.sender_id = user_uuid OR m.recipient_id = user_uuid)
         AND m.created_at >= NOW() - (days_back || ' days')::INTERVAL
         GROUP BY DATE(m.created_at)
         ORDER BY DATE(m.created_at) DESC);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_messaging_analytics(UUID, INTEGER) TO authenticated;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check if new columns were added to messages table
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'messages'
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Check if new tables were created successfully
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('message_threads', 'message_read_receipts', 'message_reactions');

-- Check if functions were created successfully
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN (
    'send_message',
    'mark_message_read',
    'get_conversation_messages',
    'get_user_threads',
    'add_message_reaction',
    'get_messaging_analytics'
);