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
  Eye,
  UserSquare,
  Building2,
  Shield,
  ArrowLeft
} from 'lucide-react';
import { db, auth, supabase } from '@/lib/supabase';
import { checkAdminFromProfile } from '@/lib/admin';
import { setAdminViewMode, getAdminViewMode, type ViewAsMode } from '@/lib/adminViewMode';
import AdminNotes from '@/components/AdminNotes';
import ActivityFeed from '@/components/admin/ActivityFeed';
import UserLookup from '@/components/admin/UserLookup';
import FeatureFlags from '@/components/admin/FeatureFlags';
import QuickAnalytics from '@/components/admin/QuickAnalytics';
import QuickAnnouncements from '@/components/admin/QuickAnnouncements';
import CinematicBackground from '@/components/CinematicBackground';

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
  const [viewMode, setViewMode] = useState<ViewAsMode>('admin');
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
    // Load saved view mode
    const savedMode = getAdminViewMode();
    setViewMode(savedMode);
  }, []);

  const checkAdminAccess = async () => {
    try {
      const { data: { user } } = await auth.getUser();

      if (!user) {
        router.push('/');
        return;
      }

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

  const handleViewModeSwitch = (mode: ViewAsMode) => {
    setViewMode(mode);
    setAdminViewMode(mode);

    // Navigate to the appropriate page based on view mode
    if (mode === 'client') {
      router.push('/home');
    } else if (mode === 'agent') {
      router.push('/agent');
    }
    // Stay on admin page for admin mode
  };

  const navigateToPage = (path: string, requiredMode?: ViewAsMode) => {
    // Set view mode if specified
    if (requiredMode) {
      setAdminViewMode(requiredMode);
      setViewMode(requiredMode);
    }
    // Navigate to page
    router.push(path);
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
      change: `+${stats.newUsersToday} today`
    },
    {
      label: 'Clients',
      value: stats.totalClients,
      icon: UserSquare,
      color: 'from-green-500 to-emerald-500',
      change: `${((stats.totalClients / stats.totalUsers) * 100).toFixed(0)}% of users`
    },
    {
      label: 'Agents',
      value: stats.totalAgents,
      icon: UserCheck,
      color: 'from-purple-500 to-pink-500',
      change: `${((stats.totalAgents / stats.totalUsers) * 100).toFixed(0)}% of users`
    },
    {
      label: 'Listings',
      value: stats.totalListings,
      icon: Home,
      color: 'from-orange-500 to-red-500',
      change: 'Active properties'
    },
    {
      label: 'Connections',
      value: stats.totalConnections,
      icon: TrendingUp,
      color: 'from-yellow-500 to-orange-500',
      change: 'Agent-client pairs'
    },
    {
      label: 'Activity',
      value: `${((stats.totalConnections / stats.totalClients) * 100).toFixed(0)}%`,
      icon: Activity,
      color: 'from-pink-500 to-rose-500',
      change: 'Connection rate'
    },
  ];

  const viewModes = [
    { id: 'admin' as ViewAsMode, label: 'Admin View', icon: Shield, description: 'Full system access' },
    { id: 'client' as ViewAsMode, label: 'Client View', icon: Eye, description: 'See as buyer/renter' },
    { id: 'agent' as ViewAsMode, label: 'Agent View', icon: Building2, description: 'See as agent' },
  ];

  return (
    <main className="relative min-h-screen pb-24">
      <CinematicBackground timeOfDay="day" />

      {/* Dark overlay */}
      <div className="fixed inset-0 z-0 bg-gradient-to-b from-black/30 via-black/20 to-black/40" />

      {/* Content */}
      <div className="relative z-10 min-h-screen">
        {/* Header */}
        <header className="sticky top-0 z-50 bg-gradient-to-b from-black/60 via-black/40 to-transparent backdrop-blur-sm">
          <div className="flex items-center justify-between px-5 py-4">
            <div className="flex items-center gap-3">
              <div>
                <h1 className="text-2xl font-bold text-white flex items-center gap-2">
                  <Shield className="w-6 h-6 text-orange-400" />
                  Admin Dashboard
                </h1>
                <p className="text-sm text-white/60">Super Admin - Full System Access</p>
              </div>
            </div>
            <div className="px-4 py-2 bg-gradient-to-r from-orange-500/20 to-yellow-500/20 border border-orange-500/30 rounded-full">
              <span className="text-xs font-bold text-orange-400">ADMIN</span>
            </div>
          </div>
        </header>

        <div className="px-4 md:px-5 py-6 md:py-8 space-y-6 md:space-y-8 max-w-6xl mx-auto">
          {/* Admin Notes & Messages */}
          <AdminNotes />

          {/* Quick Analytics */}
          <QuickAnalytics />

          {/* Activity Feed */}
          <ActivityFeed />

          {/* User Lookup */}
          <UserLookup />

          {/* Feature Flags */}
          <FeatureFlags />

          {/* Quick Announcements */}
          <QuickAnnouncements />

          {/* System Stats */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
          >
            <h2 className="text-base md:text-lg font-semibold text-white mb-3 md:mb-4">System Overview</h2>
            <div className="grid grid-cols-2 lg:grid-cols-3 gap-3 md:gap-4">
              {statCards.map((stat, index) => {
                const Icon = stat.icon;

                return (
                  <motion.div
                    key={stat.label}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.1 + index * 0.05 }}
                    className="glass-strong rounded-2xl p-6 border border-white/10 hover:border-white/20 transition-all"
                  >
                    <div className="flex items-start justify-between mb-4">
                      <div className={`p-3 rounded-xl bg-gradient-to-br ${stat.color} bg-opacity-10`}>
                        <Icon className="w-6 h-6 text-white" />
                      </div>
                    </div>
                    <div className="space-y-1">
                      <div className="text-3xl font-bold text-white">
                        {typeof stat.value === 'number' ? stat.value.toLocaleString() : stat.value}
                      </div>
                      <div className="text-sm font-medium text-white/80">{stat.label}</div>
                      <div className="text-xs text-white/50">{stat.change}</div>
                    </div>
                  </motion.div>
                );
              })}
            </div>
          </motion.div>

          {/* Quick Actions */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="glass-strong rounded-2xl p-4 md:p-6 border border-white/10"
          >
            <h2 className="text-base md:text-lg font-semibold text-white mb-3 md:mb-4">Quick Actions</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-2 md:gap-3">
              <button
                onClick={() => router.push('/admin/users')}
                className="p-4 md:p-4 bg-white/5 hover:bg-white/10 active:bg-white/15 border border-white/10 rounded-xl text-left transition-all touch-manipulation min-h-[60px]"
              >
                <div className="flex items-center gap-3">
                  <Users className="w-5 h-5 text-white flex-shrink-0" />
                  <div className="min-w-0">
                    <div className="text-sm md:text-base font-medium text-white">Manage Users</div>
                    <div className="text-xs text-white/60">View and edit user accounts</div>
                  </div>
                </div>
              </button>

              <button
                onClick={() => router.push('/admin/listings')}
                className="p-4 bg-white/5 hover:bg-white/10 border border-white/10 rounded-xl text-left transition-all"
              >
                <div className="flex items-center gap-3">
                  <Home className="w-5 h-5 text-white" />
                  <div>
                    <div className="font-medium text-white">Manage Listings</div>
                    <div className="text-xs text-white/60">Add, edit, or remove properties</div>
                  </div>
                </div>
              </button>

              <button
                onClick={() => router.push('/admin/agents')}
                className="p-4 bg-white/5 hover:bg-white/10 border border-white/10 rounded-xl text-left transition-all"
              >
                <div className="flex items-center gap-3">
                  <UserCheck className="w-5 h-5 text-white" />
                  <div>
                    <div className="font-medium text-white">Agent Management</div>
                    <div className="text-xs text-white/60">Review and approve agents</div>
                  </div>
                </div>
              </button>

              <button
                onClick={() => router.push('/admin/settings')}
                className="p-4 bg-white/5 hover:bg-white/10 border border-white/10 rounded-xl text-left transition-all"
              >
                <div className="flex items-center gap-3">
                  <Settings className="w-5 h-5 text-white" />
                  <div>
                    <div className="font-medium text-white">System Settings</div>
                    <div className="text-xs text-white/60">Configure app settings</div>
                  </div>
                </div>
              </button>
            </div>
          </motion.div>

          {/* Developer Tools */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className="glass-strong rounded-2xl p-6 border border-white/10"
          >
            <div className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 bg-gradient-to-br from-cyan-500 to-blue-500 rounded-lg flex items-center justify-center">
                <Settings className="w-6 h-6 text-white" />
              </div>
              <div>
                <h2 className="text-lg font-semibold text-white">Developer Tools</h2>
                <p className="text-xs text-white/60">Quick access to all pages and development tools</p>
              </div>
            </div>

            {/* Page Explorer */}
            <div className="space-y-3">
              <div className="border-b border-white/10 pb-2">
                <h3 className="text-sm font-semibold text-white/80 uppercase tracking-wider">Client Portal</h3>
              </div>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-2">
                {[
                  { path: '/home', label: 'Home Feed' },
                  { path: '/search', label: 'Search' },
                  { path: '/saved', label: 'Saved Properties' },
                  { path: '/profile', label: 'User Profile' },
                  { path: '/settings', label: 'Settings' },
                  { path: '/vault', label: 'Document Vault' },
                  { path: '/learn', label: 'Learn Hub' },
                  { path: '/education', label: 'Education' },
                  { path: '/matchmaker', label: 'Matchmaker' },
                  { path: '/directory', label: 'Agent Directory' },
                ].map((page) => (
                  <button
                    key={page.path}
                    onClick={() => navigateToPage(page.path, 'client')}
                    className="p-3 bg-white/5 hover:bg-white/10 border border-white/10 hover:border-white/20 rounded-lg text-left transition-all group"
                  >
                    <div className="text-xs font-medium text-white group-hover:text-cyan-400 transition-colors">
                      {page.label}
                    </div>
                    <div className="text-[10px] text-white/40 font-mono mt-1">{page.path}</div>
                    <div className="text-[9px] text-cyan-400/60 mt-1">→ View as Client</div>
                  </button>
                ))}
              </div>

              <div className="border-b border-white/10 pb-2 pt-4">
                <h3 className="text-sm font-semibold text-white/80 uppercase tracking-wider">Agent Portal</h3>
              </div>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-2">
                {[
                  { path: '/agent', label: 'Agent Dashboard' },
                  { path: '/agent/clients', label: 'Client Management' },
                  { path: '/agent/listings', label: 'Listings' },
                  { path: '/agent/showings', label: 'Showings' },
                  { path: '/agent/messages', label: 'Messages' },
                  { path: '/agent/documents', label: 'Documents' },
                  { path: '/agent/register', label: 'Agent Registration' },
                  { path: '/calendar', label: 'Calendar' },
                ].map((page) => (
                  <button
                    key={page.path}
                    onClick={() => navigateToPage(page.path, 'agent')}
                    className="p-3 bg-white/5 hover:bg-white/10 border border-white/10 hover:border-white/20 rounded-lg text-left transition-all group"
                  >
                    <div className="text-xs font-medium text-white group-hover:text-purple-400 transition-colors">
                      {page.label}
                    </div>
                    <div className="text-[10px] text-white/40 font-mono mt-1">{page.path}</div>
                    <div className="text-[9px] text-purple-400/60 mt-1">→ View as Agent</div>
                  </button>
                ))}
              </div>

              <div className="border-b border-white/10 pb-2 pt-4">
                <h3 className="text-sm font-semibold text-white/80 uppercase tracking-wider">Development & Testing</h3>
              </div>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-2">
                {[
                  { path: '/onboarding', label: 'Onboarding Flow' },
                  { path: '/studio', label: 'Style Studio' },
                  { path: '/teach', label: 'Teach (ML)' },
                  { path: '/db-test', label: 'Database Test' },
                  { path: '/signup', label: 'Signup Page' },
                ].map((page) => (
                  <button
                    key={page.path}
                    onClick={() => navigateToPage(page.path)}
                    className="p-3 bg-white/5 hover:bg-white/10 border border-white/10 hover:border-white/20 rounded-lg text-left transition-all group"
                  >
                    <div className="text-xs font-medium text-white group-hover:text-green-400 transition-colors">
                      {page.label}
                    </div>
                    <div className="text-[10px] text-white/40 font-mono mt-1">{page.path}</div>
                    <div className="text-[9px] text-green-400/60 mt-1">→ Keep current mode</div>
                  </button>
                ))}
              </div>
            </div>
          </motion.div>

          {/* System Information */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            className="glass-strong rounded-2xl p-6 border border-white/10"
          >
            <h2 className="text-lg font-semibold text-white mb-3">System Information</h2>
            <div className="space-y-2 text-sm">
              <div className="flex justify-between">
                <span className="text-white/60">Environment</span>
                <span className="text-white font-mono">{process.env.NODE_ENV}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-white/60">View Mode</span>
                <span className="text-white font-mono capitalize">{viewMode}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-white/60">Last Updated</span>
                <span className="text-white font-mono">{new Date().toLocaleTimeString()}</span>
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </main>
  );
}
