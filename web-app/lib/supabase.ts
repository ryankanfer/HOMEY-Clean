import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Auth helpers
export const auth = {
  signIn: async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    return { data, error };
  },

  signUp: async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
    });
    return { data, error };
  },

  signOut: async () => {
    const { error } = await supabase.auth.signOut();
    return { error };
  },

  resetPassword: async (email: string) => {
    const { data, error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/auth/callback`,
    });
    return { data, error };
  },

  getSession: async () => {
    const { data, error } = await supabase.auth.getSession();
    return { data, error };
  },

  getUser: async () => {
    const { data, error } = await supabase.auth.getUser();
    return { data, error };
  },

  // OAuth providers
  signInWithGoogle: async () => {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
      },
    });
    return { data, error };
  },

  signInWithApple: async () => {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: 'apple',
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
      },
    });
    return { data, error };
  },
};

// Database helpers
export const db = {
  // Profiles
  getProfile: async (userId: string) => {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single();
    return { data, error };
  },

  updateProfile: async (userId: string, updates: any) => {
    const { data, error } = await supabase
      .from('profiles')
      .upsert({
        id: userId,
        ...updates,
        updated_at: new Date().toISOString(),
      })
      .select()
      .single();
    return { data, error };
  },

  // Listings
  getListings: async (filters?: any) => {
    let query = supabase
      .from('listings')
      .select('*')
      .eq('is_active', true);

    if (filters?.minPrice) query = query.gte('price', filters.minPrice);
    if (filters?.maxPrice) query = query.lte('price', filters.maxPrice);
    if (filters?.minBedrooms) query = query.gte('bedrooms', filters.minBedrooms);
    if (filters?.listingType) query = query.eq('listing_type', filters.listingType);

    // Support both single neighborhood and multiple neighborhoods
    if (filters?.neighborhood) {
      query = query.ilike('neighborhood', `%${filters.neighborhood}%`);
    } else if (filters?.neighborhoods && filters.neighborhoods.length > 0) {
      // Filter by multiple neighborhoods using OR condition
      const neighborhoodConditions = filters.neighborhoods
        .map((n: string) => `neighborhood.ilike.%${n}%`)
        .join(',');
      query = query.or(neighborhoodConditions);
    }

    query = query.order('created_at', { ascending: false, nullsFirst: false });

    const { data, error } = await query;
    return { data, error };
  },

  getListing: async (listingId: string) => {
    const { data, error } = await supabase
      .from('listings')
      .select('*')
      .eq('id', listingId)
      .single();
    return { data, error };
  },

  searchListings: async (filters: any = {}) => {
    const { data, error } = await supabase.rpc('search_listings', {
      p_min_price: filters.minPrice || 0,
      p_max_price: filters.maxPrice || 999999999,
      p_min_bedrooms: filters.minBedrooms || 0,
      p_min_bathrooms: filters.minBathrooms || 0,
      p_listing_type: filters.listingType || null,
      p_property_type: filters.propertyType || null,
      p_neighborhood: filters.neighborhood || null,
      p_features: filters.features || [],
      p_max_results: filters.maxResults || 50,
    });
    return { data, error };
  },

  // Saved properties
  getSavedProperties: async (userId: string) => {
    const { data, error } = await supabase
      .from('user_saved_properties')
      .select(`
        *,
        listing:listings(*)
      `)
      .eq('user_id', userId);
    return { data, error };
  },

  saveProperty: async (userId: string, listingId: string) => {
    const { data, error } = await supabase
      .from('user_saved_properties')
      .insert({ user_id: userId, listing_id: listingId });
    return { data, error };
  },

  unsaveProperty: async (userId: string, listingId: string) => {
    const { data, error } = await supabase
      .from('user_saved_properties')
      .delete()
      .eq('user_id', userId)
      .eq('listing_id', listingId);
    return { data, error };
  },

  isPropertySaved: async (userId: string, listingId: string) => {
    const { data, error } = await supabase
      .from('user_saved_properties')
      .select('id')
      .eq('user_id', userId)
      .eq('listing_id', listingId)
      .single();
    return { data, error };
  },

  // Matchmaker - Swipe tracking
  recordSwipe: async (userId: string, listingId: string, action: 'pass' | 'like' | 'love') => {
    const { data, error } = await supabase
      .from('user_swipes')
      .insert({ user_id: userId, listing_id: listingId, action });
    return { data, error };
  },

  getUnswipedListings: async (userId: string, limit: number = 20) => {
    const { data, error } = await supabase
      .rpc('get_unswiped_listings', {
        p_user_id: userId,
        p_limit: limit,
      });
    return { data, error };
  },

  getUserPreferences: async (userId: string) => {
    const { data, error } = await supabase
      .from('user_preferences')
      .select('*')
      .eq('user_id', userId)
      .single();
    return { data, error };
  },

  getSwipeStats: async (userId: string) => {
    const { data, error } = await supabase
      .from('user_swipes')
      .select('action')
      .eq('user_id', userId);

    if (error) return { data: null, error };

    const stats = {
      total: data.length,
      likes: data.filter(s => s.action === 'like').length,
      loves: data.filter(s => s.action === 'love').length,
      passes: data.filter(s => s.action === 'pass').length,
    };

    return { data: stats, error: null };
  },

  // Style Studio - Design inspiration
  getUnswipedDesigns: async (userId: string, limit: number = 20) => {
    const { data, error } = await supabase
      .rpc('get_unswiped_designs', {
        p_user_id: userId,
        p_limit: limit,
      });
    return { data, error };
  },

  recordDesignSwipe: async (userId: string, inspirationId: string, action: 'pass' | 'like' | 'love') => {
    const { data, error } = await supabase
      .from('user_design_swipes')
      .insert({ user_id: userId, inspiration_id: inspirationId, action });
    return { data, error };
  },

  getUserMoodBoards: async (userId: string) => {
    const { data, error } = await supabase
      .from('user_mood_boards')
      .select(`
        *,
        items:mood_board_items(count)
      `)
      .eq('user_id', userId)
      .order('updated_at', { ascending: false });
    return { data, error };
  },

  createMoodBoard: async (userId: string, name: string, description?: string) => {
    const { data, error } = await supabase
      .from('user_mood_boards')
      .insert({ user_id: userId, name, description })
      .select()
      .single();
    return { data, error };
  },

  addToMoodBoard: async (boardId: string, inspirationId: string) => {
    const { data, error } = await supabase
      .from('mood_board_items')
      .insert({ mood_board_id: boardId, inspiration_id: inspirationId });
    return { data, error };
  },

  getMoodBoardItems: async (boardId: string) => {
    const { data, error } = await supabase
      .from('mood_board_items')
      .select(`
        *,
        inspiration:design_inspirations(*)
      `)
      .eq('mood_board_id', boardId)
      .order('created_at', { ascending: false });
    return { data, error };
  },

  getDesignSwipeStats: async (userId: string) => {
    const { data, error } = await supabase
      .from('user_design_swipes')
      .select('action')
      .eq('user_id', userId);

    if (error) return { data: null, error };

    const stats = {
      total: data.length,
      likes: data.filter(s => s.action === 'like').length,
      loves: data.filter(s => s.action === 'love').length,
      passes: data.filter(s => s.action === 'pass').length,
    };

    return { data: stats, error: null };
  },

  // Scout's Recommendations
  getRecommendedListings: async (userId: string, limit: number = 20) => {
    const { data, error } = await supabase
      .rpc('get_recommended_listings', {
        p_user_id: userId,
        p_limit: limit,
      });
    return { data, error };
  },

  getTopMatchListing: async (userId: string) => {
    const { data, error } = await supabase
      .rpc('get_top_match_listing', {
        p_user_id: userId,
      });
    return { data: data?.[0] || null, error };
  },

  getUserLearnedPreferences: async (userId: string) => {
    const { data, error } = await supabase
      .rpc('get_user_learned_preferences', {
        p_user_id: userId,
      });
    return { data: data?.[0] || null, error };
  },

  calculateMatchScore: async (userId: string, listingId: string) => {
    const { data, error } = await supabase
      .rpc('calculate_listing_match_score', {
        p_user_id: userId,
        p_listing_id: listingId,
      });
    return { data, error };
  },
};

export default supabase;
