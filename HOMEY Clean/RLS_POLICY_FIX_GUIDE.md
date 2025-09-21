# RLS Policy Fix Guide

## Problem Identified

✅ **Root Cause Found**: The Supabase profiles table has **infinite recursion in RLS policies**.

### Error Details
- **Error**: `infinite recursion detected in policy for relation "profiles"`
- **Impact**: Authenticated users cannot fetch their profile data, causing the iOS app to default all users to "client" role
- **Result**: `control.homie@gmail.com` appears as admin in Supabase but cannot access admin features in the app

## Solution

### Step 1: Access Supabase Dashboard
1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Navigate to your project: `fafbjfajmmsjftiivhil`
3. Go to **SQL Editor**

### Step 2: Execute the Fix
1. Copy the contents of `fix_rls_policies.sql`
2. Paste into Supabase SQL Editor
3. Click **Run** to execute the commands

> **Note**: If you see an error like `ERROR: 42710: policy "users_select_own_profile" already exists`, it means some policies already exist. The updated script handles this by explicitly dropping each policy before creating it.

### Step 3: Verify the Fix
After running the SQL commands, test the fix:

```bash
# Run the RLS policy check again
export SUPABASE_URL="https://mzqswvyfnblghgvcgxpw.supabase.co/"
export SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im16cXN3dnlmbmJsZ2hndmNneHB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNjY0NzIsImV4cCI6MjA3MzY0MjQ3Mn0.0Tu75LEAY04Z1kbt98NJbXtYl3a_ChWA7qEEwWRauo0"
python3 check_rls_policies.py
```

You should see:
- ✅ Successfully authenticated as control.homie@gmail.com
- ✅ Successfully fetched profile with admin role

### Step 4: Test iOS App
1. Build and run the iOS app
2. Sign in as `control.homie@gmail.com`
3. Verify that admin tabs (Admin Dashboard, Agent Dashboard, TRAE Demo) are now visible

## What the Fix Does

### Removes Problematic Policies
- Drops all existing RLS policies that may contain recursive references
- Clears any circular dependencies

### Creates Simple, Safe Policies
- **users_select_own_profile**: Users can read their own profile using `auth.uid() = id`
- **users_update_own_profile**: Users can update their own profile
- **users_insert_own_profile**: New users can create their profile during signup

### Key Principles
1. **Direct Comparison**: Uses `auth.uid() = id` without subqueries
2. **No Self-Reference**: Policies don't query the profiles table within their conditions
3. **Operation-Specific**: Separate policies for SELECT, UPDATE, INSERT

## Common Causes of Infinite Recursion

❌ **Bad Policy Example**:
```sql
CREATE POLICY "bad_policy" ON profiles
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM profiles p 
            WHERE p.id = auth.uid() 
            AND p.role = 'admin'
        )
    );
```

✅ **Good Policy Example**:
```sql
CREATE POLICY "good_policy" ON profiles
    FOR SELECT
    USING (auth.uid() = id);
```

## Expected Outcome

After applying this fix:
1. `control.homie@gmail.com` will be able to fetch their profile data
2. The iOS app will correctly identify them as an admin
3. Admin-specific features will become accessible
4. Role switching in settings will work properly

## Troubleshooting

If the fix doesn't work:
1. Check that all policies were dropped successfully
2. Verify RLS is enabled: `ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;`
3. Test with a simple query: `SELECT * FROM profiles WHERE id = auth.uid();`
4. Check Supabase logs for any remaining policy errors
