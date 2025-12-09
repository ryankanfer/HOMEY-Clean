#!/usr/bin/env node
/**
 * Test script for daily briefings
 */

import { testBriefing } from './lib/csuite-briefings.js';

console.log('🧪 Testing Daily Briefing System...\n');

try {
  console.log('📬 Sending test briefing to The Boardroom...');
  await testBriefing();
  console.log('\n✨ Test briefing sent successfully!');
  console.log('📱 Check The Boardroom at http://localhost:5174');
  console.log('\n📅 Scheduled briefings (production):');
  console.log('   • Morning: 8:30 AM daily');
  console.log('   • Evening: 6:00 PM daily');
  console.log('   • Weekly: Friday 5:00 PM');

} catch (error) {
  console.error('❌ Test failed:', error);
  process.exit(1);
}
