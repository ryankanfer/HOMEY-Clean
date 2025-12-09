#!/usr/bin/env node
/**
 * Test script for automated notifications
 */

import { notifyUserSignup, notifyPayment, notifyPerformanceIssue } from './lib/csuite-auto-notify.js';

console.log('🧪 Testing Automated Notifications...\n');

try {
  // Test 1: User signup notification
  console.log('1️⃣ Testing user signup notification...');
  await notifyUserSignup('test-user-456', 'newuser@example.com', 'integration-test');
  console.log('   ✅ User signup notification sent\n');

  // Test 2: Payment notification
  console.log('2️⃣ Testing payment notification...');
  await notifyPayment(99.99, 'test-user-456', 'success');
  console.log('   ✅ Payment notification sent\n');

  // Test 3: Performance issue
  console.log('3️⃣ Testing performance issue notification...');
  await notifyPerformanceIssue('API response time increased', {
    p95: 850,
    p99: 1200,
    endpoint: '/api/test'
  });
  console.log('   ✅ Performance notification sent\n');

  console.log('✨ All notification tests completed successfully!');
  console.log('📱 Check http://localhost:5174 to see notifications in C-Suite');

} catch (error) {
  console.error('❌ Test failed:', error);
  process.exit(1);
}
