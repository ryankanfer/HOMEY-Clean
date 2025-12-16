'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';
import { Home, Bath } from 'lucide-react';

interface CrewStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function CrewStep({ data, onNext, isSaving }: CrewStepProps) {
  const [bedrooms, setBedrooms] = useState<number | null>(data.bedrooms !== undefined ? data.bedrooms : null);
  const [bathrooms, setBathrooms] = useState<number | null>(data.bathrooms !== undefined ? data.bathrooms : null);

  const bedroomOptions = [
    { value: 0, label: 'Studio', description: 'One open space' },
    { value: 1, label: '1 Bed', description: 'Perfect for one' },
    { value: 2, label: '2 Beds', description: 'Room to spare' },
    { value: 3, label: '3 Beds', description: 'Family-sized' },
    { value: 4, label: '4+ Beds', description: 'Plenty of space' },
  ];

  const bathroomOptions = [
    { value: 1, label: '1 Bath' },
    { value: 1.5, label: '1.5 Baths' },
    { value: 2, label: '2 Baths' },
    { value: 2.5, label: '2.5 Baths' },
    { value: 3, label: '3+ Baths' },
  ];

  const handleContinue = () => {
    if (bedrooms !== null && bathrooms !== null) {
      onNext({
        bedrooms,
        bathrooms,
      });
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
        Select your ideal bedroom and bathroom count
      </motion.p>

      {/* Bedrooms Section */}
      <motion.div
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.3, duration: 0.5 }}
        className="mb-8"
      >
        <div className="flex items-center justify-center gap-2 mb-4">
          <Home className="w-5 h-5 text-white/60" />
          <h3 className="text-white text-lg font-medium">Bedrooms</h3>
        </div>

        <div className="flex justify-center gap-2 flex-wrap">
          {bedroomOptions.map((option, index) => (
            <motion.button
              key={option.value}
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: 0.4 + index * 0.05, duration: 0.4 }}
              onClick={() => setBedrooms(option.value)}
              className={`px-6 py-3 rounded-full text-center transition-all ${
                bedrooms === option.value
                  ? 'bg-gradient-to-br from-purple-500 to-pink-500 text-white shadow-lg'
                  : 'glass-strong text-white/80 hover:bg-white/10'
              }`}
            >
              <div className="text-sm font-semibold">
                {option.label}
              </div>
            </motion.button>
          ))}
        </div>
      </motion.div>

      {/* Bathrooms Section */}
      <motion.div
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.5, duration: 0.5 }}
        className="mb-10"
      >
        <div className="flex items-center justify-center gap-2 mb-4">
          <Bath className="w-5 h-5 text-white/60" />
          <h3 className="text-white text-lg font-medium">Bathrooms</h3>
        </div>

        <div className="flex justify-center gap-2 flex-wrap">
          {bathroomOptions.map((option, index) => (
            <motion.button
              key={option.value}
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: 0.6 + index * 0.05, duration: 0.4 }}
              onClick={() => setBathrooms(option.value)}
              className={`px-6 py-3 rounded-full text-center transition-all ${
                bathrooms === option.value
                  ? 'bg-gradient-to-br from-cyan-500 to-blue-500 text-white shadow-lg'
                  : 'glass-strong text-white/80 hover:bg-white/10'
              }`}
            >
              <div className="text-sm font-semibold">
                {option.label}
              </div>
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
