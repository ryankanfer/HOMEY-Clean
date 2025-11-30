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
    if (!property?.square_feet) return null;
    return property.price / property.square_feet;
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

          {/* Comparison Modal */}
          <motion.div
            className="fixed inset-0 z-[251] flex items-center justify-center p-4"
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.9 }}
            onClick={(e) => e.stopPropagation()}
          >
            <div className="w-full max-w-6xl bg-gradient-to-b from-gray-900 to-black rounded-3xl overflow-hidden shadow-2xl border border-white/10 max-h-[90vh] overflow-y-auto">
              {/* Header */}
              <div className="sticky top-0 z-10 bg-black/80 backdrop-blur-md border-b border-white/10 p-6">
                <div className="flex items-center justify-between">
                  <h2 className="text-2xl font-bold text-white">Compare Your 3 Properties</h2>
                  <button
                    onClick={onClose}
                    className="w-11 h-11 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center text-white transition-colors"
                  >
                    ✕
                  </button>
                </div>

                {/* Mobile: Swipe Indicator */}
                <div className="md:hidden flex items-center justify-center gap-2 mt-4">
                  {propertyList.map((_, idx) => (
                    <button
                      key={idx}
                      onClick={() => setActiveIndex(idx)}
                      className={`h-2 rounded-full transition-all ${
                        idx === activeIndex ? 'w-8 bg-primary' : 'w-2 bg-white/30'
                      }`}
                    />
                  ))}
                </div>
              </div>

              {/* Mobile: Swipeable Single View */}
              <div className="md:hidden">
                <motion.div
                  drag="x"
                  dragConstraints={{ left: 0, right: 0 }}
                  dragElastic={0.2}
                  onDragEnd={(_, info) => {
                    if (info.offset.x > 100 && activeIndex > 0) {
                      setActiveIndex(activeIndex - 1);
                    } else if (info.offset.x < -100 && activeIndex < propertyList.length - 1) {
                      setActiveIndex(activeIndex + 1);
                    }
                  }}
                >
                  {propertyList[activeIndex] && (
                    <PropertyCard
                      property={propertyList[activeIndex].property!}
                      label={propertyList[activeIndex].label}
                      icon={propertyList[activeIndex].icon}
                      color={propertyList[activeIndex].color}
                      formatPrice={formatPrice}
                      getPricePerSqft={getPricePerSqft}
                      onView={() => {
                        router.push(`/scout/${propertyList[activeIndex].property!.id}`);
                        onClose();
                      }}
                    />
                  )}
                </motion.div>
              </div>

              {/* Desktop: Split Screen (3 columns) */}
              <div className="hidden md:grid md:grid-cols-3 gap-4 p-6">
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

              {/* Comparison Table */}
              <div className="p-6 border-t border-white/10">
                <h3 className="text-lg font-bold text-white mb-4">Key Differences</h3>
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
                          {item.property!.square_feet?.toLocaleString() || 'N/A'}
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
      <div className="relative h-64">
        <ProgressiveImage
          src={property.images?.[0] || '/placeholder-property.jpg'}
          alt={property.address}
          className="absolute inset-0 w-full h-full object-cover"
        />
        <div className="absolute top-4 left-4">
          <span className={`px-3 py-1.5 ${getColorClasses(color)} border rounded-full text-sm font-bold backdrop-blur-sm`}>
            {icon} {label}
          </span>
        </div>
      </div>

      {/* Details */}
      <div className="p-6">
        <h3 className="text-2xl font-bold text-white mb-2">{formatPrice(property.price)}/mo</h3>
        <p className="text-white/70 mb-1">{property.neighborhood}</p>
        {getPricePerSqft(property) && (
          <p className="text-white/50 text-sm">{formatPrice(getPricePerSqft(property)!)}/sqft</p>
        )}

        <button
          onClick={onView}
          className="mt-4 w-full py-3 bg-primary hover:bg-primary/90 text-white rounded-full font-semibold transition-colors"
        >
          View Details
        </button>
      </div>
    </div>
  );
}
