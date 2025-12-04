'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';

interface CrewStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function CrewStep({ data, onNext, isSaving }: CrewStepProps) {
  const [selected, setSelected] = useState<string | null>(null);

  const crewOptions = [
    {
      id: 'solo',
      icon: '🧘',
      title: 'Just me',
      description: 'Flying solo, living my best life',
      bedrooms: 0, // Studio
      bathrooms: 1,
    },
    {
      id: 'couple',
      icon: '💑',
      title: 'Me + my partner',
      description: 'Two hearts, one home',
      bedrooms: 1,
      bathrooms: 1,
    },
    {
      id: 'roommates',
      icon: '👥',
      title: 'Me + roommate(s)',
      description: 'Splitting rent, sharing vibes',
      bedrooms: 2,
      bathrooms: 2,
    },
    {
      id: 'small-family',
      icon: '👨‍👩‍👧',
      title: 'Small family',
      description: '1-2 kids, need some breathing room',
      bedrooms: 2,
      bathrooms: 2,
    },
    {
      id: 'family',
      icon: '👨‍👩‍👧‍👦',
      title: 'Growing family',
      description: '3+ people, the more the merrier',
      bedrooms: 3,
      bathrooms: 2,
    },
    {
      id: 'custom',
      icon: '✨',
      title: 'Let me choose',
      description: 'I know exactly what I need',
      bedrooms: null, // Will show detailed selector
      bathrooms: null,
    },
  ];

  const [customBedrooms, setCustomBedrooms] = useState<number | null>(data.bedrooms || null);
  const [customBathrooms, setCustomBathrooms] = useState<number | null>(data.bathrooms || null);
  const [showCustomSelector, setShowCustomSelector] = useState(false);

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

  const handleSelect = (optionId: string) => {
    setSelected(optionId);
    if (optionId === 'custom') {
      setShowCustomSelector(true);
    } else {
      setShowCustomSelector(false);
    }
  };

  const handleContinue = () => {
    if (!selected) return;

    if (selected === 'custom') {
      if (customBedrooms !== null && customBathrooms !== null) {
        onNext({
          bedrooms: customBedrooms,
          bathrooms: customBathrooms,
          householdType: selected
        });
      }
    } else {
      const selectedOption = crewOptions.find(opt => opt.id === selected);
      if (selectedOption && selectedOption.bedrooms !== null && selectedOption.bathrooms !== null) {
        onNext({
          bedrooms: selectedOption.bedrooms,
          bathrooms: selectedOption.bathrooms,
          householdType: selected
        });
      }
    }
  };

  const isValid = selected && (
    selected !== 'custom' || (customBedrooms !== null && customBathrooms !== null)
  );

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
        Who's coming with you?
      </motion.h2>

      <motion.p
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        className="text-white/60 text-center mb-12 text-lg"
      >
        Tell me about your crew so I can find the right size
      </motion.p>

      {/* Crew Options */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
        {crewOptions.map((option, index) => (
          <motion.button
            key={option.id}
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.3 + index * 0.08, duration: 0.5 }}
            onClick={() => handleSelect(option.id)}
            className={`p-6 rounded-2xl text-left transition-all transform ${
              selected === option.id
                ? 'bg-gradient-to-r from-primary to-purple-500 text-white scale-105 shadow-2xl shadow-primary/30'
                : 'glass-strong text-white hover:bg-white/10'
            }`}
          >
            <div className="flex items-start gap-4">
              <div className="text-4xl flex-shrink-0">{option.icon}</div>
              <div className="flex-1">
                <h3 className="text-lg font-bold mb-1">{option.title}</h3>
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
                  className="text-2xl flex-shrink-0"
                >
                  ✓
                </motion.div>
              )}
            </div>
          </motion.button>
        ))}
      </div>

      {/* Custom Selector (if "Let me choose" is selected) */}
      {showCustomSelector && (
        <motion.div
          initial={{ opacity: 0, height: 0 }}
          animate={{ opacity: 1, height: 'auto' }}
          transition={{ duration: 0.4 }}
          className="space-y-8 mb-8"
        >
          {/* Bedrooms */}
          <div>
            <h3 className="text-white text-lg font-semibold mb-4 text-center">Bedrooms</h3>
            <div className="grid grid-cols-5 gap-3">
              {bedroomOptions.map((option, index) => (
                <motion.button
                  key={option.value}
                  initial={{ y: 20, opacity: 0 }}
                  animate={{ y: 0, opacity: 1 }}
                  transition={{ delay: index * 0.05, duration: 0.3 }}
                  onClick={() => setCustomBedrooms(option.value)}
                  className={`p-6 rounded-2xl text-center transition-all transform ${
                    customBedrooms === option.value
                      ? 'bg-gradient-to-br from-primary to-purple-500 text-white scale-105 shadow-xl shadow-primary/30'
                      : 'glass-strong text-white hover:bg-white/10'
                  }`}
                >
                  <div className="text-2xl font-bold mb-1">{option.value === 0 ? 'S' : option.value}</div>
                  <div className="text-xs opacity-80">{option.label}</div>
                </motion.button>
              ))}
            </div>
          </div>

          {/* Bathrooms */}
          <div>
            <h3 className="text-white text-lg font-semibold mb-4 text-center">Bathrooms</h3>
            <div className="grid grid-cols-5 gap-3">
              {bathroomOptions.map((option, index) => (
                <motion.button
                  key={option.value}
                  initial={{ y: 20, opacity: 0 }}
                  animate={{ y: 0, opacity: 1 }}
                  transition={{ delay: index * 0.05, duration: 0.3 }}
                  onClick={() => setCustomBathrooms(option.value)}
                  className={`p-6 rounded-2xl text-center transition-all transform ${
                    customBathrooms === option.value
                      ? 'bg-gradient-to-br from-primary to-purple-500 text-white scale-105 shadow-xl shadow-primary/30'
                      : 'glass-strong text-white hover:bg-white/10'
                  }`}
                >
                  <div className="text-2xl font-bold mb-1">{option.value}</div>
                  <div className="text-xs opacity-80">{option.label}</div>
                </motion.button>
              ))}
            </div>
          </div>
        </motion.div>
      )}

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
