# HOMEY Event Tracking & Analytics

## Overview

This is the nervous system for HOMEY's AI - capturing every user interaction to power personalization, recommendations, and the multi-agent learning layer.

## Architecture

### 3 Core Tables

1. **`user_events`** - Every interaction (clicks, views, searches, etc.)
2. **`user_sessions`** - Browsing sessions with engagement metrics
3. **`user_journey_states`** - Where users are in their home journey

### Event Flow

```
User Action → analytics.track() → Supabase → Triggers → Updates Sessions & Journey
```

## Usage

### 1. Page Views

```typescript
import { analytics } from '@/lib/analytics';

// Track page view
analytics.pageView('home_feed');
```

### 2. Listing Interactions

```typescript
// View listing
analytics.viewListing(listingId, {
  price: 5200,
  neighborhood: 'Tribeca',
  context: 'featured_row'
});

// Save listing
analytics.saveListing(listingId);

// Share listing
analytics.shareListing(listingId, 'email');
```

### 3. Search Behavior

```typescript
// Perform search
analytics.performSearch({
  min_price: 3000,
  max_price: 7000,
  bedrooms: 2,
  neighborhood: 'Flatiron'
});

// Change filters
analytics.changeFilter('price', { min: 3000, max: 7000 });
```

### 4. Communication

```typescript
// Contact agent
analytics.contactAgent(agentId, 'phone');

// Send message
analytics.sendMessage('agent');

// Schedule tour
analytics.scheduleTour(listingId, '2024-12-01');
```

### 5. Session Management

```typescript
import { sessionManager } from '@/lib/analytics';

// Start session (call in useEffect)
sessionManager.startSession();

// End session (call on unmount)
sessionManager.endSession();
```

### 6. Journey Tracking

```typescript
import { journeyManager } from '@/lib/analytics';

// Update journey stage
await journeyManager.updateJourneyStage('searching');

// Get current journey insights
const insights = await journeyManager.getJourneyState();
// Returns: { current_stage, days_in_stage, engagement_score, recent_actions }
```

## Event Types

### Navigation
- `page_view` - User views a page

### Engagement
- `listing_view` - User views property details
- `click` - Generic click tracking
- `scroll` - Scroll depth tracking
- `map_interaction` - Map zoom/pan/click

### Search
- `search` - User performs search
- `filter_change` - User adjusts filters

### Conversion
- `save` - User saves a listing
- `schedule_tour` - User schedules tour
- `contact` - User contacts agent

### Communication
- `message` - User sends message
- `contact` - User initiates contact

### Documents
- `document_upload` - User uploads document

### Social
- `share` - User shares listing

## Journey Stages

Users progress through 7 stages:

1. **exploring** - Just browsing, no clear intent
2. **searching** - Active search with criteria
3. **touring** - Scheduled viewings
4. **negotiating** - Offer submitted
5. **under_contract** - Deal accepted
6. **closing** - Final paperwork
7. **living** - Post-move, renewals

## Data Captured

### Automatic Context
- User ID (if logged in)
- Session ID
- Device type, browser, OS
- Screen size
- Page path, title, referrer
- Timestamp

### Custom Data
- Event-specific metadata in `event_data` JSON field
- Flexible schema for any additional context

## AI Learning Layer

### What the AI Learns From:

**Search Behavior:**
- Price ranges users actually click on
- Neighborhood preferences over time
- Feature priorities (doorman > gym?)
- Listing type patterns

**Engagement Patterns:**
- Time of day users browse
- Which feed rows get most attention
- Hero vs thumbnail click-through rates
- Save vs view ratios

**Journey Progression:**
- How long users stay in each stage
- What actions move them forward
- Drop-off points

**Network Effects:**
- Successful agent-client pairings
- Document workflows that close faster
- Design tastes that correlate with purchases

## Analytics Queries

### User Engagement Score

```sql
SELECT calculate_engagement_score('user-id-here');
-- Returns 0.0 to 1.0 score
```

### Journey Insights

```sql
SELECT * FROM get_user_journey_insights('user-id-here');
-- Returns full journey analysis
```

### Popular Listings

```sql
SELECT
  event_data->>'listing_id' as listing_id,
  COUNT(*) as views
FROM user_events
WHERE event_type = 'listing_view'
  AND timestamp > NOW() - INTERVAL '7 days'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```

### Search Trends

```sql
SELECT
  event_data->>'neighborhood' as neighborhood,
  COUNT(*) as searches
FROM user_events
WHERE event_type = 'search'
  AND timestamp > NOW() - INTERVAL '30 days'
GROUP BY 1
ORDER BY 2 DESC;
```

## Privacy & Security

- ✅ Row Level Security (RLS) enabled
- ✅ Users can only see their own events
- ✅ Anonymous tracking before login
- ✅ GDPR-compliant (events can be deleted)
- ✅ No PII in event data

## Setup

### 1. Apply Schema

```bash
# Run in Supabase SQL Editor
psql -f schema/events_tracking_schema.sql
```

### 2. Import Analytics

```typescript
import { analytics } from '@/lib/analytics';
```

### 3. Track Events

Start tracking immediately - no configuration needed!

## Triggers & Automation

### Auto-Update Session Metrics
When events are inserted, sessions automatically update:
- `pages_viewed`
- `actions_count`
- `listings_viewed`
- `searches_performed`

### Auto-Update Journey Activity
User journey `last_activity_at` updates on every event.

## Future Enhancements

- [ ] Real-time event streaming
- [ ] Predictive analytics dashboard
- [ ] A/B testing framework
- [ ] Cohort analysis
- [ ] Funnel visualization
- [ ] Recommendation engine training
- [ ] Anomaly detection (fraud, bots)

## Example: Complete Tracking Setup

```typescript
'use client';

import { useEffect } from 'react';
import { analytics, sessionManager } from '@/lib/analytics';

export default function MyPage() {
  useEffect(() => {
    // Track page view
    analytics.pageView('my_page');

    // Start session
    sessionManager.startSession();

    // Cleanup
    return () => {
      sessionManager.endSession();
    };
  }, []);

  const handleClick = () => {
    analytics.click('my_button', 'cta_button');
  };

  return <button onClick={handleClick}>Click Me</button>;
}
```

---

**Built for AI-first real estate.** Every event makes HOMEY smarter.
