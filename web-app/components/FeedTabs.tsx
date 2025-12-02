'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { TrendingUp, Sparkles, MessageSquare } from 'lucide-react';

interface FeedTab {
  id: string;
  label: string;
  icon: React.ReactNode;
}

interface FeedTabsProps {
  onTabChange?: (tab: string) => void;
  children?: React.ReactNode;
}

const tabs: FeedTab[] = [
  {
    id: 'all',
    label: 'All',
    icon: <Sparkles className="w-4 h-4" />
  },
  {
    id: 'insights',
    label: 'Insights',
    icon: <TrendingUp className="w-4 h-4" />
  },
  {
    id: 'market',
    label: 'Market',
    icon: <MessageSquare className="w-4 h-4" />
  }
];

export default function FeedTabs({ onTabChange, children }: FeedTabsProps) {
  const [activeTab, setActiveTab] = useState('all');

  const handleTabChange = (tabId: string) => {
    setActiveTab(tabId);
    if (onTabChange) {
      onTabChange(tabId);
    }
  };

  return (
    <div className="mb-8">
      {/* Header */}
      <div className="px-5 mb-6 text-center">
        <motion.h2
          className="text-4xl md:text-5xl font-light text-white mb-3"
          style={{ fontFamily: 'Playfair Display, serif' }}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
        >
          The Daily Edit
        </motion.h2>
        <motion.p
          className="text-white/50 text-sm tracking-wider"
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
        >
          CURATED FOR YOU · {new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric' }).toUpperCase()}
        </motion.p>
      </div>

      {/* Tab Filters */}
      <div className="px-5 mb-6">
        <div className="flex items-center justify-center gap-2">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => handleTabChange(tab.id)}
              className="relative"
            >
              <motion.div
                className={`px-6 py-3 rounded-full flex items-center gap-2 transition-all ${
                  activeTab === tab.id
                    ? 'bg-white/10 border border-white/20'
                    : 'bg-white/5 border border-white/10 hover:bg-white/10'
                }`}
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
              >
                {tab.icon}
                <span className={`text-sm font-medium ${
                  activeTab === tab.id ? 'text-white' : 'text-white/60'
                }`}>
                  {tab.label}
                </span>
              </motion.div>

              {/* Active Indicator */}
              {activeTab === tab.id && (
                <motion.div
                  className="absolute -bottom-1 left-0 right-0 h-0.5 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full"
                  layoutId="activeTab"
                  transition={{ type: 'spring', stiffness: 300, damping: 30 }}
                />
              )}
            </button>
          ))}
        </div>
      </div>

      {/* Tab Content */}
      <div className="px-5">
        {children}
      </div>
    </div>
  );
}
