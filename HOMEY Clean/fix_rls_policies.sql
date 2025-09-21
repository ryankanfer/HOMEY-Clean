-- Fix for infinite recursion in RLS policies on profiles table
-- Execute these commands in Supabase SQL Editor

-- Step 1: Drop all existing policies on profiles table to clear infinite recursion
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Enable read access for all users" ON profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON profiles;
DROP POLICY IF EXISTS "Enable update for users based on email" ON profiles;
DROP POLICY IF EXISTS "Allow users to view their own profile" ON profiles;
DROP POLICY IF EXISTS "Allow users to update their own profile" ON profiles;

-- Step 2: Create simple, non-recursive RLS policies

-- Allow users to read their own profile
DROP POLICY IF EXISTS "users_select_own_profile" ON profiles;
CREATE POLICY "users_select_own_profile" ON profiles
    FOR SELECT
    USING (auth.uid() = id);

-- Allow users to update their own profile
DROP POLICY IF EXISTS "users_update_own_profile" ON profiles;
CREATE POLICY "users_update_own_profile" ON profiles
    FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Allow authenticated users to insert their own profile (for new signups)
DROP POLICY IF EXISTS "users_insert_own_profile" ON profiles;
CREATE POLICY "users_insert_own_profile" ON profiles
    FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Optional: Allow admins to read all profiles (if needed)
-- Uncomment the following if admin users need to see all profiles
/*
CREATE POLICY "admins_select_all_profiles" ON profiles
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM profiles p 
            WHERE p.id = auth.uid() 
            AND p.role = 'admin'
        )
    );
*/

-- Step 3: Ensure RLS is enabled on the profiles table
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Step 4: Verify the policies are working
-- You can test this by running:
-- SELECT * FROM profiles WHERE id = auth.uid();

-- Common causes of infinite recursion:
-- 1. Policy references the same table it's protecting in a subquery
-- 2. Circular dependencies between policies
-- 3. Complex nested queries that reference auth.uid() multiple times

-- The policies above are simple and avoid these issues by:
-- 1. Using direct auth.uid() = id comparison
-- 2. Not referencing the profiles table within the policy condition
-- 3. Being specific about the operation (SELECT, UPDATE, INSERT)