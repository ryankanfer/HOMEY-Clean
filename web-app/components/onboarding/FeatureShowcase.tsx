'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';

interface FeatureShowcaseProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

const features = [
  {
    icon: '🎯',
    title: 'Matchmaker',
    subtitle: 'Your Personal Property Scout',
    description: 'Swipe through personalized listings. Like Tinder, but for your dream home.',
    gradient: 'from-pink-500 to-rose-500',
  },
  {
    icon: '✨',
    title: 'Style Studio',
    subtitle: 'Discover Your Aesthetic',
    description: 'Swipe through design inspirations. Help us learn your style preferences.',
    gradient: 'from-purple-500 to-indigo-500',
  },
  {
    icon: '🔮',
    title: 'Scout',
    subtitle: 'AI-Powered Recommendations',
    description: 'Get personalized property suggestions based on everything we\'ve learned about you.',
    gradient: 'from-blue-500 to-cyan-500',
  },
  {
    icon: '📅',
    title: 'Calendar',
    subtitle: 'Your Home Search HQ',
    description: 'Schedule tours, track deadlines, and manage your entire home search journey.',
    gradient: 'from-green-500 to-emerald-500',
  },
  {
    icon: '🗂️',
    title: 'Vault',
    subtitle: 'Secure Document Storage',
    description: 'Upload and organize all your documents. Bank statements, pay stubs, applications—all in one place.',
    gradient: 'from-yellow-500 to-orange-500',
  },
];

export default function FeatureShowcase({ onNext, isSaving }: FeatureShowcaseProps) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [autoPlayEnabled, setAutoPlayEnabled] = useState(true);

  const currentFeature = features[currentIndex];

  useEffect(() => {
    if (!autoPlayEnabled) return;

    const timer = setTimeout(() => {
      if (currentIndex < features.length - 1) {
        setCurrentIndex(currentIndex + 1);
      } else {
        setAutoPlayEnabled(false);
      }
    }, 3000);

    return () => clearTimeout(timer);
  }, [currentIndex, autoPlayEnabled]);

  const handleNext = () => {
    if (currentIndex < features.length - 1) {
      setCurrentIndex(currentIndex + 1);
      setAutoPlayEnabled(false);
    }
  };

  const handlePrevious = () => {
    if (currentIndex > 0) {
      setCurrentIndex(currentIndex - 1);
      setAutoPlayEnabled(false);
    }
  };

  const handleContinue = () => {
    onNext({});
  };

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ duration: 0.8 }}
      className="w-full max-w-4xl mx-auto"
    >
      {/* Header */}
      <motion.div
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.6 }}
        className="text-center mb-16"
      >
        <h2
          className="text-5xl md:text-6xl font-light text-white mb-4"
          style={{ fontFamily: 'Playfair Display, serif' }}
        >
          What HOMEY can do
        </h2>
        <p className="text-white/60 text-lg">
          Here's what makes HOMEY your ultimate home-finding assistant
        </p>
      </motion.div>

      {/* Feature Card */}
      <div className="relative mb-12" style={{ minHeight: '400px' }}>
        <AnimatePresence mode="wait">
          <motion.div
            key={currentIndex}
            initial={{ opacity: 0, scale: 0.9, rotateY: -20 }}
            animate={{ opacity: 1, scale: 1, rotateY: 0 }}
            exit={{ opacity: 0, scale: 0.9, rotateY: 20 }}
            transition={{
              duration: 0.7,
              type: 'spring',
              damping: 25,
              stiffness: 200,
            }}
            className="relative"
          >
            {/* Gradient Background */}
            <div className={`absolute inset-0 bg-gradient-to-br ${currentFeature.gradient} rounded-3xl opacity-90 blur-xl`} />

            {/* Content */}
            <div className="relative glass-strong rounded-3xl p-12 md:p-16 text-center border border-white/20">
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: 0.3, type: 'spring', damping: 15 }}
                className="text-8xl mb-8"
              >
                {currentFeature.icon}
              </motion.div>

              <motion.h3
                initial={{ y: 20, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                transition={{ delay: 0.4, duration: 0.5 }}
                className="text-4xl md:text-5xl font-bold text-white mb-3"
                style={{ fontFamily: 'Playfair Display, serif' }}
              >
                {currentFeature.title}
              </motion.h3>

              <motion.p
                initial={{ y: 20, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                transition={{ delay: 0.5, duration: 0.5 }}
                className="text-xl text-white/70 mb-6"
              >
                {currentFeature.subtitle}
              </motion.p>

              <motion.p
                initial={{ y: 20, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                transition={{ delay: 0.6, duration: 0.5 }}
                className="text-lg text-white/60 max-w-xl mx-auto"
              >
                {currentFeature.description}
              </motion.p>
            </div>
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Navigation Dots */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.7 }}
        className="flex justify-center gap-2 mb-8"
      >
        {features.map((_, index) => (
          <button
            key={index}
            onClick={() => {
              setCurrentIndex(index);
              setAutoPlayEnabled(false);
            }}
            className={`h-2 rounded-full transition-all ${
              index === currentIndex
                ? 'w-8 bg-white'
                : 'w-2 bg-white/30 hover:bg-white/50'
            }`}
          />
        ))}
      </motion.div>

      {/* Navigation Buttons */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.8 }}
        className="flex justify-center items-center gap-4"
      >
        {currentIndex > 0 && (
          <button
            onClick={handlePrevious}
            className="px-6 py-3 text-white/60 hover:text-white transition-colors"
          >
            ← Previous
          </button>
        )}

        {currentIndex < features.length - 1 ? (
          <button
            onClick={handleNext}
            className="px-10 py-4 bg-white text-black rounded-full font-bold text-lg hover:shadow-2xl hover:shadow-white/20 transition-all transform hover:scale-105"
          >
            Next →
          </button>
        ) : (
          <button
            onClick={handleContinue}
            disabled={isSaving}
            className="px-10 py-4 bg-gradient-to-r from-primary to-purple-500 text-white rounded-full font-bold text-lg hover:shadow-2xl hover:shadow-primary/30 transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isSaving ? 'Saving...' : 'Let\'s Go! →'}
          </button>
        )}
      </motion.div>

      {/* Skip button */}
      {currentIndex < features.length - 1 && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1 }}
          className="text-center mt-6"
        >
          <button
            onClick={handleContinue}
            disabled={isSaving}
            className="text-white/40 hover:text-white/60 transition-colors text-sm"
          >
            Skip tour
          </button>
        </motion.div>
      )}
    </motion.div>
  );
}
