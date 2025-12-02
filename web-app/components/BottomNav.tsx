'use client';

import { useState, useEffect } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import { motion } from 'framer-motion';
import { Home, Search, User } from 'lucide-react';

interface NavTab {
  id: string;
  label: string;
  icon: React.ComponentType<{ className?: string; strokeWidth?: number }>;
  path: string;
  position: 'left' | 'center' | 'right';
}

const NAV_TABS: NavTab[] = [
  { id: 'search', label: 'Search', icon: Search, path: '/search', position: 'left' },
  { id: 'home', label: 'Home', icon: Home, path: '/home', position: 'center' },
  { id: 'settings', label: 'You', icon: User, path: '/settings', position: 'right' },
];

export default function BottomNav() {
  const router = useRouter();
  const pathname = usePathname();
  const [isVisible, setIsVisible] = useState(true);
  const [lastScrollY, setLastScrollY] = useState(0);

  const isActive = (path: string) => {
    if (path === '/home') return pathname === '/home' || pathname === '/';
    return pathname?.startsWith(path);
  };

  // Auto-hide nav on scroll down, show on scroll up
  useEffect(() => {
    const handleScroll = () => {
      const currentScrollY = window.scrollY;

      if (currentScrollY < lastScrollY || currentScrollY < 50) {
        setIsVisible(true);
      } else if (currentScrollY > lastScrollY && currentScrollY > 50) {
        setIsVisible(false);
      }

      setLastScrollY(currentScrollY);
    };

    window.addEventListener('scroll', handleScroll, { passive: true });

    return () => {
      window.removeEventListener('scroll', handleScroll);
    };
  }, [lastScrollY]);

  return (
    <motion.nav
      className="fixed bottom-0 left-0 right-0 z-[9999] safe-area-bottom"
      initial={{ y: 100, opacity: 0 }}
      animate={{
        y: isVisible ? 0 : 100,
        opacity: isVisible ? 1 : 0
      }}
      transition={{ duration: 0.3, ease: [0.25, 0.1, 0.25, 1] }}
    >
      {/* Minimal Bottom Bar */}
      <div className="relative">
        {/* Backdrop blur with subtle gradient */}
        <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-black/40 to-transparent backdrop-blur-xl" />

        {/* Top border */}
        <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-white/10 to-transparent" />

        {/* Nav Items */}
        <div className="relative flex items-center justify-between px-12 py-4">
          {NAV_TABS.map((tab) => {
            const Icon = tab.icon;
            const active = isActive(tab.path);
            const isCenter = tab.position === 'center';

            return (
              <motion.button
                key={tab.id}
                onClick={() => router.push(tab.path)}
                className={`relative flex flex-col items-center justify-center ${
                  isCenter ? 'min-w-[64px] min-h-[64px]' : 'min-w-[56px] min-h-[56px]'
                }`}
                whileTap={{ scale: 0.9 }}
                transition={{ duration: 0.1 }}
              >
                {/* Icon */}
                <motion.div
                  animate={{
                    scale: active ? 1.1 : 1,
                  }}
                  transition={{ duration: 0.2 }}
                >
                  <Icon
                    className={`transition-colors ${
                      active ? 'text-white' : 'text-white/40'
                    }`}
                    strokeWidth={active ? 2.5 : 2}
                    size={isCenter ? 28 : 24}
                  />
                </motion.div>

                {/* Active indicator dot */}
                {active && (
                  <motion.div
                    layoutId="activeTab"
                    className="absolute -bottom-1 w-1 h-1 rounded-full bg-white"
                    initial={false}
                    transition={{
                      type: 'spring',
                      stiffness: 500,
                      damping: 30,
                    }}
                  />
                )}
              </motion.button>
            );
          })}
        </div>
      </div>
    </motion.nav>
  );
}
