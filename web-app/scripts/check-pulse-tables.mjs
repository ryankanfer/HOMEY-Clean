import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);

async function checkTables() {
  console.log('Checking if Pulse tables exist...\n');

  // Check vibe_logs table
  const { data: vibeLogsData, error: vibeLogsError } = await supabase
    .from('vibe_logs')
    .select('*')
    .limit(1);

  if (vibeLogsError) {
    console.log('❌ vibe_logs table:', vibeLogsError.message);
  } else {
    console.log('✅ vibe_logs table exists');
  }

  // Check neighborhood_pulse table
  const { data: pulseData, error: pulseError } = await supabase
    .from('neighborhood_pulse')
    .select('*')
    .limit(1);

  if (pulseError) {
    console.log('❌ neighborhood_pulse table:', pulseError.message);
  } else {
    console.log('✅ neighborhood_pulse table exists');
  }

  // Check vibe_playlists table
  const { data: playlistsData, error: playlistsError } = await supabase
    .from('vibe_playlists')
    .select('*')
    .limit(1);

  if (playlistsError) {
    console.log('❌ vibe_playlists table:', playlistsError.message);
  } else {
    console.log('✅ vibe_playlists table exists');
    console.log(`   Found ${playlistsData?.length || 0} playlists`);
  }

  const hasErrors = vibeLogsError || pulseError || playlistsError;

  if (hasErrors) {
    console.log('\n⚠️  Some tables are missing. Please apply the migration:');
    console.log('   1. Go to your Supabase Dashboard SQL Editor');
    console.log('   2. Copy the contents of: supabase/migrations/20251206000000_pulse_tables.sql');
    console.log('   3. Paste and run the SQL');
  } else {
    console.log('\n✅ All Pulse tables are ready!');
  }
}

checkTables().catch(console.error);
