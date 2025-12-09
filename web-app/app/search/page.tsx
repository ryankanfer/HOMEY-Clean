'use client';

import { Suspense, useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { db, auth } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';
import type { Listing } from '@/lib/types';
import { getUserPreferences } from '@/lib/preferences';
import CinematicBackground from '@/components/CinematicBackground';
import StreamingRail from '@/components/StreamingRail';
import CompactListRail from '@/components/CompactListRail';
import BottomNav from '@/components/BottomNav';
import Tutorial from '@/components/Tutorial';
import { searchTutorialSteps } from '@/lib/tutorialSteps';

function SearchPageContent() {
  const router = useRouter();

  const [allListings, setAllListings] = useState<Listing[]>([]);
  const [loading, setLoading] = useState(true);
  const [savedListings, setSavedListings] = useState<Set<string>>(new Set());
  const [userId, setUserId] = useState<string | null>(null);
  const [userEmail, setUserEmail] = useState<string | null>(null);
  const [recommendedListings, setRecommendedListings] = useState<any[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [sortBy, setSortBy] = useState<'recent' | 'price-low' | 'price-high' | 'neighborhood'>('recent');
  const [showAdvancedFilters, setShowAdvancedFilters] = useState(false);

  // Advanced filter states
  const [listingType, setListingType] = useState<'all' | 'rental' | 'sale'>('all');
  const [minPrice, setMinPrice] = useState<number | ''>('');
  const [maxPrice, setMaxPrice] = useState<number | ''>('');
  const [bedrooms, setBedrooms] = useState<number | 'any'>('any');
  const [bathrooms, setBathrooms] = useState<number | 'any'>('any');
  const [selectedNeighborhoods, setSelectedNeighborhoods] = useState<string[]>([]);
  const [useGeolocation, setUseGeolocation] = useState(false);
  const [userLocation, setUserLocation] = useState<{ lat: number; lng: number } | null>(null);
  const [geoPermissionDenied, setGeoPermissionDenied] = useState(false);
  const [expandedBoroughs, setExpandedBoroughs] = useState<Set<string>>(new Set(['Manhattan']));

  // Static neighborhood list - always available regardless of current listings
  const NEIGHBORHOODS_BY_CITY: { [key: string]: string[] } = {
    'Manhattan': [
      'Battery Park City',
      'Chelsea',
      'Chinatown',
      'East Village',
      'Financial District',
      'Flatiron',
      'Gramercy',
      'Greenwich Village',
      'Harlem',
      'Hell\'s Kitchen',
      'Kips Bay',
      'Little Italy',
      'Lower East Side',
      'Midtown',
      'Murray Hill',
      'NoHo',
      'NoMad',
      'SoHo',
      'Tribeca',
      'Upper East Side',
      'Upper West Side',
      'Washington Heights',
      'West Village',
    ],
    'Brooklyn': [
      'Bay Ridge',
      'Bedford-Stuyvesant',
      'Bensonhurst',
      'Boerum Hill',
      'Borough Park',
      'Brighton Beach',
      'Brooklyn Heights',
      'Bushwick',
      'Carroll Gardens',
      'Clinton Hill',
      'Cobble Hill',
      'Coney Island',
      'Crown Heights',
      'DUMBO',
      'Dyker Heights',
      'East Flatbush',
      'Flatbush',
      'Fort Greene',
      'Gowanus',
      'Gravesend',
      'Greenpoint',
      'Park Slope',
      'Prospect Heights',
      'Red Hook',
      'Sheepshead Bay',
      'Sunset Park',
      'Williamsburg',
    ],
    'Queens': [
      'Astoria',
      'Bayside',
      'College Point',
      'Corona',
      'Elmhurst',
      'Flushing',
      'Forest Hills',
      'Jackson Heights',
      'Kew Gardens',
      'Long Island City',
      'Maspeth',
      'Middle Village',
      'Ridgewood',
      'Rego Park',
      'Sunnyside',
      'Woodside',
    ],
    'Bronx': [
      'Bedford Park',
      'Fordham',
      'Hunts Point',
      'Kingsbridge',
      'Melrose',
      'Mott Haven',
      'Riverdale',
      'Tremont',
      'University Heights',
    ],
    'Staten Island': [
      'Great Kills',
      'New Dorp',
      'Port Richmond',
      'St. George',
      'Stapleton',
      'Tompkinsville',
    ],
  };

  useEffect(() => {
    analytics.pageView('search');
    loadData();
  }, []);

  // Get user's geolocation
  const requestGeolocation = () => {
    if (!navigator.geolocation) {
      alert('Geolocation is not supported by your browser');
      return;
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        setUserLocation({
          lat: position.coords.latitude,
          lng: position.coords.longitude,
        });
        setUseGeolocation(true);
        setGeoPermissionDenied(false);
      },
      (error) => {
        console.error('Geolocation error:', error);
        setGeoPermissionDenied(true);
        alert('Unable to get your location. Please enable location permissions.');
      }
    );
  };

  // Calculate distance between two coordinates (Haversine formula)
  const calculateDistance = (lat1: number, lon1: number, lat2: number, lon2: number) => {
    const R = 3959; // Earth's radius in miles
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a =
      Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
      Math.sin(dLon/2) * Math.sin(dLon/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c;
  };

  const loadData = async () => {
    try {
      const { data: { user } } = await auth.getUser();
      if (user) {
        setUserId(user.id);
        setUserEmail(user.email || null);

        // Load saved listings
        const { data: savedData } = await db.getSavedProperties(user.id);
        if (savedData) {
          const savedIds = new Set(savedData.map((item: any) => item.listing_id));
          setSavedListings(savedIds);
        }

        // Load user preferences and recommendations
        const prefs = await getUserPreferences(user.id);
        if (prefs) {
          // Load AI recommendations
          const { data: recs } = await db.getRecommendedListings(user.id, 10);
          if (recs) {
            setRecommendedListings(recs);
          }
        }
      }

      // Load all listings
      const { data, error } = await db.getListings({});
      if (!error && data) {
        setAllListings(data);
      }

      setLoading(false);
    } catch (error) {
      console.error('Failed to load data:', error);
      setLoading(false);
    }
  };

  const handleSaveListing = async (listingId: string) => {
    if (!userId) {
      alert('Please sign in to save properties');
      return;
    }

    const isSaved = savedListings.has(listingId);

    if (isSaved) {
      await db.unsaveProperty(userId, listingId);
      setSavedListings(prev => {
        const newSet = new Set(prev);
        newSet.delete(listingId);
        return newSet;
      });
      analytics.click('unsave_listing', 'button', { listing_id: listingId });
    } else {
      await db.saveProperty(userId, listingId);
      setSavedListings(prev => new Set(prev).add(listingId));
      analytics.saveListing(listingId);
    }
  };

  const handleCardClick = (listing: Listing) => {
    analytics.viewListing(listing.id, {
      price: listing.price,
      neighborhood: listing.neighborhood,
      context: 'streaming_rail',
    });
    router.push(`/scout/${listing.id}`);
  };

  // Parse conversational search query
  const parseSmartSearch = (query: string) => {
    const q = query.toLowerCase();
    const parsed: any = {};

    // Extract bedrooms
    const bedroomMatch = q.match(/(\d+)\s*(bed|bedroom|br)/);
    if (bedroomMatch) {
      parsed.bedrooms = parseInt(bedroomMatch[1]);
    }

    // Extract bathrooms
    const bathroomMatch = q.match(/(\d+)\s*(bath|bathroom|ba)/);
    if (bathroomMatch) {
      parsed.bathrooms = parseInt(bathroomMatch[1]);
    }

    // Extract price (various formats)
    const priceMatches = q.match(/(?:under|below|max|<|less than)\s*\$?(\d+)k?/);
    if (priceMatches) {
      const price = parseInt(priceMatches[1]);
      parsed.maxPrice = priceMatches[0].includes('k') ? price * 1000 : price;
    }

    const minPriceMatches = q.match(/(?:over|above|min|>|more than)\s*\$?(\d+)k?/);
    if (minPriceMatches) {
      const price = parseInt(minPriceMatches[1]);
      parsed.minPrice = minPriceMatches[0].includes('k') ? price * 1000 : price;
    }

    // Check for listing type
    if (q.includes('rental') || q.includes('rent')) {
      parsed.listingType = 'rental';
    } else if (q.includes('sale') || q.includes('buy')) {
      parsed.listingType = 'sale';
    }

    return parsed;
  };

  // Filter listings based on search and active filter
  const getFilteredListings = () => {
    let filtered = [...allListings];

    // Parse smart search
    const smartFilters = parseSmartSearch(searchQuery);

    // Apply search query (basic text search)
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(l =>
        l.address?.toLowerCase().includes(query) ||
        l.neighborhood?.toLowerCase().includes(query) ||
        l.city?.toLowerCase().includes(query)
      );
    }

    // Apply smart search filters
    if (smartFilters.bedrooms !== undefined) {
      filtered = filtered.filter(l => l.bedrooms >= smartFilters.bedrooms);
    }
    if (smartFilters.bathrooms !== undefined) {
      filtered = filtered.filter(l => l.bathrooms >= smartFilters.bathrooms);
    }
    if (smartFilters.maxPrice !== undefined) {
      filtered = filtered.filter(l => l.price <= smartFilters.maxPrice);
    }
    if (smartFilters.minPrice !== undefined) {
      filtered = filtered.filter(l => l.price >= smartFilters.minPrice);
    }
    if (smartFilters.listingType) {
      filtered = filtered.filter(l => l.listing_type === smartFilters.listingType);
    }

    // Apply listing type filter
    if (listingType === 'rental') {
      filtered = filtered.filter(l => l.listing_type === 'rental');
    } else if (listingType === 'sale') {
      filtered = filtered.filter(l => l.listing_type === 'sale');
    }

    // Apply advanced filters
    if (minPrice) {
      filtered = filtered.filter(l => l.price >= minPrice);
    }
    if (maxPrice) {
      filtered = filtered.filter(l => l.price <= maxPrice);
    }
    if (bedrooms !== 'any') {
      // For 5+ bedrooms, use >= 5, otherwise exact match
      if (bedrooms >= 5) {
        filtered = filtered.filter(l => l.bedrooms >= 5);
      } else {
        filtered = filtered.filter(l => l.bedrooms === bedrooms);
      }
    }
    if (bathrooms !== 'any') {
      // For 4+ bathrooms, use >= 4, otherwise exact match
      if (bathrooms >= 4) {
        filtered = filtered.filter(l => l.bathrooms >= 4);
      } else {
        filtered = filtered.filter(l => l.bathrooms === bathrooms);
      }
    }
    if (selectedNeighborhoods.length > 0) {
      filtered = filtered.filter(l => l.neighborhood && selectedNeighborhoods.includes(l.neighborhood));
    }

    // Sort by distance if geolocation is enabled
    if (useGeolocation && userLocation) {
      filtered = filtered
        .map(listing => {
          if (listing.latitude && listing.longitude) {
            const distance = calculateDistance(
              userLocation.lat,
              userLocation.lng,
              listing.latitude,
              listing.longitude
            );
            return { ...listing, distance };
          }
          return { ...listing, distance: Infinity };
        })
        .sort((a: any, b: any) => a.distance - b.distance);
    }

    return filtered;
  };

  const filteredListings = getFilteredListings();

  // Check if user is admin (for testing purposes)
  const isAdmin = userEmail === 'ryan@homeypocket.ai';

  // Split listings into tiers (using filtered listings)
  let homeysPicks = recommendedListings
    .map(rec => filteredListings.find(l => l.id === rec.listing_id))
    .filter(Boolean)
    .slice(0, 10) as Listing[];

  // Mock HOMEY's Picks for admin users
  if (isAdmin && homeysPicks.length === 0 && filteredListings.length > 0) {
    // Create mock picks from top listings with mock match scores
    homeysPicks = filteredListings
      .slice(0, 10)
      .map((listing, index) => ({
        ...listing,
        match_score: 98 - (index * 3), // Mock scores: 98, 95, 92, 89, etc.
      }));
  }

  const agentsPicks = filteredListings
    .filter(l => l.is_featured || l.is_new_to_market)
    .filter(l => !homeysPicks.some(h => h.id === l.id))
    .slice(0, 8);

  // Sort nearbyGems based on sortBy
  const sortListings = (listings: Listing[]) => {
    const sorted = [...listings];
    switch (sortBy) {
      case 'recent':
        return sorted.sort((a, b) => new Date(b.created_at || '').getTime() - new Date(a.created_at || '').getTime());
      case 'price-low':
        return sorted.sort((a, b) => a.price - b.price);
      case 'price-high':
        return sorted.sort((a, b) => b.price - a.price);
      case 'neighborhood':
        return sorted.sort((a, b) => (a.neighborhood || '').localeCompare(b.neighborhood || ''));
      default:
        return sorted;
    }
  };

  const nearbyGems = sortListings(
    filteredListings.filter(l => !homeysPicks.some(h => h.id === l.id) && !agentsPicks.some(a => a.id === l.id))
  );

  return (
    <main className="relative min-h-screen pb-24 bg-black">
      <CinematicBackground timeOfDay="night" />

      {/* Header with Search - Mobile Optimized */}
      <header className="fixed top-0 left-0 right-0 z-50 backdrop-blur-xl bg-black/60 border-b border-white/5 safe-area-top">
        <div className="px-3 sm:px-5 py-2 sm:py-3">
          {/* Smart Search Bar */}
          <div className="relative mb-2 sm:mb-3">
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder='Try "3 bed under $2000"...'
              className="w-full px-3 sm:px-4 py-2.5 sm:py-3 pl-10 sm:pl-11 pr-16 sm:pr-20 bg-white/10 border border-white/20 rounded-full text-white text-sm sm:text-base placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-blue-500/50 transition-all"
            />
            <span className="absolute left-3 sm:left-4 top-1/2 -translate-y-1/2 text-white/50 text-base sm:text-lg">🔍</span>

            {/* AI Badge */}
            <div className="absolute right-12 sm:right-14 top-1/2 -translate-y-1/2">
              <div className="px-1.5 sm:px-2 py-0.5 bg-gradient-to-r from-blue-500 to-cyan-500 rounded-full text-[9px] sm:text-[10px] font-bold text-white">
                AI
              </div>
            </div>

            {searchQuery && (
              <button
                onClick={() => setSearchQuery('')}
                className="absolute right-3 sm:right-4 top-1/2 -translate-y-1/2 text-white/50 hover:text-white transition-colors text-sm sm:text-base"
              >
                ✕
              </button>
            )}
          </div>

          {/* Preference-based Search Note */}
          <div className="mb-2 sm:mb-3 px-1">
            <p className="text-white/50 text-[10px] sm:text-xs flex items-center gap-1">
              <span className="text-blue-400">✨</span>
              <span>Showing results based on your preferences. Use filters below to customize.</span>
            </p>
          </div>

          {/* Filter Chips - Mobile Optimized */}
          <div className="flex gap-1.5 sm:gap-2 overflow-x-auto scrollbar-hide mb-2 sm:mb-3 pb-1">
            {/* Advanced Filters Button */}
            <button
              onClick={() => setShowAdvancedFilters(!showAdvancedFilters)}
              className={`flex-shrink-0 px-3 sm:px-4 py-1.5 sm:py-2 rounded-full text-xs sm:text-sm font-medium transition-all ${
                showAdvancedFilters || listingType !== 'all' || minPrice || maxPrice || bedrooms !== 'any' || bathrooms !== 'any' || selectedNeighborhoods.length > 0
                  ? 'bg-blue-500 text-white'
                  : 'bg-white/10 text-white active:bg-white/20'
              }`}
            >
              <span className="mr-1 sm:mr-1.5">⚙️</span>
              <span className="whitespace-nowrap">Filters</span>
            </button>

            {/* Near Me Button */}
            <button
              onClick={() => {
                if (useGeolocation) {
                  setUseGeolocation(false);
                  setUserLocation(null);
                } else {
                  requestGeolocation();
                }
              }}
              className={`flex-shrink-0 px-3 sm:px-4 py-1.5 sm:py-2 rounded-full text-xs sm:text-sm font-medium transition-all ${
                useGeolocation
                  ? 'bg-green-500 text-white shadow-lg shadow-green-500/50'
                  : geoPermissionDenied
                  ? 'bg-red-500/20 text-red-300'
                  : 'bg-white/10 text-white active:bg-white/20'
              }`}
            >
              <span className="mr-1 sm:mr-1.5">📍</span>
              <span className="whitespace-nowrap">
                {useGeolocation ? (
                  <>Near Me ✓</>
                ) : geoPermissionDenied ? (
                  <>Near Me ✗</>
                ) : (
                  <>Near Me</>
                )}
              </span>
            </button>
          </div>

          {/* Advanced Filters Panel - Mobile Optimized */}
          {showAdvancedFilters && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              exit={{ opacity: 0, height: 0 }}
              className="bg-white/5 rounded-xl sm:rounded-2xl p-3 sm:p-4 space-y-3 sm:space-y-4 border border-white/10"
            >
              {/* Listing Type */}
              <div>
                <label className="text-white/70 text-xs sm:text-sm mb-1.5 sm:mb-2 block">Listing Type</label>
                <div className="flex gap-2">
                  <button
                    onClick={() => setListingType('all')}
                    className={`flex-1 px-3 py-2 rounded-lg text-xs sm:text-sm font-medium transition-all ${
                      listingType === 'all'
                        ? 'bg-blue-500 text-white'
                        : 'bg-white/10 text-white active:bg-white/20'
                    }`}
                  >
                    All
                  </button>
                  <button
                    onClick={() => setListingType('rental')}
                    className={`flex-1 px-3 py-2 rounded-lg text-xs sm:text-sm font-medium transition-all ${
                      listingType === 'rental'
                        ? 'bg-blue-500 text-white'
                        : 'bg-white/10 text-white active:bg-white/20'
                    }`}
                  >
                    🏠 For Rent
                  </button>
                  <button
                    onClick={() => setListingType('sale')}
                    className={`flex-1 px-3 py-2 rounded-lg text-xs sm:text-sm font-medium transition-all ${
                      listingType === 'sale'
                        ? 'bg-blue-500 text-white'
                        : 'bg-white/10 text-white active:bg-white/20'
                    }`}
                  >
                    🏡 For Sale
                  </button>
                </div>
              </div>

              {/* Price Range */}
              <div>
                <label className="text-white/70 text-xs sm:text-sm mb-1.5 sm:mb-2 block">Price Range</label>
                <div className="flex gap-2 items-center">
                  <input
                    type="number"
                    value={minPrice}
                    onChange={(e) => setMinPrice(e.target.value ? parseInt(e.target.value) : '')}
                    placeholder="Min"
                    className="flex-1 min-w-0 px-2 sm:px-3 py-2 sm:py-2.5 bg-white/10 border border-white/20 rounded-lg text-white text-sm sm:text-base placeholder-white/40 focus:outline-none focus:ring-2 focus:ring-blue-500/50"
                  />
                  <span className="text-white/50 text-sm sm:text-base flex-shrink-0">—</span>
                  <input
                    type="number"
                    value={maxPrice}
                    onChange={(e) => setMaxPrice(e.target.value ? parseInt(e.target.value) : '')}
                    placeholder="Max"
                    className="flex-1 min-w-0 px-2 sm:px-3 py-2 sm:py-2.5 bg-white/10 border border-white/20 rounded-lg text-white text-sm sm:text-base placeholder-white/40 focus:outline-none focus:ring-2 focus:ring-blue-500/50"
                  />
                </div>
              </div>

              {/* Bedrooms & Bathrooms */}
              <div className="grid grid-cols-2 gap-2 sm:gap-4">
                <div>
                  <label className="text-white/70 text-xs sm:text-sm mb-1.5 sm:mb-2 block">Bedrooms</label>
                  <select
                    value={bedrooms === 'any' ? 'any' : bedrooms.toString()}
                    onChange={(e) => setBedrooms(e.target.value === 'any' ? 'any' : parseInt(e.target.value))}
                    className="w-full px-2.5 sm:px-3 py-2 sm:py-2.5 bg-white/10 border border-white/20 rounded-lg text-white text-sm sm:text-base focus:outline-none focus:ring-2 focus:ring-blue-500/50"
                  >
                    <option value="any">Any</option>
                    <option value="0">Studio</option>
                    <option value="1">1 Bedroom</option>
                    <option value="2">2 Bedrooms</option>
                    <option value="3">3 Bedrooms</option>
                    <option value="4">4 Bedrooms</option>
                    <option value="5">5+ Bedrooms</option>
                  </select>
                </div>

                <div>
                  <label className="text-white/70 text-xs sm:text-sm mb-1.5 sm:mb-2 block">Bathrooms</label>
                  <select
                    value={bathrooms === 'any' ? 'any' : bathrooms.toString()}
                    onChange={(e) => setBathrooms(e.target.value === 'any' ? 'any' : parseInt(e.target.value))}
                    className="w-full px-2.5 sm:px-3 py-2 sm:py-2.5 bg-white/10 border border-white/20 rounded-lg text-white text-sm sm:text-base focus:outline-none focus:ring-2 focus:ring-blue-500/50"
                  >
                    <option value="any">Any</option>
                    <option value="1">1 Bathroom</option>
                    <option value="2">2 Bathrooms</option>
                    <option value="3">3 Bathrooms</option>
                    <option value="4">4+ Bathrooms</option>
                  </select>
                </div>
              </div>

              {/* Neighborhoods - Organized by City/Borough */}
              <div>
                <label className="text-white/70 text-xs sm:text-sm mb-1.5 sm:mb-2 block">Neighborhoods</label>
                <div className="max-h-64 overflow-y-auto space-y-2">
                  {Object.entries(NEIGHBORHOODS_BY_CITY).map(([city, hoods]) => {
                    const isExpanded = expandedBoroughs.has(city);
                    const selectedCount = hoods.filter(h => selectedNeighborhoods.includes(h)).length;

                    return (
                      <div key={city} className="border border-white/10 rounded-lg overflow-hidden">
                        <button
                          onClick={() => {
                            const newExpanded = new Set(expandedBoroughs);
                            if (isExpanded) {
                              newExpanded.delete(city);
                            } else {
                              newExpanded.add(city);
                            }
                            setExpandedBoroughs(newExpanded);
                          }}
                          className="w-full px-3 py-2 bg-white/5 hover:bg-white/10 transition-colors flex items-center justify-between"
                        >
                          <div className="flex items-center gap-2">
                            <span className="text-white/90 font-semibold text-xs sm:text-sm">{city}</span>
                            {selectedCount > 0 && (
                              <span className="px-2 py-0.5 bg-blue-500 text-white text-[10px] rounded-full">
                                {selectedCount}
                              </span>
                            )}
                          </div>
                          <span className={`text-white/50 text-sm transition-transform ${isExpanded ? 'rotate-180' : ''}`}>
                            ▼
                          </span>
                        </button>

                        {isExpanded && (
                          <div className="p-3 flex gap-1.5 sm:gap-2 flex-wrap">
                            {hoods.map(neighborhood => (
                              <button
                                key={neighborhood}
                                onClick={() => {
                                  if (selectedNeighborhoods.includes(neighborhood)) {
                                    setSelectedNeighborhoods(selectedNeighborhoods.filter(n => n !== neighborhood));
                                  } else {
                                    setSelectedNeighborhoods([...selectedNeighborhoods, neighborhood]);
                                  }
                                }}
                                className={`px-2.5 sm:px-3 py-1 sm:py-1.5 rounded-full text-xs font-medium transition-all ${
                                  selectedNeighborhoods.includes(neighborhood)
                                    ? 'bg-blue-500 text-white'
                                    : 'bg-white/10 text-white active:bg-white/20'
                                }`}
                              >
                                {neighborhood}
                              </button>
                            ))}
                          </div>
                        )}
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Clear Filters */}
              <button
                onClick={() => {
                  setListingType('all');
                  setMinPrice('');
                  setMaxPrice('');
                  setBedrooms('any');
                  setBathrooms('any');
                  setSelectedNeighborhoods([]);
                }}
                className="w-full py-2 sm:py-2.5 bg-white/10 active:bg-white/20 rounded-lg text-white text-xs sm:text-sm font-medium transition-colors"
              >
                Clear All Filters
              </button>
            </motion.div>
          )}
        </div>
      </header>

      {/* Content */}
      <div className="relative z-10 pt-36">
        {loading ? (
          <div className="flex items-center justify-center h-[70vh]">
            <div className="animate-spin rounded-full h-12 w-12 border-4 border-white/20 border-t-white"></div>
          </div>
        ) : (
          <>
            {/* Tier 1: HOMEY's Picks - Always Show */}
            <div className="mb-10">
              <div className="px-5 mb-4">
                <h2 className="text-2xl font-bold text-white mb-1">HOMEY's Picks</h2>
                <p className="text-white/60 text-sm">Curated matches based on your preferences</p>
              </div>

              {homeysPicks.length > 0 ? (
                <div className="flex gap-4 overflow-x-auto scrollbar-hide px-5 pb-2 snap-x snap-mandatory">
                  {homeysPicks.map((listing, index) => (
                    <motion.div
                      key={listing.id}
                      initial={{ opacity: 0, x: 20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: index * 0.05 }}
                      className="flex-shrink-0 w-[85vw] snap-center"
                    >
                      <div
                        onClick={() => handleCardClick(listing)}
                        className="relative cursor-pointer group"
                      >
                        <div className="relative aspect-video rounded-2xl overflow-hidden bg-gradient-to-br from-blue-900/20 to-purple-900/20">
                          {listing.thumbnail_url ? (
                            <img
                              src={listing.thumbnail_url}
                              alt={listing.address}
                              className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                            />
                          ) : (
                            <div className="w-full h-full flex items-center justify-center text-6xl">
                              🏠
                            </div>
                          )}

                          <div className="absolute inset-0 bg-gradient-to-t from-black via-black/40 to-transparent" />

                          <div className="absolute bottom-0 left-0 right-0 p-5">
                            {listing.match_score && (
                              <div className="mb-2">
                                <span className="px-3 py-1 bg-gradient-to-r from-blue-500 to-cyan-500 rounded-full text-white text-sm font-bold">
                                  {Math.round(listing.match_score)}% Match
                                </span>
                              </div>
                            )}

                            <div className="text-3xl font-bold text-white mb-2">
                              {new Intl.NumberFormat('en-US', {
                                style: 'currency',
                                currency: 'USD',
                                maximumFractionDigits: 0,
                              }).format(listing.price)}
                              {listing.listing_type === 'rental' && (
                                <span className="text-lg text-white/80 font-normal">/mo</span>
                              )}
                            </div>

                            <div className="text-white/90 font-medium mb-1">{listing.address}</div>
                            <div className="text-white/60 text-sm mb-3">{listing.neighborhood}</div>

                            <div className="flex items-center gap-4 text-sm text-white/80">
                              <span>{listing.bedrooms === 0 ? 'Studio' : `${listing.bedrooms} bed`}</span>
                              <span>•</span>
                              <span>{listing.bathrooms} bath</span>
                              {listing.square_footage && (
                                <>
                                  <span>•</span>
                                  <span>{listing.square_footage.toLocaleString()} sqft</span>
                                </>
                              )}
                              {useGeolocation && (listing as any).distance && (listing as any).distance !== Infinity && (
                                <>
                                  <span>•</span>
                                  <span className="text-green-400">📍 {((listing as any).distance).toFixed(1)} mi</span>
                                </>
                              )}
                            </div>
                          </div>

                          <div className="absolute top-4 right-4 flex gap-2">
                            <button
                              onClick={(e) => {
                                e.stopPropagation();
                                handleSaveListing(listing.id);
                              }}
                              className="w-10 h-10 rounded-full bg-black/60 backdrop-blur-sm flex items-center justify-center hover:bg-black/80 transition-colors"
                            >
                              <span className="text-xl">{savedListings?.has(listing.id) ? '❤️' : '🤍'}</span>
                            </button>
                          </div>
                        </div>
                      </div>
                    </motion.div>
                  ))}
                </div>
              ) : (
                <div className="px-5">
                  <div className="relative rounded-2xl overflow-hidden bg-gradient-to-br from-blue-900/20 to-purple-900/20 border border-blue-500/30 p-8 text-center">
                    <div className="relative z-10">
                      <div className="text-5xl mb-4">🧠✨</div>
                      <h3 className="text-xl font-bold text-white mb-2">HOMEY is Learning About You</h3>
                      <p className="text-white/70 mb-4 max-w-md mx-auto">
                        Keep using the app! Swipe on properties in Matchmaker, save your favorites, and explore listings to help HOMEY understand your preferences.
                      </p>
                      <div className="flex gap-3 justify-center">
                        <button
                          onClick={() => router.push('/matchmaker')}
                          className="px-6 py-3 bg-gradient-to-r from-blue-500 to-cyan-500 rounded-full text-white font-bold hover:scale-105 transition-transform"
                        >
                          Start Swiping
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              )}
            </div>

            {/* Tier 2: Agent's Picks - Poster Rail */}
            {agentsPicks.length > 0 && (
              <StreamingRail
                title="Your Agent's Picks"
                subtitle="Hand-selected properties for you"
                listings={agentsPicks}
                type="poster"
                accentColor="from-amber-500 to-orange-500"
                onCardClick={handleCardClick}
                onSave={handleSaveListing}
                savedListings={savedListings}
              />
            )}

            {/* Tier 3: More Properties - Compact List with Sorting */}
            {nearbyGems.length > 0 && (
              <div className="mb-10">
                {/* Section Header with Sort Options */}
                <div className="px-5 mb-4">
                  <h2 className="text-2xl font-bold text-white mb-1">More Properties</h2>
                  <p className="text-white/60 text-sm mb-3">Explore all available listings</p>

                  {/* Sort Chips */}
                  <div className="flex gap-2 overflow-x-auto scrollbar-hide">
                    <button
                      onClick={() => setSortBy('recent')}
                      className={`flex-shrink-0 px-3 py-1.5 rounded-full text-xs font-medium transition-all ${
                        sortBy === 'recent'
                          ? 'bg-white/20 text-white border border-white/30'
                          : 'bg-white/5 text-white/60 hover:bg-white/10'
                      }`}
                    >
                      🕒 Recently Added
                    </button>
                    <button
                      onClick={() => setSortBy('price-low')}
                      className={`flex-shrink-0 px-3 py-1.5 rounded-full text-xs font-medium transition-all ${
                        sortBy === 'price-low'
                          ? 'bg-white/20 text-white border border-white/30'
                          : 'bg-white/5 text-white/60 hover:bg-white/10'
                      }`}
                    >
                      💰 Price: Low to High
                    </button>
                    <button
                      onClick={() => setSortBy('price-high')}
                      className={`flex-shrink-0 px-3 py-1.5 rounded-full text-xs font-medium transition-all ${
                        sortBy === 'price-high'
                          ? 'bg-white/20 text-white border border-white/30'
                          : 'bg-white/5 text-white/60 hover:bg-white/10'
                      }`}
                    >
                      💎 Price: High to Low
                    </button>
                    <button
                      onClick={() => setSortBy('neighborhood')}
                      className={`flex-shrink-0 px-3 py-1.5 rounded-full text-xs font-medium transition-all ${
                        sortBy === 'neighborhood'
                          ? 'bg-white/20 text-white border border-white/30'
                          : 'bg-white/5 text-white/60 hover:bg-white/10'
                      }`}
                    >
                      📍 By Neighborhood
                    </button>
                  </div>
                </div>

                {/* Compact List */}
                <div className="px-5 space-y-2">
                  {nearbyGems.map((listing, index) => (
                    <motion.div
                      key={listing.id}
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: index * 0.03 }}
                      onClick={() => handleCardClick(listing)}
                      className="flex items-center gap-3 p-3 rounded-xl bg-white/5 hover:bg-white/10 transition-colors cursor-pointer border border-white/5"
                    >
                      {/* Thumbnail */}
                      <div className="w-20 h-20 flex-shrink-0 rounded-lg overflow-hidden bg-gradient-to-br from-gray-700 to-gray-800">
                        {listing.thumbnail_url ? (
                          <img
                            src={listing.thumbnail_url}
                            alt={listing.address}
                            className="w-full h-full object-cover"
                          />
                        ) : (
                          <div className="w-full h-full flex items-center justify-center text-2xl">
                            🏠
                          </div>
                        )}
                      </div>

                      {/* Details */}
                      <div className="flex-1 min-w-0">
                        <div className="text-lg font-bold text-white mb-0.5">
                          {new Intl.NumberFormat('en-US', {
                            style: 'currency',
                            currency: 'USD',
                            maximumFractionDigits: 0,
                          }).format(listing.price)}
                          {listing.listing_type === 'rental' && (
                            <span className="text-sm text-white/70 font-normal">/mo</span>
                          )}
                        </div>
                        <div className="text-white/90 text-sm font-medium line-clamp-1 mb-1">
                          {listing.address}
                        </div>
                        <div className="flex items-center gap-3 text-xs text-white/60">
                          <span>{listing.bedrooms === 0 ? 'Studio' : `${listing.bedrooms} bed`}</span>
                          <span>•</span>
                          <span>{listing.bathrooms} bath</span>
                          {listing.square_footage && (
                            <>
                              <span>•</span>
                              <span>{listing.square_footage.toLocaleString()} sqft</span>
                            </>
                          )}
                          {useGeolocation && (listing as any).distance && (listing as any).distance !== Infinity && (
                            <>
                              <span>•</span>
                              <span className="text-green-400">📍 {((listing as any).distance).toFixed(1)} mi</span>
                            </>
                          )}
                        </div>
                      </div>

                      {/* Save Button */}
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleSaveListing(listing.id);
                        }}
                        className="w-9 h-9 flex-shrink-0 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors"
                      >
                        <span className="text-lg">{savedListings?.has(listing.id) ? '❤️' : '🤍'}</span>
                      </button>
                    </motion.div>
                  ))}
                </div>
              </div>
            )}

            {/* Empty State */}
            {allListings.length === 0 && (
              <div className="flex flex-col items-center justify-center h-[60vh] px-5 text-center">
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="max-w-md"
                >
                  <div className="text-6xl mb-6">🏠</div>
                  <h2 className="text-3xl font-bold text-white mb-3">No properties available</h2>
                  <p className="text-white/70 text-lg">
                    Check back soon for new listings
                  </p>
                </motion.div>
              </div>
            )}
          </>
        )}
      </div>

      {/* Bottom Navigation */}
      <BottomNav />

      {/* Tutorial */}
      <Tutorial
        steps={searchTutorialSteps}
        tutorialKey="search"
        onComplete={() => analytics.click('tutorial_complete', 'tutorial', { page: 'search' })}
        onSkip={() => analytics.click('tutorial_skip', 'tutorial', { page: 'search' })}
      />
    </main>
  );
}

export default function SearchPage() {
  return (
    <Suspense fallback={<div className="min-h-screen bg-black" />}>
      <SearchPageContent />
    </Suspense>
  );
}
