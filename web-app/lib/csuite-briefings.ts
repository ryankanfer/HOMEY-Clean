/**
 * Daily Briefing System for C-Suite
 * Generates comprehensive daily reports for The Boardroom
 */

import { notifyCSuite, CSuiteAgent, buildDatabaseContext } from './csuite-integration';
import { supabase } from './supabase';

interface BriefingData {
  users: {
    total: number;
    new_24h: number;
    active_24h: number;
  };
  listings: {
    total: number;
    new_24h: number;
  };
  activity: {
    saves_24h: number;
    events_24h: number;
    top_events: Array<{ type: string; count: number }>;
  };
  errors: {
    count_24h: number;
    critical: number;
  };
}

/**
 * Gather all data for the briefing
 */
async function gatherBriefingData(): Promise<BriefingData> {
  const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();

  // Get user metrics
  const { count: totalUsers } = await supabase
    .from('user_profiles')
    .select('*', { count: 'exact', head: true });

  const { count: newUsers } = await supabase
    .from('user_profiles')
    .select('*', { count: 'exact', head: true })
    .gte('created_at', yesterday);

  // Get listing metrics
  const { count: totalListings } = await supabase
    .from('listings')
    .select('*', { count: 'exact', head: true });

  const { count: newListings } = await supabase
    .from('listings')
    .select('*', { count: 'exact', head: true })
    .gte('created_at', yesterday);

  // Get activity metrics
  const { count: saves24h } = await supabase
    .from('saved_listings')
    .select('*', { count: 'exact', head: true })
    .gte('saved_at', yesterday);

  const { data: recentEvents } = await supabase
    .from('user_events')
    .select('event_type')
    .gte('timestamp', yesterday);

  // Count event types
  const eventCounts: Record<string, number> = {};
  recentEvents?.forEach(e => {
    eventCounts[e.event_type] = (eventCounts[e.event_type] || 0) + 1;
  });

  const topEvents = Object.entries(eventCounts)
    .map(([type, count]) => ({ type, count }))
    .sort((a, b) => b.count - a.count)
    .slice(0, 5);

  return {
    users: {
      total: totalUsers || 0,
      new_24h: newUsers || 0,
      active_24h: 0, // TODO: Calculate from events
    },
    listings: {
      total: totalListings || 0,
      new_24h: newListings || 0,
    },
    activity: {
      saves_24h: saves24h || 0,
      events_24h: recentEvents?.length || 0,
      top_events: topEvents,
    },
    errors: {
      count_24h: 0, // TODO: Integrate error tracking
      critical: 0,
    },
  };
}

/**
 * Format the morning briefing
 */
function formatMorningBrief(data: BriefingData): string {
  const date = new Date().toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });

  return `# Good Morning! 🌅
**${date}**

## 📊 Yesterday's Metrics

### Users
- **Total Users**: ${data.users.total.toLocaleString()} ${data.users.new_24h > 0 ? `(+${data.users.new_24h} new)` : ''}
- **New Signups (24h)**: ${data.users.new_24h}
${data.users.new_24h > 5 ? '🎉 Great signup day!' : data.users.new_24h === 0 ? '⚠️ No new signups yesterday' : ''}

### Listings
- **Total Listings**: ${data.listings.total.toLocaleString()} ${data.listings.new_24h > 0 ? `(+${data.listings.new_24h} new)` : ''}
- **New Listings (24h)**: ${data.listings.new_24h}

### Activity
- **Saves (24h)**: ${data.activity.saves_24h}
- **Total Events (24h)**: ${data.activity.events_24h.toLocaleString()}

**Top Events:**
${data.activity.top_events.map(e => `- **${e.type}**: ${e.count}`).join('\n')}

### Health
${data.errors.critical > 0 ? `⚠️ **${data.errors.critical} critical errors** - needs attention!` : ''}
${data.errors.count_24h > 10 ? `⚠️ ${data.errors.count_24h} errors in 24h` : data.errors.count_24h > 0 ? `✅ ${data.errors.count_24h} minor errors` : '✅ No errors - smooth sailing!'}

## 🎯 Focus Areas Today
${data.users.new_24h === 0 ? '- **Marketing**: Focus on user acquisition\n' : ''}
${data.errors.critical > 0 ? '- **Engineering**: Address critical errors\n' : ''}
${data.activity.saves_24h < 10 ? '- **Product**: Improve engagement\n' : ''}

---
*Generated automatically at 8:30 AM* 🤖
`;
}

/**
 * Format the evening briefing
 */
function formatEveningBrief(data: BriefingData): string {
  const date = new Date().toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric'
  });

  return `# End of Day Summary 🌙
**${date}**

## 📈 Today's Progress

### Users & Growth
- **New Users Today**: ${data.users.new_24h}
- **Active Users**: ${data.users.active_24h}
- **Total User Base**: ${data.users.total.toLocaleString()}
${data.users.new_24h > 5 ? '\n🎉 **Strong growth day!**' : ''}

### Engagement
- **Listings Saved**: ${data.activity.saves_24h}
- **User Actions**: ${data.activity.events_24h.toLocaleString()}
${data.activity.saves_24h > 20 ? '\n✨ **High engagement!**' : ''}

### System Health
${data.errors.critical > 0 ? `\n⚠️ **Action Required**: ${data.errors.critical} critical errors need attention before tomorrow` : '✅ **Systems Healthy** - No critical issues'}

## 🎯 Tomorrow's Priorities
${data.errors.critical > 0 ? '1. **Fix critical errors** (Cody)\n' : ''}
${data.users.new_24h < 3 ? '2. **Boost acquisition** (Mark, Bridget)\n' : ''}
${data.activity.saves_24h < 10 ? '3. **Improve engagement** (Bridget)\n' : ''}

## 💭 Reflection
${data.users.new_24h > 0 && data.errors.critical === 0 ? '**Great day!** New users joined and systems are stable.' : ''}
${data.errors.critical > 0 ? '**Challenges today.** Let\'s tackle them first thing tomorrow.' : ''}
${data.activity.saves_24h === 0 ? '**Low engagement.** Consider user research or product improvements.' : ''}

---
*Have a great evening! See you at 8:30 AM* 🌟
`;
}

/**
 * Send morning briefing at 8:30 AM
 */
export async function sendMorningBriefing() {
  console.log('📰 Generating morning briefing...');

  try {
    const data = await gatherBriefingData();
    const brief = formatMorningBrief(data);

    await notifyCSuite({
      agentId: CSuiteAgent.BOARDROOM,
      title: `☀️ Morning Briefing - ${new Date().toLocaleDateString()}`,
      context: {
        type: 'database',
        content: brief,
        timestamp: Date.now(),
        metadata: data
      },
      priority: 'high'
    });

    console.log('✅ Morning briefing sent to The Boardroom');
  } catch (error) {
    console.error('Failed to send morning briefing:', error);
  }
}

/**
 * Send evening briefing at 6:00 PM
 */
export async function sendEveningBriefing() {
  console.log('📰 Generating evening briefing...');

  try {
    const data = await gatherBriefingData();
    const brief = formatEveningBrief(data);

    await notifyCSuite({
      agentId: CSuiteAgent.BOARDROOM,
      title: `🌙 Evening Summary - ${new Date().toLocaleDateString()}`,
      context: {
        type: 'database',
        content: brief,
        timestamp: Date.now(),
        metadata: data
      },
      priority: 'medium'
    });

    console.log('✅ Evening briefing sent to The Boardroom');
  } catch (error) {
    console.error('Failed to send evening briefing:', error);
  }
}

/**
 * Weekly summary (Fridays at 5 PM)
 */
export async function sendWeeklySummary() {
  console.log('📰 Generating weekly summary...');

  try {
    // Get 7-day data
    const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();

    const { count: newUsers7d } = await supabase
      .from('user_profiles')
      .select('*', { count: 'exact', head: true })
      .gte('created_at', sevenDaysAgo);

    const { count: saves7d } = await supabase
      .from('saved_listings')
      .select('*', { count: 'exact', head: true })
      .gte('saved_at', sevenDaysAgo);

    const weekSummary = `# Weekly Summary 📊
**${new Date().toLocaleDateString()} - Week in Review**

## This Week's Highlights

### Growth
- **New Users**: ${newUsers7d}
- **User Saves**: ${saves7d}

### Wins 🎉
${newUsers7d > 10 ? '- Strong user acquisition!\n' : ''}
${saves7d > 50 ? '- High engagement levels\n' : ''}

### Areas for Improvement
${newUsers7d < 5 ? '- Focus on marketing and acquisition\n' : ''}
${saves7d < 20 ? '- Work on user engagement and retention\n' : ''}

## Next Week's Goals
1. Continue momentum in strong areas
2. Address improvement opportunities
3. Ship new features to boost engagement

---
*Have a great weekend! 🎉*
`;

    await notifyCSuite({
      agentId: CSuiteAgent.BOARDROOM,
      title: '📊 Weekly Summary',
      context: {
        type: 'database',
        content: weekSummary,
        timestamp: Date.now()
      },
      priority: 'high'
    });

    console.log('✅ Weekly summary sent');
  } catch (error) {
    console.error('Failed to send weekly summary:', error);
  }
}

/**
 * Manual test function
 */
export async function testBriefing() {
  console.log('🧪 Testing briefing system...');
  await sendMorningBriefing();
  console.log('✅ Test complete - check The Boardroom!');
}
