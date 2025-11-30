'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

interface NeighborhoodFilterProps {
  selectedNeighborhoods: string[];
  onChange: (neighborhoods: string[]) => void;
}

const NYC_NEIGHBORHOODS = {
  Manhattan: [
    'Upper East Side',
    'Upper West Side',
    'Midtown',
    'Chelsea',
    'Flatiron',
    'Greenwich Village',
    'East Village',
    'West Village',
    'SoHo',
    'TriBeCa',
    'Lower East Side',
    'Financial District',
    'Battery Park City',
    'Harlem',
    'Washington Heights',
    'Inwood',
  ],
  Brooklyn: [
    'Williamsburg',
    'Greenpoint',
    'DUMBO',
    'Brooklyn Heights',
    'Park Slope',
    'Prospect Heights',
    'Fort Greene',
    'Carroll Gardens',
    'Cobble Hill',
    'Red Hook',
    'Gowanus',
    'Sunset Park',
    'Bay Ridge',
    'Bushwick',
    'Bedford-Stuyvesant',
    'Crown Heights',
  ],
  Queens: [
    'Long Island City',
    'Astoria',
    'Sunnyside',
    'Woodside',
    'Jackson Heights',
    'Forest Hills',
    'Rego Park',
    'Flushing',
    'Ridgewood',
  ],
  Bronx: [
    'Riverdale',
    'Kingsbridge',
    'Fordham',
    'Morris Park',
    'Pelham Bay',
    'Tremont',
  ],
  'Staten Island': [
    'St. George',
    'Stapleton',
    'Tompkinsville',
    'New Brighton',
  ],
};

export default function NeighborhoodFilter({ selectedNeighborhoods, onChange }: NeighborhoodFilterProps) {
  const [expandedBorough, setExpandedBorough] = useState<string | null>('Manhattan');

  const toggleNeighborhood = (neighborhood: string) => {
    if (selectedNeighborhoods.includes(neighborhood)) {
      onChange(selectedNeighborhoods.filter(n => n !== neighborhood));
    } else {
      onChange([...selectedNeighborhoods, neighborhood]);
    }
  };

  const toggleBorough = (borough: string) => {
    const boroughNeighborhoods = NYC_NEIGHBORHOODS[borough as keyof typeof NYC_NEIGHBORHOODS];
    const allSelected = boroughNeighborhoods.every(n => selectedNeighborhoods.includes(n));

    if (allSelected) {
      // Deselect all neighborhoods in this borough
      onChange(selectedNeighborhoods.filter(n => !boroughNeighborhoods.includes(n)));
    } else {
      // Select all neighborhoods in this borough
      const newNeighborhoods = [...selectedNeighborhoods];
      boroughNeighborhoods.forEach(n => {
        if (!newNeighborhoods.includes(n)) {
          newNeighborhoods.push(n);
        }
      });
      onChange(newNeighborhoods);
    }
  };

  const getBoroughSelectionCount = (borough: string) => {
    const boroughNeighborhoods = NYC_NEIGHBORHOODS[borough as keyof typeof NYC_NEIGHBORHOODS];
    return boroughNeighborhoods.filter(n => selectedNeighborhoods.includes(n)).length;
  };

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between mb-2">
        <label className="block text-white font-semibold">Neighborhoods</label>
        {selectedNeighborhoods.length > 0 && (
          <button
            onClick={() => onChange([])}
            className="text-xs text-primary hover:underline"
          >
            Clear all ({selectedNeighborhoods.length})
          </button>
        )}
      </div>

      {Object.entries(NYC_NEIGHBORHOODS).map(([borough, neighborhoods]) => {
        const selectionCount = getBoroughSelectionCount(borough);
        const isExpanded = expandedBorough === borough;
        const allSelected = neighborhoods.every(n => selectedNeighborhoods.includes(n));

        return (
          <div key={borough} className="bg-white/5 rounded-xl border border-white/10 overflow-hidden">
            {/* Borough Header */}
            <div className="flex items-center justify-between p-3">
              <button
                onClick={() => setExpandedBorough(isExpanded ? null : borough)}
                className="flex-1 flex items-center gap-2 text-left"
              >
                <motion.span
                  animate={{ rotate: isExpanded ? 90 : 0 }}
                  transition={{ duration: 0.2 }}
                  className="text-white/60"
                >
                  ▶
                </motion.span>
                <span className="text-white font-medium">{borough}</span>
                {selectionCount > 0 && (
                  <span className="px-2 py-0.5 bg-primary/20 border border-primary/40 rounded-full text-primary text-xs font-semibold">
                    {selectionCount}
                  </span>
                )}
              </button>

              {/* Select All Borough Button */}
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  toggleBorough(borough);
                }}
                className={`px-3 py-1 rounded-full text-xs font-medium transition-all ${
                  allSelected
                    ? 'bg-primary/30 text-primary border border-primary/50'
                    : 'bg-white/10 text-white/70 border border-white/20 hover:bg-white/20'
                }`}
              >
                {allSelected ? '✓ All' : 'All'}
              </button>
            </div>

            {/* Neighborhoods Grid */}
            <AnimatePresence>
              {isExpanded && (
                <motion.div
                  initial={{ height: 0, opacity: 0 }}
                  animate={{ height: 'auto', opacity: 1 }}
                  exit={{ height: 0, opacity: 0 }}
                  transition={{ duration: 0.2 }}
                  className="overflow-hidden"
                >
                  <div className="px-3 pb-3 grid grid-cols-2 gap-2">
                    {neighborhoods.map(neighborhood => {
                      const isSelected = selectedNeighborhoods.includes(neighborhood);
                      return (
                        <motion.button
                          key={neighborhood}
                          onClick={() => toggleNeighborhood(neighborhood)}
                          whileTap={{ scale: 0.97 }}
                          className={`px-3 py-2 rounded-lg text-xs font-medium text-left transition-all ${
                            isSelected
                              ? 'bg-primary/20 text-primary border border-primary/40'
                              : 'bg-white/5 text-white/70 border border-white/10 hover:bg-white/10'
                          }`}
                        >
                          {isSelected && '✓ '}{neighborhood}
                        </motion.button>
                      );
                    })}
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>
        );
      })}
    </div>
  );
}
