'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { DollarSign, Target, TrendingUp, Award, MapPin, Bed, Bath, Home } from 'lucide-react';
import type { Listing } from '@/lib/types';

interface GuessTheRentProps {
  listings: Listing[];
  onGuess: (listing: Listing, guess: number, accuracy: number) => void;
}

export default function GuessTheRent({
  listings,
  onGuess,
}: GuessTheRentProps) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [guess, setGuess] = useState('');
  const [showResult, setShowResult] = useState(false);
  const [accuracy, setAccuracy] = useState(0);
  const [points, setPoints] = useState(0);
  const [totalPoints, setTotalPoints] = useState(0);
  const [roundsPlayed, setRoundsPlayed] = useState(0);

  const currentListing = listings[currentIndex];

  const calculatePoints = (actualPrice: number, guessedPrice: number) => {
    const difference = Math.abs(actualPrice - guessedPrice);

    // Perfect guess (within $100) = 100 points
    if (difference <= 100) return 100;

    // Within $200 = 80 points
    if (difference <= 200) return 80;

    // Within $300 = 60 points
    if (difference <= 300) return 60;

    // Within $500 = 40 points
    if (difference <= 500) return 40;

    // Within $1000 = 20 points
    if (difference <= 1000) return 20;

    // Beyond $1000 = 0 points
    return 0;
  };

  const handleSubmitGuess = () => {
    if (!guess || !currentListing.price) return;

    const guessedPrice = parseInt(guess);
    const actualPrice = currentListing.price;
    const earnedPoints = calculatePoints(actualPrice, guessedPrice);
    const accuracyPercent = Math.max(0, 100 - (Math.abs(actualPrice - guessedPrice) / actualPrice) * 100);

    setPoints(earnedPoints);
    setTotalPoints((prev) => prev + earnedPoints);
    setAccuracy(Math.round(accuracyPercent));
    setShowResult(true);

    onGuess(currentListing, guessedPrice, accuracyPercent);
  };

  const handleNext = () => {
    setShowResult(false);
    setGuess('');
    setPoints(0);
    setAccuracy(0);
    setRoundsPlayed((prev) => prev + 1);
    setCurrentIndex((prev) => (prev + 1) % listings.length);
  };

  if (!currentListing) {
    return (
      <div className="flex items-center justify-center h-full">
        <p className="text-white/60">Loading properties...</p>
      </div>
    );
  }

  return (
    <div className="relative h-full flex flex-col">
      {/* Header */}
      <div className="flex items-center justify-between mb-4 px-4">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gradient-to-br from-green-500 to-emerald-500 rounded-lg flex items-center justify-center">
            <DollarSign className="w-6 h-6 text-white" />
          </div>
          <div>
            <h3 className="text-lg font-bold text-white">Guess the Rent</h3>
            <p className="text-xs text-white/60">Test your market knowledge</p>
          </div>
        </div>

        <div className="flex items-center gap-3">
          {/* Rounds */}
          <div className="px-3 py-1.5 bg-white/10 rounded-full border border-white/20">
            <span className="text-sm font-bold text-white">{roundsPlayed} guesses</span>
          </div>

          {/* Total Points */}
          <div className="px-3 py-1.5 bg-gradient-to-r from-green-500/20 to-emerald-500/20 rounded-full border border-green-500/30">
            <div className="flex items-center gap-2">
              <Award className="w-4 h-4 text-green-400" />
              <span className="text-sm font-bold text-green-300">{totalPoints} pts</span>
            </div>
          </div>
        </div>
      </div>

      {/* Property Card */}
      <div className="flex-1 px-4 overflow-y-auto">
        <motion.div
          key={currentListing.id}
          initial={{ opacity: 0, x: 50 }}
          animate={{ opacity: 1, x: 0 }}
          className="glass-medium rounded-2xl overflow-hidden border border-white/10"
        >
          {/* Image */}
          <div className="relative h-64 bg-gradient-to-br from-purple-900 to-blue-900">
            {currentListing.image_urls?.[0] && (
              <img
                src={currentListing.image_urls[0]}
                alt="Property"
                className="w-full h-full object-cover"
              />
            )}
            <div className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent" />

            {/* Mystery Price Badge */}
            {!showResult && (
              <div className="absolute top-4 right-4 px-4 py-2 bg-black/60 backdrop-blur-sm rounded-full border border-white/20">
                <span className="text-lg font-bold text-white">???</span>
              </div>
            )}

            {/* Actual Price (after guess) */}
            {showResult && (
              <motion.div
                initial={{ scale: 0, rotate: -180 }}
                animate={{ scale: 1, rotate: 0 }}
                className="absolute top-4 right-4 px-4 py-2 bg-gradient-to-r from-green-500 to-emerald-500 rounded-full border border-white/20 shadow-lg"
              >
                <span className="text-lg font-bold text-white">
                  ${currentListing.price?.toLocaleString()}/mo
                </span>
              </motion.div>
            )}
          </div>

          {/* Details */}
          <div className="p-6 space-y-4">
            <div>
              <div className="flex items-center gap-2 text-white/60 mb-2">
                <MapPin className="w-4 h-4" />
                <span className="text-sm">{currentListing.neighborhood}</span>
              </div>
              <h4 className="text-xl font-bold text-white">
                What's the monthly rent?
              </h4>
            </div>

            {/* Property Stats */}
            <div className="grid grid-cols-3 gap-4">
              <div className="glass-medium rounded-lg p-3 border border-white/10">
                <div className="flex items-center gap-2 mb-1">
                  <Bed className="w-4 h-4 text-primary" />
                  <span className="text-xs text-white/60">Bedrooms</span>
                </div>
                <p className="text-lg font-bold text-white">{currentListing.bedrooms}</p>
              </div>

              <div className="glass-medium rounded-lg p-3 border border-white/10">
                <div className="flex items-center gap-2 mb-1">
                  <Bath className="w-4 h-4 text-cyan-400" />
                  <span className="text-xs text-white/60">Bathrooms</span>
                </div>
                <p className="text-lg font-bold text-white">{currentListing.bathrooms}</p>
              </div>

              <div className="glass-medium rounded-lg p-3 border border-white/10">
                <div className="flex items-center gap-2 mb-1">
                  <Home className="w-4 h-4 text-purple-400" />
                  <span className="text-xs text-white/60">Sq Ft</span>
                </div>
                <p className="text-lg font-bold text-white">
                  {currentListing.square_footage || '—'}
                </p>
              </div>
            </div>

            {/* Features */}
            {currentListing.amenities && currentListing.amenities.length > 0 && (
              <div>
                <p className="text-sm font-semibold text-white/80 mb-2">Amenities</p>
                <div className="flex flex-wrap gap-2">
                  {currentListing.amenities.slice(0, 6).map((amenity, index) => (
                    <span
                      key={index}
                      className="px-3 py-1 bg-white/5 border border-white/10 rounded-full text-xs text-white/80"
                    >
                      {amenity}
                    </span>
                  ))}
                </div>
              </div>
            )}

            {/* Guess Input */}
            {!showResult && (
              <div className="space-y-3 pt-4 border-t border-white/10">
                <label className="block text-sm font-semibold text-white/80">
                  Your guess (monthly rent):
                </label>
                <div className="flex gap-3">
                  <div className="flex-1 relative">
                    <span className="absolute left-4 top-1/2 -translate-y-1/2 text-white/60 text-lg">
                      $
                    </span>
                    <input
                      type="number"
                      value={guess}
                      onChange={(e) => setGuess(e.target.value)}
                      placeholder="2500"
                      className="w-full pl-8 pr-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white text-lg focus:outline-none focus:border-primary transition-all"
                    />
                  </div>
                  <button
                    onClick={handleSubmitGuess}
                    disabled={!guess}
                    className="px-6 py-3 bg-gradient-to-r from-green-500 to-emerald-500 rounded-xl text-white font-semibold hover:opacity-90 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    Guess
                  </button>
                </div>
              </div>
            )}

            {/* Result */}
            {showResult && (
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="space-y-4 pt-4 border-t border-white/10"
              >
                {/* Score */}
                <div className="grid grid-cols-2 gap-4">
                  <div className="glass-medium rounded-lg p-4 border border-green-500/30 bg-green-500/10">
                    <div className="flex items-center gap-2 mb-1">
                      <Award className="w-5 h-5 text-green-400" />
                      <span className="text-sm text-green-300">Points Earned</span>
                    </div>
                    <p className="text-3xl font-bold text-green-400">+{points}</p>
                  </div>

                  <div className="glass-medium rounded-lg p-4 border border-cyan-500/30 bg-cyan-500/10">
                    <div className="flex items-center gap-2 mb-1">
                      <Target className="w-5 h-5 text-cyan-400" />
                      <span className="text-sm text-cyan-300">Accuracy</span>
                    </div>
                    <p className="text-3xl font-bold text-cyan-400">{accuracy}%</p>
                  </div>
                </div>

                {/* Comparison */}
                <div className="glass-medium rounded-lg p-4 border border-white/10">
                  <div className="grid grid-cols-2 gap-4 text-center">
                    <div>
                      <p className="text-xs text-white/60 mb-1">Your Guess</p>
                      <p className="text-xl font-bold text-white">${parseInt(guess).toLocaleString()}</p>
                    </div>
                    <div>
                      <p className="text-xs text-white/60 mb-1">Actual Price</p>
                      <p className="text-xl font-bold text-green-400">
                        ${currentListing.price?.toLocaleString()}
                      </p>
                    </div>
                  </div>
                  <div className="mt-3 pt-3 border-t border-white/10">
                    <p className="text-sm text-white/60 text-center">
                      Difference: ${Math.abs(parseInt(guess) - (currentListing.price || 0)).toLocaleString()}
                    </p>
                  </div>
                </div>

                {/* Next Button */}
                <button
                  onClick={handleNext}
                  className="w-full py-3 bg-gradient-to-r from-primary to-purple-500 rounded-xl text-white font-semibold hover:opacity-90 transition-all"
                >
                  Next Property
                </button>
              </motion.div>
            )}
          </div>
        </motion.div>
      </div>
    </div>
  );
}
