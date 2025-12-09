-- C-Suite Internal Wiki Tables
-- Purpose: Knowledge base for C-Suite executives to access company information, decisions, and context

-- Main wiki pages table
CREATE TABLE IF NOT EXISTS csuite_wiki (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category TEXT NOT NULL,              -- 'company', 'product', 'operations', 'marketing', 'finance', 'legal', 'decisions', 'context'
  title TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,           -- URL-friendly identifier
  content TEXT NOT NULL,                -- Markdown content
  tags TEXT[],                          -- Array of tags for search

  -- Version control
  version INTEGER DEFAULT 1,
  created_by TEXT,                      -- User or agent who created it
  updated_by TEXT,                      -- User or agent who last updated
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Access control
  is_public BOOLEAN DEFAULT false,      -- Can agents access this?
  required_role TEXT,                   -- If restricted to specific agents

  -- Metadata
  importance TEXT DEFAULT 'normal',     -- 'critical', 'high', 'normal', 'low'
  related_pages TEXT[],                 -- Links to related wiki pages

  -- Search optimization
  search_vector tsvector
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_wiki_category ON csuite_wiki(category);
CREATE INDEX IF NOT EXISTS idx_wiki_slug ON csuite_wiki(slug);
CREATE INDEX IF NOT EXISTS idx_wiki_tags ON csuite_wiki USING gin(tags);
CREATE INDEX IF NOT EXISTS idx_wiki_search ON csuite_wiki USING gin(search_vector);
CREATE INDEX IF NOT EXISTS idx_wiki_created_at ON csuite_wiki(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_wiki_importance ON csuite_wiki(importance);

-- Full-text search trigger
CREATE OR REPLACE FUNCTION update_wiki_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(NEW.content, '')), 'B') ||
    setweight(to_tsvector('english', COALESCE(array_to_string(NEW.tags, ' '), '')), 'C');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS wiki_search_update ON csuite_wiki;
CREATE TRIGGER wiki_search_update
  BEFORE INSERT OR UPDATE ON csuite_wiki
  FOR EACH ROW EXECUTE FUNCTION update_wiki_search_vector();

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_wiki_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS wiki_timestamp_update ON csuite_wiki;
CREATE TRIGGER wiki_timestamp_update
  BEFORE UPDATE ON csuite_wiki
  FOR EACH ROW EXECUTE FUNCTION update_wiki_timestamp();

-- Version history table
CREATE TABLE IF NOT EXISTS csuite_wiki_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wiki_id UUID REFERENCES csuite_wiki(id) ON DELETE CASCADE,
  version INTEGER NOT NULL,
  content TEXT NOT NULL,
  updated_by TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  change_summary TEXT
);

-- Index for version history lookups
CREATE INDEX IF NOT EXISTS idx_wiki_history_wiki_id ON csuite_wiki_history(wiki_id);
CREATE INDEX IF NOT EXISTS idx_wiki_history_version ON csuite_wiki_history(wiki_id, version DESC);

-- RLS Policies
ALTER TABLE csuite_wiki ENABLE ROW LEVEL SECURITY;
ALTER TABLE csuite_wiki_history ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read public wiki pages
CREATE POLICY "Public wiki pages are viewable by everyone"
  ON csuite_wiki FOR SELECT
  USING (is_public = true);

-- Policy: Authenticated users can read all wiki pages
CREATE POLICY "Authenticated users can view all wiki pages"
  ON csuite_wiki FOR SELECT
  USING (auth.role() = 'authenticated');

-- Policy: Authenticated users can create wiki pages
CREATE POLICY "Authenticated users can create wiki pages"
  ON csuite_wiki FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

-- Policy: Authenticated users can update wiki pages
CREATE POLICY "Authenticated users can update wiki pages"
  ON csuite_wiki FOR UPDATE
  USING (auth.role() = 'authenticated');

-- Policy: Authenticated users can delete wiki pages
CREATE POLICY "Authenticated users can delete wiki pages"
  ON csuite_wiki FOR DELETE
  USING (auth.role() = 'authenticated');

-- Policy: Version history is readable by authenticated users
CREATE POLICY "Authenticated users can view wiki history"
  ON csuite_wiki_history FOR SELECT
  USING (auth.role() = 'authenticated');

-- Function to create version history on update
CREATE OR REPLACE FUNCTION save_wiki_version()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'UPDATE' AND OLD.content IS DISTINCT FROM NEW.content) THEN
    INSERT INTO csuite_wiki_history (wiki_id, version, content, updated_by, change_summary)
    VALUES (OLD.id, OLD.version, OLD.content, OLD.updated_by, 'Version ' || OLD.version);

    NEW.version := OLD.version + 1;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS wiki_version_history ON csuite_wiki;
CREATE TRIGGER wiki_version_history
  BEFORE UPDATE ON csuite_wiki
  FOR EACH ROW EXECUTE FUNCTION save_wiki_version();

-- Insert starter wiki pages
INSERT INTO csuite_wiki (category, title, slug, content, tags, is_public, importance, created_by, updated_by)
VALUES
  -- Company Overview
  (
    'company',
    'HOMEY Company Overview',
    'company-overview',
    '# HOMEY Company Overview

## Mission
Make finding your perfect home as easy as finding your perfect playlist.

## Vision
Be the most trusted platform for home discovery and living.

## Values
1. **User-first always** - Every decision starts with "what does the user need?"
2. **Move fast, learn faster** - Ship quickly, gather feedback, iterate
3. **Transparency over everything** - Be honest with users, team, and ourselves
4. **Build for the long term** - Make decisions that compound over time

## Current Team
- **Ryan Kanfer**: CEO & Founder
- **C-Suite AI Team**: 9 specialized executives
  - Denise (Executive Assistant)
  - Bridget (Product)
  - Cody (Tech/Engineering)
  - Mark (Marketing)
  - Art (Creative)
  - Cash (Finance)
  - Ward (Legal)
  - Ollie (Operations)
  - Ariana (AI/Data)

## Company Stage
Early-stage startup building the future of home search and discovery.

## Last Updated
December 2024',
    ARRAY['company', 'mission', 'vision', 'team'],
    true,
    'critical',
    'ryan@homeypocket.ai',
    'ryan@homeypocket.ai'
  ),

  -- Current Priorities
  (
    'context',
    'Current Priorities',
    'current-priorities',
    '# Current Priorities (Updated Dec 2024)

## This Month
1. **Launch C-Suite Integration (Beta v2)**
   - Deploy preview.homeypocket.ai for testing
   - Integrate notification system
   - Set up automated briefings

2. **Version-Aware Analytics**
   - Track metrics by version (v1 vs v2)
   - Enable Ariana to compare performance
   - Build data-driven decision making

3. **Internal Wiki System**
   - Build knowledge base for C-Suite
   - Enable agents to access company context
   - Create starter documentation

4. **Admin Dashboard**
   - C-Suite status monitoring
   - Task management integration
   - Alert configuration UI

## This Quarter (Q1 2025)
1. Reach 1,000 active users
2. Launch property intelligence features
3. Implement automated briefings (morning, evening, weekly)
4. Scale infrastructure for growth

## Always
- **User feedback → Product improvements within 48 hours**
- **Zero downtime deployments**
- **Keep costs under budget**
- **Ship fast, learn faster**

## Last Updated
December 9, 2024',
    ARRAY['priorities', 'roadmap', 'goals', 'context'],
    true,
    'critical',
    'ryan@homeypocket.ai',
    'ryan@homeypocket.ai'
  ),

  -- Decision Log
  (
    'decisions',
    'Decision Log',
    'decision-log',
    '# Decision Log

Document major decisions, the reasoning behind them, and the outcomes.

---

## Why we chose Supabase over Firebase (Nov 2024)

**Decision**: Use Supabase for backend infrastructure

**Why**:
- Better SQL support for complex queries
- Row-level security (RLS) policies for fine-grained access control
- Open source (we own our data)
- PostgreSQL is battle-tested and scalable

**Tradeoffs**:
- Smaller ecosystem compared to Firebase
- Fewer built-in integrations
- But we get more control and transparency

**Result**: Great choice! RLS has been invaluable for security. PostgreSQL''s power has helped us move fast.

---

## Why we built C-Suite AI (Dec 2024)

**Decision**: Create AI executive team instead of hiring human executives early

**Why**:
- Faster iteration and experimentation
- 24/7 availability for decision making
- Scalable expertise across all domains
- Cost-effective in early stage

**Tradeoffs**:
- Less human intuition and creativity
- No networking/relationship building
- But more consistent logic and always available

**Result**: Testing now. Early signs are promising - fast, consistent advice.

---

## Why preview.homeypocket.ai instead of versioned URLs (Dec 2024)

**Decision**: Use single preview URL for all beta versions instead of v2, v3, v4, etc.

**Why**:
- Simpler DNS management (set it once)
- Easier access control (one URL to protect)
- Consistent testing URL for team
- Less confusion for beta testers

**Tradeoffs**:
- Can''t run multiple preview versions simultaneously
- But we rarely need to

**Result**: Much cleaner workflow! Easy to remember where staging is.

---

## Template for New Decisions

**Decision**: [What we decided]

**Why**: [The reasoning]

**Tradeoffs**: [What we gave up]

**Result**: [How it turned out]

---

## Last Updated
December 9, 2024',
    ARRAY['decisions', 'history', 'reasoning'],
    true,
    'high',
    'ryan@homeypocket.ai',
    'ryan@homeypocket.ai'
  ),

  -- Product Roadmap
  (
    'product',
    'Product Roadmap',
    'product-roadmap',
    '# Product Roadmap

## Completed ✅
- **v1.0.0** - Initial HOMEY launch (Dec 2024)
  - Property search and discovery
  - User profiles and saved homes
  - Basic notifications
  - Mobile-responsive design

- **v2.0.0-beta** - C-Suite Integration (Dec 2024)
  - AI executive team integration
  - Smart notifications and briefings
  - Automated task creation
  - Context-aware assistance

## In Progress 🚧
- **Internal Wiki System**
  - Knowledge base for C-Suite agents
  - Company documentation
  - Decision history

- **Version-Aware Analytics**
  - Track metrics by deployment version
  - A/B testing capabilities
  - Performance comparison

## Upcoming 📅

### v2.1.0 - Admin Dashboard (Dec 2024)
- Executive dashboard in HOMEY admin
- Task management integration
- Smart alert configuration
- Property intelligence system

### v2.2.0 - Automated Briefings (Jan 2025)
- Morning briefing (8:30 AM)
- Evening summary (6 PM)
- Weekly executive report
- Custom briefing schedules

### v3.0.0 - Property Intelligence (Q1 2025)
- AI-powered property insights
- Market trend analysis
- Neighborhood intelligence
- Price prediction

## Future Ideas 💡
- Voice interface for C-Suite
- Mobile app for HOMEY
- Integration with property APIs (Zillow, Realtor.com)
- Virtual home tours
- Community features

## Last Updated
December 9, 2024',
    ARRAY['product', 'roadmap', 'features', 'planning'],
    true,
    'high',
    'ryan@homeypocket.ai',
    'ryan@homeypocket.ai'
  );

-- Grant necessary permissions
GRANT ALL ON csuite_wiki TO authenticated;
GRANT ALL ON csuite_wiki_history TO authenticated;
