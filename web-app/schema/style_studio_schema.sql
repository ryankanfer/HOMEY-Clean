-- Style Studio: Interior design inspiration and mood boards
-- Users swipe through curated design content to build aesthetic preferences

-- Design inspiration content (curated library)
CREATE TABLE IF NOT EXISTS design_inspirations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Content
    image_url TEXT NOT NULL,
    title TEXT,
    description TEXT,
    source_url TEXT,

    -- Categorization
    room_type TEXT, -- living_room, bedroom, kitchen, bathroom, etc.
    style_tags TEXT[], -- modern, minimalist, bohemian, industrial, etc.
    color_palette TEXT[], -- extracted colors

    -- Metadata
    is_active BOOLEAN DEFAULT true,
    featured BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User swipes on design inspirations
CREATE TABLE IF NOT EXISTS user_design_swipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    inspiration_id UUID NOT NULL REFERENCES design_inspirations(id) ON DELETE CASCADE,
    action TEXT NOT NULL CHECK (action IN ('pass', 'like', 'love')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Prevent duplicate swipes
    UNIQUE(user_id, inspiration_id)
);

-- User mood boards (saved collections)
CREATE TABLE IF NOT EXISTS user_mood_boards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    cover_image_url TEXT,

    -- Optional property link
    property_id UUID REFERENCES listings(id) ON DELETE SET NULL,
    room_type TEXT,

    -- Privacy
    is_public BOOLEAN DEFAULT false,

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Items saved to mood boards
CREATE TABLE IF NOT EXISTS mood_board_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mood_board_id UUID NOT NULL REFERENCES user_mood_boards(id) ON DELETE CASCADE,
    inspiration_id UUID NOT NULL REFERENCES design_inspirations(id) ON DELETE CASCADE,
    notes TEXT,
    position INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Prevent duplicates in same board
    UNIQUE(mood_board_id, inspiration_id)
);

-- User style preferences (aggregated from swipes)
CREATE TABLE IF NOT EXISTS user_style_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE,

    -- Learned preferences
    preferred_styles TEXT[], -- most swiped right styles
    avoided_styles TEXT[],
    preferred_rooms TEXT[],
    preferred_colors TEXT[],

    -- Stats
    total_swipes INTEGER DEFAULT 0,
    total_likes INTEGER DEFAULT 0,
    total_loves INTEGER DEFAULT 0,

    -- Metadata
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_design_inspirations_room_type ON design_inspirations(room_type);
CREATE INDEX IF NOT EXISTS idx_design_inspirations_style_tags ON design_inspirations USING GIN(style_tags);
CREATE INDEX IF NOT EXISTS idx_user_design_swipes_user_id ON user_design_swipes(user_id);
CREATE INDEX IF NOT EXISTS idx_user_design_swipes_inspiration_id ON user_design_swipes(inspiration_id);
CREATE INDEX IF NOT EXISTS idx_user_mood_boards_user_id ON user_mood_boards(user_id);
CREATE INDEX IF NOT EXISTS idx_mood_board_items_board_id ON mood_board_items(mood_board_id);

-- Function to update style preferences after swipe
CREATE OR REPLACE FUNCTION update_style_preferences()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_style_preferences (user_id, total_swipes)
    VALUES (NEW.user_id, 1)
    ON CONFLICT (user_id) DO UPDATE SET
        total_swipes = user_style_preferences.total_swipes + 1,
        total_likes = CASE WHEN NEW.action = 'like' THEN user_style_preferences.total_likes + 1 ELSE user_style_preferences.total_likes END,
        total_loves = CASE WHEN NEW.action = 'love' THEN user_style_preferences.total_loves + 1 ELSE user_style_preferences.total_loves END,
        updated_at = NOW();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger
DROP TRIGGER IF EXISTS trigger_update_style_preferences ON user_design_swipes;
CREATE TRIGGER trigger_update_style_preferences
    AFTER INSERT ON user_design_swipes
    FOR EACH ROW
    EXECUTE FUNCTION update_style_preferences();

-- Get unswiped design inspirations
CREATE OR REPLACE FUNCTION get_unswiped_designs(p_user_id UUID, p_limit INTEGER DEFAULT 20)
RETURNS TABLE (
    id UUID,
    image_url TEXT,
    title TEXT,
    description TEXT,
    room_type TEXT,
    style_tags TEXT[],
    color_palette TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id,
        d.image_url,
        d.title,
        d.description,
        d.room_type,
        d.style_tags,
        d.color_palette
    FROM design_inspirations d
    WHERE d.is_active = true
    AND d.id NOT IN (
        SELECT inspiration_id
        FROM user_design_swipes
        WHERE user_id = p_user_id
    )
    ORDER BY
        CASE WHEN d.featured THEN 0 ELSE 1 END,
        RANDOM()
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Insert sample design inspirations
INSERT INTO design_inspirations (image_url, title, description, room_type, style_tags, color_palette) VALUES
('https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800', 'Minimalist Living Space', 'Clean lines and neutral tones', 'living_room', ARRAY['minimalist', 'modern', 'scandinavian'], ARRAY['#FFFFFF', '#F5F5F5', '#9E9E9E']),
('https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800', 'Cozy Bedroom Retreat', 'Warm textures and soft lighting', 'bedroom', ARRAY['cozy', 'bohemian', 'modern'], ARRAY['#D4C5B9', '#8B7355', '#FFFFFF']),
('https://images.unsplash.com/photo-1556912172-45b7abe8b7e1?w=800', 'Modern Kitchen Design', 'Sleek appliances and marble countertops', 'kitchen', ARRAY['modern', 'luxury', 'minimalist'], ARRAY['#FFFFFF', '#2C2C2C', '#C4B5A0']),
('https://images.unsplash.com/photo-1540518614846-7eded433c457?w=800', 'Industrial Loft Style', 'Exposed brick and metal accents', 'living_room', ARRAY['industrial', 'urban', 'modern'], ARRAY['#8B4513', '#2F4F4F', '#D3D3D3']),
('https://images.unsplash.com/photo-1507089947368-19c1da9775ae?w=800', 'Spa-like Bathroom', 'Natural materials and calming colors', 'bathroom', ARRAY['spa', 'minimalist', 'natural'], ARRAY['#F5F5DC', '#A0D6B4', '#FFFFFF']),
('https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=800', 'Bohemian Bedroom', 'Layered textiles and plants', 'bedroom', ARRAY['bohemian', 'eclectic', 'colorful'], ARRAY['#D4A574', '#8FBC8F', '#F0E68C']),
('https://images.unsplash.com/photo-1556912167-f556f1f39faa?w=800', 'Scandinavian Dining', 'Light wood and simple forms', 'dining_room', ARRAY['scandinavian', 'minimalist', 'modern'], ARRAY['#F5F5F5', '#D2B48C', '#696969']),
('https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?w=800', 'Mid-Century Living', 'Vintage furniture and bold colors', 'living_room', ARRAY['mid-century', 'retro', 'modern'], ARRAY['#FF6347', '#4682B4', '#DEB887']),
('https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?w=800', 'Contemporary Kitchen', 'Open shelving and pendant lights', 'kitchen', ARRAY['contemporary', 'modern', 'minimalist'], ARRAY['#FFFFFF', '#708090', '#FFD700']),
('https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800', 'Coastal Bedroom', 'Breezy whites and ocean blues', 'bedroom', ARRAY['coastal', 'beach', 'relaxed'], ARRAY['#F0F8FF', '#4682B4', '#F5F5DC']),
('https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800', 'Rustic Farmhouse', 'Reclaimed wood and vintage finds', 'living_room', ARRAY['farmhouse', 'rustic', 'vintage'], ARRAY['#8B4513', '#F5F5DC', '#696969']),
('https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=800', 'Art Deco Glam', 'Metallic accents and rich colors', 'living_room', ARRAY['art-deco', 'luxury', 'glamorous'], ARRAY['#FFD700', '#2F4F4F', '#8B0000']);

-- Set featured status for some
UPDATE design_inspirations SET featured = true WHERE id IN (
    SELECT id FROM design_inspirations ORDER BY RANDOM() LIMIT 3
);
