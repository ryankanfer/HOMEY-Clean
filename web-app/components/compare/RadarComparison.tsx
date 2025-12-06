'use client';

import { useMemo } from 'react';
import type { Listing } from '@/lib/types';
import { Radar, RadarChart, PolarGrid, PolarAngleAxis, PolarRadiusAxis, ResponsiveContainer, Legend } from 'recharts';

interface RadarComparisonProps {
  listings: Listing[];
}

export default function RadarComparison({ listings }: RadarComparisonProps) {
  const chartData = useMemo(() => {
    const metrics = ['Price', 'Space', 'Location', 'Amenities', 'Condition'];

    return metrics.map(metric => {
      const dataPoint: any = { metric };

      listings.forEach((listing, idx) => {
        let value = 50; // default

        switch (metric) {
          case 'Price':
            // Normalize price (lower is better, so invert)
            const maxPrice = Math.max(...listings.map(l => l.price || 0));
            const minPrice = Math.min(...listings.map(l => l.price || 0).filter(p => p > 0));
            if (maxPrice > minPrice && listing.price) {
              value = ((maxPrice - listing.price) / (maxPrice - minPrice)) * 100;
            }
            break;

          case 'Space':
            const sqft = listing.square_footage || 0;
            const maxSqft = Math.max(...listings.map(l => l.square_footage || 0));
            const minSqft = Math.min(...listings.map(l => l.square_footage || 0).filter(s => s > 0));
            if (maxSqft > minSqft && sqft) {
              value = ((sqft - minSqft) / (maxSqft - minSqft)) * 100;
            }
            break;

          case 'Location':
            value = listing.walk_score || 50;
            break;

          case 'Amenities':
            const amenityCount = (listing.amenities || []).length;
            const maxAmenities = Math.max(...listings.map(l => (l.amenities || []).length));
            if (maxAmenities > 0) {
              value = (amenityCount / maxAmenities) * 100;
            }
            break;

          case 'Condition':
            // Based on is_new_to_market and other quality indicators
            if (listing.is_new_to_market) value += 20;
            if (listing.is_featured) value += 20;
            value = Math.min(value, 100);
            break;
        }

        dataPoint[`Property ${idx + 1}`] = Math.round(value);
      });

      return dataPoint;
    });
  }, [listings]);

  const colors = ['#8b5cf6', '#ec4899', '#06b6d4'];

  return (
    <div className="glass-strong rounded-2xl border border-white/10 p-6">
      <h3 className="text-xl font-bold text-white mb-4">Overall Comparison</h3>

      <ResponsiveContainer width="100%" height={350}>
        <RadarChart data={chartData}>
          <PolarGrid stroke="#ffffff20" />
          <PolarAngleAxis
            dataKey="metric"
            tick={{ fill: '#ffffff80', fontSize: 12 }}
          />
          <PolarRadiusAxis
            angle={90}
            domain={[0, 100]}
            tick={{ fill: '#ffffff60', fontSize: 10 }}
          />
          {listings.map((listing, idx) => (
            <Radar
              key={listing.id}
              name={`Property ${idx + 1}`}
              dataKey={`Property ${idx + 1}`}
              stroke={colors[idx % colors.length]}
              fill={colors[idx % colors.length]}
              fillOpacity={0.25}
              strokeWidth={2}
            />
          ))}
          <Legend
            wrapperStyle={{
              paddingTop: '20px',
              fontSize: '12px',
            }}
            iconType="circle"
          />
        </RadarChart>
      </ResponsiveContainer>

      <div className="mt-4 grid grid-cols-3 gap-4">
        {listings.map((listing, idx) => (
          <div
            key={listing.id}
            className="p-3 bg-white/5 rounded-lg border border-white/10"
          >
            <div className="flex items-center gap-2 mb-1">
              <div
                className="w-3 h-3 rounded-full"
                style={{ backgroundColor: colors[idx % colors.length] }}
              />
              <span className="text-xs text-white/60">Property {idx + 1}</span>
            </div>
            <p className="text-sm text-white font-medium truncate">
              {listing.neighborhood}
            </p>
          </div>
        ))}
      </div>
    </div>
  );
}
