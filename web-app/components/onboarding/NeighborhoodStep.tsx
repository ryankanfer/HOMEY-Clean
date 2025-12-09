'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';
import { Plus } from 'lucide-react';

interface NeighborhoodStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

// Neighborhoods by city
const neighborhoodsByCity: Record<string, string[]> = {
  new_york_city: [
    'Upper East Side', 'Upper West Side', 'Greenwich Village', 'SoHo',
    'Tribeca', 'Chelsea', 'Hell\'s Kitchen', 'Murray Hill', 'Midtown',
    'Lower East Side', 'East Village', 'West Village', 'Financial District',
    'Battery Park City', 'Williamsburg', 'Brooklyn Heights', 'Park Slope',
    'DUMBO', 'Long Island City', 'Astoria',
  ],
  chicago: [
    'Lincoln Park', 'Lakeview', 'Wicker Park', 'Logan Square',
    'River North', 'Gold Coast', 'Loop', 'West Loop', 'Streeterville',
    'Old Town', 'Bucktown', 'Ukrainian Village', 'Pilsen', 'Hyde Park',
    'South Loop', 'Near North Side', 'Andersonville', 'Lincoln Square',
  ],
  los_angeles: [
    'Santa Monica', 'Venice', 'Beverly Hills', 'West Hollywood',
    'Silver Lake', 'Los Feliz', 'Echo Park', 'Downtown LA', 'Arts District',
    'Koreatown', 'Mid-Wilshire', 'Culver City', 'Mar Vista', 'Westwood',
    'Brentwood', 'Pacific Palisades', 'Manhattan Beach', 'Pasadena',
  ],
  miami: [
    'Brickell', 'Wynwood', 'Design District', 'Coconut Grove',
    'Coral Gables', 'South Beach', 'Mid-Beach', 'North Beach',
    'Edgewater', 'Downtown Miami', 'Little Havana', 'Aventura',
    'Sunny Isles Beach', 'Key Biscayne', 'Miami Beach', 'Bal Harbour',
  ],
};

export default function NeighborhoodStep({ data, onNext, isSaving }: NeighborhoodStepProps) {
  const [selected, setSelected] = useState<string[]>(data.neighborhoods || []);
  const [showCustomInput, setShowCustomInput] = useState(false);
  const [customInput, setCustomInput] = useState('');

  const cityNeighborhoods = data.location ? neighborhoodsByCity[data.location] || [] : [];

  const toggleNeighborhood = (neighborhood: string) => {
    if (selected.includes(neighborhood)) {
      setSelected(selected.filter(n => n !== neighborhood));
    } else {
      setSelected([...selected, neighborhood]);
    }
  };

  const handleAddCustom = () => {
    if (customInput.trim()) {
      setSelected([...selected, customInput.trim()]);
      setCustomInput('');
      setShowCustomInput(false);
    }
  };

  const handleContinue = () => {
    onNext({ neighborhoods: selected });
  };

  const handleSkip = () => {
    onNext({ neighborhoods: [] });
  };

  return (
    <motion.div
      initial={{ opacity: 0, x: 50 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -50 }}
      transition={{ duration: 0.5 }}
      className="w-full max-w-3xl mx-auto"
    >
      {/* Question */}
      <motion.h2
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.1, duration: 0.5 }}
        className="text-4xl md:text-5xl font-light text-white text-center mb-4"
        style={{ fontFamily: 'Playfair Display, serif' }}
      >
        Any neighborhood preferences?
      </motion.h2>

      <motion.p
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        className="text-white/60 text-center mb-8 text-lg"
      >
        Select as many as you'd like
      </motion.p>

      {/* Neighborhood Grid */}
      <motion.div
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.3, duration: 0.5 }}
        className="mb-6"
      >
        <div className="flex flex-wrap gap-3 justify-center max-h-96 overflow-y-auto px-4 py-2">
          {cityNeighborhoods.map((neighborhood, index) => (
            <motion.button
              key={neighborhood}
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: 0.05 * index, duration: 0.3 }}
              onClick={() => toggleNeighborhood(neighborhood)}
              className={`px-5 py-2.5 rounded-full font-medium text-sm transition-all ${
                selected.includes(neighborhood)
                  ? 'bg-gradient-to-r from-primary to-purple-500 text-white shadow-lg shadow-primary/30'
                  : 'bg-white/10 text-white/80 hover:bg-white/20 border border-white/20'
              }`}
            >
              {neighborhood}
            </motion.button>
          ))}

          {/* Add Custom Button */}
          {!showCustomInput && (
            <motion.button
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: 0.05 * cityNeighborhoods.length }}
              onClick={() => setShowCustomInput(true)}
              className="px-5 py-2.5 rounded-full font-medium text-sm bg-white/5 text-white/60 hover:bg-white/10 border border-dashed border-white/30 flex items-center gap-2 transition-all"
            >
              <Plus className="w-4 h-4" />
              Add custom
            </motion.button>
          )}
        </div>

        {/* Custom Input */}
        {showCustomInput && (
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="mt-4 flex gap-2"
          >
            <input
              type="text"
              value={customInput}
              onChange={(e) => setCustomInput(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && handleAddCustom()}
              placeholder="Enter custom neighborhood..."
              className="flex-1 px-4 py-2 bg-white/10 border border-white/20 rounded-xl text-white placeholder:text-white/40 focus:outline-none focus:border-primary/50"
              autoFocus
            />
            <button
              onClick={handleAddCustom}
              className="px-4 py-2 bg-primary hover:bg-primary/90 text-white rounded-xl font-semibold transition-colors"
            >
              Add
            </button>
            <button
              onClick={() => {
                setShowCustomInput(false);
                setCustomInput('');
              }}
              className="px-4 py-2 bg-white/10 hover:bg-white/20 text-white rounded-xl font-semibold transition-colors"
            >
              Cancel
            </button>
          </motion.div>
        )}
      </motion.div>

      {/* Selected Neighborhoods Display */}
      {selected.length > 0 && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="mb-6"
        >
          <p className="text-center text-white/60 text-sm mb-3">
            {selected.length} neighborhood{selected.length !== 1 ? 's' : ''} selected:
          </p>
          <div className="flex flex-wrap gap-2 justify-center">
            {selected.map((neighborhood) => (
              <div
                key={neighborhood}
                className="px-4 py-2 bg-gradient-to-r from-primary to-purple-500 text-white rounded-full text-sm font-medium flex items-center gap-2"
              >
                {neighborhood}
                <button
                  onClick={() => setSelected(selected.filter(n => n !== neighborhood))}
                  className="hover:bg-white/20 rounded-full p-0.5 transition-colors"
                >
                  ×
                </button>
              </div>
            ))}
          </div>
        </motion.div>
      )}

      {/* Buttons */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4, duration: 0.5 }}
        className="flex flex-col sm:flex-row gap-4 justify-center items-center"
      >
        <button
          onClick={handleSkip}
          disabled={isSaving}
          className="px-8 py-3 text-white/60 hover:text-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Skip for now
        </button>

        <button
          onClick={handleContinue}
          disabled={isSaving}
          className="px-10 py-4 bg-white text-black rounded-full font-bold text-lg hover:shadow-2xl hover:shadow-white/20 transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {isSaving ? 'Saving...' : selected.length > 0 ? 'Continue →' : 'Open to all →'}
        </button>
      </motion.div>

      {/* Helper text */}
      <motion.p
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.5, duration: 0.5 }}
        className="text-white/40 text-sm text-center mt-6"
      >
        Don't worry, you can always refine this later
      </motion.p>
    </motion.div>
  );
}
