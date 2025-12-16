'use client';

export const dynamic = 'force-dynamic';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { auth } from '@/lib/supabase';
import { getUserPreferences, updateUserPreferences, getLocationDisplayName } from '@/lib/preferences';
import { analytics } from '@/lib/analytics';
import CinematicBackground from '@/components/CinematicBackground';
import BottomNav from '@/components/BottomNav';

const CITIES = [
  { id: 'new_york_city', name: 'New York City', icon: '🗽' },
  { id: 'chicago', name: 'Chicago', icon: '🌆' },
  { id: 'los_angeles', name: 'Los Angeles', icon: '🌴' },
  { id: 'miami', name: 'Miami', icon: '🏖️' },
];

const NEIGHBORHOOD_OPTIONS: Record<string, string[]> = {
  new_york_city: [
    'Upper West Side',
    'Upper East Side',
    'Chelsea',
    'Greenwich Village',
    'SoHo',
    'Tribeca',
    'Williamsburg',
    'DUMBO',
    'Park Slope',
    'Astoria',
    'Long Island City',
    'Harlem',
  ],
  chicago: [
    'Lincoln Park',
    'Wicker Park',
    'River North',
    'Loop',
    'West Loop',
    'Logan Square',
    'Lakeview',
    'Gold Coast',
  ],
  los_angeles: [
    'Santa Monica',
    'Venice',
    'Downtown LA',
    'West Hollywood',
    'Silver Lake',
    'Echo Park',
    'Culver City',
    'Pasadena',
  ],
  miami: [
    'South Beach',
    'Brickell',
    'Wynwood',
    'Coconut Grove',
    'Coral Gables',
    'Design District',
    'Downtown Miami',
    'Edgewater',
  ],
};

export default function PreferencesEditPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [saveSuccess, setSaveSuccess] = useState(false);
  const [saveError, setSaveError] = useState('');

  // Form state
  const [location, setLocation] = useState<string>('');
  const [userType, setUserType] = useState<string>('');
  const [budgetMin, setBudgetMin] = useState<string>('');
  const [budgetMax, setBudgetMax] = useState<string>('');
  const [bedrooms, setBedrooms] = useState<string>('');
  const [bathrooms, setBathrooms] = useState<string>('');
  const [neighborhoods, setNeighborhoods] = useState<string[]>([]);

  useEffect(() => {
    loadPreferences();
    analytics.pageView('settings_preferences_edit');
  }, []);

  const loadPreferences = async () => {
    try {
      const { data: { user } } = await auth.getUser();
      if (!user) {
        router.push('/');
        return;
      }

      const prefs = await getUserPreferences(user.id);
      if (prefs) {
        setLocation(prefs.location || '');
        setUserType(prefs.userType || '');
        setBudgetMin(prefs.budgetMin?.toString() || '');
        setBudgetMax(prefs.budgetMax?.toString() || '');
        setBedrooms(prefs.bedrooms?.toString() || '');
        setBathrooms(prefs.bathrooms?.toString() || '');
        setNeighborhoods(prefs.neighborhoods || []);
      }

      setLoading(false);
    } catch (err) {
      console.error('Failed to load preferences:', err);
      setLoading(false);
    }
  };

  const handleSave = async () => {
    setSaving(true);
    setSaveSuccess(false);
    setSaveError('');

    try {
      const updates: any = {};

      if (location) updates.location = location;
      if (userType) updates.userType = userType;
      if (budgetMin) updates.budgetMin = parseInt(budgetMin);
      if (budgetMax) updates.budgetMax = parseInt(budgetMax);
      if (bedrooms) updates.bedrooms = parseInt(bedrooms);
      if (bathrooms) updates.bathrooms = parseInt(bathrooms);
      if (neighborhoods.length > 0) updates.neighborhoods = neighborhoods;

      const { success, error } = await updateUserPreferences(updates);

      if (success) {
        setSaveSuccess(true);
        analytics.updateProfile(updates);
        setTimeout(() => {
          router.push('/settings');
        }, 1500);
      } else {
        setSaveError(error || 'Failed to save preferences');
      }
    } catch (err: any) {
      setSaveError(err.message || 'Failed to save preferences');
    } finally {
      setSaving(false);
    }
  };

  const toggleNeighborhood = (neighborhood: string) => {
    if (neighborhoods.includes(neighborhood)) {
      setNeighborhoods(neighborhoods.filter((n) => n !== neighborhood));
    } else {
      setNeighborhoods([...neighborhoods, neighborhood]);
    }
  };

  const availableNeighborhoods = location ? NEIGHBORHOOD_OPTIONS[location] || [] : [];

  if (loading) {
    return (
      <main className="relative min-h-screen flex items-center justify-center">
        <CinematicBackground timeOfDay="day" />
        <div className="animate-spin rounded-full h-12 w-12 border-4 border-white/20 border-t-primary"></div>
      </main>
    );
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
          <h1 className="text-xl font-bold text-white">Edit Preferences</h1>
          <div className="w-10" />
        </div>
      </header>

      {/* Content */}
      <div className="relative z-10 pt-24 px-5 max-w-4xl mx-auto pb-8">
        {/* Success/Error Messages */}
        {saveSuccess && (
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            className="mb-6 p-4 bg-green-500/20 border border-green-500/50 rounded-2xl text-green-300 text-center"
          >
            ✓ Preferences saved successfully!
          </motion.div>
        )}

        {saveError && (
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            className="mb-6 p-4 bg-red-500/20 border border-red-500/50 rounded-2xl text-red-300 text-center"
          >
            {saveError}
          </motion.div>
        )}

        {/* Location */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="glass-strong rounded-3xl p-6 mb-6"
        >
          <h3 className="text-xl font-bold text-white mb-4">Location</h3>
          <div className="grid grid-cols-2 gap-3">
            {CITIES.map((city) => (
              <button
                key={city.id}
                onClick={() => {
                  setLocation(city.id);
                  setNeighborhoods([]); // Reset neighborhoods when city changes
                }}
                className={`p-4 rounded-2xl transition-all ${
                  location === city.id
                    ? 'bg-primary text-white shadow-lg shadow-primary/30'
                    : 'bg-white/5 text-white/70 hover:bg-white/10'
                }`}
              >
                <div className="text-3xl mb-2">{city.icon}</div>
                <div className="font-semibold text-sm">{city.name}</div>
              </button>
            ))}
          </div>
        </motion.div>

        {/* User Type */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="glass-strong rounded-3xl p-6 mb-6"
        >
          <h3 className="text-xl font-bold text-white mb-4">I'm looking to...</h3>
          <div className="grid grid-cols-3 gap-3">
            {['renter', 'buyer', 'browser'].map((type) => (
              <button
                key={type}
                onClick={() => setUserType(type)}
                className={`p-4 rounded-2xl transition-all capitalize ${
                  userType === type
                    ? 'bg-primary text-white shadow-lg shadow-primary/30'
                    : 'bg-white/5 text-white/70 hover:bg-white/10'
                }`}
              >
                {type}
              </button>
            ))}
          </div>
        </motion.div>

        {/* Budget */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="glass-strong rounded-3xl p-6 mb-6"
        >
          <h3 className="text-xl font-bold text-white mb-4">Budget</h3>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-white/70 text-sm mb-2">Minimum</label>
              <div className="relative">
                <span className="absolute left-4 top-1/2 -translate-y-1/2 text-white/50">$</span>
                <input
                  type="number"
                  value={budgetMin}
                  onChange={(e) => setBudgetMin(e.target.value)}
                  placeholder="0"
                  className="w-full pl-8 pr-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/40 focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>
            </div>
            <div>
              <label className="block text-white/70 text-sm mb-2">Maximum</label>
              <div className="relative">
                <span className="absolute left-4 top-1/2 -translate-y-1/2 text-white/50">$</span>
                <input
                  type="number"
                  value={budgetMax}
                  onChange={(e) => setBudgetMax(e.target.value)}
                  placeholder="10000"
                  className="w-full pl-8 pr-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-white/40 focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>
            </div>
          </div>
        </motion.div>

        {/* Bedrooms & Bathrooms */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="glass-strong rounded-3xl p-6 mb-6"
        >
          <h3 className="text-xl font-bold text-white mb-4">Space Requirements</h3>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-white/70 text-sm mb-2">Bedrooms (min)</label>
              <select
                value={bedrooms}
                onChange={(e) => setBedrooms(e.target.value)}
                className="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white focus:outline-none focus:ring-2 focus:ring-primary"
              >
                <option value="">Any</option>
                <option value="0">Studio</option>
                <option value="1">1+</option>
                <option value="2">2+</option>
                <option value="3">3+</option>
                <option value="4">4+</option>
              </select>
            </div>
            <div>
              <label className="block text-white/70 text-sm mb-2">Bathrooms (min)</label>
              <select
                value={bathrooms}
                onChange={(e) => setBathrooms(e.target.value)}
                className="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white focus:outline-none focus:ring-2 focus:ring-primary"
              >
                <option value="">Any</option>
                <option value="1">1+</option>
                <option value="1.5">1.5+</option>
                <option value="2">2+</option>
                <option value="2.5">2.5+</option>
                <option value="3">3+</option>
              </select>
            </div>
          </div>
        </motion.div>

        {/* Neighborhoods */}
        {location && availableNeighborhoods.length > 0 && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            className="glass-strong rounded-3xl p-6 mb-6"
          >
            <h3 className="text-xl font-bold text-white mb-2">Neighborhoods</h3>
            <p className="text-white/60 text-sm mb-4">
              Select neighborhoods in {getLocationDisplayName(location)}
            </p>
            <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
              {availableNeighborhoods.map((neighborhood) => (
                <button
                  key={neighborhood}
                  onClick={() => toggleNeighborhood(neighborhood)}
                  className={`p-3 rounded-xl text-sm transition-all ${
                    neighborhoods.includes(neighborhood)
                      ? 'bg-primary text-white shadow-lg shadow-primary/20'
                      : 'bg-white/5 text-white/70 hover:bg-white/10'
                  }`}
                >
                  {neighborhood}
                </button>
              ))}
            </div>
            {neighborhoods.length > 0 && (
              <div className="mt-4 text-white/60 text-sm">
                {neighborhoods.length} neighborhood{neighborhoods.length > 1 ? 's' : ''} selected
              </div>
            )}
          </motion.div>
        )}

        {/* Save Button */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
          className="flex gap-4"
        >
          <button
            onClick={() => router.back()}
            disabled={saving}
            className="flex-1 px-6 py-4 bg-white/10 border border-white/20 text-white rounded-2xl font-bold hover:bg-white/20 transition-colors disabled:opacity-50"
          >
            Cancel
          </button>
          <button
            onClick={handleSave}
            disabled={saving || saveSuccess}
            className="flex-1 px-6 py-4 bg-primary text-white rounded-2xl font-bold hover:bg-primary/90 transition-colors shadow-lg shadow-primary/30 disabled:opacity-50"
          >
            {saving ? 'Saving...' : saveSuccess ? 'Saved!' : 'Save Changes'}
          </button>
        </motion.div>
      </div>

      {/* Bottom Navigation */}
      <BottomNav />
    </main>
  );
}
