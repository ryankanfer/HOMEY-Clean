// Centralized User Preferences Management
// Single source of truth for accessing and updating user preferences

import { db, auth } from '@/lib/supabase';

export interface UserPreferences {
  // Basic Info
  displayName?: string;
  fullName?: string;
  phone?: string;

  // Core Preferences (from onboarding)
  userType?: 'renter' | 'buyer' | 'browser';
  location?: 'new_york_city' | 'chicago' | 'los_angeles' | 'miami';
  neighborhoods?: string[];

  // Budget
  budgetMin?: number;
  budgetMax?: number;

  // Space Requirements
  bedrooms?: number;
  bathrooms?: number;

  // Income (NYC renters)
  householdIncome?: number;
  incomeVerified?: boolean;
  meets40xRequirement?: boolean;

  // Agent Info
  hasAgent?: boolean;
  agentName?: string;
  agentContact?: string;

  // Learned Preferences (from behavior)
  learnedPreferences?: {
    avgPriceLiked?: number;
    preferredBedrooms?: number;
    preferredNeighborhoods?: string[];
    preferredPropertyTypes?: string[];
    totalSwipes?: number;
    totalLikes?: number;
    totalLoves?: number;
  };

  // Additional Preferences (to be added)
  petFriendly?: boolean;
  commuteLocation?: string;
  maxCommuteMinutes?: number;
  moveInDate?: string;
  mustHaveAmenities?: string[];
  dealBreakers?: string[];

  // Metadata
  onboardingCompleted?: boolean;
  hasSwipeData?: boolean;
}

/**
 * Get comprehensive user preferences from all sources
 * Priority: onboarding_data (JSONB) > individual columns > learned preferences
 */
export async function getUserPreferences(userId?: string): Promise<UserPreferences | null> {
  try {
    // Get user ID if not provided
    let uid = userId;
    if (!uid) {
      const { data: { user } } = await auth.getUser();
      if (!user) return null;
      uid = user.id;
    }

    // Load profile data
    const { data: profile, error } = await db.getProfile(uid);
    if (error || !profile) {
      console.error('Failed to load user profile:', error);
      return null;
    }

    // Extract onboarding data (primary source)
    const onboardingData = profile.onboarding_data || {};

    // Load learned preferences from swipe behavior
    const { data: learnedPrefs } = await db.getUserLearnedPreferences(uid);

    // Check if user has swipe data
    const { data: swipeStats } = await db.getSwipeStats(uid);
    const hasSwipes = !!(swipeStats && swipeStats.total > 0);

    // Merge all preference sources with priority
    const preferences: UserPreferences = {
      // Basic Info (from onboarding or metadata)
      displayName: onboardingData.displayName || profile.teach_homey_preferences?.name,
      fullName: onboardingData.fullName,
      phone: onboardingData.phone,

      // Core Preferences (onboarding_data takes priority, fallback to columns)
      userType: onboardingData.userType || profile.user_type,
      location: onboardingData.location || profile.primary_location,
      neighborhoods: onboardingData.neighborhoods || profile.neighborhoods || [],

      // Budget (onboarding_data takes priority)
      budgetMin: onboardingData.budgetMin ?? profile.budget_min,
      budgetMax: onboardingData.budgetMax ?? profile.budget_max,

      // Space Requirements
      bedrooms: onboardingData.bedrooms ?? profile.bedrooms,
      bathrooms: onboardingData.bathrooms ?? profile.bathrooms,

      // Income
      householdIncome: onboardingData.householdIncome ?? profile.household_income,
      incomeVerified: profile.income_verified,
      meets40xRequirement: profile.meets_40x_requirement,

      // Agent Info
      hasAgent: onboardingData.hasAgent ?? profile.has_agent,
      agentName: onboardingData.agentName || profile.agent_name,
      agentContact: onboardingData.agentContact || profile.agent_contact,

      // Learned Preferences (from swipe behavior)
      learnedPreferences: learnedPrefs ? {
        avgPriceLiked: learnedPrefs.avg_price_liked,
        preferredBedrooms: learnedPrefs.preferred_bedrooms,
        preferredNeighborhoods: learnedPrefs.preferred_neighborhoods || [],
        preferredPropertyTypes: learnedPrefs.preferred_property_types || [],
        totalSwipes: swipeStats?.total || 0,
        totalLikes: swipeStats?.likes || 0,
        totalLoves: swipeStats?.loves || 0,
      } : undefined,

      // Metadata
      onboardingCompleted: profile.onboarding_completed,
      hasSwipeData: hasSwipes,
    };

    return preferences;
  } catch (error) {
    console.error('Error loading user preferences:', error);
    return null;
  }
}

/**
 * Update user preferences (saves to onboarding_data JSONB)
 */
export async function updateUserPreferences(
  updates: Partial<UserPreferences>,
  userId?: string
): Promise<{ success: boolean; error?: string }> {
  try {
    // Get user ID if not provided
    let uid = userId;
    if (!uid) {
      const { data: { user } } = await auth.getUser();
      if (!user) return { success: false, error: 'Not authenticated' };
      uid = user.id;
    }

    // Load current profile
    const { data: profile } = await db.getProfile(uid);
    if (!profile) {
      return { success: false, error: 'Profile not found' };
    }

    // Merge updates with existing onboarding_data
    const currentData = profile.onboarding_data || {};
    const updatedData = {
      ...currentData,
      ...updates,
      // Preserve metadata
      lastUpdated: new Date().toISOString(),
    };

    // Update profile with new onboarding_data
    const { error } = await db.updateProfile(uid, {
      onboarding_data: updatedData,
      // Also update individual columns for backwards compatibility
      ...(updates.budgetMin !== undefined && { budget_min: updates.budgetMin }),
      ...(updates.budgetMax !== undefined && { budget_max: updates.budgetMax }),
      ...(updates.bedrooms !== undefined && { bedrooms: updates.bedrooms }),
      ...(updates.bathrooms !== undefined && { bathrooms: updates.bathrooms }),
      ...(updates.neighborhoods !== undefined && { neighborhoods: updates.neighborhoods }),
      ...(updates.location !== undefined && { primary_location: updates.location }),
      ...(updates.userType !== undefined && { user_type: updates.userType }),
    });

    if (error) {
      console.error('Failed to update preferences:', error);
      return { success: false, error: error.message };
    }

    return { success: true };
  } catch (error: any) {
    console.error('Error updating user preferences:', error);
    return { success: false, error: error.message };
  }
}

/**
 * Get user's display name for personalization
 */
export async function getUserDisplayName(userId?: string): Promise<string> {
  const prefs = await getUserPreferences(userId);
  if (!prefs) return '';

  return prefs.displayName || prefs.fullName?.split(' ')[0] || '';
}

/**
 * Check if user meets budget requirements for a listing
 */
export function meetsbudgetRequirements(
  listingPrice: number,
  preferences: UserPreferences
): boolean {
  if (preferences.budgetMax && listingPrice > preferences.budgetMax) {
    return false;
  }
  if (preferences.budgetMin && listingPrice < preferences.budgetMin) {
    return false;
  }
  return true;
}

/**
 * Check if listing matches user's space requirements
 */
export function meetsSpaceRequirements(
  listing: { bedrooms: number; bathrooms: number },
  preferences: UserPreferences
): boolean {
  if (preferences.bedrooms && listing.bedrooms < preferences.bedrooms) {
    return false;
  }
  if (preferences.bathrooms && listing.bathrooms < preferences.bathrooms) {
    return false;
  }
  return true;
}

/**
 * Check if listing is in user's preferred neighborhoods
 */
export function isInPreferredNeighborhood(
  listingNeighborhood: string,
  preferences: UserPreferences
): boolean {
  if (!preferences.neighborhoods || preferences.neighborhoods.length === 0) {
    return true; // No preference = all neighborhoods OK
  }

  const normalized = listingNeighborhood.toLowerCase().trim();
  return preferences.neighborhoods.some(
    (n) => n.toLowerCase().trim() === normalized
  );
}

/**
 * Get location display name from location ID
 */
export function getLocationDisplayName(locationId?: string): string {
  const locationMap: Record<string, string> = {
    new_york_city: 'New York City',
    chicago: 'Chicago',
    los_angeles: 'Los Angeles',
    miami: 'Miami',
  };

  return locationId ? locationMap[locationId] || locationId : 'Unknown';
}

/**
 * Get property types based on user type
 */
export function getAllowedPropertyTypes(userType?: string): string[] {
  switch (userType) {
    case 'renter':
      return ['apartment', 'condo', 'studio', 'loft'];
    case 'buyer':
      return ['house', 'condo', 'townhouse', 'multi-family'];
    case 'browser':
    default:
      return ['apartment', 'condo', 'house', 'townhouse', 'studio', 'loft', 'multi-family'];
  }
}

export default {
  getUserPreferences,
  updateUserPreferences,
  getUserDisplayName,
  meetsbudgetRequirements,
  meetsSpaceRequirements,
  isInPreferredNeighborhood,
  getLocationDisplayName,
  getAllowedPropertyTypes,
};
