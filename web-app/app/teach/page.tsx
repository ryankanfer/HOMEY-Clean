'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { db, auth } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';
import CinematicBackground from '@/components/CinematicBackground';
import BottomNav from '@/components/BottomNav';

const TEACHING_TOOLS = [
  {
    id: 'this-or-that',
    title: 'This or That',
    subtitle: 'Quick Preference Game',
    icon: '⚡',
    category: 'Quick & Fun',
    color: 'from-yellow-500 to-orange-500',
    description: 'Rapid-fire choices to quickly teach your preferences',
    timeEstimate: '2 min',
    completed: false,
  },
  {
    id: 'floor-plans',
    title: 'Floor Plan Preferences',
    subtitle: 'Visual Layout Quiz',
    icon: '📐',
    category: 'Quick & Fun',
    color: 'from-blue-500 to-cyan-500',
    description: 'Swipe on different floor plan layouts',
    timeEstimate: '3 min',
    completed: false,
  },
  {
    id: 'feature-ranking',
    title: 'Feature Ranking',
    subtitle: 'Drag & Drop Priorities',
    icon: '🎯',
    category: 'Deep Preferences',
    color: 'from-primary to-purple-500',
    description: 'Rank features from must-have to nice-to-have',
    timeEstimate: '5 min',
    completed: false,
  },
  {
    id: 'deal-breakers',
    title: 'Deal Breakers',
    subtitle: 'Absolute No-Gos',
    icon: '🚫',
    category: 'Deep Preferences',
    color: 'from-red-500 to-pink-500',
    description: 'Select what you absolutely cannot compromise on',
    timeEstimate: '2 min',
    completed: false,
  },
  {
    id: 'trade-offs',
    title: 'Trade-Off Analyzer',
    subtitle: 'Budget vs Features',
    icon: '⚖️',
    category: 'Deep Preferences',
    color: 'from-purple-500 to-pink-500',
    description: 'Choose what you would sacrifice for lower rent',
    timeEstimate: '4 min',
    completed: false,
  },
  {
    id: 'budget-comfort',
    title: 'Budget Comfort Zone',
    subtitle: 'Income Calculator',
    icon: '💰',
    category: 'Budget & Location',
    color: 'from-green-500 to-emerald-500',
    description: 'Define your comfortable rent range with NYC 40x rule',
    timeEstimate: '3 min',
    completed: false,
  },
  {
    id: 'commute',
    title: 'Commute Calculator',
    subtitle: 'Location Priorities',
    icon: '🚇',
    category: 'Budget & Location',
    color: 'from-blue-500 to-indigo-500',
    description: 'Filter neighborhoods by commute time',
    timeEstimate: '4 min',
    completed: false,
  },
  {
    id: 'neighborhoods',
    title: 'Neighborhood Explorer',
    subtitle: 'Lifestyle Matching',
    icon: '🗺️',
    category: 'Budget & Location',
    color: 'from-cyan-500 to-blue-500',
    description: 'Answer questions to find your perfect neighborhood',
    timeEstimate: '5 min',
    completed: false,
  },
  {
    id: 'lifestyle',
    title: 'Lifestyle Matcher',
    subtitle: 'Daily Routine Analysis',
    icon: '☀️',
    category: 'Lifestyle',
    color: 'from-orange-500 to-red-500',
    description: 'Match your daily habits to property features',
    timeEstimate: '4 min',
    completed: false,
  },
  {
    id: 'virtual-tours',
    title: 'Virtual Tour Reactions',
    subtitle: 'Video Preferences',
    icon: '🎥',
    category: 'Lifestyle',
    color: 'from-pink-500 to-rose-500',
    description: 'React to property videos to train the AI',
    timeEstimate: '10 min',
    completed: false,
  },
];

export default function TeachHomeyPage() {
  const router = useRouter();
  const [userId, setUserId] = useState<string | null>(null);
  const [selectedTool, setSelectedTool] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [activeCategory, setActiveCategory] = useState<string>('All');

  useEffect(() => {
    loadUser();
    analytics.pageView('teach_homey');
  }, []);

  const loadUser = async () => {
    try {
      const { data: { user } } = await auth.getUser();

      if (!user) {
        router.push('/');
        return;
      }

      setUserId(user.id);
      setIsLoading(false);
    } catch (error) {
      console.error('Failed to load user:', error);
      setIsLoading(false);
    }
  };

  const categories = ['All', 'Quick & Fun', 'Deep Preferences', 'Budget & Location', 'Lifestyle'];

  const filteredTools = activeCategory === 'All'
    ? TEACHING_TOOLS
    : TEACHING_TOOLS.filter(tool => tool.category === activeCategory);

  const completedCount = TEACHING_TOOLS.filter(t => t.completed).length;
  const totalCount = TEACHING_TOOLS.length;
  const progress = (completedCount / totalCount) * 100;

  if (isLoading) {
    return (
      <main className="relative min-h-screen flex items-center justify-center">
        <CinematicBackground timeOfDay="day" />
        <div className="relative z-10">
          <div className="w-12 h-12 border-4 border-white/20 border-t-primary rounded-full animate-spin" />
        </div>
      </main>
    );
  }

  return (
    <main className="relative min-h-screen pb-24">
      <CinematicBackground timeOfDay="day" />

      {/* Dark overlay for better text contrast */}
      <div className="fixed inset-0 z-0 bg-gradient-to-b from-black/40 via-black/30 to-black/50" />

      {/* Header */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-gradient-to-b from-black/80 via-black/60 to-transparent backdrop-blur-md">
        <div className="flex items-center justify-between px-5 py-4">
          <button
            onClick={() => router.back()}
            className="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center text-xl hover:bg-white/20 transition-colors text-white"
          >
            ←
          </button>
          <h1 className="text-xl font-bold text-white">Teach Homey</h1>
          <div className="w-10" />
        </div>

        {/* Progress Bar */}
        <div className="px-5 pb-4">
          <div className="flex items-center justify-between mb-2">
            <span className="text-white/60 text-sm">{completedCount} of {totalCount} completed</span>
            <span className="text-white/60 text-sm">{Math.round(progress)}%</span>
          </div>
          <div className="w-full h-2 bg-white/10 rounded-full overflow-hidden">
            <motion.div
              className="h-full bg-gradient-to-r from-primary via-purple-500 to-pink-500"
              initial={{ width: 0 }}
              animate={{ width: `${progress}%` }}
              transition={{ duration: 0.5 }}
            />
          </div>
        </div>
      </header>

      {/* Content */}
      <div className="relative z-10 pt-32 pb-32 px-5 max-w-6xl mx-auto">
        {/* Hero Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-12"
        >
          <div className="text-7xl mb-6">🧠</div>
          <h2 className="text-4xl md:text-5xl font-light text-white mb-4 drop-shadow-lg" style={{ fontFamily: 'Playfair Display, serif', textShadow: '0 2px 8px rgba(0,0,0,0.4)' }}>
            Teach Homey Your Perfect Home
          </h2>
          <p className="text-white text-lg max-w-2xl mx-auto drop-shadow-md">
            Complete these interactive tools to help our AI understand exactly what you're looking for. The more you teach, the smarter your recommendations become.
          </p>
        </motion.div>

        {/* Category Filter */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.2 }}
          className="flex gap-3 mb-8 overflow-x-auto scrollbar-hide pb-2"
        >
          {categories.map((category) => (
            <button
              key={category}
              onClick={() => setActiveCategory(category)}
              className={`px-6 py-3 rounded-full font-medium whitespace-nowrap transition-all ${
                activeCategory === category
                  ? 'bg-gradient-to-r from-primary via-purple-500 to-pink-500 text-white'
                  : 'bg-white/10 text-white/70 hover:bg-white/20'
              }`}
            >
              {category}
            </button>
          ))}
        </motion.div>

        {/* Tools Grid */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredTools.map((tool, index) => (
            <motion.div
              key={tool.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 * index }}
              onClick={() => setSelectedTool(tool.id)}
              className="glass-strong rounded-2xl p-6 cursor-pointer hover:scale-105 transition-transform border border-white/10 hover:border-primary/40 relative group"
            >
              {/* Completion Badge */}
              {tool.completed && (
                <div className="absolute top-4 right-4 w-8 h-8 rounded-full bg-green-500 flex items-center justify-center text-white text-sm font-bold">
                  ✓
                </div>
              )}

              {/* Icon */}
              <div className={`w-16 h-16 rounded-2xl bg-gradient-to-br ${tool.color} flex items-center justify-center text-3xl mb-4 group-hover:scale-110 transition-transform`}>
                {tool.icon}
              </div>

              {/* Content */}
              <h3 className="text-white font-semibold text-lg mb-1">{tool.title}</h3>
              <p className={`text-sm font-medium mb-3 bg-gradient-to-r ${tool.color} bg-clip-text text-transparent`}>
                {tool.subtitle}
              </p>
              <p className="text-white/60 text-sm mb-4 leading-relaxed">
                {tool.description}
              </p>

              {/* Footer */}
              <div className="flex items-center justify-between text-xs">
                <span className="text-white/40">{tool.timeEstimate}</span>
                <span className="text-primary group-hover:translate-x-1 transition-transform">
                  {tool.completed ? 'Retake →' : 'Start →'}
                </span>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Coming Soon Message */}
        {selectedTool && (
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-5"
            onClick={() => setSelectedTool(null)}
          >
            <div className="glass-strong rounded-3xl p-8 max-w-md text-center" onClick={(e) => e.stopPropagation()}>
              <div className="text-6xl mb-4">🚧</div>
              <h3 className="text-2xl font-bold text-white mb-3">Coming Soon!</h3>
              <p className="text-white/70 mb-6">
                This interactive tool is being built. Check back soon for a fun way to teach Homey your preferences!
              </p>
              <button
                onClick={() => setSelectedTool(null)}
                className="px-6 py-3 bg-gradient-to-r from-primary via-purple-500 to-pink-500 text-white font-semibold rounded-full hover:shadow-lg hover:shadow-primary/50 transition-all"
              >
                Got it
              </button>
            </div>
          </motion.div>
        )}
      </div>

      {/* Bottom Navigation */}
      <BottomNav />
    </main>
  );
}
