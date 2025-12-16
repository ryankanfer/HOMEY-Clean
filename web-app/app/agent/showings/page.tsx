'use client';

export const dynamic = 'force-dynamic';

import { useState } from 'react';
import { motion } from 'framer-motion';
import {
  Calendar as CalendarIcon,
  Clock,
  MapPin,
  Users,
  CheckCircle2,
  XCircle,
  AlertCircle,
  Plus,
  Search,
  Filter,
  ChevronLeft,
  ChevronRight,
  Home,
  Phone,
  MessageSquare,
  Edit,
  Trash2,
  MoreVertical
} from 'lucide-react';

type ShowingStatus = 'confirmed' | 'pending' | 'cancelled' | 'completed';

interface ShowingRequest {
  id: string;
  property: {
    address: string;
    neighborhood: string;
    imageUrl: string;
    listingId: string;
  };
  client: {
    id: string;
    name: string;
    phone: string;
  };
  date: string;
  time: string;
  duration: number;
  status: ShowingStatus;
  notes?: string;
  createdAt: string;
}

export default function ShowingsPage() {
  const [viewMode, setViewMode] = useState<'list' | 'calendar'>('list');
  const [selectedStatus, setSelectedStatus] = useState<ShowingStatus | 'all'>('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedDate, setSelectedDate] = useState(new Date());

  // Mock data - will be replaced with real Supabase data
  const showings: ShowingRequest[] = [
    {
      id: '1',
      property: {
        address: '123 Main Street',
        neighborhood: 'Downtown',
        imageUrl: 'https://photos.zillowstatic.com/fp/1234-cc_ft_768.jpg',
        listingId: 'listing-123'
      },
      client: {
        id: 'c1',
        name: 'Sarah Johnson',
        phone: '(555) 123-4567'
      },
      date: '2024-02-24',
      time: '15:00',
      duration: 30,
      status: 'confirmed',
      notes: 'Client is particularly interested in the kitchen and backyard.',
      createdAt: '2024-02-20T10:00:00Z'
    },
    {
      id: '2',
      property: {
        address: '456 Oak Avenue',
        neighborhood: 'Midtown',
        imageUrl: 'https://photos.zillowstatic.com/fp/5678-cc_ft_768.jpg',
        listingId: 'listing-456'
      },
      client: {
        id: 'c2',
        name: 'Michael Chen',
        phone: '(555) 234-5678'
      },
      date: '2024-02-25',
      time: '14:00',
      duration: 45,
      status: 'confirmed',
      notes: 'Second showing - client wants to bring family.',
      createdAt: '2024-02-21T14:00:00Z'
    },
    {
      id: '3',
      property: {
        address: '789 Pine Road',
        neighborhood: 'Westside',
        imageUrl: 'https://photos.zillowstatic.com/fp/9012-cc_ft_768.jpg',
        listingId: 'listing-789'
      },
      client: {
        id: 'c1',
        name: 'Sarah Johnson',
        phone: '(555) 123-4567'
      },
      date: '2024-02-25',
      time: '16:30',
      duration: 30,
      status: 'pending',
      notes: 'Awaiting confirmation from listing agent.',
      createdAt: '2024-02-23T09:00:00Z'
    },
    {
      id: '4',
      property: {
        address: '234 Elm Street',
        neighborhood: 'North Park',
        imageUrl: 'https://photos.zillowstatic.com/fp/3456-cc_ft_768.jpg',
        listingId: 'listing-234'
      },
      client: {
        id: 'c3',
        name: 'Emily Davis',
        phone: '(555) 345-6789'
      },
      date: '2024-02-26',
      time: '11:00',
      duration: 30,
      status: 'pending',
      notes: 'First showing for new client.',
      createdAt: '2024-02-23T15:00:00Z'
    },
    {
      id: '5',
      property: {
        address: '567 Birch Lane',
        neighborhood: 'East Village',
        imageUrl: 'https://photos.zillowstatic.com/fp/7890-cc_ft_768.jpg',
        listingId: 'listing-567'
      },
      client: {
        id: 'c2',
        name: 'Michael Chen',
        phone: '(555) 234-5678'
      },
      date: '2024-02-23',
      time: '10:00',
      duration: 30,
      status: 'completed',
      notes: 'Client loved the property. Considering making an offer.',
      createdAt: '2024-02-20T11:00:00Z'
    },
    {
      id: '6',
      property: {
        address: '890 Cedar Court',
        neighborhood: 'Little Italy',
        imageUrl: 'https://photos.zillowstatic.com/fp/2345-cc_ft_768.jpg',
        listingId: 'listing-890'
      },
      client: {
        id: 'c4',
        name: 'James Wilson',
        phone: '(555) 456-7890'
      },
      date: '2024-02-24',
      time: '09:00',
      duration: 30,
      status: 'cancelled',
      notes: 'Client cancelled due to scheduling conflict.',
      createdAt: '2024-02-22T16:00:00Z'
    }
  ];

  const filteredShowings = showings.filter(showing => {
    const matchesSearch = showing.property.address.toLowerCase().includes(searchQuery.toLowerCase()) ||
      showing.client.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesStatus = selectedStatus === 'all' || showing.status === selectedStatus;
    return matchesSearch && matchesStatus;
  });

  const statusCounts = {
    all: showings.length,
    confirmed: showings.filter(s => s.status === 'confirmed').length,
    pending: showings.filter(s => s.status === 'pending').length,
    completed: showings.filter(s => s.status === 'completed').length,
    cancelled: showings.filter(s => s.status === 'cancelled').length
  };

  const getStatusColor = (status: ShowingStatus) => {
    switch (status) {
      case 'confirmed':
        return 'bg-green-500/20 text-green-300 border-green-500/30';
      case 'pending':
        return 'bg-yellow-500/20 text-yellow-300 border-yellow-500/30';
      case 'completed':
        return 'bg-blue-500/20 text-blue-300 border-blue-500/30';
      case 'cancelled':
        return 'bg-red-500/20 text-red-300 border-red-500/30';
    }
  };

  const getStatusIcon = (status: ShowingStatus) => {
    switch (status) {
      case 'confirmed':
        return <CheckCircle2 className="w-4 h-4" />;
      case 'pending':
        return <Clock className="w-4 h-4" />;
      case 'completed':
        return <CheckCircle2 className="w-4 h-4" />;
      case 'cancelled':
        return <XCircle className="w-4 h-4" />;
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      weekday: 'short',
      month: 'short',
      day: 'numeric'
    });
  };

  const formatTime = (timeString: string) => {
    const [hours, minutes] = timeString.split(':');
    const hour = parseInt(hours);
    const ampm = hour >= 12 ? 'PM' : 'AM';
    const displayHour = hour % 12 || 12;
    return `${displayHour}:${minutes} ${ampm}`;
  };

  const isToday = (dateString: string) => {
    const date = new Date(dateString);
    const today = new Date();
    return date.toDateString() === today.toDateString();
  };

  const isTomorrow = (dateString: string) => {
    const date = new Date(dateString);
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    return date.toDateString() === tomorrow.toDateString();
  };

  const getDateLabel = (dateString: string) => {
    if (isToday(dateString)) return 'Today';
    if (isTomorrow(dateString)) return 'Tomorrow';
    return formatDate(dateString);
  };

  // Group showings by date
  const showingsByDate = filteredShowings.reduce((acc, showing) => {
    const date = showing.date;
    if (!acc[date]) acc[date] = [];
    acc[date].push(showing);
    return acc;
  }, {} as Record<string, ShowingRequest[]>);

  // Sort dates
  const sortedDates = Object.keys(showingsByDate).sort();

  return (
    <div className="p-4 md:p-8 max-w-7xl mx-auto">
      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-3xl md:text-4xl font-bold text-white mb-2">
              Showings
            </h1>
            <p className="text-white/60">
              Manage your property showings and schedule
            </p>
          </div>

          <button className="flex items-center gap-2 px-4 md:px-6 py-3 rounded-xl bg-gradient-to-r from-purple-500 to-pink-500 text-white font-semibold hover:shadow-lg hover:shadow-purple-500/50 transition-all">
            <Plus className="w-5 h-5" />
            <span className="hidden md:inline">Schedule Showing</span>
            <span className="md:hidden">Schedule</span>
          </button>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4 mb-6">
          {[
            { label: 'Confirmed', value: statusCounts.confirmed, icon: CheckCircle2, color: 'from-green-500 to-emerald-500' },
            { label: 'Pending', value: statusCounts.pending, icon: Clock, color: 'from-yellow-500 to-orange-500' },
            { label: 'Completed', value: statusCounts.completed, icon: CheckCircle2, color: 'from-blue-500 to-cyan-500' },
            { label: 'This Week', value: statusCounts.confirmed + statusCounts.pending, icon: CalendarIcon, color: 'from-purple-500 to-pink-500' }
          ].map((stat) => {
            const Icon = stat.icon;
            return (
              <div
                key={stat.label}
                className="glass-strong rounded-xl p-4 border border-white/10"
              >
                <div className={`w-10 h-10 rounded-lg bg-gradient-to-br ${stat.color} flex items-center justify-center mb-3`}>
                  <Icon className="w-5 h-5 text-white" />
                </div>
                <div className="text-2xl font-bold text-white mb-1">{stat.value}</div>
                <div className="text-white/60 text-sm">{stat.label}</div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Filters & View Toggle */}
      <div className="glass-strong rounded-2xl p-4 md:p-6 border border-white/10 mb-6">
        <div className="flex flex-col md:flex-row gap-4">
          {/* Search */}
          <div className="flex-1 relative">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-white/40" />
            <input
              type="text"
              placeholder="Search showings..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-12 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500/50"
            />
          </div>

          {/* Status Filter */}
          <select
            value={selectedStatus}
            onChange={(e) => setSelectedStatus(e.target.value as ShowingStatus | 'all')}
            className="px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white focus:outline-none focus:border-purple-500/50"
          >
            <option value="all">All Status</option>
            <option value="confirmed">Confirmed</option>
            <option value="pending">Pending</option>
            <option value="completed">Completed</option>
            <option value="cancelled">Cancelled</option>
          </select>

          {/* View Toggle */}
          <div className="flex gap-2 bg-white/5 p-1 rounded-xl">
            <button
              onClick={() => setViewMode('list')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${
                viewMode === 'list'
                  ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white'
                  : 'text-white/60 hover:text-white'
              }`}
            >
              List
            </button>
            <button
              onClick={() => setViewMode('calendar')}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-all ${
                viewMode === 'calendar'
                  ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white'
                  : 'text-white/60 hover:text-white'
              }`}
            >
              Calendar
            </button>
          </div>
        </div>
      </div>

      {/* Showings List */}
      {viewMode === 'list' && (
        <div className="space-y-6">
          {sortedDates.length === 0 ? (
            <div className="glass-strong rounded-2xl p-12 border border-white/10 text-center">
              <CalendarIcon className="w-16 h-16 text-white/20 mx-auto mb-4" />
              <h3 className="text-xl font-bold text-white mb-2">No showings found</h3>
              <p className="text-white/60 mb-6">
                {searchQuery ? 'Try adjusting your search' : 'Start by scheduling your first showing'}
              </p>
            </div>
          ) : (
            sortedDates.map((date) => (
              <div key={date}>
                {/* Date Header */}
                <div className="flex items-center gap-3 mb-4">
                  <h2 className="text-xl font-bold text-white">
                    {getDateLabel(date)}
                  </h2>
                  <div className="flex-1 h-px bg-white/10" />
                  <span className="text-white/60 text-sm">
                    {showingsByDate[date].length} {showingsByDate[date].length === 1 ? 'showing' : 'showings'}
                  </span>
                </div>

                {/* Showings for this date */}
                <div className="space-y-3">
                  {showingsByDate[date]
                    .sort((a, b) => a.time.localeCompare(b.time))
                    .map((showing, index) => (
                      <motion.div
                        key={showing.id}
                        initial={{ y: 20, opacity: 0 }}
                        animate={{ y: 0, opacity: 1 }}
                        transition={{ delay: index * 0.05 }}
                        className="glass-strong rounded-2xl p-4 md:p-6 border border-white/10 hover:border-white/20 transition-all"
                      >
                        <div className="flex flex-col md:flex-row gap-4">
                          {/* Time */}
                          <div className="flex md:flex-col items-center md:items-start gap-2 md:gap-1 md:min-w-[100px]">
                            <Clock className="w-5 h-5 text-purple-400" />
                            <div>
                              <div className="text-white font-bold">{formatTime(showing.time)}</div>
                              <div className="text-white/60 text-xs">{showing.duration} min</div>
                            </div>
                          </div>

                          {/* Details */}
                          <div className="flex-1">
                            <div className="flex items-start justify-between mb-3">
                              <div className="flex-1">
                                <div className="flex items-center gap-2 mb-2">
                                  <h3 className="text-white font-semibold">
                                    {showing.property.address}
                                  </h3>
                                  <span className={`px-2 py-1 rounded-lg text-xs font-medium border flex items-center gap-1 ${getStatusColor(showing.status)}`}>
                                    {getStatusIcon(showing.status)}
                                    {showing.status}
                                  </span>
                                </div>

                                <div className="flex items-center gap-4 text-sm text-white/60 mb-2">
                                  <div className="flex items-center gap-1">
                                    <MapPin className="w-4 h-4" />
                                    <span>{showing.property.neighborhood}</span>
                                  </div>
                                  <div className="flex items-center gap-1">
                                    <Users className="w-4 h-4" />
                                    <span>{showing.client.name}</span>
                                  </div>
                                </div>

                                {showing.notes && (
                                  <p className="text-white/60 text-sm">{showing.notes}</p>
                                )}
                              </div>

                              {/* More Menu */}
                              <button className="w-8 h-8 rounded-lg bg-white/5 hover:bg-white/10 flex items-center justify-center transition-all">
                                <MoreVertical className="w-5 h-5 text-white/60" />
                              </button>
                            </div>

                            {/* Actions */}
                            <div className="flex gap-2">
                              <button className="flex items-center gap-2 px-3 py-2 rounded-lg bg-gradient-to-r from-purple-500 to-pink-500 text-white text-sm font-semibold hover:shadow-lg hover:shadow-purple-500/50 transition-all">
                                <MessageSquare className="w-4 h-4" />
                                Message
                              </button>
                              <button className="flex items-center gap-2 px-3 py-2 rounded-lg bg-white/5 hover:bg-white/10 text-white text-sm font-semibold border border-white/10 transition-all">
                                <Phone className="w-4 h-4" />
                                Call
                              </button>
                              <button className="flex items-center gap-2 px-3 py-2 rounded-lg bg-white/5 hover:bg-white/10 text-white text-sm font-semibold border border-white/10 transition-all">
                                <Home className="w-4 h-4" />
                                Property
                              </button>
                            </div>
                          </div>
                        </div>
                      </motion.div>
                    ))}
                </div>
              </div>
            ))
          )}
        </div>
      )}

      {/* Calendar View - Placeholder */}
      {viewMode === 'calendar' && (
        <div className="glass-strong rounded-2xl p-12 border border-white/10 text-center">
          <CalendarIcon className="w-16 h-16 text-white/20 mx-auto mb-4" />
          <h3 className="text-xl font-bold text-white mb-2">Calendar View</h3>
          <p className="text-white/60">
            Calendar view coming soon
          </p>
        </div>
      )}
    </div>
  );
}
