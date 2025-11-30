'use client';

import { motion } from 'framer-motion';
import { useRouter } from 'next/navigation';
import MatchScore from './MatchScore';

interface RecommendedListing {
  id: string;
  title?: string;
  price: number;
  bedrooms: number;
  bathrooms: number;
  sqft?: number;
  property_type?: string;
  address?: string;
  neighborhood?: string;
  images?: string[];
  match_score: number;
  match_reasons: string[];
}

interface RecommendationCardProps {
  listing: RecommendedListing;
  onClick?: () => void;
}

export default function RecommendationCard({ listing, onClick }: RecommendationCardProps) {
  const router = useRouter();

  const handleClick = () => {
    if (onClick) {
      onClick();
    } else {
      router.push(`/scout/${listing.id}`);
    }
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(price);
  };

  const formatSqft = (sqft?: number) => {
    if (!sqft) return null;
    return new Intl.NumberFormat('en-US').format(sqft);
  };

  return (
    <motion.div
      className="relative rounded-3xl overflow-hidden glass-strong cursor-pointer group h-[500px]"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      whileHover={{ scale: 1.02 }}
      transition={{ type: 'spring', stiffness: 300, damping: 30 }}
      onClick={handleClick}
    >
      {/* Image */}
      <div className="relative h-3/5">
        {listing.images && listing.images.length > 0 ? (
          <img
            src={listing.images[0]}
            alt={listing.title || 'Property'}
            className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
          />
        ) : (
          <div className="w-full h-full bg-gradient-to-br from-primary/20 to-purple-600/20 flex items-center justify-center">
            <span className="text-6xl">🏠</span>
          </div>
        )}

        {/* Gradient Overlay */}
        <div className="absolute inset-0 bg-gradient-to-t from-black via-black/40 to-transparent" />

        {/* Match Score Badge */}
        <div className="absolute top-4 right-4">
          <MatchScore score={listing.match_score} size="large" />
        </div>

        {/* Scout Badge */}
        <div className="absolute top-4 left-4">
          <motion.div
            className="px-4 py-2 bg-white/20 backdrop-blur-md rounded-full text-white font-bold text-sm border border-white/30"
            initial={{ x: -20, opacity: 0 }}
            animate={{ x: 0, opacity: 1 }}
            transition={{ delay: 0.2 }}
          >
            🔍 Scout's Pick
          </motion.div>
        </div>

        {/* Property Info Overlay */}
        <div className="absolute bottom-0 left-0 right-0 p-6">
          <motion.h2
            className="text-3xl font-bold text-white mb-2"
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.1 }}
          >
            {listing.title || `${listing.bedrooms} BR ${listing.property_type || 'Home'}`}
          </motion.h2>
          <motion.div
            className="flex items-center gap-2 text-white/90 mb-3"
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.15 }}
          >
            {listing.neighborhood && (
              <>
                <span className="text-lg">📍</span>
                <span className="font-medium">{listing.neighborhood}</span>
              </>
            )}
          </motion.div>
          <motion.div
            className="flex items-center gap-4 text-white/80 text-sm"
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.2 }}
          >
            <span>{listing.bedrooms} beds</span>
            <span>•</span>
            <span>{listing.bathrooms} baths</span>
            {listing.sqft && (
              <>
                <span>•</span>
                <span>{formatSqft(listing.sqft)} sqft</span>
              </>
            )}
          </motion.div>
        </div>
      </div>

      {/* Match Reasons Section */}
      <div className="h-2/5 p-6 bg-gradient-to-br from-black/90 to-black/80 backdrop-blur-sm">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-xl font-bold text-white">Why you'll love it</h3>
          <div className="text-2xl font-bold bg-gradient-to-r from-primary via-purple-500 to-pink-500 bg-clip-text text-transparent">
            {formatPrice(listing.price)}
          </div>
        </div>

        <div className="space-y-3">
          {listing.match_reasons && listing.match_reasons.length > 0 ? (
            listing.match_reasons.map((reason, index) => (
              <motion.div
                key={index}
                className="flex items-start gap-3"
                initial={{ x: -20, opacity: 0 }}
                animate={{ x: 0, opacity: 1 }}
                transition={{ delay: 0.3 + index * 0.1 }}
              >
                <div className="w-6 h-6 rounded-full bg-gradient-to-r from-primary to-purple-500 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <span className="text-white text-xs">✓</span>
                </div>
                <p className="text-white/90 text-sm leading-relaxed">{reason}</p>
              </motion.div>
            ))
          ) : (
            <motion.div
              className="flex items-start gap-3"
              initial={{ x: -20, opacity: 0 }}
              animate={{ x: 0, opacity: 1 }}
              transition={{ delay: 0.3 }}
            >
              <div className="w-6 h-6 rounded-full bg-gradient-to-r from-primary to-purple-500 flex items-center justify-center flex-shrink-0 mt-0.5">
                <span className="text-white text-xs">✓</span>
              </div>
              <p className="text-white/90 text-sm leading-relaxed">
                Great match based on your preferences
              </p>
            </motion.div>
          )}
        </div>

        <motion.button
          className="w-full mt-6 py-3 bg-gradient-to-r from-primary via-purple-500 to-pink-500 text-white rounded-full font-bold hover:shadow-lg transition-shadow"
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          onClick={handleClick}
        >
          View Details →
        </motion.button>
      </div>
    </motion.div>
  );
}
