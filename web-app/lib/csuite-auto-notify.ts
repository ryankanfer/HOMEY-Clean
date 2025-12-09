/**
 * Automated C-Suite Notification System
 * Automatically notifies agents about important events
 */

import csuite, { CSuiteAgent, notifyCSuite, buildCodeContext, buildFeedbackContext, buildDatabaseContext } from './csuite-integration';

// ============================================
// ERROR HANDLING
// ============================================

/**
 * Wrap any async function to automatically notify Cody of errors
 */
export function withErrorNotification<T extends (...args: any[]) => Promise<any>>(
  fn: T,
  context?: string
): T {
  return (async (...args: Parameters<T>) => {
    try {
      return await fn(...args);
    } catch (error: any) {
      // Notify Cody and Denise of the error
      await csuite.notifyError(
        `${context || 'Operation'} failed: ${error.message}`,
        error.stack,
        {
          context: context || 'unknown',
          timestamp: new Date().toISOString(),
          args: JSON.stringify(args).substring(0, 200)
        }
      );
      throw error; // Re-throw to maintain error behavior
    }
  }) as T;
}

/**
 * Global error handler - call this in your error boundary
 */
export async function handleGlobalError(error: Error, errorInfo?: any) {
  await csuite.notifyError(
    `Global Error: ${error.message}`,
    error.stack,
    {
      componentStack: errorInfo?.componentStack,
      timestamp: new Date().toISOString()
    }
  );
}

// ============================================
// USER EVENTS
// ============================================

/**
 * Notify about new user signup
 */
export async function notifyUserSignup(userId: string, email: string, source?: string) {
  await notifyCSuite({
    agentId: [CSuiteAgent.BRIDGET, CSuiteAgent.MARK, CSuiteAgent.DENISE],
    title: 'New User Signup',
    context: await buildFeedbackContext({
      source: 'user_survey',
      summary: `New user registered: ${email}${source ? ` (from ${source})` : ''}`,
      userId,
      sentiment: 'positive'
    }),
    priority: 'medium'
  });
}

/**
 * Notify about user churning
 */
export async function notifyUserChurn(userId: string, reason?: string) {
  await notifyCSuite({
    agentId: [CSuiteAgent.BRIDGET, CSuiteAgent.DENISE],
    title: 'User Churned',
    context: await buildFeedbackContext({
      source: 'analytics',
      summary: `User churned${reason ? `: ${reason}` : ''}`,
      userId,
      sentiment: 'negative'
    }),
    priority: 'high'
  });
}

/**
 * Notify about user feedback
 */
export async function notifyUserFeedback(
  feedback: string,
  userId?: string,
  sentiment?: 'positive' | 'neutral' | 'negative'
) {
  await csuite.notifyFeedback(feedback, userId, sentiment);
}

// ============================================
// BUSINESS METRICS
// ============================================

/**
 * Notify about payment/revenue events
 */
export async function notifyPayment(amount: number, userId: string, status: 'success' | 'failed') {
  await notifyCSuite({
    agentId: status === 'success' ? [CSuiteAgent.CASH, CSuiteAgent.DENISE] : [CSuiteAgent.CASH, CSuiteAgent.CODY, CSuiteAgent.DENISE],
    title: status === 'success' ? 'Payment Processed' : 'Payment Failed',
    context: await buildDatabaseContext({
      topic: 'costs',
      timeframe: '24h'
    }),
    priority: status === 'failed' ? 'high' : 'medium'
  });
}

/**
 * Notify about milestone achievements
 */
export async function notifyMilestone(milestone: string, metrics?: Record<string, any>) {
  await notifyCSuite({
    agentId: CSuiteAgent.BOARDROOM,
    title: `Milestone Achieved: ${milestone}`,
    context: await buildDatabaseContext({
      topic: 'metrics',
      timeframe: '30d'
    }),
    priority: 'high'
  });
}

// ============================================
// PERFORMANCE & MONITORING
// ============================================

/**
 * Notify about performance issues
 */
export async function notifyPerformanceIssue(issue: string, metrics: Record<string, any>) {
  await notifyCSuite({
    agentId: [CSuiteAgent.CODY, CSuiteAgent.OLLIE],
    title: 'Performance Issue Detected',
    context: buildCodeContext({
      action: 'performance',
      details: issue,
      metrics
    }),
    priority: 'high'
  });
}

/**
 * Notify about high load/traffic
 */
export async function notifyHighTraffic(currentLoad: number, threshold: number) {
  await notifyCSuite({
    agentId: [CSuiteAgent.CODY, CSuiteAgent.OLLIE, CSuiteAgent.CASH],
    title: 'High Traffic Alert',
    context: await buildDatabaseContext({
      topic: 'performance',
      timeframe: '1h'
    }),
    priority: 'medium'
  });
}

// ============================================
// DEPLOYMENTS & CHANGES
// ============================================

/**
 * Auto-notify about deployments (call this in your CI/CD)
 */
export async function notifyDeployment(version: string, changes: string[]) {
  await csuite.notifyDeploy(
    `Deployed ${version}\n\nChanges:\n${changes.map(c => `- ${c}`).join('\n')}`
  );
}

/**
 * Notify about database migrations
 */
export async function notifyMigration(migration: string, status: 'success' | 'failed') {
  await notifyCSuite({
    agentId: [CSuiteAgent.CODY, CSuiteAgent.OLLIE, CSuiteAgent.DENISE],
    title: status === 'success' ? 'Migration Completed' : 'Migration Failed',
    context: buildCodeContext({
      action: status === 'failed' ? 'error' : 'deploy',
      details: `Database migration: ${migration}`,
    }),
    priority: status === 'failed' ? 'urgent' : 'medium'
  });
}

// ============================================
// LEGAL & COMPLIANCE
// ============================================

/**
 * Notify about privacy/security concerns
 */
export async function notifySecurityIssue(issue: string, severity: 'low' | 'medium' | 'high' | 'critical') {
  await notifyCSuite({
    agentId: [CSuiteAgent.WARD, CSuiteAgent.CODY, CSuiteAgent.DENISE],
    title: 'Security Issue',
    context: buildCodeContext({
      action: 'error',
      details: issue,
      metrics: { severity }
    }),
    priority: severity === 'critical' ? 'urgent' : severity === 'high' ? 'high' : 'medium'
  });
}

/**
 * Notify about terms/privacy policy updates
 */
export async function notifyPolicyUpdate(policy: string, changes: string) {
  await notifyCSuite({
    agentId: [CSuiteAgent.WARD, CSuiteAgent.DENISE],
    title: 'Policy Update Required',
    context: await buildFeedbackContext({
      source: 'support_ticket',
      summary: `${policy} needs updating: ${changes}`,
      sentiment: 'neutral'
    }),
    priority: 'high'
  });
}

// ============================================
// AI/ML SPECIFIC
// ============================================

/**
 * Notify about AI model performance
 */
export async function notifyModelPerformance(model: string, metrics: Record<string, any>) {
  await notifyCSuite({
    agentId: [CSuiteAgent.ARIANA, CSuiteAgent.CODY],
    title: `AI Model Update: ${model}`,
    context: buildCodeContext({
      action: 'performance',
      details: `Model: ${model}`,
      metrics
    }),
    priority: 'medium'
  });
}

// ============================================
// HELPER: Batch Notifications
// ============================================

/**
 * Send multiple notifications efficiently
 */
export async function batchNotify(notifications: Array<{
  agents: CSuiteAgent | CSuiteAgent[];
  title: string;
  message: string;
  priority?: 'low' | 'medium' | 'high' | 'urgent';
}>) {
  await Promise.all(
    notifications.map(n =>
      notifyCSuite({
        agentId: n.agents,
        title: n.title,
        context: buildCodeContext({
          action: 'review',
          details: n.message
        }),
        priority: n.priority || 'medium'
      })
    )
  );
}
