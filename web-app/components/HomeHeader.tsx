'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';

interface HomeHeaderProps {
  userName?: string;
  savedCount?: number;
  onProfileClick?: () => void;
  isAdmin?: boolean;
  // User profile props
  userAvatar?: string | null;
  // AI Suggestion
  aiSuggestion?: {
    text: string;
    action: string;
    href: string;
  };
}

export default function HomeHeader({
  userName = '',
  savedCount = 0,
  onProfileClick,
  isAdmin = false,
  userAvatar,
  aiSuggestion,
}: HomeHeaderProps) {
  const router = useRouter();
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

  const getWittySubtext = () => {
    const hour = new Date().getHours();

    const morningTexts = [
      "DRINK YOUR COFFEE AND READ BELOW",
      "FRESH HOMES AND UPDATES AWAIT",
      "YOUR DAILY DOSE OF HOME HUNTING",
    ];

    const afternoonTexts = [
      "BEFORE YOUR MIDDAY NAP, TAKE A LOOK",
      "LUNCHTIME SCROLL? WE GOT YOU",
      "LET'S CHECK IN ON YOUR SEARCH",
    ];

    const eveningTexts = [
      "WIND DOWN WITH SOME HOME BROWSING",
      "END YOUR DAY WITH THIS",
      "HERE'S WHAT YOU NEED TO KNOW",
    ];

    const nightTexts = [
      "BURNING THE MIDNIGHT OIL?",
      "CAN'T SLEEP? LET'S BROWSE HOMES",
      "SOMEONE'S UP LATE",
    ];

    const getRandomText = (arr: string[]) => arr[Math.floor(Math.random() * arr.length)];

    if (hour >= 5 && hour < 12) return getRandomText(morningTexts);
    if (hour >= 12 && hour < 17) return getRandomText(afternoonTexts);
    if (hour >= 17 && hour < 21) return getRandomText(eveningTexts);
    return getRandomText(nightTexts);
  };

  const firstName = userName?.split(' ')[0] || 'there';

  // Generate initials from user name
  const getInitials = (name: string) => {
    const parts = name.split(' ');
    if (parts.length >= 2) {
      return `${parts[0][0]}${parts[parts.length - 1][0]}`.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  };

  const userInitials = getInitials(userName || 'U');

  return (
    <div className="px-5 pt-6 pb-3">
      <div className="flex justify-between items-start mb-2">
        <div className="flex-1">
          <motion.p
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-[9px] font-bold text-white/25 uppercase tracking-[0.15em] mb-1.5 font-display"
          >
            {dateStr}
          </motion.p>
          <motion.h1
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="text-[32px] font-bold text-white tracking-tightest leading-tight font-display mb-1"
          >
            {greeting}, {firstName}
          </motion.h1>
          <motion.p
            initial={{ opacity: 0, y: -5 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.15 }}
            className="text-[13px] text-white/50 font-medium tracking-tight font-body"
          >
            {getWittySubtext()}
          </motion.p>

          {/* AI Suggestion */}
          {aiSuggestion && (
            <motion.a
              href={aiSuggestion.href}
              initial={{ opacity: 0, y: -5 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 }}
              className="inline-flex items-center gap-2 mt-3 group"
            >
              <div className="flex items-center gap-2 px-3 py-2 bg-gradient-to-r from-purple-500/10 to-pink-500/10 border border-purple-500/20 rounded-full group-hover:border-purple-500/40 transition-all">
                <span className="text-[13px] text-white/70 font-medium tracking-tight font-body">{aiSuggestion.text}</span>
                <span className="text-[11px] text-purple-400 font-semibold tracking-tight font-body">{aiSuggestion.action} →</span>
              </div>
            </motion.a>
          )}
        </div>

        <motion.button
          onClick={onProfileClick}
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.2 }}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          className="relative cursor-pointer"
        >
          <div className="w-11 h-11 rounded-full bg-gradient-to-tr from-slate-700/90 to-slate-600/90 p-[1.5px] shadow-sm">
            {userAvatar ? (
              <img
                src={userAvatar}
                alt={userName}
                className="w-full h-full rounded-full object-cover bg-slate-900"
              />
            ) : (
              <div className="w-full h-full rounded-full bg-slate-900 flex items-center justify-center text-white text-base font-semibold">
                {userInitials}
              </div>
            )}
          </div>
        </motion.button>
      </div>
    </div>
  );
}
