'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';

interface LocationStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function LocationStep({ data, onNext, isSaving }: LocationStepProps) {
  const [selected, setSelected] = useState<string | null>(
    data.location || null
  );

  const cities = [
    {
      id: 'new_york_city',
      name: 'New York City',
      icon: '🗽',
      gradient: 'from-blue-500 to-cyan-500',
    },
    {
      id: 'chicago',
      name: 'Chicago',
      icon: '🌆',
      gradient: 'from-red-500 to-orange-500',
    },
    {
      id: 'los_angeles',
      name: 'Los Angeles',
      icon: '🌴',
      gradient: 'from-yellow-500 to-pink-500',
    },
    {
      id: 'miami',
      name: 'Miami',
      icon: '🏖️',
      gradient: 'from-pink-500 to-purple-500',
    },
  ];

  const handleSelect = (cityId: string) => {
    setSelected(cityId);
  };

  const handleContinue = () => {
    if (selected) {
      onNext({
        location: selected as 'new_york_city' | 'chicago' | 'los_angeles' | 'miami',
      });
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, x: 50 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -50 }}
      transition={{ duration: 0.5 }}
      className="w-full max-w-3xl mx-auto pt-12"
    >
      {/* Question */}
      <motion.h2
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.1, duration: 0.5 }}
        className="text-4xl md:text-5xl font-light text-white text-center mb-4"
        style={{ fontFamily: 'Playfair Display, serif' }}
      >
        Where are you looking?
      </motion.h2>

      <motion.p
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        className="text-white/60 text-center mb-12 text-lg"
      >
        Choose your city
      </motion.p>

      {/* City Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
        {cities.map((city, index) => (
          <motion.button
            key={city.id}
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.3 + index * 0.1, duration: 0.5 }}
            onClick={() => handleSelect(city.id)}
            className={`relative p-8 rounded-3xl text-left transition-all transform overflow-hidden ${
              selected === city.id
                ? 'scale-105 shadow-2xl'
                : 'glass-strong hover:bg-white/10'
            }`}
          >
            {/* Gradient Background (when selected) */}
            {selected === city.id && (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className={`absolute inset-0 bg-gradient-to-br ${city.gradient} opacity-90`}
              />
            )}

            {/* Content */}
            <div className="relative z-10">
              <div className="text-6xl mb-3">{city.icon}</div>
              <h3 className="text-2xl font-bold text-white mb-1">
                {city.name}
              </h3>
              {selected === city.id && (
                <motion.div
                  initial={{ scale: 0, opacity: 0 }}
                  animate={{ scale: 1, opacity: 1 }}
                  transition={{ delay: 0.1 }}
                  className="absolute top-8 right-8 text-3xl"
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
