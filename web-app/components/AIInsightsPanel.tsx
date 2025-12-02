'use client';

import { motion } from 'framer-motion';
import { UserPreferences } from '@/lib/preferences';

interface AIInsightsPanelProps {
  preferences: UserPreferences | null;
  newMatchesCount?: number;
}

export default function AIInsightsPanel({
  preferences,
  newMatchesCount = 0,
}: AIInsightsPanelProps) {
  const learnedPrefs = preferences?.learnedPreferences;
  const hasSwipeData = preferences?.hasSwipeData;

  // Extract insights from learned preferences
  const getInsights = () => {
    if (!hasSwipeData || !learnedPrefs) {
      return {
        message: "Start swiping to help Scout learn your preferences!",
        details: [],
        matchCount: 0,
      };
    }

    const details: string[] = [];

    // Budget insights
    if (learnedPrefs.avgPriceLiked) {
      details.push(`Around $${learnedPrefs.avgPriceLiked.toLocaleString()}/mo`);
    }

    // Bedroom preference
    if (learnedPrefs.preferredBedrooms) {
      details.push(`${learnedPrefs.preferredBedrooms} bedroom${learnedPrefs.preferredBedrooms > 1 ? 's' : ''}`);
    }

    // Neighborhood preferences
    if (learnedPrefs.preferredNeighborhoods && learnedPrefs.preferredNeighborhoods.length > 0) {
      const topNeighborhoods = learnedPrefs.preferredNeighborhoods.slice(0, 2);
      details.push(topNeighborhoods.join(', '));
    }

    // Property type preferences
    if (learnedPrefs.preferredPropertyTypes && learnedPrefs.preferredPropertyTypes.length > 0) {
      const types = learnedPrefs.preferredPropertyTypes.slice(0, 2);
      details.push(types.map(t => t.charAt(0).toUpperCase() + t.slice(1)).join(', '));
    }

    // Engagement stats
    const totalSwipes = learnedPrefs.totalSwipes || 0;
    const totalLikes = learnedPrefs.totalLikes || 0;
    const totalLoves = learnedPrefs.totalLoves || 0;

    return {
      message: "You tend to save properties with:",
      details,
      stats: {
        swipes: totalSwipes,
        likes: totalLikes,
        loves: totalLoves,
      },
      matchCount: newMatchesCount,
    };
  };

  const insights = getInsights();

  if (!hasSwipeData) {
    return (
      <motion.div
        className="px-5 mb-8"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.2 }}
      >
        <div className="max-w-4xl mx-auto">
          <div className="glass-strong rounded-3xl p-6 md:p-8 border border-white/10 text-center">
            <div className="text-5xl mb-4">🔮</div>
            <h3 className="text-xl font-bold text-white mb-2">
              Scout is Ready to Learn
            </h3>
            <p className="text-white/60 text-sm md:text-base mb-6">
              Swipe on properties to train Scout's AI. The more you swipe, the better the recommendations!
            </p>
            <motion.a
              href="/matchmaker"
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="inline-flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-purple-500 to-pink-500 rounded-xl text-white font-semibold shadow-lg shadow-purple-500/30"
            >
              Start Swiping
              <span>→</span>
            </motion.a>
          </div>
        </div>
      </motion.div>
    );
  }

  return (
    <motion.div
      className="px-5 mb-8"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: 0.2 }}
    >
      <div className="max-w-4xl mx-auto">
        <div className="glass-strong rounded-3xl p-6 md:p-8 border border-white/10">
          {/* Header */}
          <div className="flex items-center gap-3 mb-6">
            <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-2xl shadow-lg">
              🔮
            </div>
            <div>
              <h3 className="text-xl font-bold text-white">
                Scout's Insights
              </h3>
              <p className="text-white/60 text-sm">
                Based on {insights.stats?.swipes || 0} swipes
              </p>
            </div>
          </div>

          {/* Insights */}
          <div className="mb-6">
            <p className="text-white/80 text-sm md:text-base mb-3">
              {insights.message}
            </p>

            {insights.details.length > 0 && (
              <ul className="space-y-2">
                {insights.details.map((detail, index) => (
                  <motion.li
                    key={index}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.1 }}
                    className="flex items-center gap-2 text-white/70 text-sm md:text-base"
                  >
                    <span className="text-primary">•</span>
                    {detail}
                  </motion.li>
                ))}
              </ul>
            )}
          </div>

          {/* Match count */}
          {insights.matchCount > 0 && (
            <div className="pt-6 border-t border-white/10">
              <div className="flex items-center justify-between">
                <span className="text-white/70 text-sm">
                  New matches based on this:
                </span>
                <div className="flex items-center gap-2">
                  <span className="text-2xl font-bold text-primary">
                    {insights.matchCount}
                  </span>
                  <motion.a
                    href="/search"
                    whileHover={{ x: 3 }}
                    className="text-primary hover:text-primary/80 transition-colors"
                  >
                    View →
                  </motion.a>
                </div>
              </div>
            </div>
          )}

          {/* Stats Grid */}
          {insights.stats && (
            <div className="grid grid-cols-3 gap-4 mt-6 pt-6 border-t border-white/10">
              <div className="text-center">
                <div className="text-2xl font-bold text-white mb-1">
                  {insights.stats.swipes}
                </div>
                <div className="text-white/60 text-xs">Swipes</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-pink-400 mb-1">
                  {insights.stats.likes}
                </div>
                <div className="text-white/60 text-xs">Likes</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-purple-400 mb-1">
                  {insights.stats.loves}
                </div>
                <div className="text-white/60 text-xs">Loves</div>
              </div>
            </div>
          )}
        </div>
      </div>
    </motion.div>
  );
}
