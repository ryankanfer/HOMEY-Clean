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

  // Urgent Actions
  getTopUrgentAction: async (userId: string) => {
    const { data, error } = await supabase
      .rpc('get_top_urgent_action', {
        p_user_id: userId,
      });
    return { data: data?.[0] || null, error };
  },

  completeUrgentAction: async (actionId: string, userId: string) => {
    const { data, error } = await supabase
      .rpc('complete_urgent_action', {
        p_action_id: actionId,
        p_user_id: userId,
      });
    return { data, error };
  },

  dismissUrgentAction: async (actionId: string, userId: string) => {
    const { data, error } = await supabase
      .rpc('dismiss_urgent_action', {
        p_action_id: actionId,
        p_user_id: userId,
      });
    return { data, error };
  },

  createUrgentAction: async (params: {
    userId: string;
    actionType: 'sign_disclosure' | 'sign_lease' | 'submit_application' | 'confirm_tour' | 'payment_due' | 'deadline_approaching';
    title: string;
    description: string;
    actionText: string;
    priority: 'critical' | 'urgent' | 'high';
    href: string;
    deadline?: string; // ISO timestamp
    relatedListingId?: string;
    relatedDocumentId?: string;
    relatedTourId?: string;
  }) => {
    const { data, error } = await supabase
      .from('urgent_actions')
      .insert({
        user_id: params.userId,
        action_type: params.actionType,
        title: params.title,
        description: params.description,
        action_text: params.actionText,
        priority: params.priority,
        href: params.href,
        deadline: params.deadline,
        related_listing_id: params.relatedListingId,
        related_document_id: params.relatedDocumentId,
        related_tour_id: params.relatedTourId,
      })
      .select()
      .single();
    return { data, error };
  },

  getAllUrgentActions: async (userId: string) => {
    const { data, error } = await supabase
      .from('urgent_actions')
      .select('*')
      .eq('user_id', userId)
      .eq('status', 'pending')
      .order('created_at', { ascending: false });
    return { data, error };
  },

  getDocuments: async (userId: string) => {
    const { data, error } = await supabase
      .from('user_documents')
      .select('*')
      .eq('user_id', userId)
      .eq('is_archived', false)
      .order('created_at', { ascending: false });
    return { data, error };
  },

  uploadDocument: async (params: {
    userId: string;
    fileName: string;
    fileUrl: string;
    fileSize: number;
    mimeType: string;
  }) => {
    const { data, error } = await supabase
      .from('user_documents')
      .insert({
        user_id: params.userId,
        file_name: params.fileName,
        file_url: params.fileUrl,
        file_size: params.fileSize,
        mime_type: params.mimeType,
        extraction_status: 'pending',
      })
      .select()
      .single();
    return { data, error };
  },

  updateDocumentExtraction: async (params: {
    documentId: string;
    documentType: string;
    extractedData: any;
    viewMode: string;
    confidence: number;
  }) => {
    const { data, error } = await supabase
      .from('user_documents')
      .update({
        document_type: params.documentType,
        extracted_data: params.extractedData,
        view_mode: params.viewMode,
        extraction_confidence: params.confidence,
        extraction_status: 'completed',
        extracted_at: new Date().toISOString(),
      })
      .eq('id', params.documentId)
      .select()
      .single();
    return { data, error };
  },

  searchDocuments: async (userId: string, query: string) => {
    const { data, error } = await supabase
      .rpc('search_documents', {
        p_user_id: userId,
        p_search_query: query,
      });
    return { data, error };
  },

  getDocumentsByCategory: async (userId: string, category: string) => {
    const { data, error} = await supabase
      .rpc('get_documents_by_category', {
        p_user_id: userId,
        p_category: category,
      });
    return { data, error };
  },

  deleteDocument: async (documentId: string, userId: string, storagePath: string) => {
    // Delete from database
    const { error: dbError } = await supabase
      .from('user_documents')
      .delete()
      .eq('id', documentId)
      .eq('user_id', userId);

    if (dbError) {
      return { error: dbError };
    }

    // Delete from storage
    const { error: storageError } = await supabase.storage
      .from('documents')
      .remove([storagePath]);

    return { error: storageError };
  },
};

// Agent Portal helpers
export const agentDb = {
  // Agent Profiles
  getAgentProfile: async (userId: string) => {
    const { data, error } = await supabase
      .from('agent_profiles')
      .select('*')
      .eq('user_id', userId)
      .single();
    return { data, error };
  },

  createAgentProfile: async (userId: string, profileData: any) => {
    const { data, error } = await supabase
      .from('agent_profiles')
      .insert({
        user_id: userId,
        ...profileData,
      })
      .select()
      .single();
    return { data, error };
  },

  updateAgentProfile: async (profileId: string, updates: any) => {
    const { data, error } = await supabase
      .from('agent_profiles')
      .update({
        ...updates,
        updated_at: new Date().toISOString(),
      })
      .eq('id', profileId)
      .select()
      .single();
    return { data, error };
  },

  isUserAgent: async (userId: string) => {
    const { data, error } = await supabase
      .from('agent_profiles')
      .select('id')
      .eq('user_id', userId)
      .single();
    return { isAgent: !!data && !error, data, error };
  },

  // Agent-Client Connections
  getAgentConnections: async (agentId: string, status?: string) => {
    console.log('🔍 Fetching agent connections for:', agentId);

    // First, get the connections without join
    let query = supabase
      .from('agent_client_connections')
      .select('*')
      .eq('agent_id', agentId)
      .order('created_at', { ascending: false });

    if (status) {
      query = query.eq('status', status);
      console.log('🔍 Filtering by status:', status);
    }

    const { data, error } = await query;

    if (error) {
      console.error('❌ Database query error:', JSON.stringify(error, null, 2));
      return { data: null, error };
    }

    console.log('✅ Query successful, found:', data?.length || 0, 'connections');

    // If we have data, fetch client profile data manually
    if (data && data.length > 0) {
      const clientIds = data
        .filter(conn => conn.client_id) // Only for accepted connections
        .map(conn => conn.client_id);

      if (clientIds.length > 0) {
        console.log('📋 Fetching client profiles for:', clientIds.length, 'clients');

        const { data: clientProfiles, error: clientError } = await supabase
          .from('profiles')
          .select('id, full_name, email')
          .in('id', clientIds);

        if (!clientError && clientProfiles) {
          // Attach client profile data to connection data
          const enrichedData = data.map(conn => {
            if (conn.client_id) {
              const clientProfile = clientProfiles.find(p => p.id === conn.client_id);
              if (clientProfile) {
                return {
                  ...conn,
                  client: {
                    id: clientProfile.id,
                    full_name: clientProfile.full_name || clientProfile.email || 'Client',
                    avatar_url: null, // No avatar in profiles table yet
                  }
                };
              }
            }
            return conn;
          });

          console.log('✅ Enriched with client profile data');
          return { data: enrichedData, error: null };
        } else if (clientError) {
          console.error('❌ Error fetching client profiles:', clientError);
        }
      }
    }

    return { data, error };
  },

  getClientConnection: async (agentId: string, clientId: string) => {
    const { data, error } = await supabase
      .from('agent_client_connections')
      .select('*')
      .eq('agent_id', agentId)
      .eq('client_id', clientId)
      .single();
    return { data, error };
  },

  getClientConnections: async (clientId: string, status?: string) => {
    console.log('🔍 Fetching client connections for:', clientId);

    // Try without nested user join first
    let query = supabase
      .from('agent_client_connections')
      .select(`
        *,
        agent:agent_profiles(*)
      `)
      .eq('client_id', clientId)
      .order('created_at', { ascending: false });

    if (status) {
      query = query.eq('status', status);
      console.log('🔍 Filtering by status:', status);
    }

    let { data, error } = await query;

    if (error) {
      console.error('❌ Database query error:', JSON.stringify(error, null, 2));
      console.error('❌ Full error object:', error);
    } else {
      console.log('✅ Query successful, found:', data?.length || 0, 'connections');

      // If we have data, fetch user profiles separately
      if (data && data.length > 0) {
        console.log('📋 First connection (without user):', JSON.stringify(data[0], null, 2));

        // Fetch user profiles for each agent
        const agentIds = data.map(conn => conn.agent?.user_id).filter(Boolean);
        if (agentIds.length > 0) {
          const { data: userProfiles, error: userError } = await supabase
            .from('profiles')
            .select('id, full_name, email, phone')
            .in('id', agentIds);

          if (userError) {
            console.error('❌ Error fetching user profiles:', JSON.stringify(userError, null, 2));
            console.error('❌ Agent IDs we tried to fetch:', agentIds);
          }

          if (!userError && userProfiles) {
            // Attach user profiles to agent data
            data = data.map(conn => {
              if (conn.agent && conn.agent.user_id) {
                const userProfile = userProfiles.find(u => u.id === conn.agent.user_id);
                if (userProfile) {
                  return {
                    ...conn,
                    agent: {
                      ...conn.agent,
                      user: userProfile
                    }
                  };
                }
              }
              return conn;
            });

            console.log('✅ Enriched with user profiles:', JSON.stringify(data[0], null, 2));
          }
        }
      }
    }

    return { data, error };
  },

  inviteClient: async (params: {
    agentId: string;
    clientEmail: string;
    connectionType: 'buyer' | 'seller';
    invitationMessage?: string;
    budgetMin?: number;
    budgetMax?: number;
    bedroomsMin?: number;
    targetNeighborhoods?: string[];
  }) => {
    // Create the connection record
    const { data, error } = await supabase
      .from('agent_client_connections')
      .insert({
        agent_id: params.agentId,
        invited_email: params.clientEmail, // Store email for pending invitation
        client_id: null, // Will be set when client accepts
        status: 'pending',
        connection_type: params.connectionType,
        invitation_message: params.invitationMessage,
        budget_min: params.budgetMin,
        budget_max: params.budgetMax,
        bedrooms_min: params.bedroomsMin,
        target_neighborhoods: params.targetNeighborhoods,
      })
      .select()
      .single();

    if (error) return { data, error };

    // Send invitation email
    try {
      const invitationLink = `${window.location.origin}/accept-invitation?id=${data.id}`;

      // Get agent profile for email
      const { data: agentProfile } = await supabase
        .from('agent_profiles')
        .select('*, user:profiles!user_id(*)')
        .eq('id', params.agentId)
        .single();

      const agentName = agentProfile?.user?.full_name || 'Your Agent';
      const brokerageName = agentProfile?.brokerage_name || '';

      // Call the email API endpoint
      await fetch('/api/send-invitation', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          to: params.clientEmail,
          agentName,
          brokerageName,
          invitationMessage: params.invitationMessage,
          invitationLink,
        }),
      });
    } catch (emailError) {
      console.error('Failed to send invitation email:', emailError);
      // Don't fail the whole operation if email fails
    }

    return { data, error };
  },

  acceptInvitation: async (connectionId: string, clientId: string) => {
    console.log('🔄 Accepting invitation:', { connectionId, clientId });

    // First, check if the connection exists
    const { data: existing, error: checkError } = await supabase
      .from('agent_client_connections')
      .select('*')
      .eq('id', connectionId)
      .single();

    if (checkError) {
      console.error('❌ Connection not found:', JSON.stringify(checkError, null, 2));
      return { data: null, error: checkError };
    }

    console.log('✅ Found connection:', JSON.stringify(existing, null, 2));

    // Get the user's email - try auth first, then fall back to profiles table
    let userEmail: string | null = null;

    // Try to get from current auth session
    let { data: { user }, error: userError } = await supabase.auth.getUser();

    // If we get a 403 or auth error, try refreshing the session
    if (userError || !user) {
      console.log('⚠️ Auth error or no user, attempting to refresh session...');
      const { data: refreshData, error: refreshError } = await supabase.auth.refreshSession();

      if (refreshError) {
        console.error('❌ Session refresh failed:', JSON.stringify(refreshError, null, 2));
        // Session is truly invalid - user needs to log out and back in
        return {
          data: null,
          error: {
            message: 'Your session has expired. Please log out and log back in to accept this invitation.',
            code: 'SESSION_EXPIRED'
          } as any
        };
      }

      if (refreshData.session) {
        console.log('✅ Session refreshed successfully');
        // Try getting user again
        const result = await supabase.auth.getUser();
        user = result.data.user;
        userError = result.error;
      }
    }

    if (user?.email) {
      userEmail = user.email;
      console.log('✅ Got user email from auth:', userEmail);
    } else {
      console.log('⚠️ Still no auth session after refresh, fetching email from profiles table');

      // Fall back to profiles table (useful right after signup)
      // Try a few times in case profile is being created
      let profile = null;
      for (let i = 0; i < 3; i++) {
        const { data: profileData } = await supabase
          .from('profiles')
          .select('email')
          .eq('id', clientId)
          .single();

        if (profileData?.email) {
          profile = profileData;
          break;
        }

        // Wait a bit before retrying
        if (i < 2) {
          console.log(`⏳ Waiting for profile to be created (attempt ${i + 1}/3)...`);
          await new Promise(resolve => setTimeout(resolve, 500));
        }
      }

      if (profile?.email) {
        userEmail = profile.email;
        console.log('✅ Got user email from profiles:', userEmail);
      }
    }

    if (!userEmail) {
      console.error('❌ Could not determine user email');
      return {
        data: null,
        error: { message: 'Could not verify user identity. Please try logging in again.' } as any
      };
    }

    console.log('✅ User email verified:', userEmail);

    // Verify the user is authorized to accept this invitation
    if (existing.invited_email && existing.invited_email.toLowerCase() !== userEmail.toLowerCase()) {
      console.error('❌ Email mismatch:', { invited: existing.invited_email, user: userEmail });
      return {
        data: null,
        error: { message: `This invitation was sent to ${existing.invited_email}, but you're signed in as ${userEmail}` } as any
      };
    }

    // Check if already accepted
    if (existing.status === 'active' && existing.client_id === clientId) {
      console.log('ℹ️ Invitation already accepted, returning existing connection');
      return { data: existing, error: null };
    }

    // Verify the invitation is in pending status
    if (existing.status !== 'pending') {
      console.error('❌ Invitation is not pending:', existing.status);
      return {
        data: null,
        error: { message: `This invitation has already been ${existing.status}` } as any
      };
    }

    console.log('🔄 Updating connection to active status...');

    // Update the connection
    const { data, error } = await supabase
      .from('agent_client_connections')
      .update({
        client_id: clientId,
        status: 'active',
        updated_at: new Date().toISOString(),
      })
      .eq('id', connectionId)
      .select();

    if (error) {
      console.error('❌ Error updating connection:', JSON.stringify(error, null, 2));
      console.error('❌ Error details:', {
        code: error.code,
        message: error.message,
        details: error.details,
        hint: error.hint
      });
      return { data: null, error };
    }

    if (!data || data.length === 0) {
      console.error('❌ Update returned 0 rows - RLS policy blocking update');
      console.error('❌ Context:', {
        userId: user?.id,
        userEmail: user?.email,
        connectionId,
        invitedEmail: existing.invited_email,
        status: existing.status
      });
      return {
        data: null,
        error: {
          message: 'Unable to accept invitation. This may be a permissions issue. Please contact support.',
          code: 'RLS_BLOCK',
          details: 'The database rejected the update. Check RLS policies on agent_client_connections table.'
        } as any
      };
    }

    console.log('✅ Invitation accepted successfully:', JSON.stringify(data[0], null, 2));
    return { data: data[0], error: null };
  },

  updateConnectionStatus: async (connectionId: string, status: string) => {
    const { data, error } = await supabase
      .from('agent_client_connections')
      .update({
        status,
        updated_at: new Date().toISOString(),
      })
      .eq('id', connectionId)
      .select()
      .single();
    return { data, error };
  },

  updateConnectionNotes: async (connectionId: string, notes: string) => {
    const { data, error } = await supabase
      .from('agent_client_connections')
      .update({
        agent_notes: notes,
        updated_at: new Date().toISOString(),
      })
      .eq('id', connectionId)
      .select()
      .single();
    return { data, error };
  },

  // Find agent by email (for client-initiated connections)
  findAgentByEmail: async (email: string) => {
    // First find the user with this email
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('id, email, full_name')
      .eq('email', email.toLowerCase())
      .single();

    if (profileError || !profile) {
      return { data: null, error: profileError };
    }

    // Check if this user is an agent
    const { data: agentProfile, error: agentError } = await supabase
      .from('agent_profiles')
      .select('*, user:profiles!user_id(*)')
      .eq('user_id', profile.id)
      .single();

    return { data: agentProfile, error: agentError };
  },

  // Client requests connection to agent
  requestConnectionToAgent: async (params: {
    clientId: string;
    agentEmail: string;
    agentName: string;
    connectionMessage?: string;
  }) => {
    // Create the connection record with pending status
    // Note: agent_id will be null if agent doesn't exist yet
    const { data, error } = await supabase
      .from('agent_client_connections')
      .insert({
        client_id: params.clientId,
        agent_id: null, // Will be set when agent accepts or is found
        invited_email: params.agentEmail, // Store email for agent lookup
        status: 'client_requested', // New status for client-initiated requests
        connection_type: 'buyer', // Default, can be updated later
        invitation_message: params.connectionMessage,
        agent_notes: `Client requested connection. Agent name: ${params.agentName}`,
      })
      .select()
      .single();

    return { data, error };
  },

  // Messages
  getConnectionMessages: async (connectionId: string) => {
    const { data, error } = await supabase
      .from('messages')
      .select('*')
      .eq('connection_id', connectionId)
      .order('created_at', { ascending: true });
    return { data, error };
  },

  markMessageAsRead: async (messageId: string, readBy: string) => {
    const { data, error } = await supabase
      .from('messages')
      .update({
        read_at: new Date().toISOString(),
        read_by: readBy,
      })
      .eq('id', messageId)
      .select()
      .single();
    return { data, error };
  },

  subscribeToMessages: (connectionId: string, callback: (payload: any) => void) => {
    return supabase
      .channel(`messages:${connectionId}`)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'messages',
          filter: `connection_id=eq.${connectionId}`,
        },
        callback
      )
      .subscribe();
  },

  getAgentMessages: async (agentId: string) => {
    const { data, error } = await supabase
      .from('messages')
      .select(`
        *,
        connection:agent_client_connections!inner(
          agent_id,
          client_id,
          status
        )
      `)
      .eq('connection.agent_id', agentId)
      .order('created_at', { ascending: false })
      .limit(100);
    return { data, error };
  },

  // Shared Documents
  getConnectionDocuments: async (connectionId: string) => {
    const { data, error } = await supabase
      .from('shared_documents')
      .select('*')
      .eq('connection_id', connectionId)
      .order('created_at', { ascending: false });
    return { data, error };
  },

  getAgentDocuments: async (agentId: string) => {
    const { data, error } = await supabase
      .from('shared_documents')
      .select(`
        *,
        connection:agent_client_connections(
          client_id,
          agent_id
        )
      `)
      .eq('connection.agent_id', agentId)
      .order('created_at', { ascending: false });
    return { data, error };
  },

  uploadSharedDocument: async (params: {
    connectionId: string;
    documentName: string;
    documentType: string;
    fileUrl: string;
    fileSizeBytes: number;
    mimeType: string;
    uploadedBy: string;
    uploaderType: 'agent' | 'client';
    listingId?: string;
    requiresSignature?: boolean;
    description?: string;
  }) => {
    const { data, error } = await supabase
      .from('shared_documents')
      .insert({
        connection_id: params.connectionId,
        document_name: params.documentName,
        document_type: params.documentType,
        file_url: params.fileUrl,
        file_size_bytes: params.fileSizeBytes,
        mime_type: params.mimeType,
        uploaded_by: params.uploadedBy,
        uploader_type: params.uploaderType,
        listing_id: params.listingId,
        requires_signature: params.requiresSignature || false,
        description: params.description,
      })
      .select()
      .single();
    return { data, error };
  },

  markDocumentAsViewed: async (documentId: string, viewerType: 'agent' | 'client') => {
    const updates: any = {
      updated_at: new Date().toISOString(),
    };

    if (viewerType === 'agent') {
      updates.viewed_by_agent = true;
      updates.agent_viewed_at = new Date().toISOString();
    } else {
      updates.viewed_by_client = true;
      updates.client_viewed_at = new Date().toISOString();
    }

    const { data, error } = await supabase
      .from('shared_documents')
      .update(updates)
      .eq('id', documentId)
      .select()
      .single();
    return { data, error };
  },

  signDocument: async (documentId: string, signedBy: string, signatureUrl: string) => {
    const { data, error } = await supabase
      .from('shared_documents')
      .update({
        signed_at: new Date().toISOString(),
        signed_by: signedBy,
        signature_url: signatureUrl,
      })
      .eq('id', documentId)
      .select()
      .single();
    return { data, error };
  },

  // Property Recommendations
  getAgentRecommendations: async (agentId: string) => {
    const { data, error } = await supabase
      .from('property_recommendations')
      .select('*')
      .eq('agent_id', agentId)
      .order('created_at', { ascending: false });
    return { data, error };
  },

  getClientRecommendations: async (clientId: string) => {
    const { data, error } = await supabase
      .from('property_recommendations')
      .select('*')
      .eq('client_id', clientId)
      .eq('client_viewed', false)
      .order('priority', { ascending: false })
      .order('created_at', { ascending: false });
    return { data, error };
  },

  createRecommendation: async (params: {
    connectionId: string;
    agentId: string;
    clientId: string;
    listingId: string;
    recommendationReason: string;
    highlights?: string[];
    potentialConcerns?: string[];
    priority?: 'low' | 'medium' | 'high';
  }) => {
    const { data, error } = await supabase
      .from('property_recommendations')
      .insert({
        connection_id: params.connectionId,
        agent_id: params.agentId,
        client_id: params.clientId,
        listing_id: params.listingId,
        recommendation_reason: params.recommendationReason,
        highlights: params.highlights,
        potential_concerns: params.potentialConcerns,
        priority: params.priority || 'medium',
      })
      .select()
      .single();
    return { data, error };
  },

  markRecommendationViewed: async (recommendationId: string) => {
    const { data, error } = await supabase
      .from('property_recommendations')
      .update({
        client_viewed: true,
        client_viewed_at: new Date().toISOString(),
      })
      .eq('id', recommendationId)
      .select()
      .single();
    return { data, error };
  },

  updateRecommendationResponse: async (recommendationId: string, response: string, feedback?: string) => {
    const { data, error } = await supabase
      .from('property_recommendations')
      .update({
        client_response: response,
        client_feedback: feedback,
        client_responded_at: new Date().toISOString(),
      })
      .eq('id', recommendationId)
      .select()
      .single();
    return { data, error };
  },

  // Showing Requests
  getAgentShowings: async (agentId: string, status?: string) => {
    const { data: connections } = await supabase
      .from('agent_client_connections')
      .select('id')
      .eq('agent_id', agentId);

    if (!connections) return { data: null, error: null };

    const connectionIds = connections.map(c => c.id);

    let query = supabase
      .from('showing_requests')
      .select('*')
      .in('connection_id', connectionIds)
      .order('preferred_date_1', { ascending: true });

    if (status) {
      query = query.eq('status', status);
    }

    const { data, error } = await query;
    return { data, error };
  },

  createShowingRequest: async (params: {
    connectionId: string;
    listingId: string;
    requestedBy: string;
    requesterType: 'agent' | 'client';
    preferredDate1: string;
    preferredDate2?: string;
    preferredDate3?: string;
    duration?: number;
    meetingInstructions?: string;
  }) => {
    const { data, error } = await supabase
      .from('showing_requests')
      .insert({
        connection_id: params.connectionId,
        listing_id: params.listingId,
        requested_by: params.requestedBy,
        requester_type: params.requesterType,
        preferred_date_1: params.preferredDate1,
        preferred_date_2: params.preferredDate2,
        preferred_date_3: params.preferredDate3,
        duration_minutes: params.duration || 30,
        meeting_instructions: params.meetingInstructions,
        status: 'pending',
      })
      .select()
      .single();
    return { data, error };
  },

  confirmShowing: async (showingId: string, confirmedDate: string) => {
    const { data, error } = await supabase
      .from('showing_requests')
      .update({
        confirmed_date: confirmedDate,
        status: 'confirmed',
      })
      .eq('id', showingId)
      .select()
      .single();
    return { data, error };
  },

  cancelShowing: async (showingId: string, cancelledBy: string, reason?: string) => {
    const { data, error } = await supabase
      .from('showing_requests')
      .update({
        status: 'cancelled',
        cancellation_reason: reason,
        cancelled_by: cancelledBy,
        cancelled_at: new Date().toISOString(),
      })
      .eq('id', showingId)
      .select()
      .single();
    return { data, error };
  },

  completeShowing: async (showingId: string, notes?: string, clientFeedback?: string) => {
    const { data, error } = await supabase
      .from('showing_requests')
      .update({
        status: 'completed',
        completed_at: new Date().toISOString(),
        post_showing_notes: notes,
        client_post_showing_feedback: clientFeedback,
        client_showed_up: true,
      })
      .eq('id', showingId)
      .select()
      .single();
    return { data, error };
  },

  // Agent Listings
  getAgentListings: async (agentId: string, role?: string) => {
    let query = supabase
      .from('agent_listings')
      .select('*')
      .eq('agent_id', agentId);

    if (role) {
      query = query.eq('role', role);
    }

    const { data, error } = await query;
    return { data, error };
  },

  addAgentListing: async (params: {
    agentId: string;
    listingId: string;
    role: 'listing_agent' | 'buyers_agent' | 'dual_agent';
    commissionPercentage?: number;
    commissionAmount?: number;
    isPrimaryAgent?: boolean;
  }) => {
    const { data, error } = await supabase
      .from('agent_listings')
      .insert(params)
      .select()
      .single();
    return { data, error };
  },

  // Messages
  getMessages: async (connectionId: string) => {
    const { data, error } = await supabase
      .from('messages')
      .select('*')
      .eq('connection_id', connectionId)
      .order('created_at', { ascending: true });
    return { data, error };
  },

  sendMessage: async (params: {
    connectionId: string;
    senderId: string;
    senderType: 'agent' | 'client';
    message: string;
  }) => {
    const { data, error } = await supabase
      .from('messages')
      .insert({
        connection_id: params.connectionId,
        sender_id: params.senderId,
        sender_type: params.senderType,
        message: params.message,
      })
      .select()
      .single();
    return { data, error };
  },

  markMessagesAsRead: async (connectionId: string, userId: string) => {
    const { data, error } = await supabase
      .from('messages')
      .update({ read: true })
      .eq('connection_id', connectionId)
      .neq('sender_id', userId)
      .eq('read', false);
    return { data, error };
  },

  getUnreadMessageCount: async (connectionId: string, userId: string) => {
    const { count, error } = await supabase
      .from('messages')
      .select('*', { count: 'exact', head: true })
      .eq('connection_id', connectionId)
      .neq('sender_id', userId)
      .eq('read', false);
    return { count: count || 0, error };
  },
};

export default supabase;
