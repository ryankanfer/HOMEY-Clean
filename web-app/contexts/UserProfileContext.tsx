'use client';

import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { UserProfile, getUserProfile } from '@/lib/profileLearning';
import { auth } from '@/lib/supabase';

interface UserProfileContextType {
  profile: UserProfile | null;
  isLoading: boolean;
  error: string | null;
  refreshProfile: () => Promise<void>;
}

const UserProfileContext = createContext<UserProfileContextType | undefined>(undefined);

export function UserProfileProvider({ children }: { children: ReactNode }) {
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [userId, setUserId] = useState<string | null>(null);

  // Get userId on mount
  useEffect(() => {
    async function loadUser() {
      try {
        const { data: { user } } = await auth.getUser();
        if (user) {
          setUserId(user.id);
        } else {
          setIsLoading(false);
        }
      } catch (err) {
        console.error('Failed to get user:', err);
        setError(err instanceof Error ? err.message : 'Failed to load user');
        setIsLoading(false);
      }
    }
    loadUser();
  }, []);

  // Load profile when userId is available
  useEffect(() => {
    if (!userId) return;

    async function loadProfile() {
      try {
        setIsLoading(true);
        setError(null);

        const userProfile = await getUserProfile(userId);
        setProfile(userProfile);
      } catch (err) {
        console.error('Failed to load user profile:', err);
        setError(err instanceof Error ? err.message : 'Failed to load profile');
      } finally {
        setIsLoading(false);
      }
    }

    loadProfile();
  }, [userId]);

  // Function to manually refresh profile
  const refreshProfile = async () => {
    if (!userId) return;

    try {
      setIsLoading(true);
      setError(null);

      const userProfile = await getUserProfile(userId);
      setProfile(userProfile);
    } catch (err) {
      console.error('Failed to refresh user profile:', err);
      setError(err instanceof Error ? err.message : 'Failed to refresh profile');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <UserProfileContext.Provider value={{ profile, isLoading, error, refreshProfile }}>
      {children}
    </UserProfileContext.Provider>
  );
}

/**
 * Hook to access user profile from anywhere in the app
 *
 * Usage:
 * ```tsx
 * const { profile, isLoading, error, refreshProfile } = useUserProfile();
 *
 * if (profile?.ready_to_buy) {
 *   // Show buy listings
 * } else {
 *   // Show rent listings
 * }
 * ```
 */
export function useUserProfile() {
  const context = useContext(UserProfileContext);
  if (context === undefined) {
    throw new Error('useUserProfile must be used within a UserProfileProvider');
  }
  return context;
}

/**
 * Helper hook to get specific profile insights
 */
export function useProfileInsights() {
  const { profile } = useUserProfile();

  return {
    // Financial insights
    hasIncome: profile?.monthly_income !== null,
    monthlyIncome: profile?.monthly_income,
    maxBudget: profile?.max_budget,
    financialCapacity: profile?.financial_capacity,

    // Housing preferences
    budgetRange: profile?.budget_min && profile?.budget_max
      ? { min: profile.budget_min, max: profile.budget_max }
      : null,
    preferredNeighborhoods: profile?.preferred_neighborhoods || [],
    minBedrooms: profile?.min_bedrooms,
    minBathrooms: profile?.min_bathrooms,
    isPetFriendly: profile?.pet_friendly,

    // Current lease
    hasCurrentLease: profile?.current_lease_address !== null,
    leaseEndDate: profile?.current_lease_end_date,
    currentRent: profile?.current_monthly_rent,

    // Pre-approval
    hasPreApproval: profile?.pre_approval_amount !== null,
    preApprovalAmount: profile?.pre_approval_amount,
    readyToBuy: profile?.ready_to_buy || false,

    // Urgency
    urgency: profile?.urgency || 'low',
    isUrgent: profile?.urgency === 'high',

    // Check if profile is complete enough
    isProfileComplete: !!(
      profile?.monthly_income &&
      profile?.max_budget &&
      profile?.budget_min &&
      profile?.budget_max
    ),
  };
}
