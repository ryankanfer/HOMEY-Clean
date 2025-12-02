'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Heart } from 'lucide-react';

interface HomeHeaderProps {
  userName?: string;
  savedCount?: number;
  onProfileClick?: () => void;
}

export default function HomeHeader({
  userName = '',
  savedCount = 0,
  onProfileClick,
}: HomeHeaderProps) {
  const [greeting, setGreeting] = useState('Good evening');
  const [dateStr, setDateStr] = useState('');

  useEffect(() => {
    const hour = new Date().getHours();
    if (hour < 12) setGreeting('Good morning');
    else if (hour < 18) setGreeting('Good afternoon');
    else setGreeting('Good evening');

    const options: Intl.DateTimeFormatOptions = {
      weekday: 'long',
      month: 'short',
      day: 'numeric'
    };
    setDateStr(new Date().toLocaleDateString('en-US', options));
  }, []);

  const firstName = userName?.split(' ')[0] || 'there';

  return (
    <div className="px-5 pt-6 pb-4">
      <div className="flex justify-between items-start mb-3">
        <div className="flex-1">
          <motion.p
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-[10px] font-bold text-white/40 uppercase tracking-widest mb-1"
          >
            {dateStr}
          </motion.p>
          <motion.h1
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="text-3xl font-serif text-white tracking-wide"
          >
            {greeting}, {firstName}
          </motion.h1>
        </div>

        <motion.button
          onClick={onProfileClick}
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.2 }}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          className="relative cursor-pointer group"
        >
          <div className="w-12 h-12 rounded-full bg-gradient-to-tr from-purple-500 to-pink-500 p-[2px] group-hover:shadow-lg group-hover:shadow-purple-500/20 transition-all">
            <div className="w-full h-full rounded-full bg-slate-900 flex items-center justify-center text-white text-lg font-bold">
              {firstName[0]?.toUpperCase() || 'U'}
            </div>
          </div>
        </motion.button>
      </div>

      {/* Shortlist Progress Pill */}
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ delay: 0.2 }}
        className="flex items-center gap-2"
      >
        <span className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-gradient-to-r from-purple-500/20 to-pink-500/20 border border-purple-500/30 text-xs font-medium text-white/90">
          <Heart className="w-3 h-3 text-pink-400 fill-pink-400" />
          Shortlist: {savedCount} {savedCount === 1 ? 'home' : 'homes'}
        </span>
        {savedCount >= 3 && (
          <span className="px-2 py-1 rounded-full bg-green-500/20 border border-green-500/50 text-[10px] font-medium text-green-300">
            Ready to tour ✓
          </span>
        )}
      </motion.div>
    </div>
  );
}
