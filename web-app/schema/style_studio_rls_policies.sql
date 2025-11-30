-- Row Level Security policies for Style Studio tables

-- Enable RLS on user_design_swipes
ALTER TABLE user_design_swipes ENABLE ROW LEVEL SECURITY;

-- Policy: Users can insert their own design swipes
CREATE POLICY "Users can insert own design swipes"
ON user_design_swipes
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can read their own design swipes
CREATE POLICY "Users can read own design swipes"
ON user_design_swipes
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Policy: Users can delete their own design swipes
CREATE POLICY "Users can delete own design swipes"
ON user_design_swipes
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Enable RLS on user_mood_boards
ALTER TABLE user_mood_boards ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read their own mood boards
CREATE POLICY "Users can read own mood boards"
ON user_mood_boards
FOR SELECT
TO authenticated
USING (auth.uid() = user_id OR is_public = true);

-- Policy: Users can insert their own mood boards
CREATE POLICY "Users can insert own mood boards"
ON user_mood_boards
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own mood boards
CREATE POLICY "Users can update own mood boards"
ON user_mood_boards
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own mood boards
CREATE POLICY "Users can delete own mood boards"
ON user_mood_boards
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Enable RLS on mood_board_items
ALTER TABLE mood_board_items ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read items from their own or public mood boards
CREATE POLICY "Users can read mood board items"
ON mood_board_items
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_mood_boards
    WHERE user_mood_boards.id = mood_board_items.mood_board_id
    AND (user_mood_boards.user_id = auth.uid() OR user_mood_boards.is_public = true)
  )
);

-- Policy: Users can insert items to their own mood boards
CREATE POLICY "Users can insert mood board items"
ON mood_board_items
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM user_mood_boards
    WHERE user_mood_boards.id = mood_board_items.mood_board_id
    AND user_mood_boards.user_id = auth.uid()
  )
);

-- Policy: Users can delete items from their own mood boards
CREATE POLICY "Users can delete mood board items"
ON mood_board_items
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_mood_boards
    WHERE user_mood_boards.id = mood_board_items.mood_board_id
    AND user_mood_boards.user_id = auth.uid()
  )
);

-- Enable RLS on user_style_preferences
ALTER TABLE user_style_preferences ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read their own style preferences
CREATE POLICY "Users can read own style preferences"
ON user_style_preferences
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Policy: Users can insert their own style preferences
CREATE POLICY "Users can insert own style preferences"
ON user_style_preferences
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own style preferences
CREATE POLICY "Users can update own style preferences"
ON user_style_preferences
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Enable RLS on design_inspirations (read-only for all authenticated users)
ALTER TABLE design_inspirations ENABLE ROW LEVEL SECURITY;

-- Policy: All authenticated users can read design inspirations
CREATE POLICY "Authenticated users can read design inspirations"
ON design_inspirations
FOR SELECT
TO authenticated
USING (is_active = true);
