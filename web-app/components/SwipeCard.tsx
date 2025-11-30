'use client';

import { useState } from 'react';
import { motion, useMotionValue, useTransform, PanInfo } from 'framer-motion';
import type { Listing } from '@/lib/types';
import PropertyImage from './PropertyImage';

interface SwipeCardProps {
  listing: Listing;
  onSwipe: (direction: 'left' | 'right' | 'up') => void;
  style?: React.CSSProperties;
}

export default function SwipeCard({ listing, onSwipe, style }: SwipeCardProps) {
  const [exitDirection, setExitDirection] = useState<'left' | 'right' | 'up' | null>(null);

  const x = useMotionValue(0);
  const y = useMotionValue(0);

  // Rotation based on horizontal drag
  const rotate = useTransform(x, [-200, 200], [-20, 20]);

  // Opacity for action indicators
  const passOpacity = useTransform(x, [-150, -50, 0], [1, 0, 0]);
  const likeOpacity = useTransform(x, [0, 50, 150], [0, 0, 1]);
  const loveOpacity = useTransform(y, [-150, -50, 0], [1, 0, 0]);

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
      // Swipe up = Love
      setExitDirection('up');
      onSwipe('up');
    } else if (info.offset.x > threshold) {
      // Swipe right = Like
      setExitDirection('right');
      onSwipe('right');
    } else if (info.offset.x < -threshold) {
      // Swipe left = Pass
      setExitDirection('left');
      onSwipe('left');
    }
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
        ...style,
      }}
      drag
      dragConstraints={{ left: 0, right: 0, top: 0, bottom: 0 }}
      dragElastic={1}
      onDragEnd={handleDragEnd}
      animate={exitDirection ? exitVariants[exitDirection] : {}}
      whileTap={{ cursor: 'grabbing' }}
    >
      <div className="w-full h-full rounded-3xl overflow-hidden glass-strong shadow-2xl">
        {/* Property Image */}
        <div className="relative h-3/5">
          <PropertyImage
            src={listing.image_urls[0] || listing.thumbnail_url}
            alt={listing.address}
            className="w-full h-full"
            neighborhood={listing.neighborhood}
            propertyType={listing.property_type}
          />

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
            className="absolute top-8 left-1/2 -translate-x-1/2 px-6 py-3 bg-primary text-white font-bold text-2xl rounded-2xl border-4 border-white shadow-lg"
            style={{ opacity: loveOpacity }}
          >
            ❤️ LOVE
          </motion.div>

          {/* Badges */}
          <div className="absolute top-4 left-4 flex gap-2">
            {listing.is_new_to_market && (
              <span className="px-3 py-1 bg-primary rounded-full text-white text-xs font-bold backdrop-blur-sm">
                NEW
              </span>
            )}
            {listing.is_featured && (
              <span className="px-3 py-1 bg-yellow-500 rounded-full text-white text-xs font-bold backdrop-blur-sm">
                ⭐ FEATURED
              </span>
            )}
          </div>
        </div>

        {/* Property Details */}
        <div className="h-2/5 p-6 bg-gradient-to-b from-black/60 to-black/80 backdrop-blur-sm">
          <div className="mb-3">
            <h2 className="text-3xl font-bold text-white mb-1">
              {formatPrice(listing.price)}
              {listing.listing_type === 'rental' && (
                <span className="text-xl text-white/80">/mo</span>
              )}
            </h2>
            <p className="text-white/90 text-lg">{listing.address}</p>
            <p className="text-white/60">{listing.neighborhood}</p>
          </div>

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
