'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { X, CheckCircle2, Clock, User, TrendingUp } from 'lucide-react';

interface StageAction {
  title: string;
  completed: boolean;
  description?: string;
}

interface StageInfo {
  id: string;
  title: string;
  subtitle: string;
  icon: string;
  estimatedDays: string;
  teamMember: {
    name: string;
    role: string;
    avatar: string;
  };
  requirements: string[];
  actions: StageAction[];
  insight: string;
}

interface StageDetailModalProps {
  isOpen: boolean;
  onClose: () => void;
  stageInfo: StageInfo | null;
  currentStage: number;
  selectedStage: number;
}

// Journey stage data (Renter Journey)
export const RENTER_STAGES: StageInfo[] = [
  {
    id: 'get_ready',
    title: 'Get Ready',
    subtitle: 'Documents & Budget',
    icon: '📋',
    estimatedDays: '1-2',
    teamMember: {
      name: 'You',
      role: 'Lead',
      avatar: '👤',
    },
    requirements: ['Photo ID', 'Proof of income', 'Bank statements', 'References'],
    actions: [
      { title: 'Complete profile setup', completed: true },
      { title: 'Upload required documents', completed: false, description: 'ID, pay stubs, bank statements' },
      { title: 'Set your budget range', completed: false },
    ],
    insight: '85% of renters complete this in under 2 days',
  },
  {
    id: 'explore',
    title: 'Explore',
    subtitle: 'Find Your Home',
    icon: '🔍',
    estimatedDays: '7-14',
    teamMember: {
      name: 'Your Agent',
      role: 'Partner Agent',
      avatar: 'SC',
    },
    requirements: ['Budget defined', 'Neighborhood preferences', 'Must-have features'],
    actions: [
      { title: 'Swipe on 10+ properties', completed: false, description: 'Train HOMEY AI' },
      { title: 'Save your favorites', completed: false },
      { title: 'Refine search filters', completed: false },
    ],
    insight: 'Most users swipe through 50+ properties before finding the one',
  },
  {
    id: 'tour',
    title: 'Tour',
    subtitle: 'See in Person',
    icon: '🏠',
    estimatedDays: '3-7',
    teamMember: {
      name: 'Your Agent',
      role: 'Partner Agent',
      avatar: 'SC',
    },
    requirements: ['Scheduled viewings', 'Questions prepared', 'Transportation planned'],
    actions: [
      { title: 'Schedule property tours', completed: false },
      { title: 'Visit top properties', completed: false },
      { title: 'Take notes & photos', completed: false },
    ],
    insight: 'Average renter tours 5-8 properties before applying',
  },
  {
    id: 'apply',
    title: 'Apply',
    subtitle: 'Submit Package',
    icon: '📤',
    estimatedDays: '1-2',
    teamMember: {
      name: 'You',
      role: 'Lead',
      avatar: '👤',
    },
    requirements: ['Application fee', 'Complete documents', 'Security deposit ready'],
    actions: [
      { title: 'Submit rental application', completed: false },
      { title: 'Pay application fee', completed: false },
      { title: 'Follow up with landlord', completed: false },
    ],
    insight: 'Strong applications typically get responses within 48 hours',
  },
  {
    id: 'approved',
    title: 'Approved',
    subtitle: 'Review Lease',
    icon: '✅',
    estimatedDays: '2-3',
    teamMember: {
      name: 'Attorney',
      role: 'Legal Review',
      avatar: '⚖️',
    },
    requirements: ['Review lease terms', 'Legal consultation', 'Clarify questions'],
    actions: [
      { title: 'Review lease agreement', completed: false },
      { title: 'Consult with attorney', completed: false, description: 'Recommended for protection' },
      { title: 'Negotiate terms if needed', completed: false },
    ],
    insight: 'Having an attorney review can save thousands in the long run',
  },
  {
    id: 'move_in',
    title: 'Move In',
    subtitle: 'Get Your Keys',
    icon: '🔑',
    estimatedDays: '1',
    teamMember: {
      name: 'You',
      role: 'New Tenant',
      avatar: '👤',
    },
    requirements: ['First month rent', 'Security deposit', 'Move-in inspection'],
    actions: [
      { title: 'Complete move-in inspection', completed: false },
      { title: 'Pay first month + deposit', completed: false },
      { title: 'Receive keys', completed: false },
    ],
    insight: 'Congratulations! The average renter stays 2-3 years',
  },
];

export default function StageDetailModal({
  isOpen,
  onClose,
  stageInfo,
  currentStage,
  selectedStage,
}: StageDetailModalProps) {
  if (!stageInfo) return null;

  const isCompleted = selectedStage < currentStage;
  const isCurrent = selectedStage === currentStage;
  const isUpcoming = selectedStage > currentStage;

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4">
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="absolute inset-0 bg-black/80 backdrop-blur-sm"
          />

          {/* Modal */}
          <motion.div
            initial={{ opacity: 0, y: '100%' }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: '100%' }}
            transition={{ type: 'spring', damping: 30, stiffness: 300 }}
            onClick={(e) => e.stopPropagation()}
            className="relative w-full sm:max-w-md glass-strong sm:rounded-3xl rounded-t-3xl border border-white/10 overflow-hidden max-h-[90vh] sm:max-h-[85vh] overflow-y-auto"
          >
            {/* Header */}
            <div className="sticky top-0 p-6 border-b border-white/10 bg-slate-900/95 backdrop-blur-xl z-10">
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-4">
                  <div className="w-14 h-14 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-3xl">
                    {stageInfo.icon}
                  </div>
                  <div>
                    <h3 className="text-xl font-bold text-white mb-1">{stageInfo.title}</h3>
                    <p className="text-sm text-white/60">{stageInfo.subtitle}</p>
                    <div className="flex items-center gap-2 mt-1">
                      <Clock className="w-3 h-3 text-white/40" />
                      <span className="text-xs text-white/40">{stageInfo.estimatedDays} days</span>
                    </div>
                  </div>
                </div>
                <button
                  onClick={onClose}
                  className="p-2 hover:bg-white/10 rounded-full transition-colors flex-shrink-0"
                >
                  <X className="w-5 h-5 text-white/60" />
                </button>
              </div>

              {/* Status Badge */}
              <div className="mt-4">
                {isCompleted && (
                  <div className="inline-flex items-center gap-2 px-3 py-1.5 bg-green-500/20 border border-green-500/50 rounded-full">
                    <CheckCircle2 className="w-4 h-4 text-green-400" />
                    <span className="text-sm font-medium text-green-300">Completed</span>
                  </div>
                )}
                {isCurrent && (
                  <div className="inline-flex items-center gap-2 px-3 py-1.5 bg-gradient-to-r from-purple-500/20 to-pink-500/20 border border-purple-500/50 rounded-full">
                    <div className="w-2 h-2 rounded-full bg-gradient-to-r from-purple-500 to-pink-500 animate-pulse" />
                    <span className="text-sm font-medium text-purple-300">Current Stage</span>
                  </div>
                )}
                {isUpcoming && (
                  <div className="inline-flex items-center gap-2 px-3 py-1.5 bg-white/5 border border-white/20 rounded-full">
                    <Clock className="w-4 h-4 text-white/40" />
                    <span className="text-sm font-medium text-white/40">Upcoming</span>
                  </div>
                )}
              </div>
            </div>

            {/* Content */}
            <div className="p-6 space-y-6">
              {/* Team Member */}
              <div className="bg-white/5 rounded-2xl p-4 border border-white/10">
                <div className="flex items-center gap-3 mb-2">
                  <User className="w-4 h-4 text-purple-400" />
                  <p className="text-xs text-white/50 font-medium">Your Guide</p>
                </div>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-xl">
                    {stageInfo.teamMember.avatar}
                  </div>
                  <div>
                    <h4 className="text-white font-semibold">{stageInfo.teamMember.name}</h4>
                    <p className="text-xs text-white/40">{stageInfo.teamMember.role}</p>
                  </div>
                </div>
              </div>

              {/* Actions/Checklist */}
              <div className="bg-white/5 rounded-2xl p-4 border border-white/10">
                <h4 className="text-white font-semibold mb-3 text-sm flex items-center gap-2">
                  <CheckCircle2 className="w-4 h-4 text-purple-400" />
                  {isCurrent ? 'Your Action Items' : isCompleted ? 'What You Did' : 'What You\'ll Need'}
                </h4>
                <div className="space-y-3">
                  {stageInfo.actions.map((action, i) => (
                    <div key={i} className="flex items-start gap-3">
                      <div className={`w-5 h-5 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 ${
                        action.completed || isCompleted
                          ? 'bg-green-500/20 border-2 border-green-500'
                          : 'border-2 border-white/20'
                      }`}>
                        {(action.completed || isCompleted) && (
                          <CheckCircle2 className="w-3 h-3 text-green-400" />
                        )}
                      </div>
                      <div className="flex-1">
                        <p className={`text-sm ${action.completed || isCompleted ? 'text-white/70 line-through' : 'text-white'}`}>
                          {action.title}
                        </p>
                        {action.description && (
                          <p className="text-xs text-white/40 mt-0.5">{action.description}</p>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Requirements */}
              <div className="bg-white/5 rounded-2xl p-4 border border-white/10">
                <h4 className="text-white font-semibold mb-3 text-sm">Requirements</h4>
                <div className="space-y-2">
                  {stageInfo.requirements.map((req, i) => (
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
                      {stageInfo.insight}
                    </p>
                  </div>
                </div>
              </div>

              {/* CTA Button */}
              {isCurrent && (
                <button
                  onClick={onClose}
                  className="w-full py-4 bg-gradient-to-r from-purple-500 to-pink-500 hover:opacity-90 text-white font-semibold rounded-xl transition-all"
                >
                  Got It
                </button>
              )}
            </div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
}
