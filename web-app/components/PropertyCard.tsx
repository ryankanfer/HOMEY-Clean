'use client';

import { motion } from 'framer-motion';
import type { Listing } from '@/lib/types';
import PropertyImage from './PropertyImage';

interface PropertyCardProps {
  listing: Listing;
  size?: 'small' | 'medium' | 'large' | 'hero';
  onClick?: () => void;
  onSave?: (listingId: string) => void;
  isSaved?: boolean;
}

export default function PropertyCard({ listing, size = 'medium', onClick, onSave, isSaved = false }: PropertyCardProps) {
  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      maximumFractionDigits: 0,
    }).format(price);
  };

  const sizeClasses = {
    small: 'w-[240px] h-[280px]',
    medium: 'w-[280px] h-[320px]',
    large: 'w-[320px] h-[360px]',
    hero: 'w-full h-[400px] md:h-[500px]',
  };

  const imageHeightClasses = {
    small: 'h-[140px]',
    medium: 'h-[160px]',
    large: 'h-[200px]',
    hero: 'h-[250px] md:h-[350px]',
  };

  return (
    <motion.div
      className={`${sizeClasses[size]} flex-shrink-0 glass rounded-2xl overflow-hidden cursor-pointer group`}
      onClick={onClick}
      whileHover={{ scale: 1.03 }}
      whileTap={{ scale: 0.98 }}
      transition={{ duration: 0.2 }}
    >
      {/* Image */}
      <div className={`relative ${imageHeightClasses[size]} overflow-hidden`}>
        <PropertyImage
          src={listing.thumbnail_url}
          alt={listing.address}
          neighborhood={listing.neighborhood}
          propertyType={listing.property_type}
          className="w-full h-full group-hover:scale-110 transition-transform duration-500"
        />

        {/* Badges */}
        <div className="absolute top-2 left-2 flex gap-2 z-10">
          {listing.is_new_to_market && (
            <div className="px-2 py-1 bg-primary rounded-full text-white text-xs font-bold">
              NEW
            </div>
          )}
          {listing.is_featured && (
            <div className="px-2 py-1 bg-yellow-500 rounded-full text-white text-xs font-bold">
              ⭐
            </div>
          )}
        </div>

        {/* Save Button */}
        {onSave && (
          <button
            onClick={(e) => {
              e.stopPropagation();
              onSave(listing.id);
            }}
            className="absolute top-2 right-2 z-20 w-10 h-10 rounded-full bg-black/40 backdrop-blur-sm flex items-center justify-center hover:bg-black/60 transition-all hover:scale-110 active:scale-95"
            aria-label={isSaved ? 'Unsave property' : 'Save property'}
          >
            <motion.div
              initial={false}
              animate={{ scale: isSaved ? 1.2 : 1 }}
              transition={{ type: 'spring', stiffness: 300 }}
            >
              {isSaved ? (
                <span className="text-xl">❤️</span>
              ) : (
                <span className="text-xl text-white/90">🤍</span>
              )}
            </motion.div>
          </button>
        )}

        {/* Gradient overlay */}
        <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent pointer-events-none z-10" />
      </div>

      {/* Content */}
      <div className="p-4">
        {/* Price */}
        <div className="text-xl font-bold text-white mb-1">
          {formatPrice(listing.price)}
          {listing.listing_type === 'rental' && (
            <span className="text-sm text-white/60 font-normal">/mo</span>
          )}
        </div>

        {/* Address */}
        <div className="text-white/90 text-sm font-medium mb-0.5 line-clamp-1">
          {listing.address}
        </div>
        <div className="text-white/60 text-xs mb-2">
          {listing.neighborhood}
        </div>

        {/* Details */}
        <div className="flex items-center gap-2 text-white/70 text-xs">
          <span>{listing.bedrooms === 0 ? 'Studio' : `${listing.bedrooms} bd`}</span>
          <span>•</span>
          <span>{listing.bathrooms} ba</span>
          {listing.square_footage && (
            <>
              <span>•</span>
              <span>{listing.square_footage.toLocaleString()} sqft</span>
            </>
          )}
        </div>

        {/* Amenities (for larger cards) */}
        {(size === 'large' || size === 'hero') && listing.amenities.length > 0 && (
          <div className="mt-2 flex flex-wrap gap-1">
            {listing.amenities.slice(0, 2).map((amenity, idx) => (
              <span
                key={idx}
                className="px-2 py-0.5 bg-white/10 rounded text-[10px] text-white/70"
              >
                {amenity}
              </span>
            ))}
          </div>
        )}
      </div>
    </motion.div>
  );
}
