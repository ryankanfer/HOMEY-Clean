'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';

interface NonNegotiableStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function NonNegotiableStep({ data, onNext, isSaving }: NonNegotiableStepProps) {
  const [selected, setSelected] = useState<string | null>(data.mustHave || null);
  const [showTutorial, setShowTutorial] = useState(!data.mustHave); // Show tutorial on first visit

  const priorityOptions = [
    {
      id: 'natural-light',
      icon: '☀️',
      title: 'Natural Light',
      gradient: 'from-yellow-400 to-orange-500',
    },
    {
      id: 'location',
      icon: '📍',
      title: 'Location',
      gradient: 'from-blue-500 to-cyan-500',
    },
    {
      id: 'condition',
      icon: '✨',
      title: 'Condition',
      gradient: 'from-purple-500 to-pink-500',
    },
    {
      id: 'layout',
      icon: '🏠',
      title: 'Layout',
      gradient: 'from-green-500 to-teal-500',
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
        Quick, which one matters most?
      </motion.h2>

      <motion.p
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        className="text-white/60 text-center mb-8 text-lg"
      >
        If you had to pick just one priority
      </motion.p>

      {/* Interactive Tutorial Intro */}
      <AnimatePresence>
        {showTutorial && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="mb-8 mx-auto max-w-xl"
          >
            <div
              className="rounded-2xl p-6 backdrop-blur-xl"
              style={{
                background: 'rgba(255, 255, 255, 0.08)',
                border: '1.5px solid rgba(232, 180, 200, 0.4)',
                boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37), 0 0 30px rgba(232, 180, 200, 0.3)',
              }}
            >
              {/* Tutorial Image/Video Placeholder */}
              <div className="mb-4 rounded-xl overflow-hidden bg-white/5 border border-white/10">
                {/* Replace src with your tutorial image or GIF */}
                <img
                  src="/images/tutorials/heart-tutorial.gif"
                  alt="Heart homes you love"
                  className="w-full h-auto"
                  onError={(e) => {
                    // Fallback if image not found - show placeholder
                    e.currentTarget.style.display = 'none';
                    const placeholder = e.currentTarget.nextElementSibling as HTMLElement;
                    if (placeholder) placeholder.style.display = 'flex';
                  }}
                />
                <div
                  className="hidden items-center justify-center p-8 text-white/40 text-sm text-center"
                  style={{ minHeight: '150px' }}
                >
                  📸 Add tutorial image at<br/>
                  <code className="text-xs mt-1">/public/images/tutorials/heart-tutorial.gif</code>
                </div>
              </div>

              <div className="flex items-start gap-3 mb-4">
                <span className="text-3xl">❤️</span>
                <div className="flex-1">
                  <h3 className="text-white font-bold text-lg mb-2">
                    Save what you can't live without
                  </h3>
                  <p className="text-white/70 text-sm leading-relaxed">
                    Tap the feature that matters most. Later in HOMEY, you'll ❤️ homes you love the same way!
                  </p>
                </div>
              </div>
              <motion.button
                onClick={() => {
                  setShowTutorial(false);
                  // Auto-select first option and continue
                  if (!selected) {
                    setSelected(priorityOptions[0].id);
                    setTimeout(() => {
                      onNext({ mustHave: priorityOptions[0].id });
                    }, 300);
                  }
                }}
                className="w-full py-3 rounded-xl font-semibold backdrop-blur-sm"
                style={{
                  background: 'linear-gradient(135deg, rgba(232, 180, 200, 0.3) 0%, rgba(180, 167, 214, 0.3) 100%)',
                  border: '1px solid rgba(255, 255, 255, 0.3)',
                }}
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
              >
                <span className="text-white">Continue →</span>
              </motion.button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Priority Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-5 mb-8">
        {priorityOptions.map((option, index) => (
          <motion.button
            key={option.id}
            initial={{ y: 20, opacity: 0, scale: 0.95 }}
            animate={{ y: 0, opacity: 1, scale: 1 }}
            transition={{ delay: 0.3 + index * 0.1, duration: 0.5 }}
            onClick={() => handleSelect(option.id)}
            className={`relative p-8 rounded-3xl text-left transition-all transform overflow-hidden ${
              selected === option.id
                ? 'scale-105 shadow-2xl ring-4 ring-white/30'
                : 'shadow-lg hover:scale-[1.02]'
            }`}
          >
            {/* Gradient Background */}
            <div
              className={`absolute inset-0 bg-gradient-to-br ${option.gradient} transition-opacity ${
                selected === option.id ? 'opacity-100' : 'opacity-80'
              }`}
            />

            {/* Glass overlay */}
            <div className="absolute inset-0 bg-white/5 backdrop-blur-sm" />

            {/* Content */}
            <div className="relative z-10">
              <div className="text-6xl mb-4">{option.icon}</div>
              <h3 className="text-2xl font-bold text-white">{option.title}</h3>

              {/* Check Mark */}
              {selected === option.id && (
                <motion.div
                  initial={{ scale: 0, rotate: -180 }}
                  animate={{ scale: 1, rotate: 0 }}
                  className="absolute top-6 right-6 w-12 h-12 bg-white rounded-full flex items-center justify-center text-2xl shadow-lg"
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
