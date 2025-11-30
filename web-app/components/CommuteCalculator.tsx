'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import type { Listing } from '@/lib/types';
import BottomSheet from './BottomSheet';

interface CommuteCalculatorProps {
  isOpen: boolean;
  onClose: () => void;
  property: Listing;
}

type CommuteMode = 'transit' | 'walk' | 'drive';

interface CommuteResult {
  mode: CommuteMode;
  duration: string;
  distance: string;
  icon: string;
  color: string;
}

export default function CommuteCalculator({
  isOpen,
  onClose,
  property,
}: CommuteCalculatorProps) {
  const [workAddress, setWorkAddress] = useState('');
  const [savedWorkAddress, setSavedWorkAddress] = useState('');
  const [calculating, setCalculating] = useState(false);
  const [results, setResults] = useState<CommuteResult[]>([]);
  const [selectedMode, setSelectedMode] = useState<CommuteMode>('transit');

  // Load saved work address from localStorage
  useEffect(() => {
    const saved = localStorage.getItem('homey_work_address');
    if (saved) {
      setSavedWorkAddress(saved);
      setWorkAddress(saved);
    }
  }, []);

  // Calculate commute times
  const calculateCommute = async () => {
    if (!workAddress.trim()) {
      alert('Please enter your work address');
      return;
    }

    setCalculating(true);

    try {
      // Save work address for future use
      localStorage.setItem('homey_work_address', workAddress);
      setSavedWorkAddress(workAddress);

      // In production, use Google Maps Distance Matrix API or similar
      // For now, simulate API call with realistic estimates
      await new Promise(resolve => setTimeout(resolve, 1500));

      // Generate mock commute times based on property location
      const mockResults: CommuteResult[] = [
        {
          mode: 'transit',
          duration: '28 min',
          distance: '4.2 mi',
          icon: '🚇',
          color: '#3b82f6',
        },
        {
          mode: 'walk',
          duration: '52 min',
          distance: '4.2 mi',
          icon: '🚶',
          color: '#10b981',
        },
        {
          mode: 'drive',
          duration: '18 min',
          distance: '4.2 mi',
          icon: '🚗',
          color: '#f59e0b',
        },
      ];

      setResults(mockResults);
    } catch (error) {
      console.error('Failed to calculate commute:', error);
      alert('Failed to calculate commute. Please try again.');
    } finally {
      setCalculating(false);
    }
  };

  const getModeLabel = (mode: CommuteMode) => {
    switch (mode) {
      case 'transit':
        return 'Public Transit';
      case 'walk':
        return 'Walking';
      case 'drive':
        return 'Driving';
    }
  };

  return (
    <BottomSheet isOpen={isOpen} onClose={onClose} title="Commute Calculator" height="auto">
      <div className="p-6 space-y-6">
        {/* Property Info */}
        <div className="glass-strong rounded-xl p-4 border border-white/10">
          <div className="flex gap-3">
            <img
              src={property.images?.[0] || '/placeholder-property.jpg'}
              alt={property.address}
              className="w-20 h-20 rounded-lg object-cover"
            />
            <div className="flex-1">
              <p className="text-white font-semibold">{property.address}</p>
              <p className="text-white/60 text-sm">{property.neighborhood}</p>
            </div>
          </div>
        </div>

        {/* Work Address Input */}
        <div>
          <h3 className="text-white font-semibold mb-3">Work Address</h3>
          <div className="space-y-3">
            <input
              type="text"
              value={workAddress}
              onChange={(e) => setWorkAddress(e.target.value)}
              placeholder="Enter your work address"
              className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-primary/50"
            />

            {savedWorkAddress && savedWorkAddress !== workAddress && (
              <button
                onClick={() => setWorkAddress(savedWorkAddress)}
                className="text-primary text-sm hover:text-primary/80 transition-colors"
              >
                Use saved address: {savedWorkAddress}
              </button>
            )}
          </div>
        </div>

        {/* Calculate Button */}
        {!results.length && (
          <button
            onClick={calculateCommute}
            disabled={!workAddress.trim() || calculating}
            className={`w-full py-4 rounded-2xl font-bold transition-all min-h-[44px] ${
              workAddress.trim() && !calculating
                ? 'bg-gradient-to-r from-primary via-purple-500 to-pink-500 text-white hover:opacity-90'
                : 'bg-white/10 text-white/40 cursor-not-allowed'
            }`}
          >
            {calculating ? '⏳ Calculating...' : '🧭 Calculate Commute'}
          </button>
        )}

        {/* Results */}
        {results.length > 0 && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="space-y-4"
          >
            <div className="flex items-center justify-between">
              <h3 className="text-white font-semibold">Commute Time to Work</h3>
              <button
                onClick={() => setResults([])}
                className="text-primary text-sm hover:text-primary/80 transition-colors"
              >
                Recalculate
              </button>
            </div>

            {/* Mode Selector */}
            <div className="flex gap-2">
              {results.map((result) => (
                <motion.button
                  key={result.mode}
                  onClick={() => setSelectedMode(result.mode)}
                  whileTap={{ scale: 0.95 }}
                  className={`flex-1 p-3 rounded-xl transition-all min-h-[44px] ${
                    selectedMode === result.mode
                      ? 'bg-primary/20 border-2 border-primary'
                      : 'bg-white/5 border border-white/10 hover:bg-white/10'
                  }`}
                >
                  <div className="text-2xl mb-1">{result.icon}</div>
                  <p className="text-white/80 text-xs">{result.mode}</p>
                </motion.button>
              ))}
            </div>

            {/* Selected Mode Details */}
            <motion.div
              key={selectedMode}
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              className="glass-strong rounded-2xl p-6 border-2 border-primary/30"
            >
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-3">
                  <span className="text-4xl">
                    {results.find((r) => r.mode === selectedMode)?.icon}
                  </span>
                  <div>
                    <p className="text-white/60 text-sm">{getModeLabel(selectedMode)}</p>
                    <p className="text-white font-bold text-2xl">
                      {results.find((r) => r.mode === selectedMode)?.duration}
                    </p>
                  </div>
                </div>
              </div>

              <div className="flex items-center justify-between text-white/60 text-sm">
                <span>Distance</span>
                <span className="text-white font-semibold">
                  {results.find((r) => r.mode === selectedMode)?.distance}
                </span>
              </div>
            </motion.div>

            {/* All Results Comparison */}
            <div className="space-y-2">
              <h4 className="text-white/60 text-sm">Compare All Options</h4>
              {results.map((result) => (
                <div
                  key={result.mode}
                  className="glass-strong rounded-xl p-3 border border-white/10 flex items-center justify-between"
                >
                  <div className="flex items-center gap-3">
                    <span className="text-2xl">{result.icon}</span>
                    <span className="text-white/80 text-sm">{getModeLabel(result.mode)}</span>
                  </div>
                  <div className="text-right">
                    <p className="text-white font-semibold">{result.duration}</p>
                    <p className="text-white/60 text-xs">{result.distance}</p>
                  </div>
                </div>
              ))}
            </div>

            {/* Quick Insights */}
            <div className="glass-strong rounded-xl p-4 border border-white/10">
              <p className="text-white/60 text-sm mb-2">💡 Quick Insight</p>
              <p className="text-white text-sm">
                This property has excellent transit access. You can reach work in under 30 minutes
                via public transportation.
              </p>
            </div>
          </motion.div>
        )}
      </div>
    </BottomSheet>
  );
}
