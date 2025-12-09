/**
 * Test script for C-Suite Integration
 * Run with: npx tsx test-csuite.ts
 */

import csuite, { CSuiteAgent, notifyCSuite, buildCodeContext, buildDatabaseContext } from './lib/csuite-integration';

async function testIntegration() {
  console.log('🧪 Testing C-Suite Integration\n');

  try {
    // Test 1: Simple deployment notification
    console.log('1️⃣  Testing deployment notification...');
    await csuite.notifyDeploy('Test deployment: C-Suite integration v1.0');
    console.log('✅ Deployment notification sent\n');

    // Test 2: Error notification with code
    console.log('2️⃣  Testing error notification...');
    await csuite.notifyError(
      'Test error: Database connection timeout',
      'const db = await connectToDatabase();\n// timeout after 5000ms',
      { attempts: 3, duration_ms: 5000 }
    );
    console.log('✅ Error notification sent\n');

    // Test 3: User feedback
    console.log('3️⃣  Testing feedback notification...');
    await csuite.notifyFeedback(
      'Test feedback: User loves the new UI but wants dark mode',
      undefined,
      'positive'
    );
    console.log('✅ Feedback notification sent\n');

    // Test 4: Custom notification to specific agent
    console.log('4️⃣  Testing custom notification to Cody...');
    await notifyCSuite({
      agentId: CSuiteAgent.CODY,
      title: 'Test: Code Review Request',
      context: buildCodeContext({
        action: 'review',
        details: 'Please review the new matching algorithm',
        code: `
function calculateMatch(listing, preferences) {
  const score = 0;
  // ... algorithm logic
  return score;
}
        `,
        metrics: { accuracy: 0.92, latency_ms: 43 }
      }),
      priority: 'medium'
    });
    console.log('✅ Custom notification sent\n');

    // Test 5: Boardroom notification
    console.log('5️⃣  Testing Boardroom notification...');
    await notifyCSuite({
      agentId: CSuiteAgent.BOARDROOM,
      title: 'Test: Executive Update',
      context: await buildDatabaseContext({
        topic: 'usage',
        timeframe: '24h'
      }),
      priority: 'medium'
    });
    console.log('✅ Boardroom notification sent\n');

    console.log('🎉 All tests passed!');
    console.log('\nNext steps:');
    console.log('1. Check your Supabase dashboard: csuite_notifications table');
    console.log('2. Query the API: http://localhost:3000/api/csuite?type=notifications');
    console.log('3. Integrate this into your c-suite frontend to fetch notifications');

  } catch (error) {
    console.error('❌ Test failed:', error);
    process.exit(1);
  }
}

// Run tests
testIntegration();
