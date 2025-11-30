-- Row Level Security policies for user_swipes table
-- This enables users to insert and read their own swipe data

-- Enable RLS on the table
ALTER TABLE user_swipes ENABLE ROW LEVEL SECURITY;

-- Policy: Users can insert their own swipes
CREATE POLICY "Users can insert own swipes"
ON user_swipes
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can read their own swipes
CREATE POLICY "Users can read own swipes"
ON user_swipes
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Policy: Users can update their own swipes (in case we need to modify them later)
CREATE POLICY "Users can update own swipes"
ON user_swipes
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own swipes
CREATE POLICY "Users can delete own swipes"
ON user_swipes
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Also add RLS policies for user_preferences table
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

-- Policy: Users can read their own preferences
CREATE POLICY "Users can read own preferences"
ON user_preferences
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Policy: Users can insert their own preferences
CREATE POLICY "Users can insert own preferences"
ON user_preferences
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own preferences
CREATE POLICY "Users can update own preferences"
ON user_preferences
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
