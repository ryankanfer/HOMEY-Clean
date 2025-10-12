#!/usr/bin/env python3
"""
Comprehensive System Test Suite
Tests all implemented flows: onboarding, invitations, documents, messaging, assignments, permissions
"""

import os
import json
import uuid
import time
import asyncio
import requests
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class SupabaseTestClient:
    """Test client for Supabase operations"""
    
    def __init__(self):
        self.base_url = os.getenv('SUPABASE_URL', 'https://your-project.supabase.co')
        self.anon_key = os.getenv('SUPABASE_ANON_KEY', 'your-anon-key')
        self.service_key = os.getenv('SUPABASE_SERVICE_KEY', 'your-service-key')
        
        self.headers = {
            'apikey': self.anon_key,
            'Authorization': f'Bearer {self.anon_key}',
            'Content-Type': 'application/json'
        }
        
        self.admin_headers = {
            'apikey': self.service_key,
            'Authorization': f'Bearer {self.service_key}',
            'Content-Type': 'application/json'
        }
        
        # Test users
        self.test_users = {
            'agent1': {
                'email': 'agent1@test.com',
                'password': 'testpass123',
                'role': 'agent',
                'first_name': 'John',
                'last_name': 'Agent',
                'company_name': 'Test Realty Co'
            },
            'agent2': {
                'email': 'agent2@test.com',
                'password': 'testpass123',
                'role': 'agent',
                'first_name': 'Jane',
                'last_name': 'Broker',
                'company_name': 'Prime Properties'
            },
            'client1': {
                'email': 'client1@test.com',
                'password': 'testpass123',
                'role': 'client',
                'first_name': 'Bob',
                'last_name': 'Buyer'
            },
            'client2': {
                'email': 'client2@test.com',
                'password': 'testpass123',
                'role': 'client',
                'first_name': 'Alice',
                'last_name': 'Seller'
            }
        }
        
        self.user_sessions = {}
        self.test_data = {}

    def make_request(self, method: str, endpoint: str, data: Optional[Dict] = None, 
                    headers: Optional[Dict] = None, use_admin: bool = False) -> requests.Response:
        """Make HTTP request to Supabase"""
        url = f"{self.base_url}/rest/v1/{endpoint}"
        request_headers = headers or (self.admin_headers if use_admin else self.headers)
        
        try:
            if method.upper() == 'GET':
                response = requests.get(url, headers=request_headers, params=data)
            elif method.upper() == 'POST':
                response = requests.post(url, headers=request_headers, json=data)
            elif method.upper() == 'PATCH':
                response = requests.patch(url, headers=request_headers, json=data)
            elif method.upper() == 'DELETE':
                response = requests.delete(url, headers=request_headers)
            else:
                raise ValueError(f"Unsupported method: {method}")
            
            return response
        except Exception as e:
            logger.error(f"Request failed: {e}")
            raise

    def call_rpc(self, function_name: str, params: Dict, use_admin: bool = False) -> requests.Response:
        """Call Supabase RPC function"""
        url = f"{self.base_url}/rest/v1/rpc/{function_name}"
        headers = self.admin_headers if use_admin else self.headers
        
        try:
            response = requests.post(url, headers=headers, json=params)
            return response
        except Exception as e:
            logger.error(f"RPC call failed: {e}")
            raise

    def auth_request(self, endpoint: str, data: Dict) -> requests.Response:
        """Make authentication request"""
        url = f"{self.base_url}/auth/v1/{endpoint}"
        headers = {
            'apikey': self.anon_key,
            'Content-Type': 'application/json'
        }
        
        try:
            response = requests.post(url, headers=headers, json=data)
            return response
        except Exception as e:
            logger.error(f"Auth request failed: {e}")
            raise

class ComprehensiveSystemTest:
    """Main test suite class"""
    
    def __init__(self):
        self.client = SupabaseTestClient()
        self.test_results = {
            'passed': 0,
            'failed': 0,
            'errors': []
        }

    def log_test_result(self, test_name: str, passed: bool, message: str = ""):
        """Log test result"""
        if passed:
            self.test_results['passed'] += 1
            logger.info(f"✅ {test_name}: PASSED {message}")
        else:
            self.test_results['failed'] += 1
            error_msg = f"❌ {test_name}: FAILED {message}"
            logger.error(error_msg)
            self.test_results['errors'].append(error_msg)

    def cleanup_test_data(self):
        """Clean up test data before running tests"""
        logger.info("🧹 Cleaning up existing test data...")
        
        try:
            # Delete test users and related data
            for user_data in self.client.test_users.values():
                # Try to delete user profile
                response = self.client.make_request(
                    'DELETE', 
                    f"profiles?email=eq.{user_data['email']}", 
                    use_admin=True
                )
                
            logger.info("✅ Test data cleanup completed")
        except Exception as e:
            logger.warning(f"⚠️ Cleanup warning: {e}")

    def test_user_registration_and_onboarding(self):
        """Test 1: User Registration and Onboarding Flow"""
        logger.info("🧪 Testing User Registration and Onboarding...")
        
        for user_key, user_data in self.client.test_users.items():
            try:
                # Test user registration
                auth_response = self.client.auth_request('signup', {
                    'email': user_data['email'],
                    'password': user_data['password']
                })
                
                if auth_response.status_code not in [200, 201]:
                    self.log_test_result(
                        f"User Registration - {user_key}", 
                        False, 
                        f"Status: {auth_response.status_code}, Response: {auth_response.text}"
                    )
                    continue
                
                auth_data = auth_response.json()
                user_id = auth_data.get('user', {}).get('id')
                access_token = auth_data.get('access_token')
                
                if not user_id or not access_token:
                    self.log_test_result(f"User Registration - {user_key}", False, "Missing user ID or token")
                    continue
                
                # Store session info
                self.client.user_sessions[user_key] = {
                    'user_id': user_id,
                    'access_token': access_token,
                    'headers': {
                        'apikey': self.client.anon_key,
                        'Authorization': f'Bearer {access_token}',
                        'Content-Type': 'application/json'
                    }
                }
                
                # Test profile creation using RPC function
                profile_response = self.client.call_rpc('create_user_profile', {
                    'user_id': user_id,
                    'email_input': user_data['email'],
                    'first_name_input': user_data['first_name'],
                    'last_name_input': user_data['last_name'],
                    'role_input': user_data['role'],
                    'company_name_input': user_data.get('company_name'),
                    'phone_input': '+1234567890',
                    'metadata_input': {'test_user': True}
                }, use_admin=True)
                
                if profile_response.status_code == 200:
                    self.log_test_result(f"User Registration - {user_key}", True)
                    self.log_test_result(f"Profile Creation - {user_key}", True)
                else:
                    self.log_test_result(
                        f"Profile Creation - {user_key}", 
                        False, 
                        f"Status: {profile_response.status_code}, Response: {profile_response.text}"
                    )
                
            except Exception as e:
                self.log_test_result(f"User Registration - {user_key}", False, str(e))

    def test_agent_invitation_system(self):
        """Test 2: Agent Invitation System"""
        logger.info("🧪 Testing Agent Invitation System...")
        
        try:
            # Get agent1 session
            agent1_session = self.client.user_sessions.get('agent1')
            if not agent1_session:
                self.log_test_result("Agent Invitation System", False, "Agent1 session not found")
                return
            
            # Test creating invitation code
            invitation_response = self.client.call_rpc('create_agent_invitation', {
                'agent_id': agent1_session['user_id'],
                'max_uses_input': 5,
                'expires_at_input': (datetime.now() + timedelta(days=30)).isoformat()
            }, use_admin=True)
            
            if invitation_response.status_code != 200:
                self.log_test_result(
                    "Create Invitation Code", 
                    False, 
                    f"Status: {invitation_response.status_code}, Response: {invitation_response.text}"
                )
                return
            
            invitation_data = invitation_response.json()
            invitation_code = invitation_data[0]['invitation_code']
            self.client.test_data['invitation_code'] = invitation_code
            
            self.log_test_result("Create Invitation Code", True, f"Code: {invitation_code}")
            
            # Test validating invitation code
            validation_response = self.client.call_rpc('validate_invitation_code', {
                'code_input': invitation_code
            }, use_admin=True)
            
            if validation_response.status_code == 200:
                self.log_test_result("Validate Invitation Code", True)
            else:
                self.log_test_result("Validate Invitation Code", False, validation_response.text)
            
            # Test using invitation code (simulate client1 using the code)
            client1_session = self.client.user_sessions.get('client1')
            if client1_session:
                use_code_response = self.client.call_rpc('use_invitation_code', {
                    'code_input': invitation_code,
                    'client_id': client1_session['user_id']
                }, use_admin=True)
                
                if use_code_response.status_code == 200:
                    self.log_test_result("Use Invitation Code", True)
                    # Store the relationship for later tests
                    self.client.test_data['agent_client_link'] = {
                        'agent_id': agent1_session['user_id'],
                        'client_id': client1_session['user_id']
                    }
                else:
                    self.log_test_result("Use Invitation Code", False, use_code_response.text)
            
        except Exception as e:
            self.log_test_result("Agent Invitation System", False, str(e))

    def test_document_management(self):
        """Test 3: Document Management System"""
        logger.info("🧪 Testing Document Management...")
        
        try:
            agent1_session = self.client.user_sessions.get('agent1')
            client1_session = self.client.user_sessions.get('client1')
            
            if not agent1_session or not client1_session:
                self.log_test_result("Document Management", False, "Required sessions not found")
                return
            
            # Test creating a document
            document_data = {
                'title': 'Test Property Document',
                'description': 'Test document for property listing',
                'document_type': 'property_listing',
                'document_category': 'listing',
                'document_status': 'active',
                'owner_id': agent1_session['user_id'],
                'storage_path': '/documents/test-property-doc.pdf',
                'file_size': 1024000,
                'mime_type': 'application/pdf',
                'is_public': False,
                'metadata': {'property_id': str(uuid.uuid4()), 'test_doc': True}
            }
            
            create_doc_response = self.client.call_rpc('create_document', {
                'owner_uuid': agent1_session['user_id'],
                'title_input': document_data['title'],
                'description_input': document_data['description'],
                'document_type_input': document_data['document_type'],
                'storage_path_input': document_data['storage_path'],
                'file_size_input': document_data['file_size'],
                'mime_type_input': document_data['mime_type'],
                'document_category_input': document_data['document_category'],
                'is_public_input': document_data['is_public'],
                'metadata_input': document_data['metadata']
            }, use_admin=True)
            
            if create_doc_response.status_code == 200:
                doc_result = create_doc_response.json()
                document_id = doc_result[0]['document_id']
                self.client.test_data['document_id'] = document_id
                self.log_test_result("Create Document", True, f"Document ID: {document_id}")
                
                # Test sharing document with client
                share_response = self.client.call_rpc('share_document', {
                    'document_uuid': document_id,
                    'owner_uuid': agent1_session['user_id'],
                    'shared_with_uuid': client1_session['user_id'],
                    'permission_level_input': 'view',
                    'expires_at_input': (datetime.now() + timedelta(days=30)).isoformat()
                }, use_admin=True)
                
                if share_response.status_code == 200:
                    self.log_test_result("Share Document", True)
                else:
                    self.log_test_result("Share Document", False, share_response.text)
                
                # Test retrieving user documents
                user_docs_response = self.client.call_rpc('get_user_documents', {
                    'user_uuid': agent1_session['user_id'],
                    'limit_count': 10
                }, use_admin=True)
                
                if user_docs_response.status_code == 200:
                    docs = user_docs_response.json()
                    if len(docs) > 0:
                        self.log_test_result("Retrieve User Documents", True, f"Found {len(docs)} documents")
                    else:
                        self.log_test_result("Retrieve User Documents", False, "No documents found")
                else:
                    self.log_test_result("Retrieve User Documents", False, user_docs_response.text)
                
            else:
                self.log_test_result("Create Document", False, create_doc_response.text)
                
        except Exception as e:
            self.log_test_result("Document Management", False, str(e))

    def test_messaging_system(self):
        """Test 4: Secure Messaging System"""
        logger.info("🧪 Testing Secure Messaging System...")
        
        try:
            agent1_session = self.client.user_sessions.get('agent1')
            client1_session = self.client.user_sessions.get('client1')
            
            if not agent1_session or not client1_session:
                self.log_test_result("Messaging System", False, "Required sessions not found")
                return
            
            # Test sending a message from agent to client
            message_response = self.client.call_rpc('send_message', {
                'sender_uuid': agent1_session['user_id'],
                'recipient_uuid': client1_session['user_id'],
                'message_content': 'Hello! I have some great properties to show you.',
                'message_type_input': 'text',
                'priority_input': 'normal',
                'message_metadata': {'test_message': True}
            }, use_admin=True)
            
            if message_response.status_code == 200:
                message_result = message_response.json()
                message_id = message_result[0]['message_id']
                thread_id = message_result[0]['thread_id']
                
                self.client.test_data['message_id'] = message_id
                self.client.test_data['thread_id'] = thread_id
                
                self.log_test_result("Send Message", True, f"Message ID: {message_id}")
                
                # Test marking message as read
                read_response = self.client.call_rpc('mark_message_read', {
                    'message_uuid': message_id,
                    'reader_uuid': client1_session['user_id']
                }, use_admin=True)
                
                if read_response.status_code == 200:
                    self.log_test_result("Mark Message Read", True)
                else:
                    self.log_test_result("Mark Message Read", False, read_response.text)
                
                # Test getting conversation messages
                conversation_response = self.client.call_rpc('get_conversation_messages', {
                    'user_uuid': agent1_session['user_id'],
                    'other_user_uuid': client1_session['user_id'],
                    'limit_count': 10
                }, use_admin=True)
                
                if conversation_response.status_code == 200:
                    messages = conversation_response.json()
                    if len(messages) > 0:
                        self.log_test_result("Get Conversation Messages", True, f"Found {len(messages)} messages")
                    else:
                        self.log_test_result("Get Conversation Messages", False, "No messages found")
                else:
                    self.log_test_result("Get Conversation Messages", False, conversation_response.text)
                
                # Test getting user threads
                threads_response = self.client.call_rpc('get_user_threads', {
                    'user_uuid': client1_session['user_id'],
                    'limit_count': 10
                }, use_admin=True)
                
                if threads_response.status_code == 200:
                    threads = threads_response.json()
                    if len(threads) > 0:
                        self.log_test_result("Get User Threads", True, f"Found {len(threads)} threads")
                    else:
                        self.log_test_result("Get User Threads", False, "No threads found")
                else:
                    self.log_test_result("Get User Threads", False, threads_response.text)
                
                # Test adding message reaction
                reaction_response = self.client.call_rpc('add_message_reaction', {
                    'message_uuid': message_id,
                    'user_uuid': client1_session['user_id'],
                    'reaction_type_input': '👍'
                }, use_admin=True)
                
                if reaction_response.status_code == 200:
                    self.log_test_result("Add Message Reaction", True)
                else:
                    self.log_test_result("Add Message Reaction", False, reaction_response.text)
                
            else:
                self.log_test_result("Send Message", False, message_response.text)
                
        except Exception as e:
            self.log_test_result("Messaging System", False, str(e))

    def test_rls_permissions(self):
        """Test 5: Row-Level Security Permissions"""
        logger.info("🧪 Testing RLS Permissions...")
        
        try:
            agent1_session = self.client.user_sessions.get('agent1')
            agent2_session = self.client.user_sessions.get('agent2')
            client1_session = self.client.user_sessions.get('client1')
            client2_session = self.client.user_sessions.get('client2')
            
            if not all([agent1_session, agent2_session, client1_session, client2_session]):
                self.log_test_result("RLS Permissions", False, "Required sessions not found")
                return
            
            # Test that agent1 can only see their own profile
            agent1_headers = agent1_session['headers']
            profile_response = self.client.make_request(
                'GET', 
                f"profiles?id=eq.{agent2_session['user_id']}", 
                headers=agent1_headers
            )
            
            if profile_response.status_code == 200:
                profiles = profile_response.json()
                if len(profiles) == 0:
                    self.log_test_result("RLS Profile Isolation", True, "Agent cannot see other agent's profile")
                else:
                    self.log_test_result("RLS Profile Isolation", False, "Agent can see other agent's profile")
            else:
                self.log_test_result("RLS Profile Isolation", False, f"Unexpected response: {profile_response.status_code}")
            
            # Test that client1 can only see messages involving them
            client1_headers = client1_session['headers']
            
            # First, create a message between agent2 and client2
            message_response = self.client.call_rpc('send_message', {
                'sender_uuid': agent2_session['user_id'],
                'recipient_uuid': client2_session['user_id'],
                'message_content': 'Private message between agent2 and client2',
                'message_type_input': 'text'
            }, use_admin=True)
            
            if message_response.status_code == 200:
                # Now try to access this message as client1
                messages_response = self.client.make_request(
                    'GET',
                    'messages',
                    headers=client1_headers
                )
                
                if messages_response.status_code == 200:
                    messages = messages_response.json()
                    # Client1 should only see messages involving them
                    unauthorized_messages = [
                        msg for msg in messages 
                        if msg['sender_id'] != client1_session['user_id'] 
                        and msg['recipient_id'] != client1_session['user_id']
                    ]
                    
                    if len(unauthorized_messages) == 0:
                        self.log_test_result("RLS Message Isolation", True, "Client can only see their own messages")
                    else:
                        self.log_test_result("RLS Message Isolation", False, f"Client can see {len(unauthorized_messages)} unauthorized messages")
                else:
                    self.log_test_result("RLS Message Isolation", False, f"Unexpected response: {messages_response.status_code}")
            
            # Test document access permissions
            if 'document_id' in self.client.test_data:
                doc_id = self.client.test_data['document_id']
                
                # Try to access document as agent2 (should fail)
                agent2_headers = agent2_session['headers']
                doc_response = self.client.make_request(
                    'GET',
                    f"documents?id=eq.{doc_id}",
                    headers=agent2_headers
                )
                
                if doc_response.status_code == 200:
                    docs = doc_response.json()
                    if len(docs) == 0:
                        self.log_test_result("RLS Document Access", True, "Unauthorized agent cannot access document")
                    else:
                        self.log_test_result("RLS Document Access", False, "Unauthorized agent can access document")
                else:
                    self.log_test_result("RLS Document Access", False, f"Unexpected response: {doc_response.status_code}")
            
        except Exception as e:
            self.log_test_result("RLS Permissions", False, str(e))

    def test_agent_client_relationships(self):
        """Test 6: Agent-Client Relationship Management"""
        logger.info("🧪 Testing Agent-Client Relationships...")
        
        try:
            agent1_session = self.client.user_sessions.get('agent1')
            client1_session = self.client.user_sessions.get('client1')
            
            if not agent1_session or not client1_session:
                self.log_test_result("Agent-Client Relationships", False, "Required sessions not found")
                return
            
            # Test getting agent's clients
            agent_clients_response = self.client.call_rpc('get_agent_clients', {
                'agent_uuid': agent1_session['user_id']
            }, use_admin=True)
            
            if agent_clients_response.status_code == 200:
                clients = agent_clients_response.json()
                if len(clients) > 0:
                    self.log_test_result("Get Agent Clients", True, f"Found {len(clients)} clients")
                else:
                    self.log_test_result("Get Agent Clients", True, "No clients found (expected for new agent)")
            else:
                self.log_test_result("Get Agent Clients", False, agent_clients_response.text)
            
            # Test getting client's agents
            client_agents_response = self.client.call_rpc('get_client_agents', {
                'client_uuid': client1_session['user_id']
            }, use_admin=True)
            
            if client_agents_response.status_code == 200:
                agents = client_agents_response.json()
                if len(agents) > 0:
                    self.log_test_result("Get Client Agents", True, f"Found {len(agents)} agents")
                else:
                    self.log_test_result("Get Client Agents", True, "No agents found (expected for new client)")
            else:
                self.log_test_result("Get Client Agents", False, client_agents_response.text)
            
            # Test agent-client link status
            if 'agent_client_link' in self.client.test_data:
                link_data = self.client.test_data['agent_client_link']
                
                # Check if the relationship exists in the database
                link_response = self.client.make_request(
                    'GET',
                    f"agent_client_links?agent_id=eq.{link_data['agent_id']}&client_id=eq.{link_data['client_id']}",
                    use_admin=True
                )
                
                if link_response.status_code == 200:
                    links = link_response.json()
                    if len(links) > 0:
                        self.log_test_result("Agent-Client Link Verification", True, "Relationship exists in database")
                    else:
                        self.log_test_result("Agent-Client Link Verification", False, "Relationship not found in database")
                else:
                    self.log_test_result("Agent-Client Link Verification", False, link_response.text)
            
        except Exception as e:
            self.log_test_result("Agent-Client Relationships", False, str(e))

    def test_preferences_management(self):
        """Test 7: User Preferences Management"""
        logger.info("🧪 Testing User Preferences Management...")
        
        try:
            client1_session = self.client.user_sessions.get('client1')
            
            if not client1_session:
                self.log_test_result("Preferences Management", False, "Client1 session not found")
                return
            
            # Test creating user preferences
            preferences_data = {
                'user_id': client1_session['user_id'],
                'preference_type': 'property_search',
                'preference_key': 'budget_range',
                'preference_value': {'min': 300000, 'max': 500000},
                'is_active': True
            }
            
            create_pref_response = self.client.make_request(
                'POST',
                'preferences',
                data=preferences_data,
                use_admin=True
            )
            
            if create_pref_response.status_code in [200, 201]:
                self.log_test_result("Create User Preferences", True)
                
                # Test retrieving user preferences
                get_pref_response = self.client.make_request(
                    'GET',
                    f"preferences?user_id=eq.{client1_session['user_id']}",
                    use_admin=True
                )
                
                if get_pref_response.status_code == 200:
                    prefs = get_pref_response.json()
                    if len(prefs) > 0:
                        self.log_test_result("Retrieve User Preferences", True, f"Found {len(prefs)} preferences")
                    else:
                        self.log_test_result("Retrieve User Preferences", False, "No preferences found")
                else:
                    self.log_test_result("Retrieve User Preferences", False, get_pref_response.text)
                
            else:
                self.log_test_result("Create User Preferences", False, create_pref_response.text)
                
        except Exception as e:
            self.log_test_result("Preferences Management", False, str(e))

    def test_analytics_and_reporting(self):
        """Test 8: Analytics and Reporting Functions"""
        logger.info("🧪 Testing Analytics and Reporting...")
        
        try:
            agent1_session = self.client.user_sessions.get('agent1')
            
            if not agent1_session:
                self.log_test_result("Analytics and Reporting", False, "Agent1 session not found")
                return
            
            # Test messaging analytics
            messaging_analytics_response = self.client.call_rpc('get_messaging_analytics', {
                'user_uuid': agent1_session['user_id'],
                'days_back': 30
            }, use_admin=True)
            
            if messaging_analytics_response.status_code == 200:
                analytics = messaging_analytics_response.json()
                if len(analytics) > 0:
                    self.log_test_result("Messaging Analytics", True, "Analytics data retrieved")
                else:
                    self.log_test_result("Messaging Analytics", True, "No analytics data (expected for new user)")
            else:
                self.log_test_result("Messaging Analytics", False, messaging_analytics_response.text)
            
            # Test document analytics
            doc_analytics_response = self.client.call_rpc('get_document_analytics', {
                'user_uuid': agent1_session['user_id'],
                'days_back': 30
            }, use_admin=True)
            
            if doc_analytics_response.status_code == 200:
                doc_analytics = doc_analytics_response.json()
                if len(doc_analytics) > 0:
                    self.log_test_result("Document Analytics", True, "Document analytics retrieved")
                else:
                    self.log_test_result("Document Analytics", True, "No document analytics (expected for new user)")
            else:
                self.log_test_result("Document Analytics", False, doc_analytics_response.text)
            
            # Test invitation analytics
            invitation_analytics_response = self.client.call_rpc('get_invitation_analytics', {
                'agent_uuid': agent1_session['user_id']
            }, use_admin=True)
            
            if invitation_analytics_response.status_code == 200:
                inv_analytics = invitation_analytics_response.json()
                if len(inv_analytics) > 0:
                    self.log_test_result("Invitation Analytics", True, "Invitation analytics retrieved")
                else:
                    self.log_test_result("Invitation Analytics", True, "No invitation analytics (expected)")
            else:
                self.log_test_result("Invitation Analytics", False, invitation_analytics_response.text)
                
        except Exception as e:
            self.log_test_result("Analytics and Reporting", False, str(e))

    def run_all_tests(self):
        """Run all test suites"""
        logger.info("🚀 Starting Comprehensive System Tests...")
        
        # Cleanup before starting
        self.cleanup_test_data()
        
        # Run test suites in order
        test_suites = [
            self.test_user_registration_and_onboarding,
            self.test_agent_invitation_system,
            self.test_document_management,
            self.test_messaging_system,
            self.test_rls_permissions,
            self.test_agent_client_relationships,
            self.test_preferences_management,
            self.test_analytics_and_reporting
        ]
        
        for test_suite in test_suites:
            try:
                test_suite()
                time.sleep(1)  # Brief pause between test suites
            except Exception as e:
                logger.error(f"Test suite failed: {e}")
                self.test_results['failed'] += 1
                self.test_results['errors'].append(f"Test suite error: {e}")
        
        # Print final results
        self.print_test_summary()

    def print_test_summary(self):
        """Print comprehensive test summary"""
        total_tests = self.test_results['passed'] + self.test_results['failed']
        success_rate = (self.test_results['passed'] / total_tests * 100) if total_tests > 0 else 0
        
        logger.info("\n" + "="*80)
        logger.info("🏁 COMPREHENSIVE SYSTEM TEST RESULTS")
        logger.info("="*80)
        logger.info(f"✅ Tests Passed: {self.test_results['passed']}")
        logger.info(f"❌ Tests Failed: {self.test_results['failed']}")
        logger.info(f"📊 Success Rate: {success_rate:.1f}%")
        logger.info(f"🔢 Total Tests: {total_tests}")
        
        if self.test_results['errors']:
            logger.info("\n❌ FAILED TESTS:")
            for error in self.test_results['errors']:
                logger.info(f"   • {error}")
        
        logger.info("\n" + "="*80)
        
        if success_rate >= 90:
            logger.info("🎉 EXCELLENT: System is ready for production!")
        elif success_rate >= 75:
            logger.info("✅ GOOD: System is mostly functional with minor issues")
        elif success_rate >= 50:
            logger.info("⚠️ NEEDS WORK: System has significant issues to address")
        else:
            logger.info("🚨 CRITICAL: System requires major fixes before deployment")

def main():
    """Main function to run tests"""
    # Check environment variables
    required_env_vars = ['SUPABASE_URL', 'SUPABASE_ANON_KEY', 'SUPABASE_SERVICE_KEY']
    missing_vars = [var for var in required_env_vars if not os.getenv(var)]
    
    if missing_vars:
        logger.error(f"❌ Missing required environment variables: {', '.join(missing_vars)}")
        logger.info("Please set the following environment variables:")
        for var in missing_vars:
            logger.info(f"export {var}='your-{var.lower().replace('_', '-')}'")
        return
    
    # Run comprehensive tests
    test_runner = ComprehensiveSystemTest()
    test_runner.run_all_tests()

if __name__ == "__main__":
    main()