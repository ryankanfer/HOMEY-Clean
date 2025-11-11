# Save to HOMEY Share Extension

This directory contains a minimal iOS Share Extension that captures `streeteasy.com` URLs and saves them to Supabase under a `saved_listings` table.

## Add Target in Xcode

1. In Xcode, go to `File → New → Target…`
2. Choose `Share Extension` (Action/Share) and name it `Save to HOMEY`.
3. Check `Include UI`.
4. After creation, delete the auto-generated files and add:
   - `ShareExtension/SaveToHOMEY/ShareViewController.swift`
   - `ShareExtension/SaveToHOMEY/ShareExtensionEnv.swift`
5. In the extension's `Info.plist`, add keys:
   - `SUPABASE_URL` → your project URL
   - `SUPABASE_ANON_KEY` → your anon key

## Supabase Schema

Create table `saved_listings`:

```sql
create table saved_listings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  url text not null,
  title text,
  created_at timestamptz not null default now()
);

alter table saved_listings enable row level security;
create policy "owners can read their links" on saved_listings for select using (auth.uid() = user_id);
create policy "owners can insert links" on saved_listings for insert with check (auth.uid() = user_id);
```

If you prefer an Edge Function, deploy `saveListing` that inserts into the table and ensure it receives `user_id` via JWT.

## Notes

- The extension shows a subtle success message and haptic.
- The main app refreshes saved links on foreground and displays them in the `Saved Homes` section.