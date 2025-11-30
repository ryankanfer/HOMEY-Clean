-- =============================================
-- HOMEY User Profiles Schema
-- =============================================
-- This schema creates the profiles table and associated triggers
-- for the new onboarding system
--
-- Run this file in Supabase SQL Editor BEFORE running the app
-- =============================================

-- Drop existing objects if they exist (for clean reinstall)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP TRIGGER IF EXISTS on_profile_updated ON profiles;
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS sync_onboarding_to_preferences() CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- =============================================
-- PROFILES TABLE
-- =============================================
CREATE TABLE profiles (
    -- Primary Key (references Supabase auth)
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Basic Contact Info
    email TEXT,
    full_name TEXT,
    display_name TEXT,
    phone TEXT,

    -- User Type & Location
    user_type TEXT CHECK (user_type IN ('renter', 'buyer', 'browser')),
    primary_location TEXT CHECK (primary_location IN ('new_york_city', 'chicago', 'los_angeles', 'miami')),
    neighborhoods TEXT[], -- Array of neighborhood names

    -- Budget & Requirements
    budget_min DECIMAL(12, 2),
    budget_max DECIMAL(12, 2),
    bedrooms INTEGER CHECK (bedrooms >= 0 AND bedrooms <= 10),
    bathrooms DECIMAL(3, 1) CHECK (bathrooms >= 0 AND bathrooms <= 10),

    -- NYC Renter Income Verification (40x rule)
    household_income DECIMAL(12, 2),
    income_verified BOOLEAN DEFAULT false,
    meets_40x_requirement BOOLEAN,

    -- Agent Status
    has_agent BOOLEAN,
    agent_name TEXT,
    agent_contact TEXT,

    -- Onboarding Progress Tracking
    onboarding_completed BOOLEAN DEFAULT false,
    onboarding_step INTEGER DEFAULT 0,
    onboarding_data JSONB DEFAULT '{}'::jsonb,
    onboarding_started_at TIMESTAMP WITH TIME ZONE,
    onboarding_completed_at TIMESTAMP WITH TIME ZONE,

    -- Feature Showcase Tracking
    feature_showcase_viewed BOOLEAN DEFAULT false,
    feature_showcase_completed_at TIMESTAMP WITH TIME ZONE,

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================
CREATE INDEX idx_profiles_user_type ON profiles(user_type);
CREATE INDEX idx_profiles_location ON profiles(primary_location);
CREATE INDEX idx_profiles_onboarding_completed ON profiles(onboarding_completed);
CREATE INDEX idx_profiles_created_at ON profiles(created_at DESC);
CREATE INDEX idx_profiles_neighborhoods ON profiles USING GIN(neighborhoods);

-- =============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Users can view their own profile
CREATE POLICY "Users can view own profile"
ON profiles
FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY "Users can insert own profile"
ON profiles
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Service role can do everything (for triggers)
CREATE POLICY "Service role has full access"
ON profiles
FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- =============================================
-- TRIGGER: Auto-create profile on user signup
-- =============================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.profiles (id, email, created_at)
    VALUES (
        NEW.id,
        NEW.email,
        NOW()
    );
    RETURN NEW;
END;
$$;

-- Attach trigger to auth.users
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();

-- =============================================
-- TRIGGER: Sync onboarding data to user_preferences
-- =============================================
CREATE OR REPLACE FUNCTION sync_onboarding_to_preferences()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
    -- Only sync if onboarding was just completed
    IF NEW.onboarding_completed = true AND (OLD.onboarding_completed IS NULL OR OLD.onboarding_completed = false) THEN

        -- UPSERT to user_preferences table
        INSERT INTO user_preferences (
            user_id,
            location,
            neighborhoods,
            min_price,
            max_price,
            bedrooms,
            bathrooms,
            property_types,
            user_type,
            has_agent,
            updated_at
        ) VALUES (
            NEW.id,
            NEW.primary_location,
            NEW.neighborhoods,
            NEW.budget_min,
            NEW.budget_max,
            CASE
                WHEN NEW.bedrooms IS NOT NULL THEN ARRAY[NEW.bedrooms]
                ELSE NULL
            END,
            CASE
                WHEN NEW.bathrooms IS NOT NULL THEN ARRAY[NEW.bathrooms]
                ELSE NULL
            END,
            CASE
                WHEN NEW.user_type = 'renter' THEN ARRAY['apartment', 'condo']
                WHEN NEW.user_type = 'buyer' THEN ARRAY['house', 'condo', 'townhouse']
                ELSE ARRAY['apartment', 'house', 'condo', 'townhouse']
            END,
            NEW.user_type,
            NEW.has_agent,
            NOW()
        )
        ON CONFLICT (user_id)
        DO UPDATE SET
            location = EXCLUDED.location,
            neighborhoods = EXCLUDED.neighborhoods,
            min_price = EXCLUDED.min_price,
            max_price = EXCLUDED.max_price,
            bedrooms = EXCLUDED.bedrooms,
            bathrooms = EXCLUDED.bathrooms,
            property_types = EXCLUDED.property_types,
            user_type = EXCLUDED.user_type,
            has_agent = EXCLUDED.has_agent,
            updated_at = NOW();

        -- Log that sync happened
        RAISE NOTICE 'Synced onboarding data for user % to user_preferences', NEW.id;
    END IF;

    RETURN NEW;
END;
$$;

-- Attach trigger to profiles table
CREATE TRIGGER on_profile_updated
    AFTER INSERT OR UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION sync_onboarding_to_preferences();

-- =============================================
-- HELPER FUNCTION: Check 40x income requirement
-- =============================================
CREATE OR REPLACE FUNCTION check_40x_requirement()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
    -- Only check for NYC renters
    IF NEW.primary_location = 'new_york_city' AND NEW.user_type = 'renter' THEN
        IF NEW.household_income IS NOT NULL AND NEW.budget_max IS NOT NULL THEN
            -- NYC requires 40x annual rent (budget_max is monthly)
            NEW.meets_40x_requirement := (NEW.household_income >= (NEW.budget_max * 40));
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

-- Attach 40x check trigger
CREATE TRIGGER check_income_requirement
    BEFORE INSERT OR UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION check_40x_requirement();

-- =============================================
-- INITIAL DATA / TESTING
-- =============================================
-- No initial data needed - profiles are created automatically on signup

-- =============================================
-- VERIFICATION QUERIES
-- =============================================
-- Run these queries after applying this schema to verify everything works:
--
-- 1. Check if profiles table exists:
--    SELECT * FROM information_schema.tables WHERE table_name = 'profiles';
--
-- 2. Check if triggers exist:
--    SELECT * FROM information_schema.triggers WHERE trigger_name IN ('on_auth_user_created', 'on_profile_updated');
--
-- 3. Check if RLS is enabled:
--    SELECT tablename, rowsecurity FROM pg_tables WHERE tablename = 'profiles';
--
-- 4. View all policies:
--    SELECT * FROM pg_policies WHERE tablename = 'profiles';
--
-- 5. Test profile creation (will be created automatically on signup):
--    SELECT * FROM profiles WHERE id = auth.uid();
--
-- =============================================
-- NOTES
-- =============================================
-- - This schema supports the new onboarding flow
-- - Profiles are auto-created when users sign up via Supabase Auth
-- - Onboarding data is automatically synced to user_preferences when completed
-- - NYC renters get automatic 40x income requirement checking
-- - All data is protected by RLS policies
-- - Indexes optimize common queries (by location, user type, etc.)
