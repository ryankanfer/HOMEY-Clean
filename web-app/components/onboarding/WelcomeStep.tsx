'use client';

import { motion } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';

interface WelcomeStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function WelcomeStep({ onNext, isSaving }: WelcomeStepProps) {
  const handleContinue = () => {
    onNext({});
  };

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ duration: 0.8 }}
      className="w-full max-w-4xl mx-auto text-center"
    >
      {/* Logo/Icon */}
      <motion.div
        initial={{ scale: 0.5, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.8, type: 'spring', damping: 20 }}
        className="mb-12"
      >
        <div className="w-24 h-24 mx-auto rounded-full bg-gradient-to-br from-primary to-purple-500 flex items-center justify-center text-5xl shadow-2xl shadow-primary/30">
          🏡
        </div>
      </motion.div>

      {/* Main Heading */}
      <motion.h1
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.4, duration: 0.8 }}
        className="text-6xl md:text-7xl font-light text-white mb-6"
        style={{ fontFamily: 'Playfair Display, serif' }}
      >
        Welcome to{' '}
        <span className="font-normal bg-gradient-to-r from-primary to-purple-400 bg-clip-text text-transparent">
          HOMEY
        </span>
      </motion.h1>

      {/* Subheading */}
      <motion.p
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.6, duration: 0.8 }}
        className="text-xl md:text-2xl text-white/70 mb-16 max-w-2xl mx-auto leading-relaxed"
      >
        Your AI-powered home-finding assistant.
        <br />
        Let's find your perfect space together.
      </motion.p>

      {/* Feature Highlights */}
      <motion.div
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.8, duration: 0.8 }}
        className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-16"
      >
        <div className="glass-strong rounded-2xl p-6">
          <div className="text-4xl mb-3">✨</div>
          <h3 className="text-white font-semibold mb-2">Personalized</h3>
          <p className="text-white/60 text-sm">
            AI learns your taste and finds homes you'll love
          </p>
        </div>

        <div className="glass-strong rounded-2xl p-6">
          <div className="text-4xl mb-3">⚡️</div>
          <h3 className="text-white font-semibold mb-2">Effortless</h3>
          <p className="text-white/60 text-sm">
            Swipe, save, and schedule tours in seconds
          </p>
        </div>

        <div className="glass-strong rounded-2xl p-6">
          <div className="text-4xl mb-3">🎯</div>
          <h3 className="text-white font-semibold mb-2">Smart</h3>
          <p className="text-white/60 text-sm">
            Get recommendations that match your lifestyle
          </p>
        </div>
      </motion.div>

      {/* CTA */}
      <motion.div
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 1, duration: 0.8 }}
      >
        <button
          onClick={handleContinue}
          disabled={isSaving}
          className="px-12 py-5 bg-gradient-to-r from-primary to-purple-500 text-white rounded-full font-bold text-lg hover:shadow-2xl hover:shadow-primary/30 transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Let's Get Started →
        </button>

        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1.2, duration: 0.8 }}
          className="text-white/50 text-sm mt-6"
        >
          Takes less than 2 minutes
        </motion.p>
      </motion.div>
    </motion.div>
  );
}
