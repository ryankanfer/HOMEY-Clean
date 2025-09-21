#!/usr/bin/env python3
"""
Script to check RLS policies on the profiles table and test profile access.
This addresses the role fetching issue without generating excessive output.
"""

import os
from supabase import create_client, Client

def main():
    """Main function to test RLS policies and profile access"""
    
    # Get Supabase credentials
    url = os.getenv('SUPABASE_URL')
    anon_key = os.getenv('SUPABASE_ANON_KEY')
    
    if not url or not anon_key:
        print("❌ Missing SUPABASE_URL or SUPABASE_ANON_KEY environment variables")
        return
    
    print("🔍 Checking RLS policies and profile access...")
    print(f"Supabase URL: {url}")
    
    # Create Supabase client
    supabase: Client = create_client(url, anon_key)
    
    # Test 1: Check if we can query profiles table without authentication
    print("\n📋 Test 1: Anonymous access to profiles table")
    try:
        response = supabase.table('profiles').select('id, email, role').limit(1).execute()
        if response.data:
            print("✅ Anonymous users can read profiles (RLS may be too permissive)")
            print(f"Sample data: {response.data[0]}")
        else:
            print("ℹ️ No data returned for anonymous query")
    except Exception as e:
        print(f"❌ Anonymous access blocked: {str(e)}")
    
    # Test 2: Try to authenticate and check profile access
    print("\n🔐 Test 2: Authenticated user profile access")
    email = "control.homie@gmail.com"
    password = input(f"Enter password for {email} (or press Enter to skip): ").strip()
    
    if password:
        try:
            # Sign in
            auth_response = supabase.auth.sign_in_with_password({
                "email": email,
                "password": password
            })
            
            if auth_response.user:
                print(f"✅ Successfully authenticated as {email}")
                user_id = auth_response.user.id
                print(f"User ID: {user_id}")
                
                # Try to fetch own profile
                profile_response = supabase.table('profiles').select('id, email, role, client_segment').eq('id', user_id).execute()
                
                if profile_response.data:
                    profile = profile_response.data[0]
                    print(f"✅ Successfully fetched profile: {profile}")
                    
                    if profile.get('role') == 'admin':
                        print("🎯 User has admin role in database")
                    else:
                        print(f"⚠️ User role is: {profile.get('role', 'None')}")
                else:
                    print("❌ Could not fetch user profile - RLS policy issue detected")
                    
            else:
                print("❌ Authentication failed")
                
        except Exception as e:
            print(f"❌ Authentication or profile fetch error: {str(e)}")
    else:
        print("⏭️ Skipping authenticated test")
    
    # Test 3: Check RLS policy information
    print("\n🛡️ Test 3: RLS Policy Analysis")
    try:
        # Query pg_policies to see RLS policies (this might not work with anon key)
        policies_response = supabase.rpc('get_policies_info').execute()
        if policies_response.data:
            print("📜 RLS Policies found:")
            for policy in policies_response.data:
                print(f"  - {policy}")
        else:
            print("ℹ️ Could not retrieve policy information (expected with anon key)")
    except Exception as e:
        print(f"ℹ️ Policy query not available: {str(e)}")
    
    print("\n💡 Recommendations:")
    print("1. If anonymous access works but authenticated doesn't, RLS policies are blocking user access")
    print("2. The profiles table should allow users to read their own profile: auth.uid() = id")
    print("3. Check Supabase dashboard > Authentication > Policies for the profiles table")
    print("4. Common fix: CREATE POLICY \"Users can view own profile\" ON profiles FOR SELECT USING (auth.uid() = id);")

if __name__ == "__main__":
    main()