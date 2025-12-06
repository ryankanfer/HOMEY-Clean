import { supabase } from './supabase';

export interface VibeLog {
  id: string;
  user_id: string;
  neighborhood: string;
  text: string;
  rating: number;
  tags: string[];
  likes: number;
  liked_by: string[];
  is_featured: boolean;
  created_at: string;
  updated_at: string;
  // Joined data
  user?: {
    full_name: string;
    avatar_url?: string;
    is_resident?: boolean;
    is_agent?: boolean;
  };
}

export interface NeighborhoodPulse {
  id: string;
  neighborhood_id: string;
  name: string;
  image_url: string | null;
  vibe_score: number;
  current_mood: string | null;
  mood_emoji: string | null;
  trending_status: 'Up' | 'Down' | 'Stable' | null;
  new_openings: number;
  logs_today: number;
  created_at: string;
  updated_at: string;
}

export interface VibePlaylist {
  id: string;
  name: string;
  emoji: string | null;
  tag_filter: string | null;
  description: string | null;
  is_active: boolean;
  display_order: number;
  created_at: string;
}

export interface NeighborhoodStats {
  neighborhood: string;
  totalLogs: number;
  logsToday: number;
  vibeScore: number; // 0-100 based on average rating
  averageRating: number; // 1-5
  trending: 'Up' | 'Down' | 'Stable';
  moodEmoji: string;
  currentMood: string;
  whatsHappening: string; // Real-time description of the vibe
  recentTags: string[]; // Tags from last 24h
  energy: 'low' | 'medium' | 'high'; // Activity level
}

export interface QuickVibe {
  id: string;
  user_id: string;
  neighborhood: string;
  text: string;
  latitude: number | null;
  longitude: number | null;
  created_at: string;
  expires_at: string;
  // Joined data
  user?: {
    full_name: string;
    avatar_url?: string;
  };
}

export const pulseDb = {
  // Get all vibe logs with user info
  async getVibeLogs(limit = 50, tagFilter?: string) {
    let query = supabase
      .from('vibe_logs')
      .select(`
        *,
        user:user_id (
          full_name,
          avatar_url
        )
      `)
      .order('created_at', { ascending: false })
      .limit(limit);

    if (tagFilter) {
      query = query.contains('tags', [tagFilter]);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data as VibeLog[];
  },

  // Get vibe logs for a specific neighborhood
  async getNeighborhoodLogs(neighborhood: string, limit = 20) {
    const { data, error } = await supabase
      .from('vibe_logs')
      .select(`
        *,
        user:user_id (
          full_name,
          avatar_url
        )
      `)
      .eq('neighborhood', neighborhood)
      .order('created_at', { ascending: false })
      .limit(limit);

    if (error) throw error;
    return data as VibeLog[];
  },

  // Create a new vibe log
  async createVibeLog(log: {
    user_id: string;
    neighborhood: string;
    text: string;
    rating: number;
    tags?: string[];
  }) {
    const { data, error } = await supabase
      .from('vibe_logs')
      .insert([{
        user_id: log.user_id,
        neighborhood: log.neighborhood,
        text: log.text,
        rating: log.rating,
        tags: log.tags || [],
      }])
      .select()
      .single();

    if (error) throw error;
    return data as VibeLog;
  },

  // Toggle like on a vibe log
  async toggleLike(logId: string, userId: string) {
    // First, get the current log
    const { data: log, error: fetchError } = await supabase
      .from('vibe_logs')
      .select('liked_by, likes')
      .eq('id', logId)
      .single();

    if (fetchError) throw fetchError;

    const likedBy = log.liked_by || [];
    const hasLiked = likedBy.includes(userId);

    // Toggle like
    const newLikedBy = hasLiked
      ? likedBy.filter((id: string) => id !== userId)
      : [...likedBy, userId];

    const { data, error } = await supabase
      .from('vibe_logs')
      .update({
        liked_by: newLikedBy,
        likes: newLikedBy.length,
      })
      .eq('id', logId)
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  // Get neighborhood pulse data
  async getNeighborhoodPulse(neighborhoodId?: string) {
    let query = supabase
      .from('neighborhood_pulse')
      .select('*')
      .order('name');

    if (neighborhoodId) {
      query = query.eq('neighborhood_id', neighborhoodId);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data as NeighborhoodPulse[];
  },

  // Get all playlists
  async getPlaylists() {
    const { data, error } = await supabase
      .from('vibe_playlists')
      .select('*')
      .eq('is_active', true)
      .order('display_order');

    if (error) throw error;
    return data as VibePlaylist[];
  },

  // Update neighborhood pulse stats (admin/automated function)
  async updateNeighborhoodStats(neighborhoodId: string, updates: Partial<NeighborhoodPulse>) {
    const { data, error } = await supabase
      .from('neighborhood_pulse')
      .update(updates)
      .eq('neighborhood_id', neighborhoodId)
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  // Get user's own vibe logs
  async getUserVibeLogs(userId: string) {
    const { data, error } = await supabase
      .from('vibe_logs')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data as VibeLog[];
  },

  // Delete a vibe log (user's own)
  async deleteVibeLog(logId: string, userId: string) {
    const { error } = await supabase
      .from('vibe_logs')
      .delete()
      .eq('id', logId)
      .eq('user_id', userId);

    if (error) throw error;
    return true;
  },

  // Get neighborhood statistics (calculated from vibe logs)
  async getNeighborhoodStats(limit = 5): Promise<NeighborhoodStats[]> {
    // Get all vibe logs with tags
    const { data: logs, error } = await supabase
      .from('vibe_logs')
      .select('neighborhood, rating, created_at, tags');

    if (error) throw error;
    if (!logs || logs.length === 0) return [];

    // Group by neighborhood
    const neighborhoodMap = new Map<string, {
      ratings: number[];
      dates: string[];
      tags: string[][];
    }>();

    logs.forEach((log: any) => {
      if (!neighborhoodMap.has(log.neighborhood)) {
        neighborhoodMap.set(log.neighborhood, { ratings: [], dates: [], tags: [] });
      }
      const hood = neighborhoodMap.get(log.neighborhood)!;
      hood.ratings.push(log.rating);
      hood.dates.push(log.created_at);
      hood.tags.push(log.tags || []);
    });

    // Calculate stats for each neighborhood
    const stats: NeighborhoodStats[] = [];
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    neighborhoodMap.forEach((data, neighborhood) => {
      const totalLogs = data.ratings.length;
      const logsToday = data.dates.filter(date => new Date(date) >= today).length;
      const averageRating = data.ratings.reduce((a, b) => a + b, 0) / totalLogs;
      const vibeScore = Math.round((averageRating / 5) * 100);

      // Get recent activity (last 24h)
      const now = Date.now();
      const recentIndices: number[] = [];
      const last24h = data.dates.filter((date, index) => {
        const logDate = new Date(date);
        const hoursSince = (now - logDate.getTime()) / (1000 * 60 * 60);
        if (hoursSince <= 24) {
          recentIndices.push(index);
          return true;
        }
        return false;
      }).length;

      // Get tags from last 24h
      const recentTags = recentIndices
        .flatMap(i => data.tags[i] || [])
        .filter((tag, index, self) => self.indexOf(tag) === index) // unique
        .slice(0, 3); // top 3

      const previous24h = data.dates.filter(date => {
        const logDate = new Date(date);
        const hoursSince = (now - logDate.getTime()) / (1000 * 60 * 60);
        return hoursSince > 24 && hoursSince <= 48;
      }).length;

      let trending: 'Up' | 'Down' | 'Stable' = 'Stable';
      if (last24h > previous24h) trending = 'Up';
      else if (last24h < previous24h) trending = 'Down';

      // Determine energy level
      let energy: 'low' | 'medium' | 'high' = 'medium';
      if (last24h >= 10) energy = 'high';
      else if (last24h <= 2) energy = 'low';

      // Get current hour for time-aware moods
      const currentHour = new Date().getHours();

      // Generate mood based on rating, time, and tags
      let moodEmoji = '😐';
      let currentMood = 'Neutral';
      let whatsHappening = 'Quiet vibes';

      const hasNightlife = recentTags.includes('Nightlife');
      const hasCoffee = recentTags.includes('Coffee');
      const hasQuiet = recentTags.includes('Quiet');
      const hasFood = recentTags.includes('Food');

      // Time-aware + tag-aware mood generation
      if (currentHour >= 5 && currentHour < 12) {
        // Morning (5am-12pm)
        if (hasCoffee) {
          moodEmoji = '☕';
          currentMood = 'Morning Buzz';
          whatsHappening = 'Coffee shops filling up';
        } else if (averageRating >= 4) {
          moodEmoji = '🌅';
          currentMood = 'Fresh Start';
          whatsHappening = 'Waking up nicely';
        }
      } else if (currentHour >= 12 && currentHour < 17) {
        // Afternoon (12pm-5pm)
        if (hasFood) {
          moodEmoji = '🍽️';
          currentMood = 'Lunch Rush';
          whatsHappening = 'Great food scene';
        } else if (energy === 'high') {
          moodEmoji = '⚡';
          currentMood = 'Buzzing';
          whatsHappening = 'Lots happening';
        }
      } else if (currentHour >= 17 && currentHour < 22) {
        // Evening (5pm-10pm)
        if (hasNightlife || energy === 'high') {
          moodEmoji = '🎉';
          currentMood = 'Getting Lively';
          whatsHappening = 'Evening energy picking up';
        } else if (hasFood) {
          moodEmoji = '🍷';
          currentMood = 'Dinner Vibes';
          whatsHappening = 'Perfect dinner spot';
        }
      } else {
        // Late night (10pm-5am)
        if (hasNightlife && energy === 'high') {
          moodEmoji = '🔥';
          currentMood = 'Raging';
          whatsHappening = 'Party mode activated';
        } else if (hasNightlife) {
          moodEmoji = '🌃';
          currentMood = 'Nightlife Scene';
          whatsHappening = 'Late night energy';
        } else if (hasQuiet || energy === 'low') {
          moodEmoji = '🌙';
          currentMood = 'Chill & Cozy';
          whatsHappening = 'Winding down peacefully';
        }
      }

      // Override with rating-based mood if no specific context
      if (whatsHappening === 'Quiet vibes') {
        if (averageRating >= 4.5) {
          moodEmoji = '🤩';
          currentMood = 'Amazing Energy';
          whatsHappening = 'Everyone loving it here';
        } else if (averageRating >= 4) {
          moodEmoji = '😊';
          currentMood = 'Great Vibes';
          whatsHappening = 'Positive energy all around';
        } else if (averageRating >= 3.5) {
          moodEmoji = '🙂';
          currentMood = 'Good Times';
          whatsHappening = 'Solid neighborhood feel';
        } else if (averageRating >= 3) {
          moodEmoji = '😐';
          currentMood = 'Okay Vibes';
          whatsHappening = 'Pretty calm';
        } else {
          moodEmoji = '😕';
          currentMood = 'Mixed Feelings';
          whatsHappening = 'Varied experiences';
        }
      }

      stats.push({
        neighborhood,
        totalLogs,
        logsToday,
        vibeScore,
        averageRating,
        trending,
        moodEmoji,
        currentMood,
        whatsHappening,
        recentTags,
        energy,
      });
    });

    // Sort by total activity and return top N
    return stats.sort((a, b) => b.totalLogs - a.totalLogs).slice(0, limit);
  },

  // === Quick Vibes (24h ephemeral updates) ===

  // Get all active quick vibes (not expired)
  async getQuickVibes(limit = 20) {
    const { data, error } = await supabase
      .from('quick_vibes')
      .select(`
        *,
        user:user_id (
          full_name,
          avatar_url
        )
      `)
      .gt('expires_at', new Date().toISOString()) // Only non-expired
      .order('created_at', { ascending: false })
      .limit(limit);

    if (error) throw error;
    return data as QuickVibe[];
  },

  // Create a new quick vibe
  async createQuickVibe(vibe: {
    user_id: string;
    neighborhood: string;
    text: string;
    latitude?: number;
    longitude?: number;
  }) {
    const { data, error } = await supabase
      .from('quick_vibes')
      .insert([{
        user_id: vibe.user_id,
        neighborhood: vibe.neighborhood,
        text: vibe.text,
        latitude: vibe.latitude || null,
        longitude: vibe.longitude || null,
      }])
      .select()
      .single();

    if (error) throw error;
    return data as QuickVibe;
  },

  // Delete a quick vibe (user's own)
  async deleteQuickVibe(vibeId: string, userId: string) {
    const { error } = await supabase
      .from('quick_vibes')
      .delete()
      .eq('id', vibeId)
      .eq('user_id', userId);

    if (error) throw error;
    return true;
  },

  // Get quick vibes by neighborhood
  async getQuickVibesByNeighborhood(neighborhood: string, limit = 10) {
    const { data, error } = await supabase
      .from('quick_vibes')
      .select(`
        *,
        user:user_id (
          full_name,
          avatar_url
        )
      `)
      .eq('neighborhood', neighborhood)
      .gt('expires_at', new Date().toISOString())
      .order('created_at', { ascending: false })
      .limit(limit);

    if (error) throw error;
    return data as QuickVibe[];
  },
};

export default pulseDb;
