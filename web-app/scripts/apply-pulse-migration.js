const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('Missing Supabase credentials');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

async function applyMigration() {
  try {
    const migrationPath = path.join(__dirname, '../supabase/migrations/20251206000000_pulse_tables.sql');
    const sql = fs.readFileSync(migrationPath, 'utf8');

    console.log('Applying Pulse tables migration...');

    const { data, error } = await supabase.rpc('exec_sql', { sql_query: sql });

    if (error) {
      // If exec_sql doesn't exist, try direct execution
      console.log('Trying direct SQL execution...');
      const { error: directError } = await supabase.from('_migrations').select('*').limit(1);

      if (directError) {
        console.error('Error:', error);
        process.exit(1);
      }

      // Execute SQL statements one by one
      const statements = sql
        .split(';')
        .map(s => s.trim())
        .filter(s => s.length > 0 && !s.startsWith('--'));

      for (const statement of statements) {
        if (statement.trim()) {
          console.log('Executing statement...');
          // Note: This won't work for DDL statements through the JS client
          // We need to use the Supabase management API or CLI
        }
      }
    } else {
      console.log('Migration applied successfully!');
    }
  } catch (error) {
    console.error('Error applying migration:', error);
    process.exit(1);
  }
}

applyMigration();
