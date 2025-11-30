'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { db } from '@/lib/supabase';
import type { Listing } from '@/lib/types';
import CinematicBackground from '@/components/CinematicBackground';

export default function ScoutPage() {
  const router = useRouter();
  const [listings, setListings] = useState<Listing[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  // Filters
  const [maxPrice, setMaxPrice] = useState('');
  const [minBedrooms, setMinBedrooms] = useState('');
  const [neighborhood, setNeighborhood] = useState('');

  useEffect(() => {
    loadListings();
  }, []);

  const loadListings = async (filters?: any) => {
    setLoading(true);
    setError('');

    const { data, error: fetchError } = await db.getListings(filters);

    if (fetchError) {
      setError(fetchError.message);
      setLoading(false);
      return;
    }

    setListings(data || []);
    setLoading(false);
  };

  const handleSearch = () => {
    const filters: any = {};
    if (maxPrice) filters.maxPrice = parseFloat(maxPrice);
    if (minBedrooms) filters.minBedrooms = parseInt(minBedrooms);
    if (neighborhood) filters.neighborhood = neighborhood;

    loadListings(filters);
  };

  const handleReset = () => {
    setMaxPrice('');
    setMinBedrooms('');
    setNeighborhood('');
    loadListings();
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      maximumFractionDigits: 0,
    }).format(price);
  };

  return (
    <main className="relative min-h-screen">
      <CinematicBackground timeOfDay="day" />

      {/* Header */}
      <header className="relative z-20 py-5 px-5 flex items-center justify-between bg-gradient-to-b from-black/15 to-transparent">
        <button
          onClick={() => router.push('/dashboard')}
          className="text-white/80 hover:text-white transition-colors"
        >
          ← Back
        </button>
        <h1 className="text-2xl font-light tracking-[2px] text-white drop-shadow-lg">
          SCOUT
        </h1>
        <div className="w-16" /> {/* Spacer */}
      </header>

      {/* Main Content */}
      <div className="relative z-10 px-5 py-8 max-w-7xl mx-auto">
        {/* Search Filters */}
        <div className="glass rounded-2xl p-6 mb-8">
          <h2 className="text-xl font-semibold text-white mb-4">Search Filters</h2>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
            {/* Max Price */}
            <div>
              <label className="block text-sm font-medium text-white/80 mb-2">
                Max Price
              </label>
              <input
                type="number"
                value={maxPrice}
                onChange={(e) => setMaxPrice(e.target.value)}
                placeholder="e.g., 5000"
                className="w-full px-4 py-2 bg-white/10 border border-white/20 rounded-lg text-white placeholder:text-white/40 focus:outline-none focus:border-primary/50"
              />
            </div>

            {/* Min Bedrooms */}
            <div>
              <label className="block text-sm font-medium text-white/80 mb-2">
                Min Bedrooms
              </label>
              <select
                value={minBedrooms}
                onChange={(e) => setMinBedrooms(e.target.value)}
                className="w-full px-4 py-2 bg-white/10 border border-white/20 rounded-lg text-white focus:outline-none focus:border-primary/50"
              >
                <option value="">Any</option>
                <option value="0">Studio</option>
                <option value="1">1+</option>
                <option value="2">2+</option>
                <option value="3">3+</option>
              </select>
            </div>

            {/* Neighborhood */}
            <div>
              <label className="block text-sm font-medium text-white/80 mb-2">
                Neighborhood
              </label>
              <input
                type="text"
                value={neighborhood}
                onChange={(e) => setNeighborhood(e.target.value)}
                placeholder="e.g., Tribeca"
                className="w-full px-4 py-2 bg-white/10 border border-white/20 rounded-lg text-white placeholder:text-white/40 focus:outline-none focus:border-primary/50"
              />
            </div>
          </div>

          <div className="flex gap-3">
            <button
              onClick={handleSearch}
              className="px-6 py-2 bg-primary hover:bg-primary/90 text-white font-semibold rounded-lg transition-colors"
            >
              Search
            </button>
            <button
              onClick={handleReset}
              className="px-6 py-2 bg-white/10 hover:bg-white/20 text-white font-semibold rounded-lg transition-colors"
            >
              Reset
            </button>
          </div>
        </div>

        {/* Error State */}
        {error && (
          <div className="glass-strong rounded-xl p-4 mb-6 text-red-200 border border-red-500/50">
            Error: {error}
          </div>
        )}

        {/* Loading State */}
        {loading && (
          <div className="text-center py-12">
            <div className="inline-block animate-spin rounded-full h-12 w-12 border-4 border-white/20 border-t-primary"></div>
            <p className="mt-4 text-white/80">Loading properties...</p>
          </div>
        )}

        {/* Results */}
        {!loading && (
          <>
            <div className="mb-4 text-white/80">
              Found <span className="font-semibold text-white">{listings.length}</span> properties
            </div>

            {/* Listings Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {listings.map((listing) => (
                <div
                  key={listing.id}
                  className="glass rounded-xl overflow-hidden hover:scale-[1.02] transition-transform cursor-pointer"
                  onClick={() => router.push(`/scout/${listing.id}`)}
                >
                  {/* Image */}
                  <div className="relative h-48 bg-gradient-to-br from-primary/20 to-purple-900/20">
                    {listing.thumbnail_url && (
                      <img
                        src={listing.thumbnail_url}
                        alt={listing.address}
                        className="w-full h-full object-cover"
                      />
                    )}
                    {listing.is_new_to_market && (
                      <div className="absolute top-3 left-3 px-3 py-1 bg-primary rounded-full text-white text-xs font-semibold">
                        NEW
                      </div>
                    )}
                    {listing.is_featured && (
                      <div className="absolute top-3 right-3 px-3 py-1 bg-yellow-500 rounded-full text-white text-xs font-semibold">
                        ⭐ FEATURED
                      </div>
                    )}
                  </div>

                  {/* Content */}
                  <div className="p-5">
                    {/* Price */}
                    <div className="text-2xl font-bold text-white mb-2">
                      {formatPrice(listing.price)}
                      {listing.listing_type === 'rental' && <span className="text-lg text-white/60">/mo</span>}
                    </div>

                    {/* Address */}
                    <div className="text-white/90 font-medium mb-1">
                      {listing.address}
                    </div>
                    <div className="text-white/60 text-sm mb-3">
                      {listing.neighborhood}
                    </div>

                    {/* Details */}
                    <div className="flex items-center gap-4 text-white/80 text-sm mb-3">
                      <span>{listing.bedrooms === 0 ? 'Studio' : `${listing.bedrooms} bed${listing.bedrooms > 1 ? 's' : ''}`}</span>
                      <span>•</span>
                      <span>{listing.bathrooms} bath{listing.bathrooms > 1 ? 's' : ''}</span>
                      {listing.square_footage && (
                        <>
                          <span>•</span>
                          <span>{listing.square_footage.toLocaleString()} sqft</span>
                        </>
                      )}
                    </div>

                    {/* Amenities */}
                    {listing.amenities.length > 0 && (
                      <div className="flex flex-wrap gap-2">
                        {listing.amenities.slice(0, 3).map((amenity, idx) => (
                          <span
                            key={idx}
                            className="px-2 py-1 bg-white/10 rounded text-xs text-white/80"
                          >
                            {amenity}
                          </span>
                        ))}
                        {listing.amenities.length > 3 && (
                          <span className="px-2 py-1 bg-white/10 rounded text-xs text-white/60">
                            +{listing.amenities.length - 3} more
                          </span>
                        )}
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>

            {/* Empty State */}
            {listings.length === 0 && (
              <div className="text-center py-12">
                <div className="text-6xl mb-4">🏠</div>
                <h3 className="text-xl font-semibold text-white mb-2">No properties found</h3>
                <p className="text-white/60">Try adjusting your search filters</p>
              </div>
            )}
          </>
        )}
      </div>
    </main>
  );
}
