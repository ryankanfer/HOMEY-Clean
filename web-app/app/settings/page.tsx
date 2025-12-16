'use client';

export const dynamic = 'force-dynamic';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

export default function SettingsRedirect() {
  const router = useRouter();

  useEffect(() => {
    // Redirect to profile page
    router.replace('/profile');
  }, [router]);

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 flex items-center justify-center">
      <div className="text-center">
        <div className="w-16 h-16 border-4 border-white/20 border-t-purple-400 rounded-full animate-spin mx-auto mb-4"></div>
        <p className="text-white/80">Redirecting to profile...</p>
      </div>
    </div>
  );
}
