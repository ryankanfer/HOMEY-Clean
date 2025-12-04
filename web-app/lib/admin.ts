import { supabase } from './supabase';

/**
 * Check if a user is an admin
 * Admin: ryan@homeypocket.ai
 */
export async function isUserAdmin(userId?: string): Promise<boolean> {
  if (!userId) return false;

  try {
    const { data: profile } = await supabase
      .from('profiles')
      .select('is_admin, email')
      .eq('id', userId)
      .single();

    return profile?.is_admin === true || profile?.email === 'ryan@homeypocket.ai';
  } catch (error) {
    console.error('Error checking admin status:', error);
    return false;
  }
}

/**
 * Get admin status from profile data
 */
export function checkAdminFromProfile(profile: any): boolean {
  return profile?.is_admin === true || profile?.email === 'ryan@homeypocket.ai';
}

/**
 * Admin email constant
 */
export const ADMIN_EMAIL = 'ryan@homeypocket.ai';
