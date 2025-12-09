/**
 * HOMEY C-Suite Integration
 * Connects the HOMEY web app to AI c-suite agents
 */

import { createClient } from '@supabase/supabase-js';

// Use service role key for server-side operations (bypasses RLS)
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;
const supabase = createClient(supabaseUrl, supabaseServiceKey);

// Agent IDs from c-suite
export enum CSuiteAgent {
  DENISE = 'ea-denise',           // Executive Assistant
  BRIDGET = 'pm-bridget',         // Product Manager
  CODY = 'tech-cody',             // Engineering Lead
  MARK = 'marketing-mark',        // Marketing
  ART = 'creative-art',           // Creative Director
  CASH = 'finance-cash',          // Finance
  WARD = 'legal-ward',            // Legal
  OLLIE = 'ops-ollie',            // Operations
  ARIANA = 'ai-ariana',           // AI Architect
  BOARDROOM = 'the-boardroom',    // Group Chat
}

export type DataContextType = 'code' | 'feedback' | 'database';

export interface CSuiteDataContext {
  type: DataContextType;
  content: string;
  timestamp: number;
  metadata?: Record<string, any>;
}

export interface CSuiteNotification {
  agentId: CSuiteAgent | CSuiteAgent[];  // Can notify multiple agents
  title: string;
  context: CSuiteDataContext;
  priority?: 'low' | 'medium' | 'high' | 'urgent';
}

// Context Builders - Format app data for specific agent types

/**
 * CODE Context Builder
 * For Cody (Engineering) and Ariana (AI Architect)
 */
export const buildCodeContext = (params: {
  action: 'deploy' | 'error' | 'performance' | 'review';
  details: string;
  code?: string;
  metrics?: Record<string, any>;
}): CSuiteDataContext => {
  let content = `**CODE ${params.action.toUpperCase()}**\n\n`;
  content += `${params.details}\n\n`;

  if (params.code) {
    content += `\`\`\`\n${params.code}\n\`\`\`\n\n`;
  }

  if (params.metrics) {
    content += `**Metrics:**\n`;
    Object.entries(params.metrics).forEach(([key, value]) => {
      content += `- ${key}: ${value}\n`;
    });
  }

  return {
    type: 'code',
    content,
    timestamp: Date.now(),
    metadata: params,
  };
};

/**
 * FEEDBACK Context Builder
 * For Bridget (Product) and Mark (Marketing)
 */
export const buildFeedbackContext = async (params: {
  source: 'user_survey' | 'support_ticket' | 'analytics' | 'beta_tester';
  summary: string;
  userId?: string;
  sentiment?: 'positive' | 'neutral' | 'negative';
}): Promise<CSuiteDataContext> => {
  let content = `**USER FEEDBACK - ${params.source.toUpperCase().replace('_', ' ')}**\n\n`;
  content += `**Sentiment:** ${params.sentiment || 'unknown'}\n\n`;
  content += `${params.summary}\n\n`;

  // Enrich with user context if available
  if (params.userId) {
    try {
      const { data: profile } = await supabase
        .from('user_profiles')
        .select('*')
        .eq('user_id', params.userId)
        .single();

      if (profile) {
        content += `**User Context:**\n`;
        content += `- Journey Stage: ${profile.journey_stage || 'unknown'}\n`;
        content += `- Active Days: ${profile.days_since_signup || 0}\n`;
        if (profile.target_neighborhoods) {
          content += `- Target Areas: ${profile.target_neighborhoods.join(', ')}\n`;
        }
      }
    } catch (error) {
      console.error('Failed to enrich feedback context:', error);
    }
  }

  return {
    type: 'feedback',
    content,
    timestamp: Date.now(),
    metadata: params,
  };
};

/**
 * DATABASE Context Builder
 * For Cody (Tech), Cash (Finance), Ollie (Ops), Ariana (AI)
 */
export const buildDatabaseContext = async (params: {
  topic: 'performance' | 'usage' | 'errors' | 'metrics' | 'costs';
  timeframe?: '1h' | '24h' | '7d' | '30d';
}): Promise<CSuiteDataContext> => {
  let content = `**DATABASE REPORT - ${params.topic.toUpperCase()}**\n`;
  content += `**Timeframe:** ${params.timeframe || '24h'}\n\n`;

  try {
    // Get relevant metrics based on topic
    switch (params.topic) {
      case 'usage':
        const { count: userCount } = await supabase
          .from('user_profiles')
          .select('*', { count: 'exact', head: true });

        const { count: listingCount } = await supabase
          .from('listings')
          .select('*', { count: 'exact', head: true });

        const { count: savedCount } = await supabase
          .from('saved_listings')
          .select('*', { count: 'exact', head: true });

        content += `**Current Metrics:**\n`;
        content += `- Total Users: ${userCount || 0}\n`;
        content += `- Total Listings: ${listingCount || 0}\n`;
        content += `- Total Saves: ${savedCount || 0}\n`;
        content += `- Engagement Rate: ${userCount ? ((savedCount || 0) / userCount).toFixed(2) : 0} saves/user\n`;
        break;

      case 'performance':
        content += `**Performance Metrics:**\n`;
        content += `- Average Query Time: [Requires Supabase dashboard]\n`;
        content += `- API Response Time: [Requires monitoring tool]\n`;
        content += `- Error Rate: [Check logs]\n`;
        break;

      case 'errors':
        // Could integrate with error tracking service
        content += `**Recent Errors:**\n`;
        content += `[Integrate with error tracking service like Sentry]\n`;
        break;

      case 'costs':
        content += `**Cost Metrics:**\n`;
        content += `- Database Size: [Check Supabase dashboard]\n`;
        content += `- API Calls: [Check usage metrics]\n`;
        content += `- Storage: [Check media storage]\n`;
        break;

      case 'metrics':
        // Get analytics summary
        const { data: recentEvents } = await supabase
          .from('user_events')
          .select('event_type, event_category')
          .gte('timestamp', new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString())
          .limit(1000);

        if (recentEvents) {
          const eventCounts: Record<string, number> = {};
          recentEvents.forEach(event => {
            eventCounts[event.event_type] = (eventCounts[event.event_type] || 0) + 1;
          });

          content += `**Event Distribution (24h):**\n`;
          Object.entries(eventCounts)
            .sort(([, a], [, b]) => b - a)
            .slice(0, 10)
            .forEach(([type, count]) => {
              content += `- ${type}: ${count}\n`;
            });
        }
        break;
    }
  } catch (error) {
    content += `\n**Error fetching data:** ${error}\n`;
    console.error('Failed to build database context:', error);
  }

  return {
    type: 'database',
    content,
    timestamp: Date.now(),
    metadata: params,
  };
};

/**
 * Send notification to c-suite agents
 * This logs the notification to a database table that the c-suite can poll
 */
export const notifyCSuite = async (notification: CSuiteNotification): Promise<void> => {
  try {
    const agents = Array.isArray(notification.agentId)
      ? notification.agentId
      : [notification.agentId];

    // Store notifications in a table that c-suite can query
    const notifications = agents.map(agentId => ({
      agent_id: agentId,
      title: notification.title,
      context_type: notification.context.type,
      context_content: notification.context.content,
      context_metadata: notification.context.metadata || {},
      priority: notification.priority || 'medium',
      read: false,
      created_at: new Date(notification.context.timestamp).toISOString(),
    }));

    const { error } = await supabase
      .from('csuite_notifications')
      .insert(notifications);

    if (error) {
      console.error('Failed to notify c-suite:', error);
      return;
    }

    console.log(`📬 C-Suite notified: ${notification.title} → ${agents.join(', ')}`);
  } catch (error) {
    console.error('Error notifying c-suite:', error);
  }
};

/**
 * Quick notification helpers for common scenarios
 */
export const csuite = {
  // Notify about deployment or code changes
  notifyDeploy: async (message: string, code?: string) => {
    await notifyCSuite({
      agentId: [CSuiteAgent.CODY, CSuiteAgent.DENISE],
      title: 'Deployment Update',
      context: buildCodeContext({
        action: 'deploy',
        details: message,
        code,
      }),
      priority: 'medium',
    });
  },

  // Notify about errors
  notifyError: async (error: string, code?: string, metrics?: Record<string, any>) => {
    await notifyCSuite({
      agentId: [CSuiteAgent.CODY, CSuiteAgent.DENISE],
      title: 'Error Detected',
      context: buildCodeContext({
        action: 'error',
        details: error,
        code,
        metrics,
      }),
      priority: 'high',
    });
  },

  // Notify about user feedback
  notifyFeedback: async (summary: string, userId?: string, sentiment?: 'positive' | 'neutral' | 'negative') => {
    await notifyCSuite({
      agentId: [CSuiteAgent.BRIDGET, CSuiteAgent.MARK],
      title: 'User Feedback',
      context: await buildFeedbackContext({
        source: 'user_survey',
        summary,
        userId,
        sentiment,
      }),
      priority: sentiment === 'negative' ? 'high' : 'medium',
    });
  },

  // Daily report to entire c-suite
  sendDailyReport: async () => {
    await notifyCSuite({
      agentId: CSuiteAgent.BOARDROOM,
      title: 'Daily App Report',
      context: await buildDatabaseContext({
        topic: 'usage',
        timeframe: '24h',
      }),
      priority: 'medium',
    });
  },

  // Performance alert
  notifyPerformance: async (issue: string) => {
    await notifyCSuite({
      agentId: [CSuiteAgent.CODY, CSuiteAgent.CASH, CSuiteAgent.OLLIE],
      title: 'Performance Alert',
      context: await buildDatabaseContext({
        topic: 'performance',
        timeframe: '1h',
      }),
      priority: 'high',
    });
  },
};

export default csuite;
