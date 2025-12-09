'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';

interface IncomeStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function IncomeStep({ data, onNext, isSaving }: IncomeStepProps) {
  const [income, setIncome] = useState<string>(
    data.householdIncome?.toString() || ''
  );

  const formatCurrency = (value: string) => {
    const numbers = value.replace(/[^0-9]/g, '');
    if (!numbers) return '';
    return parseInt(numbers).toLocaleString();
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value.replace(/[^0-9]/g, '');
    setIncome(value);
  };

  const handleContinue = () => {
    const householdIncome = parseInt(income.replace(/[^0-9]/g, ''));
    if (householdIncome > 0) {
      onNext({
        householdIncome,
      });
    }
  };

  const handleSkip = () => {
    onNext({ householdIncome: undefined });
  };

  const numericIncome = parseInt(income.replace(/[^0-9]/g, '')) || 0;
  const displayValue = formatCurrency(income);
  const budgetMax = data.budgetMax || 0;
  const requiredIncome = budgetMax * 40;
  const meetsRequirement = numericIncome >= requiredIncome;

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
        NYC Income Verification
      </motion.h2>

      <motion.p
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        className="text-white/60 text-center mb-12 text-lg"
      >
        Most NYC landlords require 40x the monthly rent
      </motion.p>

      {/* Income Input */}
      <motion.div
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.3, duration: 0.5 }}
        className="mb-8"
      >
        <div className="glass-strong rounded-3xl p-8 md:p-12 text-center">
          <p className="text-white/60 text-sm mb-4">Annual Household Income</p>
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
          <p className="text-white/40 text-sm mt-4">per year</p>
        </div>
      </motion.div>

      {/* Income Requirement Check - Simplified */}
      {numericIncome > 0 && budgetMax > 0 && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3 }}
          className={`mb-8 p-6 rounded-2xl text-center ${
            meetsRequirement
              ? 'bg-green-500/10 border border-green-500/30'
              : 'bg-yellow-500/10 border border-yellow-500/30'
          }`}
        >
          {meetsRequirement ? (
            <div>
              <p className="text-green-400 text-lg font-semibold mb-2">✓ You're all set!</p>
              <p className="text-white/70 text-sm">
                You meet the 40x rule (${requiredIncome.toLocaleString()}/year required)
              </p>
            </div>
          ) : (
            <div>
              <p className="text-yellow-400 text-lg font-semibold mb-2">Almost there</p>
              <p className="text-white/70 text-sm mb-3">
                You may need a guarantor (${requiredIncome.toLocaleString()}/year required)
              </p>
              <p className="text-primary text-sm font-semibold">
                Don't worry - we'll connect you with trusted guarantor services!
              </p>
            </div>
          )}
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

        {numericIncome > 0 && (
          <button
            onClick={handleContinue}
            disabled={isSaving}
            className="px-10 py-4 bg-white text-black rounded-full font-bold text-lg hover:shadow-2xl hover:shadow-white/20 transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isSaving ? 'Saving...' : 'Continue →'}
          </button>
        )}
      </motion.div>

      {/* Helper text */}
      <motion.p
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.5, duration: 0.5 }}
        className="text-white/40 text-sm text-center mt-6"
      >
        This helps us find properties within your qualified budget
      </motion.p>
    </motion.div>
  );
}
