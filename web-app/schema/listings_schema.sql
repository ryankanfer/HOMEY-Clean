-- =====================================================
-- HOMEY Listings Database Schema
-- Property search and discovery system
-- =====================================================

-- =====================================================
-- LISTINGS TABLE
-- Core property listings for search and discovery
-- =====================================================

CREATE TABLE IF NOT EXISTS listings (
    -- Primary identification
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Basic property info
    address TEXT NOT NULL,
    neighborhood TEXT NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    bedrooms INTEGER NOT NULL CHECK (bedrooms >= 0),
    bathrooms DECIMAL(3, 1) NOT NULL CHECK (bathrooms >= 0),
    square_footage INTEGER CHECK (square_footage > 0),

    -- Property type and status
    listing_type TEXT NOT NULL CHECK (listing_type IN ('sale', 'rental')),
    property_type TEXT CHECK (property_type IN ('apartment', 'condo', 'townhouse', 'house', 'studio', 'loft')),

    -- Location data for map visualization
    latitude DECIMAL(10, 7) NOT NULL,
    longitude DECIMAL(10, 7) NOT NULL,

    -- Media
    image_urls TEXT[] DEFAULT '{}',
    thumbnail_url TEXT,

    -- Features and amenities (stored as array)
    features TEXT[] DEFAULT '{}',
    amenities TEXT[] DEFAULT '{}',

    -- Monthly costs
    monthly_hoa INTEGER DEFAULT 0,
    monthly_maintenance INTEGER DEFAULT 0,
    monthly_taxes INTEGER DEFAULT 0,
    monthly_insurance INTEGER DEFAULT 0,

    -- Quality metrics
    sun_hours INTEGER CHECK (sun_hours >= 0 AND sun_hours <= 24),
    noise_level TEXT CHECK (noise_level IN ('quiet', 'moderate', 'busy')),
    walk_score INTEGER CHECK (walk_score >= 0 AND walk_score <= 100),
    transit_score INTEGER CHECK (transit_score >= 0 AND transit_score <= 100),
    school_rating DECIMAL(3, 1) CHECK (school_rating >= 0 AND school_rating <= 10),

    -- Status flags
    is_new_to_market BOOLEAN DEFAULT FALSE,
    has_open_house BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,

    -- Additional details
    description TEXT,
    available_date DATE,

    -- Contact information
    agent_name TEXT,
    agent_phone TEXT,
    agent_email TEXT,
    brokerage_name TEXT,
    brokerage_phone TEXT,

    -- Metadata
    listing_date TIMESTAMPTZ DEFAULT NOW(),
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- External references
    external_id TEXT UNIQUE,
    source TEXT -- e.g., 'streeteasy', 'zillow', 'manual'
);

-- =====================================================
-- USER SAVED PROPERTIES TABLE
-- Track which properties users have saved/favorited
-- =====================================================

CREATE TABLE IF NOT EXISTS user_saved_properties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Ensure a user can only save a listing once
    UNIQUE(user_id, listing_id)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- Optimize common queries
-- =====================================================

-- Location-based search
CREATE INDEX IF NOT EXISTS idx_listings_coordinates ON listings(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_listings_neighborhood ON listings(neighborhood);

-- Price and bedroom filters
CREATE INDEX IF NOT EXISTS idx_listings_price ON listings(price);
CREATE INDEX IF NOT EXISTS idx_listings_bedrooms ON listings(bedrooms);
CREATE INDEX IF NOT EXISTS idx_listings_bathrooms ON listings(bathrooms);

-- Listing type and status
CREATE INDEX IF NOT EXISTS idx_listings_type ON listings(listing_type);
CREATE INDEX IF NOT EXISTS idx_listings_active ON listings(is_active);
CREATE INDEX IF NOT EXISTS idx_listings_featured ON listings(is_featured);
CREATE INDEX IF NOT EXISTS idx_listings_new ON listings(is_new_to_market);

-- Dates for sorting
CREATE INDEX IF NOT EXISTS idx_listings_listing_date ON listings(listing_date DESC);
CREATE INDEX IF NOT EXISTS idx_listings_updated ON listings(last_updated DESC);

-- Saved properties
CREATE INDEX IF NOT EXISTS idx_saved_properties_user ON user_saved_properties(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_properties_listing ON user_saved_properties(listing_id);

-- Features search (GIN index for array containment)
CREATE INDEX IF NOT EXISTS idx_listings_features ON listings USING GIN(features);
CREATE INDEX IF NOT EXISTS idx_listings_amenities ON listings USING GIN(amenities);

-- =====================================================
-- ROW LEVEL SECURITY POLICIES
-- Secure access to listings data
-- =====================================================

-- Enable RLS on listings (public read, admin write)
ALTER TABLE listings ENABLE ROW LEVEL SECURITY;

-- Anyone can view active listings
CREATE POLICY "public_read_active_listings" ON listings
    FOR SELECT
    USING (is_active = TRUE);

-- Authenticated users can view all listings
CREATE POLICY "authenticated_read_all_listings" ON listings
    FOR SELECT
    TO authenticated
    USING (TRUE);

-- Only admins can insert listings
CREATE POLICY "admin_insert_listings" ON listings
    FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id = auth.uid()
            AND profiles.role = 'admin'
        )
    );

-- Only admins can update listings
CREATE POLICY "admin_update_listings" ON listings
    FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id = auth.uid()
            AND profiles.role = 'admin'
        )
    );

-- Only admins can delete listings
CREATE POLICY "admin_delete_listings" ON listings
    FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id = auth.uid()
            AND profiles.role = 'admin'
        )
    );

-- Enable RLS on user_saved_properties
ALTER TABLE user_saved_properties ENABLE ROW LEVEL SECURITY;

-- Users can only view their own saved properties
CREATE POLICY "users_read_own_saved" ON user_saved_properties
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

-- Users can only save properties for themselves
CREATE POLICY "users_insert_own_saved" ON user_saved_properties
    FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

-- Users can only delete their own saved properties
CREATE POLICY "users_delete_own_saved" ON user_saved_properties
    FOR DELETE
    TO authenticated
    USING (user_id = auth.uid());

-- Users can update their notes on saved properties
CREATE POLICY "users_update_own_saved" ON user_saved_properties
    FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- =====================================================
-- FUNCTIONS
-- Helper functions for common operations
-- =====================================================

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at on listings
DROP TRIGGER IF EXISTS update_listings_updated_at ON listings;
CREATE TRIGGER update_listings_updated_at
    BEFORE UPDATE ON listings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger to auto-update updated_at on user_saved_properties
DROP TRIGGER IF EXISTS update_saved_properties_updated_at ON user_saved_properties;
CREATE TRIGGER update_saved_properties_updated_at
    BEFORE UPDATE ON user_saved_properties
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to search listings with filters
CREATE OR REPLACE FUNCTION search_listings(
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

-- Grant execute permission
GRANT EXECUTE ON FUNCTION search_listings TO authenticated;
GRANT EXECUTE ON FUNCTION search_listings TO anon;

-- =====================================================
-- SAMPLE DATA
-- Test listings for development
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
-- Listing 1: Flatiron luxury apartment
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
    ARRAY['https://images.unsplash.com/photo-1502672260266-1c1ef2d93688', 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2'],
    'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688',
    ARRAY['elevator', 'washer_dryer', 'doorman'],
    ARRAY['Doorman', 'Gym', 'Rooftop', 'Elevator', 'Washer/Dryer in Unit'],
    0,
    200,
    150,
    50,
    6,
    'moderate',
    95,
    88,
    8.5,
    TRUE,
    FALSE,
    TRUE,
    'Stunning two-bedroom apartment in the heart of Flatiron with floor-to-ceiling windows and modern finishes. This bright and airy unit features hardwood floors, stainless steel appliances, and an in-unit washer/dryer.',
    'Sarah Johnson',
    '(555) 123-4567',
    'sarah@flatironliving.com',
    'Flatiron Living Realty'
),

-- Listing 2: West Village charming apartment
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
    ARRAY['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267', 'https://images.unsplash.com/photo-1484154218962-a197022b5858'],
    'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
    ARRAY['pet_friendly', 'outdoor', 'dishwasher'],
    ARRAY['Pet Friendly', 'Private Patio', 'Dishwasher', 'Updated Kitchen'],
    0,
    0,
    0,
    0,
    4,
    'quiet',
    92,
    75,
    9.0,
    FALSE,
    TRUE,
    FALSE,
    'Charming one-bedroom in the heart of West Village with a private outdoor patio. This unit features exposed brick, original hardwood floors, and an updated kitchen with stainless steel appliances.',
    'Michael Chen',
    '(555) 987-6543',
    'mchen@villageproperties.com',
    'West Village Properties'
),

-- Listing 3: Tribeca luxury loft
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
    ARRAY['https://images.unsplash.com/photo-1600596542815-ffad4c1539a9', 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c'],
    'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
    ARRAY['doorman', 'parking', 'gym', 'rooftop_access'],
    ARRAY['24/7 Doorman', 'Parking Included', 'Fitness Center', 'Rooftop Terrace', 'High Ceilings'],
    0,
    300,
    250,
    75,
    8,
    'moderate',
    98,
    92,
    9.5,
    TRUE,
    TRUE,
    TRUE,
    'Spectacular Tribeca loft with soaring 14-foot ceilings and massive windows. This converted industrial space features exposed brick, polished concrete floors, and a chef''s kitchen with top-of-the-line appliances.',
    'Emma Rodriguez',
    '(555) 456-7890',
    'emma@tribecaluxury.com',
    'Tribeca Luxury Living'
),

-- Listing 4: Gramercy studio
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
    ARRAY['laundry', 'gym', 'pet_friendly'],
    ARRAY['Laundry in Building', 'Gym', 'Pet Friendly'],
    0,
    100,
    80,
    30,
    5,
    'quiet',
    85,
    90,
    8.0,
    TRUE,
    FALSE,
    FALSE,
    'Cozy studio in pre-war Gramercy building with excellent natural light. Perfect for young professionals with efficient layout and close proximity to Union Square.',
    'David Park',
    '(555) 234-5678',
    'dpark@gramercyproperties.com',
    'Gramercy Properties'
),

-- Listing 5: Midtown East luxury condo
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
    ARRAY['https://images.unsplash.com/photo-1545324418-cc1a3fa10c00', 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750'],
    'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00',
    ARRAY['doorman', 'pool', 'parking', 'outdoor'],
    ARRAY['Concierge', 'Swimming Pool', 'Valet Parking', 'Balcony', 'Central AC'],
    250,
    400,
    300,
    100,
    7,
    'busy',
    88,
    95,
    7.5,
    FALSE,
    FALSE,
    TRUE,
    'Luxurious two-bedroom condo with stunning city views and world-class amenities. Features include marble bathrooms, custom closets, and a private balcony overlooking Park Avenue.',
    'Lisa Thompson',
    '(555) 345-6789',
    'lisa@parkaveliving.com',
    'Park Avenue Living'
);

-- Verify data was inserted
SELECT 'Sample data inserted successfully!' as status;
SELECT COUNT(*) as total_listings FROM listings;
