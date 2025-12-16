'use client';

export const dynamic = 'force-dynamic';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import {
  Users,
  MessageSquare,
  Calendar,
  UserPlus,
  DollarSign,
  MapPin,
  Clock,
  CheckCircle2,
  XCircle,
  AlertCircle,
  Phone,
  Mail,
  Home,
  TrendingUp,
  Filter,
  Search,
  MoreVertical,
  Loader2
} from 'lucide-react';
import { useAgent } from '@/hooks/useAgent';
import { agentDb } from '@/lib/supabase';

type ClientStatus = 'active' | 'pending' | 'paused' | 'completed';

interface ClientConnection {
  id: string;
  client: {
    name: string;
    email: string;
    phone: string;
    avatar?: string;
  };
  status: ClientStatus;
  connectionType: 'buyer' | 'seller';
  budgetMin?: number;
  budgetMax?: number;
  bedroomsMin?: number;
  targetNeighborhoods?: string[];
  lastInteraction: string;
  totalPropertiesViewed: number;
  totalShowings: number;
  unreadMessages: number;
  createdAt: string;
}

export default function ClientsPage() {
  const { agentProfile, loading: agentLoading } = useAgent();
  const [selectedStatus, setSelectedStatus] = useState<ClientStatus | 'all'>('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [showInviteModal, setShowInviteModal] = useState(false);
  const [connections, setConnections] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Invite form state
  const [inviteEmail, setInviteEmail] = useState('');
  const [inviteType, setInviteType] = useState<'buyer' | 'seller'>('buyer');
  const [inviteMessage, setInviteMessage] = useState('');
  const [inviting, setInviting] = useState(false);

  // Fetch connections from Supabase
  useEffect(() => {
    if (!agentProfile?.id) return;

    const fetchConnections = async () => {
      try {
        setLoading(true);
        const { data, error } = await agentDb.getAgentConnections(agentProfile.id);

        if (error) throw error;

        setConnections(data || []);
      } catch (err: any) {
        console.error('Error fetching connections:', err);
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchConnections();
  }, [agentProfile?.id]);

  const handleInviteClient = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!agentProfile?.id || !inviteEmail.trim()) return;

    try {
      setInviting(true);

      const { data, error } = await agentDb.inviteClient({
        agentId: agentProfile.id,
        clientEmail: inviteEmail,
        connectionType: inviteType,
        invitationMessage: inviteMessage || undefined,
      });

      if (error) throw error;

      // Add new connection to list
      if (data) {
        setConnections([data, ...connections]);
      }

      // Reset form and close modal
      setInviteEmail('');
      setInviteMessage('');
      setShowInviteModal(false);

      // Show success message
      alert(`✅ Invitation sent to ${inviteEmail}!\n\n${
        process.env.NODE_ENV === 'development'
          ? 'Check your terminal for the invitation link (email service not configured).'
          : 'They will receive an email with the invitation link.'
      }`);

    } catch (err: any) {
      console.error('Error inviting client:', err);
      // Only show error if it's not an email-related error
      if (!err.message?.includes('email') && !err.message?.includes('fetch')) {
        alert(`Failed to invite client: ${err.message}`);
      } else {
        // Email failed but invitation was created
        alert(`⚠️ Invitation created but email failed to send.\n\nCheck your terminal for the invitation link, or configure an email service in .env.local`);
      }
    } finally {
      setInviting(false);
    }
  };

  // Transform Supabase data to match UI format
  const clients: ClientConnection[] = connections.map(conn => {
    // For pending invitations, use invited_email; for accepted, use client profile data
    const displayName = conn.status === 'pending' && conn.invited_email
      ? conn.invited_email
      : conn.client?.full_name || conn.client?.email || conn.invited_email || 'Unknown';
    const displayEmail = conn.client?.email || conn.invited_email || '';
    const displayPhone = conn.client?.phone || '';

    return {
      id: conn.id,
      client: {
        name: displayName,
        email: displayEmail,
        phone: displayPhone,
      },
      status: conn.status,
      connectionType: conn.connection_type,
      budgetMin: conn.budget_min,
      budgetMax: conn.budget_max,
      bedroomsMin: conn.bedrooms_min,
      targetNeighborhoods: conn.target_neighborhoods,
      lastInteraction: new Date(conn.last_interaction_at || conn.created_at).toLocaleString(),
      totalPropertiesViewed: conn.total_properties_viewed || 0,
      totalShowings: conn.total_showings_scheduled || 0,
      unreadMessages: 0, // TODO: Calculate from messages table
      createdAt: new Date(conn.created_at).toLocaleDateString(),
    };
  });

  // Show loading state
  if (agentLoading || loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <Loader2 className="w-12 h-12 text-purple-400 mx-auto mb-4 animate-spin" />
          <p className="text-white/60">Loading clients...</p>
        </div>
      </div>
    );
  }

  // Show error if not an agent
  if (!agentProfile) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center glass-strong rounded-2xl p-8 border border-white/10">
          <AlertCircle className="w-12 h-12 text-red-400 mx-auto mb-4" />
          <h2 className="text-xl font-bold text-white mb-2">Access Denied</h2>
          <p className="text-white/60">You need an agent profile to access this page.</p>
        </div>
      </div>
    );
  }

  const filteredClients = clients.filter(client => {
    const matchesStatus = selectedStatus === 'all' || client.status === selectedStatus;
    const matchesSearch = client.client.name.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesStatus && matchesSearch;
  });

  const statusCounts = {
    all: clients.length,
    active: clients.filter(c => c.status === 'active').length,
    pending: clients.filter(c => c.status === 'pending').length,
    paused: clients.filter(c => c.status === 'paused').length,
    completed: clients.filter(c => c.status === 'completed').length
  };

  const getStatusColor = (status: ClientStatus) => {
    switch (status) {
      case 'active':
        return 'bg-green-500/20 text-green-300 border-green-500/30';
      case 'pending':
        return 'bg-yellow-500/20 text-yellow-300 border-yellow-500/30';
      case 'paused':
        return 'bg-orange-500/20 text-orange-300 border-orange-500/30';
      case 'completed':
        return 'bg-blue-500/20 text-blue-300 border-blue-500/30';
    }
  };

  const getStatusIcon = (status: ClientStatus) => {
    switch (status) {
      case 'active':
        return <CheckCircle2 className="w-4 h-4" />;
      case 'pending':
        return <Clock className="w-4 h-4" />;
      case 'paused':
        return <AlertCircle className="w-4 h-4" />;
      case 'completed':
        return <CheckCircle2 className="w-4 h-4" />;
    }
  };

  return (
    <div className="p-4 md:p-8 max-w-7xl mx-auto">
      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h1 className="text-3xl md:text-4xl font-bold text-white mb-2">
              Clients
            </h1>
            <p className="text-white/60">
              Manage your client relationships and connections
            </p>
          </div>

          <button
            onClick={() => setShowInviteModal(true)}
            className="flex items-center gap-2 px-4 md:px-6 py-3 rounded-xl bg-gradient-to-r from-purple-500 to-pink-500 text-white font-semibold hover:shadow-lg hover:shadow-purple-500/50 transition-all"
          >
            <UserPlus className="w-5 h-5" />
            <span className="hidden md:inline">Invite Client</span>
            <span className="md:hidden">Invite</span>
          </button>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4">
          {[
            { label: 'Total', value: statusCounts.all, color: 'from-purple-500 to-pink-500' },
            { label: 'Active', value: statusCounts.active, color: 'from-green-500 to-emerald-500' },
            { label: 'Pending', value: statusCounts.pending, color: 'from-yellow-500 to-orange-500' },
            { label: 'Completed', value: statusCounts.completed, color: 'from-blue-500 to-cyan-500' }
          ].map((stat) => (
            <div
              key={stat.label}
              className="glass-strong rounded-xl p-4 border border-white/10"
            >
              <div className={`w-10 h-10 rounded-lg bg-gradient-to-br ${stat.color} flex items-center justify-center mb-3`}>
                <Users className="w-5 h-5 text-white" />
              </div>
              <div className="text-2xl font-bold text-white mb-1">{stat.value}</div>
              <div className="text-white/60 text-sm">{stat.label}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Filters & Search */}
      <div className="glass-strong rounded-2xl p-4 md:p-6 border border-white/10 mb-6">
        <div className="flex flex-col md:flex-row gap-4">
          {/* Search */}
          <div className="flex-1 relative">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-white/40" />
            <input
              type="text"
              placeholder="Search clients..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-12 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500/50"
            />
          </div>

          {/* Status Filter */}
          <div className="flex gap-2 overflow-x-auto pb-2 md:pb-0">
            {(['all', 'active', 'pending', 'paused', 'completed'] as const).map((status) => (
              <button
                key={status}
                onClick={() => setSelectedStatus(status)}
                className={`px-4 py-2 rounded-lg text-sm font-medium whitespace-nowrap transition-all ${
                  selectedStatus === status
                    ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white'
                    : 'bg-white/5 text-white/60 hover:bg-white/10 hover:text-white'
                }`}
              >
                {status.charAt(0).toUpperCase() + status.slice(1)}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Client List */}
      {filteredClients.length === 0 ? (
        <div className="glass-strong rounded-2xl p-12 border border-white/10 text-center">
          <Users className="w-16 h-16 text-white/20 mx-auto mb-4" />
          <h3 className="text-xl font-bold text-white mb-2">No clients found</h3>
          <p className="text-white/60 mb-6">
            {searchQuery ? 'Try adjusting your search' : 'Start by inviting your first client'}
          </p>
          {!searchQuery && (
            <button
              onClick={() => setShowInviteModal(true)}
              className="px-6 py-3 rounded-xl bg-gradient-to-r from-purple-500 to-pink-500 text-white font-semibold hover:shadow-lg hover:shadow-purple-500/50 transition-all"
            >
              Invite Client
            </button>
          )}
        </div>
      ) : (
        <div className="space-y-4">
          {filteredClients.map((connection, index) => (
            <motion.div
              key={connection.id}
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: index * 0.05 }}
              className="glass-strong rounded-2xl p-4 md:p-6 border border-white/10 hover:border-white/20 transition-all"
            >
              <div className="flex flex-col md:flex-row gap-4">
                {/* Client Info */}
                <div className="flex-1">
                  <div className="flex items-start justify-between mb-4">
                    <div className="flex items-center gap-3">
                      {/* Avatar */}
                      <div className="w-12 h-12 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center flex-shrink-0">
                        <span className="text-white font-bold text-lg">
                          {connection.client.name.split(' ').map(n => n[0]).join('')}
                        </span>
                      </div>

                      {/* Name & Status */}
                      <div>
                        <div className="flex items-center gap-2 mb-1">
                          <h3 className="text-lg font-bold text-white">
                            {connection.client.name}
                          </h3>
                          {connection.unreadMessages > 0 && (
                            <span className="px-2 py-0.5 rounded-full bg-red-500 text-white text-xs font-bold">
                              {connection.unreadMessages}
                            </span>
                          )}
                        </div>
                        <div className="flex items-center gap-2 flex-wrap">
                          <span className={`px-2 py-1 rounded-lg text-xs font-medium border flex items-center gap-1 ${getStatusColor(connection.status)}`}>
                            {getStatusIcon(connection.status)}
                            {connection.status}
                          </span>
                          <span className="px-2 py-1 rounded-lg text-xs font-medium bg-white/5 text-white/60">
                            {connection.connectionType}
                          </span>
                        </div>
                      </div>
                    </div>

                    {/* More Menu */}
                    <button className="w-8 h-8 rounded-lg bg-white/5 hover:bg-white/10 flex items-center justify-center transition-all">
                      <MoreVertical className="w-5 h-5 text-white/60" />
                    </button>
                  </div>

                  {/* Contact & Details */}
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mb-4">
                    <div className="flex items-center gap-2 text-sm">
                      <Mail className="w-4 h-4 text-white/40" />
                      <span className="text-white/60">{connection.client.email}</span>
                    </div>
                    <div className="flex items-center gap-2 text-sm">
                      <Phone className="w-4 h-4 text-white/40" />
                      <span className="text-white/60">{connection.client.phone}</span>
                    </div>
                    {connection.budgetMin && connection.budgetMax && (
                      <div className="flex items-center gap-2 text-sm">
                        <DollarSign className="w-4 h-4 text-white/40" />
                        <span className="text-white/60">
                          ${(connection.budgetMin / 1000).toFixed(0)}K - ${(connection.budgetMax / 1000).toFixed(0)}K
                        </span>
                      </div>
                    )}
                    {connection.bedroomsMin && (
                      <div className="flex items-center gap-2 text-sm">
                        <Home className="w-4 h-4 text-white/40" />
                        <span className="text-white/60">
                          {connection.bedroomsMin}+ bedrooms
                        </span>
                      </div>
                    )}
                  </div>

                  {/* Target Neighborhoods */}
                  {connection.targetNeighborhoods && connection.targetNeighborhoods.length > 0 && (
                    <div className="flex items-start gap-2 mb-4">
                      <MapPin className="w-4 h-4 text-white/40 mt-0.5 flex-shrink-0" />
                      <div className="flex flex-wrap gap-2">
                        {connection.targetNeighborhoods.map((hood) => (
                          <span
                            key={hood}
                            className="px-2 py-1 rounded-lg bg-white/5 text-white/60 text-xs"
                          >
                            {hood}
                          </span>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Stats */}
                  <div className="flex items-center gap-4 text-xs text-white/40">
                    <div className="flex items-center gap-1">
                      <TrendingUp className="w-4 h-4" />
                      <span>{connection.totalPropertiesViewed} viewed</span>
                    </div>
                    <div className="flex items-center gap-1">
                      <Calendar className="w-4 h-4" />
                      <span>{connection.totalShowings} showings</span>
                    </div>
                    <div className="flex items-center gap-1">
                      <Clock className="w-4 h-4" />
                      <span>{connection.lastInteraction}</span>
                    </div>
                  </div>
                </div>

                {/* Actions */}
                <div className="flex md:flex-col gap-2 md:min-w-[120px]">
                  <button className="flex-1 md:flex-none flex items-center justify-center gap-2 px-4 py-2 rounded-xl bg-gradient-to-r from-purple-500 to-pink-500 text-white text-sm font-semibold hover:shadow-lg hover:shadow-purple-500/50 transition-all">
                    <MessageSquare className="w-4 h-4" />
                    <span className="hidden md:inline">Message</span>
                  </button>
                  <button className="flex-1 md:flex-none flex items-center justify-center gap-2 px-4 py-2 rounded-xl bg-white/5 hover:bg-white/10 text-white text-sm font-semibold border border-white/10 transition-all">
                    <Calendar className="w-4 h-4" />
                    <span className="hidden md:inline">Schedule</span>
                  </button>
                  <button className="flex-1 md:flex-none flex items-center justify-center gap-2 px-4 py-2 rounded-xl bg-white/5 hover:bg-white/10 text-white text-sm font-semibold border border-white/10 transition-all">
                    <Home className="w-4 h-4" />
                    <span className="hidden md:inline">Recommend</span>
                  </button>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      )}

      {/* Invite Modal */}
      {showInviteModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm">
          <motion.div
            initial={{ scale: 0.9, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            className="glass-strong rounded-2xl p-6 md:p-8 border border-white/10 max-w-md w-full"
          >
            <form onSubmit={handleInviteClient}>
              <h2 className="text-2xl font-bold text-white mb-4">Invite Client</h2>
              <p className="text-white/60 mb-6">
                Send an invitation to connect with a new client. They'll receive an email to accept your invitation.
              </p>

              <div className="space-y-4 mb-6">
                <div>
                  <label className="block text-white text-sm font-medium mb-2">
                    Client Email
                  </label>
                  <input
                    type="email"
                    value={inviteEmail}
                    onChange={(e) => setInviteEmail(e.target.value)}
                    placeholder="client@email.com"
                    required
                    disabled={inviting}
                    className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500/50 disabled:opacity-50"
                  />
                </div>

                <div>
                  <label className="block text-white text-sm font-medium mb-2">
                    Connection Type
                  </label>
                  <select
                    value={inviteType}
                    onChange={(e) => setInviteType(e.target.value as 'buyer' | 'seller')}
                    disabled={inviting}
                    className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white focus:outline-none focus:border-purple-500/50 disabled:opacity-50"
                  >
                    <option value="buyer">Buyer</option>
                    <option value="seller">Seller</option>
                  </select>
                </div>

                <div>
                  <label className="block text-white text-sm font-medium mb-2">
                    Personal Message (Optional)
                  </label>
                  <textarea
                    value={inviteMessage}
                    onChange={(e) => setInviteMessage(e.target.value)}
                    rows={3}
                    placeholder="Add a personal message..."
                    disabled={inviting}
                    className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500/50 resize-none disabled:opacity-50"
                  />
                </div>
              </div>

              <div className="flex gap-3">
                <button
                  type="button"
                  onClick={() => setShowInviteModal(false)}
                  disabled={inviting}
                  className="flex-1 px-4 py-3 rounded-xl bg-white/5 hover:bg-white/10 text-white font-semibold border border-white/10 transition-all disabled:opacity-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={inviting || !inviteEmail.trim()}
                  className="flex-1 px-4 py-3 rounded-xl bg-gradient-to-r from-purple-500 to-pink-500 text-white font-semibold hover:shadow-lg hover:shadow-purple-500/50 transition-all disabled:opacity-50 flex items-center justify-center gap-2"
                >
                  {inviting && <Loader2 className="w-4 h-4 animate-spin" />}
                  {inviting ? 'Sending...' : 'Send Invitation'}
                </button>
              </div>
            </form>
          </motion.div>
        </div>
      )}
    </div>
  );
}
