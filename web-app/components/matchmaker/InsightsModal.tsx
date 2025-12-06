'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { X, TrendingUp, Heart, Sparkles, MapPin, DollarSign, Home, Award } from 'lucide-react';

interface SwipeInsight {
  type: 'neighborhood' | 'price' | 'features' | 'property_type' | 'bedrooms';
  title: string;
  description: string;
  count: number;
  icon: any;
  color: string;
}

interface PreferenceProfile {
  topNeighborhoods: Array<{ name: string; count: number }>;
  avgPrice: number;
  priceRange: { min: number; max: number };
  lovedFeatures: Array<{ feature: string; count: number }>;
  preferredBedrooms: number[];
  propertyTypes: Array<{ type: string; count: number }>;
}

interface InsightsModalProps {
  isOpen: boolean;
  onClose: () => void;
  totalSwipes: number;
  profile: PreferenceProfile;
  recentInsights: SwipeInsight[];
  onboardingPreferences?: {
    maxPrice: number;
    minBedrooms: number;
    neighborhoods: string[];
  };
}

export default function InsightsModal({
  isOpen,
  onClose,
  totalSwipes,
  profile,
  recentInsights,
  onboardingPreferences
}: InsightsModalProps) {
  const getYourType = () => {
    const topNeighborhood = profile.topNeighborhoods[0]?.name || 'various';
    const avgPriceFormatted = new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      maximumFractionDigits: 0,
    }).format(profile.avgPrice);
    const topType = profile.propertyTypes[0]?.type || 'apartments';
    const beds = profile.preferredBedrooms[0] || 1;

    return `${beds}BR ${topType} in ${topNeighborhood} around ${avgPriceFormatted}`;
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <motion.div
            key="insights-backdrop"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="absolute inset-0 bg-black/60 backdrop-blur-sm"
          />

          <motion.div
            key="insights-modal"
            initial={{ opacity: 0, scale: 0.9, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.9, y: 20 }}
            className="relative glass-strong rounded-2xl p-6 max-w-lg w-full border border-white/10 max-h-[85vh] overflow-y-auto"
          >
            {/* Header */}
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-gradient-to-br from-primary to-purple-500 rounded-xl flex items-center justify-center">
                  <Sparkles className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-white">Your Insights</h3>
                  <p className="text-xs text-white/60">{totalSwipes} swipes analyzed</p>
                </div>
              </div>
              <button
                onClick={onClose}
                className="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center text-white hover:bg-white/20 transition-all"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Homey Brain Connection */}
            {onboardingPreferences && (
              <div className="mb-6 p-4 bg-gradient-to-br from-cyan-500/10 to-blue-500/10 border border-cyan-500/30 rounded-xl">
                <div className="flex items-start gap-3 mb-3">
                  <div className="w-10 h-10 bg-gradient-to-br from-cyan-500 to-blue-500 rounded-lg flex items-center justify-center flex-shrink-0">
                    <Sparkles className="w-5 h-5 text-white" />
                  </div>
                  <div className="flex-1">
                    <h4 className="text-sm font-bold text-cyan-300 mb-1">Homey Brain Evolution</h4>
                    <p className="text-xs text-white/70">Here's how your preferences have evolved</p>
                  </div>
                </div>

                <div className="space-y-3">
                  {/* Price Evolution */}
                  <div className="flex items-start justify-between gap-4">
                    <div className="flex-1">
                      <p className="text-xs text-white/50 mb-1">Budget (Onboarding)</p>
                      <p className="text-sm text-white font-medium">Up to ${onboardingPreferences.maxPrice.toLocaleString()}/mo</p>
                    </div>
                    <div className="flex items-center">
                      <div className="w-8 border-t-2 border-dashed border-cyan-400/50" />
                      <TrendingUp className="w-4 h-4 text-cyan-400 mx-1" />
                      <div className="w-8 border-t-2 border-dashed border-cyan-400/50" />
                    </div>
                    <div className="flex-1 text-right">
                      <p className="text-xs text-cyan-300/80 mb-1">Actually Loving</p>
                      <p className="text-sm text-cyan-300 font-bold">~${Math.round(profile.avgPrice / 100) * 100}/mo</p>
                    </div>
                  </div>

                  {/* Neighborhood Evolution */}
                  {onboardingPreferences.neighborhoods.length > 0 && profile.topNeighborhoods.length > 0 && (
                    <div className="flex items-start justify-between gap-4 pt-3 border-t border-white/10">
                      <div className="flex-1">
                        <p className="text-xs text-white/50 mb-1">Areas (Onboarding)</p>
                        <p className="text-sm text-white font-medium">{onboardingPreferences.neighborhoods[0]}</p>
                      </div>
                      <div className="flex items-center">
                        <div className="w-8 border-t-2 border-dashed border-cyan-400/50" />
                        <TrendingUp className="w-4 h-4 text-cyan-400 mx-1" />
                        <div className="w-8 border-t-2 border-dashed border-cyan-400/50" />
                      </div>
                      <div className="flex-1 text-right">
                        <p className="text-xs text-cyan-300/80 mb-1">Top Pick</p>
                        <p className="text-sm text-cyan-300 font-bold">{profile.topNeighborhoods[0].name}</p>
                      </div>
                    </div>
                  )}

                  {/* Bedrooms Evolution */}
                  {onboardingPreferences.minBedrooms > 0 && profile.preferredBedrooms.length > 0 && (
                    <div className="flex items-start justify-between gap-4 pt-3 border-t border-white/10">
                      <div className="flex-1">
                        <p className="text-xs text-white/50 mb-1">Bedrooms (Onboarding)</p>
                        <p className="text-sm text-white font-medium">{onboardingPreferences.minBedrooms}+ bed</p>
                      </div>
                      <div className="flex items-center">
                        <div className="w-8 border-t-2 border-dashed border-cyan-400/50" />
                        <TrendingUp className="w-4 h-4 text-cyan-400 mx-1" />
                        <div className="w-8 border-t-2 border-dashed border-cyan-400/50" />
                      </div>
                      <div className="flex-1 text-right">
                        <p className="text-xs text-cyan-300/80 mb-1">Preferred</p>
                        <p className="text-sm text-cyan-300 font-bold">{profile.preferredBedrooms[0]} bed</p>
                      </div>
                    </div>
                  )}
                </div>

                <div className="mt-3 pt-3 border-t border-cyan-500/20">
                  <p className="text-xs text-cyan-300/80">
                    ✨ We're learning from your behavior to find better matches
                  </p>
                </div>
              </div>
            )}

            {/* Your Type Summary */}
            <div className="mb-6 p-4 bg-gradient-to-br from-primary/20 to-purple-500/20 border border-primary/30 rounded-xl">
              <div className="flex items-start gap-3">
                <div className="w-10 h-10 bg-gradient-to-br from-primary to-purple-500 rounded-lg flex items-center justify-center flex-shrink-0">
                  <Award className="w-5 h-5 text-white" />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-semibold text-primary mb-1">Your Type</p>
                  <p className="text-white font-medium">{getYourType()}</p>
                  <p className="text-white/60 text-xs mt-2">
                    Based on your {totalSwipes} swipes, we've learned what you love!
                  </p>
                </div>
              </div>
            </div>

            {/* Recent Insights */}
            {recentInsights.length > 0 && (
              <div className="mb-6">
                <h4 className="text-sm font-semibold text-white/80 mb-3">Recent Discoveries</h4>
                <div className="space-y-2">
                  {recentInsights.map((insight, index) => {
                    const Icon = insight.icon;
                    return (
                      <motion.div
                        key={index}
                        initial={{ opacity: 0, x: -20 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: index * 0.1 }}
                        className={`p-3 glass-medium rounded-lg border ${insight.color} flex items-start gap-3`}
                      >
                        <div className={`w-8 h-8 rounded-lg ${insight.color.replace('border-', 'bg-').replace('/30', '/20')} flex items-center justify-center flex-shrink-0`}>
                          <Icon className="w-4 h-4 text-white" />
                        </div>
                        <div className="flex-1">
                          <p className="text-white text-sm font-medium">{insight.title}</p>
                          <p className="text-white/60 text-xs mt-1">{insight.description}</p>
                        </div>
                      </motion.div>
                    );
                  })}
                </div>
              </div>
            )}

            {/* Preference Breakdown */}
            <div className="space-y-4">
              <h4 className="text-sm font-semibold text-white/80">Preference Breakdown</h4>

              {/* Top Neighborhoods */}
              {profile.topNeighborhoods.length > 0 && (
                <div className="glass-medium rounded-lg p-4 border border-white/10">
                  <div className="flex items-center gap-2 mb-3">
                    <MapPin className="w-4 h-4 text-primary" />
                    <p className="text-sm font-medium text-white">Favorite Neighborhoods</p>
                  </div>
                  <div className="space-y-2">
                    {profile.topNeighborhoods.slice(0, 3).map((neighborhood, index) => (
                      <div key={index} className="flex items-center justify-between">
                        <span className="text-white/80 text-sm">{neighborhood.name}</span>
                        <div className="flex items-center gap-2">
                          <div className="w-24 h-2 bg-white/10 rounded-full overflow-hidden">
                            <div
                              className="h-full bg-gradient-to-r from-primary to-purple-500 rounded-full"
                              style={{
                                width: `${(neighborhood.count / totalSwipes) * 100}%`
                              }}
                            />
                          </div>
                          <span className="text-white/60 text-xs w-8 text-right">
                            {neighborhood.count}
                          </span>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Price Range */}
              <div className="glass-medium rounded-lg p-4 border border-white/10">
                <div className="flex items-center gap-2 mb-3">
                  <DollarSign className="w-4 h-4 text-green-400" />
                  <p className="text-sm font-medium text-white">Price Sweet Spot</p>
                </div>
                <div className="flex items-baseline gap-2">
                  <span className="text-2xl font-bold text-white">
                    ${Math.round(profile.avgPrice / 100) * 100}
                  </span>
                  <span className="text-white/60 text-sm">avg/month</span>
                </div>
                {profile.priceRange.min > 0 && (
                  <p className="text-white/60 text-xs mt-2">
                    Range: ${profile.priceRange.min} - ${profile.priceRange.max}
                  </p>
                )}
              </div>

              {/* Loved Features */}
              {profile.lovedFeatures.length > 0 && (
                <div className="glass-medium rounded-lg p-4 border border-white/10">
                  <div className="flex items-center gap-2 mb-3">
                    <Heart className="w-4 h-4 text-pink-400" />
                    <p className="text-sm font-medium text-white">Must-Have Features</p>
                  </div>
                  <div className="flex flex-wrap gap-2">
                    {profile.lovedFeatures.slice(0, 6).map((feature, index) => (
                      <div
                        key={index}
                        className="px-3 py-1.5 bg-gradient-to-r from-pink-500/20 to-purple-500/20 border border-pink-500/30 rounded-full"
                      >
                        <span className="text-white/90 text-xs font-medium">
                          {feature.feature}
                        </span>
                        <span className="text-white/50 text-xs ml-1">({feature.count})</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Property Types */}
              {profile.propertyTypes.length > 0 && (
                <div className="glass-medium rounded-lg p-4 border border-white/10">
                  <div className="flex items-center gap-2 mb-3">
                    <Home className="w-4 h-4 text-blue-400" />
                    <p className="text-sm font-medium text-white">Property Types</p>
                  </div>
                  <div className="flex flex-wrap gap-2">
                    {profile.propertyTypes.map((type, index) => (
                      <div
                        key={index}
                        className="px-3 py-1.5 bg-white/5 border border-white/10 rounded-lg"
                      >
                        <span className="text-white/90 text-sm capitalize">{type.type}</span>
                        <span className="text-white/50 text-xs ml-2">×{type.count}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>

            {/* AI Prediction Teaser */}
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.5 }}
              className="mt-6 p-4 bg-gradient-to-br from-cyan-500/10 to-blue-500/10 border border-cyan-500/30 rounded-xl"
            >
              <div className="flex items-start gap-3">
                <TrendingUp className="w-5 h-5 text-cyan-400 flex-shrink-0 mt-0.5" />
                <div>
                  <p className="text-cyan-300 text-sm font-medium mb-1">AI Prediction</p>
                  <p className="text-white/80 text-xs">
                    Based on your swipes, we're finding more properties that match your taste.
                    Keep swiping to improve your recommendations!
                  </p>
                </div>
              </div>
            </motion.div>

            {/* Continue Button */}
            <button
              onClick={onClose}
              className="w-full mt-6 py-3 bg-gradient-to-r from-primary to-purple-500 rounded-xl text-white font-semibold hover:opacity-90 transition-all"
            >
              Continue Swiping
            </button>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
}
