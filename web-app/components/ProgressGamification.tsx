'use client';

import { motion } from 'framer-motion';

interface Badge {
  id: string;
  icon: string;
  label: string;
  description: string;
  unlocked: boolean;
  progress?: number;
  goal?: number;
}

interface ProgressGamificationProps {
  swipeCount: number;
  savedCount: number;
  tourCount: number;
  profileComplete: boolean;
}

export default function ProgressGamification({
  swipeCount,
  savedCount,
  tourCount,
  profileComplete,
}: ProgressGamificationProps) {
  const badges: Badge[] = [
    {
      id: 'complete_profile',
      icon: '📝',
      label: 'Profile Master',
      description: 'Complete your profile',
      unlocked: profileComplete,
    },
    {
      id: 'first_swipe',
      icon: '🎯',
      label: 'First Swipe',
      description: 'Swipe on your first property',
      unlocked: swipeCount >= 1,
    },
    {
      id: 'swipe_10',
      icon: '💫',
      label: 'Scout Trainee',
      description: 'Swipe on 10 properties',
      unlocked: swipeCount >= 10,
      progress: Math.min(swipeCount, 10),
      goal: 10,
    },
    {
      id: 'swipe_50',
      icon: '⭐',
      label: 'Scout Pro',
      description: 'Swipe on 50 properties',
      unlocked: swipeCount >= 50,
      progress: Math.min(swipeCount, 50),
      goal: 50,
    },
    {
      id: 'saved_10',
      icon: '💎',
      label: 'Collector',
      description: 'Save 10 homes',
      unlocked: savedCount >= 10,
      progress: Math.min(savedCount, 10),
      goal: 10,
    },
    {
      id: 'first_tour',
      icon: '🏠',
      label: 'Tour Taker',
      description: 'Schedule your first tour',
      unlocked: tourCount >= 1,
    },
  ];

  const unlockedBadges = badges.filter(b => b.unlocked);
  const nextBadge = badges.find(b => !b.unlocked);

  if (unlockedBadges.length === 0 && !nextBadge) {
    return null;
  }

  return (
    <motion.div
      className="px-5 mb-8"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: 0.5 }}
    >
      <div className="max-w-4xl mx-auto">
        {/* Unlocked Badges */}
        {unlockedBadges.length > 0 && (
          <div className="mb-6">
            <h3 className="text-sm font-semibold text-white/40 tracking-widest uppercase mb-4">
              Achievements
            </h3>
            <div className="flex flex-wrap gap-3">
              {unlockedBadges.map((badge, index) => (
                <motion.div
                  key={badge.id}
                  initial={{ opacity: 0, scale: 0 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{ delay: index * 0.1 }}
                  className="glass-strong rounded-xl px-4 py-3 border border-white/20"
                >
                  <div className="flex items-center gap-2">
                    <span className="text-2xl">{badge.icon}</span>
                    <div>
                      <div className="text-white font-semibold text-sm">{badge.label}</div>
                      <div className="text-white/60 text-xs">{badge.description}</div>
                    </div>
                  </div>
                </motion.div>
              ))}
            </div>
          </div>
        )}

        {/* Next Badge to Unlock */}
        {nextBadge && (
          <div className="glass-strong rounded-3xl p-6 border border-white/10">
            <div className="flex items-center gap-4 mb-4">
              <div className="w-16 h-16 rounded-xl bg-white/5 border-2 border-dashed border-white/20 flex items-center justify-center text-4xl grayscale opacity-50">
                {nextBadge.icon}
              </div>
              <div className="flex-1">
                <h4 className="text-white font-semibold mb-1">
                  Next: {nextBadge.label}
                </h4>
                <p className="text-white/60 text-sm">
                  {nextBadge.description}
                </p>
              </div>
            </div>

            {/* Progress Bar */}
            {nextBadge.progress !== undefined && nextBadge.goal !== undefined && (
              <div>
                <div className="flex items-center justify-between text-xs text-white/60 mb-2">
                  <span>Progress</span>
                  <span className="font-semibold">
                    {nextBadge.progress}/{nextBadge.goal}
                  </span>
                </div>
                <div className="h-2 bg-white/10 rounded-full overflow-hidden">
                  <motion.div
                    className="h-full bg-gradient-to-r from-primary via-purple-500 to-pink-500"
                    initial={{ width: 0 }}
                    animate={{ width: `${(nextBadge.progress / nextBadge.goal) * 100}%` }}
                    transition={{ duration: 1 }}
                  />
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </motion.div>
  );
}
