'use client';

import { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, ChevronRight, ChevronLeft, Sparkles } from 'lucide-react';
import { useSwipeable } from 'react-swipeable';

export interface TutorialStep {
  id: string;
  title: string;
  description: string;
  targetSelector?: string; // CSS selector for the element to highlight
  position?: 'top' | 'bottom' | 'left' | 'right' | 'center';
  action?: () => void; // Optional action to perform when step is shown
  requireInteraction?: boolean; // If true, user must tap the target element to proceed
  interactionHint?: string; // Custom hint for interactive steps
}

interface TutorialProps {
  steps: TutorialStep[];
  tutorialKey: string; // Unique key for this tutorial (for localStorage)
  onComplete?: () => void;
  onSkip?: () => void;
}

export default function Tutorial({ steps, tutorialKey, onComplete, onSkip }: TutorialProps) {
  const [currentStep, setCurrentStep] = useState(0);
  const [isActive, setIsActive] = useState(false);
  const [targetRect, setTargetRect] = useState<DOMRect | null>(null);
  const [waitingForInteraction, setWaitingForInteraction] = useState(false);
  const startTimeRef = useRef<number>(Date.now());
  const stepTimesRef = useRef<Record<string, number>>({});


  useEffect(() => {
    // Check if tutorial has been completed
    const completed = localStorage.getItem(`tutorial_${tutorialKey}`);
    if (!completed) {
      setIsActive(true);
      startTimeRef.current = Date.now();
    }
  }, [tutorialKey]);

  useEffect(() => {
    if (!isActive || !steps[currentStep]?.targetSelector) {
      setTargetRect(null);
      setWaitingForInteraction(false);
      return;
    }

    // Track step start time
    stepTimesRef.current[steps[currentStep].id] = Date.now();

    // Find the target element and get its position
    const updateTargetPosition = () => {
      const target = document.querySelector(steps[currentStep].targetSelector!);
      if (target) {
        setTargetRect(target.getBoundingClientRect());
      }
    };

    updateTargetPosition();
    window.addEventListener('resize', updateTargetPosition);
    window.addEventListener('scroll', updateTargetPosition);

    // Execute step action if provided
    if (steps[currentStep].action) {
      steps[currentStep].action!();
    }

    // Haptic feedback when step changes (mobile devices)
    if ('vibrate' in navigator) {
      navigator.vibrate(10);
    }

    // Set up interactive step listener
    if (steps[currentStep].requireInteraction) {
      setWaitingForInteraction(true);
      const target = document.querySelector(steps[currentStep].targetSelector!);

      const handleInteraction = () => {
        // Haptic feedback on interaction
        if ('vibrate' in navigator) {
          navigator.vibrate([10, 50, 10]);
        }
        setWaitingForInteraction(false);
        // Auto-advance after interaction
        setTimeout(() => handleNext(), 500);
      };

      if (target) {
        target.addEventListener('click', handleInteraction);
        return () => {
          target.removeEventListener('click', handleInteraction);
          window.removeEventListener('resize', updateTargetPosition);
          window.removeEventListener('scroll', updateTargetPosition);
        };
      }
    }

    return () => {
      window.removeEventListener('resize', updateTargetPosition);
      window.removeEventListener('scroll', updateTargetPosition);
    };
  }, [currentStep, isActive, steps]);

  const handleNext = () => {
    // Track step completion time
    const stepId = steps[currentStep].id;
    const stepDuration = Date.now() - (stepTimesRef.current[stepId] || Date.now());

    // Log analytics
    if (typeof window !== 'undefined' && (window as any).analytics) {
      (window as any).analytics.click('tutorial_step_complete', 'tutorial', {
        tutorial: tutorialKey,
        step: stepId,
        stepNumber: currentStep + 1,
        duration: stepDuration,
      });
    }

    if (currentStep < steps.length - 1) {
      setCurrentStep(currentStep + 1);
      // Haptic feedback
      if ('vibrate' in navigator) {
        navigator.vibrate(10);
      }
    } else {
      handleComplete();
    }
  };

  const handlePrevious = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
      // Haptic feedback
      if ('vibrate' in navigator) {
        navigator.vibrate(10);
      }
    }
  };

  const handleComplete = () => {
    const totalDuration = Date.now() - startTimeRef.current;

    // Log completion analytics
    if (typeof window !== 'undefined' && (window as any).analytics) {
      (window as any).analytics.click('tutorial_complete_internal', 'tutorial', {
        tutorial: tutorialKey,
        totalDuration,
        stepsCompleted: steps.length,
        stepTimes: stepTimesRef.current,
      });
    }

    localStorage.setItem(`tutorial_${tutorialKey}`, 'true');

    // Haptic celebration
    if ('vibrate' in navigator) {
      navigator.vibrate([50, 100, 50, 100, 50]);
    }

    setIsActive(false);
    onComplete?.();
  };

  const handleSkip = () => {
    const totalDuration = Date.now() - startTimeRef.current;

    // Log skip analytics
    if (typeof window !== 'undefined' && (window as any).analytics) {
      (window as any).analytics.click('tutorial_skip_internal', 'tutorial', {
        tutorial: tutorialKey,
        skippedAt: currentStep + 1,
        totalSteps: steps.length,
        duration: totalDuration,
      });
    }

    localStorage.setItem(`tutorial_${tutorialKey}`, 'true');
    setIsActive(false);
    onSkip?.();
  };

  const getTooltipPosition = () => {
    const padding = 16; // Padding from screen edges

    if (!targetRect) {
      // Center position for non-targeted steps
      return {
        top: '50%',
        left: '16px',
        right: '16px',
        transform: 'translateY(-50%)',
        maxHeight: 'calc(100vh - 32px)',
        maxWidth: '400px',
        marginLeft: 'auto',
        marginRight: 'auto',
      };
    }

    const windowHeight = window.innerHeight;
    const navBarHeight = 80;

    // Smart positioning based on target location
    const targetTop = targetRect.top;
    const targetBottom = targetRect.bottom;
    const spaceAbove = targetTop;
    const spaceBelow = windowHeight - targetBottom;

    // Base style with proper constraints
    const baseStyle = {
      left: '16px',
      right: '16px',
      maxHeight: 'calc(100vh - 100px)',
      maxWidth: '400px',
      marginLeft: 'auto',
      marginRight: 'auto',
    };

    // Check if target is in bottom half (near nav bar)
    if (spaceBelow < 200 || targetBottom > windowHeight - navBarHeight - 100) {
      // Position above target
      const bottomPosition = Math.max(
        windowHeight - targetTop + padding,
        navBarHeight + padding
      );
      return {
        ...baseStyle,
        bottom: `${bottomPosition}px`,
      };
    }

    // Check if target is in top quarter or has more space below
    if (spaceAbove < 200 || targetTop < windowHeight / 4) {
      // Position below target
      const topPosition = Math.max(targetBottom + padding, padding);
      return {
        ...baseStyle,
        top: `${topPosition}px`,
      };
    }

    // Default: position at bottom center (above nav)
    return {
      ...baseStyle,
      bottom: `${navBarHeight + padding}px`,
    };
  };

  // Swipe gesture handlers
  const swipeHandlers = useSwipeable({
    onSwipedLeft: () => {
      if (!waitingForInteraction && currentStep < steps.length - 1) {
        handleNext();
      }
    },
    onSwipedRight: () => {
      if (!waitingForInteraction && currentStep > 0) {
        handlePrevious();
      }
    },
    preventScrollOnSwipe: true,
    trackMouse: false,
  });

  if (!isActive) return null;

  const step = steps[currentStep];
  const tooltipPosition = getTooltipPosition();

  return (
    <AnimatePresence>
      <motion.div
        key="tutorial-overlay"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 z-[10000]"
        {...swipeHandlers}
      >
        {/* Spotlight on target element with pulsing animation and dark overlay */}
        {targetRect ? (
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{
              opacity: 1,
              scale: [1, 1.02, 1],
            }}
            transition={{
              scale: { duration: 2, repeat: Infinity, ease: 'easeInOut' },
            }}
            style={{
              position: 'fixed',
              top: targetRect.top - 8,
              left: targetRect.left - 8,
              width: targetRect.width + 16,
              height: targetRect.height + 16,
              borderRadius: '12px',
              border: '3px solid rgba(168, 218, 220, 0.9)',
              boxShadow: '0 0 0 9999px rgba(0, 0, 0, 0.7), 0 0 0 4px rgba(168, 218, 220, 0.3), 0 0 20px rgba(168, 218, 220, 0.5)',
              pointerEvents: waitingForInteraction ? 'none' : 'none',
            }}
          />
        ) : (
          /* Dark overlay for non-targeted steps */
          <div className="absolute inset-0 bg-black/70" onClick={handleSkip} />
        )}

        {/* Interaction prompt for interactive steps */}
        {waitingForInteraction && targetRect && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className="fixed z-[10002] pointer-events-none"
            style={{
              top: targetRect.top - 40,
              left: targetRect.left + targetRect.width / 2,
              transform: 'translateX(-50%)',
            }}
          >
            <div className="bg-primary text-white text-xs font-bold px-3 py-1.5 rounded-full shadow-lg flex items-center gap-1.5">
              <Sparkles className="w-3.5 h-3.5" />
              {step.interactionHint || 'Tap this!'}
            </div>
          </motion.div>
        )}

        {/* Tooltip */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: 20 }}
          style={tooltipPosition}
          className="fixed z-[10001] overflow-y-auto"
        >
          <div className="bg-gradient-to-br from-slate-900/95 via-purple-900/95 to-slate-900/95 backdrop-blur-xl border border-white/20 rounded-2xl p-4 shadow-2xl">
            {/* Header */}
            <div className="flex items-start justify-between mb-4">
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <span className="text-2xl">✨</span>
                  <h3 className="text-lg font-bold text-white">{step.title}</h3>
                </div>
                <p className="text-sm text-white/70">{step.description}</p>
              </div>
              <button
                onClick={handleSkip}
                className="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center transition ml-2"
              >
                <X className="w-5 h-5 text-white" />
              </button>
            </div>

            {/* Progress dots */}
            <div className="flex items-center justify-center gap-1.5 mb-4">
              {steps.map((_, index) => (
                <div
                  key={index}
                  className={`h-1.5 rounded-full transition-all ${
                    index === currentStep
                      ? 'w-8 bg-gradient-to-r from-primary to-purple-500'
                      : index < currentStep
                      ? 'w-1.5 bg-primary/50'
                      : 'w-1.5 bg-white/20'
                  }`}
                />
              ))}
            </div>

            {/* Navigation */}
            <div className="flex items-center justify-between gap-3">
              <button
                onClick={handlePrevious}
                disabled={currentStep === 0}
                className="px-4 py-2 rounded-lg bg-white/10 text-white text-sm font-medium hover:bg-white/20 transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
              >
                <ChevronLeft className="w-4 h-4" />
                Back
              </button>

              <span className="text-xs text-white/60">
                {currentStep + 1} of {steps.length}
              </span>

              <button
                onClick={handleNext}
                className="px-4 py-2 rounded-lg bg-gradient-to-r from-primary to-purple-500 text-white text-sm font-medium hover:opacity-90 transition flex items-center gap-2"
              >
                {currentStep === steps.length - 1 ? 'Finish' : 'Next'}
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>

            {/* Skip option */}
            {currentStep === 0 && (
              <button
                onClick={handleSkip}
                className="w-full mt-3 text-xs text-white/50 hover:text-white/70 transition"
              >
                Skip (but we'll always be here if you need us)
              </button>
            )}

            {/* Swipe hint */}
            <div className="flex items-center justify-center gap-2 mt-2">
              <div className="h-px w-8 bg-white/20" />
              <span className="text-[10px] text-white/40">Swipe left or right</span>
              <div className="h-px w-8 bg-white/20" />
            </div>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
}
