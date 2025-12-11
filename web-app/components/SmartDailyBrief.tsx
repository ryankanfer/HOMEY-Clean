'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { TrendingUp, TrendingDown, Clock, Sparkles, Target, Zap, ArrowRight, CheckCircle2 } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { type JourneyTheme, getThemeById, getThemePreference } from '@/lib/journeyThemes';

interface SmartDailyBriefProps {
  userName: string;
  // Journey stage (0-5)
  currentStage: number;
  // Journey theme for styling
  journeyTheme?: JourneyTheme;
  // User data
  hasSwipeData: boolean;
  swipeCount?: number;
  savedCount: number;
  toursScheduled?: number;
  // Market data
  newListingsCount?: number;
  priceDropsCount?: number;
  matchingHomesCount?: number;
  // Agent data
  agentName?: string;
  hasUnreadMessages?: boolean;
  // Behavioral insights
  preferredNeighborhoods?: string[];
  averageBudget?: number;
  mostViewedPropertyType?: string;
}

interface Insight {
  icon: string;
  text: string;
  type: 'positive' | 'neutral' | 'action';
  color: string;
  href?: string; // Optional navigation link
}

interface NextStep {
  title: string;
  description: string;
  action: string;
  href: string;
  gradient: string;
}

interface Nudge {
  text: string;
  icon: string;
  progress?: number;
  total?: number;
}

export default function SmartDailyBrief({
  userName,
  currentStage,
  journeyTheme,
  hasSwipeData,
  swipeCount = 0,
  savedCount,
  toursScheduled = 0,
  newListingsCount = 0,
  priceDropsCount = 0,
  matchingHomesCount = 0,
  agentName,
  hasUnreadMessages = false,
  preferredNeighborhoods = [],
  averageBudget,
  mostViewedPropertyType,
}: SmartDailyBriefProps) {
  const router = useRouter();
  const [timeOfDay, setTimeOfDay] = useState<'morning' | 'afternoon' | 'evening' | 'night'>('morning');
  const [currentTheme, setCurrentTheme] = useState<JourneyTheme>(() =>
    journeyTheme || getThemeById(getThemePreference())
  );
  const [showTidbit, setShowTidbit] = useState(true);

  // Rotate between tidbit and action description every 5 seconds
  useEffect(() => {
    const interval = setInterval(() => {
      setShowTidbit(prev => !prev);
    }, 5000);

    return () => clearInterval(interval);
  }, []);

  // Listen for theme changes from localStorage
  useEffect(() => {
    if (!journeyTheme) {
      const handleStorageChange = () => {
        setCurrentTheme(getThemeById(getThemePreference()));
      };

      window.addEventListener('storage', handleStorageChange);

      // Also check periodically in case same-window changes
      const interval = setInterval(() => {
        const newTheme = getThemeById(getThemePreference());
        if (newTheme.id !== currentTheme.id) {
          setCurrentTheme(newTheme);
        }
      }, 500);

      return () => {
        window.removeEventListener('storage', handleStorageChange);
        clearInterval(interval);
      };
    }
  }, [journeyTheme, currentTheme.id]);

  // Use provided theme or current theme from state
  const themeColors = journeyTheme || currentTheme;

  // Extract hex color from gradient or solid color for ambient effects
  const getPrimaryColor = () => {
    if (themeColors.colors.currentGradient) {
      // Extract first color from gradient string
      const match = themeColors.colors.currentGradient.match(/#[0-9a-f]{6}/i);
      return match ? match[0] : themeColors.colors.current;
    }
    return themeColors.colors.current;
  };

  const getSecondaryColor = () => {
    if (themeColors.colors.currentGradient) {
      // Extract second color from gradient string
      const matches = themeColors.colors.currentGradient.match(/#[0-9a-f]{6}/gi);
      return matches && matches[1] ? matches[1] : themeColors.colors.completed;
    }
    return themeColors.colors.completed;
  };

  useEffect(() => {
    const hour = new Date().getHours();
    if (hour >= 5 && hour < 12) setTimeOfDay('morning');
    else if (hour >= 12 && hour < 17) setTimeOfDay('afternoon');
    else if (hour >= 17 && hour < 21) setTimeOfDay('evening');
    else setTimeOfDay('night');
  }, []);

  const getGreeting = () => {
    const firstName = userName.split(' ')[0] || 'there';

    const morningSubtexts = [
      "Drink your coffee and read below",
      "Here's what happened while you slept",
      "Fresh homes and updates await",
      "Your daily dose of home hunting",
    ];

    const afternoonSubtexts = [
      "Before your midday nap, take a look",
      "Lunchtime scroll? We got you",
      "Fresh updates for your afternoon",
      "Let's check in on your search",
    ];

    const eveningSubtexts = [
      "Wind down with some home browsing",
      "Evening recap time",
      "Here's what you need to know",
      "End your day with this",
    ];

    const nightSubtexts = [
      "Burning the midnight oil?",
      "Can't sleep? Let's browse homes",
      "Late night home hunting session",
      "Someone's up late",
    ];

    const getRandomSubtext = (arr: string[]) => arr[Math.floor(Math.random() * arr.length)];

    const greetings = {
      morning: {
        text: `Good morning, ${firstName}`,
        subtext: getRandomSubtext(morningSubtexts)
      },
      afternoon: {
        text: `Good afternoon, ${firstName}`,
        subtext: getRandomSubtext(afternoonSubtexts)
      },
      evening: {
        text: `Good evening, ${firstName}`,
        subtext: getRandomSubtext(eveningSubtexts)
      },
      night: {
        text: `Good night, ${firstName}`,
        subtext: getRandomSubtext(nightSubtexts)
      },
    };
    return greetings[timeOfDay];
  };

  // Generate smart insights based on journey stage and data
  const getInsights = (): Insight[] => {
    const insights: Insight[] = [];

    // Stage 0: Get Ready
    if (currentStage === 0) {
      insights.push({
        icon: '🎯',
        text: 'Complete your profile to unlock personalized recommendations',
        type: 'action',
        color: 'text-purple-300',
        href: '/settings/preferences',
      });
      insights.push({
        icon: '📊',
        text: `${matchingHomesCount} homes ready for you to explore`,
        type: 'neutral',
        color: 'text-white/80',
        href: '/search',
      });
    }

    // Stage 1: Explore (No swipes yet)
    else if (currentStage === 1 && !hasSwipeData) {
      insights.push({
        icon: '🏠',
        text: `${matchingHomesCount} homes match your criteria`,
        type: 'neutral',
        color: 'text-white/80',
        href: '/search',
      });
      if (preferredNeighborhoods.length > 0) {
        insights.push({
          icon: '📍',
          text: `Most listings in ${preferredNeighborhoods[0]}`,
          type: 'neutral',
          color: 'text-white/80',
          href: '/search',
        });
      }
      insights.push({
        icon: '✨',
        text: '10 swipes unlock AI recommendations',
        type: 'action',
        color: 'text-purple-300',
        href: '/matchmaker',
      });
    }

    // Stage 2: Explore (Has swipes, no saves)
    else if (currentStage === 1 && hasSwipeData && savedCount === 0) {
      if (mostViewedPropertyType) {
        insights.push({
          icon: '🎨',
          text: `Based on your swipes, you prefer ${mostViewedPropertyType}`,
          type: 'positive',
          color: 'text-emerald-300',
          href: '/search',
        });
      }
      if (newListingsCount > 0) {
        insights.push({
          icon: '🆕',
          text: `${newListingsCount} new matches found today`,
          type: 'positive',
          color: 'text-emerald-300',
          href: '/search',
        });
      }
      insights.push({
        icon: '❤️',
        text: 'Save homes you love for easy comparison',
        type: 'action',
        color: 'text-pink-300',
        href: '/search',
      });
    }

    // Stage 3: Tour (Has saves < 3)
    else if (currentStage === 2 && savedCount < 3) {
      insights.push({
        icon: '📋',
        text: `${savedCount} home${savedCount > 1 ? 's' : ''} in saved homes`,
        type: 'neutral',
        color: 'text-white/80',
        href: '/saved',
      });
      if (averageBudget) {
        insights.push({
          icon: '💰',
          text: `Similar homes averaging $${averageBudget.toLocaleString()}/mo`,
          type: 'neutral',
          color: 'text-white/80',
          href: '/search',
        });
      }
      insights.push({
        icon: '🎯',
        text: 'Save 1-2 more homes to compare',
        type: 'action',
        color: 'text-amber-300',
        href: '/search',
      });
    }

    // Stage 4: Tour (Ready to schedule)
    else if (currentStage === 2 && savedCount >= 3) {
      insights.push({
        icon: '✅',
        text: `${savedCount} homes ready for tours`,
        type: 'positive',
        color: 'text-emerald-300',
        href: '/saved',
      });
      if (priceDropsCount > 0) {
        insights.push({
          icon: '📉',
          text: `${priceDropsCount} of your saved homes reduced price`,
          type: 'positive',
          color: 'text-emerald-300',
          href: '/saved',
        });
      }
      insights.push({
        icon: '🗓️',
        text: 'Best touring times: 2-5pm on weekends',
        type: 'neutral',
        color: 'text-white/80',
        href: '/calendar',
      });
    }

    // Stage 5: Apply
    else if (currentStage === 3) {
      if (toursScheduled > 0) {
        insights.push({
          icon: '📅',
          text: `${toursScheduled} tour${toursScheduled > 1 ? 's' : ''} scheduled`,
          type: 'positive',
          color: 'text-emerald-300',
          href: '/calendar',
        });
      }
      insights.push({
        icon: '📄',
        text: 'Have your documents ready for quick applications',
        type: 'action',
        color: 'text-blue-300',
        href: '/vault',
      });
      if (agentName) {
        insights.push({
          icon: '🤝',
          text: `${agentName} is ready to help with applications`,
          type: 'neutral',
          color: 'text-white/80',
          href: '/settings',
        });
      }
    }

    // Agent message if unread
    if (hasUnreadMessages && agentName) {
      insights.unshift({
        icon: '💬',
        text: `New message from ${agentName}`,
        type: 'action',
        color: 'text-cyan-300',
        href: '/settings', // Opens agent modal
      });
    }

    return insights.slice(0, 3); // Max 3 insights
  };

  // Get next step based on journey stage
  const getNextStep = (): NextStep & { tidbit: string } => {
    if (currentStage === 0) {
      return {
        title: 'Complete Your Profile',
        description: 'Tell us about your dream home to unlock personalized recommendations',
        tidbit: 'Most renters spend 2-3 weeks exploring before finding their perfect match',
        action: 'Get Started',
        href: '/settings/preferences',
        gradient: 'from-purple-500 to-pink-500',
      };
    }

    if (currentStage === 1 && !hasSwipeData) {
      return {
        title: 'Train Scout AI',
        description: 'Swipe on 10 homes to unlock personalized recommendations',
        tidbit: 'The average user swipes on 15-20 homes before finding clear preferences',
        action: 'Start Swiping',
        href: '/matchmaker',
        gradient: 'from-blue-500 to-cyan-500',
      };
    }

    if (currentStage === 1 && hasSwipeData && savedCount === 0) {
      return {
        title: 'Save Your First Home',
        description: 'Found something you like? Add it to your saved homes',
        tidbit: 'Users who save homes are 3x more likely to secure their top choice',
        action: 'Browse Homes',
        href: '/search',
        gradient: 'from-pink-500 to-rose-500',
      };
    }

    if (currentStage === 2 && savedCount < 3) {
      return {
        title: 'Save More Homes',
        description: `Save ${3 - savedCount} more home${3 - savedCount > 1 ? 's' : ''} to start comparing options`,
        tidbit: `Most buyers compare 3-5 homes before touring. You're ${3 - savedCount} away from a solid comparison set`,
        action: 'Find More',
        href: '/search',
        gradient: 'from-amber-500 to-orange-500',
      };
    }

    if (currentStage === 2 && savedCount >= 3 && toursScheduled === 0) {
      return {
        title: 'Schedule Your Tours',
        description: 'You have enough saved homes! Time to see them in person',
        tidbit: '85% of users who tour 3+ homes find their ideal place within 2 weeks',
        action: 'View Calendar',
        href: '/calendar',
        gradient: 'from-green-500 to-emerald-500',
      };
    }

    if (currentStage === 3) {
      return {
        title: 'Prepare to Apply',
        description: 'Gather your documents and get ready to submit applications',
        tidbit: 'Most applications are reviewed within 24-48 hours in competitive markets',
        action: 'Open Vault',
        href: '/vault',
        gradient: 'from-indigo-500 to-purple-500',
      };
    }

    // Default
    return {
      title: 'Keep Exploring',
      description: 'Discover more homes that match your preferences',
      tidbit: 'Patience pays off - the right home is out there waiting for you',
      action: 'Browse',
      href: '/search',
      gradient: 'from-purple-500 to-pink-500',
    };
  };

  // Get proactive nudge
  const getNudge = (): Nudge | null => {
    // Swipe progress nudge
    if (!hasSwipeData && swipeCount < 10) {
      return {
        text: `${10 - swipeCount} swipes away from AI recommendations`,
        icon: '🎯',
        progress: swipeCount,
        total: 10,
      };
    }

    // Saved homes nudge
    if (hasSwipeData && savedCount === 0) {
      return {
        text: "You've trained the AI, now find homes you love",
        icon: '❤️',
      };
    }

    // Comparison nudge
    if (savedCount >= 2 && savedCount < 3) {
      return {
        text: 'Most users compare 3-5 homes before touring',
        icon: '📊',
      };
    }

    // Tour scheduling nudge
    if (savedCount >= 5 && toursScheduled === 0) {
      return {
        text: 'You have lots of saved homes - ready to schedule tours?',
        icon: '🗓️',
      };
    }

    return null;
  };

  const greeting = getGreeting();
  const insights = getInsights();
  const nextStep = getNextStep();
  const nudge = getNudge();

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: 0.2 }}
      className="px-5 mb-6 space-y-4"
    >
      {/* Smart Insights Card */}
      {insights.length > 0 && (
        <div className="relative overflow-hidden rounded-[24px] bg-gradient-to-br from-white/[0.04] to-white/[0.02] border border-white/[0.08] backdrop-blur-xl">
          {/* Ambient glow - Theme colors */}
          <div
            className="absolute top-0 right-0 w-40 h-40 rounded-full blur-3xl"
            style={{ backgroundColor: `${getPrimaryColor()}1a` }}
          />
          <div
            className="absolute bottom-0 left-0 w-40 h-40 rounded-full blur-3xl"
            style={{ backgroundColor: `${getSecondaryColor()}1a` }}
          />

          <div className="relative p-5">
            {/* Subheader Only */}
            <div className="mb-4">
              <p className="text-[13px] text-white/70 font-medium tracking-tight font-body">
                {greeting.subtext}
              </p>
            </div>

            {/* Smart Insights - Floating */}
            <div className="space-y-3">
              {insights.map((insight, index) => (
                <motion.button
                  key={index}
                  onClick={() => insight.href && router.push(insight.href)}
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.3 + index * 0.1 }}
                  whileTap={{ scale: 0.98 }}
                  className="w-full flex items-start gap-3 py-2 px-0 text-left group transition-opacity hover:opacity-80"
                >
                  <span className="text-xl leading-none flex-shrink-0">{insight.icon}</span>
                  <p className={`text-[14px] leading-relaxed font-medium tracking-tight font-body flex-1 ${insight.color}`}>
                    {insight.text}
                  </p>
                  {insight.href && (
                    <ArrowRight className="w-4 h-4 text-white/30 group-hover:text-white/50 transition-colors flex-shrink-0 mt-0.5" />
                  )}
                </motion.button>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Next Step CTA - Separate Card */}
      <motion.button
        onClick={() => router.push(nextStep.href)}
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ delay: 0.6 }}
        whileTap={{ scale: 0.97 }}
        className="w-full group relative"
      >
        <div
          className="relative rounded-[18px] overflow-hidden p-[1px]"
          style={{
            background: themeColors.colors.currentGradient || themeColors.colors.current
          }}
        >
          <div className="relative rounded-[17px] bg-slate-900/90 backdrop-blur-sm p-4 group-active:bg-slate-900/70 transition-colors">
            <div className="flex items-center justify-between">
              <div className="text-left flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <Target className="w-4 h-4 text-white/60" />
                  <span className="text-[10px] font-bold text-white/40 uppercase tracking-wider">Your Next Step</span>
                </div>
                <h3 className="text-base font-bold text-white mb-1 tracking-tight font-display">
                  {nextStep.title}
                </h3>
                <AnimatePresence mode="wait">
                  <motion.p
                    key={showTidbit ? 'tidbit' : 'action'}
                    initial={{ opacity: 0, y: 5 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -5 }}
                    transition={{ duration: 0.3 }}
                    className="text-[12px] text-white/60 leading-relaxed tracking-tight font-body"
                  >
                    {showTidbit ? nextStep.tidbit : nextStep.description}
                  </motion.p>
                </AnimatePresence>
              </div>
              <div className="flex items-center gap-2 ml-4">
                <span className="text-[13px] font-bold text-white tracking-tight font-display">
                  {nextStep.action}
                </span>
                <ArrowRight className="w-4 h-4 text-white group-active:translate-x-1 transition-transform" />
              </div>
            </div>
          </div>
        </div>
      </motion.button>
    </motion.div>
  );
}
