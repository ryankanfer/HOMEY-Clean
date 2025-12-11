'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';
import { MapPin, Plus, X } from 'lucide-react';

interface NeighborhoodStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

// NYC neighborhoods organized by borough
const NYC_NEIGHBORHOODS = {
  'Manhattan': [
    'SoHo', 'West Village', 'Tribeca', 'Upper East Side', 'Upper West Side',
    'Hell\'s Kitchen', 'Midtown', 'Financial District', 'Chelsea', 'East Village',
    'Harlem', 'Greenwich Village', 'Murray Hill', 'Gramercy', 'NoHo'
  ],
  'Brooklyn': [
    'Williamsburg', 'DUMBO', 'Park Slope', 'Brooklyn Heights', 'Bushwick',
    'Greenpoint', 'Prospect Heights', 'Fort Greene', 'Crown Heights',
    'Carroll Gardens', 'Bed-Stuy', 'Cobble Hill', 'Boerum Hill'
  ],
  'Queens': [
    'Astoria', 'Long Island City', 'Flushing', 'Forest Hills', 'Sunnyside',
    'Jackson Heights', 'Elmhurst', 'Bayside', 'Ridgewood', 'Woodside'
  ],
  'Bronx': [
    'Riverdale', 'Fordham', 'Mott Haven', 'Concourse', 'Pelham Bay',
    'Kingsbridge', 'University Heights'
  ],
  'Staten Island': [
    'St. George', 'Stapleton', 'New Dorp', 'Tompkinsville', 'Great Kills',
    'Port Richmond'
  ]
};

export default function NeighborhoodStep({ data, onNext, isSaving }: NeighborhoodStepProps) {
  const [selectedNeighborhoods, setSelectedNeighborhoods] = useState<string[]>(
    data.neighborhoods || []
  );
  const [customInput, setCustomInput] = useState('');
  const [showCustomInput, setShowCustomInput] = useState(false);

  // Check if location is NYC
  const isNYC = data.location === 'new_york_city';

  const toggleNeighborhood = (neighborhood: string) => {
    setSelectedNeighborhoods(prev => {
      if (prev.includes(neighborhood)) {
        return prev.filter(n => n !== neighborhood);
      } else {
        return [...prev, neighborhood];
      }
    });
  };

  const addCustomNeighborhood = () => {
    if (customInput.trim() && !selectedNeighborhoods.includes(customInput.trim())) {
      setSelectedNeighborhoods(prev => [...prev, customInput.trim()]);
      setCustomInput('');
      setShowCustomInput(false);
    }
  };

  const removeNeighborhood = (neighborhood: string) => {
    setSelectedNeighborhoods(prev => prev.filter(n => n !== neighborhood));
  };

  const handleContinue = () => {
    onNext({ neighborhoods: selectedNeighborhoods });
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
      className="w-full max-w-4xl mx-auto"
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
        {isNYC ? 'Select neighborhoods or add your own' : 'Enter neighborhood names you\'re interested in'}
      </motion.p>

      {/* Selected Neighborhoods Pills */}
      {selectedNeighborhoods.length > 0 && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="mb-6 flex flex-wrap gap-2 justify-center"
        >
          {selectedNeighborhoods.map((neighborhood) => (
            <motion.div
              key={neighborhood}
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              className="px-4 py-2 bg-gradient-to-r from-primary to-purple-500 text-white rounded-full text-sm font-medium flex items-center gap-2"
            >
              <MapPin className="w-4 h-4" />
              {neighborhood}
              <button
                onClick={() => removeNeighborhood(neighborhood)}
                className="hover:bg-white/20 rounded-full p-0.5 transition-colors"
              >
                <X className="w-3 h-3" />
              </button>
            </motion.div>
          ))}
        </motion.div>
      )}

      {/* NYC Borough Sections */}
      {isNYC ? (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3, duration: 0.5 }}
          className="space-y-6 mb-8 max-h-[450px] overflow-y-auto scrollbar-thin scrollbar-thumb-white/10 scrollbar-track-transparent pr-2"
        >
          {Object.entries(NYC_NEIGHBORHOODS).map(([borough, neighborhoods], boroughIndex) => (
            <div key={borough} className="glass-strong rounded-2xl p-5">
              <h3 className="text-white font-bold text-lg mb-3 flex items-center gap-2">
                <MapPin className="w-5 h-5 text-primary" />
                {borough}
              </h3>
              <div className="flex flex-wrap gap-2">
                {neighborhoods.map((neighborhood) => (
                  <motion.button
                    key={neighborhood}
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: 0.4 + boroughIndex * 0.1 }}
                    onClick={() => toggleNeighborhood(neighborhood)}
                    className={`px-4 py-2 rounded-xl text-sm font-medium transition-all transform ${
                      selectedNeighborhoods.includes(neighborhood)
                        ? 'bg-gradient-to-r from-primary to-purple-500 text-white scale-105 shadow-lg'
                        : 'bg-white/5 text-white/80 hover:bg-white/10 hover:scale-102'
                    }`}
                  >
                    {neighborhood}
                  </motion.button>
                ))}
              </div>
            </div>
          ))}
        </motion.div>
      ) : (
        /* Non-NYC: Just show input */
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.3, duration: 0.5 }}
          className="mb-8"
        >
          <textarea
            value={customInput}
            onChange={(e) => setCustomInput(e.target.value)}
            placeholder="e.g. Lincoln Park, Lakeview, River North"
            rows={4}
            className="w-full px-6 py-4 bg-white/10 backdrop-blur-sm rounded-2xl text-white placeholder-white/40 focus:outline-none focus:ring-2 focus:ring-primary border border-white/20 resize-none"
            style={{ fontSize: '18px' }}
          />
        </motion.div>
      )}

      {/* Add Custom Neighborhood Button (for NYC) */}
      {isNYC && (
        <div className="mb-8">
          <AnimatePresence mode="wait">
            {!showCustomInput ? (
              <motion.button
                key="show-input"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                onClick={() => setShowCustomInput(true)}
                className="w-full px-6 py-4 glass-strong rounded-2xl text-white/70 hover:text-white hover:bg-white/10 transition-all flex items-center justify-center gap-2"
              >
                <Plus className="w-5 h-5" />
                Add a custom neighborhood
              </motion.button>
            ) : (
              <motion.div
                key="input-form"
                initial={{ opacity: 0, height: 0 }}
                animate={{ opacity: 1, height: 'auto' }}
                exit={{ opacity: 0, height: 0 }}
                className="glass-strong rounded-2xl p-4"
              >
                <div className="flex gap-3">
                  <input
                    type="text"
                    value={customInput}
                    onChange={(e) => setCustomInput(e.target.value)}
                    onKeyPress={(e) => {
                      if (e.key === 'Enter') {
                        addCustomNeighborhood();
                      }
                    }}
                    placeholder="Enter neighborhood name"
                    className="flex-1 px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-primary"
                    autoFocus
                  />
                  <button
                    onClick={addCustomNeighborhood}
                    disabled={!customInput.trim()}
                    className="px-6 py-3 bg-gradient-to-r from-primary to-purple-500 text-white rounded-xl font-semibold hover:shadow-lg hover:shadow-primary/30 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    Add
                  </button>
                  <button
                    onClick={() => {
                      setShowCustomInput(false);
                      setCustomInput('');
                    }}
                    className="px-4 py-3 bg-white/5 text-white/70 hover:text-white hover:bg-white/10 rounded-xl transition-all"
                  >
                    Cancel
                  </button>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
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
          disabled={isSaving || selectedNeighborhoods.length === 0}
          className="px-10 py-4 bg-white text-black rounded-full font-bold text-lg hover:shadow-2xl hover:shadow-white/20 transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {isSaving ? 'Saving...' : 'Continue →'}
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
