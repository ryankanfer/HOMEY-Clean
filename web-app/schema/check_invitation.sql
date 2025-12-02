-- Run this in Supabase SQL Editor to check your invitation status
SELECT 
  id,
  invited_email,
  status,
  created_at,
  agent_id,
  client_id,
  connection_type
FROM agent_client_connections
WHERE invited_email IS NOT NULL
ORDER BY created_at DESC
LIMIT 10;
