// Version tracking and announcement utilities

export const APP_VERSION = '1.0.0'; // Update this on each deploy

export interface ReleaseNote {
  version: string;
  date: string;
  title: string;
  changes: string[];
  highlights?: string[];
}

// Check if user has seen this version
export function hasSeenVersion(version: string): boolean {
  if (typeof window === 'undefined') return true;

  const lastSeenVersion = localStorage.getItem('homey_last_seen_version');
  return lastSeenVersion === version;
}

// Mark version as seen
export function markVersionAsSeen(version: string): void {
  if (typeof window === 'undefined') return;

  localStorage.setItem('homey_last_seen_version', version);
  localStorage.setItem('homey_version_seen_at', new Date().toISOString());
}

// Get stored release notes
export function getReleaseNotes(): ReleaseNote[] {
  if (typeof window === 'undefined') return [];

  const stored = localStorage.getItem('homey_release_notes');
  if (!stored) return getDefaultReleaseNotes();

  try {
    return JSON.parse(stored);
  } catch {
    return getDefaultReleaseNotes();
  }
}

// Store release notes (admin only)
export function storeReleaseNotes(notes: ReleaseNote[]): void {
  if (typeof window === 'undefined') return;

  localStorage.setItem('homey_release_notes', JSON.stringify(notes));
}

// Get release notes for a specific version
export function getReleaseNotesForVersion(version: string): ReleaseNote | null {
  const notes = getReleaseNotes();
  return notes.find(note => note.version === version) || null;
}

// Default release notes (can be updated manually or via admin)
function getDefaultReleaseNotes(): ReleaseNote[] {
  return [
    {
      version: '1.0.0',
      date: '2025-12-04',
      title: 'Profile Redesign & Admin Improvements',
      highlights: [
        '✨ Brand new passport-style profile page',
        '🎯 Interactive admin analytics',
        '📝 Quick notes from anywhere',
      ],
      changes: [
        'Redesigned profile page with sleek, passport-like aesthetic',
        'Added tap-to-copy functionality for admin notes',
        'Made analytics cards clickable with detailed views',
        'Added long-press on admin button to add notes from anywhere',
        'All admin sections now collapsed by default',
        'Settings page now redirects to unified profile page',
        'Improved mobile responsiveness across admin dashboard',
      ],
    },
  ];
}

// Check if there's a new version and return release notes if so
export function checkForNewVersion(): { hasNewVersion: boolean; releaseNotes: ReleaseNote | null } {
  const currentVersion = APP_VERSION;
  const hasSeen = hasSeenVersion(currentVersion);

  if (hasSeen) {
    return { hasNewVersion: false, releaseNotes: null };
  }

  const releaseNotes = getReleaseNotesForVersion(currentVersion);
  return { hasNewVersion: true, releaseNotes };
}

// Format version for display
export function formatVersion(version: string): string {
  return `v${version}`;
}
