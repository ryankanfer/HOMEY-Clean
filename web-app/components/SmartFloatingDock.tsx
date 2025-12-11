'use client';

import { usePathname, useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { Home, ChevronLeft, Menu } from 'lucide-react';
import { useState } from 'react';

interface SmartFloatingDockProps {
  // Optional override for page context
  customContext?: {
    icon?: React.ReactNode;
    title?: string;
    action?: {
      label: string;
      onClick: () => void;
    };
  };
  // Stats from parent (home page)
  pendingTours?: number;
  savedCount?: number;
  searchResultsCount?: number;
}

export default function SmartFloatingDock({
  customContext,
  pendingTours = 0,
  savedCount = 0,
  searchResultsCount = 0,
}: SmartFloatingDockProps) {
  const pathname = usePathname();
  const router = useRouter();
  const [showMenu, setShowMenu] = useState(false);

  // Determine context based on current page
  const getContext = () => {
    if (customContext) return customContext;

    // Determine page
    const isHome = pathname === '/home' || pathname === '/';
    const isSearch = pathname === '/search';
    const isSaved = pathname === '/saved';
    const isPulse = pathname === '/pulse';
    const isProfile = pathname === '/profile';
    const isSettings = pathname?.includes('/settings');

    // Home page
    if (isHome) {
      if (pendingTours > 0) {
        return {
          icon: <Home className="w-3.5 h-3.5" />,
          title: 'HOMEY',
          action: {
            label: `${pendingTours} tour${pendingTours > 1 ? 's' : ''} →`,
            onClick: () => router.push('/calendar'),
          },
        };
      }
      return {
        icon: <Home className="w-3.5 h-3.5" />,
        title: 'HOMEY',
        action: null,
      };
    }

    // Search page
    if (isSearch) {
      if (searchResultsCount > 0) {
        return {
          icon: <Home className="w-3.5 h-3.5" />,
          title: 'Search',
          action: {
            label: `${searchResultsCount} result${searchResultsCount > 1 ? 's' : ''}`,
            onClick: () => {}, // Could open filters
          },
        };
      }
      return {
        icon: <Home className="w-3.5 h-3.5" />,
        title: 'Search',
        action: {
          label: 'Filter →',
          onClick: () => {}, // Open filters modal
        },
      };
    }

    // Saved page
    if (isSaved) {
      if (savedCount >= 2) {
        return {
          icon: <Home className="w-3.5 h-3.5" />,
          title: 'Saved',
          action: {
            label: `Compare (${savedCount}) →`,
            onClick: () => router.push('/compare'),
          },
        };
      }
      return {
        icon: <Home className="w-3.5 h-3.5" />,
        title: 'Saved',
        action: null,
      };
    }

    // Pulse page
    if (isPulse) {
      return {
        icon: <Home className="w-3.5 h-3.5" />,
        title: 'Pulse',
        action: {
          label: 'Post →',
          onClick: () => {}, // Open post modal
        },
      };
    }

    // Profile page
    if (isProfile) {
      return {
        icon: <Home className="w-3.5 h-3.5" />,
        title: 'Profile',
        action: {
          label: 'Edit →',
          onClick: () => router.push('/settings'),
        },
      };
    }

    // Settings or other
    if (isSettings) {
      return {
        icon: <ChevronLeft className="w-3.5 h-3.5" />,
        title: 'Settings',
        action: null,
      };
    }

    // Default
    return {
      icon: <Home className="w-3.5 h-3.5" />,
      title: 'HOMEY',
      action: null,
    };
  };

  const context = getContext();
  const hasAction = context.action !== null;

  return (
    <>
      {/* Floating Dock - iPhone Optimized */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4, ease: 'easeOut' }}
        className="fixed top-3 left-0 right-0 z-50 flex justify-center pointer-events-none"
      >
        <motion.div
          layout
          className="relative flex items-center gap-2 px-4 py-2.5 bg-black/40 backdrop-blur-xl border border-white/[0.06] rounded-full shadow-lg shadow-black/20 pointer-events-auto"
        >
          {/* Left: Icon (tappable for menu) - 44px touch target */}
          <motion.button
            onClick={() => setShowMenu(!showMenu)}
            whileTap={{ scale: 0.95 }}
            className="flex items-center justify-center min-w-[32px] min-h-[32px] -ml-2 text-white/60 active:text-white/90 transition-colors"
          >
            {context.icon}
          </motion.button>

          {/* Center: Title */}
          <motion.span
            layout
            className="text-[13px] font-semibold text-white/80 tracking-tight whitespace-nowrap select-none"
          >
            {context.title}
          </motion.span>

          {/* Separator (only if action exists) */}
          <AnimatePresence mode="wait">
            {hasAction && (
              <motion.div
                initial={{ opacity: 0, scale: 0 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0 }}
                className="w-1 h-1 rounded-full bg-white/20"
              />
            )}
          </AnimatePresence>

          {/* Right: Action (if exists) - 44px touch target */}
          <AnimatePresence mode="wait">
            {hasAction && context.action && (
              <motion.button
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -10 }}
                onClick={context.action.onClick}
                whileTap={{ scale: 0.95 }}
                className="text-[12px] font-semibold text-purple-400 active:text-purple-300 transition-colors whitespace-nowrap min-h-[32px] flex items-center -mr-1"
              >
                {context.action.label}
              </motion.button>
            )}
          </AnimatePresence>
        </motion.div>
      </motion.div>

      {/* Quick Menu - iPhone Optimized */}
      <AnimatePresence>
        {showMenu && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setShowMenu(false)}
              className="fixed inset-0 bg-black/60 backdrop-blur-sm z-40"
            />

            {/* Menu - iPhone Style */}
            <motion.div
              initial={{ opacity: 0, y: -20, scale: 0.95 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: -20, scale: 0.95 }}
              transition={{ type: 'spring', damping: 25, stiffness: 300 }}
              className="fixed top-[52px] left-0 right-0 z-50 flex justify-center px-4"
            >
              <div className="w-full max-w-[240px] bg-slate-900/95 backdrop-blur-xl border border-white/10 rounded-[18px] shadow-2xl shadow-black/40 overflow-hidden">
                {/* Menu Items - 44px touch targets */}
                <button
                  onClick={() => {
                    router.push('/home');
                    setShowMenu(false);
                  }}
                  className="w-full min-h-[44px] px-4 py-3 text-left text-[15px] text-white/80 hover:bg-white/5 active:bg-white/10 transition-colors flex items-center gap-3"
                >
                  <Home className="w-4 h-4" />
                  Home
                </button>
                <div className="h-px bg-white/5 mx-4" />
                <button
                  onClick={() => {
                    router.push('/profile');
                    setShowMenu(false);
                  }}
                  className="w-full min-h-[44px] px-4 py-3 text-left text-[15px] text-white/80 hover:bg-white/5 active:bg-white/10 transition-colors flex items-center gap-3"
                >
                  <Menu className="w-4 h-4" />
                  Profile
                </button>
                <div className="h-px bg-white/5 mx-4" />
                <button
                  onClick={() => {
                    router.push('/settings');
                    setShowMenu(false);
                  }}
                  className="w-full min-h-[44px] px-4 py-3 text-left text-[15px] text-white/80 hover:bg-white/5 active:bg-white/10 transition-colors flex items-center gap-3"
                >
                  <Menu className="w-4 h-4" />
                  Settings
                </button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </>
  );
}
