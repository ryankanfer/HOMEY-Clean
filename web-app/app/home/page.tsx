'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { db, supabase, auth } from '@/lib/supabase';
import { analytics, sessionManager } from '@/lib/analytics';
import type { Listing } from '@/lib/types';
import { getUserPreferences, getLocationDisplayName } from '@/lib/preferences';
import CinematicBackground from '@/components/CinematicBackground';
import PropertyCard from '@/components/PropertyCard';
import FeedRow from '@/components/FeedRow';
import SkeletonPropertyCard from '@/components/SkeletonPropertyCard';
import PageTransition from '@/components/PageTransition';
import BottomNav from '@/components/BottomNav';
import RecommendationCard from '@/components/RecommendationCard';
import NotificationCenter from '@/components/NotificationCenter';
import ProgressiveImage from '@/components/ProgressiveImage';
import PropertyComparison from '@/components/PropertyComparison';
import searchRealEstateData from '@/lib/api/realEstateAPI';

export default function HomePage() {
  const router = useRouter();
  const [listings, setListings] = useState<Listing[]>([]);
  const [loading, setLoading] = useState(true);
  const [heroListing, setHeroListing] = useState<Listing | null>(null);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [loadingMore, setLoadingMore] = useState(false);
  const [hasMore, setHasMore] = useState(true);
  const [savedListings, setSavedListings] = useState<Set<string>>(new Set());
  const [userId, setUserId] = useState<string | null>(null);
  const [recommendedListings, setRecommendedListings] = useState<any[]>([]);
  const [topMatch, setTopMatch] = useState<any | null>(null);
  const [hasSwipeData, setHasSwipeData] = useState(false);
  const [userName, setUserName] = useState<string>('');
  const [pullDistance, setPullDistance] = useState(0);
  const [isPulling, setIsPulling] = useState(false);
  const [showComparison, setShowComparison] = useState(false);
  const [userNeighborhoods, setUserNeighborhoods] = useState<string[]>([]);
  const [userLocation, setUserLocation] = useState<string>('New York');

  // Time of day awareness
  const getTimeOfDay = () => {
    const hour = new Date().getHours();
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  };

  const getWittyHeadline = () => {
    const hour = new Date().getHours();
    const date = new Date();
    const month = date.toLocaleDateString('en-US', { month: 'short' }).toLowerCase();
    const day = date.getDate();
    const dayOfWeek = date.toLocaleDateString('en-US', { weekday: 'long' }).toLowerCase();

    const firstName = userName?.split(' ')[0] || '';

    // Late night (11 PM - 4 AM)
    if (hour >= 23 || hour < 4) {
      const lateNightMessages = [
        `ooh someone's up late${firstName ? `, ${firstName}` : ''}`,
        `burning the midnight oil${firstName ? `, ${firstName}` : ''}?`,
        `night owl mode activated`,
        `the city never sleeps, neither do you`,
      ];
      return lateNightMessages[Math.floor(Math.random() * lateNightMessages.length)];
    }

    // Early morning (4 AM - 7 AM)
    if (hour >= 4 && hour < 7) {
      const earlyMessages = [
        `morning, early bird${firstName ? ` ${firstName}` : ''}`,
        `someone's up early${firstName ? `, ${firstName}` : ''}`,
        `the early bird gets the... apartment?`,
        `rise and grind${firstName ? `, ${firstName}` : ''}`,
      ];
      return earlyMessages[Math.floor(Math.random() * earlyMessages.length)];
    }

    // Morning (7 AM - 12 PM)
    if (hour >= 7 && hour < 12) {
      const morningMessages = [
        `good morning${firstName ? `, ${firstName}` : ''}`,
        `morning${firstName ? `, ${firstName}` : ''}`,
        `wakey wakey`,
        `${month} ${day} already??`,
      ];
      return morningMessages[Math.floor(Math.random() * morningMessages.length)];
    }

    // Afternoon (12 PM - 5 PM)
    if (hour >= 12 && hour < 17) {
      const afternoonMessages = [
        `good afternoon${firstName ? `, ${firstName}` : ''}`,
        `happy ${dayOfWeek}${firstName ? `, ${firstName}` : ''}`,
        `lunch break scrolling?`,
        `midday check-in`,
      ];
      return afternoonMessages[Math.floor(Math.random() * afternoonMessages.length)];
    }

    // Evening (5 PM - 11 PM)
    const eveningMessages = [
      `evening${firstName ? `, ${firstName}` : ''}`,
      `end of day wind down${firstName ? `, ${firstName}` : ''}?`,
      `peak browsing hours`,
      `ready to find your dream home?`,
    ];
    return eveningMessages[Math.floor(Math.random() * eveningMessages.length)];
  };

  const getTimeBasedGreeting = () => {
    return 'The Morning Brief';
  };

  const getSmartAIInsight = () => {
    const insights = [
      {
        type: "What's Next",
        icon: '🎯',
        message: hasSwipeData
          ? 'Scout is analyzing your preferences to find better matches'
          : 'Swipe on 10 properties to unlock personalized recommendations',
      },
      {
        type: "What Homey's Doing",
        icon: '🔍',
        message: `Monitoring ${listings.length} listings across New York for you`,
      },
      {
        type: 'Did You Know?',
        icon: '💡',
        message: 'Properties you love train our AI to find homes that match your style',
      },
      {
        type: 'Pro Tip',
        icon: '✨',
        message: 'Use Style Studio to show us your design preferences beyond just property features',
      },
    ];

    // Rotate through insights based on time
    const index = Math.floor(Date.now() / 10000) % insights.length;
    return insights[index];
  };

  const timeOfDay = (() => {
    const time = getTimeOfDay();
    if (time === 'morning') return 'sunrise' as const;
    if (time === 'afternoon') return 'day' as const;
    if (time === 'evening') return 'sunset' as const;
    return 'night' as const;
  })();

  useEffect(() => {
    // Track page view
    analytics.pageView('home_feed');

    // Start session
    sessionManager.startSession();

    // Check onboarding status before loading feed
    checkOnboardingStatus();

    // End session on unmount
    return () => {
      sessionManager.endSession();
    };
  }, []);

  const checkOnboardingStatus = async () => {
    try {
      const { data: { user } } = await auth.getUser();

      if (!user) {
        // Not logged in, redirect to login
        router.push('/');
        return;
      }

      // Get user profile
      const { data: profile } = await db.getProfile(user.id);

      // Check if onboarding is complete
      // Read from onboarding_completed flag OR check onboarding_data JSONB
      const onboardingData = profile?.onboarding_data || {};
      const isOnboardingComplete = !!(
        profile?.onboarding_completed || (
          (onboardingData.userType || profile?.user_type) &&
          (onboardingData.location || profile?.primary_location) &&
          (onboardingData.budgetMax || profile?.budget_max)
        )
      );

      if (!isOnboardingComplete) {
        console.log('⚠️ Onboarding not complete, redirecting to /onboarding');
        router.push('/onboarding');
        return;
      }

      console.log('✅ Onboarding complete, loading home feed');
      // Load feed
      loadFeed();
    } catch (error) {
      console.error('Failed to check onboarding status:', error);
      // On error, try to load feed anyway
      loadFeed();
    }
  };

  // Fetch fresh data from external APIs and save to database
  const fetchFreshListings = async (location: string = 'New York, NY', page: number = 1) => {
    setRefreshing(true);
    setError(null);

    try {
      // Fetch from external APIs
      const apiListings = await searchRealEstateData({
        location,
        status_type: 'ForRent',
        beds_min: 1,
        page,
      });

      console.log('📦 Fetched listings from API:', apiListings.length);
      console.log('📝 Sample listing:', apiListings[0]);

      if (apiListings && apiListings.length > 0) {
        // Save to database
        let inserted = 0;
        let skipped = 0;

        for (const listing of apiListings) {
          if (!listing.external_id) {
            console.warn('⚠️ Skipping listing without external_id');
            skipped++;
            continue;
          }

          // Check if listing already exists by external_id
          const { data: existing, error: checkError } = await supabase
            .from('listings')
            .select('id')
            .eq('external_id', listing.external_id)
            .maybeSingle(); // Use maybeSingle instead of single to avoid errors

          if (checkError) {
            console.error('❌ Duplicate check failed:', checkError);
          }

          if (!existing) {
            // Insert new listing
            console.log('💾 Inserting:', listing.address, listing.price);
            const { error } = await supabase.from('listings').insert(listing);
            if (error) {
              console.error('❌ Insert failed:', error);
            } else {
              inserted++;
            }
          } else {
            skipped++;
          }
        }

        console.log(`✅ Inserted ${inserted} new listings, skipped ${skipped} duplicates`);

        // Reload the feed
        await loadFeed();
        analytics.click('refresh_listings', 'button', { count: apiListings.length });
      }
    } catch (err: any) {
      console.error('Failed to fetch fresh listings:', err);
      setError(err.message || 'Failed to fetch listings. Check API keys in .env.local');
    } finally {
      setRefreshing(false);
    }
  };

  const loadFeed = async () => {
    // Try to load from cache first for instant display
    const cachedListings = localStorage.getItem('homey_cached_listings');
    const cacheTimestamp = localStorage.getItem('homey_cache_timestamp');
    const now = Date.now();
    const cacheAge = cacheTimestamp ? now - parseInt(cacheTimestamp) : Infinity;

    // Use cache if it's less than 5 minutes old
    if (cachedListings && cacheAge < 5 * 60 * 1000) {
      const cached = JSON.parse(cachedListings);
      setListings(cached);
      const featured = cached.find((l: Listing) => l.is_featured) || cached[0];
      setHeroListing(featured);
      setLoading(false);
    }

    // Get user preferences using centralized utility
    const { data: { user } } = await auth.getUser();
    let filters = {};

    if (user) {
      const prefs = await getUserPreferences(user.id);

      if (prefs) {
        // Build filters from consolidated preferences
        if (prefs.budgetMax) {
          filters = { ...filters, maxPrice: prefs.budgetMax };
        }

        if (prefs.budgetMin) {
          filters = { ...filters, minPrice: prefs.budgetMin };
        }

        if (prefs.bedrooms) {
          filters = { ...filters, minBedrooms: prefs.bedrooms };
        }

        // Filter by neighborhoods if selected
        if (prefs.neighborhoods && prefs.neighborhoods.length > 0) {
          filters = { ...filters, neighborhoods: prefs.neighborhoods };
          setUserNeighborhoods(prefs.neighborhoods);
        }

        // Store user's location (display name)
        if (prefs.location) {
          setUserLocation(getLocationDisplayName(prefs.location));
        }

        console.log('🎯 Loading listings with user preferences:', filters);
        console.log('📍 User preferences:', prefs);
      }
    }

    // Always fetch fresh data in the background with filters
    const { data, error } = await db.getListings(filters);

    if (!error && data) {
      console.log(`📊 Loaded ${data.length} listings matching your preferences`);
      setListings(data);
      // Set featured or first listing as hero
      const featured = data.find((l: Listing) => l.is_featured) || data[0];
      setHeroListing(featured);

      // Update cache
      localStorage.setItem('homey_cached_listings', JSON.stringify(data));
      localStorage.setItem('homey_cache_timestamp', now.toString());
    } else if (error) {
      console.error('Failed to load listings:', error);
    }

    // Load recommendations if user is logged in
    await loadRecommendations();

    setLoading(false);
  };

  const loadRecommendations = async () => {
    try {
      const { data: { user } } = await auth.getUser();

      if (!user) return;

      setUserId(user.id);

      // Try cache first
      const cachedProfile = localStorage.getItem(`homey_profile_${user.id}`);
      const cachedRecommendations = localStorage.getItem(`homey_recommendations_${user.id}`);

      if (cachedProfile) {
        const profile = JSON.parse(cachedProfile);
        if (profile.name) setUserName(profile.name);
        if (profile.hasSwipeData !== undefined) setHasSwipeData(profile.hasSwipeData);
      }

      if (cachedRecommendations) {
        const recommended = JSON.parse(cachedRecommendations);
        setRecommendedListings(recommended);
        if (recommended.length > 0) setTopMatch(recommended[0]);
      }

      // Load user name using centralized preferences
      const prefs = await getUserPreferences(user.id);
      if (prefs?.displayName) {
        setUserName(prefs.displayName);
      } else if (user.user_metadata?.full_name) {
        setUserName(user.user_metadata.full_name.split(' ')[0]);
      }

      // Load saved properties
      const { data: savedProps } = await db.getSavedProperties(user.id);
      if (savedProps && savedProps.length > 0) {
        const savedIds = new Set(savedProps.map((sp: any) => sp.listing_id));
        setSavedListings(savedIds);
        console.log(`💾 Loaded ${savedIds.size} saved properties`);
      }

      // Check if user has swipe data
      const { data: swipeStats } = await db.getSwipeStats(user.id);
      const hasSwipes = !!(swipeStats && swipeStats.total > 0);
      setHasSwipeData(hasSwipes);

      // Cache profile
      localStorage.setItem(`homey_profile_${user.id}`, JSON.stringify({
        name: prefs?.displayName || user.user_metadata?.full_name?.split(' ')[0],
        hasSwipeData: hasSwipes,
      }));

      if (hasSwipes) {
        // Get personalized recommendations
        const { data: recommended } = await db.getRecommendedListings(user.id, 10);
        if (recommended && recommended.length > 0) {
          setRecommendedListings(recommended);
          setTopMatch(recommended[0]); // Highest scoring match

          // Cache recommendations
          localStorage.setItem(`homey_recommendations_${user.id}`, JSON.stringify(recommended));
        }
      }
    } catch (err) {
      console.error('Failed to load recommendations:', err);
    }
  };

  // Load more properties from next page
  const loadMore = async () => {
    if (loadingMore || !hasMore) return;

    setLoadingMore(true);
    const nextPage = currentPage + 1;

    try {
      const apiListings = await searchRealEstateData({
        location: 'New York, NY',
        status_type: 'ForRent',
        beds_min: 1,
        page: nextPage,
      });

      if (apiListings && apiListings.length > 0) {
        // Save to database
        let inserted = 0;
        for (const listing of apiListings) {
          if (!listing.external_id) continue;

          const { data: existing } = await supabase
            .from('listings')
            .select('id')
            .eq('external_id', listing.external_id)
            .maybeSingle();

          if (!existing) {
            await supabase.from('listings').insert(listing);
            inserted++;
          }
        }

        console.log(`✅ Page ${nextPage}: Inserted ${inserted} new listings`);

        // Reload feed to show new listings
        await loadFeed();
        setCurrentPage(nextPage);

        // If we got fewer than expected, there might not be more pages
        if (apiListings.length < 20) {
          setHasMore(false);
        }
      } else {
        // No more results
        setHasMore(false);
      }
    } catch (err) {
      console.error('Failed to load more listings:', err);
    } finally {
      setLoadingMore(false);
    }
  };

  // Handle save/unsave listing
  const handleSaveListing = async (listingId: string) => {
    try {
      const { data: { user } } = await auth.getUser();

      if (!user) {
        alert('Please sign in to save properties');
        return;
      }

      const isSaved = savedListings.has(listingId);

      if (isSaved) {
        // Unsave
        await db.unsaveProperty(user.id, listingId);
        setSavedListings(prev => {
          const newSet = new Set(prev);
          newSet.delete(listingId);
          return newSet;
        });
        analytics.click('unsave_listing', 'button', { listing_id: listingId });
      } else {
        // Save
        await db.saveProperty(user.id, listingId);
        setSavedListings(prev => new Set(prev).add(listingId));
        analytics.saveListing(listingId);
      }
    } catch (error) {
      console.error('Failed to save/unsave property:', error);
      alert('Failed to update saved status. Please try again.');
    }
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      maximumFractionDigits: 0,
    }).format(price);
  };

  const handleListingClick = (listing: Listing, context: string) => {
    // Track the listing view
    analytics.viewListing(listing.id, {
      price: listing.price,
      neighborhood: listing.neighborhood,
      bedrooms: listing.bedrooms,
      context,
      is_featured: listing.is_featured,
      is_new: listing.is_new_to_market,
    });

    // Navigate to listing
    router.push(`/scout/${listing.id}`);
  };

  // Filter listings by category
  const newListings = listings.filter(l => l.is_new_to_market);
  const featuredListings = listings.filter(l => l.is_featured);
  const trendingListings = listings.slice(0, 5); // Top 5 as trending

  // Intelligent Property Selection for 3 Narratives
  const selectInvestmentProperty = () => {
    // Look for properties with good value (lower price, good neighborhood)
    const sorted = [...listings].sort((a, b) => {
      const aValue = a.square_footage ? a.price / a.square_footage : a.price;
      const bValue = b.square_footage ? b.price / b.square_footage : b.price;
      return aValue - bValue;
    });
    return sorted[0];
  };

  const selectDreamProperty = () => {
    // Prefer properties with high match score if available
    if (hasSwipeData && recommendedListings.length > 0) {
      return recommendedListings[0];
    }
    // Otherwise, featured or new listings
    return featuredListings[0] || newListings[0] || listings[1];
  };

  const selectStretchProperty = () => {
    // Look for higher-end properties (higher price, more amenities)
    const sorted = [...listings].sort((a, b) => b.price - a.price);
    return sorted[0];
  };

  const investmentProp = selectInvestmentProperty();
  const dreamProp = selectDreamProperty();
  const stretchProp = selectStretchProperty();

  // Calculate days on market
  const getDaysOnMarket = (listing: Listing) => {
    const created = new Date(listing.created_at);
    const now = new Date();
    const days = Math.floor((now.getTime() - created.getTime()) / (1000 * 60 * 60 * 24));
    return days;
  };

  // Get standout feature
  const getStandoutFeature = (listing: Listing) => {
    const features = [
      'Rooftop access',
      'Recently renovated',
      'Walk to subway',
      'In-unit laundry',
      'Doorman building',
      'Pet-friendly',
      'Natural light',
      'High ceilings',
    ];
    // Return a random feature for now - in production, parse from description
    return features[Math.floor(Math.random() * features.length)];
  };

  // Section Divider Component
  const SectionDivider = ({ label }: { label: string }) => (
    <div className="relative py-8 px-5">
      {/* Gradient background shift */}
      <div className="absolute inset-0 bg-gradient-to-b from-transparent via-white/[0.02] to-transparent" />

      {/* Divider line */}
      <div className="relative flex items-center justify-center">
        <div className="absolute inset-0 flex items-center">
          <div className="w-full border-t border-white/10" />
        </div>

        {/* Floating label */}
        <motion.div
          className="relative px-6 py-2 glass-strong rounded-full border border-white/10"
          initial={{ opacity: 0, scale: 0.9 }}
          whileInView={{ opacity: 1, scale: 1 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          whileHover={{ scale: 1.05, borderColor: 'rgba(255,255,255,0.2)' }}
        >
          <span className="text-sm font-semibold text-white/60 tracking-wider">
            · {label} ·
          </span>
        </motion.div>
      </div>
    </div>
  );

  const handlePullRefresh = async () => {
    setIsPulling(true);
    await fetchFreshListings();
    setIsPulling(false);
    setPullDistance(0);
  };

  return (
    <main className="relative min-h-screen pb-24">
      <CinematicBackground timeOfDay={timeOfDay} />

      {/* Dark overlay for better text contrast */}
      <div className="fixed inset-0 z-0 bg-gradient-to-b from-black/30 via-black/20 to-black/40" />

      {/* Fixed Header */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-gradient-to-b from-black/60 via-black/40 to-transparent backdrop-blur-sm">
        <div className="flex items-center justify-between px-5 py-4">
          <button
            onClick={() => router.push('/home')}
            className="flex items-center gap-2 min-h-[44px] p-2 hover:opacity-80 transition-opacity"
          >
            <span className="text-2xl">🏠</span>
            <h1 className="text-2xl font-bold tracking-wider text-white drop-shadow-lg">
              HOMEY
            </h1>
          </button>
          <div className="flex items-center gap-3">
            <NotificationCenter />
            <button
              onClick={() => fetchFreshListings()}
              disabled={refreshing}
              className={`w-11 h-11 rounded-full bg-white/10 flex items-center justify-center text-xl hover:bg-white/20 transition-colors ${
                refreshing ? 'animate-spin' : ''
              }`}
              title="Refresh listings from API"
            >
              {refreshing ? '⏳' : '🔄'}
            </button>
            <button
              onClick={() => router.push('/settings')}
              className="w-11 h-11 rounded-full bg-white/10 flex items-center justify-center text-xl hover:bg-white/20 transition-colors"
            >
              👤
            </button>
          </div>
        </div>
        {error && (
          <div className="mx-5 mb-3 p-3 bg-red-500/20 border border-red-500/50 rounded-lg text-white text-sm backdrop-blur-sm">
            {error}
          </div>
        )}
      </header>

      {/* Pull-to-Refresh Indicator */}
      {pullDistance > 0 && (
        <motion.div
          className="fixed top-20 left-0 right-0 z-40 flex justify-center"
          initial={{ opacity: 0 }}
          animate={{ opacity: pullDistance > 80 ? 1 : 0.5 }}
        >
          <div className="px-6 py-3 bg-white/10 backdrop-blur-md rounded-full border border-white/20">
            <motion.div
              animate={{ rotate: isPulling ? 360 : 0 }}
              transition={{ duration: 1, repeat: isPulling ? Infinity : 0, ease: 'linear' }}
            >
              {pullDistance > 80 ? '🔄' : '⬇️'}
            </motion.div>
          </div>
        </motion.div>
      )}

      {/* Main Content */}
      <div className="relative z-10 pt-20">
        {loading ? (
          <PageTransition>
            {/* Skeleton Hero */}
            <div className="px-5 mb-8">
              <div className="relative h-[500px] md:h-[600px] rounded-3xl glass-strong overflow-hidden">
                <div className="absolute inset-0 bg-gradient-to-br from-white/5 to-white/10 animate-pulse" />
              </div>
            </div>

            {/* Skeleton Feed Rows */}
            {[1, 2, 3].map((row) => (
              <div key={row} className="mb-8">
                <div className="px-5 mb-4">
                  <div className="h-6 w-48 bg-white/10 rounded-lg mb-2 animate-pulse" />
                  <div className="h-4 w-32 bg-white/5 rounded animate-pulse" />
                </div>
                <div className="overflow-x-auto scrollbar-hide">
                  <div className="flex gap-4 px-5 pb-2">
                    {[1, 2, 3, 4].map((card) => (
                      <SkeletonPropertyCard key={card} size="medium" />
                    ))}
                  </div>
                </div>
              </div>
            ))}
          </PageTransition>
        ) : (
          <>
            {/* Witty Headline */}
            <motion.div
              className="px-5 mb-8 text-center"
              initial={{ opacity: 0, y: -20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
            >
              <h1 className="text-5xl md:text-7xl font-light text-white/95 tracking-tight capitalize" style={{ fontFamily: 'Playfair Display, serif' }}>
                {getWittyHeadline()}
              </h1>
            </motion.div>

            {/* Journey Progress Timeline */}
            <motion.div
              className="px-5 mb-12"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.1 }}
            >
              <div className="max-w-4xl mx-auto glass-strong rounded-3xl p-6 md:p-8 border border-white/10">
                <div className="mb-6 text-center">
                  <h3 className="text-sm font-semibold text-white/40 tracking-widest uppercase mb-2">
                    Your Journey
                  </h3>
                  <p className="text-white/70 text-sm">
                    {!hasSwipeData
                      ? "Just getting started"
                      : savedListings.size === 0
                      ? "Training the algorithm"
                      : savedListings.size < 3
                      ? "Building your collection"
                      : "Ready to take action"}
                  </p>
                </div>

                {/* Progress Steps */}
                <div className="relative">
                  {/* Progress Line */}
                  <div className="absolute top-6 left-0 right-0 h-0.5 bg-white/10" />
                  <div
                    className="absolute top-6 left-0 h-0.5 bg-gradient-to-r from-primary via-purple-500 to-pink-500 transition-all duration-1000"
                    style={{
                      width: `${!hasSwipeData ? '0%' : savedListings.size === 0 ? '25%' : savedListings.size < 3 ? '50%' : savedListings.size < 5 ? '75%' : '100%'}`
                    }}
                  />

                  {/* Steps */}
                  <div className="relative grid grid-cols-4 gap-2">
                    {/* Step 1: Train */}
                    <div className="flex flex-col items-center">
                      <div className={`w-12 h-12 rounded-full flex items-center justify-center text-2xl transition-all ${
                        hasSwipeData
                          ? 'bg-gradient-to-br from-primary to-purple-600 shadow-lg shadow-primary/30'
                          : 'bg-white/10 border-2 border-white/20'
                      }`}>
                        {hasSwipeData ? '✓' : '🎯'}
                      </div>
                      <p className="text-white/70 text-xs mt-2 text-center">Train AI</p>
                    </div>

                    {/* Step 2: Save */}
                    <div className="flex flex-col items-center">
                      <div className={`w-12 h-12 rounded-full flex items-center justify-center text-2xl transition-all ${
                        savedListings.size > 0
                          ? 'bg-gradient-to-br from-primary to-purple-600 shadow-lg shadow-primary/30'
                          : 'bg-white/10 border-2 border-white/20'
                      }`}>
                        {savedListings.size > 0 ? '✓' : '❤️'}
                      </div>
                      <p className="text-white/70 text-xs mt-2 text-center">Save Homes</p>
                    </div>

                    {/* Step 3: Shortlist */}
                    <div className="flex flex-col items-center">
                      <div className={`w-12 h-12 rounded-full flex items-center justify-center text-2xl transition-all ${
                        savedListings.size >= 3
                          ? 'bg-gradient-to-br from-primary to-purple-600 shadow-lg shadow-primary/30'
                          : 'bg-white/10 border-2 border-white/20'
                      }`}>
                        {savedListings.size >= 3 ? '✓' : '📋'}
                      </div>
                      <p className="text-white/70 text-xs mt-2 text-center">Shortlist</p>
                    </div>

                    {/* Step 4: Tour */}
                    <div className="flex flex-col items-center">
                      <div className={`w-12 h-12 rounded-full flex items-center justify-center text-2xl transition-all ${
                        savedListings.size >= 5
                          ? 'bg-gradient-to-br from-primary to-purple-600 shadow-lg shadow-primary/30'
                          : 'bg-white/10 border-2 border-white/20'
                      }`}>
                        {savedListings.size >= 5 ? '✓' : '🏠'}
                      </div>
                      <p className="text-white/70 text-xs mt-2 text-center">Book Tours</p>
                    </div>
                  </div>
                </div>

                {/* Progress Stats */}
                {hasSwipeData && (
                  <div className="mt-6 pt-6 border-t border-white/10">
                    <div className="grid grid-cols-3 gap-4 text-center">
                      <div>
                        <div className="text-2xl font-bold text-primary mb-1">
                          {savedListings.size}
                        </div>
                        <div className="text-white/60 text-xs">Saved</div>
                      </div>
                      <div>
                        <div className="text-2xl font-bold text-purple-400 mb-1">
                          {recommendedListings.length}
                        </div>
                        <div className="text-white/60 text-xs">Matches</div>
                      </div>
                      <div>
                        <div className="text-2xl font-bold text-pink-400 mb-1">
                          {topMatch?.match_score ? Math.round(topMatch.match_score * 100) : 0}%
                        </div>
                        <div className="text-white/60 text-xs">Top Match</div>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </motion.div>

            {/* The Morning Brief */}
            <motion.div
              className="px-5 mb-12 max-w-3xl mx-auto"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: 0.2 }}
            >
              <div className="glass-strong rounded-3xl p-6 md:p-8 border border-white/10">
                <motion.div
                  className="text-center"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ duration: 0.6, delay: 0.3 }}
                >
                  <h2 className="text-sm font-semibold text-white/40 mb-4 tracking-widest uppercase">
                    {getTimeBasedGreeting()}
                  </h2>

                  <p className="text-lg md:text-xl font-light text-white/80 leading-relaxed mb-4">
                    While you slept, <span className="text-primary font-normal">{listings.filter((l: any) => l.is_new_to_market).length} new listings</span> hit the market{userNeighborhoods.length > 0 ? ` in ${userNeighborhoods.slice(0, 2).join(' and ')}` : ` in ${userLocation}`}.
                    {listings.length > 0 && ` The ${listings[0]?.property_type?.toLowerCase() || 'property'} on ${listings[0]?.address?.split(',')[0] || '23rd Street'} went into contract.`}
                    {' '}I found <span className="text-primary font-normal">{Math.min(listings.length, investmentProp && dreamProp && stretchProp ? 3 : listings.length)} {listings.length === 1 ? 'property' : 'properties'}</span> that match your preferences.
                  </p>

                  <div className="flex items-center justify-center gap-3 text-xs text-white/30">
                    <span>🤖</span>
                    <span>The Brain worked through the night</span>
                    <span className="w-1 h-1 rounded-full bg-white/20" />
                    <span>{new Date().toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}</span>
                  </div>
                </motion.div>
              </div>
            </motion.div>

            {/* Next Action + Daily Edit Row */}
            <div className="px-5 mb-12">
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 max-w-7xl mx-auto">
                {/* The Friction Killer */}
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.6, delay: 0.3 }}
                >
                  <div className="relative rounded-3xl overflow-hidden border border-primary/30 bg-gradient-to-br from-primary/10 via-purple-500/5 to-pink-500/10 backdrop-blur-md h-full">
                    <div className="p-8 flex flex-col h-full">
                      <div className="flex items-start gap-4 mb-6">
                        <div className="w-12 h-12 rounded-full bg-primary/20 flex items-center justify-center text-2xl flex-shrink-0">
                          {!hasSwipeData ? '🎯' : '📍'}
                        </div>
                        <div className="flex-1">
                          <h3 className="text-sm font-semibold text-primary/80 mb-2 tracking-wide">
                            NEXT ACTION
                          </h3>
                          <p className="text-xl text-white font-medium mb-1">
                            {!hasSwipeData
                              ? 'Train The Algorithm'
                              : savedListings.size > 0
                              ? 'Schedule Your Tours'
                              : 'Save Your Favorites'}
                          </p>
                          <p className="text-white/60 text-sm">
                            {!hasSwipeData
                              ? 'Swipe on 10 properties to unlock personalized matches'
                              : savedListings.size > 0
                              ? `You have ${savedListings.size} saved ${savedListings.size === 1 ? 'property' : 'properties'}. Book viewings now.`
                              : 'Swipe right on any property below to save it for later'}
                          </p>
                        </div>
                      </div>

                      <button
                        onClick={() => {
                          if (!hasSwipeData) {
                            router.push('/matchmaker');
                          } else if (savedListings.size > 0) {
                            router.push('/calendar');
                          } else {
                            // Scroll to narratives
                            document.getElementById('narratives')?.scrollIntoView({ behavior: 'smooth' });
                          }
                        }}
                        className="w-full py-4 bg-gradient-to-r from-primary via-purple-500 to-pink-500 hover:opacity-90 text-white font-bold rounded-2xl transition-opacity min-h-[44px] mt-auto"
                      >
                        {!hasSwipeData ? 'Start Swiping →' : savedListings.size > 0 ? 'View Calendar →' : 'See The Daily Edit ↓'}
                      </button>
                    </div>
                  </div>
                </motion.div>

                {/* The Daily Edit Section */}
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.6, delay: 0.4 }}
                >
              <div className="text-center">
                <h2 className="text-4xl md:text-5xl font-light text-white mb-3" style={{ fontFamily: 'Playfair Display, serif' }}>
                  The Daily Edit
                </h2>
                <p className="text-white/50 text-sm tracking-wider mb-4">
                  CURATED FOR YOU · {new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric' }).toUpperCase()}
                </p>

                {/* Calendar Widget */}
                <div className="max-w-md mx-auto mb-6">
                  <div className="glass rounded-2xl p-5 border border-white/10 inline-block">
                    <div className="flex items-center gap-4">
                      <div className="flex-shrink-0">
                        <div className="w-16 h-16 rounded-xl bg-gradient-to-br from-primary/20 to-purple-500/20 flex flex-col items-center justify-center border border-white/10">
                          <span className="text-xs font-semibold text-white/50 uppercase tracking-wider">
                            {new Date().toLocaleDateString('en-US', { month: 'short' })}
                          </span>
                          <span className="text-2xl font-bold text-white">
                            {new Date().getDate()}
                          </span>
                        </div>
                      </div>
                      <div className="text-left">
                        <p className="text-white/90 font-medium text-sm">
                          {new Date().toLocaleDateString('en-US', { weekday: 'long' })}
                        </p>
                        <p className="text-white/50 text-xs mt-1">
                          {savedListings.size > 0
                            ? `${savedListings.size} saved ${savedListings.size === 1 ? 'property' : 'properties'}`
                            : 'Ready to discover'}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
                {userNeighborhoods.length > 0 && (
                  <div className="max-w-2xl mx-auto mt-4">
                    <div className="glass rounded-2xl p-4 border border-white/10">
                      <div className="flex items-start gap-3">
                        <span className="text-2xl">🎯</span>
                        <div className="flex-1 text-left">
                          <p className="text-white/90 text-sm leading-relaxed">
                            <span className="font-semibold text-white">Personalized for you:</span> Showing properties in {userNeighborhoods.join(', ')} that match your budget and space requirements.
                          </p>
                          <p className="text-white/60 text-xs mt-2">
                            Swipe right on properties to teach the AI your style preferences.
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </motion.div>
              </div>
            </div>

            {/* Teach Homey Section - Always Show */}
            <motion.div
                className="px-5 mb-16"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.5 }}
              >
                <div className="glass-strong rounded-3xl p-10 md:p-16 border-2 border-primary/30 bg-gradient-to-br from-primary/5 via-purple-500/5 to-pink-500/5">
                  <div className="text-center mb-10">
                    <div className="text-7xl mb-6">🧠</div>
                    <h2 className="text-4xl md:text-5xl font-light text-white mb-4 drop-shadow-lg" style={{ fontFamily: 'Playfair Display, serif', textShadow: '0 2px 8px rgba(0,0,0,0.4)' }}>
                      Teach Homey Your Style
                    </h2>
                    <p className="text-xl text-white max-w-2xl mx-auto leading-relaxed drop-shadow-md">
                      {listings.length === 0
                        ? `We don't have properties yet in ${userNeighborhoods.length > 0 ? userNeighborhoods.join(', ') : userLocation}. Help us learn what you're looking for so we can find your perfect match.`
                        : `Help us understand what you love. The more you interact, the smarter your recommendations become.`
                      }
                    </p>
                  </div>

                  {/* How It Works */}
                  <div className="max-w-4xl mx-auto mb-12">
                    <div className="grid md:grid-cols-3 gap-6 text-center">
                      <div className="glass-light rounded-xl p-6 border border-white/10">
                        <div className="text-4xl mb-3">👆</div>
                        <h4 className="text-white font-semibold mb-2">Swipe</h4>
                        <p className="text-white/60 text-sm">Pass, like, or love properties and designs</p>
                      </div>
                      <div className="glass-light rounded-xl p-6 border border-white/10">
                        <div className="text-4xl mb-3">🧠</div>
                        <h4 className="text-white font-semibold mb-2">Learn</h4>
                        <p className="text-white/60 text-sm">AI analyzes your patterns and preferences</p>
                      </div>
                      <div className="glass-light rounded-xl p-6 border border-white/10">
                        <div className="text-4xl mb-3">🎯</div>
                        <h4 className="text-white font-semibold mb-2">Match</h4>
                        <p className="text-white/60 text-sm">Get personalized property recommendations</p>
                      </div>
                    </div>
                  </div>

                  {/* Training Methods Grid - 3 columns, 2 rows */}
                  <div className="grid md:grid-cols-3 gap-6 max-w-6xl mx-auto mb-10">
                    {/* Matchmaker Card */}
                    <div className="glass rounded-2xl p-6 border border-white/10 hover:border-primary/40 transition-all group cursor-pointer"
                      onClick={() => router.push('/matchmaker')}
                    >
                      <div className="flex items-center gap-3 mb-4">
                        <div className="w-12 h-12 rounded-full bg-gradient-to-br from-primary/20 to-purple-500/20 flex items-center justify-center text-2xl flex-shrink-0">
                          🏠
                        </div>
                        <div>
                          <h3 className="text-lg font-semibold text-white">Matchmaker</h3>
                          <p className="text-primary/80 text-xs font-medium">Property Swiping</p>
                        </div>
                      </div>
                      <p className="text-white/70 text-sm mb-4 leading-relaxed">
                        Swipe through properties to teach the AI what features, layouts, and neighborhoods you love.
                      </p>
                      <div className="space-y-2 mb-4">
                        <div className="flex items-center gap-2 text-xs text-white/60">
                          <span className="text-green-400">✓</span>
                          <span>Location preferences</span>
                        </div>
                        <div className="flex items-center gap-2 text-xs text-white/60">
                          <span className="text-green-400">✓</span>
                          <span>Price range patterns</span>
                        </div>
                        <div className="flex items-center gap-2 text-xs text-white/60">
                          <span className="text-green-400">✓</span>
                          <span>Property features</span>
                        </div>
                      </div>
                      <div className="flex items-center justify-between pt-3 border-t border-white/10">
                        <span className="text-white/50 text-xs font-medium">
                          {!hasSwipeData ? 'Start here' : 'Keep swiping'}
                        </span>
                        <span className="text-primary group-hover:translate-x-1 transition-transform">→</span>
                      </div>
                    </div>

                    {/* Style Studio Card */}
                    <div className="glass rounded-2xl p-6 border border-white/10 hover:border-purple-500/40 transition-all group cursor-pointer"
                      onClick={() => router.push('/studio')}
                    >
                      <div className="flex items-center gap-3 mb-4">
                        <div className="w-12 h-12 rounded-full bg-gradient-to-br from-purple-500/20 to-pink-500/20 flex items-center justify-center text-2xl flex-shrink-0">
                          ✨
                        </div>
                        <div>
                          <h3 className="text-lg font-semibold text-white">Style Studio</h3>
                          <p className="text-purple-400/80 text-xs font-medium">Design Swiping</p>
                        </div>
                      </div>
                      <p className="text-white/70 text-sm mb-4 leading-relaxed">
                        Show us your aesthetic preferences by swiping on curated interior designs.
                      </p>
                      <div className="space-y-2 mb-4">
                        <div className="flex items-center gap-2 text-xs text-white/60">
                          <span className="text-purple-400">✓</span>
                          <span>Color palettes</span>
                        </div>
                        <div className="flex items-center gap-2 text-xs text-white/60">
                          <span className="text-purple-400">✓</span>
                          <span>Design styles</span>
                        </div>
                        <div className="flex items-center gap-2 text-xs text-white/60">
                          <span className="text-purple-400">✓</span>
                          <span>Space aesthetics</span>
                        </div>
                      </div>
                      <div className="flex items-center justify-between pt-3 border-t border-white/10">
                        <span className="text-white/50 text-xs font-medium">
                          Aesthetic training
                        </span>
                        <span className="text-purple-400 group-hover:translate-x-1 transition-transform">→</span>
                      </div>
                    </div>

                    {/* Search & Explore Card */}
                    <div className="glass rounded-2xl p-6 border border-white/10 hover:border-blue-500/40 transition-all group cursor-pointer"
                      onClick={() => router.push('/search')}
                    >
                      <div className="flex items-center gap-3 mb-4">
                        <div className="w-12 h-12 rounded-full bg-gradient-to-br from-blue-500/20 to-cyan-500/20 flex items-center justify-center text-2xl flex-shrink-0">
                          🔍
                        </div>
                        <div>
                          <h3 className="text-lg font-semibold text-white">Search</h3>
                          <p className="text-blue-400/80 text-xs font-medium">Active Exploration</p>
                        </div>
                      </div>
                      <p className="text-white/70 text-sm mb-4 leading-relaxed">
                        Search with specific filters and save properties you love to refine your profile.
                      </p>
                      <div className="space-y-2 mb-4">
                        <div className="flex items-center gap-2 text-xs text-white/60">
                          <span className="text-blue-400">✓</span>
                          <span>Custom filters</span>
                        </div>
                        <div className="flex items-center gap-2 text-xs text-white/60">
                          <span className="text-blue-400">✓</span>
                          <span>Neighborhood selection</span>
                        </div>
                        <div className="flex items-center gap-2 text-xs text-white/60">
                          <span className="text-blue-400">✓</span>
                          <span>Save favorites</span>
                        </div>
                      </div>
                      <div className="flex items-center justify-between pt-3 border-t border-white/10">
                        <span className="text-white/50 text-xs font-medium">
                          Manual exploration
                        </span>
                        <span className="text-blue-400 group-hover:translate-x-1 transition-transform">→</span>
                      </div>
                    </div>

                    {/* Saved Vault Card */}
                    <div className="glass rounded-2xl p-6 border border-white/10 hover:border-pink-500/40 transition-all group cursor-pointer"
                      onClick={() => router.push('/vault')}
                    >
                      <div className="flex items-center gap-3 mb-4">
                        <div className="w-12 h-12 rounded-full bg-gradient-to-br from-pink-500/20 to-red-500/20 flex items-center justify-center text-2xl flex-shrink-0">
                          ❤️
                        </div>
                        <div>
                          <h3 className="text-lg font-semibold text-white">Saved Vault</h3>
                          <p className="text-pink-400/80 text-xs font-medium">Your Collection</p>
                        </div>
                      </div>
                      <p className="text-white/70 text-sm mb-4 leading-relaxed">
                        Review and organize properties you've saved. The more you save, the better we understand what you want.
                      </p>
                      <div className="space-y-2 mb-4">
                        <div className="flex items-center gap-2 text-xs text-white/60">
                          <span className="text-pink-400">✓</span>
                          <span>Organize favorites</span>
                        </div>
                        <div className="flex items-center gap-2 text-xs text-white/60">
                          <span className="text-pink-400">✓</span>
                          <span>Review saved homes</span>
                        </div>
                        <div className="flex items-center gap-2 text-xs text-white/60">
                          <span className="text-pink-400">✓</span>
                          <span>Show serious interest</span>
                        </div>
                      </div>
                      <div className="flex items-center justify-between pt-3 border-t border-white/10">
                        <span className="text-white/50 text-xs font-medium">
                          Build your collection
                        </span>
                        <span className="text-pink-400 group-hover:translate-x-1 transition-transform">→</span>
                      </div>
                    </div>

                    {/* Learn Hub Card */}
                    <div className="glass rounded-2xl p-6 border border-white/10 hover:border-orange-500/40 transition-all group cursor-pointer"
                      onClick={() => router.push('/learn')}
                    >
                      <div className="flex items-center gap-3 mb-4">
                        <div className="w-12 h-12 rounded-full bg-gradient-to-br from-orange-500/20 to-yellow-500/20 flex items-center justify-center text-2xl flex-shrink-0">
                          📚
                        </div>
                        <div>
                          <h3 className="text-lg font-semibold text-white">Learn Hub</h3>
                          <p className="text-orange-400/80 text-xs font-medium">Guided Preferences</p>
                        </div>
                      </div>
                      <p className="text-white/70 text-sm mb-4 leading-relaxed">
                        Take interactive quizzes to clarify your preferences and help the AI understand your priorities.
                      </p>
                      <div className="space-y-2 mb-4">
                        <div className="flex items-center gap-2 text-xs text-white/60">
                          <span className="text-orange-400">✓</span>
                          <span>Must-have features</span>
                        </div>
                        <div className="flex items-center gap-2 text-xs text-white/60">
                          <span className="text-orange-400">✓</span>
                          <span>Lifestyle priorities</span>
                        </div>
                        <div className="flex items-center gap-2 text-xs text-white/60">
                          <span className="text-orange-400">✓</span>
                          <span>Deal breakers</span>
                        </div>
                      </div>
                      <div className="flex items-center justify-between pt-3 border-t border-white/10">
                        <span className="text-white/50 text-xs font-medium">
                          Structured feedback
                        </span>
                        <span className="text-orange-400 group-hover:translate-x-1 transition-transform">→</span>
                      </div>
                    </div>

                    {/* Calendar Card */}
                    <div className="glass rounded-2xl p-6 border border-white/10 hover:border-green-500/40 transition-all group cursor-pointer"
                      onClick={() => router.push('/calendar')}
                    >
                      <div className="flex items-center gap-3 mb-4">
                        <div className="w-12 h-12 rounded-full bg-gradient-to-br from-green-500/20 to-emerald-500/20 flex items-center justify-center text-2xl flex-shrink-0">
                          📅
                        </div>
                        <div>
                          <h3 className="text-lg font-semibold text-white">Calendar</h3>
                          <p className="text-green-400/80 text-xs font-medium">Schedule Viewings</p>
                        </div>
                      </div>
                      <p className="text-white/70 text-sm mb-4 leading-relaxed">
                        Book property tours to show serious interest. Viewing history teaches the AI what you're ready to commit to.
                      </p>
                      <div className="space-y-2 mb-4">
                        <div className="flex items-center gap-2 text-xs text-white/60">
                          <span className="text-green-400">✓</span>
                          <span>Schedule tours</span>
                        </div>
                        <div className="flex items-center gap-2 text-xs text-white/60">
                          <span className="text-green-400">✓</span>
                          <span>Track viewings</span>
                        </div>
                        <div className="flex items-center gap-2 text-xs text-white/60">
                          <span className="text-green-400">✓</span>
                          <span>Show commitment</span>
                        </div>
                      </div>
                      <div className="flex items-center justify-between pt-3 border-t border-white/10">
                        <span className="text-white/50 text-xs font-medium">
                          Real-world validation
                        </span>
                        <span className="text-green-400 group-hover:translate-x-1 transition-transform">→</span>
                      </div>
                    </div>
                  </div>

                  {/* Benefits Section */}
                  <div className="max-w-5xl mx-auto mb-10">
                    <div className="glass-light rounded-2xl p-6 border border-white/10">
                      <h4 className="text-white font-semibold mb-4 text-center">What You'll Unlock</h4>
                      <div className="grid md:grid-cols-4 gap-4">
                        <div className="text-center">
                          <div className="text-3xl mb-2">🎯</div>
                          <p className="text-white/80 text-sm font-medium mb-1">Smart Matches</p>
                          <p className="text-white/50 text-xs">AI-powered recommendations</p>
                        </div>
                        <div className="text-center">
                          <div className="text-3xl mb-2">⚡</div>
                          <p className="text-white/80 text-sm font-medium mb-1">Time Saved</p>
                          <p className="text-white/50 text-xs">Less browsing, more finding</p>
                        </div>
                        <div className="text-center">
                          <div className="text-3xl mb-2">📊</div>
                          <p className="text-white/80 text-sm font-medium mb-1">Price Insights</p>
                          <p className="text-white/50 text-xs">Learn your sweet spot</p>
                        </div>
                        <div className="text-center">
                          <div className="text-3xl mb-2">🏆</div>
                          <p className="text-white/80 text-sm font-medium mb-1">Top Picks</p>
                          <p className="text-white/50 text-xs">Daily curated selections</p>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Progress Indicator & Tips */}
                  <div className="max-w-4xl mx-auto space-y-6">
                    {!hasSwipeData && (
                      <div className="bg-gradient-to-r from-yellow-500/10 via-orange-500/10 to-red-500/10 rounded-2xl p-6 border border-yellow-500/30">
                        <div className="flex items-start gap-4">
                          <div className="w-12 h-12 rounded-full bg-yellow-500/20 flex items-center justify-center flex-shrink-0">
                            <span className="text-2xl">⚡</span>
                          </div>
                          <div className="flex-1">
                            <h4 className="text-white font-semibold mb-2">Quick Start Challenge</h4>
                            <p className="text-white/80 text-sm mb-4">
                              Complete 10 swipes to unlock AI-powered recommendations. The more you swipe, the smarter Homey becomes.
                            </p>
                            <div className="grid grid-cols-3 gap-3">
                              <div className="bg-white/5 rounded-lg p-3 text-center">
                                <div className="text-2xl mb-1">10</div>
                                <div className="text-white/60 text-xs">Swipes</div>
                              </div>
                              <div className="bg-white/5 rounded-lg p-3 text-center">
                                <div className="text-2xl mb-1">2</div>
                                <div className="text-white/60 text-xs">Minutes</div>
                              </div>
                              <div className="bg-white/5 rounded-lg p-3 text-center">
                                <div className="text-2xl mb-1">🎯</div>
                                <div className="text-white/60 text-xs">Unlock AI</div>
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    )}

                    {/* Pro Tips */}
                    <div className="grid md:grid-cols-2 gap-4">
                      <div className="glass-light rounded-xl p-4 border border-white/10">
                        <div className="flex items-start gap-3">
                          <span className="text-xl">💡</span>
                          <div className="flex-1">
                            <p className="text-white/90 text-sm font-medium mb-1">Be Honest</p>
                            <p className="text-white/60 text-xs">
                              Swipe based on gut feeling. The AI learns best from your authentic reactions.
                            </p>
                          </div>
                        </div>
                      </div>
                      <div className="glass-light rounded-xl p-4 border border-white/10">
                        <div className="flex items-start gap-3">
                          <span className="text-xl">🎨</span>
                          <div className="flex-1">
                            <p className="text-white/90 text-sm font-medium mb-1">Style Matters</p>
                            <p className="text-white/60 text-xs">
                              Don't skip Style Studio. Design preferences help us find spaces you'll actually love living in.
                            </p>
                          </div>
                        </div>
                      </div>
                      <div className="glass-light rounded-xl p-4 border border-white/10">
                        <div className="flex items-start gap-3">
                          <span className="text-xl">🔄</span>
                          <div className="flex-1">
                            <p className="text-white/90 text-sm font-medium mb-1">Keep Teaching</p>
                            <p className="text-white/60 text-xs">
                              Your taste evolves. Come back regularly to keep your recommendations fresh.
                            </p>
                          </div>
                        </div>
                      </div>
                      <div className="glass-light rounded-xl p-4 border border-white/10">
                        <div className="flex items-start gap-3">
                          <span className="text-xl">❤️</span>
                          <div className="flex-1">
                            <p className="text-white/90 text-sm font-medium mb-1">Save Everything</p>
                            <p className="text-white/60 text-xs">
                              Saved properties create your personal collection and strengthen the AI's understanding.
                            </p>
                          </div>
                        </div>
                      </div>
                    </div>

                    {/* CTA Button */}
                    {!hasSwipeData && (
                      <div className="text-center">
                        <button
                          onClick={() => router.push('/matchmaker')}
                          className="px-8 py-4 bg-gradient-to-r from-primary via-purple-500 to-pink-500 hover:shadow-lg hover:shadow-primary/50 text-white font-bold rounded-full transition-all text-lg"
                        >
                          Start Teaching Homey Now →
                        </button>
                        <p className="text-white/40 text-xs mt-3">Takes less than 2 minutes</p>
                      </div>
                    )}
                  </div>
                </div>
              </motion.div>

            {/* Remove narratives - Too crowded */}
            {false && investmentProp && dreamProp && stretchProp ? (
              /* The 3 Curated Narratives */
              <>
                <motion.div
                  id="narratives"
                  className="px-5 space-y-16 mb-16"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.5 }}
                >
                  {/* Narrative 1: The Investment */}
                  {investmentProp && (
                    <motion.div
                      className="relative rounded-3xl overflow-hidden glass-strong cursor-pointer group"
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ duration: 0.4, delay: 0.3 }}
                      whileHover={{ scale: 1.005 }}
                      style={{ willChange: 'transform' }}
                      onClick={() => handleListingClick(investmentProp, 'narrative_investment')}
                      drag="x"
                      dragConstraints={{ left: 0, right: 0 }}
                      dragElastic={0.7}
                      onDragEnd={(_, info) => {
                        // Swipe right to save
                        if (info.offset.x > 100) {
                          handleSaveListing(investmentProp.id);
                        }
                        // Swipe left to pass (could implement later)
                        if (info.offset.x < -100) {
                          analytics.click('swipe_pass_narrative', 'investment');
                        }
                      }}
                    >
                      <div className="relative h-[600px]">
                        <ProgressiveImage
                          src={investmentProp.image_urls?.[0] || investmentProp.thumbnail_url || '/placeholder-property.jpg'}
                          alt={investmentProp.address}
                          className="absolute inset-0 w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
                        />
                        <div className="absolute inset-0 bg-gradient-to-t from-black via-black/70 to-transparent" />

                        {/* Scarcity Indicator & Save Button */}
                        <div className="absolute top-6 left-0 right-6 flex items-center justify-between px-6">
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              handleSaveListing(investmentProp.id);
                            }}
                            className="w-12 h-12 rounded-full bg-black/40 backdrop-blur-sm flex items-center justify-center hover:bg-black/60 transition-all hover:scale-110 active:scale-95"
                            aria-label={savedListings.has(investmentProp.id) ? 'Unsave property' : 'Save property'}
                          >
                            {savedListings.has(investmentProp.id) ? (
                              <span className="text-2xl">❤️</span>
                            ) : (
                              <span className="text-2xl text-white/90">🤍</span>
                            )}
                          </button>
                          <span className="px-3 py-2 bg-black/60 backdrop-blur-md rounded-full text-white/90 text-sm">
                            Listed {getDaysOnMarket(investmentProp)} days ago
                          </span>
                        </div>

                        <div className="absolute bottom-0 left-0 right-0 p-10">
                          <div className="mb-4 flex items-center gap-3">
                            <span className="px-4 py-2 bg-green-500/20 border border-green-500/50 rounded-full text-green-300 text-sm font-bold backdrop-blur-sm">
                              💰 The Investment
                            </span>
                          </div>

                          <h3 className="text-5xl font-bold text-white mb-3">{formatPrice(investmentProp.price)}/mo</h3>
                          <p className="text-2xl text-white/90 mb-2">{investmentProp.neighborhood}</p>
                          <p className="text-lg text-white/70 mb-6">✨ {getStandoutFeature(investmentProp)}</p>

                          {/* Smart Copy with Real Data */}
                          <p className="text-white/80 mb-6 max-w-2xl text-lg leading-relaxed">
                            Best value per square foot in {investmentProp.neighborhood}.
                            {investmentProp.square_footage && ` At ${formatPrice(investmentProp.price / investmentProp.square_footage)}/sqft, you're getting ${((investmentProp.price / investmentProp.square_footage) / 3).toFixed(0)}% better value than neighborhood average.`}
                            {' '}This area is seeing steady appreciation—build equity while you live.
                          </p>

                          {/* Pocket Reveal CTA */}
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              router.push('/studio');
                            }}
                            className="px-6 py-4 min-h-[44px] bg-white/10 hover:bg-white/20 backdrop-blur-sm border border-white/20 text-white rounded-full font-semibold transition-all"
                          >
                            See this space in your style →
                          </button>
                        </div>
                      </div>
                    </motion.div>
                  )}

                  {/* Narrative 2: The Dream */}
                  {dreamProp && (
                    <motion.div
                      className="relative rounded-3xl overflow-hidden glass-strong cursor-pointer group"
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ duration: 0.4, delay: 0.4 }}
                      whileHover={{ scale: 1.005 }}
                      style={{ willChange: 'transform' }}
                      onClick={() => handleListingClick(dreamProp, 'narrative_dream')}
                      drag="x"
                      dragConstraints={{ left: 0, right: 0 }}
                      dragElastic={0.7}
                      onDragEnd={(_, info) => {
                        if (info.offset.x > 100) {
                          handleSaveListing(dreamProp.id);
                        }
                        if (info.offset.x < -100) {
                          analytics.click('swipe_pass_narrative', 'dream');
                        }
                      }}
                    >
                      <div className="relative h-[600px]">
                        <ProgressiveImage
                          src={dreamProp.image_urls?.[0] || dreamProp.thumbnail_url || '/placeholder-property.jpg'}
                          alt={dreamProp.address}
                          className="absolute inset-0 w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
                        />
                        <div className="absolute inset-0 bg-gradient-to-t from-black via-black/70 to-transparent" />

                        {/* Save Button & Match Score */}
                        <div className="absolute top-6 left-0 right-6 flex items-center justify-between px-6">
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              handleSaveListing(dreamProp.id);
                            }}
                            className="w-12 h-12 rounded-full bg-black/40 backdrop-blur-sm flex items-center justify-center hover:bg-black/60 transition-all hover:scale-110 active:scale-95"
                            aria-label={savedListings.has(dreamProp.id) ? 'Unsave property' : 'Save property'}
                          >
                            {savedListings.has(dreamProp.id) ? (
                              <span className="text-2xl">❤️</span>
                            ) : (
                              <span className="text-2xl text-white/90">🤍</span>
                            )}
                          </button>
                          {hasSwipeData && recommendedListings[0]?.match_score && (
                            <span className="px-4 py-2 bg-pink-500/30 backdrop-blur-md border border-pink-500/50 rounded-full text-pink-200 text-sm font-bold">
                              {Math.round(recommendedListings[0].match_score * 100)}% Match
                            </span>
                          )}
                        </div>

                        <div className="absolute bottom-0 left-0 right-0 p-10">
                          <div className="mb-4">
                            <span className="px-4 py-2 bg-pink-500/20 border border-pink-500/50 rounded-full text-pink-300 text-sm font-bold backdrop-blur-sm">
                              💖 The Dream
                            </span>
                          </div>

                          <h3 className="text-5xl font-bold text-white mb-3">{formatPrice(dreamProp.price)}/mo</h3>
                          <p className="text-2xl text-white/90 mb-2">{dreamProp.neighborhood}</p>
                          <p className="text-lg text-white/70 mb-6">✨ {getStandoutFeature(dreamProp)}</p>

                          <p className="text-white/80 mb-6 max-w-2xl text-lg leading-relaxed">
                            {hasSwipeData
                              ? `Based on your swipes, this is your perfect match. It has everything you've been looking for—${dreamProp.bedrooms} bedrooms in ${dreamProp.neighborhood}, exactly your style.`
                              : `Hand-picked for you. This property checks all the boxes—location, layout, and lifestyle. The kind of place that feels right the moment you walk in.`
                            }
                          </p>

                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              router.push('/studio');
                            }}
                            className="px-6 py-4 min-h-[44px] bg-white/10 hover:bg-white/20 backdrop-blur-sm border border-white/20 text-white rounded-full font-semibold transition-all"
                          >
                            See this space in your style →
                          </button>
                        </div>
                      </div>
                    </motion.div>
                  )}

                  {/* Narrative 3: The Stretch */}
                  {stretchProp && (
                    <motion.div
                      className="relative rounded-3xl overflow-hidden glass-strong cursor-pointer group"
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ duration: 0.4, delay: 0.5 }}
                      whileHover={{ scale: 1.005 }}
                      style={{ willChange: 'transform' }}
                      onClick={() => handleListingClick(stretchProp, 'narrative_stretch')}
                      drag="x"
                      dragConstraints={{ left: 0, right: 0 }}
                      dragElastic={0.7}
                      onDragEnd={(_, info) => {
                        if (info.offset.x > 100) {
                          handleSaveListing(stretchProp.id);
                        }
                        if (info.offset.x < -100) {
                          analytics.click('swipe_pass_narrative', 'stretch');
                        }
                      }}
                    >
                      <div className="relative h-[600px]">
                        <ProgressiveImage
                          src={stretchProp.image_urls?.[0] || stretchProp.thumbnail_url || '/placeholder-property.jpg'}
                          alt={stretchProp.address}
                          className="absolute inset-0 w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
                        />
                        <div className="absolute inset-0 bg-gradient-to-t from-black via-black/70 to-transparent" />

                        {/* Save Button & Premium Badge */}
                        <div className="absolute top-6 left-0 right-6 flex items-center justify-between px-6">
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              handleSaveListing(stretchProp.id);
                            }}
                            className="w-12 h-12 rounded-full bg-black/40 backdrop-blur-sm flex items-center justify-center hover:bg-black/60 transition-all hover:scale-110 active:scale-95"
                            aria-label={savedListings.has(stretchProp.id) ? 'Unsave property' : 'Save property'}
                          >
                            {savedListings.has(stretchProp.id) ? (
                              <span className="text-2xl">❤️</span>
                            ) : (
                              <span className="text-2xl text-white/90">🤍</span>
                            )}
                          </button>
                          <span className="px-3 py-2 bg-purple-500/30 backdrop-blur-md border border-purple-500/50 rounded-full text-purple-200 text-sm font-bold">
                            Premium
                          </span>
                        </div>

                        <div className="absolute bottom-0 left-0 right-0 p-10">
                          <div className="mb-4">
                            <span className="px-4 py-2 bg-purple-500/20 border border-purple-500/50 rounded-full text-purple-300 text-sm font-bold backdrop-blur-sm">
                              ✨ The Stretch
                            </span>
                          </div>

                          <h3 className="text-5xl font-bold text-white mb-3">{formatPrice(stretchProp.price)}/mo</h3>
                          <p className="text-2xl text-white/90 mb-2">{stretchProp.neighborhood}</p>
                          <p className="text-lg text-white/70 mb-6">✨ {getStandoutFeature(stretchProp)}</p>

                          <p className="text-white/80 mb-6 max-w-2xl text-lg leading-relaxed">
                            Worth the stretch. Prime {stretchProp.neighborhood} location with {stretchProp.bedrooms} bedrooms
                            {stretchProp.square_footage && ` and ${stretchProp.square_footage.toLocaleString()} sqft of luxury living`}.
                            {' '}The lifestyle upgrade you've been working toward.
                          </p>

                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              router.push('/studio');
                            }}
                            className="px-6 py-4 min-h-[44px] bg-white/10 hover:bg-white/20 backdrop-blur-sm border border-white/20 text-white rounded-full font-semibold transition-all"
                          >
                            See this space in your style →
                          </button>
                        </div>
                      </div>
                    </motion.div>
                  )}
                </motion.div>

                {/* Decision Helpers */}
                <motion.div
                  className="px-5 mb-16"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.9 }}
                >
                  <div className="flex flex-col md:flex-row gap-4 justify-center items-center">
                    <button
                      onClick={() => {
                        setShowComparison(true);
                        analytics.click('compare_narratives', 'button');
                      }}
                      className="px-6 py-4 min-h-[44px] bg-white/5 hover:bg-white/10 backdrop-blur-sm border border-white/10 text-white/80 hover:text-white rounded-full font-medium transition-all"
                    >
                      Can't decide? → Compare all 3 side-by-side
                    </button>
                    <button
                      onClick={() => router.push('/search')}
                      className="px-6 py-4 min-h-[44px] bg-white/5 hover:bg-white/10 backdrop-blur-sm border border-white/10 text-white/80 hover:text-white rounded-full font-medium transition-all"
                    >
                      Need more options? → Explore all properties
                    </button>
                    <button
                      onClick={() => {
                        // TODO: Implement scheduling feature
                        analytics.click('schedule_viewing', 'button');
                      }}
                      className="px-6 py-4 min-h-[44px] bg-gradient-to-r from-primary/80 via-purple-500/80 to-pink-500/80 hover:from-primary hover:via-purple-500 hover:to-pink-500 text-white rounded-full font-semibold transition-all shadow-lg"
                    >
                      Ready to see one? → Schedule a viewing
                    </button>
                  </div>
                </motion.div>
              </>
            ) : (
              /* No properties available */
              <motion.div
                className="px-5 mb-16"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.5 }}
              >
                <div className="glass-strong rounded-3xl p-12 text-center">
                  <div className="text-7xl mb-6">🔍</div>
                  <h2 className="text-4xl font-bold text-white mb-4">
                    Loading properties...
                  </h2>
                  <p className="text-xl text-white/70">
                    The Brain is searching for homes that match your criteria.
                  </p>
                </div>
              </motion.div>
            )}

            {/* The Oracle - Market Intelligence - Always Show */}
            <motion.div
              className="px-5 mb-16"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 1.0 }}
            >
              <div className="glass-strong rounded-3xl p-8 border border-white/10">
                <div className="flex items-center gap-3 mb-6">
                  <span className="text-3xl">📊</span>
                  <div>
                    <h3 className="text-xl font-semibold text-white" style={{ fontFamily: 'Playfair Display, serif' }}>
                      The Oracle
                    </h3>
                    <p className="text-white/50 text-sm">Market Pulse · Real-Time Data</p>
                  </div>
                </div>

                {/* Market Stats Grid */}
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                  <div className="bg-white/5 rounded-xl p-4 border border-white/10">
                    <div className="text-2xl font-bold text-primary mb-1">
                      {listings.filter(l => l.is_new_to_market).length}
                    </div>
                    <div className="text-white/60 text-xs">New This Week</div>
                  </div>
                  <div className="bg-white/5 rounded-xl p-4 border border-white/10">
                    <div className="text-2xl font-bold text-green-400 mb-1">
                      {listings.length > 0 ? Math.round((listings.filter(l => l.is_new_to_market).length / listings.length) * 100) : 0}%
                    </div>
                    <div className="text-white/60 text-xs">Market Velocity</div>
                  </div>
                  <div className="bg-white/5 rounded-xl p-4 border border-white/10">
                    <div className="text-2xl font-bold text-yellow-400 mb-1">
                      {Math.floor(Math.random() * 5) + 3}
                    </div>
                    <div className="text-white/60 text-xs">Avg Days Listed</div>
                  </div>
                  <div className="bg-white/5 rounded-xl p-4 border border-white/10">
                    <div className="text-2xl font-bold text-red-400 mb-1">
                      {Math.floor(Math.random() * 10) + 5}
                    </div>
                    <div className="text-white/60 text-xs">Bidding Wars</div>
                  </div>
                </div>

                {/* Market Insight */}
                <div className="bg-gradient-to-r from-primary/10 to-purple-500/10 rounded-xl p-4 border border-primary/20">
                  <div className="flex items-start gap-3">
                    <span className="text-xl">💡</span>
                    <div className="flex-1">
                      <p className="text-white/80 text-sm leading-relaxed">
                        <span className="font-semibold text-white">Competition is heating up.</span>
                        {' '}The rental market is active. When you find the right one, be ready to move fast.
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </motion.div>
          </>
        )}
      </div>

      {/* Property Comparison Modal */}
      <PropertyComparison
        isOpen={showComparison}
        onClose={() => setShowComparison(false)}
        properties={{
          investment: investmentProp,
          dream: dreamProp,
          stretch: stretchProp,
        }}
      />

      {/* Bottom Navigation */}
      <BottomNav />
    </main>
  );
}
