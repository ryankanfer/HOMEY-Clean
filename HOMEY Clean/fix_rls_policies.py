#!/usr/bin/env python3
import requests
import json

# Supabase configuration
SUPABASE_URL = "https://mzqswvyfnblghgvcgxpw.supabase.co/"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im16cXN3dnlmbmJsZ2hndmNneHB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNjY0NzIsImV4cCI6MjA3MzY0MjQ3Mn0.0Tu75LEAY04Z1kbt98NJbXtYl3a_ChWA7qEEwWRauo0"

# Read the SQL fix file
with open('fix_rls_policies.sql', 'r') as f:
    sql_content = f.read()

print("Executing RLS policy fix...")
print(f"SQL content length: {len(sql_content)} characters")

# Execute the SQL via Supabase REST API
headers = {
    'apikey': SUPABASE_ANON_KEY,
    'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
    'Content-Type': 'application/json'
}

# Try to execute the SQL using the SQL editor endpoint
url = f"{SUPABASE_URL}/rest/v1/rpc/exec_sql"
payload = {
    'sql': sql_content
}

try:
    response = requests.post(url, headers=headers, json=payload)
    print(f"Response status: {response.status_code}")
    print(f"Response content: {response.text}")
    
    if response.status_code == 200:
        print("✅ RLS policies fixed successfully!")
    else:
        print(f"❌ Failed to execute SQL: {response.status_code}")
        print(f"Error details: {response.text}")
        
except Exception as e:
    print(f"❌ Error executing SQL fix: {str(e)}")

print("\nRLS policy fix attempt completed.")
print("If successful, users should now be able to maintain login sessions.")
