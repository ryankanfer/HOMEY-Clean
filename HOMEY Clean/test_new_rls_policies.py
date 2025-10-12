#!/usr/bin/env python3
"""
Test script for RLS policies on new tables.

This script tests Row Level Security (RLS) policies for:
- profiles
- documents
- messages
- agent_invitation_codes
- invitation_usage_log
- document_access_log
- document_shares
- message_threads
- message_read_receipts
- message_reactions
- preferences
"""

import requests
import json
import os
import sys
from datetime import datetime

# Supabase configuration
SUPABASE_URL = os.getenv('SUPABASE_URL', 'https://mzqswvyfnblghgvcgxpw.supabase.co')
SUPABASE_ANON_KEY = os.getenv('SUPABASE_ANON_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im16cXN3dnlmbmJsZ2hndmNneHB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNjY0NzIsImV4cCI6MjA3MzY0MjQ3Mn0.0Tu75LEAY04Z1kbt98NJbXtYl3a_ChWA7qEEwWRauo0')

# Test user credentials
AGENT_EMAIL = "testagent@gmail.com"
AGENT_PASSWORD = "TestAgent123!"
CLIENT_EMAIL = "testclient@gmail.com" 
CLIENT_PASSWORD = "TestClient123!"

def make_request(method, endpoint, headers=None, data=None):
    """Make HTTP request to Supabase API"""
    url = f"{SUPABASE_URL}/rest/v1/{endpoint}"
    default_headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Content-Type': 'application/json'
    }
    if headers:
        default_headers.update(headers)
    
    try:
        if method == 'GET':
            response = requests.get(url, headers=default_headers)
        elif method == 'POST':
            response = requests.post(url, headers=default_headers, json=data)
        elif method == 'PATCH':
            response = requests.patch(url, headers=default_headers, json=data)
        elif method == 'DELETE':
            response = requests.delete(url, headers=default_headers)
        
        return response
    except Exception as e:
        print(f"Request failed: {e}")
        return None

def authenticate_user(email, password):
    """Authenticate user and return access token"""
    auth_url = f"{SUPABASE_URL}/auth/v1/token?grant_type=password"
    headers = {
        'apikey': SUPABASE_ANON_KEY,
        'Content-Type': 'application/json'
    }
    data = {
        'email': email,
        'password': password
    }
    
    response = requests.post(auth_url, headers=headers, json=data)
    if response.status_code == 200:
        return response.json().get('access_token')
    else:
        print(f"Authentication failed for {email}: {response.text}")
        return None

def test_table_access(table_name, token, description):
    """Test access to a specific table with given token"""
    print(f"\n--- Testing {table_name} ({description}) ---")
    
    headers = {'Authorization': f'Bearer {token}'} if token else {}
    
    # Test SELECT
    response = make_request('GET', table_name, headers)
    if response:
        if response.status_code == 200:
            data = response.json()
            print(f"✅ SELECT: Success - {len(data)} records returned")
        else:
            print(f"❌ SELECT: Failed - {response.status_code}: {response.text}")
    else:
        print(f"❌ SELECT: Request failed")
    
    # Test INSERT (with minimal data)
    test_data = get_test_data(table_name)
    if test_data:
        response = make_request('POST', table_name, headers, test_data)
        if response:
            if response.status_code in [200, 201]:
                print(f"✅ INSERT: Success")
                return response.json()
            else:
                print(f"❌ INSERT: Failed - {response.status_code}: {response.text}")
        else:
            print(f"❌ INSERT: Request failed")
    
    return None

def get_test_data(table_name):
    """Get test data for inserting into tables"""
    import uuid
    
    test_data = {
        'agent_client_links': {
            'agent_id': str(uuid.uuid4()),
            'client_id': str(uuid.uuid4()),
            'invited_by': str(uuid.uuid4()),
            'status': 'active'
        },
        'preferences': {
            'user_id': str(uuid.uuid4()),
            'budget': {'min': 1000, 'max': 2000},
            'neighborhoods': ['Manhattan'],
            'property_types': ['apartment']
        },
        'documents': {
            'user_id': str(uuid.uuid4()),
            'title': 'Test Document',
            'document_type': 'bank_statement',
            'file_url': 'https://example.com/test.pdf'
        },
        'messages': {
            'sender_id': str(uuid.uuid4()),
            'recipient_id': str(uuid.uuid4()),
            'content': 'Test message',
            'message_type': 'text'
        },
        'showing_requests': {
            'client_id': str(uuid.uuid4()),
            'property_id': str(uuid.uuid4()),
            'requested_date': datetime.now().isoformat(),
            'status': 'pending'
        },
        'client_agent_links': {
            'code': 'TEST123',
            'client_user_id': str(uuid.uuid4()),
            'status': 'pending'
        }
    }
    
    return test_data.get(table_name)

def test_rls_function():
    """Test the RLS policies verification function"""
    print("\n--- Testing RLS Policies Function ---")
    
    response = make_request('POST', 'rpc/test_rls_policies')
    if response and response.status_code == 200:
        policies = response.json()
        print(f"✅ Found {len(policies)} RLS policies:")
        for policy in policies:
            print(f"  - {policy['table_name']}: {policy['policy_name']}")
    else:
        print(f"❌ RLS function test failed: {response.status_code if response else 'No response'}")

def main():
    """Main test function"""
    print("🔒 Testing New RLS Policies for Agent-Client Tables")
    print("=" * 60)
    
    # Test tables to verify
    tables = [
        'agent_client_links',
        'preferences', 
        'documents',
        'messages',
        'showing_requests',
        'client_agent_links'
    ]
    
    # Test anonymous access (should be restricted)
    print("\n🔓 Testing Anonymous Access (should be restricted)")
    for table in tables:
        test_table_access(table, None, "Anonymous")
    
    # Test authenticated agent access
    print("\n👨‍💼 Testing Agent Access")
    agent_token = authenticate_user(AGENT_EMAIL, AGENT_PASSWORD)
    if agent_token:
        for table in tables:
            test_table_access(table, agent_token, "Agent")
    else:
        print("❌ Could not authenticate agent user")
    
    # Test authenticated client access  
    print("\n👤 Testing Client Access")
    client_token = authenticate_user(CLIENT_EMAIL, CLIENT_PASSWORD)
    if client_token:
        for table in tables:
            test_table_access(table, client_token, "Client")
    else:
        print("❌ Could not authenticate client user")
    
    # Test RLS policies function
    test_rls_function()
    
    print("\n" + "=" * 60)
    print("🏁 RLS Policy Testing Complete")
    print("\nRecommendations:")
    print("1. Anonymous access should be denied for all tables")
    print("2. Users should only access their own data or data they have permission for")
    print("3. Agent-client relationships should be properly enforced")
    print("4. All tables should have RLS enabled with appropriate policies")

if __name__ == "__main__":
    main()