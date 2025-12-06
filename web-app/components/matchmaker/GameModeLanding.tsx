'use client';

import { motion } from 'framer-motion';
import { Swords, DollarSign, Zap, Hammer, Gift, Heart, Sparkles, Award, TrendingUp } from 'lucide-react';
import type { GameMode } from './GameModeSelector';

interface GameModeCard {
  id: GameMode;
  name: string;
  tagline: string;
  description: string;
  icon: any;
  gradient: string;
  badge: string;
  features: string[];
  stats?: {
    label: string;
    value: string;
  };
}

interface GameModeLandingProps {
  onSelectMode: (mode: GameMode) => void;
  userStats: {
    totalSwipes: number;
    streak: number;
  };
}

const gameModes: GameModeCard[] = [
  {
    id: 'swipe',
    name: 'Classic Swipe',
    tagline: 'The OG Matchmaker',
    description: 'Tinder-style swiping with AI-powered match scores',
    icon: Heart,
    gradient: 'from-pink-500 via-purple-500 to-blue-500',
    badge: 'Most Popular',
    features: ['Match scoring', 'Smart recommendations', 'Undo swipes'],
    stats: { label: 'Swipes', value: '2.4M+' },
  },
  {
    id: 'battle',
    name: 'This or That',
    tagline: 'Side-by-Side Showdown',
    description: '30-second battles to choose your favorite',
    icon: Swords,
    gradient: 'from-orange-500 via-red-500 to-pink-500',
    badge: 'Fast-Paced',
    features: ['Quick decisions', 'Head-to-head', 'Rapid learning'],
    stats: { label: 'Avg Time', value: '30s' },
  },
  {
    id: 'guess',
    name: 'Guess the Rent',
    tagline: 'Test Your Market IQ',
    description: 'Guess monthly rent and earn points for accuracy',
    icon: DollarSign,
    gradient: 'from-green-500 via-emerald-500 to-teal-500',
    badge: 'Educational',
    features: ['100pts for ±$100', 'Leaderboard', 'Market knowledge'],
    stats: { label: 'Best Score', value: '95%' },
  },
  {
    id: 'speed',
    name: 'Speed Round',
    tagline: 'Beat the Clock',
    description: '60 seconds to make as many decisions as possible',
    icon: Zap,
    gradient: 'from-yellow-500 via-orange-500 to-red-500',
    badge: 'High Energy',
    features: ['60-second timer', 'Gut reactions', 'Fast Learner badge'],
    stats: { label: 'Record', value: '47 swipes' },
  },
  {
    id: 'build',
    name: 'Build Your Dream',
    tagline: 'Fantasy Apartment Builder',
    description: 'Create your perfect home with real-time pricing',
    icon: Hammer,
    gradient: 'from-blue-500 via-cyan-500 to-purple-500',
    badge: 'Creative',
    features: ['4-step wizard', 'Live pricing', 'Custom features'],
    stats: { label: 'Avg Build', value: '$3,800/mo' },
  },
  {
    id: 'mystery',
    name: 'Mystery Box',
    tagline: 'Surprise Me!',
    description: 'Open boxes to reveal random properties',
    icon: Gift,
    gradient: 'from-purple-500 via-pink-500 to-red-500',
    badge: 'Daily Rewards',
    features: ['3 free daily', 'Premium unlocks', 'Surprise element'],
    stats: { label: 'Today', value: '3 boxes left' },
  },
];

export default function GameModeLanding({ onSelectMode, userStats }: GameModeLandingProps) {
  return (
    <div className="relative min-h-screen overflow-y-auto pb-32">
      {/* Hero Section */}
      <div className="px-4 md:px-6 py-8 md:py-12">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center max-w-3xl mx-auto mb-12"
        >
          <div className="inline-flex items-center gap-2 px-4 py-2 bg-gradient-to-r from-primary/20 to-purple-500/20 border border-primary/30 rounded-full mb-6">
            <Sparkles className="w-4 h-4 text-primary" />
            <span className="text-sm font-semibold text-primary">6 Ways to Find Your Home</span>
          </div>

          <h1 className="text-4xl md:text-5xl font-bold text-white mb-4">
            Choose Your Adventure
          </h1>
          <p className="text-lg text-white/70 mb-8">
            Every game mode helps you discover properties in a unique way.
            Pick one and start building your preference profile!
          </p>

          {/* User Stats */}
          <div className="flex items-center justify-center gap-6">
            <div className="glass-medium rounded-xl px-6 py-3 border border-white/10">
              <div className="flex items-center gap-2 mb-1">
                <TrendingUp className="w-4 h-4 text-primary" />
                <span className="text-sm text-white/60">Total Swipes</span>
              </div>
              <p className="text-2xl font-bold text-white">{userStats.totalSwipes}</p>
            </div>

            {userStats.streak > 0 && (
              <div className="glass-medium rounded-xl px-6 py-3 border border-orange-500/30 bg-orange-500/10">
                <div className="flex items-center gap-2 mb-1">
                  <Zap className="w-4 h-4 text-orange-400" />
                  <span className="text-sm text-orange-300">Streak</span>
                </div>
                <p className="text-2xl font-bold text-orange-300">{userStats.streak} days 🔥</p>
              </div>
            )}

            <div className="glass-medium rounded-xl px-6 py-3 border border-purple-500/30 bg-purple-500/10">
              <div className="flex items-center gap-2 mb-1">
                <Award className="w-4 h-4 text-purple-400" />
                <span className="text-sm text-purple-300">Badges</span>
              </div>
              <p className="text-2xl font-bold text-purple-300">3</p>
            </div>
          </div>
        </motion.div>

        {/* Game Mode Grid */}
        <div className="grid grid-cols-2 md:grid-cols-2 lg:grid-cols-3 gap-3 md:gap-6 max-w-7xl mx-auto">
          {gameModes.map((mode, index) => {
            const Icon = mode.icon;

            return (
              <motion.button
                key={mode.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1 }}
                onClick={() => onSelectMode(mode.id)}
                className="group relative glass-strong rounded-2xl p-6 border border-white/10 hover:border-white/30 transition-all overflow-hidden text-left"
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
              >
                {/* Background Gradient */}
                <div className={`absolute inset-0 bg-gradient-to-br ${mode.gradient} opacity-0 group-hover:opacity-10 transition-opacity`} />

                {/* Badge */}
                <div className="absolute top-4 right-4 px-2 py-1 bg-white/10 backdrop-blur-sm rounded-full border border-white/20">
                  <span className="text-[10px] font-bold text-white/80">{mode.badge}</span>
                </div>

                {/* Icon */}
                <div className={`relative w-14 h-14 rounded-xl bg-gradient-to-br ${mode.gradient} flex items-center justify-center mb-4 group-hover:scale-110 transition-transform`}>
                  <Icon className="w-7 h-7 text-white" />
                </div>

                {/* Content */}
                <div className="relative">
                  <h3 className="text-xl font-bold text-white mb-1">{mode.name}</h3>
                  <p className="text-sm font-medium text-primary mb-3">{mode.tagline}</p>
                  <p className="text-sm text-white/70 mb-4">{mode.description}</p>

                  {/* Features */}
                  <div className="space-y-1.5 mb-4">
                    {mode.features.map((feature, i) => (
                      <div key={i} className="flex items-center gap-2">
                        <div className={`w-1.5 h-1.5 rounded-full bg-gradient-to-r ${mode.gradient}`} />
                        <span className="text-xs text-white/60">{feature}</span>
                      </div>
                    ))}
                  </div>

                  {/* Stats */}
                  {mode.stats && (
                    <div className="pt-4 border-t border-white/10">
                      <div className="flex items-center justify-between">
                        <span className="text-xs text-white/50">{mode.stats.label}</span>
                        <span className="text-sm font-bold text-white">{mode.stats.value}</span>
                      </div>
                    </div>
                  )}
                </div>

                {/* Hover Indicator */}
                <div className="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-transparent via-white/50 to-transparent transform scale-x-0 group-hover:scale-x-100 transition-transform" />
              </motion.button>
            );
          })}
        </div>

        {/* Info Card */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
          className="mt-12 max-w-2xl mx-auto p-6 glass-medium rounded-2xl border border-cyan-500/30 bg-cyan-500/5"
        >
          <div className="flex items-start gap-4">
            <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-cyan-500 to-blue-500 flex items-center justify-center flex-shrink-0">
              <Sparkles className="w-6 h-6 text-white" />
            </div>
            <div>
              <h4 className="text-lg font-bold text-white mb-2">How It Works</h4>
              <p className="text-sm text-white/70 mb-3">
                Each game mode teaches our AI what you love in different ways. The more you play,
                the smarter your recommendations become!
              </p>
              <ul className="space-y-1 text-xs text-white/60">
                <li>• All modes contribute to your preference profile</li>
                <li>• Earn badges and unlock premium features</li>
                <li>• Switch between modes anytime</li>
                <li>• Track your progress and compete on leaderboards</li>
              </ul>
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
