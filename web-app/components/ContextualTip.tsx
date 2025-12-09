'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Lightbulb, Sparkles } from 'lucide-react';

export interface ContextualTipConfig {
  id: string;
  title: string;
  message: string;
  icon?: React.ReactNode;
  position?: 'top' | 'bottom' | 'center';
  autoHideDuration?: number; // milliseconds, 0 means no auto-hide
  showOnce?: boolean; // Only show once per user
}

interface ContextualTipProps {
  tip: ContextualTipConfig | null;
  onDismiss: () => void;
}

export default function ContextualTip({ tip, onDismiss }: ContextualTipProps) {
  const [isVisible, setIsVisible] = useState(false);
  const [hasBeenShown, setHasBeenShown] = useState(false);

  useEffect(() => {
    if (!tip) {
      setIsVisible(false);
      return;
    }

    // Check if this tip has been shown before
    if (tip.showOnce) {
      const shown = localStorage.getItem(`tip_shown_${tip.id}`);
      if (shown) {
        return;
      }
    }

    // Show the tip
    setIsVisible(true);
    setHasBeenShown(true);

    // Mark as shown in localStorage
    if (tip.showOnce) {
      localStorage.setItem(`tip_shown_${tip.id}`, 'true');
    }

    // Auto-hide if duration is set
    if (tip.autoHideDuration && tip.autoHideDuration > 0) {
      const timer = setTimeout(() => {
        handleDismiss();
      }, tip.autoHideDuration);

      return () => clearTimeout(timer);
    }
  }, [tip]);

  const handleDismiss = () => {
    // Haptic feedback
    if ('vibrate' in navigator) {
      navigator.vibrate(10);
    }
    setIsVisible(false);
    setTimeout(() => {
      onDismiss();
    }, 300);
  };

  if (!tip || !isVisible) return null;

  const getPositionClasses = () => {
    switch (tip.position) {
      case 'top':
        return 'top-24 left-1/2 -translate-x-1/2';
      case 'bottom':
        return 'bottom-32 left-1/2 -translate-x-1/2';
      case 'center':
      default:
        return 'top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2';
    }
  };

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 z-[9999] pointer-events-none"
      >
        {/* Backdrop */}
        <div
          className="absolute inset-0 bg-black/20 backdrop-blur-[2px] pointer-events-auto"
          onClick={handleDismiss}
        />

        {/* Tip Card */}
        <motion.div
          initial={{ opacity: 0, scale: 0.9, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.9, y: 20 }}
          className={`fixed z-[10000] w-[calc(100vw-48px)] max-w-[380px] pointer-events-auto ${getPositionClasses()}`}
        >
          <div className="relative bg-gradient-to-br from-blue-600/95 via-purple-600/95 to-pink-600/95 backdrop-blur-xl border border-white/30 rounded-2xl p-5 shadow-2xl">
            {/* Shimmer effect */}
            <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-white/50 to-transparent" />

            {/* Close button */}
            <button
              onClick={handleDismiss}
              className="absolute top-3 right-3 w-7 h-7 rounded-full bg-white/20 hover:bg-white/30 flex items-center justify-center transition-colors"
            >
              <X className="w-4 h-4 text-white" />
            </button>

            {/* Icon and Title */}
            <div className="flex items-start gap-3 mb-3">
              <div className="w-10 h-10 rounded-full bg-white/20 flex items-center justify-center flex-shrink-0">
                {tip.icon || <Lightbulb className="w-5 h-5 text-white" />}
              </div>
              <div className="flex-1 pr-6">
                <h3 className="text-lg font-bold text-white mb-1">{tip.title}</h3>
                <p className="text-sm text-white/90 leading-relaxed">{tip.message}</p>
              </div>
            </div>

            {/* Got it button */}
            <button
              onClick={handleDismiss}
              className="w-full mt-4 py-2.5 rounded-lg bg-white/20 hover:bg-white/30 text-white font-semibold text-sm transition-colors"
            >
              Got it!
            </button>

            {/* Decorative sparkles */}
            <div className="absolute -top-2 -right-2 text-yellow-300 animate-pulse">
              <Sparkles className="w-5 h-5" />
            </div>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
}

// Hook to manage contextual tips
export function useContextualTips() {
  const [currentTip, setCurrentTip] = useState<ContextualTipConfig | null>(null);
  const [tipQueue, setTipQueue] = useState<ContextualTipConfig[]>([]);

  const showTip = (tip: ContextualTipConfig) => {
    // Check if this tip should be shown
    if (tip.showOnce) {
      const shown = localStorage.getItem(`tip_shown_${tip.id}`);
      if (shown) {
        return;
      }
    }

    // If a tip is currently showing, add to queue
    if (currentTip) {
      setTipQueue(prev => [...prev, tip]);
    } else {
      setCurrentTip(tip);
    }
  };

  const dismissTip = () => {
    setCurrentTip(null);

    // Show next tip in queue after a delay
    if (tipQueue.length > 0) {
      setTimeout(() => {
        const [nextTip, ...remainingQueue] = tipQueue;
        setCurrentTip(nextTip);
        setTipQueue(remainingQueue);
      }, 500);
    }
  };

  return {
    currentTip,
    showTip,
    dismissTip,
  };
}

// Pre-defined common tips
export const COMMON_TIPS = {
  firstSave: {
    id: 'first_save',
    title: 'Nice Save! 💝',
    message: 'You can view all your saved properties in the Saved tab. You can also compare up to 3 properties side-by-side!',
    position: 'top' as const,
    autoHideDuration: 5000,
    showOnce: true,
  },
  firstSearch: {
    id: 'first_search',
    title: 'Smart Search Tips 🔍',
    message: 'Try searching with natural language like "3 bed under $2000" or "studio in williamsburg" for AI-powered results!',
    position: 'top' as const,
    autoHideDuration: 6000,
    showOnce: true,
  },
  useFilters: {
    id: 'use_filters',
    title: 'Pro Tip: Advanced Filters ⚙️',
    message: 'Tap the Filters button to narrow down by price, bedrooms, bathrooms, and specific neighborhoods!',
    position: 'top' as const,
    autoHideDuration: 5000,
    showOnce: true,
  },
  pulseFirstVisit: {
    id: 'pulse_first_visit',
    title: 'Welcome to The Pulse! 📱',
    message: 'See what\'s happening in NYC neighborhoods in real-time. Share your vibe, vote on debates, and connect with the community!',
    position: 'top' as const,
    autoHideDuration: 6000,
    showOnce: true,
  },
  matchmakerIntro: {
    id: 'matchmaker_intro',
    title: 'AI Matchmaker 🤖✨',
    message: 'Not sure what you want? Swipe through properties to help HOMEY learn your preferences and find your perfect match!',
    position: 'center' as const,
    autoHideDuration: 6000,
    showOnce: true,
  },
  compareFeature: {
    id: 'compare_feature',
    title: 'Compare Properties 📊',
    message: 'Select 2-3 saved properties and tap Compare to see them side-by-side with detailed analysis!',
    position: 'bottom' as const,
    autoHideDuration: 5000,
    showOnce: true,
  },
};
