# Fixing Agent-Client Connection Issues

## Problem
Users accepting invitations are getting blocked by RLS (Row Level Security) policies, causing acceptance to fail with error "Update returned 0 rows".

## Root Cause
The existing RLS policies on `agent_client_connections` table don't properly allow users to accept invitations sent to their email address.

## Solution

### 1. Code Improvements (Already Applied)
✅ Enhanced `acceptInvitation` function in `/lib/supabase.ts` with:
- Email verification (user's email must match invitation's `invited_email`)
- Status validation (invitation must be `pending`)
- Better authentication checking
- Comprehensive error logging

### 2. Database Policy Fix (Needs to be Applied)

Run the SQL file in your Supabase Dashboard:

**File**: `schema/agent_client_connections_rls_fix.sql`

**How to Apply**:
1. Go to https://app.supabase.com
2. Select your project
3. Navigate to "SQL Editor" in the left sidebar
4. Open a new query
5. Copy and paste the contents of `agent_client_connections_rls_fix.sql`
6. Click "Run"

**What it does**:
- Drops conflicting/problematic policies
- Creates proper SELECT policies (agents and clients can view their connections)
- Creates the critical UPDATE policy that allows invitation acceptance
- Sets up INSERT and DELETE policies for complete CRUD operations

### 3. Key Policy for Invitation Acceptance

The most important policy is:

```sql
CREATE POLICY "Users can accept invitations sent to their email"
ON agent_client_connections
FOR UPDATE
TO authenticated
USING (
  status = 'pending'
  AND invited_email IS NOT NULL
  AND invited_email = (SELECT email FROM auth.users WHERE id = auth.uid())
)
WITH CHECK (
  client_id = auth.uid()
  AND status = 'active'
);
```

This allows users to:
- Update invitations that were sent to their email address
- Only when the invitation is in 'pending' status
- Only to set their own user ID as client_id and status to 'active'

## Testing

After applying the SQL fix:

1. **Create a test invitation** as an agent:
   - Go to `/agent/clients`
   - Send an invitation to a test email

2. **Accept the invitation** as a client:
   - Use the invitation link
   - Sign up or sign in with the email the invitation was sent to
   - The acceptance should work without errors

3. **Check the browser console**:
   - You should see: `✅ Invitation accepted successfully`
   - No `❌ Update returned 0 rows` errors

## Debugging

If issues persist, check these in Supabase SQL Editor:

### Check current policies:
```sql
SELECT policyname, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'agent_client_connections'
ORDER BY cmd, policyname;
```

### Check RLS is enabled:
```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE tablename = 'agent_client_connections';
```

### Test invitation lookup:
```sql
-- Replace with actual invitation ID
SELECT * FROM agent_client_connections WHERE id = 'invitation-id-here';
```

### Check user email:
```sql
-- Replace with actual user ID
SELECT email FROM auth.users WHERE id = 'user-id-here';
```

## Common Issues

### Issue: "Email mismatch"
**Cause**: User is signed in with a different email than the invitation was sent to.
**Solution**: Sign out and sign in with the correct email, or resend invitation to the current email.

### Issue: "Invitation has already been active"
**Cause**: The invitation was already accepted.
**Solution**: This is expected behavior. The user is already connected.

### Issue: "RLS policy blocking update"
**Cause**: The RLS policies haven't been applied or there's a policy conflict.
**Solution**: Apply the SQL fix from `agent_client_connections_rls_fix.sql`.

## Migration Notes

- The SQL file drops existing problematic policies before creating new ones
- It's safe to run multiple times (uses DROP IF EXISTS)
- No data is modified, only policies are changed
- Existing connections are not affected
