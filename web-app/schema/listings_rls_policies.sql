-- =====================================================
-- LISTINGS TABLE - RLS POLICIES
-- Allow public read access to active listings
-- =====================================================

-- Enable RLS
ALTER TABLE listings ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "public_read_active_listings" ON listings;
DROP POLICY IF EXISTS "anon_read_active_listings" ON listings;
DROP POLICY IF EXISTS "authenticated_read_listings" ON listings;

-- Allow anyone (including anonymous users) to read active listings
CREATE POLICY "public_read_active_listings"
    ON listings
    FOR SELECT
    USING (is_active = true);

-- Allow authenticated users to read all listings
CREATE POLICY "authenticated_read_all_listings"
    ON listings
    FOR SELECT
    TO authenticated
    USING (true);

-- Allow service role to do everything (for API sync)
-- No policy needed - service role bypasses RLS

SELECT 'Listings RLS policies created successfully!' as status;
