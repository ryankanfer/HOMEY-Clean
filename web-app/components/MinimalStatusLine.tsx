'use client';

import { usePathname } from 'next/navigation';
import { motion } from 'framer-motion';
import { ChevronLeft } from 'lucide-react';

interface MinimalStatusLineProps {
  // Optional overrides
  leftElement?: React.ReactNode;
  centerText?: string;
  rightBadge?: string | number;
  // Stats
  unreadCount?: number;
  pendingTours?: number;
}

export default function MinimalStatusLine({
  leftElement,
  centerText,
  rightBadge,
  unreadCount = 0,
  pendingTours = 0,
}: MinimalStatusLineProps) {
  const pathname = usePathname();

  // Determine page context
  const getPageInfo = () => {
    const isHome = pathname === '/home' || pathname === '/';
    const isSearch = pathname === '/search';
    const isSaved = pathname === '/saved';
    const isPulse = pathname === '/pulse';
    const isProfile = pathname === '/profile';
    const isSettings = pathname?.includes('/settings');

    // Default: HOMEY
    let center = 'HOMEY';
    let left = null;
    let right = null;

    if (isHome) {
      center = 'HOMEY';
      if (pendingTours > 0) {
        right = pendingTours.toString();
      }
    } else if (isSearch) {
      center = 'Search';
      left = <ChevronLeft className="w-4 h-4" />;
    } else if (isSaved) {
      center = 'Saved';
      left = <ChevronLeft className="w-4 h-4" />;
    } else if (isPulse) {
      center = 'Pulse';
      left = <ChevronLeft className="w-4 h-4" />;
    } else if (isProfile) {
      center = 'Profile';
      left = <ChevronLeft className="w-4 h-4" />;
    } else if (isSettings) {
      center = 'Settings';
      left = <ChevronLeft className="w-4 h-4" />;
    }

    // Show unread messages badge if any
    if (unreadCount > 0 && !right) {
      right = unreadCount.toString();
    }

    return {
      left: leftElement || left,
      center: centerText || center,
      right: rightBadge?.toString() || right,
    };
  };

  const pageInfo = getPageInfo();

  return (
    <motion.div
      initial={{ opacity: 0, y: -10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3, ease: 'easeOut' }}
      className="fixed top-0 left-0 right-0 z-50 h-[40px] bg-gradient-to-b from-black/20 to-transparent backdrop-blur-md"
    >
      <div className="h-full px-5 flex items-center justify-between">
        {/* Left Zone */}
        <div className="flex items-center justify-start w-[60px]">
          {pageInfo.left && (
            <div className="text-white/30">
              {pageInfo.left}
            </div>
          )}
        </div>

        {/* Center Zone - Floating */}
        <div className="flex-1 flex items-center justify-center">
          <span className="text-[11px] font-bold text-white/40 uppercase tracking-[0.12em] select-none font-display">
            {pageInfo.center}
          </span>
        </div>

        {/* Right Zone */}
        <div className="flex items-center justify-end w-[60px]">
          {pageInfo.right && (
            <div className="min-w-[20px] h-[20px] px-1.5 bg-gradient-to-r from-purple-500/80 to-pink-500/80 rounded-full flex items-center justify-center shadow-sm">
              <span className="text-[10px] font-bold text-white tabular-nums">
                {pageInfo.right}
              </span>
            </div>
          )}
        </div>
      </div>
    </motion.div>
  );
}
