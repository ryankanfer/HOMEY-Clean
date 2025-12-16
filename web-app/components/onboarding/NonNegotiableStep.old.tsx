'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';

interface NonNegotiableStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

// This or That comparison choices
const thisOrThatChoices = [
  {
    id: 'laundry_gym',
    optionA: { icon: '🧺', label: 'In-unit laundry', value: 'in_unit_laundry' },
    optionB: { icon: '🏋️', label: 'In-building gym', value: 'building_gym' }
  },
  {
    id: 'location_transit',
    optionA: { icon: '🤫', label: 'Quiet neighborhood', value: 'quiet' },
    optionB: { icon: '🚇', label: 'Near the train', value: 'near_train' }
  },
  {
    id: 'light_storage',
    optionA: { icon: '☀️', label: 'Natural light', value: 'natural_light' },
    optionB: { icon: '📦', label: 'Extra storage', value: 'extra_storage' }
  },
];

export default function NonNegotiableStep({ data, onNext, isSaving }: NonNegotiableStepProps) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [preferences, setPreferences] = useState<Record<string, string>>({});

  const currentChoice = thisOrThatChoices[currentIndex];
  const isLastChoice = currentIndex === thisOrThatChoices.length - 1;
  const progress = ((currentIndex + 1) / thisOrThatChoices.length) * 100;

  const handleChoice = (value: string) => {
    const newPreferences = { ...preferences, [currentChoice.id]: value };
    setPreferences(newPreferences);

    if (isLastChoice) {
      // All choices made, proceed to next step
      onNext({ mustHave: JSON.stringify(newPreferences) });
    } else {
      // Move to next choice after a brief delay
      setTimeout(() => {
        setCurrentIndex(prev => prev + 1);
      }, 300);
    }
  };

  const handleSkip = () => {
    if (isLastChoice) {
      onNext({ mustHave: JSON.stringify(preferences) });
    } else {
      setCurrentIndex(prev => prev + 1);
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, x: 50 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -50 }}
      transition={{ duration: 0.5 }}
      className="w-full max-w-3xl mx-auto"
    >
      {/* Progress Bar */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        className="mb-8"
      >
        <div className="w-full h-2 bg-white/10 rounded-full overflow-hidden">
          <motion.div
            initial={{ width: 0 }}
            animate={{ width: `${progress}%` }}
            transition={{ duration: 0.5 }}
            className="h-full bg-gradient-to-r from-purple-500 to-pink-500"
          />
        </div>
        <p className="text-white/60 text-sm text-center mt-2">
          {currentIndex + 1} of {thisOrThatChoices.length}
        </p>
      </motion.div>

      {/* Question */}
      <motion.h2
        key={`header-${currentIndex}`}
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.1, duration: 0.5 }}
        className="text-4xl md:text-5xl font-light text-white text-center mb-4"
        style={{ fontFamily: 'Playfair Display, serif' }}
      >
        This or that?
      </motion.h2>

      <motion.p
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        className="text-white/60 text-center mb-12 text-lg"
      >
        Help us understand your priorities
      </motion.p>

      {/* Choice Buttons */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        <motion.button
          key={`optionA-${currentIndex}`}
          initial={{ x: -50, opacity: 0 }}
          animate={{ x: 0, opacity: 1 }}
          transition={{ delay: 0.3, duration: 0.5 }}
          onClick={() => handleChoice(currentChoice.optionA.value)}
          className="group relative p-8 rounded-3xl bg-gradient-to-br from-slate-900/95 to-slate-800/95 backdrop-blur-xl border border-white/10 hover:border-purple-500/50 transition-all transform hover:scale-105 hover:shadow-2xl hover:shadow-purple-500/20"
        >
          {/* Icon */}
          <div className="text-7xl mb-4 transform group-hover:scale-110 transition-transform">
            {currentChoice.optionA.icon}
          </div>

          {/* Label */}
          <h3 className="text-2xl font-bold text-white mb-2 group-hover:text-purple-300 transition-colors">
            {currentChoice.optionA.label}
          </h3>

          {/* Hover Indicator */}
          <div className="absolute bottom-6 left-1/2 -translate-x-1/2 opacity-0 group-hover:opacity-100 transition-opacity">
            <div className="px-4 py-2 bg-purple-500 text-white rounded-full text-sm font-semibold">
              Choose this →
            </div>
          </div>
        </motion.button>

        <motion.button
          key={`optionB-${currentIndex}`}
          initial={{ x: 50, opacity: 0 }}
          animate={{ x: 0, opacity: 1 }}
          transition={{ delay: 0.3, duration: 0.5 }}
          onClick={() => handleChoice(currentChoice.optionB.value)}
          className="group relative p-8 rounded-3xl bg-gradient-to-br from-slate-900/95 to-slate-800/95 backdrop-blur-xl border border-white/10 hover:border-pink-500/50 transition-all transform hover:scale-105 hover:shadow-2xl hover:shadow-pink-500/20"
        >
          {/* Icon */}
          <div className="text-7xl mb-4 transform group-hover:scale-110 transition-transform">
            {currentChoice.optionB.icon}
          </div>

          {/* Label */}
          <h3 className="text-2xl font-bold text-white mb-2 group-hover:text-pink-300 transition-colors">
            {currentChoice.optionB.label}
          </h3>

          {/* Hover Indicator */}
          <div className="absolute bottom-6 left-1/2 -translate-x-1/2 opacity-0 group-hover:opacity-100 transition-opacity">
            <div className="px-4 py-2 bg-pink-500 text-white rounded-full text-sm font-semibold">
              Choose this →
            </div>
          </div>
        </motion.button>
      </div>

      {/* Skip Button */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.5 }}
        className="text-center"
      >
        <button
          onClick={handleSkip}
          disabled={isSaving}
          className="px-8 py-3 text-white/60 hover:text-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Skip this one
        </button>
      </motion.div>
    </motion.div>
  );
}
