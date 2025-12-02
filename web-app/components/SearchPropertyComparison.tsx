'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { X, Home, DollarSign, Maximize, MapPin, Star, TrendingUp, Zap } from 'lucide-react';
import Image from 'next/image';
import type { Listing, SavedLocation, CommuteInfo } from '@/lib/types';
import { calculateCommutes, getPrimaryCommute } from '@/lib/commute';
import { useMemo } from 'react';

interface SearchPropertyComparisonProps {
  listings: Listing[];
  savedLocations: SavedLocation[];
  onClose: () => void;
}

interface ComparisonMetric {
  label: string;
  icon: React.ReactNode;
  getValue: (listing: Listing, commute?: CommuteInfo | null) => string | number;
  isBetterWhen?: 'higher' | 'lower';
  format?: (value: any, commute?: CommuteInfo | null) => string;
}

export default function SearchPropertyComparison({
  listings,
  savedLocations,
  onClose,
}: SearchPropertyComparisonProps) {
  // Calculate commutes for each listing
  const listingCommutes = useMemo(() => {
    return listings.map(listing => {
      const commutes = calculateCommutes(
        listing.latitude,
        listing.longitude,
        savedLocations
      );
      return getPrimaryCommute(commutes);
    });
  }, [listings, savedLocations]);

  // Define comparison metrics
  const metrics: ComparisonMetric[] = [
    {
      label: 'Monthly Rent',
      icon: <DollarSign className="w-4 h-4" />,
      getValue: (listing) => listing.price,
      isBetterWhen: 'lower',
      format: (value) => `$${value.toLocaleString()}`,
    },
    {
      label: 'Square Feet',
      icon: <Maximize className="w-4 h-4" />,
      getValue: (listing) => listing.square_footage || 0,
      isBetterWhen: 'higher',
      format: (value) => value > 0 ? `${value.toLocaleString()} sqft` : 'N/A',
    },
    {
      label: 'Bedrooms',
      icon: <Home className="w-4 h-4" />,
      getValue: (listing) => listing.bedrooms,
      isBetterWhen: 'higher',
      format: (value) => `${value} bed`,
    },
    {
      label: 'Bathrooms',
      icon: <Home className="w-4 h-4" />,
      getValue: (listing) => listing.bathrooms,
      isBetterWhen: 'higher',
      format: (value) => `${value} bath`,
    },
    {
      label: 'Walk Score',
      icon: <Star className="w-4 h-4" />,
      getValue: (listing) => listing.walk_score || 0,
      isBetterWhen: 'higher',
      format: (value) => value > 0 ? `${value}` : 'N/A',
    },
    {
      label: 'Price per Sqft',
      icon: <TrendingUp className="w-4 h-4" />,
      getValue: (listing) => listing.square_footage ? Math.round(listing.price / listing.square_footage) : 0,
      isBetterWhen: 'lower',
      format: (value) => value > 0 ? `$${value}/sqft` : 'N/A',
    },
  ];

  // Add commute metric if we have saved locations
  if (savedLocations.length > 0) {
    metrics.push({
      label: 'Commute Time',
      icon: <Zap className="w-4 h-4" />,
      getValue: (_, commute) => commute?.duration || 999,
      isBetterWhen: 'lower',
      format: (value, commute) =>
        commute ? `${commute.duration}m ${commute.icon}` : 'N/A',
    });
  }

  // Find the best value for each metric
  const getBestIndices = (metric: ComparisonMetric): number[] => {
    const values = listings.map((listing, index) =>
      metric.getValue(listing, listingCommutes[index])
    );

    if (metric.isBetterWhen === 'lower') {
      const validValues = values.filter(v => typeof v === 'number' && v > 0) as number[];
      if (validValues.length === 0) return [];
      const min = Math.min(...validValues);
      return values.map((v, i) => v === min ? i : -1).filter(i => i !== -1);
    } else {
      const validValues = values.filter(v => typeof v === 'number') as number[];
      if (validValues.length === 0) return [];
      const max = Math.max(...validValues);
      return values.map((v, i) => v === max ? i : -1).filter(i => i !== -1);
    }
  };

  // Generate AI summary for each property
  const getPropertySummary = (listing: Listing, commute: CommuteInfo | null): string => {
    const highlights: string[] = [];

    // Check for best values
    metrics.forEach(metric => {
      const bestIndices = getBestIndices(metric);
      const listingIndex = listings.findIndex(l => l.id === listing.id);
      if (bestIndices.includes(listingIndex)) {
        if (metric.label === 'Monthly Rent') highlights.push('unbeatable price');
        if (metric.label === 'Square Feet') highlights.push('spacious layout');
        if (metric.label === 'Walk Score') highlights.push('walkable neighborhood');
        if (metric.label === 'Price per Sqft') highlights.push('excellent value per square foot');
        if (metric.label === 'Commute Time') highlights.push('shortest commute');
      }
    });

    // Add general highlights
    if (listing.walk_score && listing.walk_score >= 90) {
      highlights.push('walker\'s paradise');
    }
    if (listing.bedrooms >= 3) {
      highlights.push('generous bedroom count');
    }
    if (listing.amenities.length >= 5) {
      highlights.push('impressive amenity package');
    }
    if (commute && commute.duration <= 15) {
      highlights.push('quick commute');
    }

    const reasons = highlights.slice(0, 3);
    if (reasons.length === 0) {
      return `This ${listing.bedrooms} bed/${listing.bathrooms} bath home in ${listing.neighborhood} offers comfortable living with solid fundamentals.`;
    }

    return `This home is a fit because of its ${reasons.join(', ')}${reasons.length > 1 ? ',' : ''} making it an excellent choice for your lifestyle.`;
  };

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm overflow-y-auto"
        onClick={onClose}
      >
        <motion.div
          initial={{ scale: 0.95, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          exit={{ scale: 0.95, opacity: 0 }}
          onClick={(e) => e.stopPropagation()}
          className="min-h-screen py-4 px-2 md:py-8 md:px-4"
        >
          <div className="max-w-7xl mx-auto">
            {/* Header */}
            <div className="flex items-start justify-between mb-3 md:mb-6 gap-2 md:gap-3">
              <div className="flex-1 min-w-0">
                <h2 className="text-lg md:text-3xl font-bold text-white mb-0.5 md:mb-2 truncate">
                  Compare
                </h2>
                <p className="text-xs md:text-base text-white/60 hidden md:block">
                  Side-by-side analysis of {listings.length} properties
                </p>
              </div>
              <button
                onClick={onClose}
                className="w-8 h-8 md:w-12 md:h-12 rounded-full glass-strong hover:bg-white/20 flex items-center justify-center transition-colors flex-shrink-0"
              >
                <X className="w-4 h-4 md:w-6 md:h-6 text-white" />
              </button>
            </div>

            {/* Property Images */}
            <div className={`grid ${
              listings.length === 2
                ? 'grid-cols-2'
                : 'grid-cols-3'
            } gap-2 md:gap-4 mb-3 md:mb-6`}>
              {listings.map((listing, index) => (
                <motion.div
                  key={listing.id}
                  initial={{ y: 20, opacity: 0 }}
                  animate={{ y: 0, opacity: 1 }}
                  transition={{ delay: index * 0.1 }}
                  className="relative group"
                >
                  <div className="relative h-32 md:h-64 rounded-lg md:rounded-2xl overflow-hidden">
                    {listing.image_urls && listing.image_urls.length > 0 ? (
                      <Image
                        src={listing.image_urls[0]}
                        alt={listing.address}
                        fill
                        className="object-cover"
                      />
                    ) : (
                      <div className="w-full h-full bg-gradient-to-br from-purple-900/20 to-pink-900/20 flex items-center justify-center">
                        <Home className="w-12 h-12 text-white/30" />
                      </div>
                    )}
                    <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent" />

                    {/* Property info overlay */}
                    <div className="absolute bottom-0 left-0 right-0 p-2 md:p-4">
                      <h3 className="font-bold text-white text-xs md:text-lg mb-0.5 md:mb-1 truncate">
                        {listing.address}
                      </h3>
                      <div className="flex items-center gap-1 md:gap-2 text-white/80 text-xs md:text-sm">
                        <MapPin className="w-2.5 h-2.5 md:w-3 md:h-3 flex-shrink-0" />
                        <span className="truncate">{listing.neighborhood}</span>
                      </div>
                    </div>

                    {/* Walk Score badge */}
                    {listing.walk_score && (
                      <div className="absolute top-2 right-2 md:top-4 md:right-4 px-2 py-0.5 md:px-3 md:py-1 rounded-full glass-strong border border-white/20">
                        <span className="text-xs md:text-sm font-semibold text-white">
                          {listing.walk_score}
                        </span>
                      </div>
                    )}
                  </div>
                </motion.div>
              ))}
            </div>

            {/* Comparison Table */}
            <motion.div
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: 0.3 }}
              className="glass-strong rounded-2xl md:rounded-3xl overflow-hidden"
            >
              {/* Column Headers with Addresses */}
              <div className={`grid ${
                listings.length === 2
                  ? 'grid-cols-[minmax(80px,120px)_1fr_1fr] md:grid-cols-[180px_1fr_1fr]'
                  : 'grid-cols-[minmax(60px,100px)_repeat(3,1fr)] md:grid-cols-[180px_repeat(3,1fr)]'
              } gap-1.5 md:gap-4 p-2 md:p-4 bg-white/5 border-b border-white/10`}>
                <div className="text-white/60 text-xs md:text-sm font-medium">
                  Metric
                </div>
                {listings.map((listing, index) => (
                  <div key={index} className="min-w-0 text-center">
                    <p className="text-white font-semibold text-xs md:text-sm truncate">
                      {listing.address.split(',')[0]}
                    </p>
                    <p className="text-white/60 text-xs truncate hidden md:block">
                      {listing.neighborhood}
                    </p>
                  </div>
                ))}
              </div>

              <div className="divide-y divide-white/10">
                {metrics.map((metric, metricIndex) => {
                  const bestIndices = getBestIndices(metric);

                  return (
                    <div
                      key={metric.label}
                      className={`grid ${
                        listings.length === 2
                          ? 'grid-cols-[minmax(80px,120px)_1fr_1fr] md:grid-cols-[180px_1fr_1fr]'
                          : 'grid-cols-[minmax(60px,100px)_repeat(3,1fr)] md:grid-cols-[180px_repeat(3,1fr)]'
                      } gap-1.5 md:gap-4 p-2 md:p-4 hover:bg-white/5 transition-colors items-center`}
                    >
                      {/* Metric Label */}
                      <div className="flex items-center gap-1 md:gap-2 min-w-0">
                        <div className="text-purple-400 flex-shrink-0 w-3 h-3 md:w-4 md:h-4">{metric.icon}</div>
                        <span className="font-medium text-white text-xs md:text-sm truncate">
                          {metric.label}
                        </span>
                      </div>

                      {/* Values for each property */}
                      {listings.map((listing, listingIndex) => {
                        const value = metric.getValue(
                          listing,
                          listingCommutes[listingIndex]
                        );
                        const isWinner = bestIndices.includes(listingIndex);
                        const displayValue = metric.format
                          ? metric.label === 'Commute Time'
                            ? metric.format(value, listingCommutes[listingIndex])
                            : metric.format(value)
                          : value;

                        return (
                          <motion.div
                            key={listingIndex}
                            initial={{ scale: 0.9, opacity: 0 }}
                            animate={{ scale: 1, opacity: 1 }}
                            transition={{ delay: metricIndex * 0.05 + listingIndex * 0.02 }}
                            className={`
                              px-1.5 md:px-4 py-1.5 md:py-3 rounded-lg md:rounded-xl font-semibold text-center transition-all text-xs md:text-sm min-w-0
                              ${
                                isWinner
                                  ? 'bg-gradient-to-br from-green-500/20 to-emerald-500/20 border border-green-500/50 md:border-2 text-green-300 shadow-lg shadow-green-500/20'
                                  : 'bg-white/5 text-white/80'
                              }
                            `}
                          >
                            <div className="truncate">{displayValue}</div>
                            {isWinner && (
                              <motion.span
                                initial={{ scale: 0 }}
                                animate={{ scale: 1 }}
                                transition={{ delay: 0.2, type: 'spring' }}
                                className="inline-block ml-0.5 md:ml-1 hidden md:inline"
                              >
                                ✨
                              </motion.span>
                            )}
                          </motion.div>
                        );
                      })}
                    </div>
                  );
                })}
              </div>

              {/* Amenities Comparison */}
              <div className="border-t border-white/10 p-2 md:p-6">
                <h3 className="font-bold text-white text-sm md:text-lg mb-2 md:mb-4 flex items-center gap-1.5 md:gap-2">
                  <Star className="w-3.5 h-3.5 md:w-5 md:h-5 text-purple-400" />
                  Amenities
                </h3>

                <div className={`grid ${
                  listings.length === 2
                    ? 'grid-cols-[minmax(80px,120px)_1fr_1fr] md:grid-cols-[180px_1fr_1fr]'
                    : 'grid-cols-[minmax(60px,100px)_repeat(3,1fr)] md:grid-cols-[180px_repeat(3,1fr)]'
                } gap-1.5 md:gap-4 items-start`}>
                  <div className="text-white/60 text-xs md:text-sm pt-1 hidden md:block">Features</div>
                  <div className="text-white/60 text-xs pt-1 md:hidden col-span-1"></div>

                  {listings.map((listing, index) => (
                    <div key={index} className="space-y-1 md:space-y-2 min-w-0">
                      {listing.amenities.slice(0, 3).map((amenity, i) => (
                        <div
                          key={i}
                          className="px-1.5 md:px-3 py-0.5 md:py-1.5 rounded bg-white/5 text-white/80 text-xs text-center truncate"
                        >
                          {amenity}
                        </div>
                      ))}
                      {listing.amenities.length > 3 && (
                        <div className="text-white/40 text-xs text-center">
                          +{listing.amenities.length - 3} more
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              </div>

              {/* AI Summary Section */}
              <div className="border-t border-white/10 p-2 md:p-6 bg-gradient-to-br from-purple-500/5 to-pink-500/5">
                <h3 className="font-bold text-white text-sm md:text-lg mb-2 md:mb-4 flex items-center gap-1.5 md:gap-2">
                  <Zap className="w-3.5 h-3.5 md:w-5 md:h-5 text-purple-400" />
                  Sarah's Take
                </h3>

                <div className={`grid ${
                  listings.length === 2
                    ? 'grid-cols-1 sm:grid-cols-2'
                    : 'grid-cols-1'
                } gap-2 md:gap-4`}>
                  {listings.map((listing, index) => (
                    <motion.div
                      key={listing.id}
                      initial={{ y: 20, opacity: 0 }}
                      animate={{ y: 0, opacity: 1 }}
                      transition={{ delay: 0.6 + index * 0.1 }}
                      className="glass-strong rounded-lg md:rounded-2xl p-2 md:p-4 border border-white/10"
                    >
                      <div className="flex items-start gap-1.5 md:gap-2 mb-1.5 md:mb-2">
                        <div className="w-6 h-6 md:w-8 md:h-8 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center flex-shrink-0">
                          <span className="text-white text-xs md:text-sm font-bold">S</span>
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="text-white font-semibold text-xs md:text-sm truncate">
                            {listing.address.split(',')[0]}
                          </p>
                          <p className="text-white/60 text-xs hidden md:block">AI Analysis</p>
                        </div>
                      </div>
                      <p className="text-white/90 text-xs md:text-sm leading-relaxed">
                        {getPropertySummary(listing, listingCommutes[index])}
                      </p>
                    </motion.div>
                  ))}
                </div>
              </div>
            </motion.div>

            {/* Footer tip */}
            <motion.p
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.5 }}
              className="text-center text-white/40 text-xs md:text-sm mt-3 md:mt-6 hidden md:block"
            >
              Green highlights indicate the best value in each category ✨
            </motion.p>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
}
