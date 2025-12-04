'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Activity, User, Search, Heart, LogIn, ChevronDown, ChevronUp, Filter } from 'lucide-react';
import { supabase } from '@/lib/supabase';

interface ActivityItem {
  id: string;
  type: 'login' | 'search' | 'save' | 'view' | 'message';
  user_type: 'client' | 'agent' | 'unknown';
  user_name: string;
  description: string;
  timestamp: Date;
}

export default function ActivityFeed() {
  const [activities, setActivities] = useState<ActivityItem[]>([]);
  const [isExpanded, setIsExpanded] = useState(true);
  const [filter, setFilter] = useState<'all' | 'client' | 'agent'>('all');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadRecentActivity();

    // Refresh every 30 seconds
    const interval = setInterval(loadRecentActivity, 30000);
    return () => clearInterval(interval);
  }, []);

  const loadRecentActivity = async () => {
    try {
      // Get recent profiles (last 24 hours)
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);

      const { data: profiles, error } = await supabase
        .from('profiles')
        .select('*')
        .gte('created_at', yesterday.toISOString())
        .order('created_at', { ascending: false })
        .limit(20);

      if (error) throw error;

      // Transform to activity items
      const items: ActivityItem[] = (profiles || []).map((profile) => ({
        id: profile.id,
        type: 'login' as const,
        user_type: profile.user_type || 'unknown',
        user_name: profile.full_name || profile.email || 'Anonymous',
        description: `New ${profile.user_type || 'user'} signed up`,
        timestamp: new Date(profile.created_at),
      }));

      setActivities(items);
    } catch (error) {
      console.error('Error loading activity:', error);
    } finally {
      setLoading(false);
    }
  };

  const getIcon = (type: string) => {
    switch (type) {
      case 'login': return LogIn;
      case 'search': return Search;
      case 'save': return Heart;
      case 'view': return User;
      default: return Activity;
    }
  };

  const getTimeAgo = (date: Date) => {
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);

    if (minutes < 1) return 'Just now';
    if (minutes < 60) return `${minutes}m ago`;
    if (hours < 24) return `${hours}h ago`;
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  };

  const filteredActivities = activities.filter(a =>
    filter === 'all' || a.user_type === filter
  );

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="glass-strong rounded-2xl border border-white/10 overflow-hidden"
    >
      {/* Header */}
      <button
        onClick={() => setIsExpanded(!isExpanded)}
        className="w-full px-4 md:px-6 py-4 flex items-center justify-between hover:bg-white/5 transition-colors touch-manipulation"
      >
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gradient-to-br from-green-500 to-emerald-500 rounded-lg flex items-center justify-center">
            <Activity className="w-6 h-6 text-white" />
          </div>
          <div className="text-left">
            <h2 className="text-base md:text-lg font-semibold text-white">Live Activity</h2>
            <p className="text-xs text-white/60">{filteredActivities.length} recent events</p>
          </div>
        </div>
        {isExpanded ? (
          <ChevronUp className="w-5 h-5 text-white/60" />
        ) : (
          <ChevronDown className="w-5 h-5 text-white/60" />
        )}
      </button>

      <AnimatePresence>
        {isExpanded && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            className="px-4 md:px-6 pb-6"
          >
            {/* Filters */}
            <div className="flex gap-2 mb-4">
              {['all', 'client', 'agent'].map((f) => (
                <button
                  key={f}
                  onClick={() => setFilter(f as typeof filter)}
                  className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-all touch-manipulation ${
                    filter === f
                      ? 'bg-white/10 text-white border border-white/20'
                      : 'bg-white/5 text-white/60 border border-white/10 hover:bg-white/10'
                  }`}
                >
                  {f === 'all' ? 'All' : f === 'client' ? 'Clients' : 'Agents'}
                </button>
              ))}
            </div>

            {/* Activity List */}
            <div className="space-y-2 max-h-[400px] overflow-y-auto">
              {loading ? (
                <div className="text-center py-8">
                  <div className="w-6 h-6 border-2 border-white/20 border-t-white rounded-full animate-spin mx-auto" />
                </div>
              ) : filteredActivities.length === 0 ? (
                <div className="text-center py-8">
                  <Activity className="w-8 h-8 text-white/20 mx-auto mb-2" />
                  <p className="text-white/40 text-sm">No recent activity</p>
                </div>
              ) : (
                filteredActivities.map((activity, index) => {
                  const Icon = getIcon(activity.type);

                  return (
                    <motion.div
                      key={activity.id}
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: index * 0.05 }}
                      className="p-3 bg-white/5 hover:bg-white/10 rounded-lg border border-white/10 transition-all group touch-manipulation"
                    >
                      <div className="flex items-start gap-3">
                        <div className={`p-2 rounded-lg flex-shrink-0 ${
                          activity.user_type === 'client'
                            ? 'bg-cyan-500/20'
                            : activity.user_type === 'agent'
                            ? 'bg-purple-500/20'
                            : 'bg-white/10'
                        }`}>
                          <Icon className="w-4 h-4 text-white" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="text-sm text-white font-medium truncate">
                            {activity.user_name}
                          </p>
                          <p className="text-xs text-white/60 mt-0.5">
                            {activity.description}
                          </p>
                          <p className="text-[10px] text-white/40 mt-1">
                            {getTimeAgo(activity.timestamp)}
                          </p>
                        </div>
                        <div className={`px-2 py-0.5 rounded-full text-[10px] font-medium ${
                          activity.user_type === 'client'
                            ? 'bg-cyan-500/20 text-cyan-400'
                            : activity.user_type === 'agent'
                            ? 'bg-purple-500/20 text-purple-400'
                            : 'bg-white/10 text-white/60'
                        }`}>
                          {activity.user_type}
                        </div>
                      </div>
                    </motion.div>
                  );
                })
              )}
            </div>

            {/* Auto-refresh indicator */}
            <div className="mt-4 text-center text-xs text-white/40">
              Auto-refreshes every 30 seconds
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}
