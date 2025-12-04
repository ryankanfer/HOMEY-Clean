'use client';

import { motion } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';

interface MatchTeaseStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function MatchTeaseStep({ data, onNext, isSaving }: MatchTeaseStepProps) {
  const handleContinue = () => {
    onNext({});
  };

  // Generate a random match percentage (95-99%)
  const matchPercentage = 98;

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ duration: 0.8 }}
      className="w-full max-w-2xl mx-auto text-center"
    >
      {/* Heading */}
      <motion.h2
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.8 }}
        className="text-4xl md:text-5xl font-light text-white mb-4"
        style={{ fontFamily: 'Playfair Display, serif' }}
      >
        Okay, I think I've got it
      </motion.h2>

      <motion.p
        initial={{ y: 30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.4, duration: 0.8 }}
        className="text-white/60 text-lg mb-12"
      >
        Already finding places that match your vibe...
      </motion.p>

      {/* Blurred Preview Card */}
      <motion.div
        initial={{ scale: 0.8, opacity: 0, y: 30 }}
        animate={{ scale: 1, opacity: 1, y: 0 }}
        transition={{ delay: 0.6, duration: 0.8, type: 'spring', damping: 15 }}
        className="relative mb-12"
      >
        {/* Match Badge */}
        <motion.div
          initial={{ scale: 0, rotate: -180 }}
          animate={{ scale: 1, rotate: 0 }}
          transition={{ delay: 1, duration: 0.6, type: 'spring', damping: 10 }}
          className="absolute -top-6 left-1/2 -translate-x-1/2 z-20"
        >
          <div className="bg-gradient-to-r from-green-500 to-emerald-400 text-white px-6 py-3 rounded-full shadow-2xl shadow-green-500/50 font-bold text-lg flex items-center gap-2">
            <span className="text-2xl">✨</span>
            {matchPercentage}% Match
          </div>
        </motion.div>

        {/* Blurred Card */}
        <div className="glass-strong rounded-3xl overflow-hidden backdrop-blur-2xl">
          {/* Fake Image Area */}
          <div className="relative h-64 bg-gradient-to-br from-slate-800 to-slate-600 blur-xl">
            <div className="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAwIiBoZWlnaHQ9IjMwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iNDAwIiBoZWlnaHQ9IjMwMCIgZmlsbD0iIzMzMzMzMyIvPjx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBmb250LWZhbWlseT0iQXJpYWwiIGZvbnQtc2l6ZT0iMjAiIGZpbGw9IiM2NjY2NjYiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGR5PSIuM2VtIj5Ib21lIEltYWdlPC90ZXh0Pjwvc3ZnPg==')] opacity-30" />
          </div>

          {/* Card Details (Blurred) */}
          <div className="p-6 space-y-4 blur-lg">
            <div className="h-8 bg-white/30 rounded-lg w-3/4" />
            <div className="flex gap-4">
              <div className="h-6 bg-white/20 rounded w-20" />
              <div className="h-6 bg-white/20 rounded w-20" />
              <div className="h-6 bg-white/20 rounded w-24" />
            </div>
            <div className="h-6 bg-white/20 rounded w-1/2" />
          </div>
        </div>

        {/* Lock Icon Overlay */}
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          transition={{ delay: 1.2, duration: 0.4, type: 'spring' }}
          className="absolute inset-0 flex items-center justify-center"
        >
          <div className="w-20 h-20 bg-white/90 rounded-full flex items-center justify-center backdrop-blur-sm shadow-2xl">
            <span className="text-4xl">🔒</span>
          </div>
        </motion.div>
      </motion.div>

      {/* Teaser Text */}
      <motion.p
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1.4, duration: 0.8 }}
        className="text-white/80 text-lg mb-8 max-w-md mx-auto"
      >
        I've already found <span className="font-bold text-primary">dozens of places</span> you're going to love.
        <br />
        <span className="text-white/60 text-base">Ready to see them?</span>
      </motion.p>

      {/* CTA */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 1.6, duration: 0.8 }}
      >
        <button
          onClick={handleContinue}
          disabled={isSaving}
          className="px-12 py-5 bg-gradient-to-r from-primary to-purple-500 text-white rounded-full font-bold text-lg hover:shadow-2xl hover:shadow-primary/30 transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Show me! →
        </button>
      </motion.div>
    </motion.div>
  );
}
