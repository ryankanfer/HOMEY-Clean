'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { auth, db, supabase } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';
import type { Listing } from '@/lib/types';
import SwipeCard from '@/components/SwipeCard';
import CinematicBackground from '@/components/CinematicBackground';
import BottomNav from '@/components/BottomNav';
import {
  X, Heart, Sparkles, Undo, SlidersHorizontal,
  TrendingUp, Award, Zap, Info, ChevronLeft
} from 'lucide-react';

interface SwipeHistory {
  listingId: string;
  action: 'pass' | 'like' | 'love';
  listing: Listing;
}

interface MatchReason {
  score: number;
  reasons: string[];
  highlights: string[];
}

export default function MatchmakerPage() {
  const router = useRouter();
  const [userId, setUserId] = useState<string | null>(null);
  const [listings, setListings] = useState<Listing[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loading, setLoading] = useState(true);
  const [swipeHistory, setSwipeHistory] = useState<SwipeHistory[]>([]);
  const [stats, setStats] = useState({ total: 0, likes: 0, loves: 0, passes: 0 });
  const [showFilters, setShowFilters] = useState(false);
  const [showStats, setShowStats] = useState(false);
  const [matchReasons, setMatchReasons] = useState<Map<string, MatchReason>>(new Map());
  const [streak, setStreak] = useState(0);
  const [filters, setFilters] = useState({
    maxPrice: 5000,
    minBedrooms: 0,
    neighborhoods: [] as string[],
    dealBreakers: {
      noGroundFloor: false,
      mustHaveParking: false,
      mustHaveLaundry: false,
    }
  });

  useEffect(() => {
    loadUser();
    analytics.pageView('matchmaker');

    // Keyboard shortcuts
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
      } else if (e.key === 'z' || e.key === 'Z') {
        e.preventDefault();
        handleUndo();
      }
    };

    window.addEventListener('keydown', handleKeyPress);
    return () => window.removeEventListener('keydown', handleKeyPress);
  }, []);

  useEffect(() => {
    if (userId) {
      loadListings();
      loadStats();
      loadStreak();
    }
  }, [userId, filters]);

  const loadUser = async () => {
    try {
      const { data: { user } } = await auth.getUser();
      if (!user) {
        router.push('/login');
        return;
      }
      setUserId(user.id);
    } catch (error) {
      console.error('Failed to load user:', error);
    }
  };

  const loadListings = async () => {
    if (!userId) return;

    setLoading(true);
    try {
      // Get unswipped listings with smart scoring
      const { data, error } = await db.getUnswipedListings(userId, 20);

      if (error) throw error;

      if (data && data.length > 0) {
        // Calculate match reasons for each listing
        const reasonsMap = new Map<string, MatchReason>();
        for (const listing of data) {
          const reason = await calculateMatchReason(listing);
          reasonsMap.set(listing.id, reason);
        }

        // Sort by match score
        const sortedListings = [...data].sort((a, b) => {
          const scoreA = reasonsMap.get(a.id)?.score || 0;
          const scoreB = reasonsMap.get(b.id)?.score || 0;
          return scoreB - scoreA;
        });

        setListings(sortedListings);
        setMatchReasons(reasonsMap);
      } else {
        // No more listings
        setListings([]);
      }
    } catch (error) {
      console.error('Failed to load listings:', error);
    } finally {
      setLoading(false);
    }
  };

  const calculateMatchReason = async (listing: Listing): Promise<MatchReason> => {
    if (!userId) return { score: 50, reasons: [], highlights: [] };

    try {
      // Get user's learned preferences
      const { data: prefs } = await db.getUserLearnedPreferences(userId);

      let score = 50; // Base score
      const reasons: string[] = [];
      const highlights: string[] = [];

      if (prefs) {
        // Price match
        if (prefs.avg_price_liked && listing.price) {
          const priceDiff = Math.abs(listing.price - prefs.avg_price_liked);
          const priceMatch = Math.max(0, 100 - (priceDiff / prefs.avg_price_liked) * 100);
          score += priceMatch * 0.3;

          if (priceMatch > 80) {
            reasons.push(`Perfect price range - ${Math.round(priceMatch)}% match`);
            highlights.push('price');
          }
        }

        // Neighborhood preference
        if (prefs.loved_neighborhoods && prefs.loved_neighborhoods.includes(listing.neighborhood)) {
          score += 20;
          reasons.push(`You loved ${listing.neighborhood} before`);
          highlights.push('neighborhood');
        }

        // Bedroom preference
        if (prefs.preferred_bedrooms && prefs.preferred_bedrooms.includes(listing.bedrooms)) {
          score += 10;
          reasons.push(`${listing.bedrooms} bed matches your preference`);
          highlights.push('bedrooms');
        }

        // Feature matching
        if (prefs.loved_features && listing.features) {
          const matchedFeatures = listing.features.filter(f =>
            prefs.loved_features.includes(f)
          );
          if (matchedFeatures.length > 0) {
            score += matchedFeatures.length * 5;
            reasons.push(`Has ${matchedFeatures.length} features you love`);
            highlights.push(...matchedFeatures);
          }
        }

        // Property type match
        if (prefs.loved_property_types && listing.property_type &&
            prefs.loved_property_types.includes(listing.property_type)) {
          score += 10;
          reasons.push(`${listing.property_type} is your favorite type`);
          highlights.push('property_type');
        }
      }

      // New to market bonus
      if (listing.is_new_to_market) {
        score += 5;
        reasons.push('Just listed - be the first to see it!');
        highlights.push('new');
      }

      // Featured bonus
      if (listing.is_featured) {
        score += 3;
        highlights.push('featured');
      }

      return {
        score: Math.min(100, Math.round(score)),
        reasons: reasons.slice(0, 3), // Top 3 reasons
        highlights
      };
    } catch (error) {
      console.error('Error calculating match:', error);
      return { score: 50, reasons: [], highlights: [] };
    }
  };

  const loadStats = async () => {
    if (!userId) return;

    try {
      const { data } = await db.getSwipeStats(userId);
      if (data) {
        setStats(data);
      }
    } catch (error) {
      console.error('Failed to load stats:', error);
    }
  };

  const loadStreak = async () => {
    if (!userId) return;

    try {
      // Calculate streak from swipes in last 7 days
      const { data } = await supabase
        .from('user_swipes')
        .select('created_at')
        .eq('user_id', userId)
        .gte('created_at', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString())
        .order('created_at', { ascending: false });

      if (data && data.length > 0) {
        // Count consecutive days
        const dates = new Set(data.map(s => new Date(s.created_at).toDateString()));
        let currentStreak = 0;
        const today = new Date();

        for (let i = 0; i < 7; i++) {
          const checkDate = new Date(today);
          checkDate.setDate(checkDate.getDate() - i);
          if (dates.has(checkDate.toDateString())) {
            currentStreak++;
          } else {
            break;
          }
        }

        setStreak(currentStreak);
      }
    } catch (error) {
      console.error('Failed to load streak:', error);
    }
  };

  const handleSwipe = async (direction: 'left' | 'right' | 'up') => {
    const currentListing = listings[currentIndex];
    if (!currentListing || !userId) return;

    const action = direction === 'left' ? 'pass' : direction === 'right' ? 'like' : 'love';

    try {
      // Record swipe
      await db.recordSwipe(userId, currentListing.id, action);

      // Save to history
      setSwipeHistory(prev => [{
        listingId: currentListing.id,
        action,
        listing: currentListing
      }, ...prev].slice(0, 3)); // Keep last 3

      // Update stats
      setStats(prev => ({
        total: prev.total + 1,
        likes: prev.likes + (action === 'like' ? 1 : 0),
        loves: prev.loves + (action === 'love' ? 1 : 0),
        passes: prev.passes + (action === 'pass' ? 1 : 0),
      }));

      // Track in analytics
      analytics.trackEvent('swipe', {
        action,
        listing_id: currentListing.id,
        neighborhood: currentListing.neighborhood,
        price: currentListing.price,
        bedrooms: currentListing.bedrooms,
        match_score: matchReasons.get(currentListing.id)?.score,
      });

      // Move to next card
      if (currentIndex < listings.length - 1) {
        setCurrentIndex(currentIndex + 1);

        // Load more listings if running low
        if (currentIndex >= listings.length - 3) {
          loadListings();
        }
      } else {
        // Out of cards
        loadListings();
        setCurrentIndex(0);
      }
    } catch (error) {
      console.error('Failed to record swipe:', error);
    }
  };

  const handleUndo = async () => {
    if (swipeHistory.length === 0) return;

    const lastSwipe = swipeHistory[0];

    try {
      // Delete the last swipe from database
      await supabase
        .from('user_swipes')
        .delete()
        .eq('user_id', userId)
        .eq('listing_id', lastSwipe.listingId);

      // Restore to deck
      setListings(prev => [lastSwipe.listing, ...prev]);
      setSwipeHistory(prev => prev.slice(1));
      setCurrentIndex(0);

      // Update stats
      setStats(prev => ({
        total: Math.max(0, prev.total - 1),
        likes: Math.max(0, prev.likes - (lastSwipe.action === 'like' ? 1 : 0)),
        loves: Math.max(0, prev.loves - (lastSwipe.action === 'love' ? 1 : 0)),
        passes: Math.max(0, prev.passes - (lastSwipe.action === 'pass' ? 1 : 0)),
      }));

      analytics.trackEvent('undo_swipe', {
        action: lastSwipe.action,
        listing_id: lastSwipe.listingId
      });
    } catch (error) {
      console.error('Failed to undo swipe:', error);
    }
  };

  const currentListing = listings[currentIndex];
  const matchReason = currentListing ? matchReasons.get(currentListing.id) : null;

  if (loading) {
    return (
      <main className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 flex items-center justify-center">
        <CinematicBackground timeOfDay="evening" />
        <div className="relative z-10 text-center">
          <div className="w-16 h-16 border-4 border-white/20 border-t-primary rounded-full animate-spin mx-auto mb-4" />
          <p className="text-white/80">Finding your perfect matches...</p>
        </div>
      </main>
    );
  }

  if (!currentListing) {
    return (
      <main className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 flex items-center justify-center p-6">
        <CinematicBackground timeOfDay="evening" />
        <div className="relative z-10 text-center max-w-md">
          <div className="text-6xl mb-4">🎉</div>
          <h2 className="text-3xl font-bold text-white mb-4">You're all caught up!</h2>
          <p className="text-white/80 mb-6">
            You've seen all available properties. Check back soon for new listings!
          </p>
          <button
            onClick={() => router.push('/home')}
            className="px-6 py-3 bg-primary rounded-xl text-white font-semibold hover:bg-primary/90 transition-all"
          >
            Back to Home
          </button>
        </div>
        <BottomNav />
      </main>
    );
  }

  return (
    <main className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 overflow-hidden">
      <CinematicBackground timeOfDay="evening" />

      {/* Header */}
      <div className="relative z-10 p-4 md:p-6">
        <div className="flex items-center justify-between">
          <button
            onClick={() => router.push('/home')}
            className="w-10 h-10 rounded-full bg-white/10 backdrop-blur-sm flex items-center justify-center text-white hover:bg-white/20 transition-all"
          >
            <ChevronLeft className="w-5 h-5" />
          </button>

          <div className="flex items-center gap-3">
            {/* Streak */}
            {streak > 0 && (
              <div className="px-3 py-1.5 rounded-full bg-orange-500/20 backdrop-blur-sm border border-orange-500/30 flex items-center gap-2">
                <Zap className="w-4 h-4 text-orange-400" />
                <span className="text-sm font-bold text-orange-300">{streak} day streak!</span>
              </div>
            )}

            {/* Stats */}
            <button
              onClick={() => setShowStats(!showStats)}
              className="px-3 py-1.5 rounded-full bg-white/10 backdrop-blur-sm border border-white/20 flex items-center gap-2 hover:bg-white/20 transition-all"
            >
              <TrendingUp className="w-4 h-4 text-primary" />
              <span className="text-sm font-semibold text-white">{stats.total} swipes</span>
            </button>

            {/* Filters */}
            <button
              onClick={() => setShowFilters(!showFilters)}
              className="w-10 h-10 rounded-full bg-white/10 backdrop-blur-sm flex items-center justify-center text-white hover:bg-white/20 transition-all"
            >
              <SlidersHorizontal className="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>

      {/* Match Score Banner */}
      {matchReason && matchReason.score >= 70 && (
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          className="relative z-10 px-4 mb-4"
        >
          <div className="bg-gradient-to-r from-primary/20 to-purple-500/20 backdrop-blur-sm border border-primary/30 rounded-2xl p-4">
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 rounded-full bg-gradient-to-br from-primary to-purple-500 flex items-center justify-center">
                <span className="text-white font-bold">{matchReason.score}%</span>
              </div>
              <div className="flex-1">
                <p className="text-white font-semibold mb-1">Great Match!</p>
                <p className="text-white/70 text-sm">
                  {matchReason.reasons[0] || 'Based on your preferences'}
                </p>
              </div>
              <Sparkles className="w-5 h-5 text-primary" />
            </div>
          </div>
        </motion.div>
      )}

      {/* Card Stack */}
      <div className="relative z-10 px-4 md:px-6 pb-32">
        <div className="relative w-full max-w-md mx-auto" style={{ height: '600px' }}>
          <AnimatePresence>
            {listings.slice(currentIndex, currentIndex + 3).map((listing, index) => (
              <div
                key={listing.id}
                className="absolute inset-0"
                style={{
                  zIndex: 3 - index,
                  transform: `scale(${1 - index * 0.05}) translateY(${index * 20}px)`,
                  opacity: 1 - index * 0.3,
                  pointerEvents: index === 0 ? 'auto' : 'none',
                }}
              >
                <SwipeCard
                  listing={listing}
                  onSwipe={index === 0 ? handleSwipe : () => {}}
                />
              </div>
            ))}
          </AnimatePresence>

          {/* Stack depth indicator */}
          <div className="absolute bottom-[-40px] left-1/2 -translate-x-1/2 text-center">
            <p className="text-white/50 text-sm">
              {currentIndex + 1} / {listings.length}
            </p>
          </div>
        </div>
      </div>

      {/* Action Buttons */}
      <div className="fixed bottom-24 left-0 right-0 z-20">
        <div className="max-w-md mx-auto px-6">
          <div className="flex items-center justify-center gap-4">
            {/* Undo */}
            <button
              onClick={handleUndo}
              disabled={swipeHistory.length === 0}
              className="w-14 h-14 rounded-full bg-white/10 backdrop-blur-sm border border-white/20 flex items-center justify-center text-white hover:bg-white/20 transition-all disabled:opacity-30 disabled:cursor-not-allowed"
            >
              <Undo className="w-6 h-6" />
            </button>

            {/* Pass */}
            <button
              onClick={() => handleSwipe('left')}
              className="w-16 h-16 rounded-full bg-red-500/20 backdrop-blur-sm border-2 border-red-500 flex items-center justify-center text-red-500 hover:bg-red-500/30 transition-all shadow-lg"
            >
              <X className="w-8 h-8" />
            </button>

            {/* Love */}
            <button
              onClick={() => handleSwipe('up')}
              className="w-20 h-20 rounded-full bg-gradient-to-br from-primary to-purple-500 flex items-center justify-center text-white hover:scale-110 transition-all shadow-2xl"
            >
              <Sparkles className="w-10 h-10" />
            </button>

            {/* Like */}
            <button
              onClick={() => handleSwipe('right')}
              className="w-16 h-16 rounded-full bg-green-500/20 backdrop-blur-sm border-2 border-green-500 flex items-center justify-center text-green-500 hover:bg-green-500/30 transition-all shadow-lg"
            >
              <Heart className="w-8 h-8" />
            </button>

            {/* Info */}
            <button
              onClick={() => router.push(`/listing/${currentListing.id}`)}
              className="w-14 h-14 rounded-full bg-white/10 backdrop-blur-sm border border-white/20 flex items-center justify-center text-white hover:bg-white/20 transition-all"
            >
              <Info className="w-6 h-6" />
            </button>
          </div>

          {/* Keyboard hints */}
          <div className="mt-4 flex justify-center gap-4 text-white/40 text-xs">
            <span>← Pass</span>
            <span>→ Like</span>
            <span>↑ Love</span>
            <span>Z Undo</span>
          </div>
        </div>
      </div>

      <BottomNav />
    </main>
  );
}
