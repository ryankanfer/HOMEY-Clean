'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { db, auth } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';
import CinematicBackground from '@/components/CinematicBackground';
import BottomNav from '@/components/BottomNav';

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
  const [user, setUser] = useState<UserProfile | null>(null);
  const [stats, setStats] = useState<UserStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [preferences, setPreferences] = useState<any>(null);

  // Edit mode
  const [isEditingProfile, setIsEditingProfile] = useState(false);
  const [fullName, setFullName] = useState('');
  const [isSaving, setIsSaving] = useState(false);

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

      // Load profile preferences
      const { data: profile } = await db.getProfile(authUser.id);
      if (profile?.teach_homey_preferences) {
        setPreferences(profile.teach_homey_preferences);
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
                onClick={() => router.push('/teach')}
                className="text-primary hover:text-purple-400 text-sm font-semibold"
              >
                Update →
              </button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {preferences.maxPrice && (
                <div className="bg-white/5 rounded-xl p-4">
                  <div className="text-white/60 text-sm mb-1">Budget</div>
                  <div className="text-white font-semibold">
                    Up to ${preferences.maxPrice.toLocaleString()}
                  </div>
                </div>
              )}

              {preferences.bedrooms && (
                <div className="bg-white/5 rounded-xl p-4">
                  <div className="text-white/60 text-sm mb-1">Bedrooms</div>
                  <div className="text-white font-semibold">
                    {preferences.bedrooms.join(', ')} bedroom{preferences.bedrooms.length > 1 ? 's' : ''}
                  </div>
                </div>
              )}

              {preferences.propertyTypes && (
                <div className="bg-white/5 rounded-xl p-4">
                  <div className="text-white/60 text-sm mb-1">Property Type</div>
                  <div className="text-white font-semibold">
                    {preferences.propertyTypes.join(', ')}
                  </div>
                </div>
              )}

              {preferences.neighborhoods && (
                <div className="bg-white/5 rounded-xl p-4">
                  <div className="text-white/60 text-sm mb-1">Neighborhoods</div>
                  <div className="text-white font-semibold">
                    {preferences.neighborhoods.join(', ')}
                  </div>
                </div>
              )}
            </div>
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
              onClick={() => router.push('/teach')}
              className="w-full flex items-center justify-between p-4 bg-white/5 rounded-xl hover:bg-white/10 transition-colors"
            >
              <div className="flex items-center gap-3">
                <span className="text-2xl">💬</span>
                <span className="text-white font-semibold">Update Preferences</span>
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
