-- Fix: Update vibe_logs foreign key to reference profiles instead of auth.users
-- This allows the join query in pulseDb.ts to work correctly

-- Drop the existing foreign key constraint
ALTER TABLE vibe_logs
  DROP CONSTRAINT IF EXISTS vibe_logs_user_id_fkey;

-- Add new foreign key pointing to profiles
ALTER TABLE vibe_logs
  ADD CONSTRAINT vibe_logs_user_id_fkey
  FOREIGN KEY (user_id)
  REFERENCES profiles(id)
  ON DELETE CASCADE;
