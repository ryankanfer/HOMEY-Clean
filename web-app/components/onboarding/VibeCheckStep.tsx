'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';

interface VibeCheckStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function VibeCheckStep({ data, onNext, isSaving }: VibeCheckStepProps) {
  const [selected, setSelected] = useState<string | null>(data.stylePreference || null);
  const [showReassurance, setShowReassurance] = useState(false);
  const [showTutorial, setShowTutorial] = useState(!data.stylePreference); // Show tutorial on first visit

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
    setShowReassurance(true);
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
        className="text-white/60 text-center mb-8 text-lg"
      >
        Pick the aesthetic that speaks to your soul
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
                border: '1.5px solid rgba(168, 218, 220, 0.4)',
                boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37), 0 0 30px rgba(168, 218, 220, 0.3)',
              }}
            >
              {/* Tutorial Image/Video Placeholder */}
              <div className="mb-4 rounded-xl overflow-hidden bg-white/5 border border-white/10">
                {/* Replace src with your tutorial image or GIF */}
                <img
                  src="/images/tutorials/vibe-tutorial.gif"
                  alt="Swipe to choose your vibe"
                  className="w-full h-auto"
                  onError={(e) => {
                    // Fallback if image not found - show placeholder
                    e.currentTarget.style.display = 'none';
                    const placeholder = e.currentTarget.nextElementSibling as HTMLElement;
                    if (placeholder) placeholder.style.display = 'flex';
                  }}
                />
                <div
                  className="hidden items-center justify-center p-8 text-white/40 text-sm"
                  style={{ minHeight: '150px' }}
                >
                  📸 Add tutorial image at<br/>
                  <code className="text-xs mt-1">/public/images/tutorials/vibe-tutorial.gif</code>
                </div>
              </div>

              <div className="flex items-start gap-3 mb-4">
                <span className="text-3xl">👉</span>
                <div className="flex-1">
                  <h3 className="text-white font-bold text-lg mb-2">
                    Teach HOMEY your vibe
                  </h3>
                  <p className="text-white/70 text-sm leading-relaxed">
                    Tap a style card to choose your vibe. This helps HOMEY understand what kind of homes to show you later!
                  </p>
                </div>
              </div>
              <motion.button
                onClick={() => {
                  setShowTutorial(false);
                  // Auto-select first style option and continue
                  if (!selected) {
                    setSelected(styleOptions[0].id);
                    setTimeout(() => {
                      onNext({ stylePreference: styleOptions[0].id });
                    }, 300);
                  }
                }}
                className="w-full py-3 rounded-xl font-semibold backdrop-blur-sm"
                style={{
                  background: 'linear-gradient(135deg, rgba(168, 218, 220, 0.3) 0%, rgba(180, 167, 214, 0.3) 100%)',
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

      {/* Style Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
        {styleOptions.map((option, index) => (
          <motion.button
            key={option.id}
            initial={{ y: 20, opacity: 0, scale: 0.9 }}
            animate={{ y: 0, opacity: 1, scale: 1 }}
            transition={{ delay: 0.3 + index * 0.08, duration: 0.5 }}
            onClick={() => handleSelect(option.id)}
            className="group relative p-6 rounded-3xl text-left transition-all transform overflow-hidden backdrop-blur-xl"
            style={
              selected === option.id
                ? {
                    background: 'rgba(255, 255, 255, 0.08)',
                    border: '2px solid rgba(255, 255, 255, 0.4)',
                    boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37), 0 0 40px rgba(0, 240, 255, 0.6), inset 0 0 40px rgba(255, 255, 255, 0.1)',
                  }
                : {
                    background: 'rgba(255, 255, 255, 0.05)',
                    border: '1.5px solid rgba(255, 255, 255, 0.18)',
                    boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37), 0 0 20px rgba(100, 100, 255, 0.2)',
                  }
            }
            whileHover={
              selected !== option.id
                ? {
                    scale: 1.02,
                    boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37), 0 0 30px rgba(100, 100, 255, 0.3)',
                  }
                : { scale: 1.05 }
            }
          >
            {/* Background Gradient */}
            <div
              className={`absolute inset-0 bg-gradient-to-br ${option.gradient} transition-opacity ${
                selected === option.id ? 'opacity-30' : 'opacity-20 group-hover:opacity-25'
              }`}
            />

            {/* Additional holo-glass overlay */}
            <div className="absolute inset-0 backdrop-blur-md" />

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
          <motion.button
            onClick={handleContinue}
            disabled={isSaving}
            className="px-10 py-4 rounded-full font-bold text-lg transition-all backdrop-blur-xl disabled:opacity-50 disabled:cursor-not-allowed"
            style={{
              background: 'linear-gradient(135deg, rgba(168, 218, 220, 0.3) 0%, rgba(180, 167, 214, 0.3) 100%)',
              border: '1.5px solid rgba(255, 255, 255, 0.3)',
              boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37), 0 0 30px rgba(168, 218, 220, 0.5)',
            }}
            whileHover={{
              scale: 1.05,
              boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37), 0 0 40px rgba(168, 218, 220, 0.7)',
              background: 'linear-gradient(135deg, rgba(168, 218, 220, 0.4) 0%, rgba(180, 167, 214, 0.4) 100%)',
            }}
            whileTap={{ scale: 0.98 }}
          >
            <span className="text-white">
              {isSaving ? 'Saving...' : 'Continue →'}
            </span>
          </motion.button>
        </motion.div>
      )}

      {/* Reassurance Popup */}
      <AnimatePresence>
        {showReassurance && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-black/60 backdrop-blur-sm z-[100]"
              onClick={() => setShowReassurance(false)}
            />

            {/* Modal */}
            <motion.div
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              className="fixed inset-0 z-[101] flex items-center justify-center p-4"
            >
              <div
                className="rounded-2xl p-8 max-w-md w-full text-center backdrop-blur-xl"
                style={{
                  background: 'rgba(255, 255, 255, 0.08)',
                  border: '1.5px solid rgba(168, 218, 220, 0.4)',
                  boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37), 0 0 40px rgba(168, 218, 220, 0.4), inset 0 0 30px rgba(168, 218, 220, 0.1)',
                }}
              >
                <div className="text-5xl mb-4">💭</div>
                <h3 className="text-2xl font-bold text-white mb-3">
                  Just so you know...
                </h3>
                <p className="text-white/80 text-base leading-relaxed mb-6">
                  Your taste will evolve as you explore. We'll learn what you really love together, so no pressure to get this perfect right now.
                </p>
                <motion.button
                  onClick={() => {
                    setShowReassurance(false);
                    // Auto-continue to next step
                    if (selected) {
                      onNext({ stylePreference: selected });
                    }
                  }}
                  className="px-8 py-3 text-white rounded-xl font-semibold transition-all backdrop-blur-sm"
                  style={{
                    background: 'linear-gradient(135deg, rgba(168, 218, 220, 0.3) 0%, rgba(180, 167, 214, 0.3) 100%)',
                    border: '1px solid rgba(255, 255, 255, 0.3)',
                    boxShadow: '0 0 20px rgba(168, 218, 220, 0.4)',
                  }}
                  whileHover={{
                    scale: 1.05,
                    boxShadow: '0 0 30px rgba(168, 218, 220, 0.6)',
                  }}
                  whileTap={{ scale: 0.98 }}
                >
                  Continue →
                </motion.button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </motion.div>
  );
}
