'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import BottomSheet from './BottomSheet';

interface NeighborhoodDeepDiveProps {
  isOpen: boolean;
  onClose: () => void;
  neighborhoodName: string;
}

// Mock data - in production, fetch from API
const getNeighborhoodData = (name: string) => {
  // Mock data structure
  return {
    walkScore: 92,
    transitScore: 88,
    bikeScore: 75,
    safetyScore: 78,
    vibe: 'Vibrant and creative with excellent dining scene. Popular with young professionals and artists.',
    demographics: {
      medianAge: 32,
      diversity: 'High',
    },
    amenities: {
      cafes: [
        { name: 'Blue Bottle Coffee', distance: '0.2 mi', rating: 4.5 },
        { name: 'Stumptown Coffee', distance: '0.3 mi', rating: 4.7 },
        { name: 'The Local Cafe', distance: '0.4 mi', rating: 4.3 },
      ],
      groceries: [
        { name: 'Whole Foods', distance: '0.3 mi', rating: 4.4 },
        { name: 'Trader Joe\'s', distance: '0.5 mi', rating: 4.6 },
      ],
      gyms: [
        { name: 'Equinox', distance: '0.2 mi', rating: 4.5 },
        { name: 'Planet Fitness', distance: '0.6 mi', rating: 4.2 },
      ],
      restaurants: [
        { name: 'The Spotted Pig', distance: '0.1 mi', rating: 4.8 },
        { name: 'Momofuku Noodle Bar', distance: '0.3 mi', rating: 4.6 },
      ],
    },
    transit: {
      nearbyStations: [
        { name: 'Spring St Station', lines: ['6'], distance: '0.1 mi' },
        { name: 'Prince St Station', lines: ['N', 'R', 'W'], distance: '0.2 mi' },
      ],
    },
    highlights: [
      '🎨 Heart of the art gallery scene',
      '🍕 Best pizza in Manhattan',
      '🌃 Vibrant nightlife',
      '🏛️ Historic cast-iron architecture',
      '🛍️ High-end boutique shopping',
    ],
  };
};

export default function NeighborhoodDeepDive({
  isOpen,
  onClose,
  neighborhoodName,
}: NeighborhoodDeepDiveProps) {
  const [data, setData] = useState<ReturnType<typeof getNeighborhoodData> | null>(null);
  const [activeTab, setActiveTab] = useState<'overview' | 'amenities' | 'transit'>('overview');

  useEffect(() => {
    if (isOpen) {
      // Simulate API fetch
      setData(getNeighborhoodData(neighborhoodName));
    }
  }, [isOpen, neighborhoodName]);

  if (!data) return null;

  const ScoreCircle = ({ score, label, color }: { score: number; label: string; color: string }) => (
    <div className="flex flex-col items-center">
      <div className="relative w-24 h-24">
        {/* Background circle */}
        <svg className="w-24 h-24 transform -rotate-90">
          <circle
            cx="48"
            cy="48"
            r="40"
            stroke="currentColor"
            strokeWidth="8"
            fill="none"
            className="text-white/10"
          />
          <circle
            cx="48"
            cy="48"
            r="40"
            stroke={color}
            strokeWidth="8"
            fill="none"
            strokeDasharray={`${2 * Math.PI * 40}`}
            strokeDashoffset={`${2 * Math.PI * 40 * (1 - score / 100)}`}
            className="transition-all duration-1000"
          />
        </svg>
        <div className="absolute inset-0 flex items-center justify-center">
          <span className="text-2xl font-bold text-white">{score}</span>
        </div>
      </div>
      <p className="text-white/70 text-sm mt-2">{label}</p>
    </div>
  );

  return (
    <BottomSheet isOpen={isOpen} onClose={onClose} title={neighborhoodName} height="full">
      <div className="space-y-6">
        {/* Tabs */}
        <div className="sticky top-0 bg-gradient-to-b from-gray-900 to-transparent z-10 px-6 pt-4 pb-2">
          <div className="flex gap-2">
            {(['overview', 'amenities', 'transit'] as const).map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab)}
                className={`px-4 py-2 rounded-full text-sm font-medium transition-all min-h-[44px] ${
                  activeTab === tab
                    ? 'bg-primary text-white'
                    : 'bg-white/10 text-white/60 hover:bg-white/20'
                }`}
              >
                {tab.charAt(0).toUpperCase() + tab.slice(1)}
              </button>
            ))}
          </div>
        </div>

        <div className="px-6 pb-6">
          {/* Overview Tab */}
          {activeTab === 'overview' && (
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              className="space-y-6"
            >
              {/* Scores */}
              <div>
                <h3 className="text-lg font-bold text-white mb-4">Livability Scores</h3>
                <div className="grid grid-cols-3 gap-4">
                  <ScoreCircle score={data.walkScore} label="Walk Score" color="#10b981" />
                  <ScoreCircle score={data.transitScore} label="Transit" color="#3b82f6" />
                  <ScoreCircle score={data.bikeScore} label="Bike Score" color="#f59e0b" />
                </div>
              </div>

              {/* Safety */}
              <div className="glass-strong rounded-2xl p-4 border border-white/10">
                <div className="flex items-center justify-between">
                  <span className="text-white/70">Safety Score</span>
                  <div className="flex items-center gap-2">
                    <div className="w-32 h-2 bg-white/10 rounded-full overflow-hidden">
                      <div
                        className="h-full bg-gradient-to-r from-green-500 to-emerald-500 transition-all duration-1000"
                        style={{ width: `${data.safetyScore}%` }}
                      />
                    </div>
                    <span className="text-white font-bold">{data.safetyScore}</span>
                  </div>
                </div>
              </div>

              {/* Vibe */}
              <div>
                <h3 className="text-lg font-bold text-white mb-3">Neighborhood Vibe</h3>
                <p className="text-white/70 leading-relaxed">{data.vibe}</p>
              </div>

              {/* Highlights */}
              <div>
                <h3 className="text-lg font-bold text-white mb-3">Highlights</h3>
                <div className="space-y-2">
                  {data.highlights.map((highlight, idx) => (
                    <div key={idx} className="flex items-start gap-3 text-white/70">
                      <span className="text-lg">{highlight.split(' ')[0]}</span>
                      <span>{highlight.split(' ').slice(1).join(' ')}</span>
                    </div>
                  ))}
                </div>
              </div>
            </motion.div>
          )}

          {/* Amenities Tab */}
          {activeTab === 'amenities' && (
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              className="space-y-6"
            >
              {/* Cafes */}
              <AmenitySection title="☕ Cafes" items={data.amenities.cafes} />

              {/* Groceries */}
              <AmenitySection title="🛒 Groceries" items={data.amenities.groceries} />

              {/* Gyms */}
              <AmenitySection title="💪 Gyms" items={data.amenities.gyms} />

              {/* Restaurants */}
              <AmenitySection title="🍽️ Restaurants" items={data.amenities.restaurants} />
            </motion.div>
          )}

          {/* Transit Tab */}
          {activeTab === 'transit' && (
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              className="space-y-6"
            >
              <div>
                <h3 className="text-lg font-bold text-white mb-4">Nearby Stations</h3>
                <div className="space-y-3">
                  {data.transit.nearbyStations.map((station, idx) => (
                    <div
                      key={idx}
                      className="glass-strong rounded-xl p-4 border border-white/10"
                    >
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-white font-semibold">{station.name}</span>
                        <span className="text-white/60 text-sm">{station.distance}</span>
                      </div>
                      <div className="flex gap-2">
                        {station.lines.map((line) => (
                          <span
                            key={line}
                            className="px-2 py-1 bg-primary/20 border border-primary/40 rounded text-primary text-sm font-bold"
                          >
                            {line}
                          </span>
                        ))}
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              <div className="glass-strong rounded-2xl p-4 border border-white/10">
                <div className="flex items-center gap-3 text-white/70">
                  <span className="text-2xl">🚇</span>
                  <div>
                    <p className="text-white font-semibold">Excellent Transit Access</p>
                    <p className="text-sm">Multiple subway lines within walking distance</p>
                  </div>
                </div>
              </div>
            </motion.div>
          )}
        </div>
      </div>
    </BottomSheet>
  );
}

function AmenitySection({
  title,
  items,
}: {
  title: string;
  items: Array<{ name: string; distance: string; rating: number }>;
}) {
  return (
    <div>
      <h3 className="text-lg font-bold text-white mb-3">{title}</h3>
      <div className="space-y-2">
        {items.map((item, idx) => (
          <div
            key={idx}
            className="glass-strong rounded-xl p-3 border border-white/10 flex items-center justify-between"
          >
            <div>
              <p className="text-white font-medium">{item.name}</p>
              <p className="text-white/60 text-sm">{item.distance} away</p>
            </div>
            <div className="flex items-center gap-1">
              <span className="text-yellow-400">⭐</span>
              <span className="text-white font-semibold">{item.rating}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
