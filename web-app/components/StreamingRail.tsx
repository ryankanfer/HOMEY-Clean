'use client';

import { useRef } from 'react';
import { motion } from 'framer-motion';
import type { Listing } from '@/lib/types';

interface StreamingRailProps {
  title: string;
  subtitle?: string;
  listings: Listing[];
  type: 'cinematic' | 'poster' | 'compact';
  accentColor?: string;
  onCardClick: (listing: Listing) => void;
  onSave?: (listingId: string) => void;
  savedListings?: Set<string>;
  onCompare?: (listingId: string) => void;
  selectedForCompare?: Set<string>;
}

export default function StreamingRail({
  title,
  subtitle,
  listings,
  type,
  accentColor = 'from-blue-500 to-cyan-500',
  onCardClick,
  onSave,
  savedListings,
  onCompare,
  selectedForCompare,
}: StreamingRailProps) {
  const scrollRef = useRef<HTMLDivElement>(null);

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

      {/* Horizontal Scroll Container */}
      <div
        ref={scrollRef}
        className={`flex gap-4 overflow-x-auto scrollbar-hide px-5 pb-2 ${
          type === 'cinematic' ? 'snap-x snap-mandatory' : ''
        }`}
      >
        {listings.map((listing, index) => (
          <motion.div
            key={listing.id}
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: index * 0.05 }}
            className={`flex-shrink-0 ${
              type === 'cinematic'
                ? 'w-[85vw] snap-center'
                : type === 'poster'
                ? 'w-[200px]'
                : 'w-full'
            }`}
          >
            {type === 'cinematic' ? (
              // Cinematic Card (16:9)
              <div
                onClick={() => onCardClick(listing)}
                className="relative cursor-pointer group"
              >
                <div className="relative aspect-video rounded-2xl overflow-hidden bg-gradient-to-br from-blue-900/20 to-purple-900/20">
                  {listing.thumbnail_url ? (
                    <img
                      src={listing.thumbnail_url}
                      alt={listing.address}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center text-6xl">
                      🏠
                    </div>
                  )}

                  {/* Gradient Overlay */}
                  <div className="absolute inset-0 bg-gradient-to-t from-black via-black/40 to-transparent" />

                  {/* Content Overlay */}
                  <div className="absolute bottom-0 left-0 right-0 p-5">
                    {/* Match Score */}
                    {listing.match_score && (
                      <div className="mb-2">
                        <span className="px-3 py-1 bg-gradient-to-r from-blue-500 to-cyan-500 rounded-full text-white text-sm font-bold">
                          {Math.round(listing.match_score)}% Match
                        </span>
                      </div>
                    )}

                    {/* Price */}
                    <div className="text-3xl font-bold text-white mb-2">
                      {formatPrice(listing.price)}
                      {listing.listing_type === 'rental' && (
                        <span className="text-lg text-white/80 font-normal">/mo</span>
                      )}
                    </div>

                    {/* Address */}
                    <div className="text-white/90 font-medium mb-1">{listing.address}</div>
                    <div className="text-white/60 text-sm mb-3">{listing.neighborhood}</div>

                    {/* Details */}
                    <div className="flex items-center gap-4 text-sm text-white/80">
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
                  <div className="absolute top-4 right-4 flex gap-2">
                    {/* Compare Checkbox */}
                    {onCompare && (
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          onCompare(listing.id);
                        }}
                        className={`w-10 h-10 rounded-full backdrop-blur-sm flex items-center justify-center transition-colors ${
                          selectedForCompare?.has(listing.id)
                            ? 'bg-blue-500'
                            : 'bg-black/60 hover:bg-black/80'
                        }`}
                      >
                        <span className="text-xl">{selectedForCompare?.has(listing.id) ? '✓' : '◻'}</span>
                      </button>
                    )}

                    {/* Save Button */}
                    {onSave && (
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          onSave(listing.id);
                        }}
                        className="w-10 h-10 rounded-full bg-black/60 backdrop-blur-sm flex items-center justify-center hover:bg-black/80 transition-colors"
                      >
                        <span className="text-xl">{savedListings?.has(listing.id) ? '❤️' : '🤍'}</span>
                      </button>
                    )}
                  </div>
                </div>
              </div>
            ) : type === 'poster' ? (
              // Poster Card (3:4)
              <div
                onClick={() => onCardClick(listing)}
                className="relative cursor-pointer group"
              >
                <div className="relative aspect-[3/4] rounded-xl overflow-hidden bg-gradient-to-br from-amber-900/20 to-orange-900/20 border-2 border-amber-500/30 group-hover:border-amber-500/60 transition-colors">
                  {listing.thumbnail_url ? (
                    <img
                      src={listing.thumbnail_url}
                      alt={listing.address}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center text-5xl">
                      🏠
                    </div>
                  )}

                  {/* Gradient Overlay */}
                  <div className="absolute inset-0 bg-gradient-to-t from-black via-transparent to-transparent" />

                  {/* Agent Pick Badge */}
                  <div className="absolute top-3 left-3">
                    <div className="px-2 py-1 bg-gradient-to-r from-amber-500 to-orange-500 rounded-full text-white text-xs font-bold">
                      AGENT PICK
                    </div>
                  </div>

                  {/* Content Overlay */}
                  <div className="absolute bottom-0 left-0 right-0 p-4">
                    <div className="text-xl font-bold text-white mb-1">
                      {formatPrice(listing.price)}
                      {listing.listing_type === 'rental' && (
                        <span className="text-sm text-white/80 font-normal">/mo</span>
                      )}
                    </div>
                    <div className="text-white/90 text-sm font-medium mb-1 line-clamp-1">
                      {listing.address}
                    </div>
                    <div className="text-white/60 text-xs mb-2 line-clamp-1">
                      {listing.neighborhood}
                    </div>
                    <div className="flex items-center gap-2 text-xs text-white/80">
                      <span>{listing.bedrooms === 0 ? 'Studio' : `${listing.bedrooms} bd`}</span>
                      <span>•</span>
                      <span>{listing.bathrooms} ba</span>
                    </div>
                  </div>

                  {/* Action Buttons */}
                  <div className="absolute top-3 right-3 flex flex-col gap-2">
                    {/* Compare Checkbox */}
                    {onCompare && (
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          onCompare(listing.id);
                        }}
                        className={`w-8 h-8 rounded-full backdrop-blur-sm flex items-center justify-center transition-colors ${
                          selectedForCompare?.has(listing.id)
                            ? 'bg-blue-500'
                            : 'bg-black/60 hover:bg-black/80'
                        }`}
                      >
                        <span className="text-sm">{selectedForCompare?.has(listing.id) ? '✓' : '◻'}</span>
                      </button>
                    )}

                    {/* Save Button */}
                    {onSave && (
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          onSave(listing.id);
                        }}
                        className="w-8 h-8 rounded-full bg-black/60 backdrop-blur-sm flex items-center justify-center hover:bg-black/80 transition-colors"
                      >
                        <span className="text-sm">{savedListings?.has(listing.id) ? '❤️' : '🤍'}</span>
                      </button>
                    )}
                  </div>
                </div>
              </div>
            ) : null}
          </motion.div>
        ))}
      </div>
    </div>
  );
}
