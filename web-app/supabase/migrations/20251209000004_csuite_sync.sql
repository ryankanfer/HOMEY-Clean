-- C-Suite App Data Sync Tables
-- These tables store conversations, tasks, and projects for cross-device syncing

-- User ID will be stored in localStorage (simple single-user approach for now)
-- Future: Can integrate with Supabase Auth

-- Conversations table (stores all chat messages)
CREATE TABLE IF NOT EXISTS public.csuite_conversations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL DEFAULT 'ceo', -- Simple single-user for now
    agent_id TEXT NOT NULL, -- Which agent (boardroom, ea-denise, tech-cody, etc.)
    role TEXT NOT NULL, -- 'user' or 'model'
    content TEXT NOT NULL,
    timestamp BIGINT NOT NULL,
    project_id TEXT, -- Optional: if this message belongs to a project
    context_type TEXT, -- 'code', 'database', 'feedback', etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tasks table (stores project tracker tasks)
CREATE TABLE IF NOT EXISTS public.csuite_tasks (
    id TEXT PRIMARY KEY, -- Using client-generated IDs for simplicity
    user_id TEXT NOT NULL DEFAULT 'ceo',
    title TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL, -- 'todo', 'in-progress', 'done'
    priority TEXT NOT NULL, -- 'low', 'medium', 'high'
    assignee_id TEXT NOT NULL, -- Agent ID
    due_date BIGINT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Projects table (stores project groups)
CREATE TABLE IF NOT EXISTS public.csuite_projects (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL DEFAULT 'ceo',
    name TEXT NOT NULL,
    description TEXT,
    agent_ids TEXT[] NOT NULL, -- Array of agent IDs
    task_ids TEXT[] DEFAULT ARRAY[]::TEXT[],
    linked_task_id TEXT, -- Primary linked task
    created_by TEXT NOT NULL, -- 'user' or 'auto'
    status TEXT NOT NULL, -- 'active', 'completed', 'archived'
    created_at_ts BIGINT NOT NULL, -- Client timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Project chat messages (stores messages within project chats)
CREATE TABLE IF NOT EXISTS public.csuite_project_chats (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL DEFAULT 'ceo',
    project_id TEXT NOT NULL,
    agent_id TEXT NOT NULL,
    role TEXT NOT NULL, -- 'user' or 'model'
    content TEXT NOT NULL,
    timestamp BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Global history (for agent memory/recall)
CREATE TABLE IF NOT EXISTS public.csuite_global_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id TEXT NOT NULL DEFAULT 'ceo',
    agent_id TEXT NOT NULL,
    role TEXT NOT NULL,
    content TEXT NOT NULL,
    timestamp BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_csuite_conversations_user_agent ON public.csuite_conversations(user_id, agent_id);
CREATE INDEX IF NOT EXISTS idx_csuite_conversations_timestamp ON public.csuite_conversations(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_csuite_tasks_user ON public.csuite_tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_csuite_tasks_status ON public.csuite_tasks(status);
CREATE INDEX IF NOT EXISTS idx_csuite_projects_user ON public.csuite_projects(user_id);
CREATE INDEX IF NOT EXISTS idx_csuite_projects_status ON public.csuite_projects(status);
CREATE INDEX IF NOT EXISTS idx_csuite_project_chats_project ON public.csuite_project_chats(project_id);
CREATE INDEX IF NOT EXISTS idx_csuite_global_history_user ON public.csuite_global_history(user_id);

-- Enable Row Level Security (RLS)
ALTER TABLE public.csuite_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.csuite_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.csuite_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.csuite_project_chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.csuite_global_history ENABLE ROW LEVEL SECURITY;

-- RLS Policies (allow all for now since we're using anon key and single user)
-- Future: Can add user-specific policies when auth is implemented
CREATE POLICY "Allow all operations on conversations" ON public.csuite_conversations FOR ALL USING (true);
CREATE POLICY "Allow all operations on tasks" ON public.csuite_tasks FOR ALL USING (true);
CREATE POLICY "Allow all operations on projects" ON public.csuite_projects FOR ALL USING (true);
CREATE POLICY "Allow all operations on project_chats" ON public.csuite_project_chats FOR ALL USING (true);
CREATE POLICY "Allow all operations on global_history" ON public.csuite_global_history FOR ALL USING (true);
