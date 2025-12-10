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
    <div className="relative w-full h-full flex items-center justify-center overflow-hidden">
      {/* Main Content - Base Layer */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 1, delay: 1.5 }}
        className="relative z-0 text-center px-6"
      >
        {/* House Icon */}
        <motion.div
          initial={{ scale: 0, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{
            delay: 1.8,
            duration: 0.8,
            type: 'spring',
            damping: 12,
          }}
          className="mb-8"
        >
          <span className="text-8xl md:text-9xl filter drop-shadow-2xl">🏡</span>
        </motion.div>

        {/* Title */}
        <motion.h1
          initial={{ y: 30, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 2, duration: 0.8 }}
          className="text-6xl md:text-7xl font-light mb-4 text-white"
          style={{ fontFamily: 'Playfair Display, serif' }}
        >
          Hey, I'm Homey
        </motion.h1>

        {/* Tagline */}
        <motion.p
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 2.3, duration: 0.8 }}
          className="text-xl md:text-2xl text-white/70 mb-2 font-light italic"
        >
          Unlock your future
        </motion.p>

        <motion.p
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 2.5, duration: 0.8 }}
          className="text-lg md:text-xl text-white/50 mb-12 font-light"
        >
          Let's find your perfect place
        </motion.p>

        {/* CTA */}
        <motion.button
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 2.7, duration: 0.8 }}
          onClick={handleContinue}
          disabled={isSaving}
          className="px-12 py-4 bg-white/10 backdrop-blur-sm text-white rounded-full font-medium text-lg hover:bg-white/20 transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed border border-white/20"
        >
          Get Started →
        </motion.button>
      </motion.div>

      {/* Keyhole Reveal Overlay - Top Layer */}
      <motion.div
        initial={{ clipPath: 'circle(3% at 50% 45%)' }}
        animate={{ clipPath: 'circle(150% at 50% 50%)' }}
        transition={{
          duration: 1.5,
          delay: 0.2,
          ease: [0.16, 1, 0.3, 1],
        }}
        className="absolute inset-0 bg-black z-10 pointer-events-none"
      >
        {/* Keyhole icon that fades as it expands */}
        <motion.div
          initial={{ opacity: 1, scale: 1 }}
          animate={{ opacity: 0, scale: 0.5 }}
          transition={{ duration: 0.4, delay: 0.3 }}
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2"
        >
          <div className="text-white/60 text-6xl">🔑</div>
        </motion.div>
      </motion.div>
    </div>
  );
}
