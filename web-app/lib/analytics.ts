import { supabase } from './supabase';

// Event types
export type EventType =
  | 'page_view'
  | 'listing_view'
  | 'search'
  | 'save'
  | 'unsave'
  | 'share'
  | 'contact'
  | 'schedule_tour'
  | 'message'
  | 'document_upload'
  | 'filter_change'
  | 'map_interaction'
  | 'click'
  | 'scroll';

export type EventCategory =
  | 'navigation'
  | 'engagement'
  | 'conversion'
  | 'search'
  | 'social'
  | 'documents'
  | 'communication';

export type JourneyStage =
  | 'exploring'
  | 'searching'
  | 'touring'
  | 'negotiating'
  | 'under_contract'
  | 'closing'
  | 'living';

export interface TrackEventParams {
  eventType: EventType;
  eventCategory: EventCategory;
  eventAction: string;
  eventData?: Record<string, any>;
  journeyStage?: JourneyStage;
}

export interface UserEvent {
  id?: string;
  user_id?: string;
  session_id: string;
  event_type: EventType;
  event_category: EventCategory;
  event_action: string;
  journey_stage?: JourneyStage;
  event_data?: Record<string, any>;
  page_path?: string;
  page_title?: string;
  referrer?: string;
  device_type?: string;
  browser?: string;
  os?: string;
  screen_size?: string;
  timestamp?: string;
}

// Generate or retrieve session ID
let sessionId: string | null = null;

function getSessionId(): string {
  if (sessionId) return sessionId;

  // Try to get from sessionStorage
  if (typeof window !== 'undefined') {
    const stored = sessionStorage.getItem('homey_session_id');
    if (stored) {
      sessionId = stored;
      return sessionId;
    }
  }

  // Generate new session ID
  sessionId = `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

  if (typeof window !== 'undefined') {
    sessionStorage.setItem('homey_session_id', sessionId);
  }

  return sessionId;
}

// Get device info
function getDeviceInfo() {
  if (typeof window === 'undefined') {
    return {
      device_type: 'unknown',
      browser: 'unknown',
      os: 'unknown',
      screen_size: 'unknown',
    };
  }

  const ua = navigator.userAgent;
  const screen_size = `${window.screen.width}x${window.screen.height}`;

  // Simple device detection
  const isMobile = /Mobile|Android|iPhone/i.test(ua);
  const isTablet = /Tablet|iPad/i.test(ua);
  const device_type = isMobile ? 'mobile' : isTablet ? 'tablet' : 'desktop';

  // Simple browser detection
  let browser = 'unknown';
  if (ua.includes('Chrome')) browser = 'chrome';
  else if (ua.includes('Safari')) browser = 'safari';
  else if (ua.includes('Firefox')) browser = 'firefox';
  else if (ua.includes('Edge')) browser = 'edge';

  // Simple OS detection
  let os = 'unknown';
  if (ua.includes('Windows')) os = 'windows';
  else if (ua.includes('Mac')) os = 'macos';
  else if (ua.includes('Linux')) os = 'linux';
  else if (ua.includes('Android')) os = 'android';
  else if (ua.includes('iOS') || ua.includes('iPhone') || ua.includes('iPad')) os = 'ios';

  return { device_type, browser, os, screen_size };
}

// Get page info
function getPageInfo() {
  if (typeof window === 'undefined') {
    return {
      page_path: '',
      page_title: '',
      referrer: '',
    };
  }

  return {
    page_path: window.location.pathname,
    page_title: document.title,
    referrer: document.referrer,
  };
}

// Get current user ID
async function getCurrentUserId(): Promise<string | null> {
  const { data: { user } } = await supabase.auth.getUser();
  return user?.id || null;
}

// Main tracking function
export async function trackEvent(params: TrackEventParams): Promise<void> {
  try {
    const userId = await getCurrentUserId();
    const deviceInfo = getDeviceInfo();
    const pageInfo = getPageInfo();

    const event: UserEvent = {
      user_id: userId || undefined,
      session_id: getSessionId(),
      event_type: params.eventType,
      event_category: params.eventCategory,
      event_action: params.eventAction,
      journey_stage: params.journeyStage,
      event_data: params.eventData || {},
      ...deviceInfo,
      ...pageInfo,
    };

    // Insert event
    const { error } = await supabase
      .from('user_events')
      .insert(event);

    if (error) {
      console.error('Failed to track event:', error);
    }
  } catch (error) {
    console.error('Error tracking event:', error);
  }
}

// Convenience functions for common events
export const analytics = {
  // Page view
  pageView: (pageName: string) => {
    trackEvent({
      eventType: 'page_view',
      eventCategory: 'navigation',
      eventAction: 'view_page',
      eventData: { page_name: pageName },
    });
  },

  // Listing interactions
  viewListing: (listingId: string, listingData?: Record<string, any>) => {
    trackEvent({
      eventType: 'listing_view',
      eventCategory: 'engagement',
      eventAction: 'view_listing',
      eventData: {
        listing_id: listingId,
        ...listingData,
      },
    });
  },

  saveListing: (listingId: string) => {
    trackEvent({
      eventType: 'save',
      eventCategory: 'conversion',
      eventAction: 'save_listing',
      eventData: { listing_id: listingId },
    });
  },

  unsaveListing: (listingId: string) => {
    trackEvent({
      eventType: 'unsave',
      eventCategory: 'engagement',
      eventAction: 'unsave_listing',
      eventData: { listing_id: listingId },
    });
  },

  shareListing: (listingId: string, method: string) => {
    trackEvent({
      eventType: 'share',
      eventCategory: 'social',
      eventAction: 'share_listing',
      eventData: {
        listing_id: listingId,
        share_method: method,
      },
    });
  },

  // Search interactions
  performSearch: (searchParams: Record<string, any>) => {
    trackEvent({
      eventType: 'search',
      eventCategory: 'search',
      eventAction: 'perform_search',
      eventData: searchParams,
      journeyStage: 'searching',
    });
  },

  changeFilter: (filterName: string, filterValue: any) => {
    trackEvent({
      eventType: 'filter_change',
      eventCategory: 'search',
      eventAction: 'change_filter',
      eventData: {
        filter_name: filterName,
        filter_value: filterValue,
      },
    });
  },

  // Communication
  contactAgent: (agentId: string, method: string) => {
    trackEvent({
      eventType: 'contact',
      eventCategory: 'communication',
      eventAction: 'contact_agent',
      eventData: {
        agent_id: agentId,
        contact_method: method,
      },
    });
  },

  sendMessage: (recipientType: string) => {
    trackEvent({
      eventType: 'message',
      eventCategory: 'communication',
      eventAction: 'send_message',
      eventData: { recipient_type: recipientType },
    });
  },

  // Tours
  scheduleTour: (listingId: string, tourDate?: string) => {
    trackEvent({
      eventType: 'schedule_tour',
      eventCategory: 'conversion',
      eventAction: 'schedule_tour',
      eventData: {
        listing_id: listingId,
        tour_date: tourDate,
      },
      journeyStage: 'touring',
    });
  },

  // Documents
  uploadDocument: (documentType: string) => {
    trackEvent({
      eventType: 'document_upload',
      eventCategory: 'documents',
      eventAction: 'upload_document',
      eventData: { document_type: documentType },
    });
  },

  // Map interactions
  interactWithMap: (action: string, data?: Record<string, any>) => {
    trackEvent({
      eventType: 'map_interaction',
      eventCategory: 'engagement',
      eventAction: action,
      eventData: data,
    });
  },

  // Generic click tracking
  click: (elementName: string, elementType: string, additionalData?: Record<string, any>) => {
    trackEvent({
      eventType: 'click',
      eventCategory: 'engagement',
      eventAction: 'click_element',
      eventData: {
        element_name: elementName,
        element_type: elementType,
        ...additionalData,
      },
    });
  },

  // Sign out - end the session
  signOut: () => {
    sessionManager.endSession();
  },

  // Account creation
  createAccount: (method: string, userData?: Record<string, any>) => {
    trackEvent({
      eventType: 'click',
      eventCategory: 'conversion',
      eventAction: 'create_account',
      eventData: {
        signup_method: method,
        ...userData,
      },
    });
  },

  // Profile update
  updateProfile: (profileData?: Record<string, any>) => {
    trackEvent({
      eventType: 'click',
      eventCategory: 'engagement',
      eventAction: 'update_profile',
      eventData: profileData,
    });
  },

  // Complete onboarding
  completeOnboarding: (onboardingType: string) => {
    trackEvent({
      eventType: 'click',
      eventCategory: 'conversion',
      eventAction: 'complete_onboarding',
      eventData: {
        onboarding_type: onboardingType,
      },
    });
  },
};

// Session management
export const sessionManager = {
  // Start a new session
  async startSession(): Promise<void> {
    const userId = await getCurrentUserId();
    if (!userId) {
      console.log('📊 Session tracking skipped (not logged in)');
      return;
    }

    const deviceInfo = getDeviceInfo();
    const pageInfo = getPageInfo();

    const { error } = await supabase.from('user_sessions').insert({
      session_id: getSessionId(),
      user_id: userId,
      entry_page: pageInfo.page_path,
      ...deviceInfo,
    });

    if (error) {
      console.warn('Session tracking failed:', error.message);
    }
  },

  // End session
  async endSession(): Promise<void> {
    const pageInfo = getPageInfo();

    await supabase
      .from('user_sessions')
      .update({
        ended_at: new Date().toISOString(),
        exit_page: pageInfo.page_path,
      })
      .eq('session_id', getSessionId());
  },
};

// Journey state management
export const journeyManager = {
  // Initialize or update journey state
  async updateJourneyStage(stage: JourneyStage, metadata?: Record<string, any>): Promise<void> {
    const userId = await getCurrentUserId();
    if (!userId) return;

    // Check if journey state exists
    const { data: existing } = await supabase
      .from('user_journey_states')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (existing) {
      // Update existing
      await supabase
        .from('user_journey_states')
        .update({
          previous_stage: existing.current_stage,
          current_stage: stage,
          stage_started_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })
        .eq('user_id', userId);
    } else {
      // Create new
      await supabase.from('user_journey_states').insert({
        user_id: userId,
        current_stage: stage,
      });
    }
  },

  // Get current journey state
  async getJourneyState(): Promise<any> {
    const userId = await getCurrentUserId();
    if (!userId) return null;

    const { data, error } = await supabase
      .rpc('get_user_journey_insights', { p_user_id: userId });

    if (error) {
      console.error('Failed to get journey state:', error);
      return null;
    }

    return data?.[0] || null;
  },
};

export default analytics;
