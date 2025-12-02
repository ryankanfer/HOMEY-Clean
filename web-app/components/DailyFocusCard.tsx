'use client';

import { motion } from 'framer-motion';
import { UserPreferences } from '@/lib/preferences';

interface DailyFocusCardProps {
  userName: string;
  userPreferences: UserPreferences | null;
  savedListingsCount: number;
  hasSwipeData: boolean;
  swipeStats?: {
    total: number;
    today: number;
  };
}

export default function DailyFocusCard({
  userName,
  userPreferences,
  savedListingsCount,
  hasSwipeData,
  swipeStats,
}: DailyFocusCardProps) {
  const getTimeGreeting = () => {
    const hour = new Date().getHours();
    if (hour >= 5 && hour < 12) return '🌅 Good morning';
    if (hour >= 12 && hour < 17) return '☀️ Good afternoon';
    if (hour >= 17 && hour < 21) return '🌆 Good evening';
    return '🌙 Good night';
  };

  const getDailyMission = () => {
    const userType = userPreferences?.userType;
    const onboardingComplete = userPreferences?.onboardingCompleted;

    // Mission 0: Complete onboarding
    if (!onboardingComplete) {
      return {
        title: 'Complete Your Profile',
        description: 'Help us understand your home preferences to unlock personalized recommendations',
        progress: 0,
        goal: 1,
        cta: 'Complete Profile',
        href: '/settings/preferences',
        emoji: '📋',
      };
    }

    // Mission 1: Start swiping
    if (!hasSwipeData) {
      return {
        title: 'Train Scout\'s AI',
        description: 'Swipe on 10 properties to unlock personalized recommendations',
        progress: 0,
        goal: 10,
        cta: 'Start Swiping',
        href: '/matchmaker',
        emoji: '🎯',
      };
    }

    // Mission 2: Build shortlist
    if (savedListingsCount < 3) {
      return {
        title: 'Build Your Shortlist',
        description: `Save ${3 - savedListingsCount} more homes to start comparing options`,
        progress: savedListingsCount,
        goal: 3,
        cta: 'Find Homes',
        href: '/search',
        emoji: '❤️',
      };
    }

    // Mission 3: Schedule tours
    if (savedListingsCount >= 3) {
      return {
        title: 'Schedule Your Tours',
        description: 'You have a strong shortlist! Time to see these homes in person',
        progress: savedListingsCount,
        goal: savedListingsCount,
        cta: 'View Calendar',
        href: '/calendar',
        emoji: '📅',
      };
    }

    // Default mission
    return {
      title: 'Keep Exploring',
      description: 'Discover more homes that match your preferences',
      progress: savedListingsCount,
      goal: savedListingsCount + 5,
      cta: 'Browse Homes',
      href: '/search',
      emoji: '🏠',
    };
  };

  const mission = getDailyMission();
  const progressPercentage = (mission.progress / mission.goal) * 100;

  return (
    <motion.div
      className="px-5 mb-8"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6 }}
    >
      <div className="max-w-4xl mx-auto">
        <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-primary/20 via-purple-600/20 to-pink-500/20 border border-white/10 p-6 md:p-8">
          {/* Animated background blur effects */}
          <div className="absolute top-0 right-0 w-48 h-48 bg-primary/30 rounded-full blur-3xl opacity-50 animate-pulse" />
          <div className="absolute bottom-0 left-0 w-48 h-48 bg-purple-500/30 rounded-full blur-3xl opacity-50 animate-pulse" style={{ animationDelay: '1s' }} />

          <div className="relative z-10">
            {/* Greeting */}
            <div className="mb-4">
              <h2 className="text-lg md:text-xl text-white/80 font-medium">
                {getTimeGreeting()}{userName ? `, ${userName}` : ''}
              </h2>
            </div>

            {/* Mission */}
            <div className="mb-6">
              <div className="flex items-start gap-3 mb-3">
                <span className="text-4xl">{mission.emoji}</span>
                <div className="flex-1">
                  <h3 className="text-2xl md:text-3xl font-bold text-white mb-2">
                    {mission.title}
                  </h3>
                  <p className="text-white/70 text-sm md:text-base">
                    {mission.description}
                  </p>
                </div>
              </div>

              {/* Progress Bar */}
              {mission.goal > 0 && (
                <div className="mb-4">
                  <div className="flex items-center justify-between text-xs text-white/60 mb-2">
                    <span>Progress</span>
                    <span className="font-semibold">
                      {mission.progress}/{mission.goal}
                    </span>
                  </div>
                  <div className="h-2 bg-white/10 rounded-full overflow-hidden">
                    <motion.div
                      className="h-full bg-gradient-to-r from-primary via-purple-500 to-pink-500"
                      initial={{ width: 0 }}
                      animate={{ width: `${Math.min(progressPercentage, 100)}%` }}
                      transition={{ duration: 1, ease: 'easeOut' }}
                    />
                  </div>
                </div>
              )}
            </div>

            {/* CTA Button */}
            <motion.a
              href={mission.href}
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="inline-flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-primary to-purple-600 rounded-xl text-white font-semibold shadow-lg shadow-primary/30 hover:shadow-primary/50 transition-all"
            >
              {mission.cta}
              <span>→</span>
            </motion.a>

            {/* Streak indicator (if applicable) */}
            {swipeStats && swipeStats.today > 0 && (
              <div className="mt-4 pt-4 border-t border-white/10">
                <div className="flex items-center gap-2 text-sm">
                  <span className="text-orange-400">🔥</span>
                  <span className="text-white/70">
                    {swipeStats.today} swipes today
                  </span>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </motion.div>
  );
}
