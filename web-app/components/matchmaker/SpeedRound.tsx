'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Zap, Heart, X, Sparkles, Trophy, Clock } from 'lucide-react';
import type { Listing } from '@/lib/types';

interface SpeedRoundProps {
  listings: Listing[];
  onSwipe: (listing: Listing, action: 'pass' | 'like' | 'love') => void;
  onComplete: (stats: { total: number; likes: number; loves: number; passes: number }) => void;
}

export default function SpeedRound({
  listings,
  onSwipe,
  onComplete,
}: SpeedRoundProps) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [timeLeft, setTimeLeft] = useState(60);
  const [isActive, setIsActive] = useState(true);
  const [stats, setStats] = useState({ total: 0, likes: 0, loves: 0, passes: 0 });
  const [swipeDirection, setSwipeDirection] = useState<'left' | 'right' | 'up' | null>(null);

  const currentListing = listings[currentIndex];

  useEffect(() => {
    if (!isActive) return;

    const timer = setInterval(() => {
      setTimeLeft((prev) => {
        if (prev <= 1) {
          setIsActive(false);
          onComplete(stats);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [isActive, stats, onComplete]);

  const handleSwipe = (direction: 'left' | 'right' | 'up') => {
    if (!currentListing || !isActive) return;

    const action = direction === 'left' ? 'pass' : direction === 'right' ? 'like' : 'love';

    // Update stats
    setStats((prev) => ({
      total: prev.total + 1,
      likes: prev.likes + (action === 'like' ? 1 : 0),
      loves: prev.loves + (action === 'love' ? 1 : 0),
      passes: prev.passes + (action === 'pass' ? 1 : 0),
    }));

    // Animate swipe
    setSwipeDirection(direction);
    onSwipe(currentListing, action);

    // Move to next
    setTimeout(() => {
      setSwipeDirection(null);
      setCurrentIndex((prev) => (prev + 1) % listings.length);
    }, 200);
  };

  useEffect(() => {
    if (!isActive) return;

    const handleKeyPress = (e: KeyboardEvent) => {
      if (e.key === 'ArrowLeft') {
        e.preventDefault();
        handleSwipe('left');
      } else if (e.key === 'ArrowRight') {
        e.preventDefault();
        handleSwipe('right');
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        handleSwipe('up');
      }
    };

    window.addEventListener('keydown', handleKeyPress);
    return () => window.removeEventListener('keydown', handleKeyPress);
  }, [isActive, currentListing]);

  if (!isActive) {
    return (
      <div className="flex items-center justify-center h-full">
        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          className="glass-strong rounded-2xl p-8 max-w-md w-full border border-white/10 text-center"
        >
          <div className="w-20 h-20 bg-gradient-to-br from-yellow-500 to-orange-500 rounded-full flex items-center justify-center mx-auto mb-6">
            <Trophy className="w-10 h-10 text-white" />
          </div>

          <h3 className="text-3xl font-bold text-white mb-2">Time's Up!</h3>
          <p className="text-white/60 mb-6">Here's how you did</p>

          <div className="grid grid-cols-2 gap-4 mb-6">
            <div className="glass-medium rounded-lg p-4 border border-white/10">
              <p className="text-white/60 text-sm mb-1">Total Swipes</p>
              <p className="text-3xl font-bold text-white">{stats.total}</p>
            </div>

            <div className="glass-medium rounded-lg p-4 border border-purple-500/30 bg-purple-500/10">
              <p className="text-purple-300 text-sm mb-1">Loves</p>
              <p className="text-3xl font-bold text-purple-400">{stats.loves}</p>
            </div>

            <div className="glass-medium rounded-lg p-4 border border-green-500/30 bg-green-500/10">
              <p className="text-green-300 text-sm mb-1">Likes</p>
              <p className="text-3xl font-bold text-green-400">{stats.likes}</p>
            </div>

            <div className="glass-medium rounded-lg p-4 border border-red-500/30 bg-red-500/10">
              <p className="text-red-300 text-sm mb-1">Passes</p>
              <p className="text-3xl font-bold text-red-400">{stats.passes}</p>
            </div>
          </div>

          <div className="p-4 bg-gradient-to-r from-yellow-500/20 to-orange-500/20 border border-yellow-500/30 rounded-xl mb-6">
            <div className="flex items-center gap-3 justify-center">
              <Zap className="w-6 h-6 text-yellow-400" />
              <div className="text-left">
                <p className="text-yellow-300 text-sm font-medium">Fast Learner Badge</p>
                <p className="text-white/60 text-xs">
                  {stats.total >= 20 ? 'Unlocked!' : `Swipe ${20 - stats.total} more to unlock`}
                </p>
              </div>
            </div>
          </div>

          <button
            onClick={() => window.location.reload()}
            className="w-full py-3 bg-gradient-to-r from-primary to-purple-500 rounded-xl text-white font-semibold hover:opacity-90 transition-all"
          >
            Play Again
          </button>
        </motion.div>
      </div>
    );
  }

  if (!currentListing) {
    return (
      <div className="flex items-center justify-center h-full">
        <p className="text-white/60">Loading properties...</p>
      </div>
    );
  }

  return (
    <div className="relative h-full flex flex-col">
      {/* Header with Timer */}
      <div className="relative z-20 px-4 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-gradient-to-br from-yellow-500 to-orange-500 rounded-lg flex items-center justify-center">
              <Zap className="w-6 h-6 text-white" />
            </div>
            <div>
              <h3 className="text-lg font-bold text-white">Speed Round</h3>
              <p className="text-xs text-white/60">Fast decisions only!</p>
            </div>
          </div>

          {/* Timer */}
          <motion.div
            animate={{
              scale: timeLeft <= 10 ? [1, 1.1, 1] : 1,
            }}
            transition={{
              duration: 0.5,
              repeat: timeLeft <= 10 ? Infinity : 0,
            }}
            className={`px-4 py-2 rounded-full border-2 flex items-center gap-2 ${
              timeLeft <= 10
                ? 'bg-red-500/20 border-red-500 shadow-lg shadow-red-500/20'
                : 'bg-white/10 border-white/20'
            }`}
          >
            <Clock className={`w-5 h-5 ${timeLeft <= 10 ? 'text-red-400' : 'text-white'}`} />
            <span className={`text-2xl font-bold ${timeLeft <= 10 ? 'text-red-400' : 'text-white'}`}>
              {timeLeft}
            </span>
          </motion.div>
        </div>

        {/* Stats Bar */}
        <div className="flex items-center gap-2 mt-4">
          <div className="flex-1 h-2 bg-white/10 rounded-full overflow-hidden">
            <motion.div
              initial={{ width: 0 }}
              animate={{ width: `${(stats.total / 30) * 100}%` }}
              className="h-full bg-gradient-to-r from-yellow-500 to-orange-500"
            />
          </div>
          <span className="text-sm font-bold text-white">{stats.total} swipes</span>
        </div>
      </div>

      {/* Card */}
      <div className="flex-1 px-4 pb-32">
        <AnimatePresence mode="wait">
          <motion.div
            key={currentListing.id}
            initial={{ opacity: 0, scale: 0.8, x: 50 }}
            animate={{
              opacity: 1,
              scale: 1,
              x: swipeDirection === 'left' ? -1000 : swipeDirection === 'right' ? 1000 : 0,
              y: swipeDirection === 'up' ? -1000 : 0,
            }}
            exit={{ opacity: 0, scale: 0.8 }}
            transition={{ duration: 0.2 }}
            className="relative w-full max-w-md mx-auto h-full glass-medium rounded-2xl overflow-hidden border border-white/10"
          >
            {/* Image */}
            <div className="relative h-full bg-gradient-to-br from-purple-900 to-blue-900">
              {currentListing.image_urls?.[0] && (
                <img
                  src={currentListing.image_urls[0]}
                  alt="Property"
                  className="w-full h-full object-cover"
                />
              )}
              <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent" />

              {/* Quick Info Overlay */}
              <div className="absolute bottom-0 left-0 right-0 p-6">
                <div className="flex items-end justify-between">
                  <div>
                    <h4 className="text-2xl font-bold text-white mb-1">
                      {currentListing.neighborhood}
                    </h4>
                    <p className="text-white/80">{currentListing.bedrooms} bed • {currentListing.bathrooms} bath</p>
                  </div>
                  <div className="px-4 py-2 bg-black/60 backdrop-blur-sm rounded-full border border-white/20">
                    <span className="text-xl font-bold text-white">
                      ${currentListing.price?.toLocaleString()}/mo
                    </span>
                  </div>
                </div>
              </div>

              {/* Swipe Direction Indicator */}
              {swipeDirection === 'left' && (
                <motion.div
                  initial={{ opacity: 0, rotate: -20 }}
                  animate={{ opacity: 1, rotate: -20 }}
                  className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 px-8 py-4 border-4 border-red-500 rounded-2xl transform -rotate-12"
                >
                  <span className="text-4xl font-bold text-red-500">PASS</span>
                </motion.div>
              )}

              {swipeDirection === 'right' && (
                <motion.div
                  initial={{ opacity: 0, rotate: 20 }}
                  animate={{ opacity: 1, rotate: 20 }}
                  className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 px-8 py-4 border-4 border-green-500 rounded-2xl transform rotate-12"
                >
                  <span className="text-4xl font-bold text-green-500">LIKE</span>
                </motion.div>
              )}

              {swipeDirection === 'up' && (
                <motion.div
                  initial={{ opacity: 0, scale: 0.5 }}
                  animate={{ opacity: 1, scale: 1 }}
                  className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 px-8 py-4 border-4 border-purple-500 rounded-2xl"
                >
                  <span className="text-4xl font-bold text-purple-500">LOVE</span>
                </motion.div>
              )}
            </div>
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Action Buttons */}
      <div className="fixed bottom-24 left-0 right-0 z-20">
        <div className="max-w-md mx-auto px-6">
          <div className="flex items-center justify-center gap-4">
            {/* Pass */}
            <motion.button
              whileTap={{ scale: 0.9 }}
              onClick={() => handleSwipe('left')}
              className="w-16 h-16 rounded-full bg-red-500/20 backdrop-blur-sm border-2 border-red-500 flex items-center justify-center text-red-500 hover:bg-red-500/30 transition-all shadow-lg"
            >
              <X className="w-8 h-8" />
            </motion.button>

            {/* Love */}
            <motion.button
              whileTap={{ scale: 0.9 }}
              onClick={() => handleSwipe('up')}
              className="w-20 h-20 rounded-full bg-gradient-to-br from-yellow-500 to-orange-500 flex items-center justify-center text-white hover:scale-110 transition-all shadow-2xl"
            >
              <Sparkles className="w-10 h-10" />
            </motion.button>

            {/* Like */}
            <motion.button
              whileTap={{ scale: 0.9 }}
              onClick={() => handleSwipe('right')}
              className="w-16 h-16 rounded-full bg-green-500/20 backdrop-blur-sm border-2 border-green-500 flex items-center justify-center text-green-500 hover:bg-green-500/30 transition-all shadow-lg"
            >
              <Heart className="w-8 h-8" />
            </motion.button>
          </div>

          {/* Keyboard hints */}
          <div className="mt-4 flex justify-center gap-4 text-white/40 text-xs">
            <span>← Pass</span>
            <span>→ Like</span>
            <span>↑ Love</span>
          </div>
        </div>
      </div>
    </div>
  );
}
