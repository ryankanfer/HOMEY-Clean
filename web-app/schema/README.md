# Database Schema & Policies

This directory contains SQL schema files and Row Level Security (RLS) policies for the HOMEY app.

## 🚨 NEW ONBOARDING SYSTEM - REQUIRED SETUP

**IMPORTANT:** Before using the new onboarding flow, you MUST run `profiles_schema.sql` in Supabase SQL Editor!

The new onboarding system requires the `profiles` table and associated triggers. Without this, users won't be able to complete onboarding and their data won't be saved.

### Quick Start for New Onboarding:
1. Open Supabase Dashboard → SQL Editor
2. Run `/schema/profiles_schema.sql`
3. That's it! The new onboarding flow is ready.

This will create:
- ✅ `profiles` table with all onboarding fields
- ✅ Auto-create profile trigger on signup
- ✅ Sync onboarding data to `user_preferences` trigger
- ✅ NYC 40x income requirement validation
- ✅ Row Level Security policies

## 🚨 CRITICAL FIX: Onboarding Completion Error

**Error:** `column "location" (or "neighborhoods", etc.) of relation "user_preferences" does not exist`

**When it happens:** After completing onboarding, you get a 400 Bad Request error and are stuck in a redirect loop.

**Solution:** Run `fix_user_preferences.sql` in Supabase SQL Editor, OR paste this complete fix:

```sql
-- Add ALL missing columns that the onboarding trigger needs
ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS location TEXT;
ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS neighborhoods TEXT[];
ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS property_types TEXT[];
ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS user_type TEXT;
ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS has_agent BOOLEAN;
ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS min_price DECIMAL(12, 2);
ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS max_price DECIMAL(12, 2);
ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS bedrooms INTEGER[];
ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS bathrooms DECIMAL(3,1)[];
```

This adds all the missing columns that the onboarding trigger expects when syncing data to `user_preferences`.

After running this SQL:
1. Hard refresh your browser (`Cmd + Shift + R` on Mac, `Ctrl + Shift + R` on Windows)
2. Complete onboarding again
3. You should see "✅ Onboarding saved successfully" and be redirected to /home

## Applying SQL Files to Supabase

To apply these SQL files to your Supabase database:

1. **Open Supabase Dashboard**
   - Go to https://app.supabase.com
   - Select your project
   - Navigate to the "SQL Editor" in the left sidebar

2. **Run the Schema Files (in order)**
   ```
   1. profiles_schema.sql (REQUIRED for new onboarding!)
   2. listings_schema_clean.sql (or listings_schema.sql)
   3. matchmaker_schema.sql
   4. style_studio_schema.sql
   5. recommendations_schema.sql
   6. events_tracking_schema.sql
   ```

3. **Run the RLS Policy Files**
   ```
   1. user_swipes_rls_policies.sql
   2. style_studio_rls_policies.sql
   3. listings_rls_policies.sql (if needed)
   ```

## CRITICAL FIX: Property Swipes Not Recording

**Error:** `column "total_swipes" of relation "user_preferences" does not exist`

**Root Cause:** The `user_preferences` table is missing columns that the swipe trigger expects.

**Solution:** Run `fix_user_preferences.sql` in Supabase SQL Editor, OR run this:

```sql
-- Add missing columns to user_preferences table
ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS total_swipes INTEGER DEFAULT 0;
ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS total_likes INTEGER DEFAULT 0;
ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS total_loves INTEGER DEFAULT 0;
ALTER TABLE user_preferences ADD COLUMN IF NOT EXISTS avg_price_swiped_right DECIMAL(12, 2);
```

After running this, property swipes will work immediately! Test by swiping on a property and checking the browser console for "Swipe recorded successfully".

## Optional: RLS Policies

If you get "row-level security policy" errors after the above fix:

```sql
-- Enable RLS on user_swipes table
ALTER TABLE user_swipes ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to insert their own swipes
CREATE POLICY "Users can insert own swipes"
ON user_swipes
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Allow authenticated users to read their own swipes
CREATE POLICY "Users can read own swipes"
ON user_swipes
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);
```

## Debugging Database Issues

### Check if a table exists:
```sql
SELECT * FROM information_schema.tables
WHERE table_name = 'user_swipes';
```

### Check RLS status:
```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE tablename IN ('user_swipes', 'user_design_swipes');
```

### Check existing policies:
```sql
SELECT tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename IN ('user_swipes', 'user_design_swipes');
```

### Test insert permission:
```sql
-- This should work if RLS is properly configured
INSERT INTO user_swipes (user_id, listing_id, action)
VALUES (auth.uid(), 'some-listing-id', 'like');
```

## Common Issues

### Issue: "column 'location' (or 'neighborhoods', etc.) of relation 'user_preferences' does not exist"
**Solution:** Your `user_preferences` table is missing columns that the onboarding trigger needs. Run the complete fix from the "CRITICAL FIX" section at the top of this file (adds location, neighborhoods, property_types, user_type, has_agent columns).

### Issue: "column 'total_swipes' of relation 'user_preferences' does not exist"
**Solution:** Your database schema is out of sync. Run `fix_user_preferences.sql` to add the missing columns. This is the most common issue!

### Issue: "new row violates row-level security policy"
**Solution:** Run the RLS policy files above. This means RLS is enabled but no policies exist.

### Issue: "relation 'user_swipes' does not exist"
**Solution:** Run the `matchmaker_schema.sql` file first to create the table.

### Issue: Swipes work in Style Studio but not Matchmaker
**Solution:** Check the browser console for the actual error. Most likely it's the missing columns issue above, not RLS policies.
