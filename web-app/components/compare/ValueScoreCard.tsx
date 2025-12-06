'use client';

import { motion } from 'framer-motion';
import { Award, TrendingUp } from 'lucide-react';
import type { Listing } from '@/lib/types';

interface ValueScoreCardProps {
  listing: Listing;
  score: number;
  rank: number;
  isWinner: boolean;
}

export default function ValueScoreCard({ listing, score, rank, isWinner }: ValueScoreCardProps) {
  const getScoreColor = (score: number) => {
    if (score >= 80) return 'text-green-400';
    if (score >= 60) return 'text-yellow-400';
    return 'text-orange-400';
  };

  const getScoreGradient = (score: number) => {
    if (score >= 80) return 'from-green-500 to-emerald-500';
    if (score >= 60) return 'from-yellow-500 to-orange-500';
    return 'from-orange-500 to-red-500';
  };

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ delay: rank * 0.1 }}
      className={`relative overflow-hidden rounded-3xl p-6 border ${
        isWinner
          ? 'border-yellow-500/50 bg-gradient-to-br from-yellow-500/10 to-orange-500/10'
          : 'bg-gradient-to-br from-primary/10 via-purple-600/10 to-pink-500/10 border-white/10'
      }`}
    >
      {/* Animated blur effect */}
      <div className="absolute top-0 right-0 w-32 h-32 bg-primary/20 rounded-full blur-3xl opacity-50 animate-pulse" />

      {/* Rank Badge */}
      <div className="absolute -top-2 -left-2 w-10 h-10 rounded-full bg-gradient-to-br from-primary to-purple-500 flex items-center justify-center border-2 border-white/20 z-10">
        <span className="text-base font-bold text-white">#{rank}</span>
      </div>

      {/* Winner Badge */}
      {isWinner && (
        <div className="absolute -top-2 -right-2 z-10">
          <div className="relative">
            <Award className="w-10 h-10 text-yellow-500 fill-yellow-500/20" />
            <motion.div
              animate={{
                scale: [1, 1.2, 1],
                rotate: [0, 5, -5, 0],
              }}
              transition={{
                duration: 2,
                repeat: Infinity,
                repeatType: 'loop',
              }}
              className="absolute inset-0"
            >
              <Award className="w-10 h-10 text-yellow-400 fill-yellow-400/30" />
            </motion.div>
          </div>
        </div>
      )}

      <div className="relative z-10">
        <div className="flex items-start justify-between mb-4">
          <div className="flex-1">
            <p className="text-sm text-white/50 mb-2">
              {listing.neighborhood}
            </p>
            <p className="text-white font-semibold text-base line-clamp-1">
              {listing.address}
            </p>
          </div>
        </div>

        {/* Value Score */}
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <TrendingUp className={`w-5 h-5 ${getScoreColor(score)}`} />
            <span className="text-sm text-white/60">Value Score</span>
          </div>

          <div className="flex items-baseline gap-1">
            <span className={`text-4xl md:text-5xl font-bold ${getScoreColor(score)}`}>
              {score}
            </span>
            <span className="text-sm text-white/40">/100</span>
          </div>
        </div>

        {/* Progress Bar */}
        <div className="mb-4 h-2.5 bg-white/10 rounded-full overflow-hidden">
          <motion.div
            initial={{ width: 0 }}
            animate={{ width: `${score}%` }}
            transition={{ duration: 1, delay: rank * 0.1 + 0.3 }}
            className={`h-full bg-gradient-to-r ${getScoreGradient(score)}`}
          />
        </div>

        {/* Quick Stats */}
        <div className="pt-4 border-t border-white/10 flex items-center justify-between text-sm text-white/60">
          <span className="font-semibold text-white">${listing.price?.toLocaleString()}/mo</span>
          <span>•</span>
          <span>{listing.bedrooms} bed</span>
          <span>•</span>
          <span>{listing.bathrooms} bath</span>
        </div>
      </div>
    </motion.div>
  );
}
