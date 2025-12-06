'use client';

import { useState } from 'react';
import { AlertCircle, Plus, X, Sparkles } from 'lucide-react';
import type { Listing } from '@/lib/types';

interface DealBreakersProps {
  listingId: string;
  listing: Listing;
  dealBreakers: string[];
  onSave: (dealBreakers: string[]) => void;
}

const commonDealBreakers = [
  'No in-unit laundry',
  'No parking',
  'No pets allowed',
  'Ground floor',
  'No elevator',
  'Street noise',
  'No natural light',
  'Carpet flooring',
  'No dishwasher',
];

export default function DealBreakers({ listingId, listing, dealBreakers, onSave }: DealBreakersProps) {
  const [isAdding, setIsAdding] = useState(false);
  const [customBreaker, setCustomBreaker] = useState('');
  const [showHomeyTip, setShowHomeyTip] = useState(true);

  const detectAutomaticDealBreakers = (): string[] => {
    const detected: string[] = [];

    // Auto-detect based on available listing properties
    if (listing.noise_level === 'busy') {
      detected.push('Street noise');
    }

    // Could add more detections here based on features/amenities arrays
    if (!listing.amenities?.includes('Elevator')) {
      // Only suggest if it's likely a high-rise (no direct floor data available)
      // This is a guess, so we won't auto-add it
    }

    return detected;
  };

  const automaticBreakers = detectAutomaticDealBreakers();
  const allBreakers = [...new Set([...automaticBreakers, ...dealBreakers])];

  const handleAddBreaker = (breaker: string) => {
    if (!dealBreakers.includes(breaker)) {
      onSave([...dealBreakers, breaker]);
    }
  };

  const handleRemoveBreaker = (breaker: string) => {
    onSave(dealBreakers.filter(b => b !== breaker));
  };

  const handleAddCustom = () => {
    if (customBreaker.trim() && !dealBreakers.includes(customBreaker.trim())) {
      onSave([...dealBreakers, customBreaker.trim()]);
      setCustomBreaker('');
      setIsAdding(false);
    }
  };

  return (
    <div>
      {allBreakers.length > 0 ? (
        <div className="space-y-2 mb-4">
          {allBreakers.map((breaker, idx) => (
            <div
              key={idx}
              className="flex items-center justify-between px-4 py-2.5 bg-orange-500/10 border border-orange-500/20 rounded-2xl group"
            >
              <div className="flex items-center gap-2">
                <span className="text-base">🚫</span>
                <span className="text-xs text-white/80">{breaker}</span>
              </div>
              {dealBreakers.includes(breaker) && (
                <button
                  onClick={() => handleRemoveBreaker(breaker)}
                  className="opacity-0 group-hover:opacity-100 transition-opacity"
                >
                  <X className="w-3 h-3 text-orange-300 hover:text-orange-100" />
                </button>
              )}
            </div>
          ))}
        </div>
      ) : (
        <p className="text-xs text-white/40 italic text-center py-3 mb-4">
          No deal breakers yet — looking good!
        </p>
      )}

      {/* Add Custom */}
      {isAdding ? (
        <div className="mb-3">
          <input
            type="text"
            value={customBreaker}
            onChange={(e) => setCustomBreaker(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleAddCustom()}
            placeholder="Type a deal breaker..."
            className="w-full px-4 py-2.5 bg-white/5 border border-white/20 rounded-2xl text-sm text-white placeholder:text-white/40 focus:outline-none focus:border-primary/50"
            autoFocus
          />
          <div className="flex items-center gap-2 mt-2">
            <button
              onClick={handleAddCustom}
              className="flex-1 px-4 py-2 bg-orange-500/20 border border-orange-500/30 rounded-2xl text-sm text-orange-300 hover:bg-orange-500/30 transition-all font-medium"
            >
              Add
            </button>
            <button
              onClick={() => {
                setIsAdding(false);
                setCustomBreaker('');
              }}
              className="flex-1 px-4 py-2 bg-white/5 rounded-2xl text-sm text-white/60 hover:bg-white/10 transition-all font-medium"
            >
              Cancel
            </button>
          </div>
        </div>
      ) : (
        <button
          onClick={() => setIsAdding(true)}
          className="w-full px-4 py-2.5 bg-white/5 border border-white/10 rounded-2xl text-sm text-white/60 hover:text-white hover:bg-white/10 transition-all flex items-center justify-center gap-2 font-medium"
        >
          <Plus className="w-4 h-4" />
          Add a deal breaker
        </button>
      )}

      {/* Quick Add Suggestions */}
      {!isAdding && dealBreakers.length === 0 && (
        <div className="mt-3">
          <p className="text-xs text-white/40 mb-2">Common ones:</p>
          <div className="flex flex-wrap gap-1">
            {commonDealBreakers.slice(0, 3).map((breaker) => (
              <button
                key={breaker}
                onClick={() => handleAddBreaker(breaker)}
                className="px-3 py-1.5 bg-white/5 border border-white/10 rounded-xl text-xs text-white/50 hover:text-white hover:bg-white/10 transition-all"
              >
                {breaker}
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
