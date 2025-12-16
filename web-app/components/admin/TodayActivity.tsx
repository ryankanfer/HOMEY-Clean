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
  // TODO: Fetch actual activity data from Supabase
  const stats: ActivityStat[] = [];

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
            <motion.button
              key={stat.label}
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: index * 0.05 }}
              onClick={() => console.log(`View details for: ${stat.label}`)}
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="p-3 md:p-4 bg-white/5 rounded-lg md:rounded-xl border border-white/5 hover:border-white/20 hover:bg-white/10 transition-all cursor-pointer text-left"
            >
              <div className={`w-8 h-8 md:w-10 md:h-10 rounded-lg bg-gradient-to-br ${stat.color} bg-opacity-20 flex items-center justify-center mb-2 md:mb-3`}>
                <Icon className="w-4 h-4 md:w-5 md:h-5 text-white" />
              </div>
              <div className="text-xl md:text-2xl font-bold text-white mb-1">
                {stat.value}
              </div>
              <div className="text-xs md:text-sm text-white/80 mb-1">{stat.label}</div>
              <div className="text-[10px] md:text-xs text-white/50">{stat.change}</div>
            </motion.button>
          );
        })}
      </div>
    </motion.div>
  );
}
