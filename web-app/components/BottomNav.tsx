'use client';

import React, { useEffect, useState, useRef } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { Home, Search, User, Heart, Calendar, FolderOpen, TrendingUp, MapPin, GraduationCap } from 'lucide-react';

interface NavButton {
  id: string;
  icon: React.ComponentType<any>;
  path: string;
}

interface QuickPage {
  id: string;
  label: string;
  icon: string;
  path: string;
}

// Default buttons (customizable via profile in future)
const DEFAULT_LEFT_BUTTON: NavButton = {
  id: 'search',
  icon: Search,
  path: '/search',
};

const DEFAULT_RIGHT_BUTTON: NavButton = {
  id: 'profile',
  icon: User,
  path: '/settings',
};

// Market-related pages (left button long press)
const MARKET_PAGES: QuickPage[] = [
  { id: 'search', label: 'Search', icon: '', path: '/search' },
  { id: 'pulse', label: 'Pulse', icon: '', path: '/pulse' },
];

// Personal journey pages (right button long press)
const PERSONAL_PAGES: QuickPage[] = [
  { id: 'saved', label: 'Saved', icon: '', path: '/saved' },
  { id: 'calendar', label: 'Calendar', icon: '', path: '/calendar' },
  { id: 'vault', label: 'Vault', icon: '', path: '/vault' },
  { id: 'teach', label: 'Teach HOMEY', icon: '', path: '/teach' },
  { id: 'profile', label: 'Profile', icon: '', path: '/settings' },
];

// Feedback form for home button long press
interface FeedbackFormData {
  message: string;
}

export default function BottomNav() {
  const router = useRouter();
  const pathname = usePathname();
  const [leftButton, setLeftButton] = useState(DEFAULT_LEFT_BUTTON);
  const [rightButton, setRightButton] = useState(DEFAULT_RIGHT_BUTTON);
  const [showLeftMenu, setShowLeftMenu] = useState(false);
  const [showRightMenu, setShowRightMenu] = useState(false);
  const [showFeedbackBox, setShowFeedbackBox] = useState(false);
  const [feedbackMessage, setFeedbackMessage] = useState('');
  const [isSubmittingFeedback, setIsSubmittingFeedback] = useState(false);
  const [showFloatingHint, setShowFloatingHint] = useState(true);

  const leftPressTimer = useRef<NodeJS.Timeout | null>(null);
  const rightPressTimer = useRef<NodeJS.Timeout | null>(null);
  const homePressTimer = useRef<NodeJS.Timeout | null>(null);

  // Load custom buttons from localStorage (customizable via /profile)
  useEffect(() => {
    const savedLeft = localStorage.getItem('nav_left_button');
    const savedRight = localStorage.getItem('nav_right_button');

    if (savedLeft) {
      try {
        setLeftButton(JSON.parse(savedLeft));
      } catch (e) {
        console.error('Failed to parse left button config');
      }
    }

    if (savedRight) {
      try {
        setRightButton(JSON.parse(savedRight));
      } catch (e) {
        console.error('Failed to parse right button config');
      }
    }
  }, []);

  const isActive = (path: string) => {
    if (path === '/home') return pathname === '/home' || pathname === '/';
    return pathname?.startsWith(path);
  };

  const isHomeActive = isActive('/home');

  // Long press handlers
  const handleLeftPressStart = () => {
    leftPressTimer.current = setTimeout(() => {
      setShowLeftMenu(true);
    }, 500); // 500ms long press
  };

  const handleLeftPressEnd = () => {
    if (leftPressTimer.current) {
      clearTimeout(leftPressTimer.current);
      leftPressTimer.current = null;
    }
  };

  const handleRightPressStart = () => {
    rightPressTimer.current = setTimeout(() => {
      setShowRightMenu(true);
    }, 500);
  };

  const handleRightPressEnd = () => {
    if (rightPressTimer.current) {
      clearTimeout(rightPressTimer.current);
      rightPressTimer.current = null;
    }
  };

  const handleLeftClick = () => {
    if (!showLeftMenu) {
      router.push(leftButton.path);
    }
  };

  const handleRightClick = () => {
    if (!showRightMenu) {
      router.push(rightButton.path);
    }
  };

  // Home button long press handlers
  const handleHomePressStart = () => {
    homePressTimer.current = setTimeout(() => {
      setShowFeedbackBox(true);
      setShowFloatingHint(false);
    }, 800); // 800ms long press
  };

  const handleHomePressEnd = () => {
    if (homePressTimer.current) {
      clearTimeout(homePressTimer.current);
      homePressTimer.current = null;
    }
  };

  const handleHomeClick = () => {
    if (!showFeedbackBox) {
      router.push('/home');
    }
  };

  const handleSubmitFeedback = async () => {
    if (!feedbackMessage.trim()) return;

    setIsSubmittingFeedback(true);

    try {
      // TODO: Send feedback to backend/analytics
      console.log('User feedback:', feedbackMessage);

      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 500));

      // Success - close and reset
      setShowFeedbackBox(false);
      setFeedbackMessage('');

      // Show success toast briefly
      setTimeout(() => {
        setShowFloatingHint(true);
      }, 3000);
    } catch (error) {
      console.error('Failed to submit feedback:', error);
    } finally {
      setIsSubmittingFeedback(false);
    }
  };

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-[9999] pointer-events-none pb-safe">
      {/* Floating Buttons Container */}
      <div className="flex items-center justify-between px-6 pb-6 pointer-events-auto">
        {/* Left Button with Menu */}
        <div className="relative">
          {/* Left Menu */}
          <AnimatePresence>
            {showLeftMenu && (
              <>
                {/* Backdrop */}
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{ opacity: 0 }}
                  className="fixed inset-0 bg-black/40 backdrop-blur-sm -z-10"
                  onClick={() => setShowLeftMenu(false)}
                />

                {/* Menu */}
                <motion.div
                  initial={{ opacity: 0, y: 20, scale: 0.95 }}
                  animate={{ opacity: 1, y: 0, scale: 1 }}
                  exit={{ opacity: 0, y: 20, scale: 0.95 }}
                  transition={{ type: 'spring', damping: 25, stiffness: 300 }}
                  className="absolute bottom-20 left-0 bg-gradient-to-br from-slate-900/98 to-slate-800/98 backdrop-blur-xl border border-white/20 rounded-2xl p-3 shadow-2xl min-w-[180px]"
                >
                  {/* Decorative gradient */}
                  <div className="absolute inset-0 bg-gradient-to-br from-blue-500/5 to-cyan-500/5 rounded-2xl pointer-events-none" />

                  {MARKET_PAGES.map((page, index) => (
                    <motion.button
                      key={page.id}
                      onClick={() => {
                        router.push(page.path);
                        setShowLeftMenu(false);
                      }}
                      initial={{ opacity: 0, x: -10 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: index * 0.05 }}
                      className="relative w-full flex items-center px-4 py-3.5 rounded-xl hover:bg-white/10 active:bg-white/15 transition-all group"
                    >
                      <span className="text-sm font-semibold text-white/90 group-hover:text-white transition-colors">{page.label}</span>
                    </motion.button>
                  ))}
                </motion.div>
              </>
            )}
          </AnimatePresence>

          <motion.button
            onClick={handleLeftClick}
            onMouseDown={handleLeftPressStart}
            onMouseUp={handleLeftPressEnd}
            onMouseLeave={handleLeftPressEnd}
            onTouchStart={handleLeftPressStart}
            onTouchEnd={handleLeftPressEnd}
            className="w-14 h-14 rounded-full bg-slate-900/80 backdrop-blur-xl border border-white/10 flex items-center justify-center shadow-lg"
            whileTap={{ scale: 0.9 }}
            transition={{ duration: 0.1 }}
          >
            {React.createElement(leftButton.icon, {
              className: `transition-colors ${isActive(leftButton.path) ? 'text-white' : 'text-white/50'}`,
              strokeWidth: 2,
              size: 22
            })}
          </motion.button>
        </div>

        {/* Center Home Button - Pill Shape */}
        <div className="relative">
          {/* Floating Hint Text - Centered over home button */}
          <AnimatePresence>
            {showFloatingHint && !showFeedbackBox && (
              <motion.div
                initial={{ opacity: 0, y: 5 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: 5 }}
                transition={{ duration: 0.3 }}
                className="absolute bottom-full mb-3 left-1/2 -translate-x-1/2 pointer-events-none"
              >
                <div className="relative bg-white/5 backdrop-blur-sm border border-white/10 rounded-full px-3 py-1.5 whitespace-nowrap">
                  <p className="text-[9px] text-white/40 font-bold tracking-widest uppercase">
                    HOLD ME. I WON'T INTERRUPT.
                  </p>
                  {/* Small arrow pointing down */}
                  <div className="absolute -bottom-1 left-1/2 -translate-x-1/2 w-0 h-0 border-l-[4px] border-r-[4px] border-t-[4px] border-l-transparent border-r-transparent border-t-white/5" />
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Feedback Input Box */}
          <AnimatePresence>
            {showFeedbackBox && (
              <>
                {/* Backdrop */}
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{ opacity: 0 }}
                  className="fixed inset-0 bg-black/40 backdrop-blur-sm -z-10"
                  onClick={() => {
                    setShowFeedbackBox(false);
                    setFeedbackMessage('');
                    setTimeout(() => setShowFloatingHint(true), 3000);
                  }}
                />

                {/* Feedback Card */}
                <motion.div
                  initial={{ opacity: 0, y: 20, scale: 0.95, x: '-50%' }}
                  animate={{ opacity: 1, y: 0, scale: 1, x: '-50%' }}
                  exit={{ opacity: 0, y: 20, scale: 0.95, x: '-50%' }}
                  transition={{ type: 'spring', damping: 25, stiffness: 300 }}
                  className="fixed bottom-[140px] w-[360px] max-w-[90vw] z-[10000]"
                  style={{ left: '50%' }}
                >
                  <div className="relative bg-gradient-to-br from-slate-900/98 to-slate-800/98 backdrop-blur-xl border border-white/20 rounded-3xl p-5 shadow-2xl">
                    {/* Decorative gradient accent */}
                    <div className="absolute inset-0 bg-gradient-to-br from-purple-500/10 to-pink-500/10 rounded-3xl pointer-events-none" />

                    {/* Header */}
                    <div className="relative mb-4">
                      <h3 className="text-white font-semibold text-base mb-1">Share Your Thoughts</h3>
                      <p className="text-white/50 text-xs">Help us improve your experience</p>
                    </div>

                    {/* Input */}
                    <textarea
                      value={feedbackMessage}
                      onChange={(e) => setFeedbackMessage(e.target.value)}
                      placeholder="What's on your mind?"
                      className="relative w-full bg-white/5 border border-white/10 rounded-2xl px-4 py-3 text-white placeholder:text-white/30 text-sm resize-none focus:outline-none focus:ring-2 focus:ring-purple-500/50 focus:border-transparent transition-all"
                      rows={4}
                      autoFocus
                    />

                    {/* Actions */}
                    <div className="relative flex gap-2 mt-4">
                      <button
                        onClick={() => {
                          setShowFeedbackBox(false);
                          setFeedbackMessage('');
                          setTimeout(() => setShowFloatingHint(true), 3000);
                        }}
                        className="flex-1 px-4 py-2.5 rounded-xl bg-white/5 border border-white/10 text-white/60 text-sm font-medium hover:bg-white/10 transition-colors"
                      >
                        Cancel
                      </button>
                      <button
                        onClick={handleSubmitFeedback}
                        disabled={!feedbackMessage.trim() || isSubmittingFeedback}
                        className="flex-1 px-4 py-2.5 rounded-xl bg-gradient-to-r from-purple-500 to-pink-500 text-white text-sm font-semibold hover:from-purple-600 hover:to-pink-600 disabled:opacity-40 disabled:cursor-not-allowed transition-all active:scale-95"
                      >
                        {isSubmittingFeedback ? 'Sending...' : 'Send'}
                      </button>
                    </div>

                    {/* Arrow pointing down to home button */}
                    <div className="absolute -bottom-2.5 left-1/2 -translate-x-1/2 w-0 h-0 border-l-[12px] border-r-[12px] border-t-[12px] border-l-transparent border-r-transparent border-t-slate-900/98" />
                  </div>
                </motion.div>
              </>
            )}
          </AnimatePresence>

          <motion.button
            onClick={handleHomeClick}
            onMouseDown={handleHomePressStart}
            onMouseUp={handleHomePressEnd}
            onMouseLeave={handleHomePressEnd}
            onTouchStart={handleHomePressStart}
            onTouchEnd={handleHomePressEnd}
            className="px-8 h-14 rounded-full bg-slate-900/80 backdrop-blur-xl border border-white/10 flex items-center justify-center shadow-lg"
            whileTap={{ scale: 0.95 }}
            transition={{ duration: 0.1 }}
          >
            <Home
              className={`transition-colors ${isHomeActive ? 'text-white' : 'text-white/50'}`}
              strokeWidth={isHomeActive ? 2.5 : 2}
              size={24}
            />
          </motion.button>
        </div>

        {/* Right Button with Menu */}
        <div className="relative">
          {/* Right Menu */}
          <AnimatePresence>
            {showRightMenu && (
              <>
                {/* Backdrop */}
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{ opacity: 0 }}
                  className="fixed inset-0 bg-black/40 backdrop-blur-sm -z-10"
                  onClick={() => setShowRightMenu(false)}
                />

                {/* Menu */}
                <motion.div
                  initial={{ opacity: 0, y: 20, scale: 0.95 }}
                  animate={{ opacity: 1, y: 0, scale: 1 }}
                  exit={{ opacity: 0, y: 20, scale: 0.95 }}
                  transition={{ type: 'spring', damping: 25, stiffness: 300 }}
                  className="absolute bottom-20 right-0 bg-gradient-to-br from-slate-900/98 to-slate-800/98 backdrop-blur-xl border border-white/20 rounded-2xl p-3 shadow-2xl min-w-[180px]"
                >
                  {/* Decorative gradient */}
                  <div className="absolute inset-0 bg-gradient-to-br from-purple-500/5 to-pink-500/5 rounded-2xl pointer-events-none" />

                  {PERSONAL_PAGES.map((page, index) => (
                    <motion.button
                      key={page.id}
                      onClick={() => {
                        router.push(page.path);
                        setShowRightMenu(false);
                      }}
                      initial={{ opacity: 0, x: 10 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: index * 0.05 }}
                      className="relative w-full flex items-center px-4 py-3.5 rounded-xl hover:bg-white/10 active:bg-white/15 transition-all group"
                    >
                      <span className="text-sm font-semibold text-white/90 group-hover:text-white transition-colors">{page.label}</span>
                    </motion.button>
                  ))}
                </motion.div>
              </>
            )}
          </AnimatePresence>

          <motion.button
            onClick={handleRightClick}
            onMouseDown={handleRightPressStart}
            onMouseUp={handleRightPressEnd}
            onMouseLeave={handleRightPressEnd}
            onTouchStart={handleRightPressStart}
            onTouchEnd={handleRightPressEnd}
            className="w-14 h-14 rounded-full bg-slate-900/80 backdrop-blur-xl border border-white/10 flex items-center justify-center shadow-lg"
            whileTap={{ scale: 0.9 }}
            transition={{ duration: 0.1 }}
          >
            {React.createElement(rightButton.icon, {
              className: `transition-colors ${isActive(rightButton.path) ? 'text-white' : 'text-white/50'}`,
              strokeWidth: 2,
              size: 22
            })}
          </motion.button>
        </div>
      </div>
    </nav>
  );
}
