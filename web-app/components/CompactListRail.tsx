'use client';

import { motion } from 'framer-motion';
import type { Listing } from '@/lib/types';

interface CompactListRailProps {
  title: string;
  subtitle?: string;
  listings: Listing[];
  onCardClick: (listing: Listing) => void;
  onSave?: (listingId: string) => void;
  savedListings?: Set<string>;
  onCompare?: (listingId: string) => void;
  selectedForCompare?: Set<string>;
}

export default function CompactListRail({
  title,
  subtitle,
  listings,
  onCardClick,
  onSave,
  savedListings,
  onCompare,
  selectedForCompare,
}: CompactListRailProps) {
  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      maximumFractionDigits: 0,
    }).format(price);
  };

  if (listings.length === 0) return null;

  return (
    <div className="mb-10">
      {/* Section Header */}
      <div className="px-5 mb-4">
        <h2 className="text-2xl font-bold text-white mb-1">{title}</h2>
        {subtitle && <p className="text-white/60 text-sm">{subtitle}</p>}
      </div>

      {/* Compact List */}
      <div className="px-5 space-y-2">
        {listings.map((listing, index) => (
          <motion.div
            key={listing.id}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.03 }}
            onClick={() => onCardClick(listing)}
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
                {formatPrice(listing.price)}
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
              </div>
            </div>

            {/* Action Buttons */}
            <div className="flex gap-2 flex-shrink-0">
              {/* Compare Checkbox */}
              {onCompare && (
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    onCompare(listing.id);
                  }}
                  className={`w-9 h-9 rounded-full flex items-center justify-center transition-colors ${
                    selectedForCompare?.has(listing.id)
                      ? 'bg-blue-500'
                      : 'bg-white/10 hover:bg-white/20'
                  }`}
                >
                  <span className="text-lg">{selectedForCompare?.has(listing.id) ? '✓' : '◻'}</span>
                </button>
              )}

              {/* Save Button */}
              {onSave && (
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    onSave(listing.id);
                  }}
                  className="w-9 h-9 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors"
                >
                  <span className="text-lg">{savedListings?.has(listing.id) ? '❤️' : '🤍'}</span>
                </button>
              )}
            </div>
          </motion.div>
        ))}
      </div>
    </div>
  );
}
