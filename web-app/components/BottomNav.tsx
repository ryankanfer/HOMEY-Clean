'use client';

import { useRouter, usePathname } from 'next/navigation';
import { Home, Search, User, Heart, Users } from 'lucide-react';

interface NavTab {
  id: string;
  label: string;
  icon: React.ComponentType<any> | string;
  path: string;
  position: 'left' | 'center-left' | 'center' | 'center-right' | 'right';
}

const NAV_TABS: NavTab[] = [
  { id: 'saved', label: 'Saved', icon: Heart, path: '/saved', position: 'left' },
  { id: 'search', label: 'Search', icon: Search, path: '/search', position: 'center-left' },
  { id: 'home', label: 'Home', icon: Home, path: '/home', position: 'center' },
  { id: 'pulse', label: 'Pulse', icon: Users, path: '/pulse', position: 'center-right' },
  { id: 'settings', label: 'You', icon: User, path: '/settings', position: 'right' },
];

export default function BottomNav() {
  const router = useRouter();
  const pathname = usePathname();

  const isActive = (path: string) => {
    if (path === '/home') return pathname === '/home' || pathname === '/';
    return pathname?.startsWith(path);
  };

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-[9999] safe-area-bottom">
      {/* Holo Glass Bottom Bar */}
      <div className="relative">
        {/* Glassmorphism backdrop */}
        <div className="absolute inset-0 bg-gradient-to-t from-white/10 via-white/5 to-transparent backdrop-blur-2xl border-t border-white/20" style={{
          background: 'linear-gradient(to top, rgba(255, 255, 255, 0.1), rgba(255, 255, 255, 0.05), transparent)',
          backdropFilter: 'blur(20px) saturate(180%)',
          WebkitBackdropFilter: 'blur(20px) saturate(180%)',
        }} />

        {/* Shimmer effect */}
        <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-white/30 to-transparent" />

        {/* Nav Items */}
        <div className="relative flex items-center justify-between px-12 py-4">
          {NAV_TABS.map((tab) => {
            const active = isActive(tab.path);
            const isEmoji = typeof tab.icon === 'string';

            return (
              <button
                key={tab.id}
                onClick={() => router.push(tab.path)}
                className="relative flex flex-col items-center justify-center min-w-[56px] min-h-[56px] active:scale-95 transition-transform"
              >
                {/* Icon or Emoji */}
                <div className={`transition-all duration-200 ${active ? 'scale-110' : 'scale-100'}`}>
                  {isEmoji ? (
                    <span
                      className={`text-2xl transition-all ${
                        active ? 'drop-shadow-[0_0_8px_rgba(255,255,255,0.5)]' : 'opacity-40 grayscale'
                      }`}
                    >
                      {tab.icon}
                    </span>
                  ) : (
                    (() => {
                      const Icon = tab.icon as React.ComponentType<any>;
                      return (
                        <Icon
                          className={`transition-colors ${
                            active ? 'text-white drop-shadow-[0_0_8px_rgba(255,255,255,0.5)]' : 'text-white/40'
                          }`}
                          strokeWidth={active ? 2.5 : 2}
                          size={24}
                        />
                      );
                    })()
                  )}
                </div>

                {/* Active indicator dot with glow */}
                {active && (
                  <div className="absolute -bottom-1 w-1.5 h-1.5 rounded-full bg-white shadow-[0_0_8px_rgba(255,255,255,0.8)]" />
                )}
              </button>
            );
          })}
        </div>
      </div>
    </nav>
  );
}
