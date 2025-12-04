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
      {/* Logo/Icon - Bouncing with glow */}
      <motion.div
        initial={{ scale: 0.5, opacity: 0, y: -20 }}
        animate={{
          scale: 1,
          opacity: 1,
          y: [0, -10, 0],
        }}
        transition={{
          delay: 0.2,
          duration: 0.8,
          type: 'spring',
          damping: 15,
          y: {
            repeat: Infinity,
            duration: 2,
            ease: "easeInOut",
            delay: 1
          }
        }}
        className="mb-8"
      >
        <div className="w-28 h-28 mx-auto rounded-full bg-gradient-to-br from-primary via-purple-500 to-pink-500 flex items-center justify-center text-6xl shadow-2xl shadow-primary/50 relative">
          <div className="absolute inset-0 rounded-full bg-gradient-to-br from-primary to-purple-500 animate-pulse opacity-50"></div>
          <span className="relative z-10">🏡</span>
        </div>
      </motion.div>

      {/* Main Heading */}
      <motion.h1
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.4, duration: 0.8 }}
        className="text-5xl md:text-6xl font-light text-white mb-4"
        style={{ fontFamily: 'Playfair Display, serif' }}
      >
        Hey, I'm{' '}
        <span className="font-semibold bg-gradient-to-r from-primary to-purple-400 bg-clip-text text-transparent">
          Homey
        </span>
      </motion.h1>

      {/* Personality Tagline */}
      <motion.p
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.6, duration: 0.8 }}
        className="text-2xl md:text-3xl text-white/90 mb-4 font-light"
      >
        Your AI home-finding partner
      </motion.p>

      {/* Subheading */}
      <motion.p
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.7, duration: 0.8 }}
        className="text-lg md:text-xl text-white/60 mb-12 max-w-2xl mx-auto leading-relaxed"
      >
        Part real estate agent, part best friend, 100% here for you.
        <br />
        <span className="text-white/80">Let's find your perfect place.</span>
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
          <h3 className="text-white font-semibold mb-2">I learn what you love</h3>
          <p className="text-white/60 text-sm">
            The more we talk, the better I get at finding your vibe
          </p>
        </div>

        <div className="glass-strong rounded-2xl p-6">
          <div className="text-4xl mb-3">⚡️</div>
          <h3 className="text-white font-semibold mb-2">No tedious scrolling</h3>
          <p className="text-white/60 text-sm">
            Swipe through curated picks, book tours in one tap
          </p>
        </div>

        <div className="glass-strong rounded-2xl p-6">
          <div className="text-4xl mb-3">🎯</div>
          <h3 className="text-white font-semibold mb-2">Actually gets you</h3>
          <p className="text-white/60 text-sm">
            Not just bedrooms and bathrooms—your whole lifestyle
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
          Let's find your place →
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
