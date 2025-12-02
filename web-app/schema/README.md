# HOMEY Database Schemas

This directory contains SQL schema files for the HOMEY application.

## Agent Portal Schema

The `agent_portal_schema.sql` file contains the complete database schema for the agent-client connection system.

### Key Features:
- **Agent-Client Connections**: Core relationship management
- **Real-time Messaging**: Chat between agents and clients
- **Document Sharing**: Secure document upload and sharing
- **Property Recommendations**: Agents can recommend specific properties
- **Client Feedback**: Clients can provide feedback on properties and service
- **Showing Scheduling**: Request and manage property showings
- **Activity Logging**: Track all agent activities

## Applying the Schema to Supabase

1. **Open Supabase Dashboard**
   - Go to https://app.supabase.com
   - Select your HOMEY project
   - Navigate to "SQL Editor" in the left sidebar

2. **Run the Schema**
   - Click "New query"
   - Copy the entire content of `agent_portal_schema.sql`
   - Paste it into the SQL editor
   - Click "Run" or press `Cmd+Enter`

3. **Verify Tables Created**
   - Go to "Table Editor"
   - You should see the following new tables:
     - `agent_profiles`
     - `agent_client_connections`
     - `messages`
     - `shared_documents`
     - `property_recommendations`
     - `client_feedback`
     - `showing_requests`
     - `agent_activity_log`
     - `agent_listings`

## TypeScript Types

The corresponding TypeScript types are in `/lib/agent-types.ts`.

## Next Steps

1. Apply the schema to Supabase
2. Add RLS policies (coming next)
3. Build the agent portal UI
4. Integrate with existing consumer app
