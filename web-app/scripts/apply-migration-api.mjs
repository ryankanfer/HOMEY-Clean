import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const projectRef = supabaseUrl.match(/https:\/\/([^.]+)\.supabase\.co/)[1];

async function applyMigration() {
  try {
    console.log('Reading migration file...');
    const migrationPath = join(__dirname, '../supabase/migrations/20251206000000_pulse_tables.sql');
    const sql = readFileSync(migrationPath, 'utf8');

    console.log('Applying migration to Supabase...\n');

    // Use Supabase Management API to execute SQL
    const response = await fetch(`https://${projectRef}.supabase.co/rest/v1/rpc/exec_sql`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': serviceRoleKey,
        'Authorization': `Bearer ${serviceRoleKey}`,
      },
      body: JSON.stringify({ sql })
    });

    if (!response.ok) {
      // Try alternative: Execute via pg_net if exec_sql doesn't exist
      console.log('Trying alternative method...');

      // Split SQL into individual statements and execute them
      const statements = sql
        .split(';')
        .map(s => s.trim())
        .filter(s => s.length > 0 && !s.startsWith('--'));

      console.log(`Found ${statements.length} SQL statements to execute`);
      console.log('\n⚠️  Unable to execute via API. Please run the migration manually:');
      console.log('\n1. Visit: https://supabase.com/dashboard/project/' + projectRef + '/sql/new');
      console.log('2. Copy the contents of: supabase/migrations/20251206000000_pulse_tables.sql');
      console.log('3. Paste and run the SQL in the SQL Editor');
      console.log('\nThe file has been created and is ready to apply.');
      return;
    }

    const result = await response.json();
    console.log('✅ Migration applied successfully!');
    console.log(result);

  } catch (error) {
    console.error('❌ Error:', error.message);
    console.log('\n⚠️  Please apply the migration manually:');
    console.log('\n1. Visit: https://supabase.com/dashboard/project/' + projectRef + '/sql/new');
    console.log('2. Copy the contents of: supabase/migrations/20251206000000_pulse_tables.sql');
    console.log('3. Paste and run the SQL in the SQL Editor');
  }
}

applyMigration();
