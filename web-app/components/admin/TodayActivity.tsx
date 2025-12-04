'use client';

import { motion } from 'framer-motion';
import { TrendingUp, Users, Heart, Home, Activity as ActivityIcon, Zap } from 'lucide-react';

interface ActivityStat {
  label: string;
  value: string | number;
  change: string;
  icon: any;
  color: string;
}

export default function TodayActivity() {
  // Mock data - replace with actual data fetching
  const stats: ActivityStat[] = [
    {
      label: 'New Sign-ups',
      value: 12,
      change: '+4 from yesterday',
      icon: Users,
      color: 'from-blue-500 to-cyan-500'
    },
    {
      label: 'Property Swipes',
      value: '1.2k',
      change: '+23% today',
      icon: ActivityIcon,
      color: 'from-purple-500 to-pink-500'
    },
    {
      label: 'Likes',
      value: 342,
      change: '+89 this hour',
      icon: Heart,
      color: 'from-pink-500 to-rose-500'
    },
    {
      label: 'Active Users',
      value: 156,
      change: 'Right now',
      icon: Zap,
      color: 'from-yellow-500 to-orange-500'
    }
  ];

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="glass-strong rounded-xl md:rounded-2xl border border-white/10 p-4 md:p-6"
    >
      <div className="flex items-center justify-between mb-4 md:mb-6">
        <div>
          <h2 className="text-lg md:text-xl font-bold text-white">Today's Activity</h2>
          <p className="text-xs md:text-sm text-white/60">{new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}</p>
        </div>
        <div className="flex items-center gap-2 px-3 py-1.5 bg-green-500/20 border border-green-500/30 rounded-full">
          <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse" />
          <span className="text-xs font-medium text-green-400">Live</span>
        </div>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 md:gap-4">
        {stats.map((stat, index) => {
          const Icon = stat.icon;
          return (
            <motion.div
              key={stat.label}
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: index * 0.05 }}
              className="p-3 md:p-4 bg-white/5 rounded-lg md:rounded-xl border border-white/5 hover:border-white/10 transition-all"
            >
              <div className={`w-8 h-8 md:w-10 md:h-10 rounded-lg bg-gradient-to-br ${stat.color} bg-opacity-20 flex items-center justify-center mb-2 md:mb-3`}>
                <Icon className="w-4 h-4 md:w-5 md:h-5 text-white" />
              </div>
              <div className="text-xl md:text-2xl font-bold text-white mb-1">
                {stat.value}
              </div>
              <div className="text-xs md:text-sm text-white/80 mb-1">{stat.label}</div>
              <div className="text-[10px] md:text-xs text-white/50">{stat.change}</div>
            </motion.div>
          );
        })}
      </div>
    </motion.div>
  );
}
