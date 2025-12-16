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
  const isBuyer = data.userType === 'buyer';

  // Renter fields
  const [min, setMin] = useState<string>(data.budgetMin?.toString() || '');
  const [max, setMax] = useState<string>(data.budgetMax?.toString() || '');

  // Buyer fields
  const [purchasePrice, setPurchasePrice] = useState<string>(data.purchasePrice?.toString() || '');
  const [downPayment, setDownPayment] = useState<string>(data.downPayment?.toString() || '');
  const [monthlyPayment, setMonthlyPayment] = useState<string>(data.monthlyPayment?.toString() || '');

  const formatCurrency = (val: string) => {
    const num = val.replace(/\D/g, '');
    return num ? parseInt(num).toLocaleString() : '';
  };

  const handleInput = (setter: any, val: string) => setter(formatCurrency(val));

  // Renter calculations
  const maxNum = parseInt(max.replace(/,/g, '')) || 0;
  const minNum = parseInt(min.replace(/,/g, '')) || 0;
  const incomeReq = maxNum * 40;

  // Buyer calculations
  const purchasePriceNum = parseInt(purchasePrice.replace(/,/g, '')) || 0;
  const downPaymentNum = parseInt(downPayment.replace(/,/g, '')) || 0;
  const monthlyPaymentNum = parseInt(monthlyPayment.replace(/,/g, '')) || 0;

  const handleContinue = () => {
    if (isBuyer) {
      onNext({
        purchasePrice: purchasePriceNum,
        downPayment: downPaymentNum,
        monthlyPayment: monthlyPaymentNum
      });
    } else {
      onNext({
        budgetMin: minNum,
        budgetMax: maxNum
      });
    }
  };

  const isValid = isBuyer
    ? (purchasePriceNum > 0 && downPaymentNum > 0 && monthlyPaymentNum > 0)
    : maxNum > 0;

  return (
    <div className="max-w-md w-full mx-auto">
      <h1 className="text-3xl font-serif text-white mb-2" style={{ fontFamily: 'Playfair Display, serif' }}>
        Where Reality Lands
      </h1>
      <p className="text-white/50 mb-12">
        {isBuyer ? "Let's talk numbers." : 'Set your monthly range.'}
      </p>

      {isBuyer ? (
        // BUYER FORM
        <div className="space-y-6 mb-8">
          {/* Ideal Purchase Price */}
          <div>
            <label className="text-[10px] uppercase tracking-widest text-white/40 mb-2 block">
              Ideal Purchase Price
            </label>
            <div className="relative">
              <span className="absolute left-4 top-1/2 -translate-y-1/2 text-white/50">$</span>
              <input
                value={purchasePrice}
                onChange={(e) => handleInput(setPurchasePrice, e.target.value)}
                placeholder="0"
                className="w-full bg-white/5 border border-white/10 rounded-2xl p-4 pl-8 text-2xl text-white outline-none focus:border-white/50 transition-colors placeholder:text-white/10 font-mono"
                inputMode="numeric"
              />
            </div>
          </div>

          {/* Down Payment Estimation */}
          <div>
            <label className="text-[10px] uppercase tracking-widest text-white/40 mb-2 block">
              Down Payment Estimation
            </label>
            <div className="relative">
              <span className="absolute left-4 top-1/2 -translate-y-1/2 text-white/50">$</span>
              <input
                value={downPayment}
                onChange={(e) => handleInput(setDownPayment, e.target.value)}
                placeholder="0"
                className="w-full bg-white/5 border border-white/10 rounded-2xl p-4 pl-8 text-2xl text-white outline-none focus:border-white/50 transition-colors placeholder:text-white/10 font-mono"
                inputMode="numeric"
              />
            </div>
            {purchasePriceNum > 0 && downPaymentNum > 0 && (
              <motion.p
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="text-xs text-white/40 mt-2 font-mono"
              >
                {((downPaymentNum / purchasePriceNum) * 100).toFixed(1)}% down
              </motion.p>
            )}
          </div>

          {/* Dream Monthly Payments */}
          <div>
            <label className="text-[10px] uppercase tracking-widest text-white/40 mb-2 block">
              Dream Monthly Payments <span className="text-white/20">(including fees)</span>
            </label>
            <div className="relative">
              <span className="absolute left-4 top-1/2 -translate-y-1/2 text-white/50">$</span>
              <input
                value={monthlyPayment}
                onChange={(e) => handleInput(setMonthlyPayment, e.target.value)}
                placeholder="0"
                className="w-full bg-white/5 border border-white/10 rounded-2xl p-4 pl-8 text-2xl text-white outline-none focus:border-white/50 transition-colors placeholder:text-white/10 font-mono"
                inputMode="numeric"
              />
            </div>
          </div>
        </div>
      ) : (
        // RENTER FORM
        <>
          <div className="flex gap-4 mb-8">
            <div className="flex-1">
              <label className="text-[10px] uppercase tracking-widest text-white/40 mb-2 block">Min Price</label>
              <div className="relative">
                <span className="absolute left-4 top-1/2 -translate-y-1/2 text-white/50">$</span>
                <input
                  value={min}
                  onChange={(e) => handleInput(setMin, e.target.value)}
                  placeholder="0"
                  className="w-full bg-white/5 border border-white/10 rounded-2xl p-4 pl-8 text-2xl text-white outline-none focus:border-white/50 transition-colors placeholder:text-white/10 font-mono"
                  inputMode="numeric"
                />
              </div>
            </div>
            <div className="flex-1">
              <label className="text-[10px] uppercase tracking-widest text-white/40 mb-2 block">Max Price</label>
              <div className="relative">
                <span className="absolute left-4 top-1/2 -translate-y-1/2 text-white/50">$</span>
                <input
                  value={max}
                  onChange={(e) => handleInput(setMax, e.target.value)}
                  placeholder="0"
                  className="w-full bg-white/5 border border-white/10 rounded-2xl p-4 pl-8 text-2xl text-white outline-none focus:border-white/50 transition-colors placeholder:text-white/10 font-mono"
                  inputMode="numeric"
                />
              </div>
            </div>
          </div>

          {maxNum > 0 && data.location === 'new_york_city' && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              className="bg-white/5 p-4 rounded-xl border border-white/10 mb-8 overflow-hidden"
            >
              <div className="flex justify-between text-xs text-white/60 uppercase tracking-widest mb-1">
                <span>NYC 40x Rule</span>
                <span>Required Income</span>
              </div>
              <div className="text-white font-mono text-lg">${incomeReq.toLocaleString()} /yr</div>
            </motion.div>
          )}
        </>
      )}

      <button
        disabled={!isValid || isSaving}
        onClick={handleContinue}
        className="w-full py-4 bg-white text-black rounded-xl font-bold disabled:opacity-30 disabled:cursor-not-allowed hover:scale-[1.02] transition-transform"
      >
        {isSaving ? 'Saving...' : 'Continue'}
      </button>
    </div>
  );
}
