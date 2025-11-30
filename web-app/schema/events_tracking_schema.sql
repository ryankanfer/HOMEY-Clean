-- =====================================================
-- HOMEY Events Tracking Schema
-- Foundation for AI learning and network effects
-- =====================================================

-- Drop existing table if needed
DROP TABLE IF EXISTS user_events CASCADE;

-- =====================================================
-- USER EVENTS TABLE
-- Captures all user interactions for AI learning
-- =====================================================

CREATE TABLE user_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- User context
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    session_id TEXT NOT NULL,

    -- Event classification
    event_type TEXT NOT NULL,
    event_category TEXT NOT NULL,
    event_action TEXT NOT NULL,

    -- Journey context
    journey_stage TEXT,

    -- Event data
    event_data JSONB DEFAULT '{}',

    -- Location context
    page_path TEXT,
    page_title TEXT,
    referrer TEXT,

    -- Device context
    device_type TEXT,
    browser TEXT,
    os TEXT,
    screen_size TEXT,

    -- Geolocation
    city TEXT,
    region TEXT,
    country TEXT,

    -- Timestamps
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- USER SESSIONS TABLE
-- Track user sessions for behavior analysis
-- =====================================================

CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id TEXT UNIQUE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Session metadata
    started_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    duration_seconds INTEGER,

    -- Entry/exit
    entry_page TEXT,
    exit_page TEXT,

    -- Engagement metrics
    pages_viewed INTEGER DEFAULT 0,
    actions_count INTEGER DEFAULT 0,
    listings_viewed INTEGER DEFAULT 0,
    searches_performed INTEGER DEFAULT 0,

    -- Device context
    device_type TEXT,
    browser TEXT,
    os TEXT,

    -- Attribution
    utm_source TEXT,
    utm_medium TEXT,
    utm_campaign TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- USER JOURNEY STATES TABLE
-- Track where users are in their home journey
-- =====================================================

CREATE TABLE user_journey_states (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Current state
    current_stage TEXT NOT NULL DEFAULT 'exploring',
    previous_stage TEXT,

    -- Stage history
    stage_history JSONB DEFAULT '[]',

    -- Journey metadata
    search_criteria JSONB DEFAULT '{}',
    saved_properties INTEGER DEFAULT 0,
    tours_scheduled INTEGER DEFAULT 0,
    offers_made INTEGER DEFAULT 0,

    -- Engagement scores
    engagement_score DECIMAL(3, 2) DEFAULT 0.0,
    intent_score DECIMAL(3, 2) DEFAULT 0.0,

    -- Timestamps
    stage_started_at TIMESTAMPTZ DEFAULT NOW(),
    last_activity_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Events indexes
CREATE INDEX idx_events_user ON user_events(user_id);
CREATE INDEX idx_events_session ON user_events(session_id);
CREATE INDEX idx_events_type ON user_events(event_type);
CREATE INDEX idx_events_category ON user_events(event_category);
CREATE INDEX idx_events_timestamp ON user_events(timestamp DESC);
CREATE INDEX idx_events_journey_stage ON user_events(journey_stage);
CREATE INDEX idx_events_data ON user_events USING GIN(event_data);

-- Sessions indexes
CREATE INDEX idx_sessions_user ON user_sessions(user_id);
CREATE INDEX idx_sessions_started ON user_sessions(started_at DESC);
CREATE INDEX idx_sessions_duration ON user_sessions(duration_seconds);

-- Journey states indexes
CREATE INDEX idx_journey_user ON user_journey_states(user_id);
CREATE INDEX idx_journey_stage ON user_journey_states(current_stage);
CREATE INDEX idx_journey_last_activity ON user_journey_states(last_activity_at DESC);

-- =====================================================
-- ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE user_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_journey_states ENABLE ROW LEVEL SECURITY;

-- Users can only view their own events
CREATE POLICY "users_read_own_events" ON user_events
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

-- Users can insert their own events
CREATE POLICY "users_insert_own_events" ON user_events
    FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

-- Anonymous users can insert events (for tracking before login)
CREATE POLICY "anon_insert_events" ON user_events
    FOR INSERT
    TO anon
    WITH CHECK (TRUE);

-- Sessions policies
CREATE POLICY "users_manage_own_sessions" ON user_sessions
    FOR ALL
    TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Journey states policies
CREATE POLICY "users_manage_own_journey" ON user_journey_states
    FOR ALL
    TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Function to update session metrics
CREATE OR REPLACE FUNCTION update_session_metrics()
RETURNS TRIGGER AS $$
BEGIN
    -- Update session with new event data
    UPDATE user_sessions
    SET
        pages_viewed = pages_viewed + CASE WHEN NEW.event_type = 'page_view' THEN 1 ELSE 0 END,
        actions_count = actions_count + 1,
        listings_viewed = listings_viewed + CASE WHEN NEW.event_type = 'listing_view' THEN 1 ELSE 0 END,
        searches_performed = searches_performed + CASE WHEN NEW.event_type = 'search' THEN 1 ELSE 0 END,
        updated_at = NOW()
    WHERE session_id = NEW.session_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update session metrics on new events
CREATE TRIGGER update_session_on_event
    AFTER INSERT ON user_events
    FOR EACH ROW
    EXECUTE FUNCTION update_session_metrics();

-- Function to update journey state activity
CREATE OR REPLACE FUNCTION update_journey_activity()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE user_journey_states
    SET
        last_activity_at = NOW(),
        updated_at = NOW()
    WHERE user_id = NEW.user_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update journey activity on events
CREATE TRIGGER update_journey_on_event
    AFTER INSERT ON user_events
    FOR EACH ROW
    WHEN (NEW.user_id IS NOT NULL)
    EXECUTE FUNCTION update_journey_activity();

-- Function to calculate engagement score
CREATE OR REPLACE FUNCTION calculate_engagement_score(p_user_id UUID)
RETURNS DECIMAL AS $$
DECLARE
    v_score DECIMAL;
    v_events_count INTEGER;
    v_days_active INTEGER;
    v_session_count INTEGER;
BEGIN
    -- Count events in last 30 days
    SELECT COUNT(*) INTO v_events_count
    FROM user_events
    WHERE user_id = p_user_id
        AND timestamp > NOW() - INTERVAL '30 days';

    -- Count distinct days active
    SELECT COUNT(DISTINCT DATE(timestamp)) INTO v_days_active
    FROM user_events
    WHERE user_id = p_user_id
        AND timestamp > NOW() - INTERVAL '30 days';

    -- Count sessions
    SELECT COUNT(*) INTO v_session_count
    FROM user_sessions
    WHERE user_id = p_user_id
        AND started_at > NOW() - INTERVAL '30 days';

    -- Calculate score (0-1 scale)
    v_score := LEAST(1.0, (
        (v_events_count / 100.0) * 0.4 +
        (v_days_active / 30.0) * 0.3 +
        (v_session_count / 20.0) * 0.3
    ));

    RETURN v_score;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION calculate_engagement_score TO authenticated;

-- Function to get user journey insights
CREATE OR REPLACE FUNCTION get_user_journey_insights(p_user_id UUID)
RETURNS TABLE (
    current_stage TEXT,
    days_in_stage INTEGER,
    total_events INTEGER,
    recent_actions JSONB,
    engagement_score DECIMAL,
    recommended_next_actions JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ujs.current_stage,
        EXTRACT(DAY FROM NOW() - ujs.stage_started_at)::INTEGER as days_in_stage,
        (SELECT COUNT(*)::INTEGER FROM user_events WHERE user_id = p_user_id) as total_events,
        (
            SELECT jsonb_agg(jsonb_build_object(
                'type', event_type,
                'action', event_action,
                'timestamp', timestamp
            ))
            FROM (
                SELECT event_type, event_action, timestamp
                FROM user_events
                WHERE user_id = p_user_id
                ORDER BY timestamp DESC
                LIMIT 5
            ) recent
        ) as recent_actions,
        calculate_engagement_score(p_user_id) as engagement_score,
        '[]'::JSONB as recommended_next_actions
    FROM user_journey_states ujs
    WHERE ujs.user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION get_user_journey_insights TO authenticated;

-- =====================================================
-- SAMPLE JOURNEY STAGES
-- =====================================================

COMMENT ON COLUMN user_journey_states.current_stage IS
'Possible values: exploring, searching, touring, negotiating, under_contract, closing, living';

-- Success message
SELECT 'Event tracking schema created successfully!' as status;
SELECT COUNT(*) as total_event_types FROM (
    VALUES
        ('page_view'), ('listing_view'), ('search'), ('save'),
        ('share'), ('contact'), ('schedule_tour'), ('message'),
        ('document_upload'), ('filter_change'), ('map_interaction')
) as t;
