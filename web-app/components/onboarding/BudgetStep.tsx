'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';

interface BudgetStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function BudgetStep({ data, onNext, isSaving }: BudgetStepProps) {
  const [maxBudget, setMaxBudget] = useState<string>(
    data.budgetMax?.toString() || ''
  );

  const formatCurrency = (value: string) => {
    const numbers = value.replace(/[^0-9]/g, '');
    if (!numbers) return '';
    return parseInt(numbers).toLocaleString();
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value.replace(/[^0-9]/g, '');
    setMaxBudget(value);
  };

  const handleContinue = () => {
    const budget = parseInt(maxBudget.replace(/[^0-9]/g, ''));
    if (budget > 0) {
      onNext({
        budgetMax: budget,
      });
    }
  };

  const isValid = maxBudget && parseInt(maxBudget.replace(/[^0-9]/g, '')) > 0;
  const displayValue = formatCurrency(maxBudget);
  const numericValue = parseInt(maxBudget.replace(/[^0-9]/g, '')) || 0;

  // Determine if this is rent or purchase based on user type
  const isRenter = data.userType === 'renter';
  const priceLabel = isRenter ? 'monthly rent' : 'purchase price';

  return (
    <motion.div
      initial={{ opacity: 0, x: 50 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -50 }}
      transition={{ duration: 0.5 }}
      className="w-full max-w-2xl mx-auto"
    >
      {/* Question */}
      <motion.h2
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.1, duration: 0.5 }}
        className="text-4xl md:text-5xl font-light text-white text-center mb-4"
        style={{ fontFamily: 'Playfair Display, serif' }}
      >
        What's your budget?
      </motion.h2>

      <motion.p
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        className="text-white/60 text-center mb-12 text-lg"
      >
        Maximum {priceLabel} you're comfortable with
      </motion.p>

      {/* Budget Input */}
      <motion.div
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.3, duration: 0.5 }}
        className="mb-8"
      >
        <div className="glass-strong rounded-3xl p-8 md:p-12 text-center">
          <div className="relative inline-block">
            <span className="absolute left-0 top-1/2 -translate-y-1/2 text-white/40 text-5xl md:text-6xl font-light">
              $
            </span>
            <input
              type="text"
              value={displayValue}
              onChange={handleInputChange}
              placeholder="0"
              className="bg-transparent text-white text-6xl md:text-7xl font-light text-center focus:outline-none pl-8 md:pl-12 w-full"
              style={{ fontFamily: 'Playfair Display, serif', minWidth: '300px' }}
            />
          </div>

          {/* Helper text */}
          {numericValue > 0 && (
            <motion.p
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="text-white/40 text-sm mt-6"
            >
              {isRenter ? 'per month' : 'total'}
            </motion.p>
          )}
        </div>

        {/* Quick Presets */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.4 }}
          className="mt-6 flex flex-wrap justify-center gap-3"
        >
          {isRenter ? (
            <>
              <button
                onClick={() => setMaxBudget('2000')}
                className="px-4 py-2 bg-white/10 hover:bg-white/20 text-white rounded-full text-sm transition-colors"
              >
                $2,000
              </button>
              <button
                onClick={() => setMaxBudget('3000')}
                className="px-4 py-2 bg-white/10 hover:bg-white/20 text-white rounded-full text-sm transition-colors"
              >
                $3,000
              </button>
              <button
                onClick={() => setMaxBudget('4000')}
                className="px-4 py-2 bg-white/10 hover:bg-white/20 text-white rounded-full text-sm transition-colors"
              >
                $4,000
              </button>
              <button
                onClick={() => setMaxBudget('5000')}
                className="px-4 py-2 bg-white/10 hover:bg-white/20 text-white rounded-full text-sm transition-colors"
              >
                $5,000+
              </button>
            </>
          ) : (
            <>
              <button
                onClick={() => setMaxBudget('500000')}
                className="px-4 py-2 bg-white/10 hover:bg-white/20 text-white rounded-full text-sm transition-colors"
              >
                $500K
              </button>
              <button
                onClick={() => setMaxBudget('750000')}
                className="px-4 py-2 bg-white/10 hover:bg-white/20 text-white rounded-full text-sm transition-colors"
              >
                $750K
              </button>
              <button
                onClick={() => setMaxBudget('1000000')}
                className="px-4 py-2 bg-white/10 hover:bg-white/20 text-white rounded-full text-sm transition-colors"
              >
                $1M
              </button>
              <button
                onClick={() => setMaxBudget('2000000')}
                className="px-4 py-2 bg-white/10 hover:bg-white/20 text-white rounded-full text-sm transition-colors"
              >
                $2M+
              </button>
            </>
          )}
        </motion.div>
      </motion.div>

      {/* Continue Button */}
      {isValid && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3 }}
          className="text-center"
        >
          <button
            onClick={handleContinue}
            disabled={isSaving}
            className="px-10 py-4 bg-white text-black rounded-full font-bold text-lg hover:shadow-2xl hover:shadow-white/20 transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isSaving ? 'Saving...' : 'Continue →'}
          </button>
        </motion.div>
      )}
    </motion.div>
  );
}
