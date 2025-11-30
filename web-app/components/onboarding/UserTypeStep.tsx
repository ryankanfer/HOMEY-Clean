'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';

interface UserTypeStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function UserTypeStep({ data, onNext, isSaving }: UserTypeStepProps) {
  const [selected, setSelected] = useState<'renter' | 'buyer' | 'browser' | null>(
    data.userType || null
  );

  const options = [
    {
      id: 'renter' as const,
      icon: '🔑',
      title: 'Renter',
      description: 'Looking for a place to rent',
    },
    {
      id: 'buyer' as const,
      icon: '🏠',
      title: 'Buyer',
      description: 'Ready to purchase a home',
    },
    {
      id: 'browser' as const,
      icon: '👀',
      title: 'Just Browsing',
      description: 'Here for the real estate porn',
    },
  ];

  const handleSelect = (type: 'renter' | 'buyer' | 'browser') => {
    setSelected(type);
  };

  const handleContinue = () => {
    if (selected) {
      onNext({ userType: selected });
    }
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
        What brings you here?
      </motion.h2>

      <motion.p
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        className="text-white/60 text-center mb-12 text-lg"
      >
        This helps us personalize your experience
      </motion.p>

      {/* Options */}
      <div className="space-y-4 mb-8">
        {options.map((option, index) => (
          <motion.button
            key={option.id}
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.3 + index * 0.1, duration: 0.5 }}
            onClick={() => handleSelect(option.id)}
            className={`w-full p-6 rounded-2xl text-left transition-all transform ${
              selected === option.id
                ? 'bg-gradient-to-r from-primary to-purple-500 text-white scale-105 shadow-2xl shadow-primary/30'
                : 'glass-strong text-white hover:bg-white/10'
            }`}
          >
            <div className="flex items-center gap-4">
              <div className="text-5xl">{option.icon}</div>
              <div className="flex-1">
                <h3 className="text-xl font-bold mb-1">{option.title}</h3>
                <p
                  className={`text-sm ${
                    selected === option.id ? 'text-white/90' : 'text-white/60'
                  }`}
                >
                  {option.description}
                </p>
              </div>
              {selected === option.id && (
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  className="text-2xl"
                >
                  ✓
                </motion.div>
              )}
            </div>
          </motion.button>
        ))}
      </div>

      {/* Continue Button */}
      {selected && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3 }}
          className="text-center"
        >
          <button
            onClick={handleContinue}
            disabled={isSaving}
            className="px-10 py-4 bg-white text-black rounded-full font-bold text-lg hover:shadow-2xl hover:shadow-white/20 transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isSaving ? 'Saving...' : 'Continue →'}
          </button>
        </motion.div>
      )}
    </motion.div>
  );
}
