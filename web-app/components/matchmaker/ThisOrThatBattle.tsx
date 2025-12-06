'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Swords, MapPin, DollarSign, Bed, Bath, Home, Clock, Trophy } from 'lucide-react';
import type { Listing } from '@/lib/types';

interface ThisOrThatBattleProps {
  listings: Listing[];
  onChoice: (winner: Listing, loser: Listing) => void;
  onComplete: () => void;
}

export default function ThisOrThatBattle({
  listings,
  onChoice,
  onComplete,
}: ThisOrThatBattleProps) {
  const [currentPair, setCurrentPair] = useState<[Listing, Listing] | null>(null);
  const [roundsCompleted, setRoundsCompleted] = useState(0);
  const [timeLeft, setTimeLeft] = useState(30);
  const [isRoundActive, setIsRoundActive] = useState(true);
  const [selectedSide, setSelectedSide] = useState<'left' | 'right' | null>(null);

  useEffect(() => {
    // Get random pair
    if (listings.length >= 2) {
      const shuffled = [...listings].sort(() => Math.random() - 0.5);
      setCurrentPair([shuffled[0], shuffled[1]]);
    }
  }, [listings]);

  useEffect(() => {
    if (!isRoundActive) return;

    const timer = setInterval(() => {
      setTimeLeft((prev) => {
        if (prev <= 1) {
          handleTimeout();
          return 30;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(timer);
  }, [isRoundActive]);

  const handleTimeout = () => {
    // Auto-select random if time runs out
    if (currentPair) {
      const random = Math.random() > 0.5 ? 'left' : 'right';
      handleChoice(random);
    }
  };

  const handleChoice = (side: 'left' | 'right') => {
    if (!currentPair) return;

    setSelectedSide(side);
    const winner = side === 'left' ? currentPair[0] : currentPair[1];
    const loser = side === 'left' ? currentPair[1] : currentPair[0];

    onChoice(winner, loser);

    // Animate and move to next round
    setTimeout(() => {
      setRoundsCompleted((prev) => prev + 1);
      setTimeLeft(30);
      setSelectedSide(null);

      // Get new pair
      const shuffled = [...listings].sort(() => Math.random() - 0.5);
      setCurrentPair([shuffled[0], shuffled[1]]);
    }, 1000);
  };

  if (!currentPair) {
    return (
      <div className="flex items-center justify-center h-full">
        <p className="text-white/60">Loading battle...</p>
      </div>
    );
  }

  const [leftListing, rightListing] = currentPair;

  return (
    <div className="relative h-full flex flex-col">
      {/* Header Stats */}
      <div className="flex items-center justify-between mb-4 px-4">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gradient-to-br from-orange-500 to-red-500 rounded-lg flex items-center justify-center">
            <Swords className="w-6 h-6 text-white" />
          </div>
          <div>
            <h3 className="text-lg font-bold text-white">This or That</h3>
            <p className="text-xs text-white/60">Choose your favorite</p>
          </div>
        </div>

        <div className="flex items-center gap-3">
          {/* Rounds */}
          <div className="px-3 py-1.5 bg-white/10 rounded-full border border-white/20">
            <span className="text-sm font-bold text-white">{roundsCompleted} rounds</span>
          </div>

          {/* Timer */}
          <div className={`px-3 py-1.5 rounded-full border flex items-center gap-2 ${
            timeLeft <= 10
              ? 'bg-red-500/20 border-red-500/30 animate-pulse'
              : 'bg-white/10 border-white/20'
          }`}>
            <Clock className="w-4 h-4 text-white" />
            <span className="text-sm font-bold text-white">{timeLeft}s</span>
          </div>
        </div>
      </div>

      {/* VS Battle Area */}
      <div className="flex-1 grid grid-cols-2 gap-4 px-4">
        {/* Left Property */}
        <motion.button
          onClick={() => handleChoice('left')}
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
          className={`relative glass-medium rounded-2xl overflow-hidden border-2 transition-all ${
            selectedSide === 'left'
              ? 'border-green-500 shadow-lg shadow-green-500/20'
              : 'border-white/10 hover:border-white/30'
          }`}
        >
          {/* Image */}
          <div className="relative h-48 bg-gradient-to-br from-purple-900 to-blue-900">
            {leftListing.image_urls?.[0] && (
              <img
                src={leftListing.image_urls[0]}
                alt="Property"
                className="w-full h-full object-cover"
              />
            )}
            <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />

            {/* Price Badge */}
            <div className="absolute top-3 right-3 px-3 py-1.5 bg-black/60 backdrop-blur-sm rounded-full border border-white/20">
              <span className="text-sm font-bold text-white">
                ${leftListing.price?.toLocaleString()}/mo
              </span>
            </div>
          </div>

          {/* Details */}
          <div className="p-4 space-y-3">
            <div>
              <h4 className="text-lg font-bold text-white line-clamp-1">
                {leftListing.neighborhood}
              </h4>
              <p className="text-sm text-white/60 line-clamp-1">
                {leftListing.city}
              </p>
            </div>

            <div className="grid grid-cols-2 gap-2">
              <div className="flex items-center gap-2 text-white/80">
                <Bed className="w-4 h-4" />
                <span className="text-sm">{leftListing.bedrooms} bed</span>
              </div>
              <div className="flex items-center gap-2 text-white/80">
                <Bath className="w-4 h-4" />
                <span className="text-sm">{leftListing.bathrooms} bath</span>
              </div>
            </div>

            {leftListing.square_feet && (
              <div className="flex items-center gap-2 text-white/60">
                <Home className="w-4 h-4" />
                <span className="text-sm">{leftListing.square_feet} sq ft</span>
              </div>
            )}
          </div>

          {/* Winner Badge */}
          {selectedSide === 'left' && (
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-20 h-20 bg-green-500 rounded-full flex items-center justify-center shadow-2xl"
            >
              <Trophy className="w-10 h-10 text-white" />
            </motion.div>
          )}
        </motion.button>

        {/* Right Property */}
        <motion.button
          onClick={() => handleChoice('right')}
          whileHover={{ scale: 1.02 }}
          whileTap={{ scale: 0.98 }}
          className={`relative glass-medium rounded-2xl overflow-hidden border-2 transition-all ${
            selectedSide === 'right'
              ? 'border-green-500 shadow-lg shadow-green-500/20'
              : 'border-white/10 hover:border-white/30'
          }`}
        >
          {/* Image */}
          <div className="relative h-48 bg-gradient-to-br from-purple-900 to-blue-900">
            {rightListing.image_urls?.[0] && (
              <img
                src={rightListing.image_urls[0]}
                alt="Property"
                className="w-full h-full object-cover"
              />
            )}
            <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />

            {/* Price Badge */}
            <div className="absolute top-3 right-3 px-3 py-1.5 bg-black/60 backdrop-blur-sm rounded-full border border-white/20">
              <span className="text-sm font-bold text-white">
                ${rightListing.price?.toLocaleString()}/mo
              </span>
            </div>
          </div>

          {/* Details */}
          <div className="p-4 space-y-3">
            <div>
              <h4 className="text-lg font-bold text-white line-clamp-1">
                {rightListing.neighborhood}
              </h4>
              <p className="text-sm text-white/60 line-clamp-1">
                {rightListing.city}
              </p>
            </div>

            <div className="grid grid-cols-2 gap-2">
              <div className="flex items-center gap-2 text-white/80">
                <Bed className="w-4 h-4" />
                <span className="text-sm">{rightListing.bedrooms} bed</span>
              </div>
              <div className="flex items-center gap-2 text-white/80">
                <Bath className="w-4 h-4" />
                <span className="text-sm">{rightListing.bathrooms} bath</span>
              </div>
            </div>

            {rightListing.square_feet && (
              <div className="flex items-center gap-2 text-white/60">
                <Home className="w-4 h-4" />
                <span className="text-sm">{rightListing.square_feet} sq ft</span>
              </div>
            )}
          </div>

          {/* Winner Badge */}
          {selectedSide === 'right' && (
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-20 h-20 bg-green-500 rounded-full flex items-center justify-center shadow-2xl"
            >
              <Trophy className="w-10 h-10 text-white" />
            </motion.div>
          )}
        </motion.button>
      </div>

      {/* VS Badge */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-10">
        <motion.div
          animate={{ rotate: [0, 360] }}
          transition={{ duration: 20, repeat: Infinity, ease: 'linear' }}
          className="w-16 h-16 bg-gradient-to-br from-orange-500 to-red-500 rounded-full flex items-center justify-center shadow-2xl border-4 border-black/20"
        >
          <span className="text-white font-bold text-lg">VS</span>
        </motion.div>
      </div>
    </div>
  );
}
