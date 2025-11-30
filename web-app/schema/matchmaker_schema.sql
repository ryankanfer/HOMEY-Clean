-- Matchmaker: User preference tracking through swipe interactions
-- This powers Scout's recommendation engine by learning user taste

-- User swipe history
CREATE TABLE IF NOT EXISTS user_swipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    action TEXT NOT NULL CHECK (action IN ('pass', 'like', 'love')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Prevent duplicate swipes
    UNIQUE(user_id, listing_id)
);

-- User preference profile (aggregated insights)
CREATE TABLE IF NOT EXISTS user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE,

    -- Price preferences (learned from swipes)
    preferred_min_price DECIMAL(12, 2),
    preferred_max_price DECIMAL(12, 2),

    -- Space preferences
    preferred_bedrooms INTEGER[],
    preferred_bathrooms DECIMAL(3, 1)[],

    -- Location preferences
    preferred_neighborhoods TEXT[],
    avoided_neighborhoods TEXT[],

    -- Style preferences
    preferred_property_types TEXT[],
    preferred_features TEXT[],

    -- Behavioral data
    total_swipes INTEGER DEFAULT 0,
    total_likes INTEGER DEFAULT 0,
    total_loves INTEGER DEFAULT 0,
    avg_price_swiped_right DECIMAL(12, 2),

    -- Metadata
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_swipes_user_id ON user_swipes(user_id);
CREATE INDEX IF NOT EXISTS idx_user_swipes_listing_id ON user_swipes(listing_id);
CREATE INDEX IF NOT EXISTS idx_user_swipes_action ON user_swipes(action);
CREATE INDEX IF NOT EXISTS idx_user_swipes_created_at ON user_swipes(created_at DESC);

-- Function to update user preferences after swipe
CREATE OR REPLACE FUNCTION update_user_preferences()
RETURNS TRIGGER AS $$
BEGIN
    -- Update or create user preference profile
    INSERT INTO user_preferences (user_id, total_swipes)
    VALUES (NEW.user_id, 1)
    ON CONFLICT (user_id) DO UPDATE SET
        total_swipes = user_preferences.total_swipes + 1,
        total_likes = CASE WHEN NEW.action = 'like' THEN user_preferences.total_likes + 1 ELSE user_preferences.total_likes END,
        total_loves = CASE WHEN NEW.action = 'love' THEN user_preferences.total_loves + 1 ELSE user_preferences.total_loves END,
        updated_at = NOW();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update preferences
DROP TRIGGER IF EXISTS trigger_update_preferences ON user_swipes;
CREATE TRIGGER trigger_update_preferences
    AFTER INSERT ON user_swipes
    FOR EACH ROW
    EXECUTE FUNCTION update_user_preferences();

-- Get unswped listings for a user
CREATE OR REPLACE FUNCTION get_unswiped_listings(p_user_id UUID, p_limit INTEGER DEFAULT 20)
RETURNS TABLE (
    id UUID,
    address TEXT,
    neighborhood TEXT,
    price DECIMAL(12, 2),
    bedrooms INTEGER,
    bathrooms DECIMAL(3, 1),
    square_footage INTEGER,
    listing_type TEXT,
    property_type TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    image_urls TEXT[],
    thumbnail_url TEXT,
    description TEXT,
    is_new_to_market BOOLEAN,
    is_featured BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        l.id,
        l.address,
        l.neighborhood,
        l.price,
        l.bedrooms,
        l.bathrooms,
        l.square_footage,
        l.listing_type,
        l.property_type,
        l.latitude,
        l.longitude,
        l.image_urls,
        l.thumbnail_url,
        l.description,
        l.is_new_to_market,
        l.is_featured
    FROM listings l
    WHERE l.is_active = true
    AND l.id NOT IN (
        SELECT listing_id
        FROM user_swipes
        WHERE user_id = p_user_id
    )
    ORDER BY RANDOM()
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;
