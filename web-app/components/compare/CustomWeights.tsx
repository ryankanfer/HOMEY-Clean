'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { DollarSign, MapPin, Maximize2, Clock, Package, X, RotateCcw } from 'lucide-react';

interface UserWeights {
  price: number;
  location: number;
  space: number;
  commute: number;
  amenities: number;
}

interface CustomWeightsProps {
  weights: UserWeights;
  onWeightsChange: (weights: UserWeights) => void;
  onClose: () => void;
}

const weightCategories = [
  {
    key: 'price' as keyof UserWeights,
    label: 'Price',
    description: 'Monthly rent and overall affordability',
    icon: DollarSign,
    color: 'text-green-400',
  },
  {
    key: 'location' as keyof UserWeights,
    label: 'Location',
    description: 'Walkability, transit access, and neighborhood',
    icon: MapPin,
    color: 'text-blue-400',
  },
  {
    key: 'space' as keyof UserWeights,
    label: 'Space',
    description: 'Square footage, bedrooms, and bathrooms',
    icon: Maximize2,
    color: 'text-purple-400',
  },
  {
    key: 'commute' as keyof UserWeights,
    label: 'Commute',
    description: 'Travel time to your important locations',
    icon: Clock,
    color: 'text-orange-400',
  },
  {
    key: 'amenities' as keyof UserWeights,
    label: 'Amenities',
    description: 'Building features and included services',
    icon: Package,
    color: 'text-pink-400',
  },
];

export default function CustomWeights({ weights, onWeightsChange, onClose }: CustomWeightsProps) {
  const [localWeights, setLocalWeights] = useState(weights);

  const handleWeightChange = (key: keyof UserWeights, value: number) => {
    setLocalWeights(prev => ({
      ...prev,
      [key]: value,
    }));
  };

  const handleApply = () => {
    onWeightsChange(localWeights);
    onClose();
  };

  const handleReset = () => {
    const defaultWeights: UserWeights = {
      price: 1,
      location: 1,
      space: 1,
      commute: 1,
      amenities: 1,
    };
    setLocalWeights(defaultWeights);
  };

  const totalWeight = Object.values(localWeights).reduce((sum, w) => sum + w, 0);

  return (
    <motion.div
      initial={{ opacity: 0, height: 0 }}
      animate={{ opacity: 1, height: 'auto' }}
      exit={{ opacity: 0, height: 0 }}
      className="mt-6 relative overflow-hidden rounded-3xl bg-gradient-to-br from-primary/10 via-purple-600/10 to-pink-500/10 border border-primary/30"
    >
      {/* Animated blur effect */}
      <div className="absolute top-0 right-0 w-48 h-48 bg-primary/20 rounded-full blur-3xl opacity-50 animate-pulse" />

      <div className="relative z-10 p-8">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="text-2xl md:text-3xl font-bold text-white">What Matters Most?</h3>
            <p className="text-base text-white/60 mt-2">
              Adjust priorities to recalculate rankings
            </p>
          </div>
          <button
            onClick={onClose}
            className="w-10 h-10 rounded-full glass-medium flex items-center justify-center hover:bg-white/10 transition-all"
          >
            <X className="w-5 h-5 text-white" />
          </button>
        </div>

        {/* Weight Sliders */}
        <div className="space-y-8 mb-8">
          {weightCategories.map((category) => {
            const Icon = category.icon;
            const weight = localWeights[category.key];
            const percentage = totalWeight > 0 ? (weight / totalWeight) * 100 : 0;

            return (
              <div key={category.key}>
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-3">
                    <div className={`w-10 h-10 rounded-xl bg-white/5 flex items-center justify-center ${category.color}`}>
                      <Icon className="w-5 h-5" />
                    </div>
                    <div>
                      <p className="text-base font-semibold text-white">{category.label}</p>
                      <p className="text-sm text-white/50">{category.description}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <span className="text-sm text-white/60">{percentage.toFixed(0)}%</span>
                    <span className={`text-xl font-bold ${category.color}`}>
                      {weight}x
                    </span>
                  </div>
                </div>

                {/* Slider */}
                <input
                  type="range"
                  min="0"
                  max="5"
                  step="0.5"
                  value={weight}
                  onChange={(e) => handleWeightChange(category.key, parseFloat(e.target.value))}
                  className="w-full h-2.5 bg-white/10 rounded-lg appearance-none cursor-pointer slider"
                  style={{
                    background: `linear-gradient(to right,
                      var(--tw-gradient-from) 0%,
                      var(--tw-gradient-from) ${(weight / 5) * 100}%,
                      rgba(255, 255, 255, 0.1) ${(weight / 5) * 100}%,
                      rgba(255, 255, 255, 0.1) 100%)`
                  }}
                />

                {/* Labels */}
                <div className="flex items-center justify-between mt-2">
                  <span className="text-xs text-white/40">Not Important</span>
                  <span className="text-xs text-white/40">Very Important</span>
                </div>
              </div>
            );
          })}
        </div>

        {/* Actions */}
        <div className="flex items-center gap-4">
          <button
            onClick={handleReset}
            className="flex-1 py-3.5 glass-medium rounded-2xl text-white hover:bg-white/10 transition-all flex items-center justify-center gap-2 font-medium"
          >
            <RotateCcw className="w-5 h-5" />
            Reset to Equal
          </button>
          <button
            onClick={handleApply}
            className="flex-1 py-3.5 bg-gradient-to-r from-primary to-purple-500 rounded-2xl text-white font-semibold hover:opacity-90 transition-all shadow-lg shadow-primary/20"
          >
            Apply & Recalculate
          </button>
        </div>

        {/* Info */}
        <div className="mt-6 p-4 bg-cyan-500/10 border border-cyan-500/30 rounded-2xl">
          <p className="text-sm text-cyan-300">
            💡 Rankings update based on your priorities. Set a weight to 0 to exclude it entirely.
          </p>
        </div>
      </div>

      <style jsx>{`
        .slider::-webkit-slider-thumb {
          appearance: none;
          width: 24px;
          height: 24px;
          border-radius: 50%;
          background: linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%);
          cursor: pointer;
          border: 3px solid white;
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
        }

        .slider::-moz-range-thumb {
          width: 24px;
          height: 24px;
          border-radius: 50%;
          background: linear-gradient(135deg, #8b5cf6 0%, #ec4899 100%);
          cursor: pointer;
          border: 3px solid white;
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
        }
      `}</style>
    </motion.div>
  );
}
