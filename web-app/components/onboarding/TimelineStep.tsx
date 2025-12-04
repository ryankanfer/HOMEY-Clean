'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';

interface TimelineStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function TimelineStep({ data, onNext, isSaving }: TimelineStepProps) {
  const [selected, setSelected] = useState<string | null>(data.timeline || null);

  const timelineOptions = [
    {
      id: 'urgent',
      icon: '🔥',
      title: 'I need a place yesterday',
      description: 'ASAP, moving in the next 2 weeks',
      urgency: 'urgent',
    },
    {
      id: 'soon',
      icon: '⚡',
      title: 'Pretty soon',
      description: 'Within the next month',
      urgency: 'soon',
    },
    {
      id: 'flexible',
      icon: '📅',
      title: 'Got some time',
      description: '1-3 months, no huge rush',
      urgency: 'flexible',
    },
    {
      id: 'browsing',
      icon: '🌙',
      title: 'Just browsing',
      description: 'Dreaming and scheming for now',
      urgency: 'browsing',
    },
  ];

  const handleSelect = (timelineId: string) => {
    setSelected(timelineId);
  };

  const handleContinue = () => {
    if (selected) {
      onNext({ timeline: selected });
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
        When do you need to move?
      </motion.h2>

      <motion.p
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        className="text-white/60 text-center mb-12 text-lg"
      >
        This helps me prioritize what to show you first
      </motion.p>

      {/* Timeline Options */}
      <div className="space-y-4 mb-8">
        {timelineOptions.map((option, index) => (
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
