import { useState, useEffect } from 'react';
import { agentDb, auth, db } from '@/lib/supabase';
import { checkAdminFromProfile } from '@/lib/admin';
import { shouldUseMockData, mockClientAgentConnection } from '@/lib/mockData';

interface AgentConnection {
  id: string;
  agent_id: string;
  client_id: string;
  status: string;
  connection_type: string;
  agent: {
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
    total_sales?: number;
    average_rating?: number;
    verified?: boolean;
    accepting_new_clients?: boolean;
    availability_status?: string;
    user?: {
      id: string;
      full_name?: string;
      email?: string;
      avatar_url?: string;
    };
  };
  created_at?: string;
  updated_at?: string;
}

interface UseClientAgentReturn {
  agent: AgentConnection | null;
  hasAgent: boolean;
  loading: boolean;
  error: any;
  refreshAgent: () => Promise<void>;
}

/**
 * Hook for clients to get their connected agent
 * Returns the active agent connection for the current user
 */
export function useClientAgent(): UseClientAgentReturn {
  const [agent, setAgent] = useState<AgentConnection | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<any>(null);

  const fetchClientAgent = async () => {
    try {
      setLoading(true);
      setError(null);

      // Get current user
      const { data: userData, error: userError } = await auth.getUser();

      if (userError) {
        console.error('❌ Error getting user:', userError);
        setAgent(null);
        return;
      }

      if (!userData?.user) {
        console.log('ℹ️ No user found');
        setAgent(null);
        return;
      }

      console.log('✅ User found:', userData.user.id);

      // Check if admin should use mock data
      const { data: profile } = await db.getProfile(userData.user.id);
      const isAdmin = checkAdminFromProfile(profile);

      if (shouldUseMockData(isAdmin)) {
        console.log('🎭 Admin in client view mode - using mock agent connection');
        setAgent(mockClientAgentConnection as AgentConnection);
        setLoading(false);
        return;
      }

      // Get active agent connections for this client
      const { data: connections, error: connectionsError } = await agentDb.getClientConnections(
        userData.user.id,
        'active'
      );

      if (connectionsError) {
        console.error('❌ Error fetching agent connections:', connectionsError);
        throw connectionsError;
      }

      console.log('📊 Agent connections found:', connections?.length || 0);

      // Get the first active connection (clients should only have one)
      if (connections && connections.length > 0) {
        console.log('✅ Active agent connection:', connections[0]);
        setAgent(connections[0]);
      } else {
        console.log('ℹ️ No active agent connections for this user');
        setAgent(null);
      }
    } catch (err) {
      console.error('❌ Error fetching client agent:', err);
      setError(err);
      setAgent(null);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchClientAgent();
  }, []);

  return {
    agent,
    hasAgent: agent !== null,
    loading,
    error,
    refreshAgent: fetchClientAgent,
  };
}
