'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import type { Listing } from '@/lib/types';
import ProgressiveImage from './ProgressiveImage';

interface PropertyComparisonProps {
  isOpen: boolean;
  onClose: () => void;
  properties: {
    investment: Listing | null;
    dream: Listing | null;
    stretch: Listing | null;
  };
}

export default function PropertyComparison({
  isOpen,
  onClose,
  properties,
}: PropertyComparisonProps) {
  const router = useRouter();
  const [activeIndex, setActiveIndex] = useState(0);

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      maximumFractionDigits: 0,
    }).format(price);
  };

  const propertyList = [
    { key: 'investment', label: 'The Investment', icon: '💰', color: 'green', property: properties.investment },
    { key: 'dream', label: 'The Dream', icon: '💖', color: 'pink', property: properties.dream },
    { key: 'stretch', label: 'The Stretch', icon: '✨', color: 'purple', property: properties.stretch },
  ].filter(p => p.property !== null);

  const getPricePerSqft = (property: Listing | null) => {
    if (!property?.square_footage) return null;
    return property.price / property.square_footage;
  };

  const getColorClasses = (color: string) => {
    const colors = {
      green: 'bg-green-500/20 border-green-500/50 text-green-300',
      pink: 'bg-pink-500/20 border-pink-500/50 text-pink-300',
      purple: 'bg-purple-500/20 border-purple-500/50 text-purple-300',
    };
    return colors[color as keyof typeof colors] || colors.green;
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            className="fixed inset-0 z-[250] bg-black/80 backdrop-blur-md"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
          />

          {/* Comparison Modal - Bottom Third Floating */}
          <motion.div
            className="fixed inset-x-0 bottom-0 z-[251] flex items-end justify-center p-4"
            initial={{ opacity: 0, y: 100 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 100 }}
            onClick={(e) => e.stopPropagation()}
          >
            <div className="w-full max-w-7xl bg-gradient-to-b from-gray-900 to-black rounded-t-3xl overflow-hidden shadow-2xl border border-white/10 max-h-[65vh] overflow-y-auto">
              {/* Header */}
              <div className="sticky top-0 z-10 bg-black/80 backdrop-blur-md border-b border-white/10 p-4">
                <div className="flex items-center justify-between">
                  <h2 className="text-lg md:text-2xl font-bold text-white">Compare Properties</h2>
                  <button
                    onClick={onClose}
                    className="w-9 h-9 md:w-11 md:h-11 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center text-white transition-colors text-sm"
                  >
                    ✕
                  </button>
                </div>
              </div>

              {/* Mobile & Desktop: Side-by-Side View */}
              <div className="p-4 overflow-x-auto">
                <div className="grid grid-cols-3 gap-3 min-w-[900px] lg:min-w-0">
                {propertyList.map((item) => (
                  <PropertyCard
                    key={item.key}
                    property={item.property!}
                    label={item.label}
                    icon={item.icon}
                    color={item.color}
                    formatPrice={formatPrice}
                    getPricePerSqft={getPricePerSqft}
                    onView={() => {
                      router.push(`/scout/${item.property!.id}`);
                      onClose();
                    }}
                  />
                ))}
                </div>
              </div>

              {/* Comparison Table */}
              <div className="p-4 md:p-6 border-t border-white/10">
                <h3 className="text-base md:text-lg font-bold text-white mb-3 md:mb-4">Key Differences</h3>
                <div className="space-y-3">
                  {/* Price Row */}
                  <div className="flex items-center justify-between">
                    <span className="text-white/60 text-sm">Price</span>
                    <div className="flex gap-4">
                      {propertyList.map((item) => (
                        <span key={item.key} className="text-white font-semibold text-sm">
                          {formatPrice(item.property!.price)}
                        </span>
                      ))}
                    </div>
                  </div>

                  {/* Price per sqft Row */}
                  <div className="flex items-center justify-between">
                    <span className="text-white/60 text-sm">Price/sqft</span>
                    <div className="flex gap-4">
                      {propertyList.map((item) => {
                        const ppsf = getPricePerSqft(item.property);
                        return (
                          <span key={item.key} className="text-white text-sm">
                            {ppsf ? formatPrice(ppsf) : 'N/A'}
                          </span>
                        );
                      })}
                    </div>
                  </div>

                  {/* Bedrooms Row */}
                  <div className="flex items-center justify-between">
                    <span className="text-white/60 text-sm">Bedrooms</span>
                    <div className="flex gap-4">
                      {propertyList.map((item) => (
                        <span key={item.key} className="text-white text-sm">
                          {item.property!.bedrooms || 'N/A'}
                        </span>
                      ))}
                    </div>
                  </div>

                  {/* Bathrooms Row */}
                  <div className="flex items-center justify-between">
                    <span className="text-white/60 text-sm">Bathrooms</span>
                    <div className="flex gap-4">
                      {propertyList.map((item) => (
                        <span key={item.key} className="text-white text-sm">
                          {item.property!.bathrooms || 'N/A'}
                        </span>
                      ))}
                    </div>
                  </div>

                  {/* Square Feet Row */}
                  <div className="flex items-center justify-between">
                    <span className="text-white/60 text-sm">Square Feet</span>
                    <div className="flex gap-4">
                      {propertyList.map((item) => (
                        <span key={item.key} className="text-white text-sm">
                          {item.property!.square_footage?.toLocaleString() || 'N/A'}
                        </span>
                      ))}
                    </div>
                  </div>

                  {/* Neighborhood Row */}
                  <div className="flex items-center justify-between">
                    <span className="text-white/60 text-sm">Neighborhood</span>
                    <div className="flex gap-4">
                      {propertyList.map((item) => (
                        <span key={item.key} className="text-white text-sm">
                          {item.property!.neighborhood}
                        </span>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}

// Property Card Component
function PropertyCard({
  property,
  label,
  icon,
  color,
  formatPrice,
  getPricePerSqft,
  onView,
}: {
  property: Listing;
  label: string;
  icon: string;
  color: string;
  formatPrice: (price: number) => string;
  getPricePerSqft: (property: Listing) => number | null;
  onView: () => void;
}) {
  const getColorClasses = (color: string) => {
    const colors = {
      green: 'bg-green-500/20 border-green-500/50 text-green-300',
      pink: 'bg-pink-500/20 border-pink-500/50 text-pink-300',
      purple: 'bg-purple-500/20 border-purple-500/50 text-purple-300',
    };
    return colors[color as keyof typeof colors] || colors.green;
  };

  return (
    <div className="rounded-2xl overflow-hidden glass-strong border border-white/10">
      {/* Image */}
      <div className="relative h-48 md:h-64">
        <ProgressiveImage
          src={property.image_urls?.[0] || '/placeholder-property.jpg'}
          alt={property.address}
          className="absolute inset-0 w-full h-full object-cover"
        />
        <div className="absolute top-2 md:top-4 left-2 md:left-4">
          <span className={`px-2 md:px-3 py-1 md:py-1.5 ${getColorClasses(color)} border rounded-full text-xs md:text-sm font-bold backdrop-blur-sm`}>
            {icon} {label}
          </span>
        </div>
      </div>

      {/* Details */}
      <div className="p-4 md:p-6">
        <h3 className="text-lg md:text-2xl font-bold text-white mb-2">{formatPrice(property.price)}/mo</h3>
        <p className="text-white/70 mb-1 text-sm md:text-base truncate">{property.neighborhood}</p>
        {getPricePerSqft(property) && (
          <p className="text-white/50 text-xs md:text-sm">{formatPrice(getPricePerSqft(property)!)}/sqft</p>
        )}

        <button
          onClick={onView}
          className="mt-3 md:mt-4 w-full py-2 md:py-3 bg-primary hover:bg-primary/90 text-white rounded-full text-sm md:text-base font-semibold transition-colors"
        >
          View Details
        </button>
      </div>
    </div>
  );
}
