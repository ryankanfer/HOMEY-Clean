'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { X, ArrowRight, Home } from 'lucide-react';
import Image from 'next/image';
import type { Listing } from '@/lib/types';

interface CompareFloatingDockProps {
  selectedListings: Listing[];
  onRemove: (id: string) => void;
  onCompare: () => void;
  onClear: () => void;
}

export default function CompareFloatingDock({
  selectedListings,
  onRemove,
  onCompare,
  onClear,
}: CompareFloatingDockProps) {
  if (selectedListings.length === 0) return null;

  const isReady = selectedListings.length >= 2;

  return (
    <AnimatePresence>
      <motion.div
        initial={{ y: 100, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        exit={{ y: 100, opacity: 0 }}
        className="fixed bottom-4 left-0 right-0 z-50 flex justify-center px-3 md:px-4"
      >
        <div className="w-full max-w-4xl">
          <div className="glass-strong rounded-2xl md:rounded-3xl p-3 md:p-4 shadow-2xl border border-white/20">
            <div className="flex items-center justify-between mb-3 md:mb-4 gap-2">
              <div className="flex items-center gap-2 md:gap-3 min-w-0 flex-1">
                <div className="w-8 h-8 md:w-10 md:h-10 rounded-lg md:rounded-xl bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center flex-shrink-0">
                  <Home className="w-4 h-4 md:w-5 md:h-5 text-white" />
                </div>
                <div className="min-w-0">
                  <h3 className="font-semibold text-white text-sm md:text-base truncate">
                    Compare Properties
                  </h3>
                  <p className="text-xs md:text-sm text-white/60 truncate">
                    {selectedListings.length}/3 selected
                    {!isReady && ' • Select at least 2'}
                  </p>
                </div>
              </div>
              <button
                onClick={onClear}
                className="px-3 md:px-4 py-1.5 md:py-2 rounded-lg md:rounded-xl bg-white/10 hover:bg-white/20 text-white/80 text-xs md:text-sm transition-colors flex-shrink-0"
              >
                Clear All
              </button>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-2 md:gap-3 mb-3 md:mb-4">
              {selectedListings.map((listing, index) => (
                <motion.div
                  key={listing.id}
                  initial={{ scale: 0.8, opacity: 0 }}
                  animate={{ scale: 1, opacity: 1 }}
                  exit={{ scale: 0.8, opacity: 0 }}
                  transition={{ delay: index * 0.1 }}
                  className="relative group"
                >
                  <div className="relative h-28 sm:h-32 rounded-xl md:rounded-2xl overflow-hidden bg-gradient-to-br from-purple-900/20 to-pink-900/20">
                    {listing.image_urls && listing.image_urls.length > 0 ? (
                      <Image
                        src={listing.image_urls[0]}
                        alt={listing.address}
                        fill
                        className="object-cover"
                      />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center">
                        <Home className="w-6 h-6 sm:w-8 sm:h-8 text-white/30" />
                      </div>
                    )}

                    {/* Gradient overlay */}
                    <div className="absolute inset-0 bg-gradient-to-t from-black/70 to-transparent" />

                    {/* Remove button */}
                    <button
                      onClick={() => onRemove(listing.id)}
                      className="absolute top-1.5 right-1.5 sm:top-2 sm:right-2 w-6 h-6 rounded-full bg-black/60 backdrop-blur-sm flex items-center justify-center opacity-100 sm:group-hover:opacity-100 transition-opacity"
                    >
                      <X className="w-3 h-3 sm:w-4 sm:h-4 text-white" />
                    </button>

                    {/* Property info */}
                    <div className="absolute bottom-1.5 left-1.5 right-1.5 sm:bottom-2 sm:left-2 sm:right-2">
                      <p className="text-xs font-semibold text-white truncate">
                        {listing.address}
                      </p>
                      <p className="text-xs text-white/90">
                        ${listing.price.toLocaleString()}/mo
                      </p>
                    </div>
                  </div>
                </motion.div>
              ))}

              {/* Empty slots */}
              {[...Array(3 - selectedListings.length)].map((_, index) => (
                <div
                  key={`empty-${index}`}
                  className="h-28 sm:h-32 rounded-xl md:rounded-2xl border-2 border-dashed border-white/20 flex items-center justify-center"
                >
                  <div className="text-center">
                    <Home className="w-5 h-5 sm:w-6 sm:h-6 text-white/30 mx-auto mb-1" />
                    <p className="text-xs text-white/40">Empty slot</p>
                  </div>
                </div>
              ))}
            </div>

            {/* Compare button */}
            <motion.button
              onClick={onCompare}
              disabled={!isReady}
              className={`
                w-full py-2.5 md:py-3 rounded-lg md:rounded-xl font-semibold text-sm md:text-base flex items-center justify-center gap-2
                transition-all duration-300
                ${
                  isReady
                    ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white hover:shadow-lg hover:shadow-purple-500/50'
                    : 'bg-white/10 text-white/40 cursor-not-allowed'
                }
              `}
              whileHover={isReady ? { scale: 1.02 } : {}}
              whileTap={isReady ? { scale: 0.98 } : {}}
            >
              Compare Now
              <ArrowRight className="w-4 h-4 md:w-5 md:h-5" />
            </motion.button>

            {!isReady && (
              <p className="text-center text-xs text-white/50 mt-1.5 md:mt-2">
                Select at least 2 properties to compare
              </p>
            )}
          </div>
        </div>
      </motion.div>
    </AnimatePresence>
  );
}
