-- =====================================================
-- HOMEY Listings Database Schema
-- CLEAN INSTALL - Drops existing tables first
-- =====================================================

-- Drop existing tables (CASCADE removes dependencies)
DROP TABLE IF EXISTS user_saved_properties CASCADE;
DROP TABLE IF EXISTS listings CASCADE;

-- Drop existing functions
DROP FUNCTION IF EXISTS search_listings CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column CASCADE;

-- =====================================================
-- LISTINGS TABLE
-- =====================================================

CREATE TABLE listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    address TEXT NOT NULL,
    neighborhood TEXT NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    bedrooms INTEGER NOT NULL CHECK (bedrooms >= 0),
    bathrooms DECIMAL(3, 1) NOT NULL CHECK (bathrooms >= 0),
    square_footage INTEGER CHECK (square_footage > 0),
    listing_type TEXT NOT NULL CHECK (listing_type IN ('sale', 'rental')),
    property_type TEXT CHECK (property_type IN ('apartment', 'condo', 'townhouse', 'house', 'studio', 'loft')),
    latitude DECIMAL(10, 7) NOT NULL,
    longitude DECIMAL(10, 7) NOT NULL,
    image_urls TEXT[] DEFAULT '{}',
    thumbnail_url TEXT,
    features TEXT[] DEFAULT '{}',
    amenities TEXT[] DEFAULT '{}',
    monthly_hoa INTEGER DEFAULT 0,
    monthly_maintenance INTEGER DEFAULT 0,
    monthly_taxes INTEGER DEFAULT 0,
    monthly_insurance INTEGER DEFAULT 0,
    sun_hours INTEGER CHECK (sun_hours >= 0 AND sun_hours <= 24),
    noise_level TEXT CHECK (noise_level IN ('quiet', 'moderate', 'busy')),
    walk_score INTEGER CHECK (walk_score >= 0 AND walk_score <= 100),
    transit_score INTEGER CHECK (transit_score >= 0 AND transit_score <= 100),
    school_rating DECIMAL(3, 1) CHECK (school_rating >= 0 AND school_rating <= 10),
    is_new_to_market BOOLEAN DEFAULT FALSE,
    has_open_house BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    description TEXT,
    available_date DATE,
    agent_name TEXT,
    agent_phone TEXT,
    agent_email TEXT,
    brokerage_name TEXT,
    brokerage_phone TEXT,
    listing_date TIMESTAMPTZ DEFAULT NOW(),
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    external_id TEXT UNIQUE,
    source TEXT
);

-- =====================================================
-- USER SAVED PROPERTIES TABLE
-- =====================================================

CREATE TABLE user_saved_properties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, listing_id)
);

-- =====================================================
-- INDEXES
-- =====================================================

CREATE INDEX idx_listings_coordinates ON listings(latitude, longitude);
CREATE INDEX idx_listings_neighborhood ON listings(neighborhood);
CREATE INDEX idx_listings_price ON listings(price);
CREATE INDEX idx_listings_bedrooms ON listings(bedrooms);
CREATE INDEX idx_listings_bathrooms ON listings(bathrooms);
CREATE INDEX idx_listings_type ON listings(listing_type);
CREATE INDEX idx_listings_active ON listings(is_active);
CREATE INDEX idx_listings_featured ON listings(is_featured);
CREATE INDEX idx_listings_new ON listings(is_new_to_market);
CREATE INDEX idx_listings_listing_date ON listings(listing_date DESC);
CREATE INDEX idx_listings_updated ON listings(last_updated DESC);
CREATE INDEX idx_saved_properties_user ON user_saved_properties(user_id);
CREATE INDEX idx_saved_properties_listing ON user_saved_properties(listing_id);
CREATE INDEX idx_listings_features ON listings USING GIN(features);
CREATE INDEX idx_listings_amenities ON listings USING GIN(amenities);

-- =====================================================
-- ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_saved_properties ENABLE ROW LEVEL SECURITY;

-- Everyone can read active listings
CREATE POLICY "public_read_listings" ON listings
    FOR SELECT
    USING (is_active = TRUE);

-- Authenticated users can manage listings (tighten later)
CREATE POLICY "authenticated_manage_listings" ON listings
    FOR ALL
    TO authenticated
    USING (TRUE)
    WITH CHECK (TRUE);

-- Users can only manage their own saved properties
CREATE POLICY "users_manage_own_saved" ON user_saved_properties
    FOR ALL
    TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- =====================================================
-- FUNCTIONS
-- =====================================================

CREATE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_listings_updated_at
    BEFORE UPDATE ON listings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_saved_properties_updated_at
    BEFORE UPDATE ON user_saved_properties
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE FUNCTION search_listings(
    p_min_price DECIMAL DEFAULT 0,
    p_max_price DECIMAL DEFAULT 999999999,
    p_min_bedrooms INTEGER DEFAULT 0,
    p_min_bathrooms DECIMAL DEFAULT 0,
    p_listing_type TEXT DEFAULT NULL,
    p_property_type TEXT DEFAULT NULL,
    p_neighborhood TEXT DEFAULT NULL,
    p_features TEXT[] DEFAULT '{}',
    p_max_results INTEGER DEFAULT 50
)
RETURNS SETOF listings AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM listings
    WHERE is_active = TRUE
        AND price >= p_min_price
        AND price <= p_max_price
        AND bedrooms >= p_min_bedrooms
        AND bathrooms >= p_min_bathrooms
        AND (p_listing_type IS NULL OR listing_type = p_listing_type)
        AND (p_property_type IS NULL OR property_type = p_property_type)
        AND (p_neighborhood IS NULL OR neighborhood ILIKE '%' || p_neighborhood || '%')
        AND (p_features = '{}' OR features && p_features)
    ORDER BY listing_date DESC, is_featured DESC, is_new_to_market DESC
    LIMIT p_max_results;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION search_listings TO authenticated;
GRANT EXECUTE ON FUNCTION search_listings TO anon;

-- =====================================================
-- SAMPLE DATA
-- =====================================================

INSERT INTO listings (
    address, neighborhood, price, bedrooms, bathrooms, square_footage,
    listing_type, property_type, latitude, longitude,
    image_urls, thumbnail_url, features, amenities,
    monthly_hoa, monthly_maintenance, monthly_taxes, monthly_insurance,
    sun_hours, noise_level, walk_score, transit_score, school_rating,
    is_new_to_market, has_open_house, is_featured,
    description, agent_name, agent_phone, agent_email, brokerage_name
) VALUES
(
    '245 E 25th St, Apt 4B',
    'Flatiron',
    5200.00,
    2,
    2.0,
    1200,
    'rental',
    'apartment',
    40.7398,
    -73.9857,
    ARRAY['https://images.unsplash.com/photo-1502672260266-1c1ef2d93688'],
    'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688',
    ARRAY['elevator', 'washer_dryer', 'doorman'],
    ARRAY['Doorman', 'Gym', 'Rooftop'],
    0, 200, 150, 50,
    6, 'moderate', 95, 88, 8.5,
    TRUE, FALSE, TRUE,
    'Stunning two-bedroom apartment in Flatiron with modern finishes.',
    'Sarah Johnson', '(555) 123-4567', 'sarah@flatironliving.com', 'Flatiron Living'
),
(
    '123 W 14th St, Apt 2A',
    'West Village',
    4800.00,
    1,
    1.0,
    800,
    'rental',
    'apartment',
    40.7370,
    -74.0037,
    ARRAY['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267'],
    'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
    ARRAY['pet_friendly', 'outdoor'],
    ARRAY['Pet Friendly', 'Patio'],
    0, 0, 0, 0,
    4, 'quiet', 92, 75, 9.0,
    FALSE, TRUE, FALSE,
    'Charming one-bedroom in West Village with private patio.',
    'Michael Chen', '(555) 987-6543', 'mchen@villageproperties.com', 'Village Properties'
),
(
    '456 Greenwich St, Loft 8C',
    'Tribeca',
    8200.00,
    2,
    2.5,
    1400,
    'rental',
    'loft',
    40.7195,
    -74.0089,
    ARRAY['https://images.unsplash.com/photo-1600596542815-ffad4c1539a9'],
    'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
    ARRAY['doorman', 'parking', 'gym'],
    ARRAY['Doorman', 'Parking', 'Gym'],
    0, 300, 250, 75,
    8, 'moderate', 98, 92, 9.5,
    TRUE, TRUE, TRUE,
    'Spectacular Tribeca loft with high ceilings.',
    'Emma Rodriguez', '(555) 456-7890', 'emma@tribecaluxury.com', 'Tribeca Luxury'
),
(
    '321 E 23rd St, Studio 5F',
    'Gramercy',
    3200.00,
    0,
    1.0,
    450,
    'rental',
    'studio',
    40.7390,
    -73.9845,
    ARRAY['https://images.unsplash.com/photo-1536376072261-38c75010e6c9'],
    'https://images.unsplash.com/photo-1536376072261-38c75010e6c9',
    ARRAY['laundry', 'gym'],
    ARRAY['Laundry', 'Gym'],
    0, 100, 80, 30,
    5, 'quiet', 85, 90, 8.0,
    TRUE, FALSE, FALSE,
    'Cozy studio in Gramercy with great light.',
    'David Park', '(555) 234-5678', 'dpark@gramercy.com', 'Gramercy Properties'
),
(
    '789 Park Ave, Unit 12A',
    'Midtown East',
    6800.00,
    2,
    2.0,
    1100,
    'rental',
    'condo',
    40.7549,
    -73.9707,
    ARRAY['https://images.unsplash.com/photo-1545324418-cc1a3fa10c00'],
    'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00',
    ARRAY['doorman', 'pool', 'parking'],
    ARRAY['Doorman', 'Pool', 'Parking'],
    250, 400, 300, 100,
    7, 'busy', 88, 95, 7.5,
    FALSE, FALSE, TRUE,
    'Luxurious condo with stunning city views.',
    'Lisa Thompson', '(555) 345-6789', 'lisa@parkaveliving.com', 'Park Avenue Living'
);

-- Success message
SELECT 'Database schema created successfully!' as status;
SELECT 'Total listings: ' || COUNT(*)::TEXT as result FROM listings;
