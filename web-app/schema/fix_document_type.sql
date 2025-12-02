-- Fix: Make document_type optional initially (set during extraction)
-- Run this in Supabase SQL Editor to fix the constraint

ALTER TABLE user_documents 
  ALTER COLUMN document_type DROP NOT NULL,
  ALTER COLUMN document_type SET DEFAULT 'other';
