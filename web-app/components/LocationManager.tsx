'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Plus, X, MapPin, Trash2, Edit2, Save, Navigation } from 'lucide-react';
import type { SavedLocation } from '@/lib/types';

interface LocationManagerProps {
  userId: string;
  onLocationsChange?: (locations: SavedLocation[]) => void;
}

const LOCATION_TYPES = [
  { value: 'work', label: 'Work', icon: '💼' },
  { value: 'gym', label: 'Gym', icon: '💪' },
  { value: 'favorite', label: 'Favorite Spot', icon: '⭐' },
  { value: 'school', label: 'School', icon: '🎓' },
  { value: 'custom', label: 'Custom', icon: '📍' },
] as const;

export default function LocationManager({ userId, onLocationsChange }: LocationManagerProps) {
  const [locations, setLocations] = useState<SavedLocation[]>([]);
  const [isAdding, setIsAdding] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  // Form state
  const [formData, setFormData] = useState({
    name: '',
    type: 'work' as SavedLocation['type'],
    address: '',
  });

  useEffect(() => {
    loadLocations();
  }, [userId]);

  const loadLocations = async () => {
    try {
      setLoading(true);
      const response = await fetch(`/api/user/locations?userId=${userId}`);
      if (response.ok) {
        const data = await response.json();
        setLocations(data.locations || []);
      }
    } catch (error) {
      console.error('Failed to load locations:', error);
    } finally {
      setLoading(false);
    }
  };

  const geocodeAddress = async (address: string) => {
    try {
      const response = await fetch(`/api/geocode?address=${encodeURIComponent(address)}`);
      if (!response.ok) throw new Error('Geocoding failed');
      const data = await response.json();
      return {
        latitude: data.latitude,
        longitude: data.longitude,
      };
    } catch (error) {
      console.error('Geocoding error:', error);
      throw error;
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.name || !formData.address) return;

    try {
      setLoading(true);

      // Geocode the address
      const coords = await geocodeAddress(formData.address);

      const newLocation: Omit<SavedLocation, 'id'> = {
        name: formData.name,
        type: formData.type,
        address: formData.address,
        latitude: coords.latitude,
        longitude: coords.longitude,
        icon: LOCATION_TYPES.find(t => t.value === formData.type)?.icon,
      };

      // Save to database
      const response = await fetch('/api/user/locations', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId, location: newLocation }),
      });

      if (!response.ok) throw new Error('Failed to save location');

      const data = await response.json();
      const savedLocation = data.location;

      setLocations(prev => [...prev, savedLocation]);
      if (onLocationsChange) {
        onLocationsChange([...locations, savedLocation]);
      }

      // Reset form
      setFormData({ name: '', type: 'work', address: '' });
      setIsAdding(false);
    } catch (error) {
      console.error('Failed to add location:', error);
      alert('Failed to add location. Please check the address and try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (locationId: string) => {
    if (!confirm('Remove this location?')) return;

    try {
      const response = await fetch(`/api/user/locations?userId=${userId}&locationId=${locationId}`, {
        method: 'DELETE',
      });

      if (!response.ok) throw new Error('Failed to delete location');

      const updatedLocations = locations.filter(loc => loc.id !== locationId);
      setLocations(updatedLocations);
      if (onLocationsChange) {
        onLocationsChange(updatedLocations);
      }
    } catch (error) {
      console.error('Failed to delete location:', error);
      alert('Failed to remove location. Please try again.');
    }
  };

  const getLocationIcon = (type: string) => {
    return LOCATION_TYPES.find(t => t.value === type)?.icon || '📍';
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-white font-bold text-lg flex items-center gap-2">
            <MapPin className="w-5 h-5 text-purple-400" />
            My Locations
          </h3>
          <p className="text-white/60 text-sm mt-1">
            Add your frequent locations to see personalized commute times
          </p>
        </div>
        <button
          onClick={() => setIsAdding(!isAdding)}
          className="px-4 py-2 bg-gradient-to-r from-purple-500 to-pink-500 hover:opacity-90 text-white rounded-xl font-medium flex items-center gap-2 transition-opacity"
        >
          <Plus className="w-4 h-4" />
          Add Location
        </button>
      </div>

      {/* Add Location Form */}
      <AnimatePresence>
        {isAdding && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            className="overflow-hidden"
          >
            <form onSubmit={handleSubmit} className="glass-strong rounded-2xl p-6 space-y-4 border border-white/10">
              <div>
                <label className="block text-white/80 text-sm font-medium mb-2">
                  Location Type
                </label>
                <div className="grid grid-cols-5 gap-2">
                  {LOCATION_TYPES.map(type => (
                    <button
                      key={type.value}
                      type="button"
                      onClick={() => setFormData(prev => ({ ...prev, type: type.value }))}
                      className={`p-3 rounded-xl border transition-all ${
                        formData.type === type.value
                          ? 'bg-purple-500/20 border-purple-500/50 text-white'
                          : 'bg-white/5 border-white/10 text-white/60 hover:bg-white/10'
                      }`}
                    >
                      <div className="text-2xl mb-1">{type.icon}</div>
                      <div className="text-xs font-medium">{type.label}</div>
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <label className="block text-white/80 text-sm font-medium mb-2">
                  Name
                </label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                  placeholder="e.g., Main Office, Equinox Gym"
                  className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:ring-2 focus:ring-purple-500"
                  required
                />
              </div>

              <div>
                <label className="block text-white/80 text-sm font-medium mb-2">
                  Address
                </label>
                <input
                  type="text"
                  value={formData.address}
                  onChange={(e) => setFormData(prev => ({ ...prev, address: e.target.value }))}
                  placeholder="123 Main St, New York, NY 10001"
                  className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:ring-2 focus:ring-purple-500"
                  required
                />
                <p className="text-white/40 text-xs mt-1">
                  Enter full address including city and state
                </p>
              </div>

              <div className="flex gap-3 pt-2">
                <button
                  type="button"
                  onClick={() => {
                    setIsAdding(false);
                    setFormData({ name: '', type: 'work', address: '' });
                  }}
                  className="flex-1 px-4 py-3 bg-white/5 hover:bg-white/10 text-white rounded-xl font-medium transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={loading}
                  className="flex-1 px-4 py-3 bg-gradient-to-r from-purple-500 to-pink-500 hover:opacity-90 text-white rounded-xl font-medium transition-opacity disabled:opacity-50 flex items-center justify-center gap-2"
                >
                  {loading ? (
                    <>
                      <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                      Adding...
                    </>
                  ) : (
                    <>
                      <Save className="w-4 h-4" />
                      Save Location
                    </>
                  )}
                </button>
              </div>
            </form>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Locations List */}
      {loading && locations.length === 0 ? (
        <div className="glass-strong rounded-2xl p-8 text-center border border-white/10">
          <div className="w-12 h-12 border-4 border-white/20 border-t-purple-500 rounded-full animate-spin mx-auto mb-4" />
          <p className="text-white/60">Loading locations...</p>
        </div>
      ) : locations.length === 0 ? (
        <div className="glass-strong rounded-2xl p-8 text-center border border-white/10">
          <div className="text-6xl mb-4">📍</div>
          <h4 className="text-white font-semibold text-lg mb-2">No locations yet</h4>
          <p className="text-white/60 text-sm">
            Add your work, gym, or favorite spots to see personalized commute times on properties
          </p>
        </div>
      ) : (
        <div className="space-y-3">
          {locations.map((location) => (
            <motion.div
              key={location.id}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              className="glass-strong rounded-2xl p-4 border border-white/10 hover:border-purple-500/30 transition-colors"
            >
              <div className="flex items-start justify-between">
                <div className="flex items-start gap-3 flex-1">
                  <div className="text-3xl">{getLocationIcon(location.type)}</div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <h4 className="text-white font-semibold">{location.name}</h4>
                      <span className="px-2 py-0.5 bg-purple-500/20 border border-purple-500/30 rounded-full text-purple-200 text-xs">
                        {LOCATION_TYPES.find(t => t.value === location.type)?.label}
                      </span>
                    </div>
                    <p className="text-white/60 text-sm flex items-center gap-1">
                      <Navigation className="w-3 h-3" />
                      {location.address}
                    </p>
                  </div>
                </div>

                <button
                  onClick={() => handleDelete(location.id)}
                  className="p-2 hover:bg-red-500/20 rounded-lg transition-colors group"
                  title="Remove location"
                >
                  <Trash2 className="w-4 h-4 text-white/40 group-hover:text-red-400" />
                </button>
              </div>
            </motion.div>
          ))}
        </div>
      )}

      {/* Helper Text */}
      {locations.length > 0 && (
        <div className="glass-strong rounded-xl p-4 border border-blue-500/30 bg-blue-500/5">
          <div className="flex gap-3">
            <div className="text-2xl">💡</div>
            <div>
              <p className="text-white/90 text-sm font-medium mb-1">
                Tip: Your locations are now visible on property searches!
              </p>
              <p className="text-white/60 text-xs">
                Visit the search page to see personalized commute times to each property
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
