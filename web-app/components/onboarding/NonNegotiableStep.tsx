'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';

interface NonNegotiableStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function NonNegotiableStep({ data, onNext, isSaving }: NonNegotiableStepProps) {
  const [selected, setSelected] = useState<string | null>(data.mustHave || null);

  const mustHaveOptions = [
    {
      id: 'laundry',
      icon: '🧺',
      title: 'In-unit laundry',
      description: 'No more laundromat runs, ever',
      dealbreaker: true,
    },
    {
      id: 'pets',
      icon: '🐕',
      title: 'Pet-friendly',
      description: 'My fur baby comes first',
      dealbreaker: true,
    },
    {
      id: 'outdoor',
      icon: '🌿',
      title: 'Outdoor space',
      description: 'Balcony, patio, or yard—need fresh air',
      dealbreaker: true,
    },
    {
      id: 'parking',
      icon: '🚗',
      title: 'Parking spot',
      description: 'Street parking is not an option',
      dealbreaker: true,
    },
    {
      id: 'natural-light',
      icon: '☀️',
      title: 'Natural light',
      description: 'Big windows, sunshine, good vibes',
      dealbreaker: true,
    },
    {
      id: 'modern-kitchen',
      icon: '👨‍🍳',
      title: 'Modern kitchen',
      description: 'Updated appliances and counters',
      dealbreaker: true,
    },
    {
      id: 'walkability',
      icon: '🚶',
      title: 'Walkability',
      description: 'Coffee, groceries, life—all on foot',
      dealbreaker: true,
    },
    {
      id: 'gym',
      icon: '🏋️',
      title: 'Gym/fitness',
      description: 'In-building gym or nearby access',
      dealbreaker: true,
    },
    {
      id: 'flexible',
      icon: '🤷',
      title: 'Pretty flexible',
      description: 'I can compromise on most things',
      dealbreaker: false,
    },
  ];

  const handleSelect = (optionId: string) => {
    setSelected(optionId);
  };

  const handleContinue = () => {
    if (selected) {
      onNext({ mustHave: selected });
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, x: 50 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -50 }}
      transition={{ duration: 0.5 }}
      className="w-full max-w-4xl mx-auto"
    >
      {/* Question */}
      <motion.h2
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.1, duration: 0.5 }}
        className="text-4xl md:text-5xl font-light text-white text-center mb-4"
        style={{ fontFamily: 'Playfair Display, serif' }}
      >
        What's your non-negotiable?
      </motion.h2>

      <motion.p
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        className="text-white/60 text-center mb-12 text-lg"
      >
        The ONE thing you absolutely can't live without
      </motion.p>

      {/* Options Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
        {mustHaveOptions.map((option, index) => (
          <motion.button
            key={option.id}
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.3 + index * 0.05, duration: 0.4 }}
            onClick={() => handleSelect(option.id)}
            className={`p-6 rounded-2xl text-left transition-all transform ${
              selected === option.id
                ? 'bg-gradient-to-r from-primary to-purple-500 text-white scale-105 shadow-2xl shadow-primary/30'
                : 'glass-strong text-white hover:bg-white/10'
            }`}
          >
            <div className="flex flex-col gap-3">
              {/* Icon */}
              <div className="text-4xl">{option.icon}</div>

              {/* Title */}
              <h3 className="text-lg font-bold">{option.title}</h3>

              {/* Description */}
              <p
                className={`text-sm ${
                  selected === option.id ? 'text-white/90' : 'text-white/60'
                }`}
              >
                {option.description}
              </p>

              {/* Check Mark */}
              {selected === option.id && (
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  className="absolute top-4 right-4 text-2xl"
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
