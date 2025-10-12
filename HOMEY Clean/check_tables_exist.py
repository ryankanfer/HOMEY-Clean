#!/usr/bin/env python3
"""
Check which tables exist in the Supabase database before implementing RLS policies.
"""

import requests
import json
import os

# Supabase configuration
SUPABASE_URL = os.getenv('SUPABASE_URL', 'https://mzqswvyfnblghgvcgxpw.supabase.co')
SUPABASE_ANON_KEY = os.getenv('SUPABASE_ANON_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im16cXN3dnlmbmJsZ2hndmNneHB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNjY0NzIsImV4cCI6MjA3MzY0MjQ3Mn0.0Tu75LEAY04Z1kbt98NJbXtYl3a_ChWA7qEEwWRauo0')

def check_table_exists(table_name):
    """Check if a table exists by trying to query it"""
    headers = {
        "Authorization": f"Bearer {SUPABASE_ANON_KEY}",
        "apikey": SUPABASE_ANON_KEY,
        "Content-Type": "application/json"
    }
    
    try:
        # Try to query the table with a limit of 0 to just check existence
        url = f"{SUPABASE_URL}/rest/v1/{table_name}?limit=0"
        response = requests.get(url, headers=headers)
        
        if response.status_code == 200:
            return True, "Table exists"
        elif response.status_code == 404:
            return False, "Table not found"
        elif "relation" in response.text and "does not exist" in response.text:
            return False, "Table does not exist"
        else:
            return False, f"Error: {response.status_code} - {response.text[:100]}"
    except Exception as e:
        return False, f"Exception: {str(e)}"

def main():
    print("🔍 Checking Database Tables")
    print("=" * 50)
    
    # Tables we want to check for RLS policies
    tables_to_check = [
        'agent_client_links',
        'preferences', 
        'documents',
        'messages',
        'showing_requests',
        'client_agent_links',
        'profiles'
    ]
    
    existing_tables = []
    missing_tables = []
    
    for table in tables_to_check:
        exists, message = check_table_exists(table)
        status = "✅" if exists else "❌"
        print(f"{status} {table:<25} - {message}")
        
        if exists:
            existing_tables.append(table)
        else:
            missing_tables.append(table)
    
    print("\n" + "=" * 50)
    print("📊 Summary")
    print("=" * 50)
    print(f"✅ Existing tables ({len(existing_tables)}):")
    for table in existing_tables:
        print(f"   - {table}")
    
    if missing_tables:
        print(f"\n❌ Missing tables ({len(missing_tables)}):")
        for table in missing_tables:
            print(f"   - {table}")
        
        print(f"\n💡 Recommendations:")
        print("1. Create missing tables before implementing RLS policies")
        print("2. Update RLS policy script to only target existing tables")
        print("3. Review application code to ensure it matches database schema")
    else:
        print("\n🎉 All tables exist! Ready to implement RLS policies.")

if __name__ == "__main__":
    main()