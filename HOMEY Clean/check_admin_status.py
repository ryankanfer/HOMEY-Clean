#!/usr/bin/env python3
import requests
import json

# Supabase configuration
SUPABASE_URL = "https://mzqswvyfnblghgvcgxpw.supabase.co/"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im16cXN3dnlmbmJsZ2hndmNneHB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNjY0NzIsImV4cCI6MjA3MzY0MjQ3Mn0.0Tu75LEAY04Z1kbt98NJbXtYl3a_ChWA7qEEwWRauo0"

def check_user_admin_status(email):
    """Check if a user has admin privileges in Supabase"""
    
    print(f"Checking admin status for: {email}")
    print(f"Supabase URL: {SUPABASE_URL}")
    print("="*50)
    
    # Try different approaches to access user data
    headers = {
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "apikey": SUPABASE_ANON_KEY,
        "Content-Type": "application/json"
    }
    
    # Approach 1: Try to query profiles with email filter
    try:
        print("Approach 1: Querying profiles with email filter...")
        profiles_url = f"{SUPABASE_URL}/rest/v1/profiles?email=eq.{email}&select=*"
        response = requests.get(profiles_url, headers=headers)
        print(f"Response Status: {response.status_code}")
        
        if response.status_code == 200:
            profiles = response.json()
            if profiles:
                user = profiles[0]
                print(f"\n✅ User found via email filter: {email}")
                print(f"User ID: {user.get('id')}")
                print(f"Role: {user.get('role')}")
                print(f"Full Name: {user.get('full_name')}")
                print(f"Client Segment: {user.get('client_segment')}")
                
                if user.get('role') == 'admin':
                    print(f"\n🎉 CONFIRMED: {email} has ADMIN privileges")
                else:
                    print(f"\n⚠️  WARNING: {email} does NOT have admin privileges")
                    print(f"Current role: {user.get('role')}")
                    
                return user
            else:
                print(f"No user found with email: {email}")
        else:
            print(f"Error: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"Approach 1 failed: {str(e)}")
    
    # Approach 2: Try to query admin users specifically
    try:
        print("\nApproach 2: Querying admin role users...")
        admin_url = f"{SUPABASE_URL}/rest/v1/profiles?role=eq.admin&select=*"
        response = requests.get(admin_url, headers=headers)
        print(f"Response Status: {response.status_code}")
        
        if response.status_code == 200:
            admins = response.json()
            print(f"Found {len(admins)} admin users")
            
            target_admin = None
            for admin in admins:
                print(f"  - Admin: {admin.get('email')} (ID: {admin.get('id')})")
                if admin.get('email') == email:
                    target_admin = admin
            
            if target_admin:
                print(f"\n🎉 CONFIRMED: {email} is in the admin users list")
                return target_admin
            else:
                print(f"\n⚠️  {email} is NOT in the admin users list")
        else:
            print(f"Error querying admins: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"Approach 2 failed: {str(e)}")
    
    # Approach 3: Try auth endpoint (might not work with anon key)
    try:
        print("\nApproach 3: Checking auth users endpoint...")
        auth_url = f"{SUPABASE_URL}/auth/v1/admin/users"
        response = requests.get(auth_url, headers=headers)
        print(f"Auth endpoint status: {response.status_code}")
        
        if response.status_code != 200:
            print(f"Auth endpoint not accessible with anon key: {response.text[:200]}")
    except Exception as e:
        print(f"Approach 3 failed: {str(e)}")
    
    return None

def check_database_structure():
    """Check what tables and data we can access"""
    print("\n" + "="*50)
    print("CHECKING DATABASE STRUCTURE")
    print("="*50)
    
    headers = {
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "apikey": SUPABASE_ANON_KEY,
        "Content-Type": "application/json"
    }
    
    # Check what we can access
    endpoints_to_try = [
        "/rest/v1/",  # List available tables
        "/rest/v1/profiles?select=email,role&limit=5",  # Try to get limited profile data
    ]
    
    for endpoint in endpoints_to_try:
        try:
            url = f"{SUPABASE_URL}{endpoint}"
            print(f"\nTrying: {endpoint}")
            response = requests.get(url, headers=headers)
            print(f"Status: {response.status_code}")
            
            if response.status_code == 200:
                data = response.json()
                if isinstance(data, list) and len(data) > 0:
                    print(f"Sample data: {json.dumps(data[0], indent=2)}")
                else:
                    print(f"Response: {json.dumps(data, indent=2)[:500]}")
            else:
                print(f"Error: {response.text[:200]}")
        except Exception as e:
            print(f"Error with {endpoint}: {str(e)}")

if __name__ == "__main__":
    email_to_check = "control.homie@gmail.com"
    
    # First check database structure
    check_database_structure()
    
    # Then check specific user
    print("\n" + "="*50)
    print("CHECKING SPECIFIC USER")
    print("="*50)
    
    result = check_user_admin_status(email_to_check)
    
    print("\n" + "="*50)
    print("FINAL SUMMARY:")
    print("="*50)
    if result:
        print(f"Email: {email_to_check}")
        print(f"Admin Status: {'✅ YES' if result.get('role') == 'admin' else '❌ NO'}")
        print(f"Current Role: {result.get('role')}")
    else:
        print(f"❌ Could not verify admin status for {email_to_check}")
        print("This could be due to:")
        print("  - User doesn't exist in the database")
        print("  - Database policy restrictions")
        print("  - Insufficient permissions with anon key")
