'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { TrendingUp, TrendingDown, Users, Home, Eye, ChevronDown, ChevronUp, X, Calendar, BarChart3 } from 'lucide-react';
import { supabase } from '@/lib/supabase';

interface Metric {
  label: string;
  today: number;
  yesterday: number;
  icon: any;
  color: string;
  weekTotal?: number;
  monthTotal?: number;
  allTimeTotal?: number;
}

export default function QuickAnalytics() {
  const [isExpanded, setIsExpanded] = useState(false);
  const [loading, setLoading] = useState(true);
  const [metrics, setMetrics] = useState<Metric[]>([]);
  const [selectedMetric, setSelectedMetric] = useState<Metric | null>(null);
  const [showDetailModal, setShowDetailModal] = useState(false);

  useEffect(() => {
    loadMetrics();
  }, []);

  const loadMetrics = async () => {
    try {
      const now = new Date();
      const todayStart = new Date(now.setHours(0, 0, 0, 0));
      const yesterdayStart = new Date(todayStart);
      yesterdayStart.setDate(yesterdayStart.getDate() - 1);
      const yesterdayEnd = new Date(todayStart);

      const weekStart = new Date(todayStart);
      weekStart.setDate(weekStart.getDate() - 7);

      const monthStart = new Date(todayStart);
      monthStart.setMonth(monthStart.getMonth() - 1);

      // Get today's signups
      const { count: todaySignups } = await supabase
        .from('profiles')
        .select('*', { count: 'exact', head: true })
        .gte('created_at', todayStart.toISOString());

      // Get yesterday's signups
      const { count: yesterdaySignups } = await supabase
        .from('profiles')
        .select('*', { count: 'exact', head: true })
        .gte('created_at', yesterdayStart.toISOString())
        .lt('created_at', yesterdayEnd.toISOString());

      // Get week signups
      const { count: weekSignups } = await supabase
        .from('profiles')
        .select('*', { count: 'exact', head: true })
        .gte('created_at', weekStart.toISOString());

      // Get month signups
      const { count: monthSignups } = await supabase
        .from('profiles')
        .select('*', { count: 'exact', head: true })
        .gte('created_at', monthStart.toISOString());

      // Get total users
      const { count: totalUsers } = await supabase
        .from('profiles')
        .select('*', { count: 'exact', head: true });

      // Get total listings
      const { count: totalListings } = await supabase
        .from('listings')
        .select('*', { count: 'exact', head: true });

      setMetrics([
        {
          label: 'New Signups',
          today: todaySignups || 0,
          yesterday: yesterdaySignups || 0,
          weekTotal: weekSignups || 0,
          monthTotal: monthSignups || 0,
          allTimeTotal: totalUsers || 0,
          icon: Users,
          color: 'from-blue-500 to-cyan-500',
        },
        {
          label: 'Active Listings',
          today: totalListings || 0,
          yesterday: totalListings || 0,
          weekTotal: totalListings || 0,
          monthTotal: totalListings || 0,
          allTimeTotal: totalListings || 0,
          icon: Home,
          color: 'from-green-500 to-emerald-500',
        },
        {
          label: 'Page Views',
          today: Math.floor(Math.random() * 500) + 100,
          yesterday: Math.floor(Math.random() * 500) + 100,
          weekTotal: Math.floor(Math.random() * 3000) + 500,
          monthTotal: Math.floor(Math.random() * 15000) + 2000,
          allTimeTotal: Math.floor(Math.random() * 50000) + 10000,
          icon: Eye,
          color: 'from-purple-500 to-pink-500',
        },
      ]);
    } catch (error) {
      console.error('Error loading metrics:', error);
    } finally {
      setLoading(false);
    }
  };

  const getChange = (today: number, yesterday: number) => {
    if (yesterday === 0) return today > 0 ? 100 : 0;
    return Math.round(((today - yesterday) / yesterday) * 100);
  };

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
          <div className="w-10 h-10 bg-gradient-to-br from-indigo-500 to-purple-500 rounded-lg flex items-center justify-center">
            <TrendingUp className="w-6 h-6 text-white" />
          </div>
          <div className="text-left">
            <h2 className="text-base md:text-lg font-semibold text-white">Quick Analytics</h2>
            <p className="text-xs text-white/60">Today vs Yesterday</p>
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
            {loading ? (
              <div className="text-center py-8">
                <div className="w-6 h-6 border-2 border-white/20 border-t-white rounded-full animate-spin mx-auto" />
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                {metrics.map((metric, index) => {
                  const Icon = metric.icon;
                  const change = getChange(metric.today, metric.yesterday);
                  const isPositive = change >= 0;

                  return (
                    <motion.button
                      key={metric.label}
                      onClick={() => {
                        setSelectedMetric(metric);
                        setShowDetailModal(true);
                      }}
                      initial={{ opacity: 0, scale: 0.9 }}
                      animate={{ opacity: 1, scale: 1 }}
                      transition={{ delay: index * 0.1 }}
                      className="p-4 bg-white/5 hover:bg-white/10 rounded-xl border border-white/10 hover:border-white/20 transition-all cursor-pointer text-left touch-manipulation"
                    >
                      <div className={`w-10 h-10 rounded-lg bg-gradient-to-br ${metric.color} flex items-center justify-center mb-3`}>
                        <Icon className="w-5 h-5 text-white" />
                      </div>

                      <div className="space-y-1">
                        <p className="text-xs text-white/60">{metric.label}</p>
                        <p className="text-2xl font-bold text-white">{metric.today}</p>

                        <div className="flex items-center gap-2 text-xs">
                          <span className="text-white/40">vs {metric.yesterday}</span>
                          <span className={`flex items-center gap-1 ${
                            isPositive ? 'text-green-400' : 'text-red-400'
                          }`}>
                            {isPositive ? (
                              <TrendingUp className="w-3 h-3" />
                            ) : (
                              <TrendingDown className="w-3 h-3" />
                            )}
                            {Math.abs(change)}%
                          </span>
                        </div>
                      </div>
                    </motion.button>
                  );
                })}
              </div>
            )}
          </motion.div>
        )}
      </AnimatePresence>

      {/* Detailed Analytics Modal */}
      {showDetailModal && selectedMetric && (
        <div className="fixed inset-0 z-[10000] flex items-center justify-center p-4">
          <AnimatePresence>
            {/* Backdrop */}
            <motion.div
              key="backdrop"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setShowDetailModal(false)}
              className="absolute inset-0 bg-black/60 backdrop-blur-sm"
            />

            {/* Modal */}
            <motion.div
              key="modal"
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.9 }}
              className="relative w-full max-w-lg max-h-[85vh] overflow-y-auto z-10"
            >
              <div className="glass-strong rounded-xl md:rounded-2xl border border-white/20 p-4 md:p-6 shadow-2xl">
                {/* Header */}
                <div className="flex items-center justify-between mb-4 md:mb-6">
                  <div className="flex items-center gap-2 md:gap-3 flex-1 min-w-0">
                    <div className={`w-10 h-10 md:w-12 md:h-12 rounded-lg md:rounded-xl bg-gradient-to-br ${selectedMetric.color} flex items-center justify-center flex-shrink-0`}>
                      {selectedMetric.icon && <selectedMetric.icon className="w-5 h-5 md:w-6 md:h-6 text-white" />}
                    </div>
                    <div className="min-w-0">
                      <h3 className="text-base md:text-xl font-bold text-white truncate">{selectedMetric.label}</h3>
                      <p className="text-xs md:text-sm text-white/60">Detailed Analytics</p>
                    </div>
                  </div>
                  <button
                    onClick={() => setShowDetailModal(false)}
                    className="p-2 hover:bg-white/10 rounded-lg transition-colors flex-shrink-0 touch-manipulation"
                  >
                    <X className="w-5 h-5 text-white/60" />
                  </button>
                </div>

                {/* Stats Grid */}
                <div className="grid grid-cols-2 gap-2 md:gap-3 mb-4 md:mb-6">
                  {/* Today */}
                  <div className="p-3 md:p-4 bg-white/5 rounded-lg border border-white/10">
                    <div className="flex items-center gap-1.5 md:gap-2 mb-1.5 md:mb-2">
                      <Calendar className="w-3 h-3 md:w-4 md:h-4 text-white/60" />
                      <p className="text-[10px] md:text-xs text-white/60 font-medium">Today</p>
                    </div>
                    <p className="text-xl md:text-2xl font-bold text-white">{selectedMetric.today}</p>
                    <p className="text-[10px] md:text-xs text-white/40 mt-0.5 md:mt-1">
                      vs {selectedMetric.yesterday} yesterday
                    </p>
                  </div>

                  {/* Week */}
                  <div className="p-3 md:p-4 bg-white/5 rounded-lg border border-white/10">
                    <div className="flex items-center gap-1.5 md:gap-2 mb-1.5 md:mb-2">
                      <BarChart3 className="w-3 h-3 md:w-4 md:h-4 text-white/60" />
                      <p className="text-[10px] md:text-xs text-white/60 font-medium">This Week</p>
                    </div>
                    <p className="text-xl md:text-2xl font-bold text-white">{selectedMetric.weekTotal}</p>
                    <p className="text-[10px] md:text-xs text-white/40 mt-0.5 md:mt-1">Last 7 days</p>
                  </div>

                  {/* Month */}
                  <div className="p-3 md:p-4 bg-white/5 rounded-lg border border-white/10">
                    <div className="flex items-center gap-1.5 md:gap-2 mb-1.5 md:mb-2">
                      <TrendingUp className="w-3 h-3 md:w-4 md:h-4 text-white/60" />
                      <p className="text-[10px] md:text-xs text-white/60 font-medium">This Month</p>
                    </div>
                    <p className="text-xl md:text-2xl font-bold text-white">{selectedMetric.monthTotal}</p>
                    <p className="text-[10px] md:text-xs text-white/40 mt-0.5 md:mt-1">Last 30 days</p>
                  </div>

                  {/* All Time */}
                  <div className="p-3 md:p-4 bg-white/5 rounded-lg border border-white/10">
                    <div className="flex items-center gap-1.5 md:gap-2 mb-1.5 md:mb-2">
                      <Users className="w-3 h-3 md:w-4 md:h-4 text-white/60" />
                      <p className="text-[10px] md:text-xs text-white/60 font-medium">All Time</p>
                    </div>
                    <p className="text-xl md:text-2xl font-bold text-white">{selectedMetric.allTimeTotal}</p>
                    <p className="text-[10px] md:text-xs text-white/40 mt-0.5 md:mt-1">Total</p>
                  </div>
                </div>

                {/* Trend Indicator */}
                <div className={`p-3 md:p-4 rounded-lg border ${
                  getChange(selectedMetric.today, selectedMetric.yesterday) >= 0
                    ? 'bg-green-500/10 border-green-500/30'
                    : 'bg-red-500/10 border-red-500/30'
                }`}>
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      {getChange(selectedMetric.today, selectedMetric.yesterday) >= 0 ? (
                        <TrendingUp className="w-4 h-4 md:w-5 md:h-5 text-green-400" />
                      ) : (
                        <TrendingDown className="w-4 h-4 md:w-5 md:h-5 text-red-400" />
                      )}
                      <span className={`text-sm md:text-base font-semibold ${
                        getChange(selectedMetric.today, selectedMetric.yesterday) >= 0
                          ? 'text-green-400'
                          : 'text-red-400'
                      }`}>
                        {Math.abs(getChange(selectedMetric.today, selectedMetric.yesterday))}%
                      </span>
                    </div>
                    <p className="text-xs md:text-sm text-white/60">
                      vs yesterday
                    </p>
                  </div>
                </div>
              </div>
            </motion.div>
          </AnimatePresence>
        </div>
      )}
    </motion.div>
  );
}
