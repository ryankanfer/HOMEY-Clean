'use client';

import { motion } from 'framer-motion';

interface MarketIntelligenceProps {
  neighborhoods?: string[];
  location?: string;
}

export default function MarketIntelligence({
  neighborhoods = [],
  location = 'New York',
}: MarketIntelligenceProps) {
  // Mock data - in production, fetch from API
  const marketData = {
    newListings: 23,
    avgPriceChange: -150,
    competition: 'high', // low, medium, high
    daysOnMarket: 12,
    neighborhood: neighborhoods[0] || location,
  };

  const getCompetitionIndicator = () => {
    switch (marketData.competition) {
      case 'high':
        return { emoji: '🔥', label: 'High Demand', color: 'text-red-400' };
      case 'medium':
        return { emoji: '⚡', label: 'Moderate', color: 'text-yellow-400' };
      default:
        return { emoji: '✅', label: 'Low Competition', color: 'text-green-400' };
    }
  };

  const competition = getCompetitionIndicator();

  return (
    <motion.div
      className="px-5 mb-8"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: 0.3 }}
    >
      <div className="max-w-4xl mx-auto">
        <div className="glass-strong rounded-3xl p-6 md:p-8 border border-white/10">
          {/* Header */}
          <div className="flex items-center gap-3 mb-6">
            <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-blue-500 to-cyan-500 flex items-center justify-center text-2xl shadow-lg">
              📊
            </div>
            <div>
              <h3 className="text-xl font-bold text-white">
                Market Update
              </h3>
              <p className="text-white/60 text-sm">
                {marketData.neighborhood}
              </p>
            </div>
          </div>

          {/* Stats Grid */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
            {/* New Listings */}
            <div className="bg-white/5 rounded-xl p-4 border border-white/10">
              <div className="text-2xl font-bold text-white mb-1">
                {marketData.newListings}
              </div>
              <div className="text-white/60 text-xs">
                New this week
              </div>
            </div>

            {/* Price Change */}
            <div className="bg-white/5 rounded-xl p-4 border border-white/10">
              <div className="flex items-center gap-1 mb-1">
                <span className="text-2xl font-bold text-white">
                  {marketData.avgPriceChange > 0 ? '+' : ''}${Math.abs(marketData.avgPriceChange)}
                </span>
                <span className={marketData.avgPriceChange > 0 ? 'text-red-400' : 'text-green-400'}>
                  {marketData.avgPriceChange > 0 ? '↑' : '↓'}
                </span>
              </div>
              <div className="text-white/60 text-xs">
                Avg price change
              </div>
            </div>

            {/* Competition */}
            <div className="bg-white/5 rounded-xl p-4 border border-white/10">
              <div className="flex items-center gap-2 mb-1">
                <span className="text-2xl">{competition.emoji}</span>
                <span className={`text-sm font-bold ${competition.color}`}>
                  {competition.label}
                </span>
              </div>
              <div className="text-white/60 text-xs">
                Competition
              </div>
            </div>

            {/* Days on Market */}
            <div className="bg-white/5 rounded-xl p-4 border border-white/10">
              <div className="text-2xl font-bold text-white mb-1">
                {marketData.daysOnMarket}
              </div>
              <div className="text-white/60 text-xs">
                Avg days listed
              </div>
            </div>
          </div>

          {/* CTA */}
          <motion.a
            href="/search"
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            className="block text-center px-6 py-3 bg-gradient-to-r from-blue-500 to-cyan-500 rounded-xl text-white font-semibold shadow-lg shadow-blue-500/30"
          >
            See All {marketData.neighborhood} Homes →
          </motion.a>
        </div>
      </div>
    </motion.div>
  );
}
