'use client';

import { motion } from 'framer-motion';
import { UserPreferences } from '@/lib/preferences';

// RENTER JOURNEY (6 stages)
const RENTER_STAGES = [
  {
    id: 'get_ready',
    icon: '📋',
    title: 'Get Ready',
    shortTitle: 'Ready',
    description: 'Documents, income check, and search preferences',
  },
  {
    id: 'explore',
    icon: '🔍',
    title: 'Explore Homes',
    shortTitle: 'Explore',
    description: 'Browse listings and build your shortlist',
  },
  {
    id: 'tour_apply',
    icon: '🏠',
    title: 'Tour & Apply',
    shortTitle: 'Tour',
    description: 'Schedule tours and prep your application',
  },
  {
    id: 'submitted',
    icon: '📤',
    title: 'Application Submitted',
    shortTitle: 'Submitted',
    description: 'Your package is in, verification underway',
  },
  {
    id: 'approved',
    icon: '✅',
    title: 'Approved',
    shortTitle: 'Approved',
    description: 'Lease offered, reviewing terms',
  },
  {
    id: 'sign_move',
    icon: '🔑',
    title: 'Sign & Move',
    shortTitle: 'Move In',
    description: 'Lease signing and move-in coordination',
  },
];

// BUYER JOURNEY (8 stages)
const BUYER_STAGES = [
  {
    id: 'get_ready',
    icon: '💰',
    title: 'Get Ready',
    shortTitle: 'Ready',
    description: 'Financial profile and lender pre-approval',
  },
  {
    id: 'explore',
    icon: '🔍',
    title: 'Explore Homes',
    shortTitle: 'Explore',
    description: 'Matched listings and neighborhood exploration',
  },
  {
    id: 'tour_evaluate',
    icon: '🏘️',
    title: 'Tour & Evaluate',
    shortTitle: 'Tour',
    description: 'Showings, comparisons, and building financials',
  },
  {
    id: 'make_offer',
    icon: '📝',
    title: 'Make an Offer',
    shortTitle: 'Offer',
    description: 'Draft offer and prepare supporting docs',
  },
  {
    id: 'accepted_offer',
    icon: '🤝',
    title: 'Accepted Offer',
    shortTitle: 'Accepted',
    description: 'Terms aligned, attorney review period',
  },
  {
    id: 'contract_signed',
    icon: '✍️',
    title: 'Contract Signed',
    shortTitle: 'Contract',
    description: 'Signed contract, deposit delivered',
  },
  {
    id: 'board_package',
    icon: '📋',
    title: 'Board Package',
    shortTitle: 'Board',
    description: 'Co-op/condo application and interview prep',
  },
  {
    id: 'closing',
    icon: '🎉',
    title: 'Closing & Move',
    shortTitle: 'Close',
    description: 'Final walkthrough and closing day',
  },
];

interface JourneyProgressProps {
  preferences: UserPreferences | null;
  savedListingsCount: number;
  hasSwipeData: boolean;
}

export default function JourneyProgress({
  preferences,
  savedListingsCount,
  hasSwipeData,
}: JourneyProgressProps) {
  const userType = preferences?.userType || 'browser';
  const stages = userType === 'buyer' ? BUYER_STAGES : RENTER_STAGES;

  // Calculate current stage based on user progress
  const getCurrentStage = (): number => {
    // Stage 0: Get Ready
    if (!preferences?.onboardingCompleted) return 0;

    // Stage 1: Explore Homes
    if (!hasSwipeData || savedListingsCount === 0) return 1;

    // Stage 2: Tour & Apply / Tour & Evaluate
    if (savedListingsCount < 3) return 2;

    // For now, we stay at stage 2 until we implement tour scheduling, applications, etc.
    // Future: Check tours_scheduled, applications_submitted, etc.
    return 2;
  };

  const currentStageIndex = getCurrentStage();
  const progressPercentage = (currentStageIndex / (stages.length - 1)) * 100;

  // Get contextual message based on current stage
  const getContextualMessage = (): string => {
    const stage = stages[currentStageIndex];

    if (currentStageIndex === 0) {
      return `Complete your profile to get personalized recommendations`;
    } else if (currentStageIndex === 1) {
      if (!hasSwipeData) {
        return `Start swiping on properties to train Scout's AI`;
      }
      return `Save your favorite homes to build a shortlist`;
    } else if (currentStageIndex === 2) {
      if (savedListingsCount < 3) {
        return `Save ${3 - savedListingsCount} more to build a strong shortlist`;
      }
      return `Ready to schedule tours? Visit your calendar`;
    }

    return stage.description;
  };

  // Get next action CTA
  const getNextAction = (): { label: string; href: string } | null => {
    if (currentStageIndex === 0) {
      return { label: 'Complete Profile', href: '/settings/preferences' };
    } else if (currentStageIndex === 1) {
      if (!hasSwipeData) {
        return { label: 'Start Swiping', href: '/matchmaker' };
      }
      return { label: 'Explore Homes', href: '/search' };
    } else if (currentStageIndex === 2) {
      return { label: 'Schedule Tours', href: '/calendar' };
    }
    return null;
  };

  const nextAction = getNextAction();

  return (
    <motion.div
      className="px-5 mb-12"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: 0.1 }}
    >
      <div className="max-w-4xl mx-auto glass-strong rounded-3xl p-6 md:p-8 border border-white/10">
        {/* Header */}
        <div className="mb-6 text-center">
          <h3 className="text-sm font-semibold text-white/40 tracking-widest uppercase mb-2">
            Your {userType === 'buyer' ? 'Buying' : userType === 'renter' ? 'Renting' : 'Home'} Journey
          </h3>
          <p className="text-white/70 text-sm">
            {getContextualMessage()}
          </p>
        </div>

        {/* Progress Bar */}
        <div className="relative mb-8">
          {/* Background Line */}
          <div className="absolute top-6 left-0 right-0 h-0.5 bg-white/10" />

          {/* Filled Progress Line */}
          <div
            className="absolute top-6 left-0 h-0.5 bg-gradient-to-r from-primary via-purple-500 to-pink-500 transition-all duration-1000"
            style={{
              width: `${Math.min(progressPercentage, 100)}%`,
            }}
          />

          {/* Stage Indicators */}
          <div
            className={`relative grid gap-2`}
            style={{
              gridTemplateColumns: `repeat(${stages.length}, 1fr)`,
            }}
          >
            {stages.map((stage, index) => {
              const isCompleted = index < currentStageIndex;
              const isCurrent = index === currentStageIndex;
              const isUpcoming = index > currentStageIndex;

              return (
                <div key={stage.id} className="flex flex-col items-center">
                  {/* Circle Indicator */}
                  <motion.div
                    className={`w-12 h-12 rounded-full flex items-center justify-center text-xl md:text-2xl transition-all ${
                      isCompleted
                        ? 'bg-gradient-to-br from-primary to-purple-600 shadow-lg shadow-primary/30'
                        : isCurrent
                        ? 'bg-gradient-to-br from-purple-500 to-pink-500 shadow-lg shadow-purple-500/40 scale-110'
                        : 'bg-white/10 border-2 border-white/20'
                    }`}
                    whileHover={{ scale: 1.1 }}
                  >
                    {isCompleted ? '✓' : stage.icon}
                  </motion.div>

                  {/* Stage Label */}
                  <p
                    className={`text-xs mt-2 text-center transition-all ${
                      isCurrent
                        ? 'text-white font-semibold'
                        : isCompleted
                        ? 'text-white/70'
                        : 'text-white/40'
                    }`}
                  >
                    {stage.shortTitle}
                  </p>

                  {/* Current Stage Description (Mobile Only) */}
                  {isCurrent && (
                    <motion.p
                      initial={{ opacity: 0, height: 0 }}
                      animate={{ opacity: 1, height: 'auto' }}
                      className="text-xs text-white/60 text-center mt-1 md:hidden"
                    >
                      {stage.description}
                    </motion.p>
                  )}
                </div>
              );
            })}
          </div>
        </div>

        {/* Current Stage Details (Desktop) */}
        <div className="hidden md:block mb-6 p-4 bg-white/5 rounded-xl border border-white/10">
          <div className="flex items-start gap-3">
            <span className="text-3xl">{stages[currentStageIndex].icon}</span>
            <div>
              <h4 className="text-white font-semibold mb-1">
                {stages[currentStageIndex].title}
              </h4>
              <p className="text-white/60 text-sm">
                {stages[currentStageIndex].description}
              </p>
            </div>
          </div>
        </div>

        {/* Stats & Next Action */}
        <div className="flex flex-col md:flex-row gap-4 items-center justify-between">
          {/* Progress Stats */}
          <div className="grid grid-cols-3 gap-4 text-center flex-1">
            <div>
              <div className="text-xl md:text-2xl font-bold text-primary mb-1">
                {currentStageIndex + 1}/{stages.length}
              </div>
              <div className="text-white/60 text-xs">Stages</div>
            </div>
            <div>
              <div className="text-xl md:text-2xl font-bold text-purple-400 mb-1">
                {savedListingsCount}
              </div>
              <div className="text-white/60 text-xs">Saved</div>
            </div>
            <div>
              <div className="text-xl md:text-2xl font-bold text-pink-400 mb-1">
                {Math.round(progressPercentage)}%
              </div>
              <div className="text-white/60 text-xs">Complete</div>
            </div>
          </div>

          {/* Next Action Button */}
          {nextAction && (
            <motion.a
              href={nextAction.href}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="px-6 py-3 bg-gradient-to-r from-primary to-purple-600 rounded-xl text-white font-semibold text-sm shadow-lg shadow-primary/30 hover:shadow-primary/50 transition-all"
            >
              {nextAction.label} →
            </motion.a>
          )}
        </div>
      </div>
    </motion.div>
  );
}
