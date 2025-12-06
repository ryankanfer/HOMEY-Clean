'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { auth, db } from '@/lib/supabase';
import { useUserProfile } from '@/contexts/UserProfileContext';
import { getUserPreferences, getLocationDisplayName, type UserPreferences } from '@/lib/preferences';
import { clearAllSecureData } from '@/lib/secureStorage';
import { analytics } from '@/lib/analytics';
import BottomNavigation from '@/components/BottomNav';
import { useClientAgent } from '@/hooks/useClientAgent';
import {
  Phone, Mail, MessageCircle, Shield, Check, Users, Building,
  ChevronRight, Heart, Search, TrendingUp, LogOut, Settings as SettingsIcon,
  MapPin, DollarSign, BedDouble, Home, Sparkles
} from 'lucide-react';
import { Merriweather, Inter } from 'next/font/google';

const merriweather = Merriweather({
  weight: ['300', '400', '700'],
  subsets: ['latin'],
  variable: '--font-merriweather'
});

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter'
});

interface UserData {
  id: string;
  email: string;
  full_name?: string;
  avatar_url?: string;
  created_at?: string;
}

interface UserStats {
  totalSwipes: number;
  totalLikes: number;
  savedProperties: number;
  designSwipes: number;
}

export default function ProfilePage() {
  const router = useRouter();
  const { profile, isLoading: profileLoading, error, refreshProfile } = useUserProfile();
  const { agent: agentConnection, hasAgent } = useClientAgent();
  const [user, setUser] = useState<UserData | null>(null);
  const [stats, setStats] = useState<UserStats | null>(null);
  const [preferences, setPreferences] = useState<UserPreferences | null>(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  // Edit mode
  const [isEditingProfile, setIsEditingProfile] = useState(false);
  const [fullName, setFullName] = useState('');
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    loadUserData();
  }, []);

  const loadUserData = async () => {
    try {
      const { data: { user: authUser } } = await auth.getUser();

      if (!authUser) {
        router.push('/login');
        return;
      }

      setIsAuthenticated(true);
      setUser({
        id: authUser.id,
        email: authUser.email || '',
        full_name: authUser.user_metadata?.full_name,
        avatar_url: authUser.user_metadata?.avatar_url,
        created_at: authUser.created_at,
      });

      setFullName(authUser.user_metadata?.full_name || '');

      // Load preferences
      const prefs = await getUserPreferences(authUser.id);
      if (prefs) {
        setPreferences(prefs);
      }

      // Load stats
      await loadUserStats(authUser.id);

      setLoading(false);
    } catch (err) {
      console.error('Failed to load user data:', err);
      setLoading(false);
    }
  };

  const loadUserStats = async (userId: string) => {
    try {
      const [swipeStats, savedProps, designStats] = await Promise.all([
        db.getSwipeStats(userId),
        db.getSavedProperties(userId),
        db.getDesignSwipeStats(userId),
      ]);

      setStats({
        totalSwipes: swipeStats.data?.total || 0,
        totalLikes: (swipeStats.data?.likes || 0) + (swipeStats.data?.loves || 0),
        savedProperties: savedProps.data?.length || 0,
        designSwipes: designStats.data?.total || 0,
      });
    } catch (err) {
      console.error('Failed to load stats:', err);
    }
  };

  const handleSaveProfile = async () => {
    if (!user) return;

    setIsSaving(true);
    try {
      // Update profile in database
      await db.updateProfile(user.id, {
        full_name: fullName,
      });

      // Update auth user metadata so it persists across sessions
      try {
        await auth.updateUser({
          data: {
            full_name: fullName,
          }
        });
        console.log('✅ User metadata updated with full_name');
      } catch (metaError) {
        console.error('❌ Failed to update user metadata:', metaError);
        // Continue anyway - profile update succeeded
      }

      setUser({
        ...user,
        full_name: fullName,
      });

      setIsEditingProfile(false);
      analytics.updateProfile({ full_name: fullName });

      // Refresh the page to update all components with new name
      window.location.reload();
    } catch (err) {
      console.error('Failed to update profile:', err);
    } finally {
      setIsSaving(false);
    }
  };

  const handleSignOut = async () => {
    const confirmed = window.confirm('Are you sure you want to sign out?');
    if (!confirmed) return;

    clearAllSecureData();
    await auth.signOut();
    analytics.signOut();
    router.push('/');
  };

  const getInitials = (name?: string) => {
    if (!name) return '?';
    return name
      .split(' ')
      .map(n => n[0])
      .join('')
      .toUpperCase()
      .slice(0, 2);
  };

  const getAgentInitials = (name?: string) => {
    if (!name) return 'AG';
    const parts = name.split(' ');
    if (parts.length >= 2) {
      return `${parts[0][0]}${parts[parts.length - 1][0]}`.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  };

  const formatDate = (dateString?: string) => {
    if (!dateString) return 'Unknown';
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  };

  if (!isAuthenticated || loading || profileLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 flex items-center justify-center">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-white/20 border-t-purple-400 rounded-full animate-spin mx-auto mb-4"></div>
          <p className={`text-white/80 ${merriweather.className}`}>Loading your profile...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 p-6 flex items-center justify-center">
        <div className="bg-red-500/20 border-2 border-red-500 rounded-xl p-6 max-w-md">
          <h2 className={`text-xl font-bold text-red-400 mb-2 ${merriweather.className}`}>Error Loading Profile</h2>
          <p className="text-white/80 mb-4">{error}</p>
          <button
            onClick={refreshProfile}
            className="bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-600 transition-colors"
          >
            Retry
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className={`min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 pb-24 ${inter.className}`}>
      {/* Passport-style Header */}
      <div className="relative overflow-hidden bg-gradient-to-b from-black/40 via-purple-900/20 to-transparent backdrop-blur-xl border-b border-white/10">
        <div className="absolute inset-0 bg-[url('/noise.png')] opacity-5"></div>
        <div className="relative px-6 pt-12 pb-8">
          <div className="max-w-4xl mx-auto">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="flex items-center gap-4 mb-6"
            >
              <h1 className={`text-4xl font-light text-white tracking-tight ${merriweather.className}`}>
                Profile
              </h1>
              <div className="flex-1 h-px bg-gradient-to-r from-white/20 to-transparent"></div>
            </motion.div>
          </div>
        </div>
      </div>

      <div className="px-5 py-6 max-w-4xl mx-auto space-y-6">
        {/* Profile Card */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="relative overflow-hidden rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 p-8"
        >
          <div className="absolute top-0 right-0 w-64 h-64 bg-gradient-to-br from-purple-500/10 to-transparent rounded-full blur-3xl"></div>

          <div className="relative">
            <div className="flex flex-col md:flex-row items-start md:items-center gap-6 mb-8">
              {/* Avatar */}
              <div className="relative">
                {user?.avatar_url ? (
                  <img
                    src={user.avatar_url}
                    alt={user.full_name || 'User'}
                    className="w-28 h-28 rounded-2xl object-cover border-2 border-purple-400/30 shadow-2xl"
                  />
                ) : (
                  <div className="w-28 h-28 rounded-2xl bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-white text-4xl font-bold border-2 border-purple-400/30 shadow-2xl">
                    {getInitials(user?.full_name)}
                  </div>
                )}
              </div>

              {/* Info */}
              <div className="flex-1">
                {isEditingProfile ? (
                  <div className="space-y-3">
                    <input
                      type="text"
                      value={fullName}
                      onChange={(e) => setFullName(e.target.value)}
                      placeholder="Full name"
                      className="w-full px-4 py-3 bg-white/5 border border-white/20 rounded-xl text-white placeholder-white/40 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                    />
                    <div className="flex gap-2">
                      <button
                        onClick={handleSaveProfile}
                        disabled={isSaving}
                        className="px-6 py-2.5 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-xl font-semibold hover:opacity-90 transition-opacity disabled:opacity-50"
                      >
                        {isSaving ? 'Saving...' : 'Save'}
                      </button>
                      <button
                        onClick={() => {
                          setIsEditingProfile(false);
                          setFullName(user?.full_name || '');
                        }}
                        className="px-6 py-2.5 bg-white/5 text-white rounded-xl font-semibold hover:bg-white/10 transition-colors"
                      >
                        Cancel
                      </button>
                    </div>
                  </div>
                ) : (
                  <>
                    <h2 className={`text-3xl font-light text-white mb-2 ${merriweather.className}`}>
                      {user?.full_name || 'Anonymous User'}
                    </h2>
                    <p className="text-white/60 mb-1">{user?.email}</p>
                    <p className="text-white/40 text-sm">
                      Member since {formatDate(user?.created_at)}
                    </p>
                    <button
                      onClick={() => setIsEditingProfile(true)}
                      className="mt-3 text-purple-400 hover:text-purple-300 transition-colors text-sm font-medium"
                    >
                      Edit Profile →
                    </button>
                  </>
                )}
              </div>
            </div>

            {/* Stats Grid */}
            {stats && (
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4 pt-6 border-t border-white/10">
                <div className="text-center">
                  <div className="flex items-center justify-center gap-2 mb-2">
                    <Search className="w-4 h-4 text-purple-400" />
                  </div>
                  <div className={`text-3xl font-light text-white mb-1 ${merriweather.className}`}>
                    {stats.totalSwipes}
                  </div>
                  <div className="text-white/50 text-sm">Swipes</div>
                </div>
                <div className="text-center">
                  <div className="flex items-center justify-center gap-2 mb-2">
                    <Heart className="w-4 h-4 text-pink-400" />
                  </div>
                  <div className={`text-3xl font-light text-white mb-1 ${merriweather.className}`}>
                    {stats.savedProperties}
                  </div>
                  <div className="text-white/50 text-sm">Saved</div>
                </div>
                <div className="text-center">
                  <div className="flex items-center justify-center gap-2 mb-2">
                    <TrendingUp className="w-4 h-4 text-cyan-400" />
                  </div>
                  <div className={`text-3xl font-light text-white mb-1 ${merriweather.className}`}>
                    {stats.totalLikes}
                  </div>
                  <div className="text-white/50 text-sm">Liked</div>
                </div>
                <div className="text-center">
                  <div className="flex items-center justify-center gap-2 mb-2">
                    <Home className="w-4 h-4 text-purple-400" />
                  </div>
                  <div className={`text-3xl font-light text-white mb-1 ${merriweather.className}`}>
                    {stats.designSwipes}
                  </div>
                  <div className="text-white/50 text-sm">Styles</div>
                </div>
              </div>
            )}
          </div>
        </motion.div>

        {/* What Homey Knows - AI Profile */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 overflow-hidden"
        >
          <div className="p-6 border-b border-white/10">
            <h3 className={`text-2xl font-light text-white mb-1 ${merriweather.className}`}>
              What Homey Knows
            </h3>
            <p className="text-white/50 text-sm">AI-learned insights from your documents</p>
          </div>

          {profile && Object.keys(profile).length > 1 && Object.values(profile).some(val =>
            val !== null && val !== undefined && val !== '' &&
            (Array.isArray(val) ? val.length > 0 : true)
          ) ? (
            <div className="p-6 space-y-4">
              {/* Your Style & Preferences - Conversational */}
              {(profile.preferred_neighborhoods || profile.min_bedrooms || profile.budget_min) && (
                <div className="bg-gradient-to-br from-purple-500/10 to-pink-500/10 rounded-xl p-5 border border-purple-400/20">
                  <div className="flex items-center gap-2 mb-4">
                    <Sparkles className="w-5 h-5 text-purple-400" />
                    <h4 className="text-white font-semibold">Your Style</h4>
                  </div>

                  <div className="space-y-4">
                    {/* Conversational Summary */}
                    <div className="text-white/90 leading-relaxed">
                      <p className="mb-3">
                        Based on your activity, you lean towards{' '}
                        {profile.min_bedrooms && (
                          <>
                            <span className="text-purple-300 font-medium">
                              {profile.min_bedrooms}+ bedroom homes
                            </span>
                            {profile.budget_min && profile.budget_max && ' '}
                          </>
                        )}
                        {profile.budget_min && profile.budget_max && (
                          <>
                            <span className="text-purple-300 font-medium">
                              in the ${profile.budget_min.toLocaleString()}-${profile.budget_max.toLocaleString()}/mo range
                            </span>
                          </>
                        )}
                        {profile.preferred_neighborhoods && profile.preferred_neighborhoods.length > 0 && (
                          <>
                            {', particularly in '}
                            <span className="text-purple-300 font-medium">
                              {profile.preferred_neighborhoods.slice(0, 2).join(' and ')}
                            </span>
                            {profile.preferred_neighborhoods.length > 2 && (
                              <span className="text-white/60"> and {profile.preferred_neighborhoods.length - 2} more</span>
                            )}
                          </>
                        )}
                        .
                      </p>
                    </div>

                    {/* Tags/Keywords */}
                    {profile.preferred_neighborhoods && profile.preferred_neighborhoods.length > 0 && (
                      <div>
                        <p className="text-white/60 text-xs mb-2">Neighborhood Preferences</p>
                        <div className="flex flex-wrap gap-2">
                          {profile.preferred_neighborhoods.map((tag, i) => (
                            <span
                              key={i}
                              className="inline-flex items-center gap-1 px-3 py-1.5 bg-purple-500/20 border border-purple-400/30 text-purple-200 rounded-full text-xs font-medium"
                            >
                              <MapPin className="w-3 h-3" />
                              {tag}
                            </span>
                          ))}
                        </div>
                      </div>
                    )}

                    {/* Additional preference tags */}
                    <div>
                      <p className="text-white/60 text-xs mb-2">What You're Looking For</p>
                      <div className="flex flex-wrap gap-2">
                        {profile.min_bedrooms && (
                          <span className="inline-flex items-center gap-1 px-3 py-1.5 bg-blue-500/20 border border-blue-400/30 text-blue-200 rounded-full text-xs font-medium">
                            <BedDouble className="w-3 h-3" />
                            {profile.min_bedrooms}+ Bedrooms
                          </span>
                        )}
                        {profile.pet_friendly && (
                          <span className="inline-flex items-center gap-1 px-3 py-1.5 bg-green-500/20 border border-green-400/30 text-green-200 rounded-full text-xs font-medium">
                            🐾 Pet Friendly
                          </span>
                        )}
                        {profile.budget_min && profile.budget_max && (
                          <span className="inline-flex items-center gap-1 px-3 py-1.5 bg-emerald-500/20 border border-emerald-400/30 text-emerald-200 rounded-full text-xs font-medium">
                            <DollarSign className="w-3 h-3" />
                            ${profile.budget_min.toLocaleString()}-${profile.budget_max.toLocaleString()}/mo
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* Financial Profile */}
              {(profile.monthly_income || profile.max_budget || profile.pre_approval_amount) && (
                <div className="bg-white/5 rounded-xl p-5 border border-white/10">
                  <div className="flex items-center gap-2 mb-4">
                    <DollarSign className="w-5 h-5 text-green-400" />
                    <h4 className="text-white font-semibold">Financial Profile</h4>
                  </div>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                    {profile.monthly_income && (
                      <div className="bg-black/20 rounded-lg p-3">
                        <p className="text-white/40 text-xs mb-1">Monthly Income</p>
                        <p className={`text-xl font-light text-white ${merriweather.className}`}>
                          ${profile.monthly_income.toLocaleString()}
                        </p>
                      </div>
                    )}
                    {profile.max_budget && (
                      <div className="bg-black/20 rounded-lg p-3">
                        <p className="text-white/40 text-xs mb-1">Max Budget</p>
                        <p className={`text-xl font-light text-white ${merriweather.className}`}>
                          ${profile.max_budget.toLocaleString()}/mo
                        </p>
                      </div>
                    )}
                    {profile.pre_approval_amount && (
                      <div className="bg-black/20 rounded-lg p-3">
                        <p className="text-white/40 text-xs mb-1">Pre-Approval</p>
                        <p className={`text-xl font-light text-green-400 ${merriweather.className}`}>
                          ${profile.pre_approval_amount.toLocaleString()}
                        </p>
                      </div>
                    )}
                  </div>
                </div>
              )}

              {/* Housing Preferences */}
              {(profile.budget_min || profile.min_bedrooms || profile.preferred_neighborhoods) && (
                <div className="bg-white/5 rounded-xl p-5 border border-white/10">
                  <div className="flex items-center gap-2 mb-4">
                    <Home className="w-5 h-5 text-purple-400" />
                    <h4 className="text-white font-semibold">Housing Preferences</h4>
                  </div>
                  <div className="space-y-3">
                    {profile.budget_min && profile.budget_max && (
                      <div className="bg-black/20 rounded-lg p-3">
                        <p className="text-white/40 text-xs mb-1">Budget Range</p>
                        <p className="text-white font-medium">
                          ${profile.budget_min.toLocaleString()} - ${profile.budget_max.toLocaleString()}/mo
                        </p>
                      </div>
                    )}
                    <div className="grid grid-cols-2 gap-3">
                      {profile.min_bedrooms && (
                        <div className="bg-black/20 rounded-lg p-3">
                          <p className="text-white/40 text-xs mb-1">Bedrooms</p>
                          <p className="text-white font-medium">{profile.min_bedrooms}+</p>
                        </div>
                      )}
                      {profile.min_bathrooms && (
                        <div className="bg-black/20 rounded-lg p-3">
                          <p className="text-white/40 text-xs mb-1">Bathrooms</p>
                          <p className="text-white font-medium">{profile.min_bathrooms}+</p>
                        </div>
                      )}
                    </div>
                    {profile.preferred_neighborhoods && profile.preferred_neighborhoods.length > 0 && (
                      <div className="bg-black/20 rounded-lg p-3">
                        <p className="text-white/40 text-xs mb-2">Neighborhoods</p>
                        <div className="flex flex-wrap gap-2">
                          {profile.preferred_neighborhoods.map((neighborhood, i) => (
                            <span
                              key={i}
                              className="bg-purple-500/20 border border-purple-400/30 text-purple-200 px-3 py-1 rounded-full text-xs"
                            >
                              {neighborhood}
                            </span>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                </div>
              )}

              {/* Current Lease */}
              {profile.current_lease_address && (
                <div className="bg-white/5 rounded-xl p-5 border border-white/10">
                  <div className="flex items-center gap-2 mb-4">
                    <MapPin className="w-5 h-5 text-cyan-400" />
                    <h4 className="text-white font-semibold">Current Lease</h4>
                  </div>
                  <div className="space-y-3">
                    <div className="bg-black/20 rounded-lg p-3">
                      <p className="text-white/40 text-xs mb-1">Address</p>
                      <p className="text-white text-sm">{profile.current_lease_address}</p>
                    </div>
                    <div className="grid grid-cols-2 gap-3">
                      {profile.current_monthly_rent && (
                        <div className="bg-black/20 rounded-lg p-3">
                          <p className="text-white/40 text-xs mb-1">Current Rent</p>
                          <p className="text-white font-medium">
                            ${profile.current_monthly_rent.toLocaleString()}/mo
                          </p>
                        </div>
                      )}
                      {profile.current_lease_end_date && (
                        <div className="bg-black/20 rounded-lg p-3">
                          <p className="text-white/40 text-xs mb-1">Lease Ends</p>
                          <p className="text-white font-medium">
                            {new Date(profile.current_lease_end_date).toLocaleDateString()}
                          </p>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              )}
            </div>
          ) : (
            <div className="p-8 text-center">
              <div className="w-20 h-20 mx-auto mb-6 rounded-2xl bg-gradient-to-br from-purple-500/20 to-pink-500/20 border border-purple-400/30 flex items-center justify-center">
                <Sparkles className="w-10 h-10 text-purple-400" />
              </div>
              <h4 className={`text-xl font-light text-white mb-3 ${merriweather.className}`}>
                HOMEY is learning about you
              </h4>
              <p className="text-white/60 text-sm max-w-md mx-auto">
                As you interact with properties and upload documents, HOMEY will learn your preferences and display them here.
              </p>
            </div>
          )}
        </motion.div>

        {/* My Agent */}
        {hasAgent && agentConnection && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.15 }}
            className="rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 p-6"
          >
            <div className="flex items-center gap-2 mb-6">
              <Users className="w-5 h-5 text-purple-400" />
              <h3 className={`text-2xl font-light text-white ${merriweather.className}`}>My Agent</h3>
            </div>

            <div className="space-y-4">
              {/* Agent Profile */}
              <div className="flex items-start gap-4 p-4 bg-white/5 rounded-xl border border-white/10">
                <div className="relative">
                  {agentConnection.agent?.user?.avatar_url ? (
                    <img
                      src={agentConnection.agent.user.avatar_url}
                      alt={agentConnection.agent?.user?.full_name || 'Agent'}
                      className="w-16 h-16 rounded-xl object-cover border-2 border-purple-400/30"
                    />
                  ) : (
                    <div className="w-16 h-16 rounded-xl bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-white text-lg font-bold border-2 border-purple-400/30">
                      {getAgentInitials(agentConnection.agent?.user?.full_name)}
                    </div>
                  )}
                  {agentConnection.agent?.verified && (
                    <div className="absolute -bottom-1 -right-1 w-5 h-5 bg-blue-500 rounded-full border-2 border-slate-900 flex items-center justify-center">
                      <Check className="w-3 h-3 text-white" />
                    </div>
                  )}
                </div>

                <div className="flex-1">
                  <h4 className="text-white font-bold text-lg mb-1">
                    {agentConnection.agent?.user?.full_name || 'Your Agent'}
                  </h4>
                  {agentConnection.agent?.brokerage_name && (
                    <div className="flex items-center gap-2 text-white/60 text-sm mb-2">
                      <Building className="w-4 h-4" />
                      {agentConnection.agent.brokerage_name}
                    </div>
                  )}
                  {agentConnection.agent?.license_number && (
                    <p className="text-white/40 text-sm">
                      License: {agentConnection.agent.license_number}
                      {agentConnection.agent.license_state && ` (${agentConnection.agent.license_state})`}
                    </p>
                  )}
                </div>
              </div>

              {/* Contact Buttons */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                {agentConnection.agent?.professional_phone && (
                  <a
                    href={`tel:${agentConnection.agent.professional_phone}`}
                    className="flex items-center justify-center gap-2 p-3 bg-white/5 hover:bg-white/10 rounded-xl transition-colors border border-white/10"
                  >
                    <Phone className="w-4 h-4 text-purple-400" />
                    <span className="text-white text-sm font-medium">Call</span>
                  </a>
                )}
                {agentConnection.agent?.professional_email && (
                  <a
                    href={`mailto:${agentConnection.agent.professional_email}`}
                    className="flex items-center justify-center gap-2 p-3 bg-white/5 hover:bg-white/10 rounded-xl transition-colors border border-white/10"
                  >
                    <Mail className="w-4 h-4 text-purple-400" />
                    <span className="text-white text-sm font-medium">Email</span>
                  </a>
                )}
                <button
                  onClick={() => router.push('/home')}
                  className="flex items-center justify-center gap-2 p-3 bg-white/5 hover:bg-white/10 rounded-xl transition-colors border border-white/10"
                >
                  <MessageCircle className="w-4 h-4 text-purple-400" />
                  <span className="text-white text-sm font-medium">Message</span>
                </button>
              </div>

              <div className="p-3 bg-green-500/10 border border-green-500/30 rounded-xl">
                <div className="flex items-center gap-2 text-green-300 text-sm">
                  <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
                  Connected since {new Date(agentConnection.created_at || '').toLocaleDateString()}
                </div>
              </div>
            </div>
          </motion.div>
        )}

        {/* Data & Permissions */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 p-6"
        >
          <div className="flex items-center gap-2 mb-6">
            <Shield className="w-5 h-5 text-purple-400" />
            <h3 className={`text-2xl font-light text-white ${merriweather.className}`}>Data & Permissions</h3>
          </div>

          <p className="text-white/60 text-sm mb-4">
            Control who can access your information and what they can see
          </p>

          <div className="space-y-3">
            {hasAgent && agentConnection && (
              <div className="p-4 bg-white/5 rounded-xl border border-white/10">
                <div className="flex items-start gap-3">
                  <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-white text-sm font-bold flex-shrink-0">
                    {getAgentInitials(agentConnection.agent?.user?.full_name)}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center justify-between mb-2">
                      <h4 className="text-white font-semibold text-sm">
                        {agentConnection.agent?.user?.full_name || 'Your Agent'}
                      </h4>
                      <span className="text-xs text-green-400 flex items-center gap-1">
                        <Check className="w-3 h-3" />
                        Connected
                      </span>
                    </div>
                    <div className="space-y-1">
                      <p className="text-white/50 text-xs flex items-center gap-2">
                        <Check className="w-3 h-3 text-purple-400" />
                        View property preferences
                      </p>
                      <p className="text-white/50 text-xs flex items-center gap-2">
                        <Check className="w-3 h-3 text-purple-400" />
                        See liked properties
                      </p>
                      <p className="text-white/50 text-xs flex items-center gap-2">
                        <Check className="w-3 h-3 text-purple-400" />
                        Access search history
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            )}

            <div className="p-4 bg-white/5 rounded-xl border border-white/10">
              <div className="flex items-start gap-3">
                <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-2xl flex-shrink-0">
                  🏡
                </div>
                <div className="flex-1">
                  <div className="flex items-center justify-between mb-2">
                    <h4 className="text-white font-semibold text-sm">HOMEY Platform</h4>
                    <span className="text-xs text-green-400 flex items-center gap-1">
                      <Check className="w-3 h-3" />
                      Active
                    </span>
                  </div>
                  <div className="space-y-1">
                    <p className="text-white/50 text-xs flex items-center gap-2">
                      <Check className="w-3 h-3 text-purple-400" />
                      Personalized recommendations
                    </p>
                    <p className="text-white/50 text-xs flex items-center gap-2">
                      <Check className="w-3 h-3 text-purple-400" />
                      Learning your style preferences
                    </p>
                    <p className="text-white/50 text-xs flex items-center gap-2">
                      <Check className="w-3 h-3 text-purple-400" />
                      Analytics to improve experience
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </motion.div>

        {/* Quick Actions */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.25 }}
          className="rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 p-6"
        >
          <h3 className={`text-2xl font-light text-white mb-4 ${merriweather.className}`}>Quick Actions</h3>
          <div className="space-y-2">
            <button
              onClick={() => router.push('/settings/preferences')}
              className="w-full flex items-center justify-between p-4 bg-white/5 rounded-xl hover:bg-white/10 transition-colors group"
            >
              <div className="flex items-center gap-3">
                <SettingsIcon className="w-5 h-5 text-purple-400" />
                <span className="text-white font-medium">Edit Preferences</span>
              </div>
              <ChevronRight className="w-5 h-5 text-white/40 group-hover:text-white/60 transition-colors" />
            </button>

            <button
              onClick={() => router.push('/saved')}
              className="w-full flex items-center justify-between p-4 bg-white/5 rounded-xl hover:bg-white/10 transition-colors group"
            >
              <div className="flex items-center gap-3">
                <Heart className="w-5 h-5 text-pink-400" />
                <span className="text-white font-medium">Saved Properties</span>
              </div>
              <ChevronRight className="w-5 h-5 text-white/40 group-hover:text-white/60 transition-colors" />
            </button>

            <button
              onClick={() => router.push('/vault')}
              className="w-full flex items-center justify-between p-4 bg-white/5 rounded-xl hover:bg-white/10 transition-colors group"
            >
              <div className="flex items-center gap-3">
                <Shield className="w-5 h-5 text-cyan-400" />
                <span className="text-white font-medium">Document Vault</span>
              </div>
              <ChevronRight className="w-5 h-5 text-white/40 group-hover:text-white/60 transition-colors" />
            </button>
          </div>
        </motion.div>

        {/* Sign Out */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
        >
          <button
            onClick={handleSignOut}
            className="w-full px-6 py-4 bg-red-500/10 border border-red-500/30 text-red-300 rounded-xl font-semibold hover:bg-red-500/20 transition-colors flex items-center justify-center gap-2"
          >
            <LogOut className="w-5 h-5" />
            Sign Out
          </button>
        </motion.div>

        {/* Footer */}
        <div className="text-center text-white/30 text-sm pt-4 space-y-1">
          <p className={`${merriweather.className} font-light`}>HOMEY</p>
          <p>Beta</p>
        </div>
      </div>

      <BottomNavigation />
    </div>
  );
}
