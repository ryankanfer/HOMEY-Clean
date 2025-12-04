# Supabase Storage Setup Guide

## Quick Setup (5 minutes)

### Step 1: Create Storage Bucket

**Option A: Using Supabase Dashboard**
1. Go to your [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Click **Storage** in the sidebar
4. Click **New bucket**
5. Name: `avatars`
6. Toggle **Public bucket** to ON
7. Click **Create bucket**

**Option B: Using SQL**
```sql
-- Run this in your Supabase SQL Editor

-- Create public bucket for avatars
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Set up storage policies to allow uploads
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'avatars' );

CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
WITH CHECK ( bucket_id = 'avatars' AND auth.role() = 'authenticated' );

CREATE POLICY "Users can update own files"
ON storage.objects FOR UPDATE
USING ( bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1] );

CREATE POLICY "Users can delete own files"
ON storage.objects FOR DELETE
USING ( bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1] );
```

### Step 2: Verify Setup

1. Go to **Storage** > **avatars** bucket
2. You should see an empty bucket ready for uploads
3. Test by uploading an avatar image through the app!

## What This Enables

- **Avatar Upload**: Users can upload custom photos
- **AI Image Generation**: Generated images are stored in the bucket
- **Profile Pictures**: All avatar URLs point to this bucket

## Troubleshooting

**Error: "Bucket not found"**
- Make sure the bucket is named exactly `avatars`
- Verify the bucket exists in Storage section
- Check that it's marked as public

**Error: "Failed to upload image"**
- Check RLS policies are created
- Verify user is authenticated
- Ensure bucket is public

**Error: "Permission denied"**
- Run the SQL policies above
- Make sure user is logged in
- Check bucket public setting is ON
