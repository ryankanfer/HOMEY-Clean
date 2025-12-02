'use client';

import { motion } from 'framer-motion';
import { useRouter } from 'next/navigation';
import { ArrowRight } from 'lucide-react';

interface SingleActionFocusProps {
  hasSwipeData?: boolean;
  savedCount?: number;
}

export default function SingleActionFocus({
  hasSwipeData = false,
  savedCount = 0
}: SingleActionFocusProps) {
  const router = useRouter();

  // Determine the most pressing action based on user state
  const getMostPressingAction = () => {
    if (!hasSwipeData) {
      return {
        icon: '🎯',
        title: 'Train The Algorithm',
        description: 'Swipe on 10 properties to unlock personalized matches',
        action: 'Start Swiping',
        href: '/matchmaker',
        priority: 'urgent',
        gradient: 'from-red-500 to-orange-500'
      };
    } else if (savedCount === 0) {
      return {
        icon: '❤️',
        title: 'Save Your First Home',
        description: 'Build your shortlist by saving properties you love',
        action: 'Browse Properties',
        href: '/search',
        priority: 'high',
        gradient: 'from-pink-500 to-rose-500'
      };
    } else if (savedCount < 3) {
      return {
        icon: '🏠',
        title: 'Build Your Shortlist',
        description: `You have ${savedCount} saved. Add ${3 - savedCount} more to start scheduling tours`,
        action: 'Keep Exploring',
        href: '/search',
        priority: 'medium',
        gradient: 'from-purple-500 to-pink-500'
      };
    } else {
      return {
        icon: '📅',
        title: 'Schedule Your Tours',
        description: `You have ${savedCount} saved homes ready to view`,
        action: 'View Calendar',
        href: '/calendar',
        priority: 'high',
        gradient: 'from-green-500 to-emerald-500'
      };
    }
  };

  const action = getMostPressingAction();

  return (
    <motion.div
      className="px-5 mb-8"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: 0.35 }}
    >
      <div className="mb-3">
        <h2 className="text-sm font-bold text-white/40 uppercase tracking-wider">Next Step</h2>
      </div>

      <motion.div
        onClick={() => router.push(action.href)}
        whileHover={{ scale: 1.02 }}
        whileTap={{ scale: 0.98 }}
        className="relative rounded-3xl overflow-hidden border border-white/20 bg-gradient-to-br from-slate-800/50 to-slate-900/50 backdrop-blur-md cursor-pointer group"
      >
        {/* Gradient Glow */}
        <div className={`absolute inset-0 bg-gradient-to-r ${action.gradient} opacity-10 group-hover:opacity-20 transition-opacity`} />

        {/* Content */}
        <div className="relative p-5">
          {/* Top Section - Icon and Text */}
          <div className="flex items-start gap-4 mb-4">
            {/* Icon */}
            <div className={`w-14 h-14 sm:w-16 sm:h-16 rounded-2xl bg-gradient-to-br ${action.gradient} flex items-center justify-center text-2xl sm:text-3xl shrink-0 shadow-lg group-hover:scale-110 transition-transform`}>
              {action.icon}
            </div>

            {/* Text */}
            <div className="flex-1 min-w-0">
              <h3 className="text-lg sm:text-xl font-bold text-white mb-1 group-hover:text-purple-200 transition-colors">
                {action.title}
              </h3>
              <p className="text-white/60 text-sm leading-relaxed">
                {action.description}
              </p>
            </div>
          </div>

          {/* Action Button - Full Width on Mobile */}
          <div className="w-full">
            <div className={`w-full px-4 py-3.5 rounded-xl bg-gradient-to-r ${action.gradient} text-white font-semibold flex items-center justify-center gap-2 shadow-lg group-hover:shadow-xl transition-all text-sm sm:text-base`}>
              <span>{action.action}</span>
              <ArrowRight className="w-4 h-4 sm:w-5 sm:h-5 group-hover:translate-x-1 transition-transform flex-shrink-0" />
            </div>
          </div>
        </div>

        {/* Priority Indicator */}
        {action.priority === 'urgent' && (
          <div className="absolute top-3 left-3">
            <div className="px-2 py-1 rounded-full bg-red-500/20 border border-red-500/50 text-red-300 text-xs font-bold flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full bg-red-500 animate-pulse" />
              URGENT
            </div>
          </div>
        )}
      </motion.div>
    </motion.div>
  );
}
