'use client';

export const dynamic = 'force-dynamic';

import { Suspense, useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { db, auth } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';
import type { Listing } from '@/lib/types';
import BottomNav from '@/components/BottomNav';
import { Heart, Sliders } from 'lucide-react';

function SearchPageContent() {
  const router = useRouter();

  const [homeyPicks, setHomeyPicks] = useState<Listing[]>([]);
  const [agentPicks, setAgentPicks] = useState<Listing[]>([]);
  const [nearbyGems, setNearbyGems] = useState<Listing[]>([]);
  const [loading, setLoading] = useState(true);
  const [savedListings, setSavedListings] = useState<Set<string>>(new Set());
  const [userId, setUserId] = useState<string | null>(null);

  // Near Me functionality
  const [nearMeMode, setNearMeMode] = useState(false);
  const [userLocation, setUserLocation] = useState<{ lat: number; lng: number } | null>(null);
  const [locationLoading, setLocationLoading] = useState(false);

  // Simplified filters
  const [showFilters, setShowFilters] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [filters, setFilters] = useState({
    minPrice: '',
    maxPrice: '',
    minBedrooms: '',
    minBathrooms: '',
    neighborhoods: [] as string[],
  });

  const NEIGHBORHOODS_BY_BOROUGH = {
    'Manhattan': ['Battery Park City', 'Chelsea', 'East Harlem', 'East Village', 'Financial District', 'Flatiron', 'Gramercy', 'Greenwich Village', 'Harlem', 'Hell\'s Kitchen', 'Inwood', 'Lincoln Square', 'Lower East Side', 'Midtown', 'Morningside Heights', 'Murray Hill', 'NoHo', 'Nolita', 'SoHo', 'Times Square', 'Tribeca', 'Upper East Side', 'Upper West Side', 'Washington Heights', 'West Village'].sort(),
    'Brooklyn': ['Bay Ridge', 'Bedford-Stuyvesant', 'Bensonhurst', 'Brooklyn Heights', 'Bushwick', 'Clinton Hill', 'Coney Island', 'Crown Heights', 'DUMBO', 'Fort Greene', 'Greenpoint', 'Park Slope', 'Prospect Heights', 'Sunset Park', 'Williamsburg'].sort(),
    'Queens': ['Astoria', 'Elmhurst', 'Flushing', 'Forest Hills', 'Jackson Heights', 'Jamaica', 'Long Island City', 'Rego Park', 'Ridgewood', 'Sunnyside'].sort(),
    'Bronx': ['Concourse', 'Fordham', 'Pelham Bay', 'Riverdale', 'Throggs Neck'].sort(),
    'Staten Island': ['New Brighton', 'St. George', 'Stapleton', 'Tompkinsville'].sort()
  };

  const [neighborhoodSearch, setNeighborhoodSearch] = useState('');
  const [expandedBoroughs, setExpandedBoroughs] = useState<Set<string>>(new Set());

  const getFilteredNeighborhoods = () => {
    if (!neighborhoodSearch) return NEIGHBORHOODS_BY_BOROUGH;

    const filtered: Partial<typeof NEIGHBORHOODS_BY_BOROUGH> = {};
    Object.entries(NEIGHBORHOODS_BY_BOROUGH).forEach(([borough, hoods]) => {
      const matching = hoods.filter(n =>
        n.toLowerCase().includes(neighborhoodSearch.toLowerCase())
      );
      if (matching.length > 0) {
        filtered[borough as keyof typeof NEIGHBORHOODS_BY_BOROUGH] = matching;
      }
    });
    return filtered;
  };

  const filteredNeighborhoods = getFilteredNeighborhoods();
  const hasResults = Object.keys(filteredNeighborhoods).length > 0;

  useEffect(() => {
    analytics.pageView('search');
    loadSearchData();
  }, []);

  const loadSearchData = async () => {
    setLoading(true);
    try {
      const { data: { user } } = await auth.getUser();
      if (user) {
        setUserId(user.id);

        // Load saved properties
        const { data: savedProps } = await db.getSavedProperties(user.id);
        if (savedProps) {
          const savedIds = new Set(savedProps.map((sp: any) => sp.listing_id));
          setSavedListings(savedIds);
        }

        // Load AI recommendations for HOMEY's Picks
        const { data: recommended } = await db.getRecommendedListings(user.id, 10);
        if (recommended) {
          setHomeyPicks(recommended);
        }
      }

      // Load all listings
      const { data: allListings } = await db.getListings({});
      if (allListings) {
        // Agent's Picks: Newest listings
        setAgentPicks(allListings.slice(0, 10));

        // Nearby Gems: Random selection for demo
        const shuffled = [...allListings].sort(() => Math.random() - 0.5);
        setNearbyGems(shuffled.slice(0, 15));
      }
    } catch (error) {
      console.error('Failed to load search data:', error);
    }
    setLoading(false);
  };

  const handleSaveListing = async (listingId: string) => {
    try {
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
      } else {
        await db.saveProperty(userId, listingId);
        setSavedListings(prev => new Set(prev).add(listingId));
        analytics.saveListing(listingId);
      }
    } catch (error) {
      console.error('Failed to save/unsave property:', error);
    }
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      maximumFractionDigits: 0,
    }).format(price);
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
    return R * c; // Distance in miles
  };

  // Get user's location and sort listings by proximity
  const handleNearMe = async () => {
    // Toggle off if already active
    if (nearMeMode) {
      setNearMeMode(false);
      setUserLocation(null);
      // Reload data to reset sorting
      loadSearchData();
      return;
    }

    if (!navigator.geolocation) {
      alert('Geolocation is not supported by your browser');
      return;
    }

    setLocationLoading(true);

    navigator.geolocation.getCurrentPosition(
      (position) => {
        const { latitude, longitude } = position.coords;
        setUserLocation({ lat: latitude, lng: longitude });
        setNearMeMode(true);
        setLocationLoading(false);

        // Sort all listings by distance
        const sortByDistance = (listings: Listing[]) => {
          return [...listings].sort((a, b) => {
            // Assuming listings have latitude/longitude properties
            // If not, we'll need to geocode the addresses
            const distA = a.latitude && a.longitude
              ? calculateDistance(latitude, longitude, a.latitude, a.longitude)
              : Infinity;
            const distB = b.latitude && b.longitude
              ? calculateDistance(latitude, longitude, b.latitude, b.longitude)
              : Infinity;
            return distA - distB;
          });
        };

        // Update all listings to be sorted by distance
        setHomeyPicks(prev => sortByDistance(prev));
        setAgentPicks(prev => sortByDistance(prev));
        setNearbyGems(prev => sortByDistance(prev));
      },
      (error) => {
        console.error('Error getting location:', error);
        let errorMessage = 'Unable to get your location. ';
        if (error.code === 1) {
          errorMessage += 'Please enable location permissions in your browser settings.';
        } else if (error.code === 2) {
          errorMessage += 'Location information is unavailable.';
        } else if (error.code === 3) {
          errorMessage += 'Location request timed out.';
        }
        alert(errorMessage);
        setLocationLoading(false);
      },
      {
        enableHighAccuracy: true, // Request high accuracy GPS
        timeout: 10000, // 10 second timeout
        maximumAge: 0 // Don't use cached position
      }
    );
  };

  return (
    <main className="relative min-h-screen pb-24 bg-gradient-to-br from-slate-950 via-purple-950 to-slate-950">
      {/* Header */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-gradient-to-b from-black/90 via-black/70 to-transparent backdrop-blur-md border-b border-white/10">
        <div className="px-5 py-4">
          <div className="flex items-center justify-between mb-3">
            <button
              onClick={() => router.back()}
              className="w-11 h-11 rounded-full bg-white/10 flex items-center justify-center hover:bg-white/20 transition-colors text-white text-xl"
            >
              ←
            </button>
            <h1 className="text-xl font-bold text-white">Search</h1>
            <button
              onClick={() => setShowFilters(!showFilters)}
              className="w-11 h-11 rounded-full bg-white/10 flex items-center justify-center hover:bg-white/20 transition-colors text-white"
            >
              <Sliders className="w-5 h-5" />
            </button>
          </div>

          {/* AI Search Bar */}
          <div className="space-y-3">
            <div className="relative">
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Ask me anything... 'loft with natural light in SoHo'"
                className="w-full px-4 py-3 bg-white/10 backdrop-blur-sm border border-white/20 rounded-2xl text-white placeholder-white/50 focus:outline-none focus:ring-2 focus:ring-pink-500 focus:bg-white/15"
              />
              <div className="absolute right-3 top-1/2 -translate-y-1/2 px-2 py-1 bg-gradient-to-r from-pink-500 to-rose-500 rounded-full">
                <span className="text-white text-xs font-medium">AI</span>
              </div>
            </div>

            {/* Near Me Button */}
            <button
              onClick={handleNearMe}
              disabled={locationLoading}
              className={`w-full px-4 py-2.5 rounded-xl font-medium transition-all ${
                nearMeMode
                  ? 'bg-gradient-to-r from-blue-500 to-cyan-500 text-white'
                  : 'bg-white/10 text-white/70 hover:bg-white/15'
              }`}
            >
              {locationLoading ? (
                <span className="flex items-center justify-center gap-2">
                  <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                  Getting location...
                </span>
              ) : nearMeMode ? (
                'Near Me Active'
              ) : (
                'Show homes near me'
              )}
            </button>
          </div>
        </div>

        {/* Advanced Filters Panel */}
        <AnimatePresence>
          {showFilters && (
            <motion.div
              initial={{ height: 0, opacity: 0 }}
              animate={{ height: 'auto', opacity: 1 }}
              exit={{ height: 0, opacity: 0 }}
              className="overflow-hidden bg-black/60 backdrop-blur-md border-t border-white/10"
            >
              <div className="px-5 py-6 space-y-4">
                <h3 className="text-white font-bold text-lg">Advanced Filters</h3>

                {/* Price Range */}
                <div>
                  <label className="block text-white font-medium mb-2">Price Range</label>
                  <div className="grid grid-cols-2 gap-3">
                    <input
                      type="number"
                      placeholder="Min"
                      value={filters.minPrice}
                      onChange={(e) => setFilters({ ...filters, minPrice: e.target.value })}
                      className="px-4 py-2 bg-white/10 rounded-lg text-white placeholder-white/40 focus:outline-none focus:ring-2 focus:ring-pink-500"
                    />
                    <input
                      type="number"
                      placeholder="Max"
                      value={filters.maxPrice}
                      onChange={(e) => setFilters({ ...filters, maxPrice: e.target.value })}
                      className="px-4 py-2 bg-white/10 rounded-lg text-white placeholder-white/40 focus:outline-none focus:ring-2 focus:ring-pink-500"
                    />
                  </div>
                </div>

                {/* Beds & Baths */}
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-white font-medium mb-2">Min Beds</label>
                    <select
                      value={filters.minBedrooms}
                      onChange={(e) => setFilters({ ...filters, minBedrooms: e.target.value })}
                      className="w-full px-4 py-2 bg-white/10 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-pink-500"
                    >
                      <option value="">Any</option>
                      <option value="0">Studio</option>
                      <option value="1">1+</option>
                      <option value="2">2+</option>
                      <option value="3">3+</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-white font-medium mb-2">Min Baths</label>
                    <select
                      value={filters.minBathrooms}
                      onChange={(e) => setFilters({ ...filters, minBathrooms: e.target.value })}
                      className="w-full px-4 py-2 bg-white/10 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-pink-500"
                    >
                      <option value="">Any</option>
                      <option value="1">1+</option>
                      <option value="2">2+</option>
                      <option value="3">3+</option>
                    </select>
                  </div>
                </div>

                {/* Neighborhoods by Borough (Collapsed by Default) */}
                <details className="group">
                  <summary className="cursor-pointer text-white font-medium py-2 flex items-center justify-between">
                    Neighborhoods
                    <span className="text-white/60 group-open:rotate-180 transition-transform">▼</span>
                  </summary>
                  <div className="mt-3">
                    {/* Search within neighborhoods */}
                    <input
                      type="text"
                      value={neighborhoodSearch}
                      onChange={(e) => setNeighborhoodSearch(e.target.value)}
                      placeholder="Search neighborhoods..."
                      className="w-full px-3 py-2 mb-3 bg-white/10 rounded-lg text-white placeholder-white/40 text-sm focus:outline-none focus:ring-2 focus:ring-pink-500"
                    />

                    <div className="space-y-3 max-h-64 overflow-y-auto">
                      {hasResults ? (
                        Object.entries(filteredNeighborhoods).map(([borough, hoods]) => (
                          <div key={borough}>
                            <button
                              onClick={() => {
                                const newExpanded = new Set(expandedBoroughs);
                                if (newExpanded.has(borough)) {
                                  newExpanded.delete(borough);
                                } else {
                                  newExpanded.add(borough);
                                }
                                setExpandedBoroughs(newExpanded);
                              }}
                              className="w-full flex items-center justify-between text-white/90 font-medium text-sm py-1.5 hover:text-white"
                            >
                              {borough}
                              <span className={`text-xs transition-transform ${expandedBoroughs.has(borough) ? 'rotate-180' : ''}`}>▼</span>
                            </button>
                            {expandedBoroughs.has(borough) && (
                              <div className="mt-2 ml-2 space-y-1.5">
                                {hoods.map(n => (
                                  <label key={n} className="flex items-center gap-2 text-white/70 hover:text-white cursor-pointer text-sm">
                                    <input
                                      type="checkbox"
                                      checked={filters.neighborhoods.includes(n)}
                                      onChange={(e) => {
                                        if (e.target.checked) {
                                          setFilters({ ...filters, neighborhoods: [...filters.neighborhoods, n] });
                                        } else {
                                          setFilters({ ...filters, neighborhoods: filters.neighborhoods.filter(x => x !== n) });
                                        }
                                      }}
                                      className="w-3.5 h-3.5 rounded"
                                    />
                                    {n}
                                  </label>
                                ))}
                              </div>
                            )}
                          </div>
                        ))
                      ) : (
                        <div className="text-center py-4">
                          <p className="text-white/60 text-sm mb-1">No neighborhoods found</p>
                          <p className="text-white/40 text-xs">"{neighborhoodSearch}" doesn't exist in our database</p>
                        </div>
                      )}
                    </div>
                  </div>
                </details>

                <button
                  onClick={() => setShowFilters(false)}
                  className="w-full px-4 py-3 bg-gradient-to-r from-pink-500 to-rose-500 text-white rounded-full font-semibold hover:shadow-lg transition-all"
                >
                  Apply Filters
                </button>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </header>

      {/* Content Rails */}
      <div className="pt-[200px] space-y-10">
        {/* Tier 1: Cinematic Rail - HOMEY's Picks */}
        <section>
          <div className="px-5 mb-4">
            <h2 className="text-2xl font-bold text-white flex items-center gap-2">
              HOMEY's Picks
            </h2>
            <p className="text-white/60 text-sm mt-1">AI-curated matches for you</p>
          </div>

          <div className="overflow-x-auto scrollbar-hide">
            <div className="flex gap-4 px-5 pb-4">
              {loading ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <div key={i} className="flex-shrink-0 w-80 aspect-video bg-white/10 rounded-2xl animate-pulse" />
                ))
              ) : homeyPicks.length > 0 ? (
                homeyPicks.map((listing, idx) => (
                  <motion.div
                    key={listing.id}
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: idx * 0.1 }}
                    className="flex-shrink-0 w-80"
                  >
                    <div
                      onClick={() => router.push(`/scout/${listing.id}`)}
                      className="relative aspect-video rounded-2xl overflow-hidden cursor-pointer group"
                    >
                      <img
                        src={listing.image_urls?.[0] || '/placeholder-property.jpg'}
                        alt={listing.address}
                        className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-300"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/30 to-transparent" />

                      {/* Match Score */}
                      {(listing as any).match_score && (
                        <div className="absolute top-3 left-3 px-3 py-1 bg-blue-500/90 backdrop-blur-sm rounded-full text-white font-bold text-sm">
                          {(listing as any).match_score}% Match
                        </div>
                      )}

                      {/* Save Button */}
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleSaveListing(listing.id);
                        }}
                        className="absolute top-3 right-3 w-9 h-9 rounded-full bg-black/50 backdrop-blur-sm flex items-center justify-center hover:bg-black/70 transition-colors"
                      >
                        <Heart className={`w-5 h-5 ${savedListings.has(listing.id) ? 'fill-pink-500 text-pink-500' : 'text-white'}`} />
                      </button>

                      {/* Info */}
                      <div className="absolute bottom-0 left-0 right-0 p-4">
                        <h3 className="text-white font-bold text-lg mb-1">{formatPrice(listing.price)}/mo</h3>
                        <p className="text-white/90 text-sm mb-1">{listing.bedrooms} bed • {listing.bathrooms} bath</p>
                        <p className="text-white/70 text-xs">{listing.neighborhood}</p>
                      </div>
                    </div>
                  </motion.div>
                ))
              ) : (
                <div className="text-white/60 px-5">No picks available yet</div>
              )}
            </div>
          </div>
        </section>

        {/* Tier 2: Poster Rail - Agent's Picks */}
        <section>
          <div className="px-5 mb-4">
            <h2 className="text-2xl font-bold text-white flex items-center gap-2">
              Agent's Picks
            </h2>
            <p className="text-white/60 text-sm mt-1">Newest premium listings</p>
          </div>

          <div className="overflow-x-auto scrollbar-hide">
            <div className="flex gap-4 px-5 pb-4">
              {loading ? (
                Array.from({ length: 5 }).map((_, i) => (
                  <div key={i} className="flex-shrink-0 w-56 aspect-[3/4] bg-white/10 rounded-2xl animate-pulse" />
                ))
              ) : agentPicks.length > 0 ? (
                agentPicks.map((listing, idx) => (
                  <motion.div
                    key={listing.id}
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: idx * 0.1 }}
                    className="flex-shrink-0 w-56"
                  >
                    <div
                      onClick={() => router.push(`/scout/${listing.id}`)}
                      className="relative aspect-[3/4] rounded-2xl overflow-hidden cursor-pointer group"
                    >
                      <img
                        src={listing.image_urls?.[0] || '/placeholder-property.jpg'}
                        alt={listing.address}
                        className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-300"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent" />

                      {/* Save Button */}
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleSaveListing(listing.id);
                        }}
                        className="absolute top-3 right-3 w-9 h-9 rounded-full bg-black/50 backdrop-blur-sm flex items-center justify-center hover:bg-black/70 transition-colors"
                      >
                        <Heart className={`w-5 h-5 ${savedListings.has(listing.id) ? 'fill-pink-500 text-pink-500' : 'text-white'}`} />
                      </button>

                      {/* Badge */}
                      <div className="absolute top-3 left-3 px-2 py-1 bg-amber-500/90 backdrop-blur-sm rounded-full text-white font-bold text-xs">
                        NEW
                      </div>

                      {/* Info */}
                      <div className="absolute bottom-0 left-0 right-0 p-3">
                        <h3 className="text-white font-bold text-base mb-1">{formatPrice(listing.price)}/mo</h3>
                        <p className="text-white/90 text-xs mb-1">{listing.bedrooms} bed • {listing.bathrooms} bath</p>
                        <p className="text-white/70 text-xs truncate">{listing.neighborhood}</p>
                      </div>
                    </div>
                  </motion.div>
                ))
              ) : (
                <div className="text-white/60 px-5">No picks available yet</div>
              )}
            </div>
          </div>
        </section>

        {/* Tier 3: List - Nearby Gems */}
        <section>
          <div className="px-5 mb-4">
            <h2 className="text-2xl font-bold text-white flex items-center gap-2">
              Nearby Gems
            </h2>
            <p className="text-white/60 text-sm mt-1">Affordable finds in your area</p>
          </div>

          <div className="px-5 space-y-3">
            {loading ? (
              Array.from({ length: 5 }).map((_, i) => (
                <div key={i} className="h-20 bg-white/10 rounded-xl animate-pulse" />
              ))
            ) : nearbyGems.length > 0 ? (
              nearbyGems.map((listing, idx) => (
                <motion.div
                  key={listing.id}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: idx * 0.05 }}
                  onClick={() => router.push(`/scout/${listing.id}`)}
                  className="flex items-center gap-3 bg-white/5 hover:bg-white/10 rounded-xl p-3 cursor-pointer transition-colors border border-white/10"
                >
                  <img
                    src={listing.image_urls?.[0] || '/placeholder-property.jpg'}
                    alt={listing.address}
                    className="w-16 h-16 rounded-lg object-cover flex-shrink-0"
                  />
                  <div className="flex-1 min-w-0">
                    <h3 className="text-white font-semibold text-sm">{formatPrice(listing.price)}/mo</h3>
                    <p className="text-white/70 text-xs">{listing.bedrooms} bed • {listing.bathrooms} bath</p>
                    <p className="text-white/50 text-xs truncate">{listing.neighborhood}</p>
                  </div>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      handleSaveListing(listing.id);
                    }}
                    className="flex-shrink-0"
                  >
                    <Heart className={`w-5 h-5 ${savedListings.has(listing.id) ? 'fill-pink-500 text-pink-500' : 'text-white/40'}`} />
                  </button>
                </motion.div>
              ))
            ) : (
              <div className="text-white/60 text-center py-8">No nearby gems found</div>
            )}
          </div>
        </section>
      </div>

      <BottomNav />
    </main>
  );
}

export default function SearchPage() {
  return (
    <Suspense fallback={
      <main className="min-h-screen pb-24 bg-gradient-to-br from-slate-950 via-purple-950 to-slate-950">
        <div className="pt-24 px-5">
          <div className="h-10 bg-white/10 rounded-xl animate-pulse mb-8" />
          <div className="space-y-8">
            {[1, 2, 3].map((i) => (
              <div key={i} className="h-48 bg-white/10 rounded-xl animate-pulse" />
            ))}
          </div>
        </div>
      </main>
    }>
      <SearchPageContent />
    </Suspense>
  );
}
