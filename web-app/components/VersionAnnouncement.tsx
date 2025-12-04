'use client';

import { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Sparkles, Check } from 'lucide-react';
import { checkForNewVersion, markVersionAsSeen, formatVersion, type ReleaseNote } from '@/lib/version';
import { auth } from '@/lib/supabase';

export default function VersionAnnouncement() {
  const [show, setShow] = useState(false);
  const [releaseNotes, setReleaseNotes] = useState<ReleaseNote | null>(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  useEffect(() => {
    // Check authentication first
    async function checkAuthAndVersion() {
      const { data: { user } } = await auth.getUser();

      if (!user) {
        setIsAuthenticated(false);
        return;
      }

      setIsAuthenticated(true);

      // Only check for new version if user is authenticated
      const { hasNewVersion, releaseNotes: notes } = checkForNewVersion();

      if (hasNewVersion && notes) {
        setReleaseNotes(notes);
        setShow(true);
      }
    }

    checkAuthAndVersion();
  }, []);

  const handleDismiss = () => {
    if (releaseNotes) {
      markVersionAsSeen(releaseNotes.version);
    }
    setShow(false);
  };

  // Don't show if not authenticated or no release notes
  if (!isAuthenticated || !releaseNotes) return null;

  return (
    <AnimatePresence>
      {show && (
        <div className="fixed inset-0 z-[10000] flex items-center justify-center p-3 md:p-4">
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={handleDismiss}
            className="absolute inset-0 bg-black/60 backdrop-blur-sm"
          />

          {/* Modal */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.9, y: 20 }}
            className="relative w-full max-w-lg max-h-[90vh] md:max-h-[85vh] overflow-y-auto z-10"
          >
            <div className="glass-strong rounded-xl md:rounded-2xl border border-white/20 shadow-2xl overflow-hidden">
              {/* Header */}
              <div className="relative bg-gradient-to-r from-purple-600 to-pink-600 p-4 md:p-6">
                <div className="absolute inset-0 bg-[url('/noise.png')] opacity-10"></div>
                <button
                  onClick={handleDismiss}
                  className="absolute top-3 right-3 md:top-4 md:right-4 p-2 hover:bg-white/10 rounded-lg transition-colors"
                >
                  <X className="w-5 h-5 text-white" />
                </button>

                <div className="relative flex items-center gap-2 md:gap-3 mb-2">
                  <div className="w-10 h-10 md:w-12 md:h-12 bg-white/20 rounded-lg md:rounded-xl flex items-center justify-center flex-shrink-0">
                    <Sparkles className="w-5 h-5 md:w-6 md:h-6 text-white" />
                  </div>
                  <div className="flex-1 min-w-0 pr-8">
                    <h2 className="text-lg md:text-2xl font-bold text-white truncate">
                      {releaseNotes.title}
                    </h2>
                    <p className="text-white/90 text-xs md:text-sm font-medium">
                      {formatVersion(releaseNotes.version)} • {releaseNotes.date}
                    </p>
                  </div>
                </div>
              </div>

              {/* Content */}
              <div className="p-4 md:p-6 space-y-4 md:space-y-6">
                {/* Highlights */}
                {releaseNotes.highlights && releaseNotes.highlights.length > 0 && (
                  <div>
                    <h3 className="text-white font-semibold mb-2 md:mb-3 flex items-center gap-2 text-sm md:text-base">
                      <Sparkles className="w-4 h-4 text-yellow-400" />
                      Highlights
                    </h3>
                    <div className="space-y-2">
                      {releaseNotes.highlights.map((highlight, index) => (
                        <div
                          key={index}
                          className="flex items-start gap-2 md:gap-3 p-2.5 md:p-3 bg-gradient-to-r from-purple-500/10 to-pink-500/10 border border-purple-500/20 rounded-lg"
                        >
                          <div className="text-base md:text-lg flex-shrink-0 mt-0.5">
                            {highlight.split(' ')[0]}
                          </div>
                          <p className="text-white text-xs md:text-sm flex-1">
                            {highlight.split(' ').slice(1).join(' ')}
                          </p>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {/* All Changes */}
                <div>
                  <h3 className="text-white font-semibold mb-2 md:mb-3 text-sm md:text-base">What's New</h3>
                  <div className="space-y-1.5 md:space-y-2">
                    {releaseNotes.changes.map((change, index) => (
                      <div
                        key={index}
                        className="flex items-start gap-2 md:gap-3 text-white/80 text-xs md:text-sm"
                      >
                        <Check className="w-3.5 h-3.5 md:w-4 md:h-4 text-green-400 flex-shrink-0 mt-0.5" />
                        <span>{change}</span>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Footer */}
                <div className="pt-3 md:pt-4 border-t border-white/10">
                  <p className="text-white/40 text-xs text-center mb-3 md:mb-4">
                    We're constantly improving HOMEY to help you find your perfect home
                  </p>
                  <button
                    onClick={handleDismiss}
                    className="w-full px-4 md:px-6 py-2.5 md:py-3 bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 text-white font-semibold rounded-lg md:rounded-xl transition-all text-sm md:text-base"
                  >
                    Got it, thanks!
                  </button>
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
}
