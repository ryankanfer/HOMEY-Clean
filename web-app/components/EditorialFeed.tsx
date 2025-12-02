'use client';

import { motion } from 'framer-motion';
import VibeCheckCard from './VibeCheckCard';
import MarketInsightCard from './MarketInsightCard';

type FilterType = 'all' | 'insights' | 'market';

interface EditorialFeedProps {
  userNeighborhoods?: string[];
  activeTab?: string;
  hasSwipeData?: boolean;
}

export default function EditorialFeed({
  userNeighborhoods = [],
  activeTab = 'all',
  hasSwipeData = false
}: EditorialFeedProps) {

  // Sample editorial content - this would come from an API/CMS in production
  const vibeCheckContent = [
    {
      neighborhood: 'East Village',
      quote: 'The Saturday farmers market changed everything for me. Fresh produce, live music, and I met half my friend group there.',
      author: 'Sarah Chen',
      authorTitle: 'Resident since 2021',
      imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&q=80',
      category: 'Vibe Check'
    },
    {
      neighborhood: 'Williamsburg',
      quote: 'Every Sunday I walk to the waterfront for bagels at dawn. The skyline view never gets old, and neither does the everything bagel.',
      author: 'Marcus Johnson',
      authorTitle: 'Local since 2019',
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&q=80',
      category: 'Vibe Check'
    },
    {
      neighborhood: 'Park Slope',
      quote: 'The parks, the brownstones, the tree-lined streets... it feels like a small town inside a big city. My kids can actually play outside.',
      author: 'Jessica Rodriguez',
      authorTitle: 'Family of four',
      imageUrl: 'https://images.unsplash.com/photo-1541534401786-2eedac8a27a3?w=800&q=80',
      category: 'Vibe Check'
    }
  ];

  const marketInsights = [
    {
      title: 'Williamsburg Rental Market Cooling',
      stat: '2.3%',
      trend: 'down' as const,
      trendLabel: 'vs last month',
      description: 'Average rent dropped from $3,850 to $3,761. More negotiating power for renters this month.',
      ctaText: 'View Full Report',
      neighborhood: 'Williamsburg, Brooklyn'
    },
    {
      title: 'East Village Seeing More Inventory',
      stat: '+42',
      trend: 'up' as const,
      trendLabel: 'new listings',
      description: '42 new rentals hit the market this week. Competition is easing up, giving you more options.',
      ctaText: 'Browse Listings',
      neighborhood: 'East Village, Manhattan'
    },
    {
      title: 'Astoria Holding Steady',
      stat: '$2,845',
      trend: 'neutral' as const,
      trendLabel: 'stable',
      description: 'Median rent unchanged for 3 months. Predictable pricing makes budgeting easier.',
      ctaText: 'Explore Astoria',
      neighborhood: 'Astoria, Queens'
    },
    {
      title: 'Park Slope Demand Rising',
      stat: '18%',
      trend: 'up' as const,
      trendLabel: 'faster bookings',
      description: 'Properties are getting snatched up 18% faster than last quarter. Act quickly on favorites.',
      ctaText: 'See Hot Listings',
      neighborhood: 'Park Slope, Brooklyn'
    }
  ];

  const allContent = [
    { type: 'vibe', data: vibeCheckContent[0] },
    { type: 'market', data: marketInsights[0] },
    { type: 'vibe', data: vibeCheckContent[1] },
    { type: 'market', data: marketInsights[1] },
    { type: 'vibe', data: vibeCheckContent[2] },
    { type: 'market', data: marketInsights[2] },
    { type: 'market', data: marketInsights[3] }
  ];

  // Apply tab filtering (show all sample content for now - CMS integration later)
  const getFilteredContent = () => {
    if (activeTab === 'insights') {
      return allContent.filter(item => item.type === 'vibe');
    }
    if (activeTab === 'market') {
      return allContent.filter(item => item.type === 'market');
    }
    return allContent;
  };

  const filteredContent = getFilteredContent();

  return (
    <div>
      {/* Horizontal Scroll Feed */}
      <div className="overflow-x-auto scrollbar-hide snap-x snap-mandatory">
        <div className="flex gap-4 px-5 pb-4">
          {filteredContent.map((item, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: index * 0.05 }}
              className="snap-start"
            >
              {item.type === 'vibe' ? (
                <VibeCheckCard {...(item.data as any)} />
              ) : (
                <MarketInsightCard
                  {...(item.data as any)}
                  onCtaClick={() => {
                    console.log('CTA clicked:', item.data);
                    // Handle CTA click - could navigate to search/market pages
                  }}
                />
              )}
            </motion.div>
          ))}
        </div>
      </div>

      {/* Scrollbar hint */}
      <style jsx>{`
        .scrollbar-hide::-webkit-scrollbar {
          display: none;
        }
        .scrollbar-hide {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
      `}</style>
    </div>
  );
}
