'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { motion } from 'framer-motion';
import { db, auth } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';
import type { Listing } from '@/lib/types';
import CinematicBackground from '@/components/CinematicBackground';
import PropertyImage from '@/components/PropertyImage';
import MatchScore from '@/components/MatchScore';
import PropertyCard from '@/components/PropertyCard';
import BottomNav from '@/components/BottomNav';
import ShareProperty from '@/components/ShareProperty';
import VirtualWalkthrough from '@/components/VirtualWalkthrough';
import NeighborhoodDeepDive from '@/components/NeighborhoodDeepDive';
import SaveToVault from '@/components/SaveToVault';
import TourScheduler from '@/components/TourScheduler';
import CommuteCalculator from '@/components/CommuteCalculator';
import PriceAlerts from '@/components/PriceAlerts';
import PropertyChat from '@/components/PropertyChat';

export default function PropertyDetailPage() {
  const router = useRouter();
  const params = useParams();
  const listingId = params.id as string;

  const [listing, setListing] = useState<Listing | null>(null);
  const [loading, setLoading] = useState(true);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [matchScore, setMatchScore] = useState<number | null>(null);
  const [matchReasons, setMatchReasons] = useState<string[]>([]);
  const [userId, setUserId] = useState<string | null>(null);
  const [similarProperties, setSimilarProperties] = useState<any[]>([]);
  const [styleCompatibility, setStyleCompatibility] = useState<number | null>(null);
  const [hasStyleData, setHasStyleData] = useState(false);
  const [scoutInsights, setScoutInsights] = useState<string[]>([]);
  const [priceInsight, setPriceInsight] = useState<string>('');
  const [neighborhoodScore, setNeighborhoodScore] = useState<number | null>(null);
  const [showShare, setShowShare] = useState(false);
  const [showWalkthrough, setShowWalkthrough] = useState(false);
  const [showNeighborhood, setShowNeighborhood] = useState(false);
  const [showSaveToVault, setShowSaveToVault] = useState(false);
  const [showTourScheduler, setShowTourScheduler] = useState(false);
  const [showCommuteCalculator, setShowCommuteCalculator] = useState(false);
  const [showPriceAlerts, setShowPriceAlerts] = useState(false);
  const [showPropertyChat, setShowPropertyChat] = useState(false);

  useEffect(() => {
    loadListing();
  }, [listingId]);

  const loadListing = async () => {
    const { data, error } = await db.getListing(listingId);

    if (!error && data) {
      setListing(data);
      analytics.pageView('property_detail');

      // Load match score if user is logged in
      await loadMatchData();
    } else {
      console.error('Failed to load listing:', error);
    }

    setLoading(false);
  };

  const loadMatchData = async () => {
    try {
      const { data: { user } } = await auth.getUser();

      if (!user) return;

      setUserId(user.id);

      // Get match score for this property
      const { data: score } = await db.calculateMatchScore(user.id, listingId);

      if (score !== null && score !== undefined) {
        setMatchScore(score);

        // Get recommended listings to find match reasons for this property
        const { data: recommended } = await db.getRecommendedListings(user.id, 50);

        if (recommended) {
          const matchingListing = recommended.find((r: any) => r.id === listingId);
          if (matchingListing && matchingListing.match_reasons) {
            setMatchReasons(matchingListing.match_reasons);
          }

          // Get similar properties (exclude current listing, take top 6)
          const similar = recommended
            .filter((r: any) => r.id !== listingId)
            .slice(0, 6);
          setSimilarProperties(similar);
        }
      }

      // Check for style compatibility from Style Studio
      const { data: designStats } = await db.getDesignSwipeStats(user.id);
      if (designStats && designStats.total > 0) {
        setHasStyleData(true);
        // Simple compatibility: if they have design data, show a score based on property type
        // In a real app, this would analyze property images against preferred styles
        const baseScore = score || 70;
        const styleBonus = Math.min(20, designStats.total / 5); // Up to 20 points bonus
        const compatibility = Math.min(100, baseScore + styleBonus);
        setStyleCompatibility(Math.round(compatibility));
      }

      // Generate Scout's AI insights
      await generateScoutInsights(user.id);
    } catch (err) {
      console.error('Failed to load match data:', err);
    }
  };

  const generateScoutInsights = async (uid: string) => {
    if (!listing) return;

    const insights: string[] = [];

    try {
      // Get user preferences
      const { data: profile } = await db.getProfile(uid);
      const prefs = profile?.teach_homey_preferences;

      // Price insight
      if (prefs?.maxPrice) {
        const percentOfBudget = (listing.price / prefs.maxPrice) * 100;
        if (percentOfBudget <= 80) {
          insights.push(`Great value! This is ${Math.round(100 - percentOfBudget)}% below your budget.`);
          setPriceInsight('Below Budget');
        } else if (percentOfBudget <= 100) {
          insights.push(`Well-priced within your ${formatPrice(prefs.maxPrice)} budget.`);
          setPriceInsight('Within Budget');
        } else {
          insights.push(`Above your stated budget by ${formatPrice(listing.price - prefs.maxPrice)}.`);
          setPriceInsight('Above Budget');
        }
      }

      // Bedroom match
      if (prefs?.bedrooms && prefs.bedrooms.includes(listing.bedrooms)) {
        insights.push(`Perfect ${listing.bedrooms}-bedroom layout matches your preferences!`);
      }

      // Neighborhood match
      if (prefs?.neighborhoods && prefs.neighborhoods.includes(listing.neighborhood)) {
        insights.push(`You'll love ${listing.neighborhood} - it's one of your preferred neighborhoods!`);
        setNeighborhoodScore(95);
      } else {
        setNeighborhoodScore(75);
      }

      // Features match
      if (prefs?.mustHaveFeatures && listing.features) {
        const hasFeatures = prefs.mustHaveFeatures.filter((f: string) =>
          listing.features?.toLowerCase().includes(f.toLowerCase())
        );
        if (hasFeatures.length > 0) {
          insights.push(`Includes ${hasFeatures.length} must-have features: ${hasFeatures.join(', ')}`);
        }
      }

      // Style compatibility
      if (hasStyleData && styleCompatibility && styleCompatibility > 80) {
        insights.push(`The interior style aligns ${styleCompatibility}% with your design preferences!`);
      }

      // General market insight
      const avgPricePerBed = listing.price / (listing.bedrooms || 1);
      if (avgPricePerBed < 1500) {
        insights.push('Excellent price per bedroom for this area.');
      }

      setScoutInsights(insights);
    } catch (err) {
      console.error('Failed to generate insights:', err);
    }
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      maximumFractionDigits: 0,
    }).format(price);
  };

  if (loading) {
    return (
      <main className="relative min-h-screen flex items-center justify-center">
        <CinematicBackground timeOfDay="day" />
        <div className="animate-spin rounded-full h-12 w-12 border-4 border-white/20 border-t-primary"></div>
      </main>
    );
  }

  if (!listing) {
    return (
      <main className="relative min-h-screen flex items-center justify-center">
        <CinematicBackground timeOfDay="day" />
        <div className="text-center text-white">
          <h1 className="text-2xl font-bold mb-4">Property Not Found</h1>
          <button
            onClick={() => router.push('/home')}
            className="px-6 py-3 bg-primary text-white rounded-full font-bold"
          >
            Back to Home
          </button>
        </div>
      </main>
    );
  }

  const images = listing.image_urls || [];
  const allImages = images.length > 0 ? images : (listing.thumbnail_url ? [listing.thumbnail_url] : []);
  const currentImage = images[currentImageIndex] || listing.thumbnail_url;

  return (
    <main className="relative min-h-screen pb-24">
      <CinematicBackground timeOfDay="day" />

      {/* Header */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-gradient-to-b from-black/60 via-black/40 to-transparent backdrop-blur-sm">
        <div className="flex items-center justify-between px-5 py-4">
          <button
            onClick={() => router.back()}
            className="w-11 h-11 rounded-full bg-white/10 flex items-center justify-center text-xl hover:bg-white/20 transition-colors"
          >
            ←
          </button>
          <h1 className="text-lg font-bold text-white">Property Details</h1>
          <div className="flex gap-2">
            <button
              onClick={() => setShowShare(true)}
              className="w-11 h-11 rounded-full bg-white/10 flex items-center justify-center text-xl hover:bg-white/20 transition-colors"
              title="Share property"
            >
              ↗️
            </button>
            <button
              onClick={() => {
                analytics.saveListing(listing.id);
                alert('Saved to your favorites!');
              }}
              className="w-11 h-11 rounded-full bg-white/10 flex items-center justify-center text-xl hover:bg-white/20 transition-colors"
            >
              ❤️
            </button>
          </div>
        </div>
      </header>

      {/* Content */}
      <div className="relative z-10 pt-20">
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.6 }}
        >
          {/* Image Gallery */}
          <div className="relative h-[400px] md:h-[500px] mb-6">
            <PropertyImage
              src={currentImage}
              alt={listing.address}
              neighborhood={listing.neighborhood}
              propertyType={listing.property_type}
              className="w-full h-full"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent pointer-events-none" />

            {/* Virtual Walkthrough Button */}
            {allImages.length > 0 && (
              <button
                onClick={() => setShowWalkthrough(true)}
                className="absolute bottom-4 right-4 px-4 py-2 bg-black/60 hover:bg-black/80 backdrop-blur-md rounded-full text-white font-semibold transition-colors flex items-center gap-2 min-h-[44px]"
              >
                <span className="text-xl">📸</span>
                View All {allImages.length} {allImages.length === 1 ? 'Photo' : 'Photos'}
              </button>
            )}

            {/* Image Navigation */}
            {images.length > 1 && (
              <>
                <button
                  onClick={() => setCurrentImageIndex((currentImageIndex - 1 + images.length) % images.length)}
                  className="absolute left-4 top-1/2 -translate-y-1/2 w-11 h-11 rounded-full bg-black/50 flex items-center justify-center text-white text-xl hover:bg-black/70 transition-colors"
                >
                  ←
                </button>
                <button
                  onClick={() => setCurrentImageIndex((currentImageIndex + 1) % images.length)}
                  className="absolute right-4 top-1/2 -translate-y-1/2 w-11 h-11 rounded-full bg-black/50 flex items-center justify-center text-white text-xl hover:bg-black/70 transition-colors"
                >
                  →
                </button>
                <div className="absolute bottom-20 left-1/2 -translate-x-1/2 flex gap-2">
                  {images.map((_, index) => (
                    <button
                      key={index}
                      onClick={() => setCurrentImageIndex(index)}
                      className={`w-2 h-2 rounded-full transition-all ${
                        index === currentImageIndex ? 'bg-white w-6' : 'bg-white/50'
                      }`}
                    />
                  ))}
                </div>
              </>
            )}

            {/* Badges */}
            <div className="absolute top-4 left-4 flex gap-2 flex-wrap">
              {matchScore !== null && (
                <MatchScore score={matchScore} size="medium" />
              )}
              {listing.is_new_to_market && (
                <span className="px-3 py-1 bg-primary rounded-full text-white text-xs font-bold">
                  NEW TODAY
                </span>
              )}
              {listing.is_featured && (
                <span className="px-3 py-1 bg-yellow-500 rounded-full text-white text-xs font-bold">
                  ⭐ FEATURED
                </span>
              )}
            </div>
          </div>

          {/* Details */}
          <div className="px-5 space-y-6">
            {/* Price & Title */}
            <div>
              <div className="flex items-start justify-between mb-2">
                <h1 className="text-4xl font-bold text-white">
                  {formatPrice(listing.price)}
                  {listing.listing_type === 'rental' && (
                    <span className="text-xl text-white/80">/month</span>
                  )}
                </h1>
                <button
                  onClick={() => setShowPriceAlerts(true)}
                  className="px-3 py-2 bg-primary/20 hover:bg-primary/30 border border-primary/40 rounded-full text-primary font-semibold transition-colors flex items-center gap-1 text-sm min-h-[44px]"
                  title="Set price alert"
                >
                  <span className="text-lg">🔔</span>
                  Track Price
                </button>
              </div>
              <p className="text-xl text-white/90 mb-1">{listing.address}</p>
              <button
                onClick={() => setShowNeighborhood(true)}
                className="text-lg text-white/70 hover:text-primary transition-colors underline decoration-dotted underline-offset-4"
              >
                📍 {listing.neighborhood}
              </button>
              <button
                onClick={() => setShowCommuteCalculator(true)}
                className="mt-2 flex items-center gap-2 px-4 py-2 bg-white/10 hover:bg-white/20 rounded-full text-white/80 hover:text-white transition-colors min-h-[44px]"
              >
                <span className="text-xl">🧭</span>
                <span className="text-sm font-medium">Calculate Commute Time</span>
              </button>
            </div>

            {/* Why Scout Recommends This */}
            {matchReasons.length > 0 && (
              <motion.div
                className="glass-strong rounded-2xl p-6 border-2 border-primary/30"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 }}
              >
                <div className="flex items-center gap-2 mb-4">
                  <span className="text-2xl">🔍</span>
                  <h2 className="text-xl font-bold text-white">Why Scout Recommends This</h2>
                </div>
                <div className="space-y-3">
                  {matchReasons.map((reason, index) => (
                    <motion.div
                      key={index}
                      className="flex items-start gap-3"
                      initial={{ x: -20, opacity: 0 }}
                      animate={{ x: 0, opacity: 1 }}
                      transition={{ delay: 0.3 + index * 0.1 }}
                    >
                      <div className="w-6 h-6 rounded-full bg-gradient-to-r from-primary to-purple-500 flex items-center justify-center flex-shrink-0 mt-0.5">
                        <span className="text-white text-xs">✓</span>
                      </div>
                      <p className="text-white/90 leading-relaxed">{reason}</p>
                    </motion.div>
                  ))}
                </div>
              </motion.div>
            )}

            {/* Style Compatibility */}
            {hasStyleData && styleCompatibility !== null && (
              <motion.div
                className="glass-strong rounded-2xl p-6 bg-gradient-to-r from-purple-500/10 to-pink-500/10 border-2 border-purple-500/30"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3 }}
              >
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-2">
                    <span className="text-2xl">🎨</span>
                    <h3 className="text-lg font-bold text-white">Style Compatibility</h3>
                  </div>
                  <MatchScore score={styleCompatibility} size="small" showLabel={false} />
                </div>
                <p className="text-white/80 text-sm mb-3">
                  Based on your design preferences from Style Studio
                </p>
                <button
                  onClick={() => router.push('/studio')}
                  className="text-primary hover:text-purple-400 text-sm font-medium transition-colors flex items-center gap-1"
                >
                  Explore more design inspiration →
                </button>
              </motion.div>
            )}

            {/* Key Stats */}
            <div className="grid grid-cols-3 gap-4">
              <div className="glass-strong rounded-2xl p-4 text-center">
                <div className="text-3xl mb-1">🛏️</div>
                <div className="text-white font-bold">
                  {listing.bedrooms === 0 ? 'Studio' : listing.bedrooms}
                </div>
                <div className="text-white/60 text-sm">Bedrooms</div>
              </div>
              <div className="glass-strong rounded-2xl p-4 text-center">
                <div className="text-3xl mb-1">🚿</div>
                <div className="text-white font-bold">{listing.bathrooms}</div>
                <div className="text-white/60 text-sm">Bathrooms</div>
              </div>
              <div className="glass-strong rounded-2xl p-4 text-center">
                <div className="text-3xl mb-1">📏</div>
                <div className="text-white font-bold">
                  {listing.square_footage ? listing.square_footage.toLocaleString() : 'N/A'}
                </div>
                <div className="text-white/60 text-sm">sqft</div>
              </div>
            </div>

            {/* Description */}
            {listing.description && (
              <div className="glass-strong rounded-2xl p-6">
                <h2 className="text-xl font-bold text-white mb-3">About This Property</h2>
                <p className="text-white/80 leading-relaxed">{listing.description}</p>
              </div>
            )}

            {/* Amenities */}
            {listing.amenities && listing.amenities.length > 0 && (
              <div className="glass-strong rounded-2xl p-6">
                <h2 className="text-xl font-bold text-white mb-3">Amenities</h2>
                <div className="grid grid-cols-2 gap-3">
                  {listing.amenities.map((amenity, index) => (
                    <div key={index} className="flex items-center gap-2 text-white/80">
                      <span className="text-primary">✓</span>
                      <span>{amenity}</span>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Monthly Costs */}
            {listing.listing_type === 'rental' && (
              <div className="glass-strong rounded-2xl p-6">
                <h2 className="text-xl font-bold text-white mb-3">Monthly Costs</h2>
                <div className="space-y-2">
                  <div className="flex justify-between text-white/80">
                    <span>Rent</span>
                    <span className="font-bold">{formatPrice(listing.price)}</span>
                  </div>
                  {listing.monthly_hoa > 0 && (
                    <div className="flex justify-between text-white/80">
                      <span>HOA</span>
                      <span>{formatPrice(listing.monthly_hoa)}</span>
                    </div>
                  )}
                  {listing.monthly_maintenance > 0 && (
                    <div className="flex justify-between text-white/80">
                      <span>Maintenance</span>
                      <span>{formatPrice(listing.monthly_maintenance)}</span>
                    </div>
                  )}
                  <div className="border-t border-white/20 my-2"></div>
                  <div className="flex justify-between text-white font-bold text-lg">
                    <span>Total Monthly</span>
                    <span>
                      {formatPrice(
                        listing.price +
                          listing.monthly_hoa +
                          listing.monthly_maintenance
                      )}
                    </span>
                  </div>
                </div>
              </div>
            )}

            {/* Similar Properties You'll Love */}
            {similarProperties.length > 0 && (
              <div>
                <div className="flex items-center gap-2 mb-4">
                  <h2 className="text-2xl font-bold text-white">Similar Properties You'll Love</h2>
                  <span className="text-2xl">✨</span>
                </div>
                <p className="text-white/60 mb-6">
                  Based on your taste, here are {similarProperties.length} more properties you might like
                </p>
                <div className="grid grid-cols-2 gap-4">
                  {similarProperties.map((property, index) => (
                    <motion.div
                      key={property.id}
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: index * 0.1 }}
                    >
                      <PropertyCard
                        listing={property}
                        size="small"
                        onClick={() => {
                          analytics.click('view_similar_property', 'card', {
                            listing_id: property.id,
                            match_score: property.match_score,
                          });
                          router.push(`/scout/${property.id}`);
                        }}
                      />
                    </motion.div>
                  ))}
                </div>
              </div>
            )}

            {/* CTA Buttons */}
            <div className="space-y-3 sticky bottom-24 pb-6">
              <div className="flex gap-3">
                <button
                  onClick={() => setShowTourScheduler(true)}
                  className="flex-1 px-6 py-4 bg-primary text-white rounded-full font-bold hover:bg-primary/90 transition-colors min-h-[44px]"
                >
                  Schedule Tour
                </button>
                <button
                  onClick={() => {
                    analytics.contactAgent('agent-id', 'message');
                    alert('Messaging coming soon!');
                  }}
                  className="flex-1 px-6 py-4 bg-white/20 text-white rounded-full font-bold hover:bg-white/30 transition-colors backdrop-blur-sm min-h-[44px]"
                >
                  Message Agent
                </button>
              </div>

              {/* Save to Vault Button */}
              <button
                onClick={() => setShowSaveToVault(true)}
                className="w-full px-6 py-4 bg-white/10 hover:bg-white/20 text-white rounded-full font-semibold transition-colors backdrop-blur-sm flex items-center justify-center gap-2 min-h-[44px]"
              >
                <span className="text-xl">🔐</span>
                Save Documents to Vault
              </button>
            </div>
          </div>
        </motion.div>
      </div>

      {/* Share Property Modal */}
      <ShareProperty
        isOpen={showShare}
        onClose={() => setShowShare(false)}
        property={listing}
      />

      {/* Virtual Walkthrough Modal */}
      <VirtualWalkthrough
        isOpen={showWalkthrough}
        onClose={() => setShowWalkthrough(false)}
        images={allImages}
        address={listing.address}
      />

      {/* Neighborhood Deep Dive Modal */}
      <NeighborhoodDeepDive
        isOpen={showNeighborhood}
        onClose={() => setShowNeighborhood(false)}
        neighborhoodName={listing.neighborhood}
      />

      {/* Save to Vault Modal */}
      <SaveToVault
        isOpen={showSaveToVault}
        onClose={() => setShowSaveToVault(false)}
        property={listing}
      />

      {/* Tour Scheduler Modal */}
      <TourScheduler
        isOpen={showTourScheduler}
        onClose={() => setShowTourScheduler(false)}
        property={listing}
      />

      {/* Commute Calculator Modal */}
      <CommuteCalculator
        isOpen={showCommuteCalculator}
        onClose={() => setShowCommuteCalculator(false)}
        property={listing}
      />

      {/* Price Alerts Modal */}
      <PriceAlerts
        isOpen={showPriceAlerts}
        onClose={() => setShowPriceAlerts(false)}
        property={listing}
      />

      {/* Property Chat Modal */}
      <PropertyChat
        isOpen={showPropertyChat}
        onClose={() => setShowPropertyChat(false)}
        property={listing}
      />

      {/* Floating Chat Button */}
      {!showPropertyChat && (
        <motion.button
          onClick={() => setShowPropertyChat(true)}
          whileTap={{ scale: 0.9 }}
          className="fixed bottom-28 right-6 z-40 w-16 h-16 rounded-full bg-gradient-to-r from-primary via-purple-500 to-pink-500 text-white shadow-lg hover:shadow-xl transition-shadow flex items-center justify-center text-2xl"
          title="Ask questions"
        >
          💬
        </motion.button>
      )}

      {/* Bottom Navigation */}
      <BottomNav />
    </main>
  );
}
