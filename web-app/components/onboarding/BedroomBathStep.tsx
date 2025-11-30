'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';

interface BedroomBathStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function BedroomBathStep({ data, onNext, isSaving }: BedroomBathStepProps) {
  const [bedrooms, setBedrooms] = useState<number | null>(data.bedrooms || null);
  const [bathrooms, setBathrooms] = useState<number | null>(data.bathrooms || null);

  const bedroomOptions = [
    { value: 0, label: 'Studio' },
    { value: 1, label: '1 BR' },
    { value: 2, label: '2 BR' },
    { value: 3, label: '3 BR' },
    { value: 4, label: '4+ BR' },
  ];

  const bathroomOptions = [
    { value: 1, label: '1 BA' },
    { value: 1.5, label: '1.5 BA' },
    { value: 2, label: '2 BA' },
    { value: 2.5, label: '2.5 BA' },
    { value: 3, label: '3+ BA' },
  ];

  const handleContinue = () => {
    if (bedrooms !== null && bathrooms !== null) {
      onNext({ bedrooms, bathrooms });
    }
  };

  const isValid = bedrooms !== null && bathrooms !== null;

  return (
    <motion.div
      initial={{ opacity: 0, x: 50 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -50 }}
      transition={{ duration: 0.5 }}
      className="w-full max-w-3xl mx-auto"
    >
      {/* Question */}
      <motion.h2
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.1, duration: 0.5 }}
        className="text-4xl md:text-5xl font-light text-white text-center mb-4"
        style={{ fontFamily: 'Playfair Display, serif' }}
      >
        How much space do you need?
      </motion.h2>

      <motion.p
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        className="text-white/60 text-center mb-12 text-lg"
      >
        Select bedrooms and bathrooms
      </motion.p>

      {/* Bedrooms */}
      <motion.div
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.3, duration: 0.5 }}
        className="mb-10"
      >
        <h3 className="text-white text-lg font-semibold mb-4 text-center">Bedrooms</h3>
        <div className="grid grid-cols-5 gap-3">
          {bedroomOptions.map((option, index) => (
            <motion.button
              key={option.value}
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: 0.35 + index * 0.05, duration: 0.4 }}
              onClick={() => setBedrooms(option.value)}
              className={`p-6 rounded-2xl text-center transition-all transform ${
                bedrooms === option.value
                  ? 'bg-gradient-to-br from-primary to-purple-500 text-white scale-105 shadow-xl shadow-primary/30'
                  : 'glass-strong text-white hover:bg-white/10'
              }`}
            >
              <div className="text-2xl font-bold mb-1">{option.value === 0 ? 'S' : option.value}</div>
              <div className="text-xs opacity-80">{option.label}</div>
            </motion.button>
          ))}
        </div>
      </motion.div>

      {/* Bathrooms */}
      <motion.div
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.5, duration: 0.5 }}
        className="mb-10"
      >
        <h3 className="text-white text-lg font-semibold mb-4 text-center">Bathrooms</h3>
        <div className="grid grid-cols-5 gap-3">
          {bathroomOptions.map((option, index) => (
            <motion.button
              key={option.value}
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: 0.55 + index * 0.05, duration: 0.4 }}
              onClick={() => setBathrooms(option.value)}
              className={`p-6 rounded-2xl text-center transition-all transform ${
                bathrooms === option.value
                  ? 'bg-gradient-to-br from-primary to-purple-500 text-white scale-105 shadow-xl shadow-primary/30'
                  : 'glass-strong text-white hover:bg-white/10'
              }`}
            >
              <div className="text-2xl font-bold mb-1">{option.value}</div>
              <div className="text-xs opacity-80">{option.label}</div>
            </motion.button>
          ))}
        </div>
      </motion.div>

      {/* Continue Button */}
      {isValid && (
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
