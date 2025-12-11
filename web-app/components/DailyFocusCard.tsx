'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { TrendingUp, Sparkles, MapPin } from 'lucide-react';
import { UserPreferences } from '@/lib/preferences';
import pulseDb, { type NeighborhoodStats, type VibeLog } from '@/lib/pulseDb';

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
  const [pulseData, setPulseData] = useState<{
    trendingNeighborhood: NeighborhoodStats | null;
    recentVibe: VibeLog | null;
  }>({ trendingNeighborhood: null, recentVibe: null });

  useEffect(() => {
    const loadPulseData = async () => {
      try {
        // Get user's preferred location/neighborhood
        const preferredCity = userPreferences?.location;

        // Fetch recent vibes from preferred area
        const vibes = await pulseDb.getVibeLogs(10);
        const relevantVibe = vibes.find(v =>
          !preferredCity || v.neighborhood.toLowerCase().includes(preferredCity.toLowerCase())
        ) || vibes[0];

        // Get neighborhood stats to find trending areas
        const allNeighborhoods = await pulseDb.getNeighborhoodStats();
        const trendingAreas = allNeighborhoods
          .filter(n => n.trending === 'Up' && n.energy !== 'low')
          .sort((a, b) => b.vibeScore - a.vibeScore);

        const topTrending = trendingAreas[0] || allNeighborhoods[0];

        setPulseData({
          trendingNeighborhood: topTrending,
          recentVibe: relevantVibe,
        });
      } catch (error) {
        console.error('Error loading Pulse data:', error);
      }
    };

    loadPulseData();
  }, [userPreferences?.location]);

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
      className="px-5 mb-5"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6 }}
    >
      <div className="max-w-4xl mx-auto">
        <div className="relative overflow-hidden rounded-[20px] bg-gradient-to-br from-primary/10 via-purple-600/10 to-pink-500/10 border border-white/[0.04] p-4 md:p-5">
          {/* Animated background blur effects - very subtle */}
          <div className="absolute top-0 right-0 w-32 h-32 bg-primary/15 rounded-full blur-3xl opacity-30 animate-pulse" />
          <div className="absolute bottom-0 left-0 w-32 h-32 bg-purple-500/15 rounded-full blur-3xl opacity-30 animate-pulse" style={{ animationDelay: '1s' }} />

          <div className="relative z-10">
            {/* Mission - Compact */}
            <div className="mb-3">
              <div className="flex items-start gap-2.5 mb-2">
                <span className="text-2xl leading-none">{mission.emoji}</span>
                <div className="flex-1">
                  <h3 className="text-lg md:text-xl font-bold text-white mb-1 tracking-tight leading-tight">
                    {mission.title}
                  </h3>
                  <p className="text-white/55 text-[12px] md:text-[13px] leading-relaxed">
                    {mission.description}
                  </p>
                </div>
              </div>

              {/* Progress Bar - Compact */}
              {mission.goal > 0 && (
                <div className="mb-3">
                  <div className="flex items-center justify-between text-[9px] text-white/45 mb-1.5">
                    <span className="uppercase tracking-wider font-medium">Progress</span>
                    <span className="font-semibold tabular-nums">
                      {mission.progress}/{mission.goal}
                    </span>
                  </div>
                  <div className="h-1 bg-white/[0.06] rounded-full overflow-hidden">
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

            {/* CTA Button - Compact */}
            <motion.a
              href={mission.href}
              whileHover={{ scale: 1.015 }}
              whileTap={{ scale: 0.985 }}
              className="inline-flex items-center justify-center gap-1.5 px-5 py-2.5 bg-gradient-to-r from-primary to-purple-600 rounded-[12px] text-white text-[14px] font-semibold shadow-sm shadow-primary/15 hover:shadow-md hover:shadow-primary/25 transition-all"
            >
              {mission.cta}
              <span className="text-base leading-none">→</span>
            </motion.a>

            {/* Streak indicator (if applicable) - Compact */}
            {swipeStats && swipeStats.today > 0 && (
              <div className="mt-3 pt-3 border-t border-white/[0.04]">
                <div className="flex items-center gap-1.5 text-[12px]">
                  <span className="text-orange-400 text-sm leading-none">🔥</span>
                  <span className="text-white/55 font-medium">
                    {swipeStats.today} swipes today
                  </span>
                </div>
              </div>
            )}

            {/* Pulse Insights - Compact */}
            {(pulseData.trendingNeighborhood || pulseData.recentVibe) && (
              <div className="mt-3 pt-3 border-t border-white/[0.04] space-y-2">
                <div className="flex items-center gap-1.5 mb-1.5">
                  <Sparkles className="w-3 h-3 text-yellow-400/80" />
                  <span className="text-[8px] font-semibold text-white/45 uppercase tracking-[0.12em]">
                    Live from the Pulse
                  </span>
                </div>

                {/* Trending Neighborhood - iPhone Style */}
                {pulseData.trendingNeighborhood && (
                  <motion.div
                    initial={{ opacity: 0, x: -10 }}
                    animate={{ opacity: 1, x: 0 }}
                    className="bg-white/[0.03] rounded-[16px] p-3 border border-white/[0.06]"
                  >
                    <div className="flex items-start justify-between mb-1">
                      <div className="flex items-center gap-2">
                        <MapPin className="w-3.5 h-3.5 text-purple-400/90" />
                        <span className="text-[13px] font-semibold text-white tracking-tight">
                          {pulseData.trendingNeighborhood.neighborhood}
                        </span>
                      </div>
                      {pulseData.trendingNeighborhood.trending === 'Up' && (
                        <div className="flex items-center gap-1">
                          <TrendingUp className="w-3 h-3 text-emerald-400" />
                          <span className="text-[10px] text-emerald-400 font-medium">Trending</span>
                        </div>
                      )}
                    </div>
                    <div className="flex items-center gap-2 mb-1.5">
                      <span className="text-lg leading-none">{pulseData.trendingNeighborhood.moodEmoji}</span>
                      <span className="text-[11px] text-white/50">
                        {pulseData.trendingNeighborhood.currentMood} •{' '}
                        {pulseData.trendingNeighborhood.energy} energy
                      </span>
                    </div>
                    <p className="text-[11px] text-white/60 line-clamp-2 leading-relaxed">
                      {pulseData.trendingNeighborhood.whatsHappening}
                    </p>
                  </motion.div>
                )}

                {/* Recent Community Vibe - iPhone Style */}
                {pulseData.recentVibe && (
                  <motion.div
                    initial={{ opacity: 0, x: -10 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.1 }}
                    className="bg-white/[0.03] rounded-[16px] p-3 border border-white/[0.06]"
                  >
                    <div className="flex items-start gap-2.5 mb-1">
                      <div className="w-6 h-6 rounded-full bg-gradient-to-br from-primary/30 to-purple-600/30 flex items-center justify-center text-white font-bold text-[11px] flex-shrink-0">
                        {pulseData.recentVibe.user?.full_name?.charAt(0) || 'U'}
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-1">
                          <span className="text-[11px] font-semibold text-white/90 tracking-tight">
                            {pulseData.recentVibe.user?.full_name || 'Someone'}
                          </span>
                          <span className="text-[10px] text-white/40">in {pulseData.recentVibe.neighborhood}</span>
                        </div>
                        <p className="text-[11px] text-white/60 line-clamp-2 leading-relaxed">
                          "{pulseData.recentVibe.text}"
                        </p>
                        {pulseData.recentVibe.tags && pulseData.recentVibe.tags.length > 0 && (
                          <div className="flex gap-1 mt-2 flex-wrap">
                            {pulseData.recentVibe.tags.slice(0, 3).map((tag, i) => (
                              <span
                                key={i}
                                className="px-2 py-0.5 bg-white/[0.08] rounded-full text-[9px] text-white/50 font-medium"
                              >
                                {tag}
                              </span>
                            ))}
                          </div>
                        )}
                      </div>
                    </div>
                  </motion.div>
                )}
              </div>
            )}
          </div>
        </div>
      </div>
    </motion.div>
  );
}
