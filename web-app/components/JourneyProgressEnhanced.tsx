'use client';

import { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { UserPreferences } from '@/lib/preferences';
import { X, Plus, Share2, CheckCircle2, Clock, TrendingUp } from 'lucide-react';
import confetti from 'canvas-confetti';

// Team member who helps with each stage
interface TeamMember {
  name: string;
  role: string;
  avatar: string | null; // Initials or emoji
  color: string;
  recruited?: boolean; // Has user recruited this person yet?
}

interface Station {
  id: string;
  title: string;
  subtitle: string;
  icon: string;
  category: 'financial' | 'exploration' | 'legal' | 'administrative';
  estimatedDays: string;
  requirements: string[];
  insight: string;
  actionLink?: string;
  teamMember: TeamMember;
}

// RENTER JOURNEY (6 stations)
const RENTER_STATIONS: Station[] = [
  {
    id: 'get_ready',
    title: 'Get Ready',
    subtitle: 'Documents & Budget',
    icon: '📋',
    category: 'administrative',
    estimatedDays: '1-2',
    requirements: ['Photo ID', 'Proof of income', 'Bank statements', 'References'],
    insight: '85% of renters complete this in under 2 days',
    actionLink: '/teach',
    teamMember: {
      name: 'You',
      role: 'Lead',
      avatar: '👤',
      color: 'from-blue-500 to-cyan-500',
      recruited: true,
    },
  },
  {
    id: 'explore',
    title: 'Explore',
    subtitle: 'Find Your Home',
    icon: '🔍',
    category: 'exploration',
    estimatedDays: '7-14',
    requirements: ['Budget defined', 'Neighborhood preferences', 'Must-have features'],
    insight: 'Most users swipe through 50+ properties before finding the one',
    actionLink: '/matchmaker',
    teamMember: {
      name: 'Sarah',
      role: 'Your Agent',
      avatar: 'SC',
      color: 'from-purple-500 to-pink-500',
      recruited: true,
    },
  },
  {
    id: 'tour_apply',
    title: 'Tour',
    subtitle: 'See in Person',
    icon: '🏠',
    category: 'exploration',
    estimatedDays: '3-7',
    requirements: ['Scheduled viewings', 'Questions prepared', 'Transportation planned'],
    insight: 'Average renter tours 5-8 properties before applying',
    actionLink: '/calendar',
    teamMember: {
      name: 'Sarah',
      role: 'Your Agent',
      avatar: 'SC',
      color: 'from-purple-500 to-pink-500',
      recruited: true,
    },
  },
  {
    id: 'submitted',
    title: 'Apply',
    subtitle: 'Submit Package',
    icon: '📤',
    category: 'administrative',
    estimatedDays: '1-2',
    requirements: ['Application fee', 'Complete documents', 'Security deposit ready'],
    insight: 'Strong applications typically get responses within 48 hours',
    teamMember: {
      name: 'You',
      role: 'Lead',
      avatar: '👤',
      color: 'from-blue-500 to-cyan-500',
      recruited: true,
    },
  },
  {
    id: 'approved',
    title: 'Approved',
    subtitle: 'Review Lease',
    icon: '✅',
    category: 'legal',
    estimatedDays: '2-3',
    requirements: ['Review lease terms', 'Legal consultation', 'Clarify questions'],
    insight: 'Having an attorney review can save thousands in the long run',
    teamMember: {
      name: 'Attorney',
      role: 'Legal Review',
      avatar: null, // Empty slot
      color: 'from-blue-500 to-indigo-500',
      recruited: false,
    },
  },
  {
    id: 'sign_move',
    title: 'Move In',
    subtitle: 'Get Your Keys',
    icon: '🔑',
    category: 'administrative',
    estimatedDays: '1',
    requirements: ['First month rent', 'Security deposit', 'Move-in inspection'],
    insight: 'Congratulations! The average renter stays 2-3 years',
    teamMember: {
      name: 'You',
      role: 'Lead',
      avatar: '👤',
      color: 'from-blue-500 to-cyan-500',
      recruited: true,
    },
  },
];

// BUYER JOURNEY (8 stations)
const BUYER_STATIONS: Station[] = [
  {
    id: 'get_ready',
    title: 'Pre-Approval',
    subtitle: 'Get Financing',
    icon: '💰',
    category: 'financial',
    estimatedDays: '3-7',
    requirements: ['Credit report', 'Income verification', 'Asset statements', 'Employment history'],
    insight: 'Pre-approval strengthens your offer by 40% in competitive markets',
    actionLink: '/teach',
    teamMember: {
      name: 'Michael',
      role: 'Your Lender',
      avatar: 'MJ',
      color: 'from-green-500 to-emerald-500',
      recruited: true,
    },
  },
  {
    id: 'explore',
    title: 'Explore',
    subtitle: 'Find Properties',
    icon: '🔍',
    category: 'exploration',
    estimatedDays: '14-60',
    requirements: ['Budget set', 'Neighborhood research', 'Property criteria'],
    insight: 'Buyers view an average of 10-12 properties before making an offer',
    actionLink: '/matchmaker',
    teamMember: {
      name: 'Sarah',
      role: 'Your Agent',
      avatar: 'SC',
      color: 'from-purple-500 to-pink-500',
      recruited: true,
    },
  },
  {
    id: 'tour_evaluate',
    title: 'Tour',
    subtitle: 'Visit Homes',
    icon: '🏘️',
    category: 'exploration',
    estimatedDays: '7-21',
    requirements: ['Tour schedule', 'Inspection checklist', 'Neighborhood visits'],
    insight: 'Visit neighborhoods at different times to get the full picture',
    actionLink: '/calendar',
    teamMember: {
      name: 'Sarah',
      role: 'Your Agent',
      avatar: 'SC',
      color: 'from-purple-500 to-pink-500',
      recruited: true,
    },
  },
  {
    id: 'make_offer',
    title: 'Make Offer',
    subtitle: 'Draft & Submit',
    icon: '📝',
    category: 'administrative',
    estimatedDays: '1-3',
    requirements: ['Offer price decided', 'Contingencies defined', 'Proof of funds'],
    insight: 'In NYC, 60% of first offers are countered',
    teamMember: {
      name: 'Sarah',
      role: 'Your Agent',
      avatar: 'SC',
      color: 'from-purple-500 to-pink-500',
      recruited: true,
    },
  },
  {
    id: 'accepted_offer',
    title: 'Accepted',
    subtitle: 'Attorney Review',
    icon: '🤝',
    category: 'legal',
    estimatedDays: '3-5',
    requirements: ['Attorney retained', 'Contract review', 'Deposit ready'],
    insight: 'NYC requires attorneys - most buyers spend $2-5k on legal fees',
    teamMember: {
      name: 'Lawyer',
      role: 'Real Estate Attorney',
      avatar: null, // Empty slot - needs to recruit
      color: 'from-blue-500 to-indigo-500',
      recruited: false,
    },
  },
  {
    id: 'contract_signed',
    title: 'Contract',
    subtitle: 'Sign & Deposit',
    icon: '✍️',
    category: 'legal',
    estimatedDays: '1-2',
    requirements: ['10% deposit', 'Signed contract', 'Mortgage commitment'],
    insight: 'Your deposit goes into escrow and is protected',
    teamMember: {
      name: 'Lawyer',
      role: 'Real Estate Attorney',
      avatar: null,
      color: 'from-blue-500 to-indigo-500',
      recruited: false,
    },
  },
  {
    id: 'board_package',
    title: 'Board Approval',
    subtitle: 'Application & Interview',
    icon: '📋',
    category: 'administrative',
    estimatedDays: '30-60',
    requirements: ['Board package', 'Reference letters', 'Financial documents', 'Interview prep'],
    insight: 'Co-op board approval takes 4-8 weeks on average',
    teamMember: {
      name: 'Sarah',
      role: 'Your Agent',
      avatar: 'SC',
      color: 'from-purple-500 to-pink-500',
      recruited: true,
    },
  },
  {
    id: 'closing',
    title: 'Closing',
    subtitle: 'Final Day!',
    icon: '🎉',
    category: 'administrative',
    estimatedDays: '1',
    requirements: ['Closing costs', 'Final walkthrough', 'Moving plans'],
    insight: 'Welcome home! NYC homeowners stay an average of 7-10 years',
    teamMember: {
      name: 'You',
      role: 'New Homeowner',
      avatar: '👤',
      color: 'from-blue-500 to-cyan-500',
      recruited: true,
    },
  },
];

// Category colors for visual organization
const CATEGORY_COLORS = {
  financial: 'from-green-500 to-emerald-500',
  exploration: 'from-purple-500 to-pink-500',
  legal: 'from-blue-500 to-indigo-500',
  administrative: 'from-orange-500 to-amber-500',
};

interface JourneyProgressEnhancedProps {
  preferences: UserPreferences | null;
  savedListingsCount: number;
  hasSwipeData: boolean;
}

export default function JourneyProgressEnhanced({
  preferences,
  savedListingsCount,
  hasSwipeData,
}: JourneyProgressEnhancedProps) {
  const [selectedStation, setSelectedStation] = useState<Station | null>(null);
  const [showRequirements, setShowRequirements] = useState<string | null>(null);
  const scrollContainerRef = useRef<HTMLDivElement>(null);
  const activeStationRef = useRef<HTMLDivElement>(null);

  const userType = preferences?.userType || 'browser';
  const stations = userType === 'buyer' ? BUYER_STATIONS : RENTER_STATIONS;

  // Calculate current station based on real data
  const getCurrentStation = (): number => {
    if (!preferences?.onboardingCompleted) return 0;
    if (!hasSwipeData || savedListingsCount === 0) return 1;
    if (savedListingsCount >= 3 && savedListingsCount < 10) return 2;
    if (savedListingsCount >= 10) return 3;
    return 2;
  };

  const currentStationIndex = getCurrentStation();
  const progressPercentage = Math.round((currentStationIndex / stations.length) * 100);
  const isJourneyComplete = currentStationIndex >= stations.length - 1;

  // Auto-scroll to active station on mount or when progress changes
  useEffect(() => {
    if (activeStationRef.current && scrollContainerRef.current) {
      const container = scrollContainerRef.current;
      const activeElement = activeStationRef.current;

      const scrollLeft = activeElement.offsetLeft - (container.offsetWidth / 2) + (activeElement.offsetWidth / 2);

      container.scrollTo({
        left: scrollLeft,
        behavior: 'smooth'
      });
    }
  }, [currentStationIndex]);

  // Confetti celebration when journey is complete
  useEffect(() => {
    if (isJourneyComplete) {
      const duration = 3000;
      const end = Date.now() + duration;

      const frame = () => {
        confetti({
          particleCount: 3,
          angle: 60,
          spread: 55,
          origin: { x: 0, y: 0.6 },
          colors: ['#a855f7', '#ec4899', '#8b5cf6']
        });
        confetti({
          particleCount: 3,
          angle: 120,
          spread: 55,
          origin: { x: 1, y: 0.6 },
          colors: ['#a855f7', '#ec4899', '#8b5cf6']
        });

        if (Date.now() < end) {
          requestAnimationFrame(frame);
        }
      };

      // Small delay before starting
      setTimeout(frame, 100);
    }
  }, [isJourneyComplete]);

  // Haptic feedback on mobile
  const triggerHaptic = () => {
    if ('vibrate' in navigator) {
      navigator.vibrate(50);
    }
  };

  // Share journey progress
  const handleShare = async () => {
    triggerHaptic();

    const shareData = {
      title: 'My Home Finding Journey',
      text: `I'm ${progressPercentage}% of the way to finding my new home with HOMEY! Currently at: ${stations[currentStationIndex].title}`,
      url: window.location.origin
    };

    try {
      if (navigator.share) {
        await navigator.share(shareData);
      } else {
        // Fallback: copy to clipboard
        await navigator.clipboard.writeText(`${shareData.text} ${shareData.url}`);
        alert('Progress copied to clipboard!');
      }
    } catch (err) {
      console.log('Share failed:', err);
    }
  };

  // Handle station click
  const handleStationClick = (station: Station, index: number) => {
    triggerHaptic();
    setSelectedStation(station);
  };

  // Get contextual CTA text
  const getModalCTA = (station: Station, index: number) => {
    if (!station.teamMember.recruited) {
      return {
        text: `Find ${station.teamMember.role}`,
        action: () => console.log('Navigate to directory'),
        variant: 'primary' as const
      };
    }

    if (index === currentStationIndex) {
      return {
        text: station.actionLink ? 'Get Started' : 'View Details',
        action: () => station.actionLink && (window.location.href = station.actionLink),
        variant: 'primary' as const
      };
    }

    if (index < currentStationIndex) {
      return {
        text: 'Completed',
        action: () => {},
        variant: 'success' as const
      };
    }

    return {
      text: 'Coming Soon',
      action: () => {},
      variant: 'disabled' as const
    };
  };

  return (
    <motion.div
      className="mb-6"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: 0.4 }}
    >
      {/* Widget Card */}
      <div className="mx-5">
        <div className="glass-strong rounded-2xl border border-white/10 p-4">
          {/* Header */}
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-sm font-bold text-white/40 uppercase tracking-wider">Your Journey</h2>
            <div className="text-sm font-bold text-white">{progressPercentage}%</div>
          </div>

          {/* Progress Bar */}
          <div className="relative h-1.5 bg-white/5 rounded-full overflow-hidden mb-4">
            <motion.div
              className="absolute inset-y-0 left-0 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full"
              initial={{ width: 0 }}
              animate={{ width: `${progressPercentage}%` }}
              transition={{ duration: 1, ease: 'easeOut' }}
            />
          </div>

          {/* Current Station */}
          <motion.button
            onClick={() => handleStationClick(stations[currentStationIndex], currentStationIndex)}
            whileTap={{ scale: 0.98 }}
            className="w-full bg-gradient-to-r from-purple-500/20 to-pink-500/20 border border-purple-500/30 rounded-xl p-3 mb-3"
          >
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-2xl flex-shrink-0">
                {stations[currentStationIndex].icon}
              </div>
              <div className="flex-1 text-left min-w-0">
                <div className="flex items-center gap-2 mb-0.5">
                  <h3 className="text-base font-bold text-white">
                    {stations[currentStationIndex].title}
                  </h3>
                  <motion.span
                    animate={{ opacity: [0.5, 1, 0.5] }}
                    transition={{ duration: 2, repeat: Infinity }}
                    className="text-xs font-bold text-purple-300"
                  >
                    NOW
                  </motion.span>
                </div>
                <p className="text-sm text-white/70">
                  {stations[currentStationIndex].subtitle}
                </p>
              </div>
              <div className="flex items-center gap-1 text-[10px] text-white/40">
                <Clock className="w-3 h-3" />
                <span>{stations[currentStationIndex].estimatedDays}d</span>
              </div>
            </div>
          </motion.button>

          {/* Next Station (if exists) */}
          {currentStationIndex < stations.length - 1 && (
            <motion.button
              onClick={() => handleStationClick(stations[currentStationIndex + 1], currentStationIndex + 1)}
              whileTap={{ scale: 0.98 }}
              className="w-full bg-white/[0.02] border border-white/5 rounded-xl p-3 mb-3"
            >
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-white/5 flex items-center justify-center text-lg flex-shrink-0">
                  {stations[currentStationIndex + 1].icon}
                </div>
                <div className="flex-1 text-left min-w-0">
                  <h3 className="text-sm font-semibold text-white/40">
                    Up Next: {stations[currentStationIndex + 1].title}
                  </h3>
                  <p className="text-xs text-white/30">
                    {stations[currentStationIndex + 1].subtitle}
                  </p>
                </div>
              </div>
            </motion.button>
          )}

          {/* Milestone Dots */}
          <div className="flex items-center gap-1.5 justify-center pt-2">
            {stations.map((_, index) => (
              <motion.button
                key={index}
                onClick={() => index <= currentStationIndex && handleStationClick(stations[index], index)}
                whileTap={{ scale: 0.9 }}
                className={`rounded-full transition-all ${
                  index === currentStationIndex
                    ? 'w-6 h-2 bg-gradient-to-r from-purple-500 to-pink-500'
                    : index < currentStationIndex
                    ? 'w-2 h-2 bg-green-500'
                    : 'w-2 h-2 bg-white/10'
                }`}
              />
            ))}
          </div>
        </div>
      </div>

      {/* Station Detail Modal */}
      <AnimatePresence>
        {selectedStation && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4 bg-black/80 backdrop-blur-sm"
            onClick={() => setSelectedStation(null)}
          >
            <motion.div
              initial={{ y: '100%', opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              exit={{ y: '100%', opacity: 0 }}
              transition={{ type: 'spring', damping: 30, stiffness: 300 }}
              onClick={(e) => e.stopPropagation()}
              className="w-full sm:max-w-md bg-gradient-to-br from-slate-900 to-slate-800 sm:rounded-3xl rounded-t-3xl border border-white/10 overflow-hidden max-h-[90vh] sm:max-h-[85vh] overflow-y-auto"
            >
              {/* Header */}
              <div className="p-6 border-b border-white/10 sticky top-0 bg-slate-900/95 backdrop-blur-xl z-10">
                <div className="flex items-start justify-between">
                  <div className="flex items-center gap-4">
                    <div className={`w-14 h-14 rounded-full bg-gradient-to-br ${selectedStation.teamMember.color} flex items-center justify-center text-xl flex-shrink-0`}>
                      {selectedStation.teamMember.avatar || <Plus className="w-6 h-6 text-white/40" />}
                    </div>
                    <div>
                      <h3 className="text-xl font-bold text-white mb-1">{selectedStation.title}</h3>
                      <p className="text-sm text-white/60">{selectedStation.subtitle}</p>
                      <div className="flex items-center gap-2 mt-1">
                        <Clock className="w-3 h-3 text-white/40" />
                        <span className="text-xs text-white/40">{selectedStation.estimatedDays} days</span>
                      </div>
                    </div>
                  </div>
                  <button
                    onClick={() => setSelectedStation(null)}
                    className="p-2 hover:bg-white/10 rounded-full transition-colors flex-shrink-0"
                  >
                    <X className="w-5 h-5 text-white/60" />
                  </button>
                </div>
              </div>

              {/* Content */}
              <div className="p-6 space-y-4">
                {/* Team Member */}
                <div className="bg-white/5 rounded-2xl p-4 border border-white/10">
                  <div className="flex items-center justify-between mb-3">
                    <div>
                      <p className="text-xs text-white/50 mb-1">Your Guide</p>
                      <h4 className="text-white font-semibold">{selectedStation.teamMember.name}</h4>
                      <p className="text-xs text-white/40">{selectedStation.teamMember.role}</p>
                    </div>
                    {!selectedStation.teamMember.recruited && (
                      <button
                        onClick={() => triggerHaptic()}
                        className="px-4 py-2 bg-purple-500 hover:bg-purple-600 active:scale-95 text-white text-sm font-semibold rounded-lg transition-all"
                      >
                        Find Expert
                      </button>
                    )}
                  </div>
                </div>

                {/* Requirements */}
                <div className="bg-white/5 rounded-2xl p-4 border border-white/10">
                  <h4 className="text-white font-semibold mb-3 text-sm flex items-center gap-2">
                    <CheckCircle2 className="w-4 h-4 text-purple-400" />
                    What You'll Need
                  </h4>
                  <div className="space-y-2">
                    {selectedStation.requirements.map((req, i) => (
                      <div key={i} className="flex items-start gap-3">
                        <div className="w-1.5 h-1.5 rounded-full bg-purple-400 mt-1.5 flex-shrink-0" />
                        <span className="text-sm text-white/70">{req}</span>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Insight */}
                <div className="bg-gradient-to-r from-purple-500/10 to-pink-500/10 border border-purple-500/20 rounded-xl p-4">
                  <div className="flex items-start gap-3">
                    <TrendingUp className="w-5 h-5 text-purple-300 flex-shrink-0 mt-0.5" />
                    <div>
                      <p className="text-xs text-purple-200/60 mb-1 font-semibold">Insight</p>
                      <p className="text-sm text-purple-100/80 leading-relaxed">
                        {selectedStation.insight}
                      </p>
                    </div>
                  </div>
                </div>

                {!selectedStation.teamMember.recruited && (
                  <div className="p-4 bg-yellow-500/10 border border-yellow-500/20 rounded-xl">
                    <p className="text-yellow-200/80 text-sm leading-relaxed">
                      💡 You'll need a {selectedStation.teamMember.role.toLowerCase()} for this step. Browse our directory to find the right expert.
                    </p>
                  </div>
                )}

                {/* CTA Button */}
                <button
                  onClick={() => {
                    triggerHaptic();
                    const cta = getModalCTA(selectedStation, stations.indexOf(selectedStation));
                    cta.action();
                  }}
                  className={`w-full py-4 rounded-xl font-semibold transition-all active:scale-95 ${
                    getModalCTA(selectedStation, stations.indexOf(selectedStation)).variant === 'primary'
                      ? 'bg-gradient-to-r from-purple-500 to-pink-500 hover:opacity-90 text-white'
                      : getModalCTA(selectedStation, stations.indexOf(selectedStation)).variant === 'success'
                      ? 'bg-green-500/20 text-green-300 border border-green-500/30'
                      : 'bg-white/5 text-white/40 cursor-not-allowed'
                  }`}
                  disabled={getModalCTA(selectedStation, stations.indexOf(selectedStation)).variant === 'disabled'}
                >
                  {getModalCTA(selectedStation, stations.indexOf(selectedStation)).text}
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}
