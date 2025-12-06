'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { DollarSign, PawPrint, Car, Calendar, TrendingUp, AlertCircle, Sparkles, Home, Calculator } from 'lucide-react';
import type { Listing } from '@/lib/types';

interface EnhancedMetricsProps {
  listings: Listing[];
}

export default function EnhancedMetrics({ listings }: EnhancedMetricsProps) {
  const [selectedPropertyIndex, setSelectedPropertyIndex] = useState<number | null>(null);
  const [customDownPayment, setCustomDownPayment] = useState<number | null>(null);

  const calculateMonthlyTotal = (listing: Listing) => {
    const monthlyRent = listing.price || 0;
    const estimatedUtilities = 150;
    // Note: parking and pet fees would be added here if available in listing data
    return monthlyRent + estimatedUtilities;
  };

  // Mortgage calculation helper
  const calculateMortgagePayment = (principal: number, annualRate: number, years: number): number => {
    const monthlyRate = annualRate / 100 / 12;
    const numberOfPayments = years * 12;

    if (monthlyRate === 0) return principal / numberOfPayments;

    const payment = principal * (monthlyRate * Math.pow(1 + monthlyRate, numberOfPayments)) /
                    (Math.pow(1 + monthlyRate, numberOfPayments) - 1);
    return payment;
  };

  // Estimate purchase price from rent (rough multiplier)
  const estimatePurchasePrice = (monthlyRent: number): number => {
    // NYC rent-to-price ratio is roughly 1:200-250
    return monthlyRent * 220;
  };

  const calculateMoveInCost = (listing: Listing) => {
    const monthlyRent = listing.price || 0;
    const securityDeposit = monthlyRent;
    const firstMonth = monthlyRent;
    const lastMonth = monthlyRent;
    const applicationFee = 50;
    return securityDeposit + firstMonth + lastMonth + applicationFee;
  };

  const getHomeyTakeForMoveIn = (cost: number) => {
    if (cost < 5000) {
      return "This is a stretch but doable for most first-timers with some savings.";
    } else if (cost < 10000) {
      return "You'll need solid savings or maybe a roommate to split this.";
    } else {
      return "This usually means family help, savings already stacked, or roommates.";
    }
  };

  // Calculate differences
  const monthlyTotals = listings.map(calculateMonthlyTotal);
  const lowestMonthly = Math.min(...monthlyTotals);
  const differences = monthlyTotals.map(total => total - lowestMonthly);
  const annualDifferences = differences.map(diff => diff * 12);

  return (
    <div className="mb-8 space-y-8">
      {/* Monthly Reality Check */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
      >
        <div className="mb-6">
          <h3 className="text-3xl md:text-4xl font-bold text-white mb-2">Monthly Reality Check</h3>
          <p className="text-white/60">What hits your account every month</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {listings.map((listing, idx) => {
            const monthlyTotal = monthlyTotals[idx];
            const difference = differences[idx];
            const annualDifference = annualDifferences[idx];

            return (
              <motion.div
                key={listing.id}
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: idx * 0.1 }}
                className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-primary/10 via-purple-600/10 to-pink-500/10 border border-white/10 p-8"
              >
                {/* Animated blur effect */}
                <div className="absolute top-0 right-0 w-40 h-40 bg-primary/20 rounded-full blur-3xl opacity-50 animate-pulse" />

                <div className="relative z-10">
                  <p className="text-sm text-white/50 mb-3">Property {idx + 1}</p>

                  <p className="text-4xl md:text-5xl font-bold text-white mb-2">
                    ~${monthlyTotal.toLocaleString()}
                  </p>
                  <p className="text-white/60 text-sm mb-4">/month all-in</p>

                  {difference > 0 ? (
                    <div className="space-y-3">
                      <p className="text-sm text-orange-300 font-medium">
                        That's ${difference.toLocaleString()} more every month than Place #{monthlyTotals.indexOf(lowestMonthly) + 1}
                      </p>

                      {annualDifference > 1000 && (
                        <div className="pt-3 border-t border-white/10">
                          <div className="flex items-start gap-2">
                            <Sparkles className="w-4 h-4 text-primary flex-shrink-0 mt-0.5" />
                            <p className="text-xs text-white/70 leading-relaxed">
                              That difference is <span className="font-semibold text-white">${annualDifference.toLocaleString()}/year</span> — basically {
                                annualDifference > 30000 ? "a new car, a Europe summer, or a future down payment chunk" :
                                annualDifference > 15000 ? "several great trips or a solid emergency fund" :
                                annualDifference > 5000 ? "a nice vacation or new furniture" :
                                "weekend getaways all year"
                              }.
                            </p>
                          </div>
                        </div>
                      )}
                    </div>
                  ) : (
                    <p className="text-sm text-green-300 font-medium">
                      This is the most affordable option monthly
                    </p>
                  )}

                  {/* Breakdown */}
                  <div className="mt-4 pt-4 border-t border-white/10 space-y-2 text-xs text-white/50">
                    <div className="flex justify-between">
                      <span>Rent</span>
                      <span className="text-white/70 font-medium">${listing.price?.toLocaleString()}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Utilities (rough)</span>
                      <span className="text-white/70 font-medium">~$150</span>
                    </div>
                  </div>
                </div>
              </motion.div>
            );
          })}
        </div>
      </motion.div>

      {/* Day One Damage */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.2 }}
      >
        <div className="mb-6">
          <h3 className="text-3xl md:text-4xl font-bold text-white mb-2">Day One Damage</h3>
          <p className="text-white/60">What you'd roughly need to wire before getting the keys</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {listings.map((listing, idx) => {
            const moveInCost = calculateMoveInCost(listing);
            const homeyTake = getHomeyTakeForMoveIn(moveInCost);

            return (
              <motion.div
                key={listing.id}
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: idx * 0.1 + 0.2 }}
                className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-primary/10 via-purple-600/10 to-pink-500/10 border border-white/10 p-8"
              >
                {/* Animated blur effect */}
                <div className="absolute top-0 right-0 w-40 h-40 bg-purple-500/20 rounded-full blur-3xl opacity-50 animate-pulse" style={{ animationDelay: '1s' }} />

                <div className="relative z-10">
                  <p className="text-sm text-white/50 mb-3">Property {idx + 1}</p>

                  <p className="text-4xl md:text-5xl font-bold text-orange-300 mb-6">
                    ${moveInCost.toLocaleString()}
                  </p>

                  <div className="flex items-start gap-3 p-4 bg-primary/10 border border-primary/20 rounded-2xl mb-4">
                    <Sparkles className="w-5 h-5 text-primary flex-shrink-0 mt-0.5" />
                    <p className="text-sm text-white/90 leading-relaxed">
                      {homeyTake}
                    </p>
                  </div>

                  {/* Breakdown */}
                  <div className="space-y-2 text-xs text-white/50">
                    <div className="flex justify-between">
                      <span>Security deposit</span>
                      <span className="text-white/70 font-medium">${listing.price?.toLocaleString()}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>First month</span>
                      <span className="text-white/70 font-medium">${listing.price?.toLocaleString()}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Last month</span>
                      <span className="text-white/70 font-medium">${listing.price?.toLocaleString()}</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Application fee</span>
                      <span className="text-white/70 font-medium">~$50</span>
                    </div>
                  </div>
                </div>
              </motion.div>
            );
          })}
        </div>
      </motion.div>

      {/* Annual View */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.4 }}
      >
        <div className="mb-6">
          <h3 className="text-3xl md:text-4xl font-bold text-white mb-2">The Annual Reality</h3>
          <p className="text-white/60">What a year here actually costs</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {listings.map((listing, idx) => {
            const annualCost = monthlyTotals[idx] * 12;

            return (
              <motion.div
                key={listing.id}
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: idx * 0.1 + 0.4 }}
                className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-primary/10 via-purple-600/10 to-pink-500/10 border border-white/10 p-8 text-center"
              >
                {/* Animated blur effect */}
                <div className="absolute bottom-0 left-0 w-40 h-40 bg-pink-500/20 rounded-full blur-3xl opacity-50 animate-pulse" style={{ animationDelay: '0.5s' }} />

                <div className="relative z-10">
                  <p className="text-sm text-white/50 mb-4">Property {idx + 1}</p>
                  <p className="text-5xl md:text-6xl font-bold text-white mb-2">
                    ${annualCost.toLocaleString()}
                  </p>
                  <p className="text-white/60">per year, all in</p>
                </div>
              </motion.div>
            );
          })}
        </div>
      </motion.div>

      {/* Thinking About Buying? */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.6 }}
      >
        <div className="mb-6">
          <h3 className="text-3xl md:text-4xl font-bold text-white mb-2">Thinking about buying?</h3>
          <p className="text-white/60">See what owning could look like with real-time mortgage scenarios</p>
        </div>

        {/* Property Selector Tabs */}
        <div className="flex gap-2 mb-6 overflow-x-auto pb-2">
          {listings.map((listing, idx) => (
            <button
              key={listing.id}
              onClick={() => setSelectedPropertyIndex(idx)}
              className={`px-4 py-2 rounded-xl font-medium whitespace-nowrap transition-all ${
                selectedPropertyIndex === idx
                  ? 'bg-gradient-to-r from-primary to-purple-500 text-white shadow-lg'
                  : 'glass-medium text-white/60 hover:text-white hover:bg-white/10'
              }`}
            >
              Property {idx + 1}
            </button>
          ))}
        </div>

        {/* Mortgage Calculator */}
        {selectedPropertyIndex !== null && listings[selectedPropertyIndex] && (() => {
          const selectedListing = listings[selectedPropertyIndex];
          const estimatedPrice = estimatePurchasePrice(selectedListing.price || 0);
          const downPaymentPercent = 20;
          const downPayment = customDownPayment || (estimatedPrice * downPaymentPercent / 100);
          const loanAmount = estimatedPrice - downPayment;

          // Current average rates (these could be fetched from an API in production)
          const rates = {
            thirtyYear: 7.0,
            fifteenYear: 6.5,
            sevenARM: 6.75
          };

          const monthlyPayment30 = calculateMortgagePayment(loanAmount, rates.thirtyYear, 30);
          const monthlyPayment15 = calculateMortgagePayment(loanAmount, rates.fifteenYear, 15);
          const monthlyPayment7ARM = calculateMortgagePayment(loanAmount, rates.sevenARM, 7);

          // Add property tax and insurance estimates
          const monthlyPropertyTax = (estimatedPrice * 0.01) / 12; // ~1% annually
          const monthlyInsurance = 150;

          return (
            <div className="space-y-6">
              {/* Estimated Purchase Price */}
              <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-green-500/10 via-emerald-500/10 to-teal-500/10 border border-green-500/20 p-8">
                <div className="absolute top-0 right-0 w-48 h-48 bg-green-500/20 rounded-full blur-3xl opacity-50 animate-pulse" />

                <div className="relative z-10">
                  <div className="flex items-start gap-3 mb-4">
                    <Home className="w-6 h-6 text-green-400 flex-shrink-0 mt-1" />
                    <div>
                      <p className="text-sm text-white/60 mb-1">Estimated Purchase Price</p>
                      <p className="text-4xl md:text-5xl font-bold text-white">
                        ${estimatedPrice.toLocaleString()}
                      </p>
                      <p className="text-xs text-white/50 mt-2">Based on NYC rent-to-price ratio</p>
                    </div>
                  </div>

                  <div className="mt-6 pt-6 border-t border-white/10">
                    <div className="flex items-center justify-between mb-2">
                      <span className="text-sm text-white/60">20% Down Payment</span>
                      <span className="text-lg font-bold text-green-400">${downPayment.toLocaleString()}</span>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-sm text-white/60">Loan Amount</span>
                      <span className="text-lg font-bold text-white">${loanAmount.toLocaleString()}</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Mortgage Options */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                {/* 30 Year Fixed */}
                <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-blue-500/10 via-cyan-500/10 to-sky-500/10 border border-blue-500/20 p-6">
                  <div className="absolute bottom-0 left-0 w-32 h-32 bg-blue-500/20 rounded-full blur-3xl opacity-50" />

                  <div className="relative z-10">
                    <div className="flex items-center gap-2 mb-4">
                      <Calculator className="w-5 h-5 text-blue-400" />
                      <h4 className="text-lg font-bold text-white">30-Year Fixed</h4>
                    </div>

                    <div className="mb-4">
                      <p className="text-3xl font-bold text-white mb-1">
                        ${Math.round(monthlyPayment30).toLocaleString()}
                      </p>
                      <p className="text-xs text-white/50">per month (P&I)</p>
                    </div>

                    <div className="space-y-2 text-xs text-white/60">
                      <div className="flex justify-between">
                        <span>Interest Rate</span>
                        <span className="text-white/80 font-medium">{rates.thirtyYear}%</span>
                      </div>
                      <div className="flex justify-between">
                        <span>+ Property Tax</span>
                        <span className="text-white/80 font-medium">${Math.round(monthlyPropertyTax).toLocaleString()}</span>
                      </div>
                      <div className="flex justify-between">
                        <span>+ Insurance</span>
                        <span className="text-white/80 font-medium">${monthlyInsurance}</span>
                      </div>
                      <div className="pt-2 border-t border-white/10 flex justify-between font-semibold">
                        <span className="text-white/80">Total Monthly</span>
                        <span className="text-white">${Math.round(monthlyPayment30 + monthlyPropertyTax + monthlyInsurance).toLocaleString()}</span>
                      </div>
                    </div>

                    <div className="mt-4 pt-4 border-t border-white/10">
                      <p className="text-xs text-white/50">
                        Total paid over 30 years: <span className="text-white font-semibold">${Math.round(monthlyPayment30 * 360).toLocaleString()}</span>
                      </p>
                    </div>
                  </div>
                </div>

                {/* 15 Year Fixed */}
                <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-purple-500/10 via-violet-500/10 to-fuchsia-500/10 border border-purple-500/20 p-6">
                  <div className="absolute bottom-0 right-0 w-32 h-32 bg-purple-500/20 rounded-full blur-3xl opacity-50" />

                  <div className="relative z-10">
                    <div className="flex items-center gap-2 mb-4">
                      <Calculator className="w-5 h-5 text-purple-400" />
                      <h4 className="text-lg font-bold text-white">15-Year Fixed</h4>
                    </div>

                    <div className="mb-4">
                      <p className="text-3xl font-bold text-white mb-1">
                        ${Math.round(monthlyPayment15).toLocaleString()}
                      </p>
                      <p className="text-xs text-white/50">per month (P&I)</p>
                    </div>

                    <div className="space-y-2 text-xs text-white/60">
                      <div className="flex justify-between">
                        <span>Interest Rate</span>
                        <span className="text-white/80 font-medium">{rates.fifteenYear}%</span>
                      </div>
                      <div className="flex justify-between">
                        <span>+ Property Tax</span>
                        <span className="text-white/80 font-medium">${Math.round(monthlyPropertyTax).toLocaleString()}</span>
                      </div>
                      <div className="flex justify-between">
                        <span>+ Insurance</span>
                        <span className="text-white/80 font-medium">${monthlyInsurance}</span>
                      </div>
                      <div className="pt-2 border-t border-white/10 flex justify-between font-semibold">
                        <span className="text-white/80">Total Monthly</span>
                        <span className="text-white">${Math.round(monthlyPayment15 + monthlyPropertyTax + monthlyInsurance).toLocaleString()}</span>
                      </div>
                    </div>

                    <div className="mt-4 pt-4 border-t border-white/10">
                      <div className="flex items-start gap-2">
                        <Sparkles className="w-3 h-3 text-purple-400 flex-shrink-0 mt-0.5" />
                        <p className="text-xs text-purple-300">
                          Save ${Math.round((monthlyPayment30 * 360) - (monthlyPayment15 * 180)).toLocaleString()} in interest vs 30-year
                        </p>
                      </div>
                    </div>
                  </div>
                </div>

                {/* 7/1 ARM */}
                <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-orange-500/10 via-amber-500/10 to-yellow-500/10 border border-orange-500/20 p-6">
                  <div className="absolute top-0 right-0 w-32 h-32 bg-orange-500/20 rounded-full blur-3xl opacity-50" />

                  <div className="relative z-10">
                    <div className="flex items-center gap-2 mb-4">
                      <Calculator className="w-5 h-5 text-orange-400" />
                      <h4 className="text-lg font-bold text-white">7/1 ARM</h4>
                    </div>

                    <div className="mb-4">
                      <p className="text-3xl font-bold text-white mb-1">
                        ${Math.round(monthlyPayment7ARM).toLocaleString()}
                      </p>
                      <p className="text-xs text-white/50">per month (P&I)</p>
                    </div>

                    <div className="space-y-2 text-xs text-white/60">
                      <div className="flex justify-between">
                        <span>Initial Rate (7 yrs)</span>
                        <span className="text-white/80 font-medium">{rates.sevenARM}%</span>
                      </div>
                      <div className="flex justify-between">
                        <span>+ Property Tax</span>
                        <span className="text-white/80 font-medium">${Math.round(monthlyPropertyTax).toLocaleString()}</span>
                      </div>
                      <div className="flex justify-between">
                        <span>+ Insurance</span>
                        <span className="text-white/80 font-medium">${monthlyInsurance}</span>
                      </div>
                      <div className="pt-2 border-t border-white/10 flex justify-between font-semibold">
                        <span className="text-white/80">Total Monthly</span>
                        <span className="text-white">${Math.round(monthlyPayment7ARM + monthlyPropertyTax + monthlyInsurance).toLocaleString()}</span>
                      </div>
                    </div>

                    <div className="mt-4 pt-4 border-t border-white/10">
                      <p className="text-xs text-orange-300">
                        ⚠️ Rate adjusts after 7 years
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Rate Source */}
              <div className="text-center">
                <p className="text-xs text-white/40">
                  Current mortgage rates as of {new Date().toLocaleDateString('en-US', { month: 'long', year: 'numeric' })} • Source: <a href="https://www.freddiemac.com/pmms" target="_blank" rel="noopener noreferrer" className="text-primary hover:underline">Freddie Mac PMMS</a>
                </p>
              </div>

              {/* Homey Insight */}
              <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-primary/10 to-purple-500/10 border border-primary/30 p-6">
                <div className="absolute bottom-0 right-0 w-48 h-48 bg-primary/30 rounded-full blur-3xl opacity-50 animate-pulse" />

                <div className="relative z-10 flex items-start gap-4">
                  <div className="w-12 h-12 bg-gradient-to-br from-primary to-purple-500 rounded-2xl flex items-center justify-center flex-shrink-0">
                    <Sparkles className="w-6 h-6 text-white" />
                  </div>
                  <div>
                    <p className="text-lg font-bold text-white mb-2">Rent vs Buy Reality Check</p>
                    <p className="text-sm text-white/80 leading-relaxed">
                      {(() => {
                        const rentMonthly = selectedListing.price || 0;
                        const buyMonthly30 = Math.round(monthlyPayment30 + monthlyPropertyTax + monthlyInsurance);
                        const difference = buyMonthly30 - rentMonthly;

                        if (difference > 1000) {
                          return `Buying would cost ~$${Math.abs(difference).toLocaleString()} more per month than renting. But you're building equity instead of paying your landlord. Over 5 years, you'd build roughly $${Math.round((downPayment + (loanAmount * 0.05))).toLocaleString()} in equity.`;
                        } else if (difference < -500) {
                          return `Buying could actually be cheaper at ~$${Math.abs(difference).toLocaleString()} less per month than renting. Plus you're building equity and locking in your housing cost.`;
                        } else {
                          return `Monthly costs are similar (~$${Math.abs(difference).toLocaleString()} ${difference > 0 ? 'more' : 'less'}), but buying means you're building equity instead of paying rent. After 5 years, you'd own roughly $${Math.round((downPayment + (loanAmount * 0.05))).toLocaleString()} in equity.`;
                        }
                      })()}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          );
        })()}
      </motion.div>

      {/* Pet & Parking */}
      {/* Additional metrics sections can be added here when more listing data becomes available */}
    </div>
  );
}
