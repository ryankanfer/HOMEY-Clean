'use client';

import { useState, useEffect } from 'react';
import { auth, db } from '@/lib/supabase';
import { checkAdminFromProfile } from '@/lib/admin';
import AdminPill from './AdminPill';

/**
 * Wrapper component that shows AdminPill on all pages for admin users
 * Add this to root layout to make admin button available everywhere
 */
export default function AdminPillWrapper() {
  const [isAdmin, setIsAdmin] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkAdmin();
  }, []);

  const checkAdmin = async () => {
    try {
      const { data: { user } } = await auth.getUser();

      if (!user) {
        setIsAdmin(false);
        setLoading(false);
        return;
      }

      const { data: profile } = await db.getProfile(user.id);
      const adminStatus = checkAdminFromProfile(profile);
      setIsAdmin(adminStatus);
    } catch (error) {
      console.error('Error checking admin status:', error);
      setIsAdmin(false);
    } finally {
      setLoading(false);
    }
  };

  // Don't render anything while loading or if not admin
  if (loading || !isAdmin) return null;

  return <AdminPill />;
}
