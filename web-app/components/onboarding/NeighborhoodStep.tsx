'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';

interface NeighborhoodStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function NeighborhoodStep({ data, onNext, isSaving }: NeighborhoodStepProps) {
  const [input, setInput] = useState<string>(
    data.neighborhoods?.join(', ') || ''
  );

  const handleContinue = () => {
    const neighborhoods = input
      .split(',')
      .map(n => n.trim())
      .filter(n => n.length > 0);

    onNext({ neighborhoods });
  };

  const handleSkip = () => {
    onNext({ neighborhoods: [] });
  };

  return (
    <motion.div
      initial={{ opacity: 0, x: 50 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -50 }}
      transition={{ duration: 0.5 }}
      className="w-full max-w-2xl mx-auto"
    >
      {/* Question */}
      <motion.h2
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.1, duration: 0.5 }}
        className="text-4xl md:text-5xl font-light text-white text-center mb-4"
        style={{ fontFamily: 'Playfair Display, serif' }}
      >
        Any neighborhood preferences?
      </motion.h2>

      <motion.p
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        className="text-white/60 text-center mb-12 text-lg"
      >
        Enter neighborhood names, separated by commas
      </motion.p>

      {/* Input */}
      <motion.div
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.3, duration: 0.5 }}
        className="mb-8"
      >
        <textarea
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="e.g. SoHo, West Village, Tribeca"
          rows={4}
          className="w-full px-6 py-4 bg-white/10 backdrop-blur-sm rounded-2xl text-white placeholder-white/40 focus:outline-none focus:ring-2 focus:ring-primary border border-white/20 resize-none"
          style={{ fontSize: '18px' }}
        />

        {input.length > 0 && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="mt-3 flex flex-wrap gap-2"
          >
            {input.split(',').map((neighborhood, index) => {
              const trimmed = neighborhood.trim();
              if (!trimmed) return null;
              return (
                <span
                  key={index}
                  className="px-3 py-1 bg-primary/20 backdrop-blur-sm text-white text-sm rounded-full border border-primary/40"
                >
                  {trimmed}
                </span>
              );
            })}
          </motion.div>
        )}
      </motion.div>

      {/* Buttons */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4, duration: 0.5 }}
        className="flex flex-col sm:flex-row gap-4 justify-center items-center"
      >
        <button
          onClick={handleSkip}
          disabled={isSaving}
          className="px-8 py-3 text-white/60 hover:text-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Skip for now
        </button>

        <button
          onClick={handleContinue}
          disabled={isSaving || input.trim().length === 0}
          className="px-10 py-4 bg-white text-black rounded-full font-bold text-lg hover:shadow-2xl hover:shadow-white/20 transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {isSaving ? 'Saving...' : 'Continue →'}
        </button>
      </motion.div>

      {/* Helper text */}
      <motion.p
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.5, duration: 0.5 }}
        className="text-white/40 text-sm text-center mt-6"
      >
        Don't worry, you can always refine this later
      </motion.p>
    </motion.div>
  );
}
