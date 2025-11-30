'use client';

import { ReactNode } from 'react';

interface FeedRowProps {
  title: string;
  subtitle?: string;
  children: ReactNode;
  onSeeAll?: () => void;
}

export default function FeedRow({ title, subtitle, children, onSeeAll }: FeedRowProps) {
  return (
    <div className="mb-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-4 px-5">
        <div>
          <h2 className="text-xl font-bold text-white">{title}</h2>
          {subtitle && (
            <p className="text-sm text-white/60 mt-0.5">{subtitle}</p>
          )}
        </div>
        {onSeeAll && (
          <button
            onClick={onSeeAll}
            className="text-sm font-semibold text-primary hover:text-primary/80 transition-colors"
          >
            See All →
          </button>
        )}
      </div>

      {/* Horizontal scroll container */}
      <div className="overflow-x-auto scrollbar-hide">
        <div className="flex gap-4 px-5 pb-2">
          {children}
        </div>
      </div>
    </div>
  );
}
