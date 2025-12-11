'use client';

import { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Palette, X, ChevronLeft, ChevronRight } from 'lucide-react';
import { JOURNEY_THEMES, getThemePreference, saveThemePreference, type JourneyTheme } from '@/lib/journeyThemes';

interface JourneyThemeSelectorProps {
  onThemeChange?: (themeId: string) => void;
}

export default function JourneyThemeSelector({ onThemeChange }: JourneyThemeSelectorProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedTheme, setSelectedTheme] = useState('default');
  const [activeCarousel, setActiveCarousel] = useState(0); // 0 = gradients, 1 = monochrome

  const gradientScrollRef = useRef<HTMLDivElement>(null);
  const monochromeScrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    setSelectedTheme(getThemePreference());
  }, []);

  const handleThemeSelect = (themeId: string) => {
    setSelectedTheme(themeId);
    saveThemePreference(themeId);
    onThemeChange?.(themeId);
    setIsOpen(false); // Close modal immediately after selection
  };

  const gradientThemes = JOURNEY_THEMES.filter(t => t.type === 'gradient');
  const monochromeThemes = JOURNEY_THEMES.filter(t => t.type === 'monochrome');

  const scrollCarousel = (direction: 'left' | 'right', ref: React.RefObject<HTMLDivElement>) => {
    if (!ref.current) return;
    const scrollAmount = 200;
    ref.current.scrollBy({
      left: direction === 'left' ? -scrollAmount : scrollAmount,
      behavior: 'smooth'
    });
  };

  return (
    <>
      {/* Theme Selector Button - iPhone Minimal */}
      <motion.button
        onClick={() => setIsOpen(true)}
        whileHover={{ scale: 1.05 }}
        whileTap={{ scale: 0.95 }}
        className="p-1.5 rounded-full bg-white/[0.03] hover:bg-white/[0.08] transition-colors border border-white/[0.06]"
        aria-label="Change journey theme"
      >
        <Palette className="w-3.5 h-3.5 text-white/40" />
      </motion.button>

      {/* Theme Selector Modal */}
      <AnimatePresence>
        {isOpen && (
          <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4">
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setIsOpen(false)}
              className="absolute inset-0 bg-black/80 backdrop-blur-sm"
            />

            {/* Modal */}
            <motion.div
              initial={{ opacity: 0, y: '100%' }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: '100%' }}
              transition={{ type: 'spring', damping: 30, stiffness: 300 }}
              onClick={(e) => e.stopPropagation()}
              className="relative w-full sm:max-w-md glass-strong sm:rounded-3xl rounded-t-3xl border border-white/10 overflow-hidden"
            >
              {/* Header */}
              <div className="p-6 border-b border-white/10 bg-slate-900/95 backdrop-blur-xl">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <Palette className="w-6 h-6 text-purple-400" />
                    <h3 className="text-xl font-bold text-white">Journey Theme</h3>
                  </div>
                  <button
                    onClick={() => setIsOpen(false)}
                    className="p-2 hover:bg-white/10 rounded-full transition-colors"
                  >
                    <X className="w-5 h-5 text-white/60" />
                  </button>
                </div>
                <p className="text-sm text-white/50 mt-2">Swipe to explore themes</p>
              </div>

              {/* Content */}
              <div className="p-6 space-y-6">
                {/* Gradient Themes Carousel */}
                <div>
                  <div className="flex items-center justify-between mb-3">
                    <h4 className="text-sm font-semibold text-white/70 uppercase tracking-wider">
                      Gradients
                    </h4>
                    <div className="flex gap-1">
                      <button
                        onClick={() => scrollCarousel('left', gradientScrollRef)}
                        className="p-1 hover:bg-white/10 rounded-full transition-colors"
                      >
                        <ChevronLeft className="w-4 h-4 text-white/60" />
                      </button>
                      <button
                        onClick={() => scrollCarousel('right', gradientScrollRef)}
                        className="p-1 hover:bg-white/10 rounded-full transition-colors"
                      >
                        <ChevronRight className="w-4 h-4 text-white/60" />
                      </button>
                    </div>
                  </div>

                  <div
                    ref={gradientScrollRef}
                    className="flex gap-3 overflow-x-auto pb-2 scrollbar-hide snap-x snap-mandatory"
                    style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
                  >
                    {gradientThemes.map((theme) => (
                      <motion.button
                        key={theme.id}
                        onClick={() => handleThemeSelect(theme.id)}
                        whileHover={{ scale: 1.02 }}
                        whileTap={{ scale: 0.98 }}
                        className={`flex-shrink-0 w-32 p-4 rounded-xl border-2 transition-all snap-center ${
                          selectedTheme === theme.id
                            ? 'border-purple-500 bg-purple-500/10'
                            : 'border-white/10 bg-white/5 hover:border-white/20'
                        }`}
                      >
                        <div
                          className="w-full h-12 rounded-lg mb-2"
                          style={{ background: theme.preview }}
                        />
                        <p className="text-sm font-medium text-white text-center">{theme.name}</p>
                      </motion.button>
                    ))}
                  </div>
                </div>

                {/* Monochrome Themes Carousel */}
                <div>
                  <div className="flex items-center justify-between mb-3">
                    <h4 className="text-sm font-semibold text-white/70 uppercase tracking-wider">
                      Monochrome
                    </h4>
                    <div className="flex gap-1">
                      <button
                        onClick={() => scrollCarousel('left', monochromeScrollRef)}
                        className="p-1 hover:bg-white/10 rounded-full transition-colors"
                      >
                        <ChevronLeft className="w-4 h-4 text-white/60" />
                      </button>
                      <button
                        onClick={() => scrollCarousel('right', monochromeScrollRef)}
                        className="p-1 hover:bg-white/10 rounded-full transition-colors"
                      >
                        <ChevronRight className="w-4 h-4 text-white/60" />
                      </button>
                    </div>
                  </div>

                  <div
                    ref={monochromeScrollRef}
                    className="flex gap-3 overflow-x-auto pb-2 scrollbar-hide snap-x snap-mandatory"
                    style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
                  >
                    {monochromeThemes.map((theme) => (
                      <motion.button
                        key={theme.id}
                        onClick={() => handleThemeSelect(theme.id)}
                        whileHover={{ scale: 1.02 }}
                        whileTap={{ scale: 0.98 }}
                        className={`flex-shrink-0 w-32 p-4 rounded-xl border-2 transition-all snap-center ${
                          selectedTheme === theme.id
                            ? 'border-purple-500 bg-purple-500/10'
                            : 'border-white/10 bg-white/5 hover:border-white/20'
                        }`}
                      >
                        <div
                          className="w-full h-12 rounded-lg mb-2 border border-white/20"
                          style={{ background: theme.preview }}
                        />
                        <p className="text-sm font-medium text-white text-center">{theme.name}</p>
                      </motion.button>
                    ))}
                  </div>
                </div>

                {/* Close Button */}
                <button
                  onClick={() => setIsOpen(false)}
                  className="w-full py-3 bg-gradient-to-r from-purple-500 to-pink-500 hover:opacity-90 text-white font-semibold rounded-xl transition-all"
                >
                  Done
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      <style jsx>{`
        .scrollbar-hide::-webkit-scrollbar {
          display: none;
        }
      `}</style>
    </>
  );
}
