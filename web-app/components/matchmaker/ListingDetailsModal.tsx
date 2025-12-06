'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  X, ChevronLeft, ChevronRight, MapPin, DollarSign, Bed, Bath,
  Home, Calendar, Sparkles, Heart, Share2, ExternalLink,
  Maximize2, Package, Award, Clock
} from 'lucide-react';
import type { Listing } from '@/lib/types';

interface ListingDetailsModalProps {
  listing: Listing | null;
  onClose: () => void;
  onLove?: () => void;
  onShare?: () => void;
}

export default function ListingDetailsModal({
  listing,
  onClose,
  onLove,
  onShare,
}: ListingDetailsModalProps) {
  const [currentImageIndex, setCurrentImageIndex] = useState(0);

  if (!listing) return null;

  const images = listing.image_urls || [];
  const hasMultipleImages = images.length > 1;

  const nextImage = () => {
    setCurrentImageIndex((prev) => (prev + 1) % images.length);
  };

  const prevImage = () => {
    setCurrentImageIndex((prev) => (prev - 1 + images.length) % images.length);
  };

  return (
    <AnimatePresence>
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
        <motion.div
          key="listing-backdrop"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          onClick={onClose}
          className="absolute inset-0 bg-black/80 backdrop-blur-md"
        />

        <motion.div
          key="listing-modal"
          initial={{ opacity: 0, scale: 0.95, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.95, y: 20 }}
          className="relative glass-strong rounded-3xl max-w-4xl w-full max-h-[90vh] overflow-hidden border border-white/10"
        >
          {/* Close Button */}
          <button
            onClick={onClose}
            className="absolute top-4 right-4 z-30 w-10 h-10 rounded-full bg-black/60 backdrop-blur-sm border border-white/20 flex items-center justify-center text-white hover:bg-black/80 transition-all shadow-lg"
          >
            <X className="w-6 h-6" />
          </button>

          <div className="flex flex-col md:flex-row h-full max-h-[90vh]">
            {/* Left: Image Gallery */}
            <div className="relative md:w-1/2 h-80 md:h-auto bg-gradient-to-br from-purple-900 to-blue-900">
              {images.length > 0 ? (
                <>
                  <AnimatePresence mode="wait">
                    <motion.img
                      key={currentImageIndex}
                      src={images[currentImageIndex]}
                      alt={`Property ${currentImageIndex + 1}`}
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      exit={{ opacity: 0 }}
                      transition={{ duration: 0.3 }}
                      className="w-full h-full object-cover"
                    />
                  </AnimatePresence>

                  {/* Image Navigation */}
                  {hasMultipleImages && (
                    <>
                      <button
                        onClick={prevImage}
                        className="absolute left-4 top-1/2 -translate-y-1/2 w-10 h-10 rounded-full bg-black/60 backdrop-blur-sm border border-white/20 flex items-center justify-center text-white hover:bg-black/80 transition-all"
                      >
                        <ChevronLeft className="w-6 h-6" />
                      </button>
                      <button
                        onClick={nextImage}
                        className="absolute right-4 top-1/2 -translate-y-1/2 w-10 h-10 rounded-full bg-black/60 backdrop-blur-sm border border-white/20 flex items-center justify-center text-white hover:bg-black/80 transition-all"
                      >
                        <ChevronRight className="w-6 h-6" />
                      </button>

                      {/* Image Indicators */}
                      <div className="absolute bottom-4 left-1/2 -translate-x-1/2 flex gap-2">
                        {images.map((_, index) => (
                          <button
                            key={index}
                            onClick={() => setCurrentImageIndex(index)}
                            className={`h-1.5 rounded-full transition-all ${
                              index === currentImageIndex
                                ? 'w-8 bg-white'
                                : 'w-1.5 bg-white/50'
                            }`}
                          />
                        ))}
                      </div>
                    </>
                  )}

                  {/* Image Counter */}
                  {hasMultipleImages && (
                    <div className="absolute top-4 left-4 px-3 py-1.5 bg-black/60 backdrop-blur-sm rounded-full border border-white/20">
                      <span className="text-white text-sm font-medium">
                        {currentImageIndex + 1} / {images.length}
                      </span>
                    </div>
                  )}

                  {/* Featured Badge */}
                  {listing.is_featured && (
                    <div className="absolute top-4 left-1/2 -translate-x-1/2 px-3 py-1.5 bg-yellow-500/90 rounded-full flex items-center gap-1.5">
                      <Sparkles className="w-4 h-4 text-black" />
                      <span className="text-sm font-bold text-black">Featured</span>
                    </div>
                  )}
                </>
              ) : (
                <div className="w-full h-full flex items-center justify-center">
                  <Home className="w-20 h-20 text-white/30" />
                </div>
              )}
            </div>

            {/* Right: Property Details */}
            <div className="md:w-1/2 overflow-y-auto p-6 md:p-8">
              {/* Price */}
              <motion.div
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                className="mb-4"
              >
                <div className="flex items-baseline gap-2 mb-2">
                  <span className="text-4xl font-bold text-white">
                    ${listing.price?.toLocaleString()}
                  </span>
                  <span className="text-lg text-white/60">/month</span>
                </div>
              </motion.div>

              {/* Location */}
              <motion.div
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 }}
                className="mb-6"
              >
                <div className="flex items-start gap-2 text-white/80 mb-1">
                  <MapPin className="w-5 h-5 flex-shrink-0 mt-0.5" />
                  <div>
                    <p className="font-medium text-white">{listing.neighborhood}</p>
                    {listing.address && (
                      <p className="text-sm text-white/60 mt-1">{listing.address}</p>
                    )}
                  </div>
                </div>
              </motion.div>

              {/* Quick Stats */}
              <motion.div
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 }}
                className="grid grid-cols-3 gap-3 mb-6"
              >
                <div className="glass-medium rounded-xl p-3 border border-white/10 text-center">
                  <Bed className="w-5 h-5 text-primary mx-auto mb-1" />
                  <p className="text-xs text-white/60">Bedrooms</p>
                  <p className="text-lg font-bold text-white">{listing.bedrooms}</p>
                </div>

                <div className="glass-medium rounded-xl p-3 border border-white/10 text-center">
                  <Bath className="w-5 h-5 text-cyan-400 mx-auto mb-1" />
                  <p className="text-xs text-white/60">Bathrooms</p>
                  <p className="text-lg font-bold text-white">{listing.bathrooms}</p>
                </div>

                <div className="glass-medium rounded-xl p-3 border border-white/10 text-center">
                  <Maximize2 className="w-5 h-5 text-purple-400 mx-auto mb-1" />
                  <p className="text-xs text-white/60">Sq Ft</p>
                  <p className="text-lg font-bold text-white">
                    {listing.square_footage ? listing.square_footage.toLocaleString() : '—'}
                  </p>
                </div>
              </motion.div>

              {/* Description */}
              {listing.description && (
                <motion.div
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.3 }}
                  className="mb-6"
                >
                  <h4 className="text-sm font-semibold text-white/80 mb-2">Description</h4>
                  <p className="text-sm text-white/70 leading-relaxed">
                    {listing.description}
                  </p>
                </motion.div>
              )}

              {/* Amenities */}
              {listing.amenities && listing.amenities.length > 0 && (
                <motion.div
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.4 }}
                  className="mb-6"
                >
                  <h4 className="text-sm font-semibold text-white/80 mb-3">Amenities</h4>
                  <div className="flex flex-wrap gap-2">
                    {listing.amenities.map((amenity, index) => (
                      <div
                        key={index}
                        className="px-3 py-1.5 bg-gradient-to-r from-primary/20 to-purple-500/20 border border-primary/30 rounded-full flex items-center gap-1.5"
                      >
                        <Package className="w-3.5 h-3.5 text-primary" />
                        <span className="text-xs text-white/90">{amenity}</span>
                      </div>
                    ))}
                  </div>
                </motion.div>
              )}

              {/* Additional Info */}
              <motion.div
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.5 }}
                className="space-y-3 mb-6"
              >
                {listing.available_date && (
                  <div className="flex items-center gap-2 text-sm text-white/70">
                    <Calendar className="w-4 h-4" />
                    <span>Available: {new Date(listing.available_date).toLocaleDateString()}</span>
                  </div>
                )}

                {listing.property_type && (
                  <div className="flex items-center gap-2 text-sm text-white/70">
                    <Home className="w-4 h-4" />
                    <span className="capitalize">{listing.property_type}</span>
                  </div>
                )}

                {listing.lease_duration && (
                  <div className="flex items-center gap-2 text-sm text-white/70">
                    <Clock className="w-4 h-4" />
                    <span>{listing.lease_duration} month lease</span>
                  </div>
                )}
              </motion.div>

              {/* Action Buttons */}
              <motion.div
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.6 }}
                className="flex gap-3 pt-4 border-t border-white/10"
              >
                {onLove && (
                  <button
                    onClick={onLove}
                    className="flex-1 py-3 bg-gradient-to-r from-primary to-purple-500 rounded-xl text-white font-semibold hover:opacity-90 transition-all flex items-center justify-center gap-2"
                  >
                    <Heart className="w-5 h-5" fill="currentColor" />
                    Love This
                  </button>
                )}

                {onShare && (
                  <button
                    onClick={onShare}
                    className="px-6 py-3 glass-medium rounded-xl border border-white/20 text-white hover:bg-white/10 transition-all flex items-center justify-center gap-2"
                  >
                    <Share2 className="w-5 h-5" />
                  </button>
                )}

                {listing.listing_url && (
                  <a
                    href={listing.listing_url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="px-6 py-3 glass-medium rounded-xl border border-white/20 text-white hover:bg-white/10 transition-all flex items-center justify-center gap-2"
                  >
                    <ExternalLink className="w-5 h-5" />
                  </a>
                )}
              </motion.div>
            </div>
          </div>
        </motion.div>
      </div>
    </AnimatePresence>
  );
}
