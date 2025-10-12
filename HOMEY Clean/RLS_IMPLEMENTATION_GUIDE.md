# RLS Implementation Guide for New Tables

## Overview
This guide covers the implementation of Row Level Security (RLS) policies for the new agent-client relationship tables in the HOMEY Clean application.

## Files Created
1. `fix_new_table_rls_policies.sql` - SQL script to create RLS policies
2. `test_new_rls_policies.py` - Python script to test RLS policies
3. This guide - Implementation instructions

## Tables Covered
- `agent_client_links` - Core agent-client relationship table
- `preferences` - User preferences with agent access
- `documents` - Document storage with agent access
- `messages` - Messaging system between agents and clients
- `showing_requests` - Property showing requests
- `client_agent_links` - Invite system for client→agent connections

## Implementation Steps

### Step 1: Execute RLS Policies
1. Open Supabase Dashboard → SQL Editor
2. Copy and paste the contents of `fix_new_table_rls_policies.sql`
3. Execute the script to create all RLS policies

### Step 2: Verify Tables Exist
Before executing the RLS policies, ensure all tables exist in your database:

```sql
-- Check if tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
    'agent_client_links',
    'preferences', 
    'documents',
    'messages',
    'showing_requests',
    'client_agent_links'
);
```

### Step 3: Create Missing Tables (if needed)
If any tables are missing, create them with appropriate schemas:

```sql
-- Example: Create agent_client_links table
CREATE TABLE IF NOT EXISTS agent_client_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES auth.users(id) NOT NULL,
    client_id UUID REFERENCES auth.users(id) NOT NULL,
    invited_by UUID REFERENCES auth.users(id) NOT NULL,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(agent_id, client_id)
);

-- Add similar CREATE TABLE statements for other missing tables
```

### Step 4: Test RLS Policies
1. Create test users (agent and client) in Supabase Auth
2. Confirm their email addresses
3. Update the test script with correct credentials
4. Run: `python3 test_new_rls_policies.py`

## RLS Policy Structure

### Core Principles
1. **User Ownership**: Users can manage their own data
2. **Agent-Client Relationships**: Agents can access data from assigned clients
3. **Secure by Default**: Anonymous access is restricted
4. **Admin Override**: Optional admin policies for full access

### Policy Types

#### 1. Self-Management Policies
```sql
-- Users can manage their own data
CREATE POLICY "users_manage_own_data" ON table_name
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);
```

#### 2. Agent Access Policies
```sql
-- Agents can view client data through agent_client_links
CREATE POLICY "agents_view_client_data" ON table_name
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM agent_client_links acl
            WHERE acl.agent_id = auth.uid()
            AND acl.client_id = table_name.user_id
            AND acl.status = 'active'
        )
    );
```

#### 3. Conversation Policies
```sql
-- Users can access conversations they're part of
CREATE POLICY "conversation_access" ON messages
    FOR SELECT
    USING (
        auth.uid() = sender_id OR 
        auth.uid() = recipient_id OR
        -- Agent-client relationship access
        EXISTS (SELECT 1 FROM agent_client_links ...)
    );
```

## Testing Checklist

### ✅ Anonymous Access
- [ ] All tables should deny anonymous INSERT/UPDATE/DELETE
- [ ] SELECT should return empty results or be denied
- [ ] No sensitive data should be accessible

### ✅ User Access
- [ ] Users can read/write their own data
- [ ] Users cannot access other users' data
- [ ] Agent-client relationships are properly enforced

### ✅ Agent Access
- [ ] Agents can view assigned clients' data
- [ ] Agents cannot view unassigned clients' data
- [ ] Agent-client links control access properly

### ✅ Client Access
- [ ] Clients can view their assigned agent
- [ ] Clients can manage their own data
- [ ] Clients cannot access other clients' data

## Troubleshooting

### Common Issues

#### 1. Table Not Found
```
ERROR: relation "table_name" does not exist
```
**Solution**: Create the missing table with proper schema

#### 2. Authentication Failed
```
Email not confirmed
```
**Solution**: Confirm test user emails in Supabase Auth dashboard

#### 3. RLS Function Missing
```
Could not find the function public.test_rls_policies
```
**Solution**: Execute the RLS policies SQL script to create the function

#### 4. Policy Conflicts
```
Policy already exists
```
**Solution**: The script includes DROP POLICY IF EXISTS statements

### Debugging Commands

```sql
-- Check if RLS is enabled
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';

-- View existing policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE schemaname = 'public';

-- Test specific policy
SELECT * FROM table_name; -- Should respect RLS
```

## Security Considerations

### 1. Data Isolation
- Each user can only access their own data
- Agent-client relationships are strictly enforced
- No data leakage between unrelated users

### 2. Access Control
- All access is controlled through RLS policies
- No application-level security bypasses
- Consistent security across all tables

### 3. Audit Trail
- All policies are documented and versioned
- Changes can be tracked through SQL scripts
- Test scripts verify policy effectiveness

## Next Steps

After implementing RLS policies:

1. **Update Application Code**: Ensure repositories use proper authentication
2. **Remove Legacy Security**: Remove application-level access controls that are now redundant
3. **Monitor Performance**: RLS policies can impact query performance
4. **Regular Testing**: Run test scripts regularly to verify security
5. **Documentation**: Keep this guide updated with any changes

## Support

For issues with RLS implementation:
1. Check Supabase logs for detailed error messages
2. Verify table schemas match policy expectations
3. Test with minimal data sets first
4. Use Supabase Dashboard → Authentication → Policies for visual debugging