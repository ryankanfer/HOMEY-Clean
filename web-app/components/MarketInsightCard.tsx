'use client';

import { motion } from 'framer-motion';
import { TrendingDown, TrendingUp, Minus, ArrowRight } from 'lucide-react';

interface MarketInsightCardProps {
  title: string;
  stat: string;
  trend: 'up' | 'down' | 'neutral';
  trendLabel: string;
  description: string;
  ctaText: string;
  onCtaClick?: () => void;
  neighborhood?: string;
}

export default function MarketInsightCard({
  title,
  stat,
  trend,
  trendLabel,
  description,
  ctaText,
  onCtaClick,
  neighborhood
}: MarketInsightCardProps) {
  const getTrendIcon = () => {
    switch (trend) {
      case 'up':
        return <TrendingUp className="w-5 h-5" />;
      case 'down':
        return <TrendingDown className="w-5 h-5" />;
      default:
        return <Minus className="w-5 h-5" />;
    }
  };

  const getTrendColor = () => {
    switch (trend) {
      case 'up':
        return 'text-green-400 bg-green-500/20 border-green-500/50';
      case 'down':
        return 'text-red-400 bg-red-500/20 border-red-500/50';
      default:
        return 'text-yellow-400 bg-yellow-500/20 border-yellow-500/50';
    }
  };

  return (
    <motion.div
      className="relative min-w-[320px] h-[400px] rounded-2xl overflow-hidden cursor-pointer group bg-slate-800/50 backdrop-blur-md border border-white/10"
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
      onClick={onCtaClick}
    >
      {/* Gradient Accent */}
      <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-blue-500 via-cyan-500 to-blue-500" />

      {/* Content */}
      <div className="relative h-full flex flex-col justify-between p-6">
        {/* Header */}
        <div>
          {/* Category Badge */}
          <span className="inline-block px-3 py-1.5 rounded-full bg-blue-500/20 backdrop-blur-sm border border-blue-500/50 text-blue-300 text-xs font-semibold mb-4">
            Market Insight
          </span>

          {/* Title */}
          <h3 className="text-white font-bold text-xl mb-3 leading-tight">
            {title}
          </h3>

          {neighborhood && (
            <p className="text-white/50 text-sm mb-4">{neighborhood}</p>
          )}

          {/* Stat Display */}
          <div className="flex items-center gap-3 mb-4">
            <div className="text-4xl font-bold text-white">{stat}</div>
            <div className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full ${getTrendColor()} text-sm font-semibold`}>
              {getTrendIcon()}
              {trendLabel}
            </div>
          </div>

          {/* Description */}
          <p className="text-white/70 text-sm leading-relaxed">
            {description}
          </p>
        </div>

        {/* CTA Button */}
        <button
          onClick={(e) => {
            e.stopPropagation();
            onCtaClick?.();
          }}
          className="w-full py-3 px-4 rounded-xl bg-gradient-to-r from-blue-500/20 to-cyan-500/20 border border-blue-500/30 text-white font-semibold hover:from-blue-500/30 hover:to-cyan-500/30 transition-all flex items-center justify-center gap-2 group-hover:border-blue-500/50"
        >
          <span>{ctaText}</span>
          <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
        </button>
      </div>
    </motion.div>
  );
}
