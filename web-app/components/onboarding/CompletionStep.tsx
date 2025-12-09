'use client';

import { useEffect } from 'react';
import { motion } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';

interface CompletionStepProps {
  data: OnboardingData;
  onComplete: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function CompletionStep({ onComplete, isSaving }: CompletionStepProps) {
  useEffect(() => {
    // Auto-complete after a delay to show the celebration
    const timer = setTimeout(() => {
      onComplete({});
    }, 4000);

    return () => clearTimeout(timer);
  }, [onComplete]);

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ duration: 0.8 }}
      className="w-full max-w-2xl mx-auto text-center"
    >
      {/* Success Icon */}
      <motion.div
        initial={{ opacity: 0, scale: 0.8 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ delay: 0.2, duration: 0.6 }}
        className="mb-8"
      >
        <div
          className="w-24 h-24 mx-auto rounded-full flex items-center justify-center text-5xl backdrop-blur-xl"
          style={{
            background: 'rgba(20, 241, 149, 0.15)',
            border: '2px solid rgba(20, 241, 149, 0.4)',
            boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37), 0 0 30px rgba(20, 241, 149, 0.3)',
          }}
        >
          ✓
        </div>
      </motion.div>

      {/* Main Message */}
      <motion.h1
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4, duration: 0.6 }}
        className="text-5xl md:text-6xl font-light mb-4 text-white"
        style={{ fontFamily: 'Playfair Display, serif' }}
      >
        You're all set!
      </motion.h1>

      <motion.p
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.6, duration: 0.6 }}
        className="text-xl text-white/60 mb-12 max-w-lg mx-auto"
      >
        We've created your personalized home search experience.
      </motion.p>

      {/* Reassurance Card */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.8, duration: 0.6 }}
        className="rounded-2xl p-8 mb-8 backdrop-blur-xl"
        style={{
          background: 'rgba(255, 255, 255, 0.05)',
          border: '1.5px solid rgba(0, 240, 255, 0.3)',
          boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37), 0 0 30px rgba(0, 240, 255, 0.2)',
        }}
      >
        <div className="text-3xl mb-3">🎯</div>
        <h3 className="text-white text-lg font-semibold mb-2">
          HOMEY learns as you go
        </h3>
        <p className="text-white/60 text-sm leading-relaxed">
          Don't worry about getting everything perfect right now. The more you explore,
          the better HOMEY gets at understanding what you're looking for.
        </p>
      </motion.div>

      {/* Loading Indicator */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1, duration: 0.6 }}
        className="flex flex-col items-center gap-3"
      >
        <motion.div
          className="w-8 h-8 rounded-full"
          style={{
            border: '3px solid rgba(0, 240, 255, 0.2)',
            borderTopColor: '#00f0ff',
          }}
          animate={{ rotate: 360 }}
          transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
        />
        <p className="text-white/50 text-sm">
          {isSaving ? 'Saving your preferences...' : 'Getting your home feed ready...'}
        </p>
      </motion.div>
    </motion.div>
  );
}
