'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Phone, MessageCircle, Mail, ChevronDown, ChevronUp } from 'lucide-react';
import JourneyThemeSelector from './JourneyThemeSelector';
import { getThemeById, getThemePreference } from '@/lib/journeyThemes';

interface JourneyProgressTimelineProps {
  currentStage: number;
  totalStages: number;
  stageName: string;
  onStageClick?: (stageIndex: number) => void;
  onThemeChange?: (themeId: string) => void;
  agentName?: string;
  agentAvatar?: string | null;
  agentPhone?: string;
  agentEmail?: string;
  onAgentMessageClick?: () => void;
  guidanceText?: string;
}

export default function JourneyProgressTimeline({
  currentStage,
  totalStages,
  stageName,
  onStageClick,
  onThemeChange,
  agentName = 'Your Agent',
  agentAvatar,
  agentPhone,
  agentEmail,
  onAgentMessageClick,
  guidanceText,
}: JourneyProgressTimelineProps) {
  const [currentTheme, setCurrentTheme] = useState(() => getThemeById(getThemePreference()));
  const [isExpanded, setIsExpanded] = useState(false);

  const handleThemeChange = (themeId: string) => {
    const newTheme = getThemeById(themeId);
    setCurrentTheme(newTheme);
    onThemeChange?.(themeId);
  };

  const getInitials = (name: string) => {
    const parts = name.split(' ');
    if (parts.length >= 2) {
      return `${parts[0][0]}${parts[parts.length - 1][0]}`.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  };

  const agentInitials = getInitials(agentName);

  const handleCall = () => {
    if (agentPhone) {
      window.location.href = `tel:${agentPhone}`;
    }
  };

  const handleText = () => {
    if (agentPhone) {
      window.location.href = `sms:${agentPhone}`;
    }
  };

  const handleEmail = () => {
    if (agentEmail) {
      window.location.href = `mailto:${agentEmail}`;
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.4 }}
      className="px-5 mb-6"
    >
      <button
        onClick={() => setIsExpanded(!isExpanded)}
        className="w-full relative overflow-hidden rounded-[20px] bg-gradient-to-br from-white/[0.04] to-white/[0.02] border border-white/[0.08] backdrop-blur-xl py-3 px-4 text-left transition-all hover:border-white/[0.12]"
      >
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="w-2 h-2 rounded-full" style={{ backgroundColor: currentTheme.colors.current }} />
            <h3 className="text-[11px] font-bold text-white/40 uppercase tracking-[0.12em] font-display">
              Your Journey
            </h3>
          </div>
          <div className="flex items-center gap-3">
            <p className="text-[13px] font-bold tracking-tight font-display" style={{ color: currentTheme.colors.text.stageName }}>
              {stageName} · {Math.round((currentStage / totalStages) * 100)}%
            </p>
            <div className="text-white/40 text-sm font-bold">
              {isExpanded ? '⌄' : '>'}
            </div>
          </div>
        </div>
      </button>

      <AnimatePresence>
        {isExpanded && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.3, ease: 'easeOut' }}
            className="overflow-hidden"
          >
            <div className="px-5 pt-4 pb-5 bg-gradient-to-br from-white/[0.04] to-white/[0.02] border border-t-0 border-white/[0.08] rounded-b-[24px] backdrop-blur-xl">
              <div className="mb-4">
                <div className="h-2 bg-white/[0.06] rounded-full overflow-hidden">
                  <motion.div
                    initial={{ width: 0 }}
                    animate={{ width: `${(currentStage / totalStages) * 100}%` }}
                    transition={{ duration: 1, ease: 'easeOut' }}
                    className="h-full rounded-full"
                    style={{
                      background: currentTheme.colors.currentGradient || currentTheme.colors.current
                    }}
                  />
                </div>
              </div>

              <div className="mb-5">
                {/* Combined Dots and Labels - Properly aligned */}
                <div className="flex items-start justify-between">
                  {Array.from({ length: totalStages }).map((_, index) => {
                    const isCompleted = index < currentStage;
                    const isCurrent = index === currentStage;
                    const isUpcoming = index > currentStage;
                    const labels = ['Get Ready', 'Explore', 'Tour', 'Apply', 'Approved', 'Move'];

                    return (
                      <div key={index} className="flex flex-col items-center gap-2 flex-1">
                        {/* Dot with connecting line */}
                        <div className="flex items-center w-full">
                          {/* Left spacer for first item */}
                          {index === 0 && <div className="flex-1" />}

                          {/* Line before dot (except first) */}
                          {index > 0 && (
                            <div className="flex-1">
                              {index - 1 < currentStage ? (
                                <motion.div
                                  initial={{ scaleX: 0 }}
                                  animate={{ scaleX: 1 }}
                                  transition={{ delay: (index - 1) * 0.05 + 0.1, duration: 0.2 }}
                                  className="h-0.5 w-full origin-left"
                                  style={{ backgroundColor: currentTheme.colors.line.completed }}
                                />
                              ) : (
                                <div
                                  className="h-0.5 w-full"
                                  style={{ backgroundColor: currentTheme.colors.line.upcoming }}
                                />
                              )}
                            </div>
                          )}

                          {/* Dot */}
                          <motion.button
                            onClick={(e) => {
                              e.stopPropagation();
                              onStageClick?.(index);
                            }}
                            initial={{ scale: 0 }}
                            animate={{ scale: 1 }}
                            transition={{ delay: index * 0.05, type: 'spring' }}
                            whileHover={{ scale: 1.2 }}
                            whileTap={{ scale: 0.9 }}
                            className="relative cursor-pointer flex-shrink-0"
                          >
                            {isCompleted && (
                              <div
                                className="w-2.5 h-2.5 rounded-full"
                                style={{ backgroundColor: currentTheme.colors.completed }}
                              />
                            )}
                            {isCurrent && (
                              <motion.div
                                className="w-3 h-3 rounded-full"
                                style={{
                                  background: currentTheme.colors.currentGradient || currentTheme.colors.current
                                }}
                                animate={currentTheme.pulse ? {
                                  scale: [1, 1.25, 1],
                                } : {}}
                                transition={{
                                  duration: 2,
                                  repeat: Infinity,
                                  ease: "easeInOut"
                                }}
                              />
                            )}
                            {isUpcoming && (
                              <div
                                className="w-2.5 h-2.5 rounded-full border-2"
                                style={{
                                  backgroundColor: currentTheme.colors.upcoming,
                                  borderColor: 'rgba(255, 255, 255, 0.2)'
                                }}
                              />
                            )}
                          </motion.button>

                          {/* Line after dot (except last) */}
                          {index < totalStages - 1 && (
                            <div className="flex-1">
                              {isCompleted ? (
                                <motion.div
                                  initial={{ scaleX: 0 }}
                                  animate={{ scaleX: 1 }}
                                  transition={{ delay: index * 0.05 + 0.1, duration: 0.2 }}
                                  className="h-0.5 w-full origin-left"
                                  style={{ backgroundColor: currentTheme.colors.line.completed }}
                                />
                              ) : (
                                <div
                                  className="h-0.5 w-full"
                                  style={{ backgroundColor: currentTheme.colors.line.upcoming }}
                                />
                              )}
                            </div>
                          )}

                          {/* Right spacer for last item */}
                          {index === totalStages - 1 && <div className="flex-1" />}
                        </div>

                        {/* Label directly below dot */}
                        <p className="text-[9px] text-white/40 font-medium uppercase tracking-wide font-display text-center whitespace-nowrap">
                          {labels[index]}
                        </p>
                      </div>
                    );
                  })}
                </div>
              </div>

              {guidanceText && (
                <div className="mb-5 text-center">
                  <p className="text-[13px] text-white/70 font-medium leading-relaxed font-body">
                    {guidanceText}
                  </p>
                </div>
              )}

              <div className="pt-4 border-t border-white/[0.06]">
                <h4 className="text-[10px] font-bold text-white/40 uppercase tracking-[0.12em] mb-3 font-display">
                  Your Agent
                </h4>
                <div className="flex items-center gap-3 mb-4">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-purple-500/90 to-pink-500/90 p-[1.5px] flex-shrink-0">
                    {agentAvatar ? (
                      <img
                        src={agentAvatar}
                        alt={agentName}
                        className="w-full h-full rounded-full object-cover bg-slate-900"
                      />
                    ) : (
                      <div className="w-full h-full rounded-full bg-slate-900 flex items-center justify-center text-white text-sm font-semibold">
                        {agentInitials}
                      </div>
                    )}
                  </div>
                  <div className="flex-1">
                    <p className="text-[13px] text-white/80 font-medium leading-relaxed font-body">
                      Ready to talk through these homes? I&apos;m here.
                    </p>
                  </div>
                </div>

                <div className="grid grid-cols-3 gap-2">
                  {agentPhone && (
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        handleCall();
                      }}
                      className="flex flex-col items-center gap-1.5 p-3 rounded-[14px] bg-white/[0.04] border border-white/[0.08] hover:bg-white/[0.06] active:bg-white/[0.08] transition-colors"
                    >
                      <Phone className="w-4 h-4 text-white/60" />
                      <span className="text-[11px] text-white/60 font-medium font-body">Call</span>
                    </button>
                  )}

                  {agentPhone && (
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        handleText();
                      }}
                      className="flex flex-col items-center gap-1.5 p-3 rounded-[14px] bg-white/[0.04] border border-white/[0.08] hover:bg-white/[0.06] active:bg-white/[0.08] transition-colors"
                    >
                      <MessageCircle className="w-4 h-4 text-white/60" />
                      <span className="text-[11px] text-white/60 font-medium font-body">Text</span>
                    </button>
                  )}

                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      onAgentMessageClick?.();
                    }}
                    className="flex flex-col items-center gap-1.5 p-3 rounded-[14px] bg-white/[0.04] border border-white/[0.08] hover:bg-white/[0.06] active:bg-white/[0.08] transition-colors"
                  >
                    <Mail className="w-4 h-4 text-white/60" />
                    <span className="text-[11px] text-white/60 font-medium font-body">Message</span>
                  </button>
                </div>

                <div className="mt-4 pt-4 border-t border-white/[0.06] flex items-center justify-between">
                  <p className="text-[10px] font-bold text-white/40 uppercase tracking-[0.12em] font-display">
                    Theme
                  </p>
                  <JourneyThemeSelector onThemeChange={handleThemeChange} />
                </div>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}
