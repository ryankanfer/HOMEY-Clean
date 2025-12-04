'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';

interface VibeCheckStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function VibeCheckStep({ data, onNext, isSaving }: VibeCheckStepProps) {
  const [selected, setSelected] = useState<string | null>(data.stylePreference || null);

  const styleOptions = [
    {
      id: 'modern',
      emoji: '⬜',
      gradient: 'from-slate-600 to-slate-400',
      title: 'Modern Minimalist',
      description: 'Clean lines, neutral tones, less is more',
      keywords: ['sleek', 'minimal', 'contemporary'],
    },
    {
      id: 'cozy',
      emoji: '🪵',
      gradient: 'from-amber-700 to-orange-600',
      title: 'Cozy Traditional',
      description: 'Warm woods, soft textures, homey feels',
      keywords: ['traditional', 'warm', 'inviting'],
    },
    {
      id: 'industrial',
      emoji: '🏭',
      gradient: 'from-zinc-700 to-stone-600',
      title: 'Industrial Urban',
      description: 'Exposed brick, metal accents, loft vibes',
      keywords: ['urban', 'edgy', 'raw'],
    },
    {
      id: 'bohemian',
      emoji: '🌿',
      gradient: 'from-emerald-600 to-teal-500',
      title: 'Boho Eclectic',
      description: 'Plants, patterns, collected treasures',
      keywords: ['eclectic', 'artistic', 'free-spirited'],
    },
    {
      id: 'luxe',
      emoji: '✨',
      gradient: 'from-purple-600 to-pink-500',
      title: 'Luxe & Elegant',
      description: 'High-end finishes, statement pieces, glamorous',
      keywords: ['luxury', 'sophisticated', 'polished'],
    },
    {
      id: 'coastal',
      emoji: '🌊',
      gradient: 'from-cyan-500 to-blue-400',
      title: 'Coastal Chill',
      description: 'Breezy, bright, beach house energy',
      keywords: ['coastal', 'airy', 'relaxed'],
    },
  ];

  const handleSelect = (styleId: string) => {
    setSelected(styleId);
  };

  const handleContinue = () => {
    if (selected) {
      onNext({ stylePreference: selected });
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
        What's your vibe?
      </motion.h2>

      <motion.p
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        className="text-white/60 text-center mb-12 text-lg"
      >
        Pick the aesthetic that speaks to your soul
      </motion.p>

      {/* Style Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
        {styleOptions.map((option, index) => (
          <motion.button
            key={option.id}
            initial={{ y: 20, opacity: 0, scale: 0.9 }}
            animate={{ y: 0, opacity: 1, scale: 1 }}
            transition={{ delay: 0.3 + index * 0.08, duration: 0.5 }}
            onClick={() => handleSelect(option.id)}
            className={`group relative p-6 rounded-3xl text-left transition-all transform overflow-hidden ${
              selected === option.id
                ? 'scale-105 shadow-2xl ring-4 ring-white/50'
                : 'hover:scale-102 shadow-lg'
            }`}
          >
            {/* Background Gradient */}
            <div
              className={`absolute inset-0 bg-gradient-to-br ${option.gradient} transition-opacity ${
                selected === option.id ? 'opacity-100' : 'opacity-70 group-hover:opacity-90'
              }`}
            />

            {/* Glass overlay */}
            <div className="absolute inset-0 bg-white/5 backdrop-blur-sm" />

            {/* Content */}
            <div className="relative z-10">
              {/* Emoji Icon */}
              <div className="text-6xl mb-4">{option.emoji}</div>

              {/* Title */}
              <h3 className="text-xl font-bold text-white mb-2">{option.title}</h3>

              {/* Description */}
              <p className="text-white/90 text-sm mb-3">{option.description}</p>

              {/* Keywords */}
              <div className="flex flex-wrap gap-2">
                {option.keywords.map((keyword) => (
                  <span
                    key={keyword}
                    className="px-2 py-1 bg-white/20 rounded-full text-xs text-white"
                  >
                    {keyword}
                  </span>
                ))}
              </div>

              {/* Check Mark */}
              {selected === option.id && (
                <motion.div
                  initial={{ scale: 0, rotate: -180 }}
                  animate={{ scale: 1, rotate: 0 }}
                  className="absolute top-4 right-4 w-10 h-10 bg-white rounded-full flex items-center justify-center text-2xl"
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
