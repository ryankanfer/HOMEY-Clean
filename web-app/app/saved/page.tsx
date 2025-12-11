'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { db, supabase } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';
import type { Listing } from '@/lib/types';
import CinematicBackground from '@/components/CinematicBackground';
import BottomNav from '@/components/BottomNav';
import { ArrowRight, X } from 'lucide-react';

export default function SavedListingsPage() {
  const router = useRouter();
  const [savedListings, setSavedListings] = useState<Listing[]>([]);
  const [loading, setLoading] = useState(true);
  const [userId, setUserId] = useState<string | null>(null);
  const [selectedForCompare, setSelectedForCompare] = useState<Set<string>>(new Set());

  useEffect(() => {
    analytics.pageView('saved_listings');
    loadSavedListings();
  }, []);

  const loadSavedListings = async () => {
    // Get current user
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
      setLoading(false);
      return;
    }

    setUserId(user.id);

    // Load saved properties
    const { data, error } = await db.getSavedProperties(user.id);

    if (!error && data) {
      // Extract listings from saved properties
      const listings = data
        .filter((item: any) => item.listing)
        .map((item: any) => item.listing);
      setSavedListings(listings);
    }

    setLoading(false);
  };

  const handleUnsave = async (listingId: string) => {
    if (!userId) return;

    analytics.unsaveListing(listingId);

    // Remove from database
    await db.unsaveProperty(userId, listingId);

    // Remove from local state
    setSavedListings(savedListings.filter(l => l.id !== listingId));

    // Remove from compare selection if selected
    setSelectedForCompare(prev => {
      const newSet = new Set(prev);
      newSet.delete(listingId);
      return newSet;
    });
  };

  const toggleCompareSelection = (listingId: string) => {
    setSelectedForCompare(prev => {
      const newSet = new Set(prev);
      if (newSet.has(listingId)) {
        newSet.delete(listingId);
      } else if (newSet.size < 3) {
        newSet.add(listingId);
      } else {
        alert('You can only compare up to 3 properties');
      }
      return newSet;
    });
  };

  const handleCompare = () => {
    const ids = Array.from(selectedForCompare).join(',');
    router.push(`/compare?ids=${ids}`);
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      maximumFractionDigits: 0,
    }).format(price);
  };

  return (
    <main className="relative min-h-screen pb-24 bg-gradient-to-br from-slate-950 via-purple-950 to-slate-950">
      {/* Header */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-gradient-to-b from-black/90 via-black/70 to-transparent backdrop-blur-md border-b border-white/10">
        <div className="flex items-center justify-between px-5 py-4">
          <button
            onClick={() => router.back()}
            className="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center text-xl hover:bg-white/20 transition-colors text-white"
          >
            ←
          </button>
          <h1 className="text-xl font-bold text-white">Saved</h1>
          <div className="w-10 h-10"></div>
        </div>
      </header>

      {/* Content */}
      <div className="relative z-10 pt-24">
        {loading ? (
          <div className="flex items-center justify-center h-[60vh]">
            <div className="animate-spin rounded-full h-12 w-12 border-4 border-white/20 border-t-pink-500"></div>
          </div>
        ) : !userId ? (
          /* Not logged in */
          <div className="flex flex-col items-center justify-center h-[60vh] px-5 text-center">
            <div className="text-6xl mb-4">🔐</div>
            <h2 className="text-2xl font-bold text-white mb-2">Sign in to save properties</h2>
            <p className="text-white/60 mb-6">
              Create an account to save your favorite properties and access them anywhere
            </p>
            <button
              onClick={() => router.push('/')}
              className="px-6 py-3 bg-gradient-to-r from-pink-500 to-rose-500 text-white rounded-full font-semibold"
            >
              Sign In
            </button>
          </div>
        ) : savedListings.length === 0 ? (
          /* Empty state */
          <div className="flex flex-col items-center justify-center h-[60vh] px-5 text-center">
            <div className="text-6xl mb-4">❤️</div>
            <h2 className="text-2xl font-bold text-white mb-2">No saved properties yet</h2>
            <p className="text-white/60 mb-6">
              Start saving properties you love to view them here
            </p>
            <button
              onClick={() => router.push('/search')}
              className="px-6 py-3 bg-gradient-to-r from-pink-500 to-rose-500 text-white rounded-full font-semibold"
            >
              Browse Properties
            </button>
          </div>
        ) : (
          /* Saved listings grid */
          <>
            <div className="px-5 mb-4 flex items-center justify-between">
              <p className="text-white/80">{savedListings.length} saved properties</p>
              {selectedForCompare.size > 0 && (
                <button
                  onClick={() => setSelectedForCompare(new Set())}
                  className="text-sm text-white/60 hover:text-white transition-colors"
                >
                  Clear selection
                </button>
              )}
            </div>

            <div className="px-5 space-y-4">
              {savedListings.map((listing, index) => {
                const isSelected = selectedForCompare.has(listing.id);

                return (
                  <motion.div
                    key={listing.id}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ duration: 0.4, delay: index * 0.05 }}
                    className={`relative rounded-2xl overflow-hidden transition-all ${
                      isSelected
                        ? 'ring-2 ring-pink-500 bg-white/10'
                        : 'bg-white/5 hover:bg-white/10'
                    }`}
                  >
                    {/* Compare Checkbox */}
                    <button
                      onClick={() => toggleCompareSelection(listing.id)}
                      className="absolute top-3 left-3 z-10 w-8 h-8 rounded-full bg-black/50 backdrop-blur-sm border-2 border-white/30 flex items-center justify-center hover:bg-black/70 transition-colors"
                    >
                      {isSelected && <span className="text-pink-500 text-xl">✓</span>}
                    </button>

                    <div
                      className="flex cursor-pointer"
                      onClick={() => {
                        analytics.viewListing(listing.id, {
                          price: listing.price,
                          neighborhood: listing.neighborhood,
                          context: 'saved_listings',
                        });
                        router.push(`/scout/${listing.id}`);
                      }}
                    >
                      {/* Image */}
                      <div className="w-32 h-32 flex-shrink-0 relative">
                        {listing.thumbnail_url ? (
                          <img
                            src={listing.thumbnail_url}
                            alt={listing.address}
                            className="w-full h-full object-cover"
                          />
                        ) : (
                          <div className="w-full h-full bg-gradient-to-br from-pink-500/40 to-purple-600/40 flex items-center justify-center text-4xl">
                            🏠
                          </div>
                        )}
                        {listing.is_new_to_market && (
                          <div className="absolute top-2 right-2 px-2 py-0.5 bg-pink-500 rounded-full text-white text-xs font-bold">
                            NEW
                          </div>
                        )}
                      </div>

                      {/* Details */}
                      <div className="flex-1 p-4">
                        <div className="flex items-start justify-between mb-2">
                          <div>
                            <div className="text-xl font-bold text-white">
                              {formatPrice(listing.price)}
                              {listing.listing_type === 'rental' && (
                                <span className="text-sm text-white/60 font-normal">/mo</span>
                              )}
                            </div>
                            <div className="text-sm text-white/70">{listing.address}</div>
                            <div className="text-xs text-white/50">{listing.neighborhood}</div>
                          </div>
                        </div>

                        <div className="flex items-center gap-4 text-sm text-white/70">
                          <span>
                            {listing.bedrooms === 0 ? 'Studio' : `${listing.bedrooms} bed`}
                          </span>
                          <span>•</span>
                          <span>{listing.bathrooms} bath</span>
                          {listing.square_footage && (
                            <>
                              <span>•</span>
                              <span>{listing.square_footage.toLocaleString()} sqft</span>
                            </>
                          )}
                        </div>
                      </div>

                      {/* Unsave button */}
                      <div className="flex items-center pr-4">
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            handleUnsave(listing.id);
                          }}
                          className="w-10 h-10 rounded-full bg-red-500/20 hover:bg-red-500/30 flex items-center justify-center text-xl transition-colors"
                        >
                          ❤️
                        </button>
                      </div>
                    </div>
                  </motion.div>
                );
              })}
            </div>

            {/* Summary stats */}
            <div className="px-5 mt-8 grid grid-cols-2 gap-4 mb-20">
              <div className="bg-white/5 backdrop-blur-sm rounded-2xl p-4 text-center border border-white/10">
                <div className="text-2xl font-bold text-white">
                  {formatPrice(
                    savedListings.reduce((sum, l) => sum + l.price, 0) / savedListings.length
                  )}
                </div>
                <div className="text-sm text-white/60">Avg. Price</div>
              </div>
              <div className="bg-white/5 backdrop-blur-sm rounded-2xl p-4 text-center border border-white/10">
                <div className="text-2xl font-bold text-white">
                  {(savedListings.reduce((sum, l) => sum + l.bedrooms, 0) / savedListings.length).toFixed(1)}
                </div>
                <div className="text-sm text-white/60">Avg. Bedrooms</div>
              </div>
            </div>
          </>
        )}
      </div>

      {/* Compare Floating Button */}
      <AnimatePresence>
        {selectedForCompare.size >= 2 && (
          <motion.div
            initial={{ y: 100, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: 100, opacity: 0 }}
            className="fixed bottom-24 left-0 right-0 z-40 px-5"
          >
            <div className="max-w-md mx-auto bg-gradient-to-r from-pink-500 to-rose-500 rounded-full shadow-2xl">
              <button
                onClick={handleCompare}
                className="w-full flex items-center justify-between px-6 py-4 text-white"
              >
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-full bg-white/20 flex items-center justify-center font-bold">
                    {selectedForCompare.size}
                  </div>
                  <span className="font-semibold">Compare Properties</span>
                </div>
                <ArrowRight className="w-5 h-5" />
              </button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      <BottomNav />
    </main>
  );
}
