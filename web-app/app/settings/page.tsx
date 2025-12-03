'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { db, auth } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';
import { getUserPreferences, getLocationDisplayName, type UserPreferences } from '@/lib/preferences';
import { clearAllSecureData } from '@/lib/secureStorage';
import CinematicBackground from '@/components/CinematicBackground';
import BottomNav from '@/components/BottomNav';
import LocationManager from '@/components/LocationManager';
import { useClientAgent } from '@/hooks/useClientAgent';
import { Phone, Mail, MessageCircle, Shield, Check, Users, Building } from 'lucide-react';

interface UserProfile {
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
  coursesStarted: number;
}

export default function SettingsPage() {
  const router = useRouter();
  const { agent: agentConnection, hasAgent } = useClientAgent();
  const [user, setUser] = useState<UserProfile | null>(null);
  const [stats, setStats] = useState<UserStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [preferences, setPreferences] = useState<UserPreferences | null>(null);

  // Edit mode
  const [isEditingProfile, setIsEditingProfile] = useState(false);
  const [fullName, setFullName] = useState('');
  const [isSaving, setIsSaving] = useState(false);

  // Get agent initials
  const getAgentInitials = (name?: string) => {
    if (!name) return 'AG';
    const parts = name.split(' ');
    if (parts.length >= 2) {
      return `${parts[0][0]}${parts[parts.length - 1][0]}`.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  };

  useEffect(() => {
    loadUserData();
    analytics.pageView('settings');
  }, []);

  const loadUserData = async () => {
    try {
      const { data: { user: authUser } } = await auth.getUser();

      if (!authUser) {
        router.push('/');
        return;
      }

      setUser({
        id: authUser.id,
        email: authUser.email || '',
        full_name: authUser.user_metadata?.full_name,
        avatar_url: authUser.user_metadata?.avatar_url,
        created_at: authUser.created_at,
      });

      setFullName(authUser.user_metadata?.full_name || '');

      // Load profile preferences using centralized utility
      const prefs = await getUserPreferences(authUser.id);
      if (prefs) {
        setPreferences(prefs);
      }

      // Load user statistics
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
        coursesStarted: 0, // TODO: Add course tracking
      });
    } catch (err) {
      console.error('Failed to load stats:', err);
    }
  };

  const handleSaveProfile = async () => {
    if (!user) return;

    setIsSaving(true);
    try {
      // Update profile in Supabase
      await db.updateProfile(user.id, {
        full_name: fullName,
      });

      setUser({
        ...user,
        full_name: fullName,
      });

      setIsEditingProfile(false);
      analytics.updateProfile({ full_name: fullName });
    } catch (err) {
      console.error('Failed to update profile:', err);
    } finally {
      setIsSaving(false);
    }
  };

  const handleSignOut = async () => {
    const confirmed = window.confirm('Are you sure you want to sign out?');
    if (!confirmed) return;

    // Clear all cached data (profiles, recommendations, etc.)
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

  const formatDate = (dateString?: string) => {
    if (!dateString) return 'Unknown';
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  };

  if (loading) {
    return (
      <main className="relative min-h-screen flex items-center justify-center">
        <CinematicBackground timeOfDay="day" />
        <div className="animate-spin rounded-full h-12 w-12 border-4 border-white/20 border-t-primary"></div>
      </main>
    );
  }

  if (!user) {
    return null;
  }

  return (
    <main className="relative min-h-screen pb-24">
      <CinematicBackground timeOfDay="day" />

      {/* Header */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-gradient-to-b from-black/80 via-black/60 to-transparent backdrop-blur-md">
        <div className="flex items-center justify-between px-5 py-4">
          <button
            onClick={() => router.back()}
            className="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center text-xl hover:bg-white/20 transition-colors text-white"
          >
            ←
          </button>
          <h1 className="text-xl font-bold text-white">Settings & Profile</h1>
          <div className="w-10" />
        </div>
      </header>

      {/* Content */}
      <div className="relative z-10 pt-24 px-5 max-w-4xl mx-auto pb-8">
        {/* Profile Card */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="glass-strong rounded-3xl p-8 mb-6"
        >
          <div className="flex items-start gap-6 mb-6">
            {/* Avatar */}
            <div className="relative">
              {user.avatar_url ? (
                <img
                  src={user.avatar_url}
                  alt={user.full_name || 'User'}
                  className="w-24 h-24 rounded-full object-cover border-4 border-primary/30"
                />
              ) : (
                <div className="w-24 h-24 rounded-full bg-gradient-to-br from-primary to-purple-600 flex items-center justify-center text-white text-3xl font-bold border-4 border-primary/30">
                  {getInitials(user.full_name)}
                </div>
              )}
              <button className="absolute bottom-0 right-0 w-8 h-8 rounded-full bg-primary flex items-center justify-center text-white shadow-lg hover:scale-110 transition-transform">
                ✏️
              </button>
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
                    className="w-full px-4 py-2 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/40 focus:outline-none focus:ring-2 focus:ring-primary"
                  />
                  <div className="flex gap-2">
                    <button
                      onClick={handleSaveProfile}
                      disabled={isSaving}
                      className="px-4 py-2 bg-primary text-white rounded-xl font-semibold hover:bg-primary/90 transition-colors disabled:opacity-50"
                    >
                      {isSaving ? 'Saving...' : 'Save'}
                    </button>
                    <button
                      onClick={() => {
                        setIsEditingProfile(false);
                        setFullName(user.full_name || '');
                      }}
                      className="px-4 py-2 bg-white/10 text-white rounded-xl font-semibold hover:bg-white/20 transition-colors"
                    >
                      Cancel
                    </button>
                  </div>
                </div>
              ) : (
                <>
                  <div className="flex items-center gap-3 mb-2">
                    <h2 className="text-2xl font-bold text-white">
                      {user.full_name || 'Anonymous User'}
                    </h2>
                    <button
                      onClick={() => setIsEditingProfile(true)}
                      className="text-primary hover:text-purple-400 transition-colors"
                    >
                      ✏️
                    </button>
                  </div>
                  <p className="text-white/70 mb-1">{user.email}</p>
                  <p className="text-white/50 text-sm">
                    Member since {formatDate(user.created_at)}
                  </p>
                </>
              )}
            </div>
          </div>

          {/* Stats Grid */}
          {stats && (
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 pt-6 border-t border-white/10">
              <div className="text-center">
                <div className="text-3xl font-bold text-white mb-1">
                  {stats.totalSwipes}
                </div>
                <div className="text-white/60 text-sm">Property Swipes</div>
              </div>
              <div className="text-center">
                <div className="text-3xl font-bold text-white mb-1">
                  {stats.totalLikes}
                </div>
                <div className="text-white/60 text-sm">Liked</div>
              </div>
              <div className="text-center">
                <div className="text-3xl font-bold text-white mb-1">
                  {stats.savedProperties}
                </div>
                <div className="text-white/60 text-sm">Saved</div>
              </div>
              <div className="text-center">
                <div className="text-3xl font-bold text-white mb-1">
                  {stats.designSwipes}
                </div>
                <div className="text-white/60 text-sm">Design Swipes</div>
              </div>
            </div>
          )}
        </motion.div>

        {/* Preferences */}
        {preferences && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="glass-strong rounded-3xl p-6 mb-6"
          >
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-xl font-bold text-white">Your Preferences</h3>
              <button
                onClick={() => router.push('/settings/preferences')}
                className="text-primary hover:text-purple-400 text-sm font-semibold"
              >
                Edit →
              </button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {preferences.location && (
                <div className="bg-white/5 rounded-xl p-4">
                  <div className="text-white/60 text-sm mb-1">Location</div>
                  <div className="text-white font-semibold">
                    {getLocationDisplayName(preferences.location)}
                  </div>
                </div>
              )}

              {preferences.userType && (
                <div className="bg-white/5 rounded-xl p-4">
                  <div className="text-white/60 text-sm mb-1">User Type</div>
                  <div className="text-white font-semibold capitalize">
                    {preferences.userType}
                  </div>
                </div>
              )}

              {(preferences.budgetMin || preferences.budgetMax) && (
                <div className="bg-white/5 rounded-xl p-4">
                  <div className="text-white/60 text-sm mb-1">Budget</div>
                  <div className="text-white font-semibold">
                    {preferences.budgetMin && preferences.budgetMax
                      ? `$${preferences.budgetMin.toLocaleString()} - $${preferences.budgetMax.toLocaleString()}`
                      : preferences.budgetMax
                      ? `Up to $${preferences.budgetMax.toLocaleString()}`
                      : `From $${preferences.budgetMin?.toLocaleString()}`}
                  </div>
                </div>
              )}

              {preferences.bedrooms && (
                <div className="bg-white/5 rounded-xl p-4">
                  <div className="text-white/60 text-sm mb-1">Bedrooms</div>
                  <div className="text-white font-semibold">
                    {preferences.bedrooms}+ bedroom{preferences.bedrooms > 1 ? 's' : ''}
                  </div>
                </div>
              )}

              {preferences.bathrooms && (
                <div className="bg-white/5 rounded-xl p-4">
                  <div className="text-white/60 text-sm mb-1">Bathrooms</div>
                  <div className="text-white font-semibold">
                    {preferences.bathrooms}+ bathroom{preferences.bathrooms > 1 ? 's' : ''}
                  </div>
                </div>
              )}

              {preferences.neighborhoods && preferences.neighborhoods.length > 0 && (
                <div className="bg-white/5 rounded-xl p-4">
                  <div className="text-white/60 text-sm mb-1">Neighborhoods</div>
                  <div className="text-white font-semibold">
                    {preferences.neighborhoods.join(', ')}
                  </div>
                </div>
              )}

              {preferences.hasAgent && (
                <div className="bg-white/5 rounded-xl p-4">
                  <div className="text-white/60 text-sm mb-1">Real Estate Agent</div>
                  <div className="text-white font-semibold">
                    {preferences.agentName || 'Yes'}
                  </div>
                  {preferences.agentContact && (
                    <div className="text-white/70 text-sm mt-1">
                      {preferences.agentContact}
                    </div>
                  )}
                </div>
              )}
            </div>
          </motion.div>
        )}

        {/* My Agent Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.15 }}
          className="glass-strong rounded-3xl p-6 mb-6"
        >
          <div className="flex items-center gap-2 mb-4">
            <Users className="w-5 h-5 text-purple-400" />
            <h3 className="text-xl font-bold text-white">My Agent</h3>
          </div>

          {hasAgent && agentConnection ? (
            <div className="space-y-4">
              {/* Agent Profile */}
              <div className="flex items-start gap-4 p-4 bg-white/5 rounded-xl">
                {/* Avatar */}
                <div className="relative">
                  {agentConnection.agent?.user?.avatar_url ? (
                    <img
                      src={agentConnection.agent.user.avatar_url}
                      alt={agentConnection.agent?.user?.full_name || 'Agent'}
                      className="w-16 h-16 rounded-full object-cover border-2 border-purple-400/30"
                    />
                  ) : (
                    <div className="w-16 h-16 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-white text-lg font-bold border-2 border-purple-400/30">
                      {getAgentInitials(agentConnection.agent?.user?.full_name)}
                    </div>
                  )}
                  {agentConnection.agent?.verified && (
                    <div className="absolute -bottom-1 -right-1 w-5 h-5 bg-blue-500 rounded-full border-2 border-slate-900 flex items-center justify-center">
                      <Check className="w-3 h-3 text-white" />
                    </div>
                  )}
                </div>

                {/* Agent Info */}
                <div className="flex-1">
                  <h4 className="text-white font-bold text-lg mb-1">
                    {agentConnection.agent?.user?.full_name || 'Your Agent'}
                  </h4>
                  {agentConnection.agent?.brokerage_name && (
                    <div className="flex items-center gap-2 text-white/70 text-sm mb-2">
                      <Building className="w-4 h-4" />
                      {agentConnection.agent.brokerage_name}
                    </div>
                  )}
                  {agentConnection.agent?.license_number && (
                    <p className="text-white/50 text-sm">
                      License: {agentConnection.agent.license_number}
                      {agentConnection.agent.license_state && ` (${agentConnection.agent.license_state})`}
                    </p>
                  )}
                </div>
              </div>

              {/* Contact Info */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                {agentConnection.agent?.professional_phone && (
                  <a
                    href={`tel:${agentConnection.agent.professional_phone}`}
                    className="flex items-center gap-3 p-3 bg-white/5 hover:bg-white/10 rounded-xl transition-colors"
                  >
                    <Phone className="w-4 h-4 text-purple-400" />
                    <span className="text-white/90 text-sm">Call</span>
                  </a>
                )}
                {agentConnection.agent?.professional_email && (
                  <a
                    href={`mailto:${agentConnection.agent.professional_email}`}
                    className="flex items-center gap-3 p-3 bg-white/5 hover:bg-white/10 rounded-xl transition-colors"
                  >
                    <Mail className="w-4 h-4 text-purple-400" />
                    <span className="text-white/90 text-sm">Email</span>
                  </a>
                )}
                <button
                  onClick={() => router.push('/home')}
                  className="flex items-center gap-3 p-3 bg-white/5 hover:bg-white/10 rounded-xl transition-colors"
                >
                  <MessageCircle className="w-4 h-4 text-purple-400" />
                  <span className="text-white/90 text-sm">Message</span>
                </button>
              </div>

              {/* Connection Status */}
              <div className="p-3 bg-green-500/10 border border-green-500/30 rounded-xl">
                <div className="flex items-center gap-2 text-green-300 text-sm">
                  <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
                  Connected since {new Date(agentConnection.created_at || '').toLocaleDateString()}
                </div>
              </div>
            </div>
          ) : (
            <div className="text-center p-8">
              <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-gradient-to-br from-purple-500/20 to-pink-500/20 flex items-center justify-center">
                <Users className="w-8 h-8 text-purple-400" />
              </div>
              <h4 className="text-white font-semibold mb-2">No Agent Connected</h4>
              <p className="text-white/60 text-sm mb-4">
                Connect with a real estate agent to get personalized help
              </p>
              <button
                onClick={() => router.push('/directory')}
                className="px-6 py-3 bg-gradient-to-r from-purple-500 to-pink-500 hover:opacity-90 text-white font-semibold rounded-xl transition-opacity"
              >
                Find an Agent
              </button>
            </div>
          )}
        </motion.div>

        {/* Data Access & Permissions Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="glass-strong rounded-3xl p-6 mb-6"
        >
          <div className="flex items-center gap-2 mb-4">
            <Shield className="w-5 h-5 text-purple-400" />
            <h3 className="text-xl font-bold text-white">Data Access & Permissions</h3>
          </div>

          <p className="text-white/70 text-sm mb-4">
            Control who can access your information and what they can see
          </p>

          <div className="space-y-3">
            {/* Agent Access */}
            {hasAgent && agentConnection && (
              <div className="p-4 bg-white/5 rounded-xl border border-white/10">
                <div className="flex items-start gap-3">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-white text-sm font-bold flex-shrink-0">
                    {getAgentInitials(agentConnection.agent?.user?.full_name)}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center justify-between mb-2">
                      <h4 className="text-white font-semibold">
                        {agentConnection.agent?.user?.full_name || 'Your Agent'}
                      </h4>
                      <span className="text-xs text-green-400 flex items-center gap-1">
                        <Check className="w-3 h-3" />
                        Connected
                      </span>
                    </div>
                    <div className="space-y-1">
                      <p className="text-white/60 text-sm flex items-center gap-2">
                        <Check className="w-3 h-3 text-purple-400" />
                        View your property preferences
                      </p>
                      <p className="text-white/60 text-sm flex items-center gap-2">
                        <Check className="w-3 h-3 text-purple-400" />
                        See your liked properties
                      </p>
                      <p className="text-white/60 text-sm flex items-center gap-2">
                        <Check className="w-3 h-3 text-purple-400" />
                        Access your search history
                      </p>
                      <p className="text-white/60 text-sm flex items-center gap-2">
                        <Check className="w-3 h-3 text-purple-400" />
                        View your budget and requirements
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* HOMEY Platform Access */}
            <div className="p-4 bg-white/5 rounded-xl border border-white/10">
              <div className="flex items-start gap-3">
                <div className="w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-white text-xl flex-shrink-0">
                  🏡
                </div>
                <div className="flex-1">
                  <div className="flex items-center justify-between mb-2">
                    <h4 className="text-white font-semibold">HOMEY Platform</h4>
                    <span className="text-xs text-green-400 flex items-center gap-1">
                      <Check className="w-3 h-3" />
                      Active
                    </span>
                  </div>
                  <div className="space-y-1">
                    <p className="text-white/60 text-sm flex items-center gap-2">
                      <Check className="w-3 h-3 text-purple-400" />
                      Personalized property recommendations
                    </p>
                    <p className="text-white/60 text-sm flex items-center gap-2">
                      <Check className="w-3 h-3 text-purple-400" />
                      Learning your style preferences
                    </p>
                    <p className="text-white/60 text-sm flex items-center gap-2">
                      <Check className="w-3 h-3 text-purple-400" />
                      Analytics to improve your experience
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </motion.div>

        {/* Location Manager */}
        {user && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.25 }}
            className="glass-strong rounded-3xl p-6 mb-6"
          >
            <LocationManager userId={user.id} />
          </motion.div>
        )}

        {/* Quick Actions */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="glass-strong rounded-3xl p-6 mb-6"
        >
          <h3 className="text-xl font-bold text-white mb-4">Quick Actions</h3>
          <div className="space-y-3">
            <button
              onClick={() => router.push('/settings/preferences')}
              className="w-full flex items-center justify-between p-4 bg-white/5 rounded-xl hover:bg-white/10 transition-colors"
            >
              <div className="flex items-center gap-3">
                <span className="text-2xl">⚙️</span>
                <span className="text-white font-semibold">Edit Preferences</span>
              </div>
              <span className="text-white/40">→</span>
            </button>

            <button
              onClick={() => router.push('/saved')}
              className="w-full flex items-center justify-between p-4 bg-white/5 rounded-xl hover:bg-white/10 transition-colors"
            >
              <div className="flex items-center gap-3">
                <span className="text-2xl">❤️</span>
                <span className="text-white font-semibold">Saved Properties</span>
              </div>
              <span className="text-white/40">→</span>
            </button>

            <button
              onClick={() => router.push('/learn')}
              className="w-full flex items-center justify-between p-4 bg-white/5 rounded-xl hover:bg-white/10 transition-colors"
            >
              <div className="flex items-center gap-3">
                <span className="text-2xl">🎓</span>
                <span className="text-white font-semibold">Learning Progress</span>
              </div>
              <span className="text-white/40">→</span>
            </button>
          </div>
        </motion.div>

        {/* Account Settings */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="glass-strong rounded-3xl p-6 mb-6"
        >
          <h3 className="text-xl font-bold text-white mb-4">Account</h3>
          <div className="space-y-3">
            <button className="w-full flex items-center justify-between p-4 bg-white/5 rounded-xl hover:bg-white/10 transition-colors">
              <div className="flex items-center gap-3">
                <span className="text-2xl">🔔</span>
                <span className="text-white font-semibold">Notifications</span>
              </div>
              <span className="text-white/40">→</span>
            </button>

            <button className="w-full flex items-center justify-between p-4 bg-white/5 rounded-xl hover:bg-white/10 transition-colors">
              <div className="flex items-center gap-3">
                <span className="text-2xl">🔒</span>
                <span className="text-white font-semibold">Privacy & Security</span>
              </div>
              <span className="text-white/40">→</span>
            </button>

            <button className="w-full flex items-center justify-between p-4 bg-white/5 rounded-xl hover:bg-white/10 transition-colors">
              <div className="flex items-center gap-3">
                <span className="text-2xl">❓</span>
                <span className="text-white font-semibold">Help & Support</span>
              </div>
              <span className="text-white/40">→</span>
            </button>
          </div>
        </motion.div>

        {/* Sign Out */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
        >
          <button
            onClick={handleSignOut}
            className="w-full px-6 py-4 bg-red-500/20 border border-red-500/50 text-red-300 rounded-2xl font-bold hover:bg-red-500/30 transition-colors"
          >
            Sign Out
          </button>
        </motion.div>

        {/* App Info */}
        <div className="text-center text-white/40 text-sm mt-8 space-y-1">
          <p>HOMEY v1.0.0</p>
          <p>Made with ❤️ for home seekers</p>
        </div>
      </div>

      {/* Bottom Navigation */}
      <BottomNav />
    </main>
  );
}
