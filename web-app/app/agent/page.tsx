'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import {
  Users,
  MessageSquare,
  Calendar,
  TrendingUp,
  Home,
  DollarSign,
  Clock,
  CheckCircle2,
  AlertCircle,
  Loader2
} from 'lucide-react';
import { useAgent } from '@/hooks/useAgent';
import { agentDb, db } from '@/lib/supabase';

export default function AgentDashboard() {
  const { agentProfile, loading: agentLoading } = useAgent();
  const [loading, setLoading] = useState(true);
  const [userProfile, setUserProfile] = useState<any>(null);
  const [connections, setConnections] = useState<any[]>([]);
  const [messages, setMessages] = useState<any[]>([]);
  const [showings, setShowings] = useState<any[]>([]);
  const [listings, setListings] = useState<any[]>([]);
  const [stats, setStats] = useState([
    {
      label: 'Active Clients',
      value: '0',
      change: 'Loading...',
      icon: Users,
      color: 'from-purple-500 to-pink-500'
    },
    {
      label: 'Unread Messages',
      value: '0',
      change: 'Loading...',
      icon: MessageSquare,
      color: 'from-blue-500 to-cyan-500'
    },
    {
      label: 'Showings This Week',
      value: '0',
      change: 'Loading...',
      icon: Calendar,
      color: 'from-green-500 to-emerald-500'
    },
    {
      label: 'Active Listings',
      value: '0',
      change: 'Loading...',
      icon: Home,
      color: 'from-orange-500 to-amber-500'
    }
  ]);

  useEffect(() => {
    async function loadDashboardData() {
      if (!agentProfile || agentLoading) return;

      try {
        setLoading(true);

        // Fetch all data in parallel
        const [connectionsRes, messagesRes, showingsRes, listingsRes, profileRes] = await Promise.all([
          agentDb.getAgentConnections(agentProfile.id),
          agentDb.getAgentMessages(agentProfile.id),
          agentDb.getAgentShowings(agentProfile.id),
          agentDb.getAgentListings(agentProfile.id),
          db.getProfile(agentProfile.user_id)
        ]);

        const connectionsData = connectionsRes.data || [];
        const messagesData = messagesRes.data || [];
        const showingsData = showingsRes.data || [];
        const listingsData = listingsRes.data || [];

        setConnections(connectionsData);
        setMessages(messagesData);
        setShowings(showingsData);
        setListings(listingsData);
        setUserProfile(profileRes.data);

        // Calculate stats
        const activeClients = connectionsData?.filter((c: any) => c.status === 'active').length || 0;
        const unreadMessages = messagesData?.filter((m: any) => !m.read_at && m.sender_type === 'client').length || 0;

        // Showings this week
        const now = new Date();
        const weekFromNow = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
        const showingsThisWeek = showingsData?.filter((s: any) => {
          const showingDate = new Date(s.preferred_date_1 || s.confirmed_date);
          return showingDate >= now && showingDate <= weekFromNow;
        }).length || 0;

        const confirmedShowings = showingsData?.filter((s: any) => s.status === 'confirmed').length || 0;
        const activeListings = listingsData?.length || 0;

        setStats([
          {
            label: 'Active Clients',
            value: activeClients.toString(),
            change: `${connectionsData?.filter((c: any) => c.status === 'pending').length || 0} pending`,
            icon: Users,
            color: 'from-purple-500 to-pink-500'
          },
          {
            label: 'Unread Messages',
            value: unreadMessages.toString(),
            change: messagesData?.length ? `${messagesData.length} total` : 'No messages',
            icon: MessageSquare,
            color: 'from-blue-500 to-cyan-500'
          },
          {
            label: 'Showings This Week',
            value: showingsThisWeek.toString(),
            change: `${confirmedShowings} confirmed`,
            icon: Calendar,
            color: 'from-green-500 to-emerald-500'
          },
          {
            label: 'Active Listings',
            value: activeListings.toString(),
            change: `Managed by you`,
            icon: Home,
            color: 'from-orange-500 to-amber-500'
          }
        ]);

        setLoading(false);
      } catch (error) {
        console.error('Error loading dashboard data:', error);
        setLoading(false);
      }
    }

    loadDashboardData();
  }, [agentProfile, agentLoading]);

  function getRelativeTime(timestamp: string) {
    const now = new Date();
    const date = new Date(timestamp);
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 60) return `${diffMins} minute${diffMins !== 1 ? 's' : ''} ago`;
    if (diffHours < 24) return `${diffHours} hour${diffHours !== 1 ? 's' : ''} ago`;
    return `${diffDays} day${diffDays !== 1 ? 's' : ''} ago`;
  }

  function formatShowingTime(timestamp: string) {
    const date = new Date(timestamp);
    const now = new Date();
    const tomorrow = new Date(now);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const timeStr = date.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true });

    if (date.toDateString() === now.toDateString()) {
      return `Today at ${timeStr}`;
    } else if (date.toDateString() === tomorrow.toDateString()) {
      return `Tomorrow at ${timeStr}`;
    } else {
      return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) + ` at ${timeStr}`;
    }
  }

  const agentName = userProfile?.full_name?.split(' ')[0] || agentProfile?.professional_email?.split('@')[0] || 'Agent';

  // Generate recent activity from messages, showings, and connections
  const recentActivity = [...messages.slice(0, 2).map((msg: any) => ({
    id: msg.id,
    type: 'message',
    content: msg.content,
    time: getRelativeTime(msg.created_at),
    icon: MessageSquare,
    unread: !msg.read_at
  })), ...showings.slice(0, 1).map((showing: any) => ({
    id: showing.id,
    type: 'showing',
    content: `Showing ${showing.status} for ${showing.listing_id}`,
    time: getRelativeTime(showing.created_at),
    icon: Calendar,
    unread: false
  })), ...connections.slice(0, 1).map((conn: any) => ({
    id: conn.id,
    type: 'client',
    content: `Client connection ${conn.status}`,
    time: getRelativeTime(conn.created_at),
    icon: Users,
    unread: false
  }))].slice(0, 4);

  // Get upcoming showings (next 3)
  const upcomingShowings = showings
    .filter((s: any) => {
      const showingDate = new Date(s.preferred_date_1 || s.confirmed_date);
      return showingDate >= new Date();
    })
    .sort((a: any, b: any) => {
      const dateA = new Date(a.preferred_date_1 || a.confirmed_date);
      const dateB = new Date(b.preferred_date_1 || b.confirmed_date);
      return dateA.getTime() - dateB.getTime();
    })
    .slice(0, 3)
    .map((s: any) => ({
      id: s.id,
      property: s.listing_id,
      client: 'Client',
      time: formatShowingTime(s.preferred_date_1 || s.confirmed_date),
      status: s.status
    }));

  if (agentLoading || loading) {
    return (
      <div className="p-4 md:p-8 max-w-7xl mx-auto flex items-center justify-center min-h-screen">
        <div className="text-center">
          <Loader2 className="w-12 h-12 text-purple-400 animate-spin mx-auto mb-4" />
          <p className="text-white/60">Loading your dashboard...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-4 md:p-8 max-w-7xl mx-auto">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl md:text-4xl font-bold text-white mb-2">
          Welcome back, {agentName}
        </h1>
        <p className="text-white/60">
          Here's what's happening with your clients today
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 md:gap-6 mb-8">
        {stats.map((stat, index) => {
          const Icon = stat.icon;
          return (
            <motion.div
              key={stat.label}
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: index * 0.1 }}
              className="glass-strong rounded-2xl p-6 border border-white/10 hover:border-white/20 transition-all"
            >
              <div className="flex items-start justify-between mb-4">
                <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${stat.color} flex items-center justify-center`}>
                  <Icon className="w-6 h-6 text-white" />
                </div>
              </div>
              <div className="text-3xl font-bold text-white mb-1">{stat.value}</div>
              <div className="text-white/60 text-sm mb-2">{stat.label}</div>
              <div className="text-xs text-white/40">{stat.change}</div>
            </motion.div>
          );
        })}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        {/* Recent Activity */}
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.4 }}
          className="glass-strong rounded-2xl p-6 border border-white/10"
        >
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-bold text-white">Recent Activity</h2>
            <button className="text-sm text-purple-400 hover:text-purple-300">
              View All
            </button>
          </div>

          {recentActivity.length > 0 ? (
            <div className="space-y-4">
              {recentActivity.map((activity) => {
                const Icon = activity.icon;
                return (
                  <div
                    key={activity.id}
                    className={`flex items-start gap-4 p-4 rounded-xl transition-all ${
                      activity.unread
                        ? 'bg-purple-500/10 border border-purple-500/20'
                        : 'bg-white/5 hover:bg-white/10'
                    }`}
                  >
                    <div className={`w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0 ${
                      activity.unread
                        ? 'bg-gradient-to-br from-purple-500 to-pink-500'
                        : 'bg-white/10'
                    }`}>
                      <Icon className="w-5 h-5 text-white" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-white text-sm mb-1">{activity.content}</p>
                      <p className="text-white/40 text-xs">{activity.time}</p>
                    </div>
                  </div>
                );
              })}
            </div>
          ) : (
            <div className="text-center py-8">
              <AlertCircle className="w-12 h-12 text-white/20 mx-auto mb-3" />
              <p className="text-white/40 text-sm">No recent activity</p>
            </div>
          )}
        </motion.div>

        {/* Upcoming Showings */}
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.5 }}
          className="glass-strong rounded-2xl p-6 border border-white/10"
        >
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-bold text-white">Upcoming Showings</h2>
            <button className="text-sm text-purple-400 hover:text-purple-300">
              Calendar
            </button>
          </div>

          {upcomingShowings.length > 0 ? (
            <div className="space-y-4">
              {upcomingShowings.map((showing) => (
                <div
                  key={showing.id}
                  className="p-4 rounded-xl bg-white/5 hover:bg-white/10 transition-all border border-white/10"
                >
                  <div className="flex items-start justify-between mb-2">
                    <div className="flex-1 min-w-0">
                      <p className="text-white font-medium text-sm mb-1 truncate">
                        {showing.property}
                      </p>
                      <p className="text-white/60 text-xs mb-2">
                        Client: {showing.client}
                      </p>
                    </div>
                    {showing.status === 'confirmed' ? (
                      <CheckCircle2 className="w-5 h-5 text-green-400 flex-shrink-0 ml-2" />
                    ) : (
                      <Clock className="w-5 h-5 text-orange-400 flex-shrink-0 ml-2" />
                    )}
                  </div>
                  <div className="flex items-center gap-2 text-xs">
                    <Calendar className="w-4 h-4 text-white/40" />
                    <span className="text-white/60">{showing.time}</span>
                    <span className={`ml-auto px-2 py-1 rounded-full text-xs ${
                      showing.status === 'confirmed'
                        ? 'bg-green-500/20 text-green-300'
                        : 'bg-orange-500/20 text-orange-300'
                    }`}>
                      {showing.status}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-8">
              <Calendar className="w-12 h-12 text-white/20 mx-auto mb-3" />
              <p className="text-white/40 text-sm mb-4">No upcoming showings</p>
            </div>
          )}

          <button className="w-full mt-4 py-3 rounded-xl bg-gradient-to-r from-purple-500 to-pink-500 text-white font-semibold hover:shadow-lg hover:shadow-purple-500/50 transition-all">
            Schedule New Showing
          </button>
        </motion.div>
      </div>

      {/* Quick Actions */}
      <motion.div
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.6 }}
        className="glass-strong rounded-2xl p-6 border border-white/10"
      >
        <h2 className="text-xl font-bold text-white mb-6">Quick Actions</h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {[
            { label: 'Invite Client', icon: Users, href: '/agent/clients/invite' },
            { label: 'Send Message', icon: MessageSquare, href: '/agent/messages' },
            { label: 'Add Listing', icon: Home, href: '/agent/listings/new' },
            { label: 'View Analytics', icon: TrendingUp, href: '/agent/analytics' }
          ].map((action) => {
            const Icon = action.icon;
            return (
              <button
                key={action.label}
                className="flex flex-col items-center gap-3 p-4 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 hover:border-white/20 transition-all"
              >
                <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-purple-500/20 to-pink-500/20 flex items-center justify-center border border-white/10">
                  <Icon className="w-6 h-6 text-white" />
                </div>
                <span className="text-white text-sm font-medium">{action.label}</span>
              </button>
            );
          })}
        </div>
      </motion.div>
    </div>
  );
}
