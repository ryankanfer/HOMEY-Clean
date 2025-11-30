-- Scout's Recommendation Engine
-- Analyzes user swipe data to generate personalized property recommendations

-- Function to get user's learned property preferences from swipes
CREATE OR REPLACE FUNCTION get_user_learned_preferences(p_user_id UUID)
RETURNS TABLE (
    preferred_min_price DECIMAL,
    preferred_max_price DECIMAL,
    preferred_bedrooms INTEGER[],
    preferred_bathrooms DECIMAL[],
    preferred_property_types TEXT[],
    preferred_neighborhoods TEXT[],
    avoided_neighborhoods TEXT[],
    total_swipes INTEGER,
    total_likes INTEGER,
    total_loves INTEGER
) AS $$
DECLARE
    v_liked_listings RECORD;
BEGIN
    -- Analyze liked and loved properties to infer preferences
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY l.price) AS min_price,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY l.price) AS max_price,
        ARRAY_AGG(DISTINCT l.bedrooms ORDER BY l.bedrooms) FILTER (WHERE l.bedrooms IS NOT NULL) AS bedrooms,
        ARRAY_AGG(DISTINCT l.bathrooms ORDER BY l.bathrooms) FILTER (WHERE l.bathrooms IS NOT NULL) AS bathrooms,
        ARRAY_AGG(DISTINCT l.property_type) FILTER (WHERE l.property_type IS NOT NULL) AS property_types,
        ARRAY_AGG(DISTINCT l.neighborhood ORDER BY COUNT(*) DESC) FILTER (WHERE l.neighborhood IS NOT NULL) AS neighborhoods
    INTO v_liked_listings
    FROM user_swipes s
    JOIN listings l ON s.listing_id = l.id
    WHERE s.user_id = p_user_id
    AND s.action IN ('like', 'love');

    RETURN QUERY
    SELECT
        COALESCE(v_liked_listings.min_price, 0::DECIMAL) AS preferred_min_price,
        COALESCE(v_liked_listings.max_price, 999999999::DECIMAL) AS preferred_max_price,
        COALESCE(v_liked_listings.bedrooms, ARRAY[]::INTEGER[]) AS preferred_bedrooms,
        COALESCE(v_liked_listings.bathrooms, ARRAY[]::DECIMAL[]) AS preferred_bathrooms,
        COALESCE(v_liked_listings.property_types, ARRAY[]::TEXT[]) AS preferred_property_types,
        COALESCE(v_liked_listings.neighborhoods, ARRAY[]::TEXT[]) AS preferred_neighborhoods,
        ARRAY[]::TEXT[] AS avoided_neighborhoods,
        (SELECT COUNT(*)::INTEGER FROM user_swipes WHERE user_id = p_user_id) AS total_swipes,
        (SELECT COUNT(*)::INTEGER FROM user_swipes WHERE user_id = p_user_id AND action = 'like') AS total_likes,
        (SELECT COUNT(*)::INTEGER FROM user_swipes WHERE user_id = p_user_id AND action = 'love') AS total_loves;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate match score between user preferences and a listing
CREATE OR REPLACE FUNCTION calculate_listing_match_score(
    p_user_id UUID,
    p_listing_id UUID
)
RETURNS INTEGER AS $$
DECLARE
    v_prefs RECORD;
    v_listing RECORD;
    v_score INTEGER := 0;
    v_design_prefs RECORD;
BEGIN
    -- Get user preferences
    SELECT * INTO v_prefs FROM get_user_learned_preferences(p_user_id);

    -- Get listing details
    SELECT * INTO v_listing FROM listings WHERE id = p_listing_id;

    IF v_listing IS NULL THEN
        RETURN 0;
    END IF;

    -- Base score
    v_score := 50;

    -- Price match (0-20 points)
    IF v_listing.price BETWEEN v_prefs.preferred_min_price AND v_prefs.preferred_max_price THEN
        v_score := v_score + 20;
    ELSIF v_listing.price < v_prefs.preferred_min_price * 0.8 OR v_listing.price > v_prefs.preferred_max_price * 1.2 THEN
        v_score := v_score - 10;
    ELSE
        v_score := v_score + 10;
    END IF;

    -- Bedrooms match (0-15 points)
    IF v_prefs.preferred_bedrooms IS NOT NULL AND array_length(v_prefs.preferred_bedrooms, 1) > 0 THEN
        IF v_listing.bedrooms = ANY(v_prefs.preferred_bedrooms) THEN
            v_score := v_score + 15;
        END IF;
    END IF;

    -- Bathrooms match (0-10 points)
    IF v_prefs.preferred_bathrooms IS NOT NULL AND array_length(v_prefs.preferred_bathrooms, 1) > 0 THEN
        IF v_listing.bathrooms = ANY(v_prefs.preferred_bathrooms) THEN
            v_score := v_score + 10;
        END IF;
    END IF;

    -- Property type match (0-10 points)
    IF v_prefs.preferred_property_types IS NOT NULL AND array_length(v_prefs.preferred_property_types, 1) > 0 THEN
        IF v_listing.property_type = ANY(v_prefs.preferred_property_types) THEN
            v_score := v_score + 10;
        END IF;
    END IF;

    -- Neighborhood match (0-15 points)
    IF v_prefs.preferred_neighborhoods IS NOT NULL AND array_length(v_prefs.preferred_neighborhoods, 1) > 0 THEN
        IF v_listing.neighborhood = ANY(v_prefs.preferred_neighborhoods) THEN
            v_score := v_score + 15;
        END IF;
    END IF;

    -- Style preference bonus from design swipes (0-10 points)
    SELECT COUNT(*) INTO v_design_prefs
    FROM user_design_swipes
    WHERE user_id = p_user_id
    AND action IN ('like', 'love');

    IF v_design_prefs > 10 THEN
        v_score := v_score + 5; -- Bonus for users who've defined their style
    END IF;

    -- Ensure score is between 0 and 100
    v_score := GREATEST(0, LEAST(100, v_score));

    RETURN v_score;
END;
$$ LANGUAGE plpgsql;

-- Function to get recommended listings for a user
CREATE OR REPLACE FUNCTION get_recommended_listings(
    p_user_id UUID,
    p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    price DECIMAL,
    bedrooms INTEGER,
    bathrooms DECIMAL,
    sqft INTEGER,
    property_type TEXT,
    listing_type TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT,
    neighborhood TEXT,
    latitude DECIMAL,
    longitude DECIMAL,
    images TEXT[],
    features TEXT[],
    description TEXT,
    year_built INTEGER,
    listing_date TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN,
    match_score INTEGER,
    match_reasons TEXT[]
) AS $$
DECLARE
    v_prefs RECORD;
BEGIN
    -- Get user preferences
    SELECT * INTO v_prefs FROM get_user_learned_preferences(p_user_id);

    -- Return listings user hasn't swiped, scored and ranked
    RETURN QUERY
    SELECT
        l.id,
        l.title,
        l.price,
        l.bedrooms,
        l.bathrooms,
        l.sqft,
        l.property_type,
        l.listing_type,
        l.address,
        l.city,
        l.state,
        l.zip_code,
        l.neighborhood,
        l.latitude,
        l.longitude,
        l.images,
        l.features,
        l.description,
        l.year_built,
        l.listing_date,
        l.is_active,
        calculate_listing_match_score(p_user_id, l.id) AS match_score,
        -- Generate match reasons
        ARRAY(
            SELECT reason FROM (
                SELECT 'Perfect price range' AS reason, 1 AS priority
                WHERE l.price BETWEEN v_prefs.preferred_min_price AND v_prefs.preferred_max_price
                UNION ALL
                SELECT 'Your preferred bedroom count' AS reason, 2 AS priority
                WHERE l.bedrooms = ANY(v_prefs.preferred_bedrooms)
                UNION ALL
                SELECT 'In your favorite neighborhood' AS reason, 3 AS priority
                WHERE l.neighborhood = ANY(v_prefs.preferred_neighborhoods)
                UNION ALL
                SELECT 'Your preferred property type' AS reason, 4 AS priority
                WHERE l.property_type = ANY(v_prefs.preferred_property_types)
                UNION ALL
                SELECT 'Similar to homes you loved' AS reason, 5 AS priority
                WHERE v_prefs.total_loves > 0
            ) AS reasons
            ORDER BY priority
            LIMIT 3
        ) AS match_reasons
    FROM listings l
    WHERE l.is_active = true
    AND l.id NOT IN (
        SELECT listing_id FROM user_swipes WHERE user_id = p_user_id
    )
    ORDER BY calculate_listing_match_score(p_user_id, l.id) DESC, l.listing_date DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Function to get top match for hero display
CREATE OR REPLACE FUNCTION get_top_match_listing(p_user_id UUID)
RETURNS TABLE (
    id UUID,
    title TEXT,
    price DECIMAL,
    bedrooms INTEGER,
    bathrooms DECIMAL,
    sqft INTEGER,
    property_type TEXT,
    listing_type TEXT,
    address TEXT,
    city TEXT,
    state TEXT,
    zip_code TEXT,
    neighborhood TEXT,
    latitude DECIMAL,
    longitude DECIMAL,
    images TEXT[],
    features TEXT[],
    description TEXT,
    year_built INTEGER,
    listing_date TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN,
    match_score INTEGER,
    match_reasons TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM get_recommended_listings(p_user_id, 1);
END;
$$ LANGUAGE plpgsql;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_swipes_user_action ON user_swipes(user_id, action);
CREATE INDEX IF NOT EXISTS idx_listings_active_date ON listings(is_active, listing_date DESC);
CREATE INDEX IF NOT EXISTS idx_listings_neighborhood ON listings(neighborhood);
CREATE INDEX IF NOT EXISTS idx_listings_property_type ON listings(property_type);
