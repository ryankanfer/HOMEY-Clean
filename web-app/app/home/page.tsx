'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { db, supabase, auth } from '@/lib/supabase';
import { analytics, sessionManager } from '@/lib/analytics';
import type { Listing } from '@/lib/types';
import { getUserPreferences, getLocationDisplayName, type UserPreferences } from '@/lib/preferences';
import { useClientAgent } from '@/hooks/useClientAgent';
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
import JourneyProgress from '@/components/JourneyProgress';
import JourneyProgressEnhanced from '@/components/JourneyProgressEnhanced';
import HomeHeader from '@/components/HomeHeader';
import DailyFocusCard from '@/components/DailyFocusCard';
import QuickActionsHub from '@/components/QuickActionsHub';
import AIInsightsPanel from '@/components/AIInsightsPanel';
import MarketIntelligence from '@/components/MarketIntelligence';
import SmartNotifications from '@/components/SmartNotifications';
import ProgressGamification from '@/components/ProgressGamification';
import AgentHero from '@/components/AgentHero';
import AgentEmptyState from '@/components/AgentEmptyState';
import MessagesModal from '@/components/MessagesModal';
import SingleActionFocus from '@/components/SingleActionFocus';
import AllPages from '@/components/AllPages';
import StyleTuner from '@/components/StyleTuner';
import FeedTabs from '@/components/FeedTabs';
import EditorialFeed from '@/components/EditorialFeed';
import searchRealEstateData from '@/lib/api/realEstateAPI';

export default function HomePage() {
  const router = useRouter();

  // Agent connection hook
  const { agent: agentConnection, hasAgent, loading: agentLoading } = useClientAgent();

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
  const [userPreferences, setUserPreferences] = useState<UserPreferences | null>(null);
  const [showStyleTuner, setShowStyleTuner] = useState(false);
  const [activeEditorialTab, setActiveEditorialTab] = useState('all');
  const [isMessagesOpen, setIsMessagesOpen] = useState(false);

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

      // Load user preferences using centralized function
      const prefs = await getUserPreferences(user.id);
      if (prefs) {
        setUserPreferences(prefs); // Store full preferences for journey tracker
        if (prefs.displayName) {
          setUserName(prefs.displayName);
        } else if (user.user_metadata?.full_name) {
          setUserName(user.user_metadata.full_name.split(' ')[0]);
        }
        if (prefs.neighborhoods) {
          setUserNeighborhoods(prefs.neighborhoods);
        }
        if (prefs.location) {
          setUserLocation(getLocationDisplayName(prefs.location));
        }
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

      {/* Ambient Background Effects */}
      <div className="fixed top-0 left-0 w-full h-full overflow-hidden pointer-events-none z-0">
        <div className="absolute top-[-10%] right-[-10%] w-[500px] h-[500px] bg-purple-900/20 rounded-full blur-[100px]"></div>
        <div className="absolute bottom-[-10%] left-[-20%] w-[600px] h-[600px] bg-blue-900/10 rounded-full blur-[120px]"></div>
      </div>

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
            {/* Enhanced Header with time-based greeting and Shortlist Progress */}
            <HomeHeader
              userName={userName}
              savedCount={savedListings.size}
              onProfileClick={() => router.push('/settings')}
            />

            {/* Home Widgets */}
            <div className="space-y-0">
              {/* Show agent hero if connected, otherwise show empty state */}
              {agentConnection ? (
                <AgentHero
                  agentName={agentConnection.agent?.user?.full_name || 'Your Agent'}
                  agentAvatar={agentConnection.agent?.user?.avatar_url}
                  agentTitle="Your Partner Agent"
                  agentStatus="online"
                  agentPhone={agentConnection.agent?.professional_phone}
                  agentEmail={agentConnection.agent?.professional_email}
                  onMessageClick={() => setIsMessagesOpen(true)}
                  connectionId={agentConnection.id}
                  userId={userId || undefined}
                />
              ) : (
                <AgentEmptyState
                  onConnectAgent={() => router.push('/directory')}
                  onInviteAgent={() => router.push('/onboarding?step=agent')}
                />
              )}

              {/* Section Divider */}
              <div className="relative py-6 px-5">
                <div className="absolute inset-0 bg-gradient-to-b from-transparent via-white/[0.02] to-transparent" />
                <div className="relative flex items-center">
                  <div className="flex-1 border-t border-white/5" />
                  <div className="px-4">
                    <div className="w-1.5 h-1.5 rounded-full bg-white/10" />
                  </div>
                  <div className="flex-1 border-t border-white/5" />
                </div>
              </div>

              <AllPages />

              {/* Section Divider */}
              <div className="relative py-6 px-5">
                <div className="absolute inset-0 bg-gradient-to-b from-transparent via-white/[0.02] to-transparent" />
                <div className="relative flex items-center">
                  <div className="flex-1 border-t border-white/5" />
                  <div className="px-4">
                    <div className="w-1.5 h-1.5 rounded-full bg-white/10" />
                  </div>
                  <div className="flex-1 border-t border-white/5" />
                </div>
              </div>

              <SingleActionFocus
                hasSwipeData={hasSwipeData}
                savedCount={savedListings.size}
              />

              {/* Section Divider */}
              <div className="relative py-6 px-5">
                <div className="absolute inset-0 bg-gradient-to-b from-transparent via-white/[0.02] to-transparent" />
                <div className="relative flex items-center">
                  <div className="flex-1 border-t border-white/5" />
                  <div className="px-4">
                    <div className="w-1.5 h-1.5 rounded-full bg-white/10" />
                  </div>
                  <div className="flex-1 border-t border-white/5" />
                </div>
              </div>

              <JourneyProgressEnhanced
                preferences={userPreferences}
                savedListingsCount={savedListings.size}
                hasSwipeData={hasSwipeData}
              />

              {/* Section Divider */}
              <div className="relative py-6 px-5">
                <div className="absolute inset-0 bg-gradient-to-b from-transparent via-white/[0.02] to-transparent" />
                <div className="relative flex items-center">
                  <div className="flex-1 border-t border-white/5" />
                  <div className="px-4">
                    <div className="w-1.5 h-1.5 rounded-full bg-white/10" />
                  </div>
                  <div className="flex-1 border-t border-white/5" />
                </div>
              </div>

              <FeedTabs onTabChange={setActiveEditorialTab}>
                <EditorialFeed
                  userNeighborhoods={userNeighborhoods}
                  activeTab={activeEditorialTab}
                  hasSwipeData={hasSwipeData}
                />
              </FeedTabs>
            </div>
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

      {/* Style Tuner Modal */}
      <StyleTuner
        isOpen={showStyleTuner}
        onClose={() => setShowStyleTuner(false)}
      />

      {/* Messages Modal */}
      {agentConnection && userId && (
        <MessagesModal
          isOpen={isMessagesOpen}
          onClose={() => setIsMessagesOpen(false)}
          agentName={agentConnection.agent?.user?.full_name || 'Your Agent'}
          agentAvatar={agentConnection.agent?.user?.avatar_url}
          connectionId={agentConnection.id}
          userId={userId}
        />
      )}

      {/* Bottom Navigation */}
      <BottomNav />
    </main>
  );
}
