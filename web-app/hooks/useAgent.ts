import { useState, useEffect } from 'react';
import { agentDb, auth } from '@/lib/supabase';

interface AgentProfile {
  id: string;
  user_id: string;
  license_number?: string;
  license_state?: string;
  brokerage_name?: string;
  brokerage_address?: string;
  years_experience?: number;
  specialties?: string[];
  professional_phone?: string;
  professional_email?: string;
  website_url?: string;
  bio?: string;
  profile_image_url?: string;
  cover_image_url?: string;
  service_neighborhoods?: string[];
  service_zip_codes?: string[];
  service_radius_miles?: number;
  total_sales?: number;
  average_rating?: number;
  verified?: boolean;
  verification_date?: string;
  accepting_new_clients?: boolean;
  auto_respond_enabled?: boolean;
  availability_status?: string;
  created_at?: string;
  updated_at?: string;
}

interface UseAgentReturn {
  isAgent: boolean;
  agentProfile: AgentProfile | null;
  loading: boolean;
  error: any;
  refreshProfile: () => Promise<void>;
}

export function useAgent(): UseAgentReturn {
  const [isAgent, setIsAgent] = useState(false);
  const [agentProfile, setAgentProfile] = useState<AgentProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<any>(null);

  const fetchAgentProfile = async () => {
    try {
      setLoading(true);
      setError(null);

      // Get current user
      const { data: userData, error: userError } = await auth.getUser();

      if (userError || !userData?.user) {
        setIsAgent(false);
        setAgentProfile(null);
        return;
      }

      // Check if user has an agent profile
      const { data: profile, error: profileError } = await agentDb.getAgentProfile(userData.user.id);

      if (profileError && profileError.code !== 'PGRST116') {
        // PGRST116 is "no rows returned", which is expected for non-agents
        throw profileError;
      }

      if (profile) {
        setIsAgent(true);
        setAgentProfile(profile);
      } else {
        setIsAgent(false);
        setAgentProfile(null);
      }
    } catch (err) {
      console.error('Error fetching agent profile:', err);
      setError(err);
      setIsAgent(false);
      setAgentProfile(null);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAgentProfile();
  }, []);

  return {
    isAgent,
    agentProfile,
    loading,
    error,
    refreshProfile: fetchAgentProfile,
  };
}
