'use client';

import { useState } from 'react';
import { motion, useMotionValue, useTransform, PanInfo, AnimatePresence } from 'framer-motion';
import type { Listing } from '@/lib/types';
import { ChevronLeft, ChevronRight, MapPin, Info, Heart } from 'lucide-react';

interface EnhancedSwipeCardProps {
  listing: Listing;
  onSwipe: (direction: 'left' | 'right' | 'up') => void;
  onClick?: () => void;
  matchScore?: number;
  matchReasons?: string[];
  highlights?: string[];
}

export default function EnhancedSwipeCard({
  listing,
  onSwipe,
  onClick,
  matchScore,
  matchReasons = [],
  highlights = []
}: EnhancedSwipeCardProps) {
  const [exitDirection, setExitDirection] = useState<'left' | 'right' | 'up' | null>(null);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [showDetails, setShowDetails] = useState(false);

  const x = useMotionValue(0);
  const y = useMotionValue(0);

  // Rotation based on horizontal drag
  const rotate = useTransform(x, [-200, 200], [-20, 20]);

  // Opacity for action indicators
  const passOpacity = useTransform(x, [-150, -50, 0], [1, 0, 0]);
  const likeOpacity = useTransform(x, [0, 50, 150], [0, 0, 1]);
  const loveOpacity = useTransform(y, [-150, -50, 0], [1, 0, 0]);

  const images = listing.image_urls && listing.image_urls.length > 0
    ? listing.image_urls
    : listing.thumbnail_url
    ? [listing.thumbnail_url]
    : ['/placeholder-property.jpg'];

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      maximumFractionDigits: 0,
    }).format(price);
  };

  const handleDragEnd = (_: any, info: PanInfo) => {
    const threshold = 100;
    const upThreshold = -100;

    if (info.offset.y < upThreshold) {
      setExitDirection('up');
      onSwipe('up');
    } else if (info.offset.x > threshold) {
      setExitDirection('right');
      onSwipe('right');
    } else if (info.offset.x < -threshold) {
      setExitDirection('left');
      onSwipe('left');
    }
  };

  const nextImage = (e: React.MouseEvent) => {
    e.stopPropagation();
    setCurrentImageIndex((prev) => (prev + 1) % images.length);
  };

  const prevImage = (e: React.MouseEvent) => {
    e.stopPropagation();
    setCurrentImageIndex((prev) => (prev - 1 + images.length) % images.length);
  };

  const exitVariants = {
    left: { x: -500, opacity: 0, transition: { duration: 0.3 } },
    right: { x: 500, opacity: 0, transition: { duration: 0.3 } },
    up: { y: -500, opacity: 0, transition: { duration: 0.3 } },
  };

  return (
    <motion.div
      className="absolute w-full h-full"
      style={{
        x,
        y,
        rotate,
        cursor: 'grab',
      }}
      drag
      dragConstraints={{ left: 0, right: 0, top: 0, bottom: 0 }}
      dragElastic={1}
      onDragEnd={handleDragEnd}
      animate={exitDirection ? exitVariants[exitDirection] : {}}
      whileTap={{ cursor: 'grabbing' }}
    >
      <div className="w-full h-full rounded-3xl overflow-hidden glass-strong shadow-2xl">
        {/* Image Gallery */}
        <div className="relative h-3/5">
          {/* Current Image */}
          <AnimatePresence mode="wait">
            <motion.img
              key={currentImageIndex}
              src={images[currentImageIndex]}
              alt={`${listing.address} - Image ${currentImageIndex + 1}`}
              className="w-full h-full object-cover"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.2 }}
            />
          </AnimatePresence>

          {/* Image Navigation */}
          {images.length > 1 && (
            <>
              <button
                onClick={prevImage}
                className="absolute left-2 top-1/2 -translate-y-1/2 w-10 h-10 rounded-full bg-black/50 backdrop-blur-sm flex items-center justify-center text-white hover:bg-black/70 transition-all z-10"
              >
                <ChevronLeft className="w-6 h-6" />
              </button>

              <button
                onClick={nextImage}
                className="absolute right-2 top-1/2 -translate-y-1/2 w-10 h-10 rounded-full bg-black/50 backdrop-blur-sm flex items-center justify-center text-white hover:bg-black/70 transition-all z-10"
              >
                <ChevronRight className="w-6 h-6" />
              </button>

              {/* Image Dots */}
              <div className="absolute bottom-4 left-1/2 -translate-x-1/2 flex gap-1.5 z-10">
                {images.map((_, index) => (
                  <button
                    key={index}
                    onClick={(e) => {
                      e.stopPropagation();
                      setCurrentImageIndex(index);
                    }}
                    className={`w-2 h-2 rounded-full transition-all ${
                      index === currentImageIndex
                        ? 'bg-white w-6'
                        : 'bg-white/50 hover:bg-white/70'
                    }`}
                  />
                ))}
              </div>
            </>
          )}

          {/* Action Overlays */}
          <motion.div
            className="absolute top-8 left-8 px-6 py-3 bg-red-500 text-white font-bold text-2xl rounded-2xl border-4 border-white shadow-lg rotate-[-15deg]"
            style={{ opacity: passOpacity }}
          >
            PASS
          </motion.div>

          <motion.div
            className="absolute top-8 right-8 px-6 py-3 bg-green-500 text-white font-bold text-2xl rounded-2xl border-4 border-white shadow-lg rotate-[15deg]"
            style={{ opacity: likeOpacity }}
          >
            LIKE
          </motion.div>

          <motion.div
            className="absolute top-8 left-1/2 -translate-x-1/2 px-6 py-3 bg-gradient-to-r from-primary to-purple-500 text-white font-bold text-2xl rounded-2xl border-4 border-white shadow-lg"
            style={{ opacity: loveOpacity }}
          >
            ❤️ LOVE
          </motion.div>

          {/* Top Badges */}
          <div className="absolute top-4 left-4 flex flex-col gap-2 z-10">
            {matchScore && matchScore >= 70 && (
              <div className="px-3 py-1.5 bg-gradient-to-r from-primary to-purple-500 rounded-full flex items-center gap-2 backdrop-blur-sm">
                <Heart className="w-3 h-3 text-white fill-white" />
                <span className="text-white text-xs font-bold">{matchScore}% Match</span>
              </div>
            )}

            {listing.is_new_to_market && (
              <span className="px-3 py-1 bg-green-500 rounded-full text-white text-xs font-bold backdrop-blur-sm">
                NEW LISTING
              </span>
            )}

            {listing.is_featured && (
              <span className="px-3 py-1 bg-yellow-500 rounded-full text-white text-xs font-bold backdrop-blur-sm">
                ⭐ FEATURED
              </span>
            )}
          </div>

          {/* Details Toggle */}
          <button
            onClick={(e) => {
              e.stopPropagation();
              if (onClick) {
                onClick();
              } else {
                setShowDetails(!showDetails);
              }
            }}
            className="absolute top-4 right-4 w-10 h-10 rounded-full bg-black/50 backdrop-blur-sm flex items-center justify-center text-white hover:bg-black/70 transition-all z-10"
          >
            <Info className="w-5 h-5" />
          </button>
        </div>

        {/* Property Details */}
        <div className="h-2/5 p-6 bg-gradient-to-b from-black/60 to-black/80 backdrop-blur-sm overflow-y-auto">
          <div className="mb-3">
            <h2 className="text-3xl font-bold text-white mb-1">
              {formatPrice(listing.price)}
              {listing.listing_type === 'rental' && (
                <span className="text-xl text-white/80">/mo</span>
              )}
            </h2>
            <p className="text-white/90 text-lg">{listing.address}</p>
            <div className="flex items-center gap-1 text-white/60 text-sm mt-1">
              <MapPin className="w-4 h-4" />
              <span>{listing.neighborhood}</span>
            </div>
          </div>

          {/* Match Reasons */}
          {matchReasons.length > 0 && (
            <div className="mb-4 p-3 bg-primary/10 border border-primary/30 rounded-lg">
              <p className="text-primary text-xs font-semibold mb-2">Why we picked this:</p>
              <ul className="space-y-1">
                {matchReasons.slice(0, 2).map((reason, i) => (
                  <li key={i} className="text-white/80 text-xs flex items-start gap-2">
                    <span className="text-primary mt-0.5">•</span>
                    <span>{reason}</span>
                  </li>
                ))}
              </ul>
            </div>
          )}

          <div className="flex items-center gap-4 text-white/80 mb-4">
            <span className="flex items-center gap-1">
              <span className="text-xl">🛏️</span>
              {listing.bedrooms === 0 ? 'Studio' : `${listing.bedrooms} bed`}
            </span>
            <span>•</span>
            <span className="flex items-center gap-1">
              <span className="text-xl">🚿</span>
              {listing.bathrooms} bath
            </span>
            {listing.square_footage && (
              <>
                <span>•</span>
                <span className="flex items-center gap-1">
                  <span className="text-xl">📐</span>
                  {listing.square_footage.toLocaleString()} sqft
                </span>
              </>
            )}
          </div>

          {/* Features & Amenities */}
          {showDetails && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              exit={{ opacity: 0, height: 0 }}
              className="mb-4"
            >
              {listing.features && listing.features.length > 0 && (
                <div className="mb-3">
                  <p className="text-white/60 text-xs font-semibold mb-2">Features</p>
                  <div className="flex flex-wrap gap-2">
                    {listing.features.slice(0, 6).map((feature, i) => (
                      <span
                        key={i}
                        className={`px-2 py-1 rounded-lg text-xs ${
                          highlights.includes(feature)
                            ? 'bg-primary/20 border border-primary/40 text-primary'
                            : 'bg-white/10 border border-white/20 text-white/70'
                        }`}
                      >
                        {feature}
                      </span>
                    ))}
                  </div>
                </div>
              )}

              {listing.amenities && listing.amenities.length > 0 && (
                <div className="mb-3">
                  <p className="text-white/60 text-xs font-semibold mb-2">Building Amenities</p>
                  <div className="flex flex-wrap gap-2">
                    {listing.amenities.slice(0, 4).map((amenity, i) => (
                      <span
                        key={i}
                        className="px-2 py-1 bg-white/10 border border-white/20 rounded-lg text-white/70 text-xs"
                      >
                        {amenity}
                      </span>
                    ))}
                  </div>
                </div>
              )}

              {/* Scores */}
              <div className="flex gap-4 mb-3">
                {listing.walk_score && (
                  <div>
                    <p className="text-white/40 text-[10px]">Walk Score</p>
                    <p className="text-white font-semibold text-sm">{listing.walk_score}</p>
                  </div>
                )}
                {listing.transit_score && (
                  <div>
                    <p className="text-white/40 text-[10px]">Transit Score</p>
                    <p className="text-white font-semibold text-sm">{listing.transit_score}</p>
                  </div>
                )}
                {listing.noise_level && (
                  <div>
                    <p className="text-white/40 text-[10px]">Noise</p>
                    <p className="text-white font-semibold text-sm capitalize">{listing.noise_level}</p>
                  </div>
                )}
              </div>
            </motion.div>
          )}

          {listing.description && (
            <p className="text-white/70 text-sm line-clamp-2">
              {listing.description}
            </p>
          )}
        </div>
      </div>
    </motion.div>
  );
}
