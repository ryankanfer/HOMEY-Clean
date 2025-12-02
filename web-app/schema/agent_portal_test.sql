-- Super minimal test version
-- Run this first to test the basic structure

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Agent Profiles
CREATE TABLE IF NOT EXISTS agent_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE,
  brokerage_name TEXT,
  bio TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 2. Agent-Client Connections
CREATE TABLE IF NOT EXISTS agent_client_connections (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  agent_id UUID NOT NULL REFERENCES agent_profiles(id) ON DELETE CASCADE,
  client_id UUID NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(agent_id, client_id)
);

-- 3. Messages (references connection_id from agent_client_connections)
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  connection_id UUID NOT NULL REFERENCES agent_client_connections(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
