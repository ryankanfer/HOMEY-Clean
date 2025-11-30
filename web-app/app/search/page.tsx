'use client';

import { useState, useEffect } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { db, auth } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';
import type { Listing } from '@/lib/types';
import CinematicBackground from '@/components/CinematicBackground';
import PropertyCard from '@/components/PropertyCard';
import SkeletonPropertyCard from '@/components/SkeletonPropertyCard';
import PropertyMap from '@/components/PropertyMap';
import MatchScore from '@/components/MatchScore';
import NeighborhoodFilter from '@/components/NeighborhoodFilter';

export default function SearchPage() {
  const router = useRouter();
  const searchParams = useSearchParams();

  const [listings, setListings] = useState<Listing[]>([]);
  const [loading, setLoading] = useState(true);
  const [showFilters, setShowFilters] = useState(false);
  const [viewMode, setViewMode] = useState<'grid' | 'map'>('grid');
  const [savedListings, setSavedListings] = useState<Set<string>>(new Set());

  // AI-powered search
  const [userId, setUserId] = useState<string | null>(null);
  const [naturalLanguageQuery, setNaturalLanguageQuery] = useState('');
  const [learnedPreferences, setLearnedPreferences] = useState<any>(null);
  const [recommendedListings, setRecommendedListings] = useState<any[]>([]);
  const [showSuggestions, setShowSuggestions] = useState(false);

  // Filter state
  const [filters, setFilters] = useState({
    minPrice: '',
    maxPrice: '',
    minBedrooms: '',
    minBathrooms: '',
    neighborhood: searchParams.get('neighborhood') || '',
    propertyType: '',
    sortBy: 'newest',
  });

  // Neighborhood filter state (multiple selections)
  const [selectedNeighborhoods, setSelectedNeighborhoods] = useState<string[]>([]);

  useEffect(() => {
    analytics.pageView('search');
    loadUserPreferences();
  }, []);

  useEffect(() => {
    searchListings();
  }, [filters, selectedNeighborhoods]);

  const loadUserPreferences = async () => {
    try {
      const { data: { user } } = await auth.getUser();
      if (!user) return;

      setUserId(user.id);

      // Load saved properties
      const { data: savedProps } = await db.getSavedProperties(user.id);
      if (savedProps && savedProps.length > 0) {
        const savedIds = new Set(savedProps.map((sp: any) => sp.listing_id));
        setSavedListings(savedIds);
        console.log(`💾 Loaded ${savedIds.size} saved properties`);
      }

      // Get learned preferences from swipe history
      const { data: prefs } = await db.getUserLearnedPreferences(user.id);
      if (prefs) {
        setLearnedPreferences(prefs);
      }
    } catch (err) {
      console.error('Failed to load user preferences:', err);
    }
  };

  const parseNaturalLanguageQuery = (query: string) => {
    const parsed: any = {};
    const lowerQuery = query.toLowerCase();

    // Extract bedroom count
    const bedroomMatch = lowerQuery.match(/(\d+)\s*(bed|br|bedroom)/);
    if (bedroomMatch) {
      parsed.minBedrooms = bedroomMatch[1];
    }

    // Extract bathroom count
    const bathroomMatch = lowerQuery.match(/(\d+(\.\d+)?)\s*(bath|bathroom)/);
    if (bathroomMatch) {
      parsed.minBathrooms = bathroomMatch[1];
    }

    // Extract price range
    const priceMatch = lowerQuery.match(/(\$|under|below|max)\s*(\d+)k?/);
    if (priceMatch) {
      let price = parseInt(priceMatch[2]);
      if (!lowerQuery.includes('k')) {
        price = price; // Assume it's already in dollars
      } else {
        price = price * 1000;
      }
      parsed.maxPrice = price.toString();
    }

    const minPriceMatch = lowerQuery.match(/(over|above|min)\s*(\$)?(\d+)k?/);
    if (minPriceMatch) {
      let price = parseInt(minPriceMatch[3]);
      if (lowerQuery.includes('k')) {
        price = price * 1000;
      }
      parsed.minPrice = price.toString();
    }

    // Extract neighborhood or location keywords
    const neighborhoods = ['downtown', 'midtown', 'uptown', 'suburbs', 'beach', 'hills'];
    neighborhoods.forEach(n => {
      if (lowerQuery.includes(n)) {
        parsed.neighborhood = n;
      }
    });

    return parsed;
  };

  const handleNaturalLanguageSearch = () => {
    if (!naturalLanguageQuery.trim()) return;

    const parsed = parseNaturalLanguageQuery(naturalLanguageQuery);
    setFilters(prev => ({
      ...prev,
      ...parsed,
    }));

    analytics.performSearch({
      query: naturalLanguageQuery,
      parsed_filters: parsed,
    });
  };

  const searchListings = async () => {
    setLoading(true);

    // If sorting by match score, use recommendation engine
    if (filters.sortBy === 'match' && userId) {
      const { data: recommended } = await db.getRecommendedListings(userId, 50);

      if (recommended) {
        setRecommendedListings(recommended);

        // Apply filters to recommended listings
        let filtered = [...recommended];

        if (filters.minPrice) {
          filtered = filtered.filter(l => l.price >= parseInt(filters.minPrice));
        }
        if (filters.maxPrice) {
          filtered = filtered.filter(l => l.price <= parseInt(filters.maxPrice));
        }
        if (filters.minBedrooms) {
          filtered = filtered.filter(l => l.bedrooms >= parseInt(filters.minBedrooms));
        }
        if (filters.minBathrooms) {
          filtered = filtered.filter(l => l.bathrooms >= parseFloat(filters.minBathrooms));
        }
        if (filters.neighborhood) {
          filtered = filtered.filter(l =>
            l.neighborhood?.toLowerCase().includes(filters.neighborhood.toLowerCase())
          );
        }
        if (selectedNeighborhoods.length > 0) {
          filtered = filtered.filter(l =>
            selectedNeighborhoods.some(n =>
              l.neighborhood?.toLowerCase().includes(n.toLowerCase())
            )
          );
        }

        setListings(filtered);

        analytics.performSearch({
          sortBy: 'match',
          resultsCount: filtered.length,
        });

        setLoading(false);
        return;
      }
    }

    const searchFilters: any = {};

    if (filters.minPrice) searchFilters.minPrice = parseInt(filters.minPrice);
    if (filters.maxPrice) searchFilters.maxPrice = parseInt(filters.maxPrice);
    if (filters.minBedrooms) searchFilters.minBedrooms = parseInt(filters.minBedrooms);
    if (filters.neighborhood) searchFilters.neighborhood = filters.neighborhood;

    // Add neighborhoods array filter (takes precedence over single neighborhood)
    if (selectedNeighborhoods.length > 0) {
      searchFilters.neighborhoods = selectedNeighborhoods;
      delete searchFilters.neighborhood; // Remove single neighborhood if array is set
    }

    const { data, error } = await db.getListings(searchFilters);

    if (!error && data) {
      let sorted = [...data];

      // Sort results
      switch (filters.sortBy) {
        case 'price_low':
          sorted.sort((a, b) => a.price - b.price);
          break;
        case 'price_high':
          sorted.sort((a, b) => b.price - a.price);
          break;
        case 'bedrooms':
          sorted.sort((a, b) => b.bedrooms - a.bedrooms);
          break;
        default: // newest
          sorted.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());
      }

      setListings(sorted);
      setRecommendedListings([]);

      // Track search
      analytics.performSearch({
        ...searchFilters,
        resultsCount: sorted.length,
      });
    }

    setLoading(false);
  };

  // Handle save/unsave listing
  const handleSaveListing = async (listingId: string) => {
    try {
      if (!userId) {
        alert('Please sign in to save properties');
        return;
      }

      const isSaved = savedListings.has(listingId);

      if (isSaved) {
        // Unsave
        await db.unsaveProperty(userId, listingId);
        setSavedListings(prev => {
          const newSet = new Set(prev);
          newSet.delete(listingId);
          return newSet;
        });
        analytics.click('unsave_listing', 'button', { listing_id: listingId, context: 'search' });
      } else {
        // Save
        await db.saveProperty(userId, listingId);
        setSavedListings(prev => new Set(prev).add(listingId));
        analytics.saveListing(listingId);
        console.log('💾 Property saved - AI will learn from this!');
      }
    } catch (error) {
      console.error('Failed to save/unsave property:', error);
      alert('Failed to update saved status. Please try again.');
    }
  };

  const clearFilters = () => {
    setFilters({
      minPrice: '',
      maxPrice: '',
      minBedrooms: '',
      minBathrooms: '',
      neighborhood: '',
      propertyType: '',
      sortBy: 'newest',
    });
    setSelectedNeighborhoods([]);
    setNaturalLanguageQuery('');
  };

  const applySuggestedFilters = (suggestion: any) => {
    setFilters(prev => ({
      ...prev,
      ...suggestion,
    }));
    setShowSuggestions(false);
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      maximumFractionDigits: 0,
    }).format(price);
  };

  const hasActiveFilters = Object.values(filters).some(
    (v, i) => i !== 6 && v !== '' // Exclude sortBy
  ) || selectedNeighborhoods.length > 0;

  return (
    <main className="relative min-h-screen pb-24">
      <CinematicBackground timeOfDay="day" />

      {/* Dark overlay for better text contrast */}
      <div className="fixed inset-0 z-0 bg-gradient-to-b from-black/30 via-black/20 to-black/40" />

      {/* Header */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-gradient-to-b from-black/80 via-black/60 to-transparent backdrop-blur-md">
        <div className="px-5 py-4">
          <div className="flex items-center justify-between mb-4">
            <button
              onClick={() => router.back()}
              className="w-11 h-11 rounded-full bg-white/10 flex items-center justify-center text-xl hover:bg-white/20 transition-colors text-white"
            >
              ←
            </button>
            <h1 className="text-xl font-bold text-white">Search Properties</h1>
            <div className="flex gap-2">
              <button
                onClick={() => setViewMode(viewMode === 'grid' ? 'map' : 'grid')}
                className="w-11 h-11 rounded-full bg-white/10 flex items-center justify-center text-xl hover:bg-white/20 transition-colors text-white"
                title={viewMode === 'grid' ? 'Switch to map view' : 'Switch to grid view'}
              >
                {viewMode === 'grid' ? '🗺️' : '▦'}
              </button>
              <button
                onClick={() => setShowFilters(!showFilters)}
                className={`w-11 h-11 rounded-full flex items-center justify-center text-xl transition-colors ${
                  hasActiveFilters
                    ? 'bg-primary text-white'
                    : 'bg-white/10 text-white hover:bg-white/20'
                }`}
              >
                ⚙️
              </button>
            </div>
          </div>

          {/* AI-Powered Natural Language Search */}
          <div className="space-y-3">
            <div className="relative">
              <input
                type="text"
                placeholder="Try: '3 bed house under $500k in downtown' or 'luxury condo with parking'"
                value={naturalLanguageQuery}
                onChange={(e) => setNaturalLanguageQuery(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === 'Enter') {
                    handleNaturalLanguageSearch();
                  }
                }}
                className="w-full px-4 py-3 pl-12 pr-24 bg-white/10 backdrop-blur-sm rounded-full text-white placeholder-white/60 focus:outline-none focus:ring-2 focus:ring-primary"
              />
              <span className="absolute left-4 top-1/2 -translate-y-1/2 text-xl">✨</span>
              {naturalLanguageQuery && (
                <>
                  <button
                    onClick={() => setNaturalLanguageQuery('')}
                    className="absolute right-16 top-1/2 -translate-y-1/2 text-white/60 hover:text-white"
                  >
                    ✕
                  </button>
                  <button
                    onClick={handleNaturalLanguageSearch}
                    className="absolute right-3 top-1/2 -translate-y-1/2 px-3 py-1 bg-primary rounded-full text-white text-sm font-bold hover:bg-primary/90 transition-colors"
                  >
                    Go
                  </button>
                </>
              )}
            </div>

            {/* Smart Filter Suggestions */}
            {learnedPreferences && learnedPreferences.total_swipes > 5 && (
              <div>
                <button
                  onClick={() => setShowSuggestions(!showSuggestions)}
                  className="text-white/80 text-sm hover:text-white transition-colors flex items-center gap-1"
                >
                  <span>💡</span>
                  <span>Smart suggestions based on your taste</span>
                  <span className="text-xs">{showSuggestions ? '▼' : '▶'}</span>
                </button>

                <AnimatePresence>
                  {showSuggestions && (
                    <motion.div
                      initial={{ height: 0, opacity: 0 }}
                      animate={{ height: 'auto', opacity: 1 }}
                      exit={{ height: 0, opacity: 0 }}
                      className="flex flex-wrap gap-2 mt-2 overflow-hidden"
                    >
                      {/* Price Range Suggestion */}
                      {learnedPreferences.preferred_min_price && learnedPreferences.preferred_max_price && (
                        <button
                          onClick={() => applySuggestedFilters({
                            minPrice: Math.floor(learnedPreferences.preferred_min_price).toString(),
                            maxPrice: Math.ceil(learnedPreferences.preferred_max_price).toString(),
                          })}
                          className="px-3 py-1.5 bg-primary/20 border border-primary/40 rounded-full text-white text-sm hover:bg-primary/30 transition-colors backdrop-blur-sm"
                        >
                          Your price range: {formatPrice(learnedPreferences.preferred_min_price)} - {formatPrice(learnedPreferences.preferred_max_price)}
                        </button>
                      )}

                      {/* Bedroom Suggestions */}
                      {learnedPreferences.preferred_bedrooms && learnedPreferences.preferred_bedrooms.length > 0 && (
                        <button
                          onClick={() => applySuggestedFilters({
                            minBedrooms: Math.min(...learnedPreferences.preferred_bedrooms).toString(),
                          })}
                          className="px-3 py-1.5 bg-purple-500/20 border border-purple-500/40 rounded-full text-white text-sm hover:bg-purple-500/30 transition-colors backdrop-blur-sm"
                        >
                          {learnedPreferences.preferred_bedrooms.join(' or ')} bedrooms
                        </button>
                      )}

                      {/* Neighborhood Suggestions */}
                      {learnedPreferences.preferred_neighborhoods && learnedPreferences.preferred_neighborhoods.length > 0 && (
                        learnedPreferences.preferred_neighborhoods.slice(0, 3).map((neighborhood: string) => (
                          <button
                            key={neighborhood}
                            onClick={() => applySuggestedFilters({
                              neighborhood,
                            })}
                            className="px-3 py-1.5 bg-pink-500/20 border border-pink-500/40 rounded-full text-white text-sm hover:bg-pink-500/30 transition-colors backdrop-blur-sm"
                          >
                            📍 {neighborhood}
                          </button>
                        ))
                      )}

                      {/* Best Match Sorting */}
                      {userId && (
                        <button
                          onClick={() => applySuggestedFilters({
                            sortBy: 'match',
                          })}
                          className="px-3 py-1.5 bg-green-500/20 border border-green-500/40 rounded-full text-white text-sm hover:bg-green-500/30 transition-colors backdrop-blur-sm"
                        >
                          ✨ Show best matches
                        </button>
                      )}
                    </motion.div>
                  )}
                </AnimatePresence>
              </div>
            )}

            {/* Quick Filter Chips - Always Visible */}
            <div className="flex gap-2 overflow-x-auto scrollbar-hide pb-2">
              <motion.button
                onClick={() => setFilters(prev => ({ ...prev, maxPrice: '3000' }))}
                whileTap={{ scale: 0.95 }}
                className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all min-h-[44px] ${
                  filters.maxPrice === '3000'
                    ? 'bg-primary text-white'
                    : 'bg-white/10 text-white hover:bg-white/20'
                }`}
              >
                💵 Under $3k
              </motion.button>

              <motion.button
                onClick={() => {
                  // Filter by pet-friendly in the next search
                  setFilters(prev => ({ ...prev, propertyType: 'pet-friendly' }));
                }}
                whileTap={{ scale: 0.95 }}
                className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all min-h-[44px] ${
                  filters.propertyType === 'pet-friendly'
                    ? 'bg-primary text-white'
                    : 'bg-white/10 text-white hover:bg-white/20'
                }`}
              >
                🐕 Pet-friendly
              </motion.button>

              <motion.button
                onClick={() => {
                  setFilters(prev => ({ ...prev, propertyType: 'move-in-ready' }));
                }}
                whileTap={{ scale: 0.95 }}
                className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all min-h-[44px] ${
                  filters.propertyType === 'move-in-ready'
                    ? 'bg-primary text-white'
                    : 'bg-white/10 text-white hover:bg-white/20'
                }`}
              >
                ✨ Move-in ready
              </motion.button>

              <motion.button
                onClick={() => setFilters(prev => ({ ...prev, minBedrooms: '2' }))}
                whileTap={{ scale: 0.95 }}
                className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all min-h-[44px] ${
                  filters.minBedrooms === '2'
                    ? 'bg-primary text-white'
                    : 'bg-white/10 text-white hover:bg-white/20'
                }`}
              >
                🛏️ 2+ Beds
              </motion.button>

              <motion.button
                onClick={() => {
                  setFilters(prev => ({ ...prev, propertyType: 'doorman' }));
                }}
                whileTap={{ scale: 0.95 }}
                className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all min-h-[44px] ${
                  filters.propertyType === 'doorman'
                    ? 'bg-primary text-white'
                    : 'bg-white/10 text-white hover:bg-white/20'
                }`}
              >
                🚪 Doorman
              </motion.button>

              <motion.button
                onClick={() => {
                  setFilters(prev => ({ ...prev, propertyType: 'laundry' }));
                }}
                whileTap={{ scale: 0.95 }}
                className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all min-h-[44px] ${
                  filters.propertyType === 'laundry'
                    ? 'bg-primary text-white'
                    : 'bg-white/10 text-white hover:bg-white/20'
                }`}
              >
                🧺 In-unit laundry
              </motion.button>

              {hasActiveFilters && (
                <motion.button
                  initial={{ scale: 0.8, opacity: 0 }}
                  animate={{ scale: 1, opacity: 1 }}
                  onClick={clearFilters}
                  whileTap={{ scale: 0.95 }}
                  className="px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap bg-red-500/20 text-red-200 hover:bg-red-500/30 transition-all min-h-[44px]"
                >
                  ✕ Clear all
                </motion.button>
              )}
            </div>
          </div>
        </div>

        {/* Filter Panel */}
        <AnimatePresence>
          {showFilters && (
            <motion.div
              initial={{ height: 0, opacity: 0 }}
              animate={{ height: 'auto', opacity: 1 }}
              exit={{ height: 0, opacity: 0 }}
              transition={{ duration: 0.3 }}
              className="overflow-hidden bg-black/40 backdrop-blur-md border-t border-white/10"
            >
              <div className="px-5 py-6 space-y-4">
                {/* Price Range */}
                <div>
                  <label className="block text-white font-semibold mb-2">Price Range</label>
                  <div className="grid grid-cols-2 gap-3">
                    <input
                      type="number"
                      placeholder="Min"
                      value={filters.minPrice}
                      onChange={(e) => setFilters({ ...filters, minPrice: e.target.value })}
                      className="px-4 py-2 bg-white/10 rounded-lg text-white placeholder-white/40 focus:outline-none focus:ring-2 focus:ring-primary"
                    />
                    <input
                      type="number"
                      placeholder="Max"
                      value={filters.maxPrice}
                      onChange={(e) => setFilters({ ...filters, maxPrice: e.target.value })}
                      className="px-4 py-2 bg-white/10 rounded-lg text-white placeholder-white/40 focus:outline-none focus:ring-2 focus:ring-primary"
                    />
                  </div>
                </div>

                {/* Bedrooms & Bathrooms */}
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-white font-semibold mb-2">Min Beds</label>
                    <select
                      value={filters.minBedrooms}
                      onChange={(e) => setFilters({ ...filters, minBedrooms: e.target.value })}
                      className="w-full px-4 py-2 bg-white/10 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-primary"
                    >
                      <option value="">Any</option>
                      <option value="0">Studio</option>
                      <option value="1">1+</option>
                      <option value="2">2+</option>
                      <option value="3">3+</option>
                      <option value="4">4+</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-white font-semibold mb-2">Min Baths</label>
                    <select
                      value={filters.minBathrooms}
                      onChange={(e) => setFilters({ ...filters, minBathrooms: e.target.value })}
                      className="w-full px-4 py-2 bg-white/10 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-primary"
                    >
                      <option value="">Any</option>
                      <option value="1">1+</option>
                      <option value="1.5">1.5+</option>
                      <option value="2">2+</option>
                      <option value="3">3+</option>
                    </select>
                  </div>
                </div>

                {/* Neighborhoods */}
                <NeighborhoodFilter
                  selectedNeighborhoods={selectedNeighborhoods}
                  onChange={setSelectedNeighborhoods}
                />

                {/* Sort By */}
                <div>
                  <label className="block text-white font-semibold mb-2">Sort By</label>
                  <select
                    value={filters.sortBy}
                    onChange={(e) => setFilters({ ...filters, sortBy: e.target.value })}
                    className="w-full px-4 py-2 bg-white/10 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-primary"
                  >
                    {userId && <option value="match">✨ Best Match (AI-Powered)</option>}
                    <option value="newest">Newest First</option>
                    <option value="price_low">Price: Low to High</option>
                    <option value="price_high">Price: High to Low</option>
                    <option value="bedrooms">Most Bedrooms</option>
                  </select>
                </div>

                {/* Actions */}
                <div className="flex gap-3 pt-2">
                  <button
                    onClick={clearFilters}
                    className="flex-1 px-4 py-3 bg-white/10 text-white rounded-full font-semibold hover:bg-white/20 transition-colors"
                  >
                    Clear All
                  </button>
                  <button
                    onClick={() => setShowFilters(false)}
                    className="flex-1 px-4 py-3 bg-primary text-white rounded-full font-semibold hover:bg-primary/90 transition-colors"
                  >
                    Apply Filters
                  </button>
                </div>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </header>

      {/* Results */}
      <div className="relative z-10 pt-48">
        <div className="px-5 mb-4">
          <p className="text-white/80">
            {loading ? 'Searching...' : `${listings.length} properties found`}
            {hasActiveFilters && (
              <button
                onClick={clearFilters}
                className="ml-2 text-primary hover:underline"
              >
                (clear filters)
              </button>
            )}
          </p>
        </div>

        {loading ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 px-5">
            {[1, 2, 3, 4, 5, 6, 7, 8].map((i) => (
              <SkeletonPropertyCard key={i} size="medium" />
            ))}
          </div>
        ) : listings.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-64 px-5 text-center">
            <div className="text-6xl mb-4">🔍</div>
            <h2 className="text-2xl font-bold text-white mb-2">No Properties Found</h2>
            <p className="text-white/60 mb-6">Try adjusting your filters to see more results</p>
            <button
              onClick={clearFilters}
              className="px-6 py-3 bg-primary text-white rounded-full font-semibold"
            >
              Clear Filters
            </button>
          </div>
        ) : viewMode === 'map' ? (
          <div className="px-5 h-[calc(100vh-280px)] min-h-[400px] rounded-2xl overflow-hidden">
            <PropertyMap
              listings={listings}
              onMarkerClick={(listing) => {
                analytics.viewListing(listing.id, {
                  price: listing.price,
                  neighborhood: listing.neighborhood,
                  context: 'search_map',
                });
                router.push(`/scout/${listing.id}`);
              }}
            />
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 px-5">
            {listings.map((listing, index) => {
              const matchListing = recommendedListings.find((r: any) => r.id === listing.id);
              const matchScore = matchListing?.match_score;

              return (
                <motion.div
                  key={listing.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.4, delay: index * 0.05 }}
                >
                  <div className="relative">
                    {matchScore && (
                      <div className="absolute top-4 left-4 z-10">
                        <MatchScore score={matchScore} size="small" />
                      </div>
                    )}
                    <PropertyCard
                      listing={listing}
                      size="medium"
                      onClick={() => {
                        analytics.viewListing(listing.id, {
                          price: listing.price,
                          neighborhood: listing.neighborhood,
                          context: 'search_results',
                          match_score: matchScore,
                        });
                        router.push(`/scout/${listing.id}`);
                      }}
                      onSave={handleSaveListing}
                      isSaved={savedListings.has(listing.id)}
                    />
                  </div>
                </motion.div>
              );
            })}
          </div>
        )}
      </div>

    </main>
  );
}
