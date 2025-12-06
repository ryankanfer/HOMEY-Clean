'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Gift, Sparkles, Heart, X, MapPin, DollarSign, Bed, Bath, Home, Zap } from 'lucide-react';
import type { Listing } from '@/lib/types';

interface MysteryBoxProps {
  listings: Listing[];
  onReveal: (listing: Listing, action: 'love' | 'pass') => void;
  dailyBoxesRemaining: number;
}

export default function MysteryBox({
  listings,
  onReveal,
  dailyBoxesRemaining,
}: MysteryBoxProps) {
  const [isOpening, setIsOpening] = useState(false);
  const [currentListing, setCurrentListing] = useState<Listing | null>(null);
  const [boxType, setBoxType] = useState<'standard' | 'premium'>('standard');

  const openBox = (type: 'standard' | 'premium') => {
    setBoxType(type);
    setIsOpening(true);

    // Animate box opening
    setTimeout(() => {
      // Get random listing
      const randomIndex = Math.floor(Math.random() * listings.length);
      setCurrentListing(listings[randomIndex]);
      setIsOpening(false);
    }, 2000);
  };

  const handleDecision = (action: 'love' | 'pass') => {
    if (!currentListing) return;
    onReveal(currentListing, action);
    setCurrentListing(null);
  };

  if (currentListing) {
    return (
      <div className="relative h-full flex flex-col">
        {/* Header */}
        <div className="px-4 py-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-gradient-to-br from-purple-500 to-pink-500 rounded-lg flex items-center justify-center">
              <Gift className="w-6 h-6 text-white" />
            </div>
            <div>
              <h3 className="text-lg font-bold text-white">Mystery Revealed!</h3>
              <p className="text-xs text-white/60">
                {boxType === 'premium' ? '✨ Premium Box' : '📦 Standard Box'}
              </p>
            </div>
          </div>
        </div>

        {/* Property Card */}
        <div className="flex-1 px-4 overflow-y-auto pb-32">
          <motion.div
            initial={{ opacity: 0, scale: 0.8, rotateY: 180 }}
            animate={{ opacity: 1, scale: 1, rotateY: 0 }}
            transition={{ duration: 0.6 }}
            className="glass-medium rounded-2xl overflow-hidden border border-white/10"
          >
            {/* Image */}
            <div className="relative h-80 bg-gradient-to-br from-purple-900 to-pink-900">
              {currentListing.image_urls?.[0] && (
                <img
                  src={currentListing.image_urls[0]}
                  alt="Property"
                  className="w-full h-full object-cover"
                />
              )}
              <div className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent" />

              {/* Price Badge */}
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: 0.3 }}
                className="absolute top-4 right-4 px-4 py-2 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full border border-white/20 shadow-lg"
              >
                <span className="text-lg font-bold text-white">
                  ${currentListing.price?.toLocaleString()}/mo
                </span>
              </motion.div>

              {/* Special Badge */}
              {currentListing.is_featured && (
                <motion.div
                  initial={{ scale: 0, rotate: -12 }}
                  animate={{ scale: 1, rotate: -12 }}
                  transition={{ delay: 0.5 }}
                  className="absolute top-4 left-4 px-3 py-1.5 bg-yellow-500/90 rounded-lg"
                >
                  <span className="text-sm font-bold text-black flex items-center gap-1">
                    <Sparkles className="w-4 h-4" />
                    Featured
                  </span>
                </motion.div>
              )}
            </div>

            {/* Details */}
            <div className="p-6 space-y-4">
              <div>
                <div className="flex items-center gap-2 text-white/60 mb-2">
                  <MapPin className="w-4 h-4" />
                  <span className="text-sm">{currentListing.neighborhood}, {currentListing.city}</span>
                </div>
                <h4 className="text-2xl font-bold text-white mb-2">
                  {currentListing.bedrooms} Bedroom Apartment
                </h4>
              </div>

              {/* Stats Grid */}
              <div className="grid grid-cols-3 gap-3">
                <div className="glass-medium rounded-lg p-3 border border-white/10 text-center">
                  <Bed className="w-5 h-5 text-primary mx-auto mb-1" />
                  <p className="text-xs text-white/60">Bedrooms</p>
                  <p className="text-lg font-bold text-white">{currentListing.bedrooms}</p>
                </div>

                <div className="glass-medium rounded-lg p-3 border border-white/10 text-center">
                  <Bath className="w-5 h-5 text-cyan-400 mx-auto mb-1" />
                  <p className="text-xs text-white/60">Bathrooms</p>
                  <p className="text-lg font-bold text-white">{currentListing.bathrooms}</p>
                </div>

                <div className="glass-medium rounded-lg p-3 border border-white/10 text-center">
                  <Home className="w-5 h-5 text-purple-400 mx-auto mb-1" />
                  <p className="text-xs text-white/60">Sq Ft</p>
                  <p className="text-lg font-bold text-white">
                    {currentListing.square_feet || '—'}
                  </p>
                </div>
              </div>

              {/* Amenities */}
              {currentListing.amenities && currentListing.amenities.length > 0 && (
                <div>
                  <p className="text-sm font-semibold text-white/80 mb-2">Amenities</p>
                  <div className="flex flex-wrap gap-2">
                    {currentListing.amenities.slice(0, 8).map((amenity, index) => (
                      <motion.span
                        key={index}
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.7 + index * 0.05 }}
                        className="px-3 py-1.5 bg-gradient-to-r from-purple-500/20 to-pink-500/20 border border-purple-500/30 rounded-full text-xs text-white/90"
                      >
                        {amenity}
                      </motion.span>
                    ))}
                  </div>
                </div>
              )}

              {/* Mystery Result */}
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 1 }}
                className="pt-4 border-t border-white/10"
              >
                <p className="text-center text-white/80 mb-4">
                  {boxType === 'premium' ? (
                    <span className="flex items-center justify-center gap-2">
                      <Sparkles className="w-5 h-5 text-yellow-400" />
                      <span>Premium mystery box revealed!</span>
                      <Sparkles className="w-5 h-5 text-yellow-400" />
                    </span>
                  ) : (
                    'Is this your dream home?'
                  )}
                </p>
              </motion.div>
            </div>
          </motion.div>
        </div>

        {/* Decision Buttons */}
        <div className="fixed bottom-24 left-0 right-0 z-20 px-4">
          <div className="max-w-md mx-auto">
            <div className="flex items-center justify-center gap-6">
              <motion.button
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
                onClick={() => handleDecision('pass')}
                className="w-20 h-20 rounded-full bg-red-500/20 backdrop-blur-sm border-2 border-red-500 flex items-center justify-center text-red-500 hover:bg-red-500/30 transition-all shadow-lg"
              >
                <X className="w-10 h-10" />
              </motion.button>

              <motion.button
                whileHover={{ scale: 1.1 }}
                whileTap={{ scale: 0.9 }}
                onClick={() => handleDecision('love')}
                className="w-24 h-24 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-white hover:scale-110 transition-all shadow-2xl"
              >
                <Heart className="w-12 h-12" fill="currentColor" />
              </motion.button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (isOpening) {
    return (
      <div className="flex items-center justify-center h-full">
        <motion.div
          animate={{
            rotateY: [0, 360],
            scale: [1, 1.2, 1],
          }}
          transition={{
            duration: 2,
            ease: 'easeInOut',
          }}
          className="text-center"
        >
          <div className="w-32 h-32 bg-gradient-to-br from-purple-500 to-pink-500 rounded-2xl flex items-center justify-center mx-auto mb-6 shadow-2xl">
            <Gift className="w-16 h-16 text-white" />
          </div>
          <p className="text-2xl font-bold text-white mb-2">Opening...</p>
          <p className="text-white/60">Revealing your mystery property</p>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="relative h-full flex flex-col items-center justify-center px-4">
      <div className="max-w-lg w-full space-y-6">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="w-16 h-16 bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl flex items-center justify-center mx-auto mb-4">
            <Gift className="w-8 h-8 text-white" />
          </div>
          <h3 className="text-2xl font-bold text-white mb-2">Mystery Box</h3>
          <p className="text-white/60">Open a box to reveal a random property</p>
        </div>

        {/* Daily Boxes */}
        <motion.button
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
          onClick={() => openBox('standard')}
          disabled={dailyBoxesRemaining === 0}
          className="w-full glass-medium rounded-2xl p-6 border-2 border-white/20 hover:border-purple-500/50 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <div className="flex items-center gap-4">
            <div className="w-16 h-16 bg-gradient-to-br from-purple-500/20 to-pink-500/20 rounded-xl flex items-center justify-center border border-purple-500/30">
              <Gift className="w-8 h-8 text-purple-400" />
            </div>
            <div className="flex-1 text-left">
              <h4 className="text-lg font-bold text-white mb-1">Daily Mystery Box</h4>
              <p className="text-sm text-white/60">
                {dailyBoxesRemaining > 0
                  ? `${dailyBoxesRemaining} box${dailyBoxesRemaining > 1 ? 'es' : ''} remaining today`
                  : 'Come back tomorrow!'}
              </p>
            </div>
            <div className="text-green-400 font-bold">FREE</div>
          </div>
        </motion.button>

        {/* Premium Box */}
        <motion.button
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
          onClick={() => openBox('premium')}
          className="w-full glass-medium rounded-2xl p-6 border-2 border-yellow-500/30 hover:border-yellow-500/50 transition-all relative overflow-hidden"
        >
          <div className="absolute inset-0 bg-gradient-to-r from-yellow-500/5 to-orange-500/5" />
          <div className="relative flex items-center gap-4">
            <div className="w-16 h-16 bg-gradient-to-br from-yellow-500 to-orange-500 rounded-xl flex items-center justify-center shadow-lg">
              <Sparkles className="w-8 h-8 text-white" />
            </div>
            <div className="flex-1 text-left">
              <h4 className="text-lg font-bold text-white mb-1 flex items-center gap-2">
                Premium Mystery Box
                <Sparkles className="w-4 h-4 text-yellow-400" />
              </h4>
              <p className="text-sm text-white/60">Guaranteed featured property</p>
            </div>
            <div className="flex items-center gap-2">
              <Zap className="w-5 h-5 text-yellow-400" />
              <div className="text-yellow-400 font-bold">5 Streak</div>
            </div>
          </div>
        </motion.button>

        {/* Info */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="p-4 bg-purple-500/10 border border-purple-500/30 rounded-xl"
        >
          <p className="text-sm text-purple-300 font-medium mb-1">How it works</p>
          <ul className="text-xs text-white/70 space-y-1">
            <li>• Each box contains a random property</li>
            <li>• Could be your dream home or something unexpected</li>
            <li>• Premium boxes unlock with 5-day streak</li>
            <li>• Make quick decisions to build your profile</li>
          </ul>
        </motion.div>
      </div>
    </div>
  );
}
