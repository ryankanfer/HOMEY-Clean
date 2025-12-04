/**
 * Admin View Mode Manager
 * Allows admins to impersonate different user types for testing
 */

export type ViewAsMode = 'admin' | 'client' | 'agent';

const VIEW_MODE_KEY = 'homey_admin_view_mode';

/**
 * Set the admin's view mode
 */
export function setAdminViewMode(mode: ViewAsMode): void {
  if (typeof window === 'undefined') return;
  localStorage.setItem(VIEW_MODE_KEY, mode);
  console.log(`👁️ Admin viewing as: ${mode}`);
}

/**
 * Get the current admin view mode
 */
export function getAdminViewMode(): ViewAsMode {
  if (typeof window === 'undefined') return 'admin';
  const mode = localStorage.getItem(VIEW_MODE_KEY);
  return (mode as ViewAsMode) || 'admin';
}

/**
 * Clear the admin view mode (return to normal admin mode)
 */
export function clearAdminViewMode(): void {
  if (typeof window === 'undefined') return;
  localStorage.removeItem(VIEW_MODE_KEY);
  console.log('👁️ Admin view mode cleared');
}

/**
 * Check if admin is currently impersonating a user type
 */
export function isImpersonating(): boolean {
  const mode = getAdminViewMode();
  return mode !== 'admin';
}

/**
 * Get the effective user type for the current view mode
 * This is what pages should check when determining access
 */
export function getEffectiveUserType(isAdmin: boolean, actualUserType?: string): string | null {
  if (!isAdmin) return actualUserType || null;

  const viewMode = getAdminViewMode();

  switch (viewMode) {
    case 'client':
      return 'buyer'; // or 'renter'
    case 'agent':
      return 'agent';
    case 'admin':
    default:
      return actualUserType || null;
  }
}
