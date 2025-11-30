'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';

export default function DevDebugPanel() {
  const router = useRouter();
  const [isOpen, setIsOpen] = useState(false);

  // Only show in development
  if (process.env.NODE_ENV !== 'development') {
    return null;
  }

  return (
    <>
      {/* Toggle Button */}
      <motion.button
        onClick={() => setIsOpen(!isOpen)}
        className="fixed bottom-24 left-4 z-[9999] w-12 h-12 rounded-full bg-purple-600 text-white flex items-center justify-center shadow-lg hover:bg-purple-700 transition-colors"
        whileHover={{ scale: 1.1 }}
        whileTap={{ scale: 0.9 }}
      >
        🔧
      </motion.button>

      {/* Debug Panel */}
      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, x: -300 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -300 }}
            transition={{ type: 'spring', damping: 25 }}
            className="fixed bottom-24 left-20 z-[9999] w-72 bg-gray-900 rounded-2xl shadow-2xl border border-purple-500/30 overflow-hidden"
          >
            {/* Header */}
            <div className="bg-gradient-to-r from-purple-600 to-pink-600 px-4 py-3">
              <h3 className="text-white font-bold text-sm">🔧 Developer Tools</h3>
            </div>

            {/* Content */}
            <div className="p-4 space-y-2">
              {/* Database Test */}
              <button
                onClick={() => {
                  router.push('/db-test');
                  setIsOpen(false);
                }}
                className="w-full px-4 py-3 bg-green-600/20 hover:bg-green-600/30 text-white rounded-lg text-left transition-colors flex items-center gap-3"
              >
                <span className="text-2xl">🧪</span>
                <div>
                  <div className="font-semibold text-sm">Database Test</div>
                  <div className="text-xs text-white/60">Test Supabase connection</div>
                </div>
              </button>

              {/* Onboarding */}
              <button
                onClick={() => {
                  router.push('/onboarding');
                  setIsOpen(false);
                }}
                className="w-full px-4 py-3 bg-purple-600/20 hover:bg-purple-600/30 text-white rounded-lg text-left transition-colors flex items-center gap-3"
              >
                <span className="text-2xl">🎯</span>
                <div>
                  <div className="font-semibold text-sm">View Onboarding</div>
                  <div className="text-xs text-white/60">See the full flow</div>
                </div>
              </button>

              {/* Teach/Preferences */}
              <button
                onClick={() => {
                  router.push('/teach');
                  setIsOpen(false);
                }}
                className="w-full px-4 py-3 bg-blue-600/20 hover:bg-blue-600/30 text-white rounded-lg text-left transition-colors flex items-center gap-3"
              >
                <span className="text-2xl">⚙️</span>
                <div>
                  <div className="font-semibold text-sm">Refine Preferences</div>
                  <div className="text-xs text-white/60">Update settings</div>
                </div>
              </button>

              {/* Matchmaker */}
              <button
                onClick={() => {
                  router.push('/matchmaker');
                  setIsOpen(false);
                }}
                className="w-full px-4 py-3 bg-pink-600/20 hover:bg-pink-600/30 text-white rounded-lg text-left transition-colors flex items-center gap-3"
              >
                <span className="text-2xl">💕</span>
                <div>
                  <div className="font-semibold text-sm">Matchmaker</div>
                  <div className="text-xs text-white/60">Swipe properties</div>
                </div>
              </button>

              {/* Style Studio */}
              <button
                onClick={() => {
                  router.push('/studio');
                  setIsOpen(false);
                }}
                className="w-full px-4 py-3 bg-indigo-600/20 hover:bg-indigo-600/30 text-white rounded-lg text-left transition-colors flex items-center gap-3"
              >
                <span className="text-2xl">✨</span>
                <div>
                  <div className="font-semibold text-sm">Style Studio</div>
                  <div className="text-xs text-white/60">Design swipes</div>
                </div>
              </button>

              {/* Settings */}
              <button
                onClick={() => {
                  router.push('/settings');
                  setIsOpen(false);
                }}
                className="w-full px-4 py-3 bg-gray-600/20 hover:bg-gray-600/30 text-white rounded-lg text-left transition-colors flex items-center gap-3"
              >
                <span className="text-2xl">⚙️</span>
                <div>
                  <div className="font-semibold text-sm">Settings</div>
                  <div className="text-xs text-white/60">Account settings</div>
                </div>
              </button>
            </div>

            {/* Footer */}
            <div className="px-4 py-2 bg-gray-800/50 border-t border-white/5">
              <p className="text-xs text-white/40">
                Dev mode only • Hidden in production
              </p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
