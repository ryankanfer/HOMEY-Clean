# Database Migrations

## How to Run Migrations

### Option 1: Using Supabase CLI (Recommended)

```bash
# If you have Supabase CLI installed
supabase db push

# Or apply specific migration
psql $DATABASE_URL < migrations/20251203_add_avatar_url_to_profiles.sql
```

### Option 2: Using Supabase Dashboard

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Copy the contents of `20251203_add_avatar_url_to_profiles.sql`
4. Paste and run the SQL

### Option 3: Using psql

```bash
# Connect to your Supabase database
psql "postgresql://postgres:[YOUR-PASSWORD]@db.[YOUR-PROJECT-REF].supabase.co:5432/postgres"

# Run the migration
\i migrations/20251203_add_avatar_url_to_profiles.sql
```

## Migrations

### `20251203_add_avatar_url_to_profiles.sql`

Adds `avatar_url` column to the `profiles` table for storing user-uploaded or AI-generated avatar images.

**Changes:**
- Adds `avatar_url TEXT` column to `profiles` table
- Adds documentation comment
- Safe to run (uses `IF NOT EXISTS`)

## Verifying Migrations

After running a migration, verify it worked:

```sql
-- Check if column exists
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'profiles' AND column_name = 'avatar_url';
```
