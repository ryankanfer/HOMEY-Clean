'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { db, auth } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';
import type { Listing } from '@/lib/types';
import CinematicBackground from '@/components/CinematicBackground';
import SwipeCard from '@/components/SwipeCard';
import BottomNav from '@/components/BottomNav';

export default function MatchmakerPage() {
  const router = useRouter();
  const [listings, setListings] = useState<Listing[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loading, setLoading] = useState(true);
  const [userId, setUserId] = useState<string | null>(null);
  const [stats, setStats] = useState({ total: 0, likes: 0, loves: 0, passes: 0 });
  const [showOnboarding, setShowOnboarding] = useState(true);
  const [aiLearning, setAiLearning] = useState(false);
  const [matchScore, setMatchScore] = useState<number | null>(null);
  const [loadingMore, setLoadingMore] = useState(false);

  useEffect(() => {
    analytics.pageView('matchmaker');
    initMatchmaker();
  }, []);

  const initMatchmaker = async () => {
    try {
      // Get user
      const { data: { user } } = await auth.getUser();

      if (!user) {
        router.push('/');
        return;
      }

      setUserId(user.id);

      // Load swipe stats first to check if AI-powered recommendations are available
      const { data: swipeStats } = await db.getSwipeStats(user.id);
      if (swipeStats) {
        setStats(swipeStats);
        // If user has swiped before, skip onboarding
        if (swipeStats.total > 0) {
          setShowOnboarding(false);
        }
      }

      // If user has enough swipe history, use AI-powered recommendations
      if (swipeStats && swipeStats.total >= 10) {
        const { data: aiRecommendations } = await db.getRecommendedListings(user.id, 20);
        if (aiRecommendations && aiRecommendations.length > 0) {
          // Filter out already swiped ones
          const { data: unswipedAI } = await db.getUnswipedListings(user.id, 100);
          const unswipedIds = new Set(unswipedAI?.map(l => l.id) || []);
          const filteredRecommendations = aiRecommendations.filter(l => unswipedIds.has(l.id));

          if (filteredRecommendations.length > 0) {
            setListings(filteredRecommendations);
            setLoading(false);
            return;
          }
        }
      }

      // Fallback to unswiped listings
      const { data: unswipedListings, error } = await db.getUnswipedListings(user.id, 20);

      if (error) throw error;

      if (unswipedListings && unswipedListings.length > 0) {
        setListings(unswipedListings);
      }

      setLoading(false);
    } catch (err) {
      console.error('Failed to initialize matchmaker:', err);
      setLoading(false);
    }
  };

  // Auto-refill when running low
  useEffect(() => {
    if (userId && remainingCount <= 5 && remainingCount > 0 && !loadingMore) {
      loadMoreListings();
    }
  }, [currentIndex, userId]);

  const loadMoreListings = async () => {
    if (!userId || loadingMore) return;

    setLoadingMore(true);
    try {
      // Try AI recommendations first if user has enough data
      if (stats.total >= 10) {
        const { data: moreRecommendations } = await db.getRecommendedListings(userId, 20);
        if (moreRecommendations && moreRecommendations.length > 0) {
          const { data: unswipedAI } = await db.getUnswipedListings(userId, 100);
          const unswipedIds = new Set(unswipedAI?.map(l => l.id) || []);
          const filtered = moreRecommendations.filter(l =>
            unswipedIds.has(l.id) && !listings.find(existing => existing.id === l.id)
          );
          if (filtered.length > 0) {
            setListings(prev => [...prev, ...filtered]);
            setLoadingMore(false);
            return;
          }
        }
      }

      // Fallback to regular unswiped
      const { data: moreListings } = await db.getUnswipedListings(userId, 20);
      if (moreListings && moreListings.length > 0) {
        const newListings = moreListings.filter(l => !listings.find(existing => existing.id === l.id));
        setListings(prev => [...prev, ...newListings]);
      }
    } catch (err) {
      console.error('Failed to load more listings:', err);
    } finally {
      setLoadingMore(false);
    }
  };

  const handleSwipe = async (direction: 'left' | 'right' | 'up') => {
    if (!userId || currentIndex >= listings.length) return;

    const currentListing = listings[currentIndex];
    const action = direction === 'left' ? 'pass' : direction === 'right' ? 'like' : 'love';

    // Show AI learning feedback
    setAiLearning(true);
    setTimeout(() => setAiLearning(false), 1500);

    // Record swipe
    const { data, error } = await db.recordSwipe(userId, currentListing.id, action);
    if (error) {
      console.error('Failed to record swipe:', error);
      console.error('Swipe details:', { userId, listingId: currentListing.id, action });
    } else {
      console.log('Swipe recorded successfully:', { userId, listingId: currentListing.id, action });
    }

    // Track analytics
    analytics.click(`swipe_${action}`, 'card', {
      listing_id: currentListing.id,
      price: currentListing.price,
      neighborhood: currentListing.neighborhood,
    });

    // Update stats
    const newStats = {
      total: stats.total + 1,
      likes: stats.likes + (action === 'like' ? 1 : 0),
      loves: stats.loves + (action === 'love' ? 1 : 0),
      passes: stats.passes + (action === 'pass' ? 1 : 0),
    };
    setStats(newStats);

    // Calculate match score for next card if available
    if (currentIndex + 1 < listings.length) {
      const nextListing = listings[currentIndex + 1];
      if ('match_score' in nextListing) {
        setMatchScore((nextListing as any).match_score);
      } else {
        setMatchScore(null);
      }
    }

    // Move to next card
    setTimeout(() => {
      setCurrentIndex(prev => prev + 1);
    }, 300);
  };

  const handleButtonSwipe = (direction: 'left' | 'right' | 'up') => {
    handleSwipe(direction);
  };

  const currentListing = listings[currentIndex];
  const remainingCount = listings.length - currentIndex;

  if (loading) {
    return (
      <main className="relative min-h-screen flex items-center justify-center">
        <CinematicBackground timeOfDay="day" />
        <div className="text-white text-2xl">Loading...</div>
      </main>
    );
  }

  return (
    <main className="relative min-h-screen pb-24">
      <CinematicBackground timeOfDay="day" />

      {/* Header */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-gradient-to-b from-black/80 via-black/60 to-transparent backdrop-blur-md">
        <div className="px-5 py-4">
          <div className="flex items-center justify-between">
            <button
              onClick={() => router.back()}
              className="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center text-xl hover:bg-white/20 transition-colors text-white"
            >
              ←
            </button>
            <div className="text-center">
              <div className="flex items-center gap-2 justify-center">
                <h1 className="text-xl font-bold text-white">Matchmaker</h1>
                {stats.total >= 10 && (
                  <motion.div
                    className="px-2 py-1 bg-primary/20 rounded-full text-xs font-bold text-primary border border-primary/30"
                    animate={{ scale: aiLearning ? [1, 1.1, 1] : 1 }}
                    transition={{ duration: 0.3 }}
                  >
                    AI Mode
                  </motion.div>
                )}
              </div>
              <div className="flex items-center gap-2 justify-center text-xs text-white/60 mt-1">
                <span>{remainingCount} remaining</span>
                {loadingMore && (
                  <>
                    <span>•</span>
                    <span className="text-primary">Loading more...</span>
                  </>
                )}
              </div>
            </div>
            <div className="w-10 h-10" /> {/* Spacer */}
          </div>
        </div>

        {/* AI Learning Indicator */}
        <AnimatePresence>
          {aiLearning && (
            <motion.div
              className="mx-5 mb-3 p-3 bg-primary/20 border border-primary/30 rounded-xl backdrop-blur-sm"
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
            >
              <div className="flex items-center gap-2">
                <motion.div
                  className="w-2 h-2 rounded-full bg-primary"
                  animate={{ opacity: [0.5, 1, 0.5] }}
                  transition={{ duration: 1, repeat: Infinity }}
                />
                <span className="text-white text-sm font-semibold">
                  Scout is learning your preferences...
                </span>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </header>

      {/* Onboarding Overlay */}
      <AnimatePresence>
        {showOnboarding && (
          <motion.div
            className="fixed inset-0 z-[100] flex items-center justify-center bg-black/80 backdrop-blur-sm px-5"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          >
            <motion.div
              className="max-w-md w-full glass-strong rounded-3xl p-8 text-center"
              initial={{ scale: 0.9, y: 20 }}
              animate={{ scale: 1, y: 0 }}
              transition={{ delay: 0.1 }}
            >
              <div className="text-6xl mb-4">💘</div>
              <h2 className="text-3xl font-bold text-white mb-4">Find Your Perfect Home</h2>
              <p className="text-white/80 mb-8">
                Swipe through properties to help us learn your taste. The more you swipe, the better our recommendations!
              </p>

              <div className="space-y-4 mb-8">
                <div className="flex items-center gap-4 text-left">
                  <div className="w-12 h-12 rounded-full bg-red-500/20 flex items-center justify-center text-2xl">←</div>
                  <div>
                    <div className="text-white font-bold">Swipe Left</div>
                    <div className="text-white/60 text-sm">Not interested</div>
                  </div>
                </div>
                <div className="flex items-center gap-4 text-left">
                  <div className="w-12 h-12 rounded-full bg-green-500/20 flex items-center justify-center text-2xl">→</div>
                  <div>
                    <div className="text-white font-bold">Swipe Right</div>
                    <div className="text-white/60 text-sm">I like this</div>
                  </div>
                </div>
                <div className="flex items-center gap-4 text-left">
                  <div className="w-12 h-12 rounded-full bg-primary/20 flex items-center justify-center text-2xl">↑</div>
                  <div>
                    <div className="text-white font-bold">Swipe Up</div>
                    <div className="text-white/60 text-sm">Love it! Save this</div>
                  </div>
                </div>
              </div>

              <button
                onClick={() => setShowOnboarding(false)}
                className="w-full px-8 py-4 bg-primary text-white rounded-full font-bold hover:bg-primary/90 transition-colors"
              >
                Start Swiping
              </button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Swipe Cards */}
      <div className="relative z-10 pt-24 px-5">
        {remainingCount === 0 ? (
          <motion.div
            className="h-[600px] flex flex-col items-center justify-center text-center"
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
          >
            <div className="text-8xl mb-6">🎉</div>
            <h2 className="text-4xl font-bold text-white mb-4">You're All Caught Up!</h2>
            <p className="text-xl text-white/80 mb-8">
              You've swiped through all available properties.
            </p>
            <div className="glass-strong rounded-2xl p-6 mb-8">
              <div className="grid grid-cols-3 gap-6 text-center">
                <div>
                  <div className="text-3xl font-bold text-white">{stats.loves}</div>
                  <div className="text-white/60 text-sm">Loved</div>
                </div>
                <div>
                  <div className="text-3xl font-bold text-white">{stats.likes}</div>
                  <div className="text-white/60 text-sm">Liked</div>
                </div>
                <div>
                  <div className="text-3xl font-bold text-white">{stats.passes}</div>
                  <div className="text-white/60 text-sm">Passed</div>
                </div>
              </div>
            </div>
            <button
              onClick={() => router.push('/home')}
              className="px-8 py-4 bg-primary text-white rounded-full font-bold hover:bg-primary/90 transition-colors"
            >
              View Your Recommendations
            </button>
          </motion.div>
        ) : (
          <>
            {/* Card Stack */}
            <div className="relative h-[600px] max-w-md mx-auto">
              <AnimatePresence>
                {listings.slice(currentIndex, currentIndex + 3).map((listing, index) => (
                  <SwipeCard
                    key={listing.id}
                    listing={listing}
                    onSwipe={index === 0 ? handleSwipe : () => {}}
                    style={{
                      zIndex: 3 - index,
                      scale: 1 - index * 0.05,
                      y: index * 10,
                      opacity: 1 - index * 0.3,
                      pointerEvents: index === 0 ? 'auto' : 'none',
                    }}
                  />
                ))}
              </AnimatePresence>
            </div>

            {/* Match Score Badge */}
            {matchScore !== null && stats.total >= 10 && (
              <motion.div
                className="flex items-center justify-center mt-6"
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: 0.2 }}
              >
                <div className="glass-strong rounded-full px-6 py-3 border border-primary/30">
                  <div className="flex items-center gap-2">
                    <span className="text-white/60 text-sm">Match Score:</span>
                    <span className="text-2xl font-bold text-primary">
                      {Math.round(matchScore)}%
                    </span>
                    <motion.div
                      className="text-xl"
                      animate={{ rotate: [0, 10, -10, 0] }}
                      transition={{ duration: 2, repeat: Infinity }}
                    >
                      ✨
                    </motion.div>
                  </div>
                </div>
              </motion.div>
            )}

            {/* Action Buttons */}
            <div className="flex items-center justify-center gap-4 mt-8">
              <motion.button
                onClick={() => handleButtonSwipe('left')}
                className="w-16 h-16 rounded-full bg-red-500/20 hover:bg-red-500/30 flex items-center justify-center text-3xl transition-colors border-2 border-red-500/50"
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
              >
                ✕
              </motion.button>
              <motion.button
                onClick={() => handleButtonSwipe('up')}
                className="w-20 h-20 rounded-full bg-primary/20 hover:bg-primary/30 flex items-center justify-center text-4xl transition-colors border-2 border-primary/50"
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
              >
                ❤️
              </motion.button>
              <motion.button
                onClick={() => handleButtonSwipe('right')}
                className="w-16 h-16 rounded-full bg-green-500/20 hover:bg-green-500/30 flex items-center justify-center text-3xl transition-colors border-2 border-green-500/50"
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
              >
                ✓
              </motion.button>
            </div>

            {/* Stats and Progress */}
            <div className="mt-6 space-y-3">
              <div className="flex items-center justify-center gap-6 text-white/60 text-sm">
                <span>{stats.total} total</span>
                <span>•</span>
                <span>{stats.loves} ❤️</span>
                <span>•</span>
                <span>{stats.likes} liked</span>
              </div>

              {/* AI Mode Progress */}
              {stats.total < 10 && (
                <motion.div
                  className="max-w-xs mx-auto glass-strong rounded-xl p-4"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                >
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-white/80 text-sm">Unlock AI Recommendations</span>
                    <span className="text-primary text-sm font-bold">{stats.total}/10</span>
                  </div>
                  <div className="w-full h-2 bg-white/10 rounded-full overflow-hidden">
                    <motion.div
                      className="h-full bg-gradient-to-r from-primary to-purple-500"
                      initial={{ width: 0 }}
                      animate={{ width: `${(stats.total / 10) * 100}%` }}
                      transition={{ duration: 0.5 }}
                    />
                  </div>
                </motion.div>
              )}
            </div>
          </>
        )}
      </div>

      {/* Bottom Navigation */}
      <BottomNav />
    </main>
  );
}
