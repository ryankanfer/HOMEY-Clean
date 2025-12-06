# The Pulse - Setup Instructions

The Pulse feature is fully implemented, but the database tables need to be created.

## Quick Setup

### Option 1: Supabase Dashboard (Recommended)

1. **Go to SQL Editor**
   - Visit: https://supabase.com/dashboard/project/mzqswvyfnblghgvcgxpw/sql/new

2. **Copy and Run Migration**
   - Open file: `supabase/migrations/20251206000000_pulse_tables.sql`
   - Copy ALL the SQL content
   - Paste into the SQL Editor
   - Click "Run"

3. **Verify Setup**
   ```bash
   node --env-file=.env.local scripts/check-pulse-tables.mjs
   ```

   You should see:
   ```
   ✅ vibe_logs table exists
   ✅ neighborhood_pulse table exists
   ✅ vibe_playlists table exists
   ✅ All Pulse tables are ready!
   ```

## What Gets Created

### Tables
- **vibe_logs** - Community posts about neighborhoods
- **neighborhood_pulse** - Real-time neighborhood vibe data
- **vibe_playlists** - Curated collections of vibe logs

### Features
- Row Level Security (RLS) policies
- Performance indexes
- Default playlists (Coffee, Nightlife, Parks, etc.)
- Auto-updated timestamps

## After Setup

Once the migration is applied, The Pulse page (`/pulse`) will be fully functional:
- ✅ Post neighborhood vibes
- ✅ Like/unlike posts
- ✅ Filter by category
- ✅ Mobile-first responsive design
- ✅ Real-time updates

## Troubleshooting

If you see "Pulse tables missing" error:
1. Make sure you ran the migration in Supabase Dashboard
2. Check the migration ran successfully (no errors)
3. Run the verification script above
4. Refresh your browser

## Developer Notes

The migration file is properly formatted and ready to apply. The CLI `supabase db push` had authentication issues, so manual application via dashboard is the recommended approach.
