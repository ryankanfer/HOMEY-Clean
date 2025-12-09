# HOMEY C-Suite Integration Guide

This guide explains how to connect your HOMEY web app to your c-suite AI agents.

## Overview

The c-suite integration allows your AI team (Denise, Bridget, Cody, Mark, Art, Cash, Ward, Ollie, Ariana, and The Boardroom) to receive real-time updates about what's happening in the HOMEY app.

## Architecture

```
HOMEY App                          C-Suite Agents
    │                                    │
    ├─► Analytics Events                 │
    ├─► Error Tracking                   │
    ├─► User Feedback                    │
    ├─► Performance Metrics              │
    │                                    │
    └─► csuite-integration.ts ──────────►│
         │                               │
         ├─► Database: csuite_notifications
         │                               │
         └─► API: /api/csuite ◄──────────┘
                  (Agents query here)
```

## Setup

### 1. Run the Database Migration

```bash
supabase db push
```

This creates the `csuite_notifications` table.

### 2. Set Environment Variables

Make sure these are set in your `.env.local`:
```
NEXT_PUBLIC_SUPABASE_URL=your_url
SUPABASE_SERVICE_ROLE_KEY=your_service_key
```

### 3. Import the Integration

```typescript
import csuite, { CSuiteAgent, notifyCSuite, buildCodeContext } from '@/lib/csuite-integration';
```

## Usage Examples

### Quick Notifications

```typescript
// Notify about a deployment
await csuite.notifyDeploy('Deployed v2.1.0 with new search filters');

// Notify about an error
await csuite.notifyError('Database connection timeout', undefined, {
  attempt: 3,
  duration_ms: 5000
});

// Notify about user feedback
await csuite.notifyFeedback(
  'User loves the new search UX but wants dark mode',
  userId,
  'positive'
);

// Send daily report to The Boardroom
await csuite.sendDailyReport();
```

### Custom Notifications

```typescript
import { notifyCSuite, CSuiteAgent, buildCodeContext } from '@/lib/csuite-integration';

// Notify Cody about a code review
await notifyCSuite({
  agentId: CSuiteAgent.CODY,
  title: 'Code Review: New AI Matching Algorithm',
  context: buildCodeContext({
    action: 'review',
    details: 'New algorithm improves match accuracy by 23%',
    code: `
      function calculateMatch(listing, preferences) {
        // ... algorithm code
      }
    `,
    metrics: {
      accuracy: 0.89,
      latency_ms: 45
    }
  }),
  priority: 'high'
});

// Notify multiple agents about a launch
await notifyCSuite({
  agentId: [CSuiteAgent.BRIDGET, CSuiteAgent.MARK, CSuiteAgent.ART],
  title: 'Launch Preparation: New Feature',
  context: await buildFeedbackContext({
    source: 'beta_tester',
    summary: 'Beta testers report 95% satisfaction with new feature',
    sentiment: 'positive'
  }),
  priority: 'medium'
});
```

### Integration with Analytics

```typescript
// In your analytics.ts or component
import { analytics } from '@/lib/analytics';
import csuite from '@/lib/csuite-integration';

// After tracking a critical event
analytics.scheduleTour(listingId, tourDate);

// Notify c-suite
await csuite.notifyCSuite({
  agentId: [CSuiteAgent.BRIDGET, CSuiteAgent.DENISE],
  title: 'Tour Scheduled',
  context: await buildDatabaseContext({
    topic: 'metrics',
    timeframe: '24h'
  }),
  priority: 'medium'
});
```

### Error Handling

```typescript
// In your error boundary or API error handler
try {
  // ... your code
} catch (error) {
  // Log to error tracking service
  console.error(error);

  // Notify Cody and Denise
  await csuite.notifyError(
    `API Error: ${error.message}`,
    error.stack,
    {
      endpoint: '/api/listings',
      method: 'GET',
      status: 500
    }
  );
}
```

## C-Suite API Endpoints

Your c-suite agents can query these endpoints:

### Get Notifications
```bash
GET /api/csuite?type=notifications&agent_id=tech-cody
```

Returns unread notifications for a specific agent.

### Get App Status
```bash
GET /api/csuite?type=status
```

Returns overall app health metrics.

### Get Metrics
```bash
GET /api/csuite?type=metrics&timeframe=24h
```

Returns event analytics for the specified timeframe.

### Get Recent Errors
```bash
GET /api/csuite?type=errors&timeframe=24h
```

Returns recent errors (integrate with your error tracking).

### Get Recent Feedback
```bash
GET /api/csuite?type=feedback&timeframe=7d
```

Returns recent user feedback and communication events.

### Mark Notifications as Read
```bash
POST /api/csuite/mark-read
Content-Type: application/json

{
  "notification_ids": ["uuid1", "uuid2"]
}
```

## Agent Responsibilities

Each agent receives notifications based on their role:

- **Denise (EA)**: All coordination, scheduling, and daily summaries
- **Bridget (Product)**: User feedback, feature requests, usage patterns
- **Cody (Tech)**: Code changes, errors, performance, deployments
- **Mark (Marketing)**: User engagement, growth metrics, campaigns
- **Art (Creative)**: Design feedback, visual content needs
- **Cash (Finance)**: Usage costs, pricing feedback, ROI metrics
- **Ward (Legal)**: Compliance issues, privacy concerns, terms updates
- **Ollie (Ops)**: Process issues, system operations, infrastructure
- **Ariana (AI)**: AI/ML performance, data quality, embeddings
- **The Boardroom**: Major updates requiring cross-functional discussion

## Best Practices

1. **Don't over-notify**: Only send notifications for meaningful events
2. **Use appropriate priority**: Reserve 'urgent' for critical issues
3. **Include context**: Provide relevant code, metrics, or user data
4. **Target the right agents**: Send to specific agents or use Boardroom for cross-functional topics
5. **Check async**: All notification functions are async - use await
6. **Handle errors gracefully**: Notifications shouldn't break your app if they fail

## Example: Daily Digest

Create a scheduled job to send daily digests:

```typescript
// In a cron job or scheduled function
import csuite from '@/lib/csuite-integration';

export async function sendDailyDigest() {
  // Send to The Boardroom for executive overview
  await csuite.sendDailyReport();

  // Send specific metrics to Cash
  await notifyCSuite({
    agentId: CSuiteAgent.CASH,
    title: 'Daily Financial Metrics',
    context: await buildDatabaseContext({
      topic: 'costs',
      timeframe: '24h'
    }),
    priority: 'medium'
  });

  // Send user engagement to Bridget and Mark
  await notifyCSuite({
    agentId: [CSuiteAgent.BRIDGET, CSuiteAgent.MARK],
    title: 'Daily Engagement Report',
    context: await buildDatabaseContext({
      topic: 'usage',
      timeframe: '24h'
    }),
    priority: 'medium'
  });
}
```

## Querying from C-Suite

In your c-suite app, you can query the HOMEY app:

```typescript
// In your c-suite frontend or agent script
const response = await fetch('https://your-app.vercel.app/api/csuite?type=notifications&agent_id=tech-cody');
const data = await response.json();

console.log(`${data.unread_count} unread notifications`);
data.notifications.forEach(notification => {
  console.log(`[${notification.priority}] ${notification.title}`);
  console.log(notification.context_content);
});
```

## Next Steps

1. Run the migration: `supabase db push`
2. Add notifications to key events in your app
3. Test with `csuite.notifyDeploy('Test notification')`
4. Build a dashboard in your c-suite app to view notifications
5. Set up scheduled daily reports

## Troubleshooting

**Notifications not appearing?**
- Check that the migration ran successfully
- Verify SUPABASE_SERVICE_ROLE_KEY is set
- Check console for errors
- Query the table directly: `SELECT * FROM csuite_notifications LIMIT 10;`

**API returning 500?**
- Ensure service role key has proper permissions
- Check that all referenced tables exist (user_profiles, listings, etc.)
- Review server logs for detailed error messages
