'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';
import { DollarSign, Info, X } from 'lucide-react';

interface BudgetStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function BudgetStep({ data, onNext, isSaving }: BudgetStepProps) {
  const [maxBudget, setMaxBudget] = useState<string>(
    data.budgetMax?.toString() || ''
  );
  const [showIncomeDisclosure, setShowIncomeDisclosure] = useState(false);

  // Determine if this is rent or purchase based on user type
  const isRenter = data.userType === 'renter';

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
      // Show income disclosure for NYC renters before proceeding
      if (isRenter) {
        setShowIncomeDisclosure(true);
      } else {
        onNext({
          budgetMax: budget,
        });
      }
    }
  };

  const handleIncomeModalClose = () => {
    setShowIncomeDisclosure(false);
    // After viewing income disclosure, proceed to next step
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
  const priceLabel = isRenter ? 'monthly rent' : 'purchase price';
  const requiredIncome = numericValue * 40;

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

      {/* Income Disclosure Modal */}
      <AnimatePresence>
        {showIncomeDisclosure && isRenter && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={handleIncomeModalClose}
              className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50"
            />

            {/* Modal */}
            <motion.div
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              transition={{ type: 'spring', damping: 25, stiffness: 300 }}
              className="fixed top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-[60] w-full max-w-md px-4 max-h-[90vh] overflow-y-auto"
            >
              <div className="glass-strong rounded-3xl p-8 border border-white/20 relative">
                {/* Close Button */}
                <button
                  onClick={handleIncomeModalClose}
                  className="absolute top-4 right-4 w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center text-white/60 hover:text-white transition-all"
                >
                  <X className="w-4 h-4" />
                </button>

                {/* Icon */}
                <div className="w-16 h-16 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-2xl flex items-center justify-center mx-auto mb-6">
                  <DollarSign className="w-8 h-8 text-white" />
                </div>

                {/* Title */}
                <h3 className="text-2xl font-bold text-white text-center mb-4">
                  Income Requirements
                </h3>

                {/* Content */}
                <div className="space-y-4 text-white/80">
                  <p className="text-center">
                    For a monthly rent of <span className="font-bold text-white">${displayValue}</span>, most landlords in NYC require:
                  </p>

                  <div className="bg-white/5 border border-white/10 rounded-2xl p-4 text-center">
                    <p className="text-sm text-white/60 mb-1">Minimum Annual Income</p>
                    <p className="text-3xl font-bold text-white">
                      ${formatCurrency(requiredIncome.toString())}
                    </p>
                    <p className="text-xs text-white/40 mt-1">
                      (40x monthly rent)
                    </p>
                  </div>

                  <div className="bg-blue-500/10 border border-blue-500/30 rounded-xl p-4">
                    <p className="text-sm text-blue-200 font-medium mb-2">Why 40x?</p>
                    <p className="text-xs text-blue-200/70 leading-relaxed">
                      NYC landlords typically require your annual income to be at least 40 times the monthly rent to ensure you can afford the apartment comfortably.
                    </p>
                  </div>

                  <div className="bg-green-500/10 border border-green-500/30 rounded-xl p-4">
                    <p className="text-sm text-green-200 font-medium mb-2">Don't meet the requirement?</p>
                    <p className="text-xs text-green-200/70 leading-relaxed">
                      No worries! You can use a <span className="font-semibold">guarantor</span> (someone who agrees to cover rent if you can't) or apply with <span className="font-semibold">roommates</span> to combine incomes.
                    </p>
                  </div>
                </div>

                {/* Got It Button */}
                <button
                  onClick={handleIncomeModalClose}
                  className="w-full mt-6 px-6 py-4 bg-gradient-to-r from-blue-500 to-cyan-500 text-white rounded-xl font-bold hover:shadow-lg hover:shadow-blue-500/30 transition-all"
                >
                  Got it, thanks!
                </button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

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
