'use client';

import { useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Heart, Share2, ChevronLeft, ChevronRight, Check, MapPin, Calendar, Sparkles, Navigation } from 'lucide-react';
import type { Listing, SavedLocation, CommuteInfo, AgentNote } from '@/lib/types';
import PropertyImage from './PropertyImage';
import { calculateCommutes, getPrimaryCommute, formatCommuteTime } from '@/lib/commute';
import SarahVoiceNote from './SarahVoiceNote';

interface ImmersivePropertyCardProps {
  listing: Listing & { match_score?: number };
  onClick?: () => void;
  onSave?: (listingId: string) => void;
  isSaved?: boolean;
  onCompare?: (listingId: string) => void;
  isSelected?: boolean;
  userPreferences?: any;
  savedLocations?: SavedLocation[];
  agentNote?: AgentNote | null;
}

export default function ImmersivePropertyCard({
  listing,
  onClick,
  onSave,
  isSaved = false,
  onCompare,
  isSelected = false,
  userPreferences,
  savedLocations = [],
  agentNote,
}: ImmersivePropertyCardProps) {
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [touchStart, setTouchStart] = useState(0);
  const [touchEnd, setTouchEnd] = useState(0);

  // Calculate commute info
  const commutes = useMemo(() => {
    if (!savedLocations || savedLocations.length === 0) return [];
    return calculateCommutes(listing.latitude, listing.longitude, savedLocations);
  }, [listing.latitude, listing.longitude, savedLocations]);

  const primaryCommute = useMemo(() => {
    return getPrimaryCommute(commutes);
  }, [commutes]);

  const images = listing.image_urls && listing.image_urls.length > 0
    ? listing.image_urls
    : listing.thumbnail_url
    ? [listing.thumbnail_url]
    : [];

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      maximumFractionDigits: 0,
    }).format(price);
  };

  // Generate AI reasoning based on listing features and user preferences
  const generateMatchReasons = () => {
    const reasons: string[] = [];

    // Check amenities
    if (listing.amenities.some(a => a.toLowerCase().includes('elevator'))) {
      reasons.push('Direct elevator access');
    }
    if (listing.amenities.some(a => a.toLowerCase().includes('kitchen'))) {
      reasons.push('Modern kitchen');
    }
    if (listing.amenities.some(a => a.toLowerCase().includes('laundry'))) {
      reasons.push('In-unit laundry');
    }
    if (listing.amenities.some(a => a.toLowerCase().includes('parking'))) {
      reasons.push('Parking included');
    }
    if (listing.amenities.some(a => a.toLowerCase().includes('balcony') || a.toLowerCase().includes('terrace'))) {
      reasons.push('Outdoor space');
    }
    if (listing.amenities.some(a => a.toLowerCase().includes('gym') || a.toLowerCase().includes('fitness'))) {
      reasons.push('Fitness center');
    }
    if (listing.amenities.some(a => a.toLowerCase().includes('doorman') || a.toLowerCase().includes('concierge'))) {
      reasons.push('24/7 doorman');
    }

    // Check features
    if (listing.features.some(f => f.toLowerCase().includes('light') || f.toLowerCase().includes('windows'))) {
      reasons.push('Natural light');
    }
    if (listing.features.some(f => f.toLowerCase().includes('view'))) {
      reasons.push('Great views');
    }
    if (listing.features.some(f => f.toLowerCase().includes('hardwood'))) {
      reasons.push('Hardwood floors');
    }

    // Check environmental factors
    if (listing.sun_hours && listing.sun_hours > 6) {
      reasons.push('Sunny exposure');
    }
    if (listing.noise_level === 'quiet') {
      reasons.push('Quiet location');
    }
    if (listing.walk_score && listing.walk_score > 80) {
      reasons.push('Walkable area');
    }

    // If we have fewer than 3 reasons, add some generic ones
    if (reasons.length < 3) {
      if (listing.is_new_to_market) {
        reasons.push('Newly listed');
      }
      if (listing.bedrooms >= 2) {
        reasons.push('Spacious layout');
      }
      if (listing.square_footage && listing.square_footage > 1000) {
        reasons.push('Good square footage');
      }
    }

    return reasons.slice(0, 4); // Max 4 reasons
  };

  const matchReasons = generateMatchReasons();

  const nextImage = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (currentImageIndex < images.length - 1) {
      setCurrentImageIndex(prev => prev + 1);
    }
  };

  const prevImage = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (currentImageIndex > 0) {
      setCurrentImageIndex(prev => prev - 1);
    }
  };

  const handleTouchStart = (e: React.TouchEvent) => {
    setTouchStart(e.targetTouches[0].clientX);
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    setTouchEnd(e.targetTouches[0].clientX);
  };

  const handleTouchEnd = () => {
    if (!touchStart || !touchEnd) return;

    const distance = touchStart - touchEnd;
    const isLeftSwipe = distance > 50;
    const isRightSwipe = distance < -50;

    if (isLeftSwipe && currentImageIndex < images.length - 1) {
      setCurrentImageIndex(prev => prev + 1);
    }
    if (isRightSwipe && currentImageIndex > 0) {
      setCurrentImageIndex(prev => prev - 1);
    }

    setTouchStart(0);
    setTouchEnd(0);
  };

  const handleShare = async (e: React.MouseEvent) => {
    e.stopPropagation();

    if (navigator.share) {
      try {
        await navigator.share({
          title: listing.address,
          text: `Check out this ${listing.bedrooms}BR ${listing.bathrooms}BA ${listing.property_type || 'property'} in ${listing.neighborhood}`,
          url: window.location.href,
        });
      } catch (err) {
        console.log('Share cancelled');
      }
    } else {
      // Fallback: copy to clipboard
      navigator.clipboard.writeText(window.location.href);
      alert('Link copied to clipboard!');
    }
  };

  return (
    <motion.div
      className="w-full mb-6 bg-slate-900/40 backdrop-blur-sm rounded-3xl overflow-hidden border border-white/10"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4 }}
    >
      {/* Image Gallery */}
      <div
        className="relative w-full h-[500px] overflow-hidden cursor-pointer"
        onClick={onClick}
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
      >
        <AnimatePresence mode="wait">
          <motion.div
            key={currentImageIndex}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.3 }}
            className="w-full h-full"
          >
            <PropertyImage
              src={images[currentImageIndex] || '/placeholder.jpg'}
              alt={`${listing.address} - Photo ${currentImageIndex + 1}`}
              neighborhood={listing.neighborhood}
              propertyType={listing.property_type || undefined}
              className="w-full h-full object-cover"
            />
          </motion.div>
        </AnimatePresence>

        {/* Gradient Overlays for Text Readability */}
        <div className="absolute inset-0 bg-gradient-to-b from-black/60 via-transparent to-black/80 pointer-events-none" />
        <div className="absolute bottom-0 left-0 right-0 h-2/3 bg-gradient-to-t from-black/90 via-black/50 to-transparent pointer-events-none" />

        {/* Top Badges & Actions */}
        <div className="absolute top-0 left-0 right-0 p-5 flex items-start justify-between z-20">
          <div className="flex flex-col gap-2">
            <div className="flex gap-2">
              {listing.is_new_to_market && (
                <motion.div
                  className="px-3 py-1.5 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full text-white text-xs font-bold shadow-lg"
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ delay: 0.2, type: 'spring' }}
                >
                  NEW
                </motion.div>
              )}
              {listing.match_score && listing.match_score > 80 && (
                <motion.div
                  className="px-3 py-1.5 bg-green-500/90 backdrop-blur-sm rounded-full text-white text-xs font-bold shadow-lg flex items-center gap-1"
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ delay: 0.3, type: 'spring' }}
                >
                  <Sparkles className="w-3 h-3" />
                  {listing.match_score}% Match
                </motion.div>
              )}
            </div>

            {/* Sarah's Take Badge */}
            {agentNote && (
              <motion.div
                className="px-3 py-2 bg-gradient-to-r from-purple-500/90 to-pink-500/90 backdrop-blur-sm border border-purple-300/50 rounded-full flex items-center gap-2 shadow-lg"
                initial={{ scale: 0, x: -20 }}
                animate={{ scale: 1, x: 0 }}
                transition={{ delay: 0.4, type: 'spring' }}
              >
                <Sparkles className="w-3 h-3 text-white" />
                <span className="text-white text-xs font-bold">Sarah's Pick</span>
              </motion.div>
            )}
          </div>

          {/* Action Buttons */}
          <div className="flex gap-2">
            {onSave && (
              <motion.button
                onClick={(e) => {
                  e.stopPropagation();
                  onSave(listing.id);
                }}
                className={`w-11 h-11 rounded-full ${
                  isSaved
                    ? 'bg-red-500/90'
                    : 'bg-black/40'
                } backdrop-blur-sm flex items-center justify-center hover:scale-110 active:scale-95 transition-all shadow-lg`}
                whileTap={{ scale: 0.9 }}
              >
                <Heart
                  className={`w-5 h-5 ${isSaved ? 'fill-white text-white' : 'text-white'}`}
                />
              </motion.button>
            )}
            <motion.button
              onClick={handleShare}
              className="w-11 h-11 rounded-full bg-black/40 backdrop-blur-sm flex items-center justify-center hover:scale-110 active:scale-95 transition-all shadow-lg"
              whileTap={{ scale: 0.9 }}
            >
              <Share2 className="w-5 h-5 text-white" />
            </motion.button>
            {onCompare && (
              <motion.button
                onClick={(e) => {
                  e.stopPropagation();
                  onCompare(listing.id);
                }}
                className={`w-11 h-11 rounded-full ${
                  isSelected
                    ? 'bg-purple-500/90'
                    : 'bg-black/40'
                } backdrop-blur-sm flex items-center justify-center hover:scale-110 active:scale-95 transition-all shadow-lg`}
                whileTap={{ scale: 0.9 }}
              >
                <Check className={`w-5 h-5 ${isSelected ? 'text-white' : 'text-white/70'}`} />
              </motion.button>
            )}
          </div>
        </div>

        {/* Gallery Navigation */}
        {images.length > 1 && (
          <>
            {/* Previous Button */}
            {currentImageIndex > 0 && (
              <motion.button
                onClick={prevImage}
                className="absolute left-4 top-1/2 -translate-y-1/2 z-20 w-10 h-10 rounded-full bg-black/60 backdrop-blur-sm flex items-center justify-center hover:bg-black/80 transition-colors shadow-lg"
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                whileTap={{ scale: 0.9 }}
              >
                <ChevronLeft className="w-6 h-6 text-white" />
              </motion.button>
            )}

            {/* Next Button */}
            {currentImageIndex < images.length - 1 && (
              <motion.button
                onClick={nextImage}
                className="absolute right-4 top-1/2 -translate-y-1/2 z-20 w-10 h-10 rounded-full bg-black/60 backdrop-blur-sm flex items-center justify-center hover:bg-black/80 transition-colors shadow-lg"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                whileTap={{ scale: 0.9 }}
              >
                <ChevronRight className="w-6 h-6 text-white" />
              </motion.button>
            )}

            {/* Image Indicator Dots */}
            <div className="absolute bottom-4 left-1/2 -translate-x-1/2 z-20 flex gap-1.5">
              {images.map((_, index) => (
                <button
                  key={index}
                  onClick={(e) => {
                    e.stopPropagation();
                    setCurrentImageIndex(index);
                  }}
                  className={`h-1.5 rounded-full transition-all ${
                    index === currentImageIndex
                      ? 'w-8 bg-white'
                      : 'w-1.5 bg-white/40 hover:bg-white/60'
                  }`}
                />
              ))}
            </div>
          </>
        )}

        {/* Bottom Info Overlay */}
        <div className="absolute bottom-0 left-0 right-0 p-5 z-10">
          <div className="flex items-end justify-between">
            <div className="flex-1">
              {/* Price */}
              <div className="text-3xl font-bold text-white mb-2 drop-shadow-lg">
                {formatPrice(listing.price)}
                {listing.listing_type === 'rental' && (
                  <span className="text-lg text-white/90 font-normal">/mo</span>
                )}
              </div>

              {/* Address */}
              <div className="text-white text-base font-semibold mb-1 drop-shadow-md flex items-center gap-2">
                <MapPin className="w-4 h-4 text-white/80" />
                {listing.address}
              </div>
              <div className="text-white/90 text-sm mb-3 drop-shadow-md">
                {listing.neighborhood}
              </div>

              {/* Details */}
              <div className="flex items-center gap-4 text-white text-sm font-medium drop-shadow-md">
                <span>{listing.bedrooms === 0 ? 'Studio' : `${listing.bedrooms} bed`}</span>
                <span className="text-white/60">•</span>
                <span>{listing.bathrooms} bath</span>
                {listing.square_footage && (
                  <>
                    <span className="text-white/60">•</span>
                    <span>{listing.square_footage.toLocaleString()} sqft</span>
                  </>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Sarah's Voice Note */}
      {agentNote && (
        <div className="px-5 pt-4 pb-4 border-t border-white/10">
          <SarahVoiceNote agentNote={agentNote} />
        </div>
      )}

      {/* Commute Reality Section */}
      {primaryCommute && (
        <div className="px-5 pt-4 pb-2 border-t border-white/10">
          <div className="flex items-center gap-2 mb-3">
            <Navigation className="w-4 h-4 text-blue-400" />
            <h3 className="text-white font-semibold text-sm">Commute</h3>
          </div>

          {/* Primary Commute Badge */}
          <motion.div
            className="mb-3 px-4 py-3 bg-gradient-to-r from-blue-500/20 to-cyan-500/20 border border-blue-500/40 rounded-xl"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="text-2xl">{primaryCommute.icon}</div>
                <div>
                  <div className="text-white font-bold text-base">
                    {formatCommuteTime(primaryCommute.duration)} to {primaryCommute.locationName}
                  </div>
                  <div className="text-blue-200 text-xs">
                    {primaryCommute.distance} mi • {primaryCommute.mode}
                  </div>
                </div>
              </div>
            </div>
          </motion.div>

          {/* Other Commutes */}
          {commutes.length > 1 && (
            <div className="grid grid-cols-2 gap-2">
              {commutes.slice(1, 3).map((commute, index) => (
                <motion.div
                  key={index}
                  className="px-3 py-2 bg-white/5 border border-white/10 rounded-lg"
                  initial={{ opacity: 0, x: -10 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: index * 0.05 }}
                >
                  <div className="flex items-center gap-2 mb-1">
                    <span className="text-base">{commute.icon}</span>
                    <span className="text-white/90 text-xs font-medium">
                      {formatCommuteTime(commute.duration)}
                    </span>
                  </div>
                  <div className="text-white/60 text-xs truncate">
                    to {commute.locationName}
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* AI Reasoning Section */}
      {matchReasons.length > 0 && (
        <div className="px-5 py-4 border-t border-white/10">
          <div className="flex items-center gap-2 mb-3">
            <Sparkles className="w-4 h-4 text-purple-400" />
            <h3 className="text-white font-semibold text-sm">Why this matches</h3>
          </div>
          <div className="grid grid-cols-2 gap-2">
            {matchReasons.map((reason, index) => (
              <motion.div
                key={index}
                className="flex items-center gap-2 px-3 py-2 bg-green-500/10 border border-green-500/30 rounded-lg"
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: index * 0.05 }}
              >
                <Check className="w-4 h-4 text-green-400 flex-shrink-0" />
                <span className="text-green-200 text-xs font-medium">{reason}</span>
              </motion.div>
            ))}
          </div>
        </div>
      )}

      {/* Quick Stats */}
      {(listing.walk_score || listing.transit_score || listing.noise_level) && (
        <div className="px-5 pb-4 flex gap-3">
          {listing.walk_score && (
            <div className="flex-1 px-3 py-2 bg-white/5 rounded-lg border border-white/10">
              <div className="text-white/50 text-xs mb-0.5">Walk Score</div>
              <div className="text-white font-bold text-sm">{listing.walk_score}/100</div>
            </div>
          )}
          {listing.transit_score && (
            <div className="flex-1 px-3 py-2 bg-white/5 rounded-lg border border-white/10">
              <div className="text-white/50 text-xs mb-0.5">Transit</div>
              <div className="text-white font-bold text-sm">{listing.transit_score}/100</div>
            </div>
          )}
          {listing.noise_level && (
            <div className="flex-1 px-3 py-2 bg-white/5 rounded-lg border border-white/10">
              <div className="text-white/50 text-xs mb-0.5">Noise</div>
              <div className="text-white font-bold text-sm capitalize">{listing.noise_level}</div>
            </div>
          )}
        </div>
      )}
    </motion.div>
  );
}
