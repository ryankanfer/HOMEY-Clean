'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { auth, db, supabase } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';
import type { Listing } from '@/lib/types';
import SwipeCard from '@/components/SwipeCard';
import EnhancedSwipeCard from '@/components/EnhancedSwipeCard';
import CinematicBackground from '@/components/CinematicBackground';
import BottomNav from '@/components/BottomNav';
import InsightsModal from '@/components/matchmaker/InsightsModal';
import SocialPanel from '@/components/matchmaker/SocialPanel';
import ListingDetailsModal from '@/components/matchmaker/ListingDetailsModal';
import GameModeSelector, { type GameMode } from '@/components/matchmaker/GameModeSelector';
import GameModeLanding from '@/components/matchmaker/GameModeLanding';
import ThisOrThatBattle from '@/components/matchmaker/ThisOrThatBattle';
import GuessTheRent from '@/components/matchmaker/GuessTheRent';
import SpeedRound from '@/components/matchmaker/SpeedRound';
import BuildYourDream from '@/components/matchmaker/BuildYourDream';
import MysteryBox from '@/components/matchmaker/MysteryBox';
import {
  X, Heart, Sparkles, Undo, SlidersHorizontal,
  TrendingUp, Award, Zap, Info, ChevronLeft, Home, DollarSign, Bed, Users, Lightbulb, Gamepad2
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
  const [showInsights, setShowInsights] = useState(false);
  const [showSocial, setShowSocial] = useState(false);
  const [selectedListing, setSelectedListing] = useState<Listing | null>(null);
  const [matchReasons, setMatchReasons] = useState<Map<string, MatchReason>>(new Map());
  const [streak, setStreak] = useState(0);
  const [swipesUntilInsight, setSwipesUntilInsight] = useState(10);
  const [preferenceProfile, setPreferenceProfile] = useState<any>(null);
  const [recentInsights, setRecentInsights] = useState<any[]>([]);
  const [currentGameMode, setCurrentGameMode] = useState<GameMode | null>(null);
  const [showGameModeSelector, setShowGameModeSelector] = useState(false);
  const [dailyBoxesRemaining, setDailyBoxesRemaining] = useState(3);
  const [neighborhoods, setNeighborhoods] = useState<string[]>([]);
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

  const getPreferenceProfile = async () => {
    if (!userId) return {
      topNeighborhoods: [],
      avgPrice: 0,
      priceRange: { min: 0, max: 0 },
      lovedFeatures: [],
      preferredBedrooms: [],
      propertyTypes: []
    };

    try {
      // Get user preferences from database
      const { data: prefs } = await db.getUserPreferences(userId);

      // Build preference profile from stats and preferences
      const profile = {
        topNeighborhoods: prefs?.loved_neighborhoods?.slice(0, 3).map((n: string, i: number) => ({
          name: n,
          count: Math.max(1, stats.loves - i * 2)
        })) || [],
        avgPrice: prefs?.avg_price_liked || 0,
        priceRange: {
          min: prefs?.min_price_liked || 0,
          max: prefs?.max_price_liked || 0
        },
        lovedFeatures: prefs?.loved_features?.slice(0, 6).map((f: string, i: number) => ({
          feature: f,
          count: Math.max(1, Math.floor(stats.loves / 2) - i)
        })) || [],
        preferredBedrooms: prefs?.preferred_bedrooms || [2],
        propertyTypes: prefs?.preferred_property_types?.map((t: string, i: number) => ({
          type: t,
          count: Math.max(1, stats.loves - i * 3)
        })) || []
      };

      return profile;
    } catch (error) {
      console.error('Failed to get preference profile:', error);
      return {
        topNeighborhoods: [],
        avgPrice: 0,
        priceRange: { min: 0, max: 0 },
        lovedFeatures: [],
        preferredBedrooms: [],
        propertyTypes: []
      };
    }
  };

  const handleSwipe = async (direction: 'left' | 'right' | 'up') => {
    const currentListing = listings[currentIndex];
    if (!currentListing || !userId) return;

    const action: 'pass' | 'like' | 'love' = direction === 'left' ? 'pass' : direction === 'right' ? 'like' : 'love';

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

      // Auto-show insights after every 10 swipes
      const newSwipesUntilInsight = swipesUntilInsight - 1;
      setSwipesUntilInsight(newSwipesUntilInsight);
      if (newSwipesUntilInsight <= 0) {
        setSwipesUntilInsight(10); // Reset counter
        // Load preference profile and show insights
        getPreferenceProfile().then(profile => {
          setPreferenceProfile(profile);
          setTimeout(() => setShowInsights(true), 500); // Show after animation
        });
      }

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
        <CinematicBackground timeOfDay="sunset" />
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
        <CinematicBackground timeOfDay="sunset" />
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
      <CinematicBackground timeOfDay="sunset" />

      {/* Header */}
      <div className="relative z-10 p-4 md:p-6">
        <div className="flex items-center justify-between">
          {currentGameMode ? (
            <button
              onClick={() => setCurrentGameMode(null)}
              className="w-10 h-10 rounded-full bg-white/10 backdrop-blur-sm flex items-center justify-center text-white hover:bg-white/20 transition-all"
            >
              <Home className="w-5 h-5" />
            </button>
          ) : (
            <button
              onClick={() => router.push('/home')}
              className="w-10 h-10 rounded-full bg-white/10 backdrop-blur-sm flex items-center justify-center text-white hover:bg-white/20 transition-all"
            >
              <ChevronLeft className="w-5 h-5" />
            </button>
          )}

          <div className="flex items-center gap-3">
            {/* Streak */}
            {streak > 0 && (
              <div className="px-3 py-1.5 rounded-full bg-orange-500/20 backdrop-blur-sm border border-orange-500/30 flex items-center gap-2">
                <Zap className="w-4 h-4 text-orange-400" />
                <span className="text-sm font-bold text-orange-300">{streak} day streak!</span>
              </div>
            )}

            {/* Filters */}
            <button
              onClick={() => setShowFilters(!showFilters)}
              className="w-10 h-10 rounded-full bg-white/10 backdrop-blur-sm flex items-center justify-center text-white hover:bg-white/20 transition-all"
            >
              <SlidersHorizontal className="w-5 h-5" />
            </button>

            {/* Insights */}
            <button
              onClick={async () => {
                if (!showInsights && !preferenceProfile) {
                  const profile = await getPreferenceProfile();
                  setPreferenceProfile(profile);
                }
                setShowInsights(!showInsights);
              }}
              className="w-10 h-10 rounded-full bg-white/10 backdrop-blur-sm flex items-center justify-center text-white hover:bg-white/20 transition-all"
            >
              <Lightbulb className="w-5 h-5" />
            </button>

            {/* Social */}
            <button
              onClick={() => setShowSocial(!showSocial)}
              className="w-10 h-10 rounded-full bg-white/10 backdrop-blur-sm flex items-center justify-center text-white hover:bg-white/20 transition-all"
            >
              <Users className="w-5 h-5" />
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

      {/* Game Mode Content */}
      <div className="relative z-10 flex-1 overflow-hidden">
        {/* Landing Page */}
        {!currentGameMode && (
          <GameModeLanding
            onSelectMode={setCurrentGameMode}
            userStats={{
              totalSwipes: stats.total,
              streak: streak,
            }}
          />
        )}

        {/* Classic Swipe Mode */}
        {currentGameMode === 'swipe' && (
          <>
            {/* Card Stack */}
            <div className="relative z-10 px-4 md:px-6 pb-32">
              <div className="relative w-full max-w-md mx-auto" style={{ height: '600px' }}>
                <AnimatePresence>
                  {listings.slice(currentIndex, currentIndex + 3).map((listing, index) => {
                    const reason = matchReasons.get(listing.id);
                    return (
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
                        <EnhancedSwipeCard
                          listing={listing}
                          onSwipe={index === 0 ? handleSwipe : () => {}}
                          onClick={index === 0 ? () => setSelectedListing(listing) : undefined}
                          matchScore={reason?.score}
                          matchReasons={reason?.reasons}
                          highlights={reason?.highlights}
                        />
                      </div>
                    );
                  })}
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
          </>
        )}

        {/* This or That Battle Mode */}
        {currentGameMode === 'battle' && (
          <ThisOrThatBattle
            listings={listings}
            onChoice={(winner, loser) => {
              handleSwipe('up'); // Record love for winner
              analytics.trackEvent('battle_choice', {
                winner_id: winner.id,
                loser_id: loser.id,
              });
            }}
            onComplete={() => setCurrentGameMode('swipe')}
          />
        )}

        {/* Guess the Rent Mode */}
        {currentGameMode === 'guess' && (
          <GuessTheRent
            listings={listings}
            onGuess={(listing, guess, accuracy) => {
              analytics.trackEvent('guess_rent', {
                listing_id: listing.id,
                actual_price: listing.price,
                guessed_price: guess,
                accuracy,
              });
            }}
          />
        )}

        {/* Speed Round Mode */}
        {currentGameMode === 'speed' && (
          <SpeedRound
            listings={listings}
            onSwipe={(listing, action) => {
              // SpeedRound handles the listing internally, we just need to record it
              db.recordSwipe(userId!, listing.id, action);
            }}
            onComplete={(speedStats) => {
              analytics.trackEvent('speed_round_complete', speedStats);
              setCurrentGameMode('swipe');
            }}
          />
        )}

        {/* Build Your Dream Mode */}
        {currentGameMode === 'build' && (
          <BuildYourDream
            neighborhoods={neighborhoods.length > 0 ? neighborhoods : ['Downtown', 'Midtown', 'Upper East', 'Brooklyn Heights']}
            onComplete={(config, price) => {
              analytics.trackEvent('dream_home_built', {
                config,
                estimated_price: price,
              });
              setCurrentGameMode('swipe');
            }}
          />
        )}

        {/* Mystery Box Mode */}
        {currentGameMode === 'mystery' && (
          <MysteryBox
            listings={listings}
            onReveal={(listing, action) => {
              if (action === 'love') {
                handleSwipe('up');
              } else {
                handleSwipe('left');
              }
              setDailyBoxesRemaining(prev => Math.max(0, prev - 1));
              analytics.trackEvent('mystery_box_reveal', {
                listing_id: listing.id,
                action,
              });
            }}
            dailyBoxesRemaining={dailyBoxesRemaining}
          />
        )}
      </div>

      {/* Stats Modal */}
      <AnimatePresence>
        {showStats && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <motion.div
              key="stats-backdrop"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setShowStats(false)}
              className="absolute inset-0 bg-black/60 backdrop-blur-sm"
            />

            <motion.div
              key="stats-modal"
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.9 }}
              className="relative glass-strong rounded-2xl p-6 max-w-md w-full border border-white/10"
            >
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-white">Your Stats</h3>
                <button
                  onClick={() => setShowStats(false)}
                  className="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center text-white hover:bg-white/20 transition-all"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>

              <div className="space-y-4">
                {/* Total Swipes */}
                <div className="glass-medium rounded-xl p-4 border border-white/10">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 to-blue-500 flex items-center justify-center">
                        <TrendingUp className="w-5 h-5 text-white" />
                      </div>
                      <div>
                        <p className="text-white/60 text-sm">Total Swipes</p>
                        <p className="text-2xl font-bold text-white">{stats.total}</p>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Loves */}
                <div className="glass-medium rounded-xl p-4 border border-white/10">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center">
                        <Sparkles className="w-5 h-5 text-white" />
                      </div>
                      <div>
                        <p className="text-white/60 text-sm">Loves</p>
                        <p className="text-2xl font-bold text-white">{stats.loves}</p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-white/40 text-xs">
                        {stats.total > 0 ? Math.round((stats.loves / stats.total) * 100) : 0}%
                      </p>
                    </div>
                  </div>
                </div>

                {/* Likes */}
                <div className="glass-medium rounded-xl p-4 border border-white/10">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-gradient-to-br from-green-500 to-emerald-500 flex items-center justify-center">
                        <Heart className="w-5 h-5 text-white" />
                      </div>
                      <div>
                        <p className="text-white/60 text-sm">Likes</p>
                        <p className="text-2xl font-bold text-white">{stats.likes}</p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-white/40 text-xs">
                        {stats.total > 0 ? Math.round((stats.likes / stats.total) * 100) : 0}%
                      </p>
                    </div>
                  </div>
                </div>

                {/* Passes */}
                <div className="glass-medium rounded-xl p-4 border border-white/10">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-gradient-to-br from-red-500 to-orange-500 flex items-center justify-center">
                        <X className="w-5 h-5 text-white" />
                      </div>
                      <div>
                        <p className="text-white/60 text-sm">Passes</p>
                        <p className="text-2xl font-bold text-white">{stats.passes}</p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-white/40 text-xs">
                        {stats.total > 0 ? Math.round((stats.passes / stats.total) * 100) : 0}%
                      </p>
                    </div>
                  </div>
                </div>

                {/* Streak */}
                {streak > 0 && (
                  <div className="glass-medium rounded-xl p-4 border border-orange-500/30 bg-orange-500/10">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-gradient-to-br from-orange-500 to-yellow-500 flex items-center justify-center">
                        <Zap className="w-5 h-5 text-white" />
                      </div>
                      <div>
                        <p className="text-white/60 text-sm">Current Streak</p>
                        <p className="text-2xl font-bold text-orange-300">{streak} days 🔥</p>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* Filters Modal */}
      <AnimatePresence>
        {showFilters && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <motion.div
              key="filters-backdrop"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setShowFilters(false)}
              className="absolute inset-0 bg-black/60 backdrop-blur-sm"
            />

            <motion.div
              key="filters-modal"
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.9 }}
              className="relative glass-strong rounded-2xl p-6 max-w-md w-full border border-white/10 max-h-[80vh] overflow-y-auto"
            >
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold text-white">Your Preferences</h3>
                <button
                  onClick={() => setShowFilters(false)}
                  className="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center text-white hover:bg-white/20 transition-all"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>

              {/* Homey Brain Section */}
              <div className="mb-6 p-4 bg-gradient-to-br from-primary/20 to-purple-500/20 border border-primary/30 rounded-xl">
                <div className="flex items-start gap-3 mb-3">
                  <div className="w-10 h-10 bg-gradient-to-br from-primary to-purple-500 rounded-lg flex items-center justify-center flex-shrink-0">
                    <Sparkles className="w-5 h-5 text-white" />
                  </div>
                  <div className="flex-1">
                    <h4 className="text-sm font-bold text-white mb-1">Homey Brain</h4>
                    <p className="text-xs text-white/70">Here's what we learned from your onboarding</p>
                  </div>
                </div>
                <div className="space-y-2">
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-white/60">Budget:</span>
                    <span className="text-white font-medium">Up to ${filters.maxPrice.toLocaleString()}/mo</span>
                  </div>
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-white/60">Bedrooms:</span>
                    <span className="text-white font-medium">
                      {filters.minBedrooms === 0 ? 'Any' : `${filters.minBedrooms}+ bed`}
                    </span>
                  </div>
                  {filters.neighborhoods.length > 0 && (
                    <div className="flex items-start justify-between text-sm">
                      <span className="text-white/60">Areas:</span>
                      <span className="text-white font-medium text-right">
                        {filters.neighborhoods.join(', ')}
                      </span>
                    </div>
                  )}
                </div>
                <div className="mt-3 pt-3 border-t border-white/20">
                  <p className="text-xs text-primary font-medium">
                    ✨ Customize below to refine your search
                  </p>
                </div>
              </div>

              <div className="space-y-6">
                {/* Max Price */}
                <div>
                  <label className="flex items-center gap-2 text-white/80 text-sm font-medium mb-3">
                    <DollarSign className="w-4 h-4" />
                    Max Monthly Rent
                  </label>
                  <div className="relative">
                    <span className="absolute left-4 top-1/2 -translate-y-1/2 text-white/60 text-lg">
                      $
                    </span>
                    <input
                      type="number"
                      min="0"
                      step="100"
                      value={filters.maxPrice}
                      onChange={(e) => setFilters({ ...filters, maxPrice: parseInt(e.target.value) || 0 })}
                      placeholder="5000"
                      className="w-full pl-8 pr-16 py-3 bg-white/10 border border-white/20 rounded-xl text-white text-lg focus:outline-none focus:border-primary transition-all"
                    />
                    <span className="absolute right-4 top-1/2 -translate-y-1/2 text-white/40 text-sm">
                      /month
                    </span>
                  </div>
                  <p className="text-xs text-white/40 mt-2">
                    Only show properties at or below this price
                  </p>
                </div>

                {/* Min Bedrooms */}
                <div>
                  <label className="flex items-center gap-2 text-white/80 text-sm font-medium mb-2">
                    <Bed className="w-4 h-4" />
                    Min Bedrooms: {filters.minBedrooms === 0 ? 'Any' : filters.minBedrooms}
                  </label>
                  <div className="flex gap-2">
                    {[0, 1, 2, 3, 4].map((num) => (
                      <button
                        key={num}
                        onClick={() => setFilters({ ...filters, minBedrooms: num })}
                        className={`flex-1 py-2 rounded-lg border transition-all ${
                          filters.minBedrooms === num
                            ? 'bg-primary border-primary text-white'
                            : 'bg-white/5 border-white/10 text-white/60 hover:bg-white/10'
                        }`}
                      >
                        {num === 0 ? 'Any' : num}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Deal Breakers */}
                <div>
                  <label className="text-white/80 text-sm font-medium mb-3 block">
                    Deal Breakers
                  </label>
                  <div className="space-y-2">
                    <label className="flex items-center gap-3 p-3 glass-medium rounded-lg border border-white/10 cursor-pointer hover:bg-white/10 transition-all">
                      <input
                        type="checkbox"
                        checked={filters.dealBreakers.noGroundFloor}
                        onChange={(e) => setFilters({
                          ...filters,
                          dealBreakers: { ...filters.dealBreakers, noGroundFloor: e.target.checked }
                        })}
                        className="w-5 h-5 rounded accent-primary"
                      />
                      <span className="text-white/80 text-sm">No ground floor units</span>
                    </label>

                    <label className="flex items-center gap-3 p-3 glass-medium rounded-lg border border-white/10 cursor-pointer hover:bg-white/10 transition-all">
                      <input
                        type="checkbox"
                        checked={filters.dealBreakers.mustHaveParking}
                        onChange={(e) => setFilters({
                          ...filters,
                          dealBreakers: { ...filters.dealBreakers, mustHaveParking: e.target.checked }
                        })}
                        className="w-5 h-5 rounded accent-primary"
                      />
                      <span className="text-white/80 text-sm">Must have parking</span>
                    </label>

                    <label className="flex items-center gap-3 p-3 glass-medium rounded-lg border border-white/10 cursor-pointer hover:bg-white/10 transition-all">
                      <input
                        type="checkbox"
                        checked={filters.dealBreakers.mustHaveLaundry}
                        onChange={(e) => setFilters({
                          ...filters,
                          dealBreakers: { ...filters.dealBreakers, mustHaveLaundry: e.target.checked }
                        })}
                        className="w-5 h-5 rounded accent-primary"
                      />
                      <span className="text-white/80 text-sm">Must have in-unit laundry</span>
                    </label>
                  </div>
                </div>

                {/* Apply Button */}
                <button
                  onClick={() => {
                    setShowFilters(false);
                    setCurrentIndex(0);
                    loadListings();
                  }}
                  className="w-full py-3 bg-gradient-to-r from-primary to-purple-500 rounded-xl text-white font-semibold hover:opacity-90 transition-all"
                >
                  Apply Filters
                </button>

                {/* Reset Button */}
                <button
                  onClick={() => {
                    setFilters({
                      maxPrice: 5000,
                      minBedrooms: 0,
                      neighborhoods: [],
                      dealBreakers: {
                        noGroundFloor: false,
                        mustHaveParking: false,
                        mustHaveLaundry: false,
                      }
                    });
                  }}
                  className="w-full py-2 text-white/60 hover:text-white text-sm transition-all"
                >
                  Reset All Filters
                </button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>

      {/* Insights Modal */}
      <InsightsModal
        isOpen={showInsights}
        onClose={() => setShowInsights(false)}
        totalSwipes={stats.total}
        profile={preferenceProfile || {
          topNeighborhoods: [],
          avgPrice: 0,
          priceRange: { min: 0, max: 0 },
          lovedFeatures: [],
          preferredBedrooms: [],
          propertyTypes: []
        }}
        recentInsights={recentInsights}
        onboardingPreferences={{
          maxPrice: filters.maxPrice,
          minBedrooms: filters.minBedrooms,
          neighborhoods: filters.neighborhoods
        }}
      />

      {/* Listing Details Modal */}
      <ListingDetailsModal
        listing={selectedListing}
        onClose={() => setSelectedListing(null)}
        onLove={() => {
          if (selectedListing) {
            handleSwipe('up');
            setSelectedListing(null);
          }
        }}
        onShare={() => {
          // TODO: Implement share functionality
          console.log('Share listing', selectedListing?.id);
        }}
      />

      {/* Social Panel */}
      <SocialPanel
        isOpen={showSocial}
        onClose={() => setShowSocial(false)}
        currentListing={currentListing}
        userId={userId || ''}
      />

      {/* Game Mode Selector */}
      <GameModeSelector
        isOpen={showGameModeSelector}
        onClose={() => setShowGameModeSelector(false)}
        currentMode={currentGameMode || 'swipe'}
        onSelectMode={(mode) => setCurrentGameMode(mode)}
      />

      <BottomNav />
    </main>
  );
}
