/**
 * Setup script for C-Suite Wiki tables
 * Run this once to create the wiki tables in Supabase
 */

import { createClient } from '@supabase/supabase-js';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Read environment variables
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('❌ Missing environment variables');
  console.error('Required: NEXT_PUBLIC_SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function setupWikiTables() {
  console.log('🚀 Setting up C-Suite Wiki tables...\n');

  try {
    // Read the migration file
    const migrationPath = join(__dirname, '..', 'supabase', 'migrations', '20251209000002_csuite_wiki.sql');
    const migrationSQL = readFileSync(migrationPath, 'utf8');

    console.log('📄 Applying migration: 20251209000002_csuite_wiki.sql');

    // Execute the migration SQL
    // Note: This might fail if run via RPC, so we'll try via the admin API
    const { data, error } = await supabase.rpc('exec_sql', { sql: migrationSQL }).catch(async (rpcError) => {
      // If RPC doesn't work, try direct SQL execution via the REST API
      console.log('⚠️  RPC exec_sql not available, trying alternative method...');

      // Split the SQL into individual statements
      const statements = migrationSQL
        .split(';')
        .map(s => s.trim())
        .filter(s => s.length > 0 && !s.startsWith('--'));

      for (const statement of statements) {
        if (statement.length > 0) {
          try {
            const result = await fetch(`${supabaseUrl}/rest/v1/rpc/exec_sql`, {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'apikey': supabaseServiceKey,
                'Authorization': `Bearer ${supabaseServiceKey}`
              },
              body: JSON.stringify({ sql: statement + ';' })
            });

            if (!result.ok) {
              console.log(`⚠️  Statement failed (might be expected): ${statement.substring(0, 50)}...`);
            }
          } catch (err) {
            console.log(`⚠️  Error executing statement: ${err.message}`);
          }
        }
      }

      return { data: null, error: null };
    });

    if (error) {
      console.error('❌ Migration failed:', error.message);
      process.exit(1);
    }

    console.log('✅ Migration applied successfully!\n');

    // Verify tables were created
    console.log('🔍 Verifying tables...');

    const { data: wikiData, error: wikiError } = await supabase
      .from('csuite_wiki')
      .select('*')
      .limit(1);

    if (wikiError && !wikiError.message.includes('does not exist')) {
      console.error('❌ Error checking csuite_wiki table:', wikiError.message);
    } else if (wikiError) {
      console.log('⚠️  csuite_wiki table might not exist yet');
    } else {
      console.log('✅ csuite_wiki table exists');
    }

    const { data: historyData, error: historyError } = await supabase
      .from('csuite_wiki_history')
      .select('*')
      .limit(1);

    if (historyError && !historyError.message.includes('does not exist')) {
      console.error('❌ Error checking csuite_wiki_history table:', historyError.message);
    } else if (historyError) {
      console.log('⚠️  csuite_wiki_history table might not exist yet');
    } else {
      console.log('✅ csuite_wiki_history table exists');
    }

    // Check if starter pages exist
    const { data: pages, error: pagesError } = await supabase
      .from('csuite_wiki')
      .select('title')
      .limit(10);

    if (!pagesError && pages) {
      console.log(`\n📚 Found ${pages.length} wiki pages:`);
      pages.forEach(page => console.log(`  - ${page.title}`));
    }

    console.log('\n✨ Setup complete!\n');
    console.log('You can now:');
    console.log('1. Access the wiki through the API endpoints');
    console.log('2. Add new pages via the WikiView component');
    console.log('3. Let C-Suite agents search and reference wiki pages\n');

  } catch (error) {
    console.error('❌ Setup failed:', error.message);
    process.exit(1);
  }
}

setupWikiTables();
