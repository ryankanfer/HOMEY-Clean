# HOMEY Version Tracking & Deployment Strategy

## 🎯 Overview

This document outlines how we track, deploy, and analyze different versions of HOMEY to enable data-driven decisions and smooth rollouts.

---

## 📦 Version Naming Convention

### Format: `MAJOR.MINOR.PATCH-STAGE`

Examples:
- `1.0.0` - Original HOMEY (Production)
- `2.0.0-beta` - C-Suite Integration (Staging)
- `2.1.0-beta` - Admin Dashboard (Development)
- `2.0.0` - C-Suite Integration (Production)

### Stages:
- **development**: Active development, local testing
- **staging**: Ready for testing, deployed to staging URL
- **beta**: Public beta testing
- **production**: Live for all users

---

## 🌐 Deployment URLs

### Custom Domain Setup (Recommended):

```
Production:
├─ app.homeypocket.ai           → main branch (public)
└─ www.homeypocket.ai           → main branch (public)

Preview/Staging (All Beta Versions):
└─ preview.homeypocket.ai       → preview-updates branch (PRIVATE - Ryan + C-Suite only)
   ├─ Password protected
   ├─ Access only for Ryan's account
   └─ C-Suite API access allowed

Development:
└─ localhost:3003               → local development
```

**Benefits of Single Preview URL:**
- No need to change DNS for v2, v3, v4, etc.
- Always know where to find latest staging version
- Easier to share with team (same URL, just update code)
- Simpler access control (one URL to protect)

### Vercel Configuration:

1. **Production Deployment**:
   - Branch: `main`
   - Domain: `app.homeypocket.ai`
   - Auto-deploy: ✅ On push to main

2. **Staging Deployment**:
   - Branch: `preview-updates`
   - Domain: `v2.homeypocket.ai`
   - Auto-deploy: ✅ On push to preview-updates

3. **Preview Deployments**:
   - All other branches get automatic preview URLs
   - Format: `homey-{branch}-{hash}.vercel.app`

---

## 📊 Version-Aware Analytics

### Implementation:

Add version tracking to every analytics event:

```typescript
// In every analytics event
{
  app_version: "beta_v2_staging",     // Human-readable tag
  version_number: "2.0.0-beta",       // Semantic version
  version_codename: "C-Suite Integration",
  deployment_status: "staging",       // production | staging | development
  git_branch: "preview-updates",
  timestamp: "2024-12-09T..."
}
```

### Events to Track:

#### User Behavior Events:
```typescript
// Page views
trackVersionedEvent('page_view', {
  page: '/home',
  referrer: document.referrer
});

// Feature usage
trackVersionedEvent('feature_used', {
  feature: 'property_search',
  filters_applied: 3
});

// User actions
trackVersionedEvent('listing_viewed', {
  listing_id: '123',
  price: 850000
});

// Conversions
trackVersionedEvent('booking_created', {
  listing_id: '123',
  nights: 7,
  total: 5000
});
```

#### Performance Events:
```typescript
// Page load times
trackVersionedEvent('performance_metric', {
  metric: 'page_load',
  duration_ms: 1250,
  page: '/home'
});

// API response times
trackVersionedEvent('api_call', {
  endpoint: '/api/listings',
  duration_ms: 350,
  status: 200
});
```

#### Error Events:
```typescript
// Errors
trackVersionedEvent('error_occurred', {
  error_type: '404',
  page: '/listing/999',
  message: 'Listing not found'
});
```

---

## 🤖 C-Suite Integration

### 1. Automatic Deployment Notifications

When a new version is deployed, automatically notify C-Suite:

```typescript
// On deployment (Vercel build hook or cron)
POST /api/csuite/notify
{
  title: "C-Suite Integration deployed to staging",
  description: "Version 2.0.0-beta is now live at v2.homeypocket.ai",
  priority: "high",
  context_type: "deployment",
  context_content: {
    version: "2.0.0-beta",
    codename: "C-Suite Integration",
    status: "staging",
    deployUrl: "https://v2.homeypocket.ai",
    features: [
      "C-Suite notification system",
      "Executive briefings",
      "..."
    ]
  },
  target_agents: ["ea-denise", "ai-ariana"]
}
```

### 2. Version Comparison by Ariana (AI/Data)

Ariana can analyze and compare metrics between versions:

**Example Query from Ryan:**
> "Ariana, how is v2 performing compared to v1?"

**Ariana's Response:**
```
Here's what I'm seeing between beta_v1_production and beta_v2_staging:

User Engagement:
• Average session time: v1 = 4.2 min, v2 = 5.8 min (+38%)
• Pages per session: v1 = 3.1, v2 = 4.5 (+45%)
• Bounce rate: v1 = 42%, v2 = 31% (-26%)

Property Search:
• Searches per user: v1 = 2.3, v2 = 3.7 (+61%)
• Filters used: v1 = 1.8, v2 = 2.9 (+61%)
• Saved listings: v1 = 0.8, v2 = 1.4 (+75%)

Conversions:
• Booking requests: v1 = 2.1%, v2 = 3.4% (+62%)
• Contact rate: v1 = 5.3%, v2 = 7.8% (+47%)

Performance:
• Page load (home): v1 = 1.8s, v2 = 1.2s (-33%)
• Search results: v1 = 2.1s, v2 = 1.5s (-29%)

Bottom Line:
V2 is crushing it! Users are way more engaged, searching more, and converting better. The faster load times are probably helping too. I'd recommend moving v2 to production.
```

### 3. Automated A/B Test Reports

Daily/weekly automated reports sent to C-Suite:

```
[Denise]: Daily A/B Test Summary for Dec 9

V1 (Production):
• 1,245 active users
• 18 bookings ($47,200)
• Average satisfaction: 4.2/5

V2 (Staging):
• 312 beta testers
• 8 bookings ($21,600)
• Average satisfaction: 4.6/5

[Ariana]: V2 has a 23% higher booking rate when normalized for traffic. Conversion funnel is tighter. Recommend wider rollout.

[Cash]: V2 booking value is 15% higher per transaction. ROI looks good for the development cost.

[Bridget]: Users are loving the new search filters. Feedback score increased from 4.2 to 4.6.
```

---

## 🗄️ Database Schema

### Version Tracking Table:

```sql
CREATE TABLE app_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  version_number TEXT NOT NULL,
  codename TEXT NOT NULL,
  status TEXT NOT NULL, -- 'development' | 'staging' | 'beta' | 'production'
  git_branch TEXT NOT NULL,
  git_commit_sha TEXT,
  deploy_url TEXT,
  deployed_at TIMESTAMPTZ DEFAULT NOW(),
  deployed_by TEXT,
  features JSONB,
  changelog JSONB,
  is_current BOOLEAN DEFAULT false
);

-- Index for quick lookups
CREATE INDEX idx_versions_status ON app_versions(status);
CREATE INDEX idx_versions_current ON app_versions(is_current) WHERE is_current = true;
```

### Analytics Events Table:

```sql
CREATE TABLE analytics_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_name TEXT NOT NULL,
  user_id UUID REFERENCES users(id),
  session_id TEXT,

  -- Version tracking
  app_version TEXT NOT NULL,         -- e.g., "beta_v2_staging"
  version_number TEXT NOT NULL,      -- e.g., "2.0.0-beta"
  deployment_status TEXT NOT NULL,   -- 'production' | 'staging' | etc.

  -- Event data
  properties JSONB,
  page_url TEXT,
  referrer TEXT,
  user_agent TEXT,

  -- Performance
  duration_ms INTEGER,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for analytics queries
CREATE INDEX idx_events_version ON analytics_events(app_version);
CREATE INDEX idx_events_name ON analytics_events(event_name);
CREATE INDEX idx_events_user ON analytics_events(user_id);
CREATE INDEX idx_events_created ON analytics_events(created_at DESC);

-- Composite index for version comparisons
CREATE INDEX idx_events_version_name_date
  ON analytics_events(app_version, event_name, created_at DESC);
```

---

## 🚀 Deployment Workflow

### Step-by-Step Process:

#### **Stage 1: Development** (Local)
```bash
# Work on feature branch
git checkout -b feature/new-feature
# Develop and test locally
npm run dev
# Commit changes
git commit -m "Add new feature"
```

#### **Stage 2: Staging** (v2.homeypocket.ai)
```bash
# Merge to preview-updates
git checkout preview-updates
git merge feature/new-feature
git push origin preview-updates

# Vercel auto-deploys to staging
# URL: https://v2.homeypocket.ai

# Update VERSION.json
{
  "current": {
    "version": "2.1.0-beta",
    "status": "staging",
    ...
  }
}

# Notify C-Suite
# (Automatic via deployment hook)
```

#### **Stage 3: Beta Testing** (Invite-only on staging)
```bash
# Enable for select users
# Add feature flag or user whitelist
# Monitor analytics, gather feedback
# Fix issues, iterate
```

#### **Stage 4: Production** (app.homeypocket.ai)
```bash
# When ready, merge to main
git checkout main
git merge preview-updates
git tag v2.1.0
git push origin main --tags

# Vercel auto-deploys to production
# URL: https://app.homeypocket.ai

# Update VERSION.json
{
  "current": {
    "version": "2.1.0",
    "status": "production",
    ...
  }
}

# Notify C-Suite of production deployment
```

---

## 📈 Ariana's Version Comparison Queries

### Example SQL Queries for Analytics:

#### Compare Conversion Rates:
```sql
WITH v1_stats AS (
  SELECT
    COUNT(DISTINCT user_id) as users,
    COUNT(*) FILTER (WHERE event_name = 'booking_created') as bookings
  FROM analytics_events
  WHERE app_version LIKE 'v1_%'
    AND created_at > NOW() - INTERVAL '7 days'
),
v2_stats AS (
  SELECT
    COUNT(DISTINCT user_id) as users,
    COUNT(*) FILTER (WHERE event_name = 'booking_created') as bookings
  FROM analytics_events
  WHERE app_version LIKE 'beta_v2_%'
    AND created_at > NOW() - INTERVAL '7 days'
)
SELECT
  'v1' as version,
  users,
  bookings,
  ROUND((bookings::FLOAT / users * 100), 2) as conversion_rate
FROM v1_stats
UNION ALL
SELECT
  'v2' as version,
  users,
  bookings,
  ROUND((bookings::FLOAT / users * 100), 2) as conversion_rate
FROM v2_stats;
```

#### Compare Page Load Times:
```sql
SELECT
  app_version,
  event_name,
  AVG(duration_ms) as avg_duration_ms,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY duration_ms) as median_duration_ms,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY duration_ms) as p95_duration_ms
FROM analytics_events
WHERE event_name = 'page_load'
  AND created_at > NOW() - INTERVAL '7 days'
GROUP BY app_version, event_name
ORDER BY app_version;
```

---

## ✅ Implementation Checklist

### Phase 1: Setup (Now)
- [x] Create VERSION.json with version tracking
- [ ] Set up Vercel custom domains (v2.homeypocket.ai)
- [ ] Add version.ts utility for tracking
- [ ] Create version tracking database tables
- [ ] Add git tags for versions

### Phase 2: Analytics Integration (This Week)
- [ ] Add version tag to all analytics events
- [ ] Set up analytics events table in Supabase
- [ ] Create trackVersionedEvent() wrapper
- [ ] Add performance monitoring
- [ ] Test version tracking in development

### Phase 3: C-Suite Integration (This Week)
- [ ] Create deployment notification endpoint
- [ ] Add Vercel deployment webhook
- [ ] Enable Ariana to query version metrics
- [ ] Set up automated A/B test reports
- [ ] Create version comparison dashboard

### Phase 4: Production Deployment (Next Week)
- [ ] Deploy v2 to staging (v2.homeypocket.ai)
- [ ] Beta test with select users
- [ ] Monitor metrics for 3-7 days
- [ ] Get C-Suite recommendation
- [ ] Deploy to production if metrics are good

---

## 🎯 Success Metrics

Track these to decide when to promote v2 to production:

### Must-Haves (Required to Pass):
- [ ] No critical bugs reported
- [ ] Performance equal or better than v1
- [ ] Error rate < v1 error rate
- [ ] Core user flows working

### Nice-to-Haves (Bonus):
- [ ] Engagement metrics up 10%+
- [ ] Conversion rate up 5%+
- [ ] User satisfaction score up
- [ ] Positive feedback from beta testers

---

**Let C-Suite help you decide when v2 is ready for prime time!** 🚀
