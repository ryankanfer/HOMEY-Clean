'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';

interface VibeCheckStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function VibeCheckStep({ data, onNext, isSaving }: VibeCheckStepProps) {
  const [selected, setSelected] = useState<'true' | 'false' | null>(null);
  const [showFeedback, setShowFeedback] = useState(false);

  // Map door selection to vibe description
  const getDoorVibe = () => {
    const doorSelection = data.doorSelection;

    const doorVibes: Record<string, { entrance: string; vibe: string }> = {
      classic: { entrance: 'a refined soul through the Classic door', vibe: 'timeless and grounded' },
      french: { entrance: 'like a queen through the French doors', vibe: 'elegant and sophisticated' },
      elevator: { entrance: 'ascending through the Elevator', vibe: 'modern and upward-moving' },
      loft: { entrance: 'into the Loft', vibe: 'creative and bold' },
      vault: { entrance: 'through the Vault', vibe: 'secure and discerning' },
      shoji: { entrance: 'through the Shoji screen', vibe: 'zen and intentional' },
    };

    const doorVibe = doorVibes[doorSelection || 'classic'];
    return doorVibe || { entrance: 'through your chosen entrance', vibe: 'unique and authentic' };
  };

  const doorVibe = getDoorVibe();

  const handleSelect = (choice: 'true' | 'false') => {
    setSelected(choice);
    setShowFeedback(true);

    // Auto-advance after showing feedback
    setTimeout(() => {
      onNext({
        vibeConfirmed: choice === 'true',
        stylePreference: choice === 'true' ? 'confirmed' : 'exploratory'
      });
    }, 2000);
  };

  return (
    <motion.div
      initial={{ opacity: 0, x: 50 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -50 }}
      transition={{ duration: 0.5 }}
      className="w-full max-w-2xl mx-auto px-4"
    >
      <AnimatePresence mode="wait">
        {!showFeedback ? (
          <motion.div
            key="question"
            initial={{ opacity: 1 }}
            exit={{ opacity: 0, scale: 0.95 }}
            transition={{ duration: 0.3 }}
          >
            {/* Question */}
            <motion.h2
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: 0.1, duration: 0.5 }}
              className="text-3xl md:text-4xl font-serif text-white text-center mb-6 leading-tight"
              style={{ fontFamily: 'Playfair Display, serif' }}
            >
              Since you chose to enter {doorVibe.entrance}, HOMEY sees your vibe as {doorVibe.vibe}.
            </motion.h2>

            <motion.p
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: 0.2, duration: 0.5 }}
              className="text-white/60 text-center mb-12 text-xl font-serif"
              style={{ fontFamily: 'Playfair Display, serif' }}
            >
              True or False?
            </motion.p>

            {/* True/False Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
              {/* True Card */}
              <motion.button
                initial={{ x: -20, opacity: 0 }}
                animate={{ x: 0, opacity: 1 }}
                transition={{ delay: 0.3, duration: 0.5 }}
                onClick={() => handleSelect('true')}
                disabled={isSaving}
                className="group relative p-8 rounded-3xl text-center transition-all transform hover:scale-105 overflow-hidden shadow-2xl"
              >
                {/* Background Gradient */}
                <div className="absolute inset-0 bg-gradient-to-br from-emerald-500 to-teal-600 opacity-90 group-hover:opacity-100 transition-opacity" />

                {/* Glass overlay */}
                <div className="absolute inset-0 bg-white/5 backdrop-blur-sm" />

                {/* Content */}
                <div className="relative z-10">
                  <div className="text-7xl mb-4">✓</div>
                  <h3 className="text-3xl font-bold text-white mb-2">True</h3>
                  <p className="text-white/80 text-sm">That's me!</p>
                </div>
              </motion.button>

              {/* False Card */}
              <motion.button
                initial={{ x: 20, opacity: 0 }}
                animate={{ x: 0, opacity: 1 }}
                transition={{ delay: 0.4, duration: 0.5 }}
                onClick={() => handleSelect('false')}
                disabled={isSaving}
                className="group relative p-8 rounded-3xl text-center transition-all transform hover:scale-105 overflow-hidden shadow-2xl"
              >
                {/* Background Gradient */}
                <div className="absolute inset-0 bg-gradient-to-br from-rose-500 to-pink-600 opacity-90 group-hover:opacity-100 transition-opacity" />

                {/* Glass overlay */}
                <div className="absolute inset-0 bg-white/5 backdrop-blur-sm" />

                {/* Content */}
                <div className="relative z-10">
                  <div className="text-7xl mb-4">✗</div>
                  <h3 className="text-3xl font-bold text-white mb-2">False</h3>
                  <p className="text-white/80 text-sm">Not quite</p>
                </div>
              </motion.button>
            </div>
          </motion.div>
        ) : (
          <motion.div
            key="feedback"
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.5, type: 'spring' }}
            className="text-center py-20"
          >
            {selected === 'true' ? (
              <>
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ delay: 0.2, type: 'spring', stiffness: 200 }}
                  className="text-8xl mb-6"
                >
                  💚
                </motion.div>
                <motion.h2
                  initial={{ y: 20, opacity: 0 }}
                  animate={{ y: 0, opacity: 1 }}
                  transition={{ delay: 0.3 }}
                  className="text-4xl font-serif text-white mb-4"
                  style={{ fontFamily: 'Playfair Display, serif' }}
                >
                  Already connecting
                </motion.h2>
                <motion.p
                  initial={{ y: 20, opacity: 0 }}
                  animate={{ y: 0, opacity: 1 }}
                  transition={{ delay: 0.4 }}
                  className="text-white/60 text-xl"
                >
                  Loves it
                </motion.p>
              </>
            ) : (
              <>
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ delay: 0.2, type: 'spring', stiffness: 200 }}
                  className="text-8xl mb-6"
                >
                  ✨
                </motion.div>
                <motion.h2
                  initial={{ y: 20, opacity: 0 }}
                  animate={{ y: 0, opacity: 1 }}
                  transition={{ delay: 0.3 }}
                  className="text-4xl font-serif text-white mb-4"
                  style={{ fontFamily: 'Playfair Display, serif' }}
                >
                  My bad!
                </motion.h2>
                <motion.p
                  initial={{ y: 20, opacity: 0 }}
                  animate={{ y: 0, opacity: 1 }}
                  transition={{ delay: 0.4 }}
                  className="text-white/60 text-xl"
                >
                  You know what that means? Can't wait to get to know you
                </motion.p>
              </>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}
