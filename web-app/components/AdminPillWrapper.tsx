'use client';

import { useState, useEffect } from 'react';
import { usePathname } from 'next/navigation';
import { auth, db } from '@/lib/supabase';
import { checkAdminFromProfile } from '@/lib/admin';
import QuickActions from './admin/QuickActions';

/**
 * Wrapper component that shows QuickActions FAB on all pages for admin users
 * Add this to root layout to make admin quick actions available everywhere
 */
export default function AdminPillWrapper() {
  const [isAdmin, setIsAdmin] = useState(false);
  const [loading, setLoading] = useState(true);
  const pathname = usePathname();

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

  // Hide on public pages
  const publicPages = ['/login', '/signup', '/'];
  const isPublicPage = publicPages.includes(pathname);

  // Don't render anything while loading, if not admin, or on public pages
  if (loading || !isAdmin || isPublicPage) return null;

  return <QuickActions />;
}
