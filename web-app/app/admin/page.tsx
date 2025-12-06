'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import {
  Users,
  Home,
  UserCheck,
  TrendingUp,
  Settings,
  Activity,
  UserSquare,
  Shield
} from 'lucide-react';
import { db, auth, supabase } from '@/lib/supabase';
import { checkAdminFromProfile } from '@/lib/admin';
import AdminNotes from '@/components/AdminNotes';
import ActivityFeed from '@/components/admin/ActivityFeed';
import UserLookup from '@/components/admin/UserLookup';
import FeatureFlags from '@/components/admin/FeatureFlags';
import QuickAnalytics from '@/components/admin/QuickAnalytics';
import QuickAnnouncements from '@/components/admin/QuickAnnouncements';
import VersionManager from '@/components/admin/VersionManager';
import CinematicBackground from '@/components/CinematicBackground';
import AdminHeader from '@/components/admin/AdminHeader';
import TodayActivity from '@/components/admin/TodayActivity';
import SystemHealth from '@/components/admin/SystemHealth';
import BetaSignups from '@/components/admin/BetaSignups';

interface SystemStats {
  totalUsers: number;
  totalClients: number;
  totalAgents: number;
  totalListings: number;
  totalConnections: number;
  newUsersToday: number;
}

export default function AdminDashboard() {
  const router = useRouter();
  const [loading, setLoading] = useState(true);
  const [authorized, setAuthorized] = useState(false);
  const [userEmail, setUserEmail] = useState<string>('');
  const [userName, setUserName] = useState<string>('');
  const [stats, setStats] = useState<SystemStats>({
    totalUsers: 0,
    totalClients: 0,
    totalAgents: 0,
    totalListings: 0,
    totalConnections: 0,
    newUsersToday: 0,
  });

  useEffect(() => {
    checkAdminAccess();
  }, []);

  const checkAdminAccess = async () => {
    try {
      const { data: { user } } = await auth.getUser();

      if (!user) {
        router.push('/');
        return;
      }

      // Set user info
      setUserEmail(user.email || '');
      setUserName(user.user_metadata?.full_name || 'Admin User');

      // Check if user is admin
      const { data: profile } = await db.getProfile(user.id);
      const isAdmin = checkAdminFromProfile(profile);

      if (!isAdmin) {
        console.error('❌ Unauthorized admin access attempt');
        router.push('/home');
        return;
      }

      setAuthorized(true);
      await loadSystemStats();
    } catch (error) {
      console.error('Failed to check admin access:', error);
      router.push('/home');
    } finally {
      setLoading(false);
    }
  };

  const loadSystemStats = async () => {
    try {
      // Get total users
      const { count: totalUsers } = await supabase
        .from('profiles')
        .select('*', { count: 'exact', head: true });

      // Get clients (users with user_type = 'buyer' or 'renter')
      const { count: totalClients } = await supabase
        .from('profiles')
        .select('*', { count: 'exact', head: true })
        .or('user_type.eq.buyer,user_type.eq.renter');

      // Get agents (users with user_type = 'agent')
      const { count: totalAgents } = await supabase
        .from('profiles')
        .select('*', { count: 'exact', head: true })
        .eq('user_type', 'agent');

      // Get total listings
      const { count: totalListings } = await supabase
        .from('listings')
        .select('*', { count: 'exact', head: true });

      // Get total agent-client connections
      const { count: totalConnections } = await supabase
        .from('agent_client_connections')
        .select('*', { count: 'exact', head: true });

      // Get new users today
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const { count: newUsersToday } = await supabase
        .from('profiles')
        .select('*', { count: 'exact', head: true })
        .gte('created_at', today.toISOString());

      setStats({
        totalUsers: totalUsers || 0,
        totalClients: totalClients || 0,
        totalAgents: totalAgents || 0,
        totalListings: totalListings || 0,
        totalConnections: totalConnections || 0,
        newUsersToday: newUsersToday || 0,
      });
    } catch (error) {
      console.error('Failed to load system stats:', error);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-black">
        <motion.div
          animate={{ rotate: 360 }}
          transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
          className="w-8 h-8 border-2 border-white/20 border-t-white rounded-full"
        />
      </div>
    );
  }

  if (!authorized) {
    return null;
  }

  const statCards = [
    {
      label: 'Total Users',
      value: stats.totalUsers,
      icon: Users,
      color: 'from-blue-500 to-cyan-500',
      change: `+${stats.newUsersToday} today`,
      action: () => router.push('/admin/users')
    },
    {
      label: 'Clients',
      value: stats.totalClients,
      icon: UserSquare,
      color: 'from-green-500 to-emerald-500',
      change: `${((stats.totalClients / stats.totalUsers) * 100).toFixed(0)}% of users`,
      action: () => router.push('/admin/users')
    },
    {
      label: 'Agents',
      value: stats.totalAgents,
      icon: UserCheck,
      color: 'from-purple-500 to-pink-500',
      change: `${((stats.totalAgents / stats.totalUsers) * 100).toFixed(0)}% of users`,
      action: () => router.push('/admin/agents')
    },
    {
      label: 'Listings',
      value: stats.totalListings,
      icon: Home,
      color: 'from-orange-500 to-red-500',
      change: 'Active properties',
      action: () => router.push('/admin/listings')
    },
    {
      label: 'Connections',
      value: stats.totalConnections,
      icon: TrendingUp,
      color: 'from-yellow-500 to-orange-500',
      change: 'Agent-client pairs',
      action: () => {}
    },
  ];

  return (
    <main className="relative min-h-screen pb-24">
      <CinematicBackground timeOfDay="day" />

      {/* Dark overlay */}
      <div className="fixed inset-0 z-0 bg-gradient-to-b from-black/30 via-black/20 to-black/40" />

      {/* Content */}
      <div className="relative z-10 min-h-screen">
        {/* Header */}
        <AdminHeader userName={userName} userEmail={userEmail} />

        <div className="px-4 md:px-5 py-6 md:py-8 max-w-7xl mx-auto space-y-6">
          {/* Today's Activity */}
          <TodayActivity />

          {/* Developer Tools - Quick Access */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.05 }}
          >
            <motion.button
              onClick={() => router.push('/admin/dev')}
              className="w-full glass-strong rounded-xl md:rounded-2xl p-4 md:p-6 border border-cyan-500/30 hover:border-cyan-400/50 transition-all text-left group cursor-pointer bg-gradient-to-br from-cyan-500/5 to-blue-500/5 hover:from-cyan-500/10 hover:to-blue-500/10"
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3 md:gap-4">
                  <div className="p-2 md:p-3 rounded-lg md:rounded-xl bg-gradient-to-br from-cyan-500 to-blue-500">
                    <Settings className="w-5 h-5 md:w-6 md:h-6 text-white" />
                  </div>
                  <div>
                    <div className="text-base md:text-lg font-bold text-white group-hover:text-cyan-300 transition-colors">
                      Developer Tools
                    </div>
                    <div className="text-xs md:text-sm text-white/60 group-hover:text-white/80 transition-colors">
                      Page explorer, debugging tools, and view mode testing
                    </div>
                  </div>
                </div>
                <div className="text-2xl md:text-3xl text-cyan-400 group-hover:translate-x-1 transition-transform">
                  →
                </div>
              </div>
            </motion.button>
          </motion.div>

          {/* System Health */}
          <SystemHealth />
          {/* Primary Tools */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 md:gap-6">
            <AdminNotes />
            <QuickAnalytics />
            <BetaSignups />
            <ActivityFeed />
          </div>

          {/* Settings & Configuration */}
          <div className="mb-6 md:mb-8">
            <h2 className="text-base md:text-lg font-semibold text-white mb-3 md:mb-4 px-1">Settings & Configuration</h2>
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-4 md:gap-6">
              <FeatureFlags />
              <QuickAnnouncements />
              <VersionManager />
            </div>
          </div>

          {/* System Stats */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
          >
            <h2 className="text-base md:text-lg font-semibold text-white mb-3 md:mb-4 px-1">Quick Access</h2>
            <div className="grid grid-cols-2 lg:grid-cols-3 gap-3 md:gap-4">
              {statCards.map((stat, index) => {
                const Icon = stat.icon;

                return (
                  <motion.button
                    key={stat.label}
                    onClick={stat.action}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.1 + index * 0.05 }}
                    className="glass-strong rounded-xl md:rounded-2xl p-3 md:p-6 border border-white/10 hover:border-white/30 transition-all text-left group cursor-pointer"
                  >
                    <div className="flex items-start justify-between mb-2 md:mb-4">
                      <div className={`p-2 md:p-3 rounded-lg md:rounded-xl bg-gradient-to-br ${stat.color} bg-opacity-10 group-hover:bg-opacity-20 transition-all`}>
                        <Icon className="w-4 h-4 md:w-6 md:h-6 text-white" />
                      </div>
                    </div>
                    <div className="space-y-0.5 md:space-y-1">
                      <div className="text-xl md:text-3xl font-bold text-white">
                        {typeof stat.value === 'number' ? stat.value.toLocaleString() : stat.value}
                      </div>
                      <div className="text-xs md:text-sm font-medium text-white/80 group-hover:text-white transition-colors">{stat.label}</div>
                      <div className="text-[10px] md:text-xs text-white/50 group-hover:text-white/70 transition-colors">{stat.change}</div>
                    </div>
                  </motion.button>
                );
              })}
            </div>
          </motion.div>
        </div>
      </div>
    </main>
  );
}
