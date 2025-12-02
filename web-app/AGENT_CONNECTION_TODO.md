# Agent-Client Connection - Remaining Tasks

## ✅ What's Working

1. **Invitation Flow**: Client can accept invitations via email link
2. **Sign-up Integration**: New users can sign up and immediately accept
3. **Database Connection**: `agent_client_connections` table working with RLS
4. **Profile Display**: `/settings` shows correct agent info
5. **Agent Dashboard**: Agents can see their clients at `/agent/clients`

## 🔧 What Needs Fixing

### 1. Home Page Agent Contact Display
**Issue**: `/home` shows "Your Agent" instead of agent name
**Location**: `/app/home/page.tsx`
**Root Cause**: The `useClientAgent()` hook returns agent data, but the display component isn't using `agent.user.full_name` correctly
**Fix Needed**: Check where `agentConnection` is passed to widgets and ensure it uses the enriched data with `user` profile

### 2. Directory Page Agent Display
**Issue**: `/directory` doesn't show correct agent info
**Location**: `/app/directory/page.tsx`
**Fix Needed**: Similar to home page - needs to use `useClientAgent()` hook and display enriched data

### 3. Vault Connection
**Location**: `/app/vault/page.tsx`
**Check**: Does it show agent info? Does it need to?
**Action**: Verify if vault should display agent context

### 4. Search Connection
**Location**: `/app/search/page.tsx`
**Check**: Does it show agent info? Does it need to?
**Action**: Verify if search should display agent context

### 5. Messages Popup Component
**Status**: Needs to be created
**Requirements**:
- Floating message icon/button
- Click to open messages modal
- Show conversation with agent
- Send/receive messages
- Real-time updates (optional)

**Suggested Implementation**:
```typescript
// components/MessagesPopup.tsx
- Floating FAB (Floating Action Button) in bottom right
- Badge showing unread count
- Opens modal with message thread
- Uses agent connection from useClientAgent()
- Stores messages in database (needs messages table)
```

## 📋 Quick Fix Guide

### Fix 1: Home Page Agent Display

The issue is that `useClientAgent()` returns:
```typescript
{
  agent: {
    ...agentProfile,
    user: {
      full_name: "Minerva McGonagall",
      email: "minerva@mc.com",
      phone: "123-456-7890"
    }
  }
}
```

But components are looking for `agent.full_name` instead of `agent.user.full_name`.

**Solution**: Update any component displaying agent info to use:
```typescript
const agentName = agentConnection?.user?.full_name || 'Your Agent';
const agentEmail = agentConnection?.user?.email;
const agentPhone = agentConnection?.user?.phone;
```

### Fix 2: RLS Policy for Profiles (If Not Applied Yet)

Make sure this SQL has been run:
```sql
-- Allow clients to read their agent's profile
CREATE POLICY "Clients can read connected agents profiles"
ON profiles
FOR SELECT
TO authenticated
USING (
  id IN (
    SELECT ap.user_id
    FROM agent_profiles ap
    INNER JOIN agent_client_connections acc ON acc.agent_id = ap.id
    WHERE acc.client_id = auth.uid()
    AND acc.status = 'active'
  )
);
```

## 🎯 Priority Order

1. **High Priority**: Fix home page agent display (most visible)
2. **High Priority**: Create messages popup (essential for communication)
3. **Medium Priority**: Fix directory page display
4. **Low Priority**: Vault/Search connection (verify if needed)

## 📁 Files to Modify

### For Agent Display Issues:
1. `/app/home/page.tsx` - Check widget creation
2. `/app/directory/page.tsx` - Check agent display
3. Any component that uses `useClientAgent()` hook

### For Messages Feature:
1. Create `/components/MessagesPopup.tsx`
2. Create database table for messages
3. Add to `/app/layout.tsx` or main pages

## 🔍 Debug Steps

### To verify agent data is loading:
```javascript
// Add to any page using useClientAgent()
console.log('Agent connection:', agentConnection);
console.log('Agent user data:', agentConnection?.user);
```

### To check RLS policies:
```sql
-- In Supabase SQL Editor
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE tablename IN ('profiles', 'agent_client_connections');
```

## 📝 Messages Feature Spec

### Database Schema Needed:
```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID REFERENCES agent_client_connections(id),
  sender_id UUID REFERENCES auth.users(id),
  message TEXT NOT NULL,
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their messages"
ON messages
FOR SELECT
TO authenticated
USING (
  connection_id IN (
    SELECT id FROM agent_client_connections
    WHERE client_id = auth.uid() OR agent_id IN (
      SELECT id FROM agent_profiles WHERE user_id = auth.uid()
    )
  )
);

CREATE POLICY "Users can send messages"
ON messages
FOR INSERT
TO authenticated
WITH CHECK (
  sender_id = auth.uid()
  AND connection_id IN (
    SELECT id FROM agent_client_connections
    WHERE client_id = auth.uid() OR agent_id IN (
      SELECT id FROM agent_profiles WHERE user_id = auth.uid()
    )
  )
);
```

### Component Structure:
```
<MessagesPopup>
  ├── <FloatingButton>  // FAB with unread badge
  └── <MessageModal>
      ├── <MessageHeader>  // Agent/Client name
      ├── <MessageThread>  // Conversation
      └── <MessageInput>   // Send new message
```

## ✅ Testing Checklist

After fixes:
- [ ] Home page shows "Minerva McGonagall" not "Your Agent"
- [ ] Click contact shows email and phone
- [ ] Directory shows agent info
- [ ] Messages popup appears on all client pages
- [ ] Can send message to agent
- [ ] Agent can receive and reply to messages
- [ ] Connection persists across browser refresh
- [ ] Multiple clients can connect to same agent

