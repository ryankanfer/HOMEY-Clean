'use client';

export const dynamic = 'force-dynamic';

import { useState } from 'react';
import { motion } from 'framer-motion';
import {
  Home,
  Plus,
  Search,
  Filter,
  Eye,
  Heart,
  TrendingUp,
  DollarSign,
  MapPin,
  Bed,
  Bath,
  Square,
  Calendar,
  Users,
  MoreVertical,
  Edit,
  Share2,
  Trash2
} from 'lucide-react';
import Image from 'next/image';

type ListingRole = 'listing_agent' | 'buyers_agent' | 'dual_agent';
type ListingStatus = 'active' | 'pending' | 'sold' | 'expired' | 'withdrawn';

interface AgentListing {
  id: string;
  listingId: string;
  role: ListingRole;
  status: ListingStatus;
  property: {
    address: string;
    neighborhood: string;
    city: string;
    state: string;
    zipcode: string;
    price: number;
    bedrooms: number;
    bathrooms: number;
    sqft: number;
    imageUrl: string;
  };
  metrics: {
    views: number;
    saves: number;
    showings: number;
    offers: number;
  };
  listingDate: string;
  daysOnMarket: number;
  commissionPercentage?: number;
  potentialCommission?: number;
}

export default function ListingsPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedStatus, setSelectedStatus] = useState<ListingStatus | 'all'>('all');
  const [selectedRole, setSelectedRole] = useState<ListingRole | 'all'>('all');

  // Mock data - will be replaced with real Supabase data
  const listings: AgentListing[] = [
    {
      id: '1',
      listingId: 'listing-123',
      role: 'listing_agent',
      status: 'active',
      property: {
        address: '123 Main Street',
        neighborhood: 'Downtown',
        city: 'San Diego',
        state: 'CA',
        zipcode: '92101',
        price: 850000,
        bedrooms: 3,
        bathrooms: 2.5,
        sqft: 2100,
        imageUrl: 'https://photos.zillowstatic.com/fp/1234-cc_ft_768.jpg'
      },
      metrics: {
        views: 1250,
        saves: 43,
        showings: 12,
        offers: 2
      },
      listingDate: '2024-02-01',
      daysOnMarket: 23,
      commissionPercentage: 3.0,
      potentialCommission: 25500
    },
    {
      id: '2',
      listingId: 'listing-456',
      role: 'buyers_agent',
      status: 'pending',
      property: {
        address: '456 Oak Avenue',
        neighborhood: 'Midtown',
        city: 'San Diego',
        state: 'CA',
        zipcode: '92103',
        price: 625000,
        bedrooms: 2,
        bathrooms: 2,
        sqft: 1500,
        imageUrl: 'https://photos.zillowstatic.com/fp/5678-cc_ft_768.jpg'
      },
      metrics: {
        views: 890,
        saves: 31,
        showings: 8,
        offers: 1
      },
      listingDate: '2024-01-15',
      daysOnMarket: 40,
      commissionPercentage: 2.5,
      potentialCommission: 15625
    },
    {
      id: '3',
      listingId: 'listing-789',
      role: 'listing_agent',
      status: 'active',
      property: {
        address: '789 Pine Road',
        neighborhood: 'Westside',
        city: 'San Diego',
        state: 'CA',
        zipcode: '92110',
        price: 1200000,
        bedrooms: 4,
        bathrooms: 3,
        sqft: 2800,
        imageUrl: 'https://photos.zillowstatic.com/fp/9012-cc_ft_768.jpg'
      },
      metrics: {
        views: 2100,
        saves: 67,
        showings: 18,
        offers: 0
      },
      listingDate: '2024-02-10',
      daysOnMarket: 14,
      commissionPercentage: 3.0,
      potentialCommission: 36000
    },
    {
      id: '4',
      listingId: 'listing-234',
      role: 'buyers_agent',
      status: 'sold',
      property: {
        address: '234 Elm Street',
        neighborhood: 'North Park',
        city: 'San Diego',
        state: 'CA',
        zipcode: '92104',
        price: 550000,
        bedrooms: 2,
        bathrooms: 1.5,
        sqft: 1200,
        imageUrl: 'https://photos.zillowstatic.com/fp/3456-cc_ft_768.jpg'
      },
      metrics: {
        views: 650,
        saves: 28,
        showings: 6,
        offers: 1
      },
      listingDate: '2024-01-05',
      daysOnMarket: 35,
      commissionPercentage: 2.5,
      potentialCommission: 13750
    }
  ];

  const filteredListings = listings.filter(listing => {
    const matchesSearch = listing.property.address.toLowerCase().includes(searchQuery.toLowerCase()) ||
      listing.property.neighborhood.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesStatus = selectedStatus === 'all' || listing.status === selectedStatus;
    const matchesRole = selectedRole === 'all' || listing.role === selectedRole;
    return matchesSearch && matchesStatus && matchesRole;
  });

  const statusCounts = {
    all: listings.length,
    active: listings.filter(l => l.status === 'active').length,
    pending: listings.filter(l => l.status === 'pending').length,
    sold: listings.filter(l => l.status === 'sold').length,
    expired: listings.filter(l => l.status === 'expired').length,
    withdrawn: listings.filter(l => l.status === 'withdrawn').length
  };

  const totalCommission = listings
    .filter(l => l.status === 'sold' || l.status === 'pending')
    .reduce((sum, l) => sum + (l.potentialCommission || 0), 0);

  const getStatusColor = (status: ListingStatus) => {
    switch (status) {
      case 'active':
        return 'bg-green-500/20 text-green-300 border-green-500/30';
      case 'pending':
        return 'bg-yellow-500/20 text-yellow-300 border-yellow-500/30';
      case 'sold':
        return 'bg-blue-500/20 text-blue-300 border-blue-500/30';
      case 'expired':
        return 'bg-red-500/20 text-red-300 border-red-500/30';
      case 'withdrawn':
        return 'bg-gray-500/20 text-gray-300 border-gray-500/30';
    }
  };

  const getRoleLabel = (role: ListingRole) => {
    switch (role) {
      case 'listing_agent':
        return 'Listing Agent';
      case 'buyers_agent':
        return "Buyer's Agent";
      case 'dual_agent':
        return 'Dual Agent';
    }
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0
    }).format(price);
  };

  return (
    <div className="p-4 md:p-8 max-w-7xl mx-auto">
      {/* Header */}
      <div className="mb-8">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-3xl md:text-4xl font-bold text-white mb-2">
              My Listings
            </h1>
            <p className="text-white/60">
              Manage your property listings and track performance
            </p>
          </div>

          <button className="flex items-center gap-2 px-4 md:px-6 py-3 rounded-xl bg-gradient-to-r from-purple-500 to-pink-500 text-white font-semibold hover:shadow-lg hover:shadow-purple-500/50 transition-all">
            <Plus className="w-5 h-5" />
            <span className="hidden md:inline">Add Listing</span>
            <span className="md:hidden">Add</span>
          </button>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4 mb-6">
          {[
            { label: 'Active', value: statusCounts.active, icon: Home, color: 'from-green-500 to-emerald-500' },
            { label: 'Pending', value: statusCounts.pending, icon: Calendar, color: 'from-yellow-500 to-orange-500' },
            { label: 'Sold', value: statusCounts.sold, icon: TrendingUp, color: 'from-blue-500 to-cyan-500' },
            { label: 'Potential Commission', value: formatPrice(totalCommission), icon: DollarSign, color: 'from-purple-500 to-pink-500' }
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
                <div className="text-xl md:text-2xl font-bold text-white mb-1 truncate">{stat.value}</div>
                <div className="text-white/60 text-sm">{stat.label}</div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Filters */}
      <div className="glass-strong rounded-2xl p-4 md:p-6 border border-white/10 mb-6">
        <div className="flex flex-col gap-4">
          {/* Search */}
          <div className="relative">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-white/40" />
            <input
              type="text"
              placeholder="Search listings..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-12 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500/50"
            />
          </div>

          {/* Status & Role Filters */}
          <div className="flex flex-col md:flex-row gap-4">
            <div className="flex-1">
              <label className="block text-white/60 text-sm mb-2">Status</label>
              <select
                value={selectedStatus}
                onChange={(e) => setSelectedStatus(e.target.value as ListingStatus | 'all')}
                className="w-full px-4 py-2 bg-white/5 border border-white/10 rounded-xl text-white focus:outline-none focus:border-purple-500/50"
              >
                <option value="all">All Status</option>
                <option value="active">Active</option>
                <option value="pending">Pending</option>
                <option value="sold">Sold</option>
                <option value="expired">Expired</option>
                <option value="withdrawn">Withdrawn</option>
              </select>
            </div>

            <div className="flex-1">
              <label className="block text-white/60 text-sm mb-2">Role</label>
              <select
                value={selectedRole}
                onChange={(e) => setSelectedRole(e.target.value as ListingRole | 'all')}
                className="w-full px-4 py-2 bg-white/5 border border-white/10 rounded-xl text-white focus:outline-none focus:border-purple-500/50"
              >
                <option value="all">All Roles</option>
                <option value="listing_agent">Listing Agent</option>
                <option value="buyers_agent">Buyer's Agent</option>
                <option value="dual_agent">Dual Agent</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      {/* Listings Grid */}
      {filteredListings.length === 0 ? (
        <div className="glass-strong rounded-2xl p-12 border border-white/10 text-center">
          <Home className="w-16 h-16 text-white/20 mx-auto mb-4" />
          <h3 className="text-xl font-bold text-white mb-2">No listings found</h3>
          <p className="text-white/60 mb-6">
            {searchQuery ? 'Try adjusting your search' : 'Start by adding your first listing'}
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {filteredListings.map((listing, index) => (
            <motion.div
              key={listing.id}
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: index * 0.05 }}
              className="glass-strong rounded-2xl overflow-hidden border border-white/10 hover:border-white/20 transition-all"
            >
              {/* Image */}
              <div className="relative h-48 bg-white/5">
                <Image
                  src={listing.property.imageUrl}
                  alt={listing.property.address}
                  fill
                  className="object-cover"
                />
                <div className="absolute top-3 left-3 flex gap-2">
                  <span className={`px-3 py-1 rounded-lg text-xs font-medium border ${getStatusColor(listing.status)}`}>
                    {listing.status}
                  </span>
                  <span className="px-3 py-1 rounded-lg text-xs font-medium bg-black/60 text-white border border-white/20">
                    {getRoleLabel(listing.role)}
                  </span>
                </div>
                <div className="absolute top-3 right-3">
                  <button className="w-8 h-8 rounded-lg bg-black/60 backdrop-blur-sm flex items-center justify-center border border-white/20 hover:bg-black/80 transition-all">
                    <MoreVertical className="w-4 h-4 text-white" />
                  </button>
                </div>
              </div>

              {/* Content */}
              <div className="p-4 md:p-6">
                {/* Price & Address */}
                <div className="mb-4">
                  <div className="text-2xl md:text-3xl font-bold text-white mb-2">
                    {formatPrice(listing.property.price)}
                  </div>
                  <h3 className="text-white font-semibold mb-1">
                    {listing.property.address}
                  </h3>
                  <div className="flex items-center gap-1 text-white/60 text-sm">
                    <MapPin className="w-4 h-4" />
                    <span>{listing.property.neighborhood}, {listing.property.city}</span>
                  </div>
                </div>

                {/* Property Details */}
                <div className="flex items-center gap-4 mb-4 text-white/80">
                  <div className="flex items-center gap-1">
                    <Bed className="w-4 h-4" />
                    <span className="text-sm">{listing.property.bedrooms}</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <Bath className="w-4 h-4" />
                    <span className="text-sm">{listing.property.bathrooms}</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <Square className="w-4 h-4" />
                    <span className="text-sm">{listing.property.sqft.toLocaleString()} sqft</span>
                  </div>
                </div>

                {/* Metrics */}
                <div className="grid grid-cols-4 gap-2 mb-4">
                  {[
                    { icon: Eye, value: listing.metrics.views, label: 'Views' },
                    { icon: Heart, value: listing.metrics.saves, label: 'Saves' },
                    { icon: Calendar, value: listing.metrics.showings, label: 'Showings' },
                    { icon: DollarSign, value: listing.metrics.offers, label: 'Offers' }
                  ].map((metric) => {
                    const Icon = metric.icon;
                    return (
                      <div key={metric.label} className="text-center p-2 rounded-lg bg-white/5">
                        <Icon className="w-4 h-4 text-white/40 mx-auto mb-1" />
                        <div className="text-white font-bold text-sm">{metric.value}</div>
                        <div className="text-white/40 text-xs">{metric.label}</div>
                      </div>
                    );
                  })}
                </div>

                {/* Days on Market & Commission */}
                <div className="flex items-center justify-between text-xs text-white/60 mb-4 p-3 rounded-lg bg-white/5">
                  <span>{listing.daysOnMarket} days on market</span>
                  {listing.potentialCommission && (
                    <span className="font-semibold text-green-400">
                      {formatPrice(listing.potentialCommission)} commission
                    </span>
                  )}
                </div>

                {/* Actions */}
                <div className="flex gap-2">
                  <button className="flex-1 flex items-center justify-center gap-2 px-3 py-2 rounded-lg bg-gradient-to-r from-purple-500 to-pink-500 text-white text-sm font-semibold hover:shadow-lg hover:shadow-purple-500/50 transition-all">
                    <Edit className="w-4 h-4" />
                    Edit
                  </button>
                  <button className="flex items-center justify-center gap-2 px-3 py-2 rounded-lg bg-white/5 hover:bg-white/10 text-white text-sm font-semibold border border-white/10 transition-all">
                    <Share2 className="w-4 h-4" />
                  </button>
                  <button className="flex items-center justify-center gap-2 px-3 py-2 rounded-lg bg-white/5 hover:bg-white/10 text-white text-sm font-semibold border border-white/10 transition-all">
                    <Users className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      )}
    </div>
  );
}
