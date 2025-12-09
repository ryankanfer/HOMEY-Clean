'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { db, supabase } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';
import type { Listing } from '@/lib/types';
import CinematicBackground from '@/components/CinematicBackground';
import StreamingRail from '@/components/StreamingRail';
import CompactListRail from '@/components/CompactListRail';
import BottomNav from '@/components/BottomNav';
import Tutorial from '@/components/Tutorial';
import { savedTutorialSteps } from '@/lib/tutorialSteps';

export default function SavedPage() {
  const router = useRouter();
  const [savedListings, setSavedListings] = useState<Listing[]>([]);
  const [filteredListings, setFilteredListings] = useState<Listing[]>([]);
  const [loading, setLoading] = useState(true);
  const [userId, setUserId] = useState<string | null>(null);
  const [activeFilter, setActiveFilter] = useState<string>('all');
  const [selectedForCompare, setSelectedForCompare] = useState<Set<string>>(new Set());

  const filters = [
    { id: 'all', label: 'All', icon: '✨' },
    { id: 'price-drops', label: 'Price Drops', icon: '📉' },
    { id: 'open-houses', label: 'Open Houses', icon: '🚪' },
    { id: 'new', label: 'New Listings', icon: '🆕' },
    { id: 'high-match', label: 'Best Matches', icon: '🎯' },
  ];

  useEffect(() => {
    analytics.pageView('saved_listings');
    loadSavedListings();
  }, []);

  useEffect(() => {
    applyFilter(activeFilter);
  }, [savedListings, activeFilter]);

  const loadSavedListings = async () => {
    const { data: { user } } = await supabase.auth.getUser();

    if (!user) {
      setLoading(false);
      return;
    }

    setUserId(user.id);

    const { data, error } = await db.getSavedProperties(user.id);

    if (!error && data) {
      const listings = data
        .filter((item: any) => item.listing)
        .map((item: any) => item.listing);
      setSavedListings(listings);
    }

    setLoading(false);
  };

  const applyFilter = (filterId: string) => {
    let filtered = [...savedListings];

    switch (filterId) {
      case 'price-drops':
        filtered = filtered.filter(l => l.price_reduced);
        break;
      case 'open-houses':
        filtered = filtered.filter(l => l.has_open_house);
        break;
      case 'new':
        filtered = filtered.filter(l => l.is_new_to_market);
        break;
      case 'high-match':
        filtered = filtered
          .filter(l => l.match_score && l.match_score > 80)
          .sort((a, b) => (b.match_score || 0) - (a.match_score || 0));
        break;
      default:
        // All - no filter
        break;
    }

    setFilteredListings(filtered);
  };

  const handleUnsave = async (listingId: string) => {
    if (!userId) return;

    analytics.unsaveListing(listingId);
    await db.unsaveProperty(userId, listingId);
    setSavedListings(savedListings.filter(l => l.id !== listingId));
    setSelectedForCompare(prev => {
      const newSet = new Set(prev);
      newSet.delete(listingId);
      return newSet;
    });
  };

  const handleCardClick = (listing: Listing) => {
    analytics.viewListing(listing.id, {
      price: listing.price,
      neighborhood: listing.neighborhood,
      context: 'saved_listings',
    });
    router.push(`/scout/${listing.id}`);
  };

  const toggleCompare = (listingId: string) => {
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
    if (selectedForCompare.size < 2) {
      alert('Select at least 2 properties to compare');
      return;
    }
    const ids = Array.from(selectedForCompare).join(',');
    router.push(`/compare?ids=${ids}`);
  };

  // Split into tiers for display
  const highMatches = filteredListings.filter(l => l.match_score && l.match_score > 80).slice(0, 5);
  const recentlySaved = filteredListings.slice(0, 8);
  const allOthers = filteredListings.slice(8);

  return (
    <main className="relative min-h-screen pb-24 bg-black">
      <CinematicBackground timeOfDay="night" />

      {/* Header */}
      <header className="fixed top-0 left-0 right-0 z-50 backdrop-blur-xl bg-black/60 border-b border-white/5">
        <div className="px-5 py-3">
          <div className="flex items-center justify-between">
            <h1 className="text-xl font-bold text-white">Saved</h1>
            {selectedForCompare.size > 0 && (
              <motion.div
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                className="px-3 py-1.5 bg-white/10 rounded-full text-white text-sm font-medium"
              >
                {selectedForCompare.size} selected
              </motion.div>
            )}
          </div>
        </div>

        {/* Filter Chips */}
        <div className="flex gap-2 overflow-x-auto scrollbar-hide px-5 pb-3">
          {filters.map(filter => (
            <button
              key={filter.id}
              onClick={() => setActiveFilter(filter.id)}
              className={`flex-shrink-0 px-4 py-2 rounded-full text-sm font-medium transition-all ${
                activeFilter === filter.id
                  ? 'bg-white text-black'
                  : 'bg-white/10 text-white hover:bg-white/20'
              }`}
            >
              <span className="mr-1.5">{filter.icon}</span>
              {filter.label}
            </button>
          ))}
        </div>
      </header>

      {/* Content */}
      <div className="relative z-10 pt-32">
        {loading ? (
          <div className="flex items-center justify-center h-[70vh]">
            <div className="animate-spin rounded-full h-12 w-12 border-4 border-white/20 border-t-white"></div>
          </div>
        ) : !userId ? (
          /* Not logged in */
          <div className="flex flex-col items-center justify-center h-[70vh] px-5 text-center">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="max-w-md"
            >
              <div className="text-6xl mb-6">💙</div>
              <h2 className="text-3xl font-bold text-white mb-3">Save your favorites</h2>
              <p className="text-white/70 mb-8 text-lg">
                Sign in to save properties and access them from anywhere
              </p>
              <button
                onClick={() => router.push('/')}
                className="px-8 py-4 bg-white text-black rounded-full font-bold text-lg hover:scale-105 transition-transform"
              >
                Sign In
              </button>
            </motion.div>
          </div>
        ) : savedListings.length === 0 ? (
          /* Empty state */
          <div className="flex flex-col items-center justify-center h-[70vh] px-5 text-center">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="max-w-md"
            >
              <div className="text-6xl mb-6">💙</div>
              <h2 className="text-3xl font-bold text-white mb-3">No saved properties yet</h2>
              <p className="text-white/70 mb-8 text-lg">
                Start saving properties you love to build your collection
              </p>
              <button
                onClick={() => router.push('/search')}
                className="px-8 py-4 bg-white text-black rounded-full font-bold text-lg hover:scale-105 transition-transform"
              >
                Browse Properties
              </button>
            </motion.div>
          </div>
        ) : filteredListings.length === 0 ? (
          /* No results for filter */
          <div className="flex flex-col items-center justify-center h-[50vh] px-5 text-center">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="max-w-md"
            >
              <div className="text-5xl mb-4">🔍</div>
              <h2 className="text-2xl font-bold text-white mb-3">No properties match this filter</h2>
              <p className="text-white/70 text-lg">
                Try selecting a different filter
              </p>
            </motion.div>
          </div>
        ) : (
          /* Saved listings in rails */
          <>
            {/* High Matches Rail */}
            {activeFilter === 'all' && highMatches.length > 0 && (
              <StreamingRail
                title="Best Matches"
                subtitle="Your top AI-matched saved properties"
                listings={highMatches}
                type="cinematic"
                accentColor="from-blue-500 to-cyan-500"
                onCardClick={handleCardClick}
                onSave={handleUnsave}
                savedListings={new Set(savedListings.map(l => l.id))}
                onCompare={toggleCompare}
                selectedForCompare={selectedForCompare}
              />
            )}

            {/* Recently Saved Rail */}
            {activeFilter === 'all' && recentlySaved.length > 0 && (
              <StreamingRail
                title="Recently Saved"
                subtitle="Your latest saved properties"
                listings={recentlySaved}
                type="poster"
                accentColor="from-purple-500 to-pink-500"
                onCardClick={handleCardClick}
                onSave={handleUnsave}
                savedListings={new Set(savedListings.map(l => l.id))}
                onCompare={toggleCompare}
                selectedForCompare={selectedForCompare}
              />
            )}

            {/* All Others / Filtered Results */}
            {(activeFilter !== 'all' || allOthers.length > 0) && (
              <CompactListRail
                title={activeFilter === 'all' ? 'All Saved Properties' : filters.find(f => f.id === activeFilter)?.label || 'Filtered Results'}
                subtitle={activeFilter === 'all' ? `${allOthers.length} properties` : `${filteredListings.length} properties`}
                listings={activeFilter === 'all' ? allOthers : filteredListings}
                onCardClick={handleCardClick}
                onSave={handleUnsave}
                savedListings={new Set(savedListings.map(l => l.id))}
                onCompare={toggleCompare}
                selectedForCompare={selectedForCompare}
              />
            )}
          </>
        )}
      </div>

      {/* Floating Compare Button */}
      <AnimatePresence>
        {selectedForCompare.size >= 2 && (
          <motion.div
            initial={{ y: 100, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: 100, opacity: 0 }}
            transition={{ type: 'spring', damping: 20 }}
            className="fixed bottom-24 left-0 right-0 z-50 px-5"
          >
            <button
              onClick={handleCompare}
              className="w-full py-4 rounded-2xl font-bold text-lg text-white backdrop-blur-xl shadow-2xl"
              style={{
                background: 'linear-gradient(135deg, rgba(168, 218, 220, 0.4) 0%, rgba(180, 167, 214, 0.4) 100%)',
                border: '1.5px solid rgba(255, 255, 255, 0.3)',
                boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37), 0 0 30px rgba(168, 218, 220, 0.5)',
              }}
            >
              Compare {selectedForCompare.size} Properties →
            </button>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Bottom Navigation */}
      <BottomNav />

      {/* Tutorial */}
      <Tutorial
        steps={savedTutorialSteps}
        tutorialKey="saved"
        onComplete={() => analytics.click('tutorial_complete', 'tutorial', { page: 'saved' })}
        onSkip={() => analytics.click('tutorial_skip', 'tutorial', { page: 'saved' })}
      />
    </main>
  );
}
