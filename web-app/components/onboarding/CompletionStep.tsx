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
      className="w-full max-w-3xl mx-auto text-center"
    >
      {/* Success Icon */}
      <motion.div
        initial={{ scale: 0, rotate: -180 }}
        animate={{ scale: 1, rotate: 0 }}
        transition={{
          delay: 0.2,
          duration: 0.8,
          type: 'spring',
          damping: 15,
        }}
        className="mb-12"
      >
        <div className="w-32 h-32 mx-auto rounded-full bg-gradient-to-br from-green-400 to-emerald-500 flex items-center justify-center text-7xl shadow-2xl shadow-green-500/30">
          ✓
        </div>
      </motion.div>

      {/* Main Message */}
      <motion.h1
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.4, duration: 0.8 }}
        className="text-5xl md:text-6xl font-light text-white mb-6"
        style={{ fontFamily: 'Playfair Display, serif' }}
      >
        You're all set!
      </motion.h1>

      <motion.p
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.6, duration: 0.8 }}
        className="text-xl md:text-2xl text-white/70 mb-16 max-w-2xl mx-auto leading-relaxed"
      >
        We've created your personalized home search experience.
        <br />
        Let's find your perfect space.
      </motion.p>

      {/* Reassurance Message */}
      <motion.div
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.8, duration: 0.8 }}
        className="glass-strong rounded-3xl p-8 md:p-10 mb-12 border border-white/10"
      >
        <div className="text-4xl mb-4">🎯</div>
        <h3 className="text-white text-xl font-semibold mb-3">
          HOMEY learns as you go
        </h3>
        <p className="text-white/60 leading-relaxed">
          Don't worry about getting everything perfect right now. The more you swipe,
          save, and explore, the better HOMEY gets at understanding exactly what you're
          looking for. Your dream home journey starts now, and we'll be with you every
          step of the way.
        </p>
      </motion.div>

      {/* Loading Indicator */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1, duration: 0.8 }}
        className="flex flex-col items-center gap-4"
      >
        <div className="w-12 h-12 border-4 border-white/20 border-t-primary rounded-full animate-spin" />
        <p className="text-white/50 text-sm">
          {isSaving ? 'Preparing your personalized feed...' : 'Taking you to your home...'}
        </p>
      </motion.div>

      {/* Floating particles animation */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        {[...Array(20)].map((_, i) => (
          <motion.div
            key={i}
            initial={{
              x: Math.random() * window.innerWidth,
              y: window.innerHeight + 50,
              opacity: 0,
            }}
            animate={{
              y: -50,
              opacity: [0, 1, 0],
            }}
            transition={{
              delay: Math.random() * 2,
              duration: 3 + Math.random() * 2,
              repeat: Infinity,
              repeatDelay: Math.random() * 3,
            }}
            className="absolute text-2xl"
          >
            {['🏡', '✨', '🎉', '🔑', '❤️'][Math.floor(Math.random() * 5)]}
          </motion.div>
        ))}
      </div>
    </motion.div>
  );
}
