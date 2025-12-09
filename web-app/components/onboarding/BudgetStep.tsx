'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';
import { DollarSign } from 'lucide-react';

interface BudgetStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function BudgetStep({ data, onNext, isSaving }: BudgetStepProps) {
  const [minBudget, setMinBudget] = useState<string>(data.budgetMin?.toString() || '');
  const [maxBudget, setMaxBudget] = useState<string>(data.budgetMax?.toString() || '');

  // Determine if this is rent or purchase based on user type
  const isRenter = data.userType === 'renter';

  const formatCurrency = (value: string) => {
    const numbers = value.replace(/[^0-9]/g, '');
    if (!numbers) return '';
    return parseInt(numbers).toLocaleString();
  };

  const handleContinue = () => {
    const min = parseInt(minBudget.replace(/[^0-9]/g, '')) || 0;
    const max = parseInt(maxBudget.replace(/[^0-9]/g, '')) || 0;

    if (max > 0) {
      onNext({
        budgetMin: min,
        budgetMax: max,
      });
    }
  };

  const isValid = maxBudget && parseInt(maxBudget.replace(/[^0-9]/g, '')) > 0;

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
        {isRenter ? 'Monthly rent range' : 'Purchase price range'}
      </motion.p>

      {/* Budget Range Inputs */}
      <div className="space-y-6 mb-8">
        {/* Minimum Budget */}
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.3, duration: 0.5 }}
        >
          <label className="block text-white/70 text-sm font-medium mb-3 text-center">
            Minimum {isRenter ? '(optional)' : ''}
          </label>
          <div
            className="rounded-2xl p-6 text-center backdrop-blur-xl"
            style={{
              background: 'rgba(255, 255, 255, 0.05)',
              border: '1.5px solid rgba(255, 255, 255, 0.18)',
              boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37), 0 0 20px rgba(100, 100, 255, 0.2), inset 0 0 20px rgba(100, 100, 255, 0.05)',
            }}
          >
            <div className="relative inline-block">
              <span className="absolute left-0 top-1/2 -translate-y-1/2 text-white/40 text-4xl md:text-5xl font-light">
                $
              </span>
              <input
                type="text"
                value={formatCurrency(minBudget)}
                onChange={(e) => setMinBudget(e.target.value.replace(/[^0-9]/g, ''))}
                placeholder="0"
                className="bg-transparent text-white text-5xl md:text-6xl font-light text-center focus:outline-none pl-6 md:pl-8 w-full"
                style={{ fontFamily: 'Playfair Display, serif', minWidth: '250px' }}
              />
            </div>
            <p className="text-white/40 text-sm mt-3">
              {isRenter ? 'per month' : 'total price'}
            </p>
          </div>
        </motion.div>

        {/* Maximum Budget */}
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.4, duration: 0.5 }}
        >
          <label className="block text-white/70 text-sm font-medium mb-3 text-center">
            Maximum *
          </label>
          <div
            className="rounded-2xl p-6 text-center backdrop-blur-xl"
            style={{
              background: 'rgba(255, 255, 255, 0.05)',
              border: '1.5px solid rgba(168, 218, 220, 0.4)',
              borderTopColor: 'rgba(168, 218, 220, 0.6)',
              borderLeftColor: 'rgba(168, 218, 220, 0.5)',
              boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37), 0 0 30px rgba(168, 218, 220, 0.3), inset 0 0 30px rgba(168, 218, 220, 0.1)',
            }}
          >
            <div className="relative inline-block">
              <span className="absolute left-0 top-1/2 -translate-y-1/2 text-white/40 text-4xl md:text-5xl font-light">
                $
              </span>
              <input
                type="text"
                value={formatCurrency(maxBudget)}
                onChange={(e) => setMaxBudget(e.target.value.replace(/[^0-9]/g, ''))}
                placeholder="0"
                className="bg-transparent text-white text-5xl md:text-6xl font-light text-center focus:outline-none pl-6 md:pl-8 w-full"
                style={{ fontFamily: 'Playfair Display, serif', minWidth: '250px' }}
              />
            </div>
            <p className="text-white/40 text-sm mt-3">
              {isRenter ? 'per month' : 'total price'}
            </p>
          </div>
        </motion.div>
      </div>

      {/* Helper Note */}
      <motion.p
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.5 }}
        className="text-white/50 text-sm text-center mb-8"
      >
        💡 This helps Homey show you homes within your actual budget
      </motion.p>

      {/* Continue Button */}
      {isValid && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3 }}
          className="text-center"
        >
          <motion.button
            onClick={handleContinue}
            disabled={isSaving}
            className="px-10 py-4 rounded-full font-bold text-lg transition-all backdrop-blur-xl disabled:opacity-50 disabled:cursor-not-allowed"
            style={{
              background: 'linear-gradient(135deg, rgba(168, 218, 220, 0.3) 0%, rgba(180, 167, 214, 0.3) 100%)',
              border: '1.5px solid rgba(255, 255, 255, 0.3)',
              boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37), 0 0 30px rgba(168, 218, 220, 0.5)',
            }}
            whileHover={{
              scale: 1.05,
              boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37), 0 0 40px rgba(168, 218, 220, 0.7)',
              background: 'linear-gradient(135deg, rgba(168, 218, 220, 0.4) 0%, rgba(180, 167, 214, 0.4) 100%)',
            }}
            whileTap={{ scale: 0.98 }}
          >
            <span className="text-white">
              {isSaving ? 'Saving...' : 'Continue →'}
            </span>
          </motion.button>
        </motion.div>
      )}
    </motion.div>
  );
}
