#!/usr/bin/env python3
import requests
import json
import sys

# Supabase configuration
SUPABASE_URL = "https://mzqswvyfnblghgvcgxpw.supabase.co/"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im16cXN3dnlmbmJsZ2hndmNneHB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNjY0NzIsImV4cCI6MjA3MzY0MjQ3Mn0.0Tu75LEAY04Z1kbt98NJbXtYl3a_ChWA7qEEwWRauo0"

def create_admin_user(email, password, admin_token, referral_code=""):
    """Create an admin user using the create-admin-user Supabase function"""
    
    print(f"Creating admin user: {email}")
    print(f"Supabase URL: {SUPABASE_URL}")
    print("="*50)
    
    # Headers for the request
    headers = {
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "apikey": SUPABASE_ANON_KEY,
        "Content-Type": "application/json",
        "X-Admin-Token": admin_token
    }
    
    # Request body
    payload = {
        "email": email,
        "password": password,
        "token": "",  # Don't echo token back in body
        "referral_code": referral_code
    }
    
    try:
        # Call the create-admin-user function
        function_url = f"{SUPABASE_URL}/functions/v1/create-admin-user"
        print(f"Calling function: {function_url}")
        
        response = requests.post(function_url, headers=headers, json=payload)
        print(f"Response Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"\n✅ SUCCESS: Admin user created successfully!")
            print(f"Message: {result.get('message', 'No message')}")
            print(f"User ID: {result.get('user_id', 'No user ID')}")
            return result
        else:
            print(f"\n❌ ERROR: Failed to create admin user")
            print(f"Status: {response.status_code}")
            print(f"Response: {response.text}")
            return None
            
    except Exception as e:
        print(f"\n❌ EXCEPTION: {str(e)}")
        return None

def verify_admin_user(email):
    """Verify the admin user was created successfully"""
    
    print(f"\nVerifying admin user: {email}")
    print("="*30)
    
    headers = {
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "apikey": SUPABASE_ANON_KEY,
        "Content-Type": "application/json"
    }
    
    try:
        # Query the profiles table
        profiles_url = f"{SUPABASE_URL}/rest/v1/profiles?email=eq.{email}&select=*"
        response = requests.get(profiles_url, headers=headers)
        
        if response.status_code == 200:
            profiles = response.json()
            if profiles:
                user = profiles[0]
                print(f"✅ User found: {email}")
                print(f"User ID: {user.get('id')}")
                print(f"Role: {user.get('role')}")
                print(f"Full Name: {user.get('full_name')}")
                
                if user.get('role') == 'admin':
                    print(f"🎉 CONFIRMED: {email} has ADMIN privileges")
                else:
                    print(f"⚠️  WARNING: {email} does NOT have admin privileges")
                    print(f"Current role: {user.get('role')}")
                    
                return user
            else:
                print(f"❌ User not found: {email}")
        else:
            print(f"❌ Error querying profiles: {response.status_code} - {response.text}")
            
    except Exception as e:
        print(f"❌ Exception during verification: {str(e)}")
        
    return None

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 create_admin_user.py <admin_token> <password> [referral_code]")
        print("Example: python3 create_admin_user.py 'your-admin-token' 'secure-password'")
        sys.exit(1)
    
    admin_token = sys.argv[1]
    password = sys.argv[2]
    referral_code = sys.argv[3] if len(sys.argv) > 3 else ""
    
    email = "control.homie@gmail.com"
    
    print("HOMEY Clean - Admin User Creation")
    print("="*50)
    
    # Create the admin user
    result = create_admin_user(email, password, admin_token, referral_code)
    
    if result:
        # Verify the user was created
        verify_admin_user(email)
        
        print("\n" + "="*50)
        print("SUMMARY:")
        print("="*50)
        print(f"✅ Admin user creation completed for {email}")
        print("You can now run check_admin_status.py to verify the user has admin privileges.")
    else:
        print("\n" + "="*50)
        print("SUMMARY:")
        print("="*50)
        print(f"❌ Failed to create admin user for {email}")
        print("Please check the admin token and try again.")
        sys.exit(1)
