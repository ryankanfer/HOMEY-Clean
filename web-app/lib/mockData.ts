/**
 * Mock Data Generator for Admin Developer Tools
 * Provides realistic demo data when admin is testing client/agent views
 */

import { getAdminViewMode } from './adminViewMode';

/**
 * Check if we should use mock data
 * Returns true if admin is in client or agent view mode
 */
export function shouldUseMockData(isAdmin: boolean): boolean {
  if (!isAdmin) return false;

  const viewMode = getAdminViewMode();
  return viewMode === 'client' || viewMode === 'agent';
}

/**
 * Mock Client Profile Data
 */
export const mockClientProfile = {
  id: 'mock-client-001',
  email: 'demo.client@homey.test',
  full_name: 'Alex Thompson',
  avatar_url: null,
  user_type: 'buyer',
  onboarding_completed: true,
  primary_location: 'New York, NY',
  budget_min: 2000,
  budget_max: 4500,
  bedrooms: 2,
  bathrooms: 1,
  neighborhoods: ['Chelsea', 'West Village', 'Williamsburg'],
  move_in_date: '2025-03-01',
  created_at: '2024-11-15T00:00:00Z',
};

/**
 * Mock Agent Profile Data
 */
export const mockAgentProfile = {
  id: 'mock-agent-001',
  user_id: 'mock-agent-user-001',
  email: 'demo.agent@homey.test',
  full_name: 'Sarah Martinez',
  avatar_url: null,
  professional_phone: '(555) 123-4567',
  professional_email: 'sarah@premierrealty.com',
  brokerage: 'Premier Realty NYC',
  license_number: 'RE-123456',
  years_experience: 8,
  specialties: ['Luxury Rentals', 'First-time Buyers', 'Investment Properties'],
  bio: 'Experienced NYC real estate agent specializing in Manhattan and Brooklyn properties.',
  created_at: '2023-06-01T00:00:00Z',
};

/**
 * Mock Client Connections (for agents)
 */
export const mockAgentConnections = [
  {
    id: 'conn-001',
    agent_id: 'mock-agent-001',
    client_id: 'client-001',
    status: 'active',
    created_at: '2025-01-15T10:00:00Z',
    client: {
      user: {
        full_name: 'Emily Chen',
        email: 'emily.chen@email.com',
        avatar_url: null,
      }
    }
  },
  {
    id: 'conn-002',
    agent_id: 'mock-agent-001',
    client_id: 'client-002',
    status: 'active',
    created_at: '2025-01-10T14:30:00Z',
    client: {
      user: {
        full_name: 'Marcus Johnson',
        email: 'marcus.j@email.com',
        avatar_url: null,
      }
    }
  },
  {
    id: 'conn-003',
    agent_id: 'mock-agent-001',
    client_id: 'client-003',
    status: 'pending',
    created_at: '2025-01-20T09:15:00Z',
    client: {
      user: {
        full_name: 'Jessica Park',
        email: 'j.park@email.com',
        avatar_url: null,
      }
    }
  },
];

/**
 * Mock Messages (for agents)
 */
export const mockAgentMessages = [
  {
    id: 'msg-001',
    connection_id: 'conn-001',
    sender_type: 'client',
    message: 'Hi Sarah! I loved the apartment you showed me yesterday. Can we schedule another viewing?',
    created_at: '2025-01-22T15:30:00Z',
    read_at: null,
  },
  {
    id: 'msg-002',
    connection_id: 'conn-002',
    sender_type: 'client',
    message: 'What time works for the Chelsea showing tomorrow?',
    created_at: '2025-01-22T11:20:00Z',
    read_at: '2025-01-22T11:25:00Z',
  },
  {
    id: 'msg-003',
    connection_id: 'conn-001',
    sender_type: 'agent',
    message: 'Of course! I have availability tomorrow at 2pm or Thursday at 10am. Which works better?',
    created_at: '2025-01-22T15:45:00Z',
    read_at: null,
  },
];

/**
 * Mock Showings (for agents)
 */
export const mockAgentShowings = [
  {
    id: 'showing-001',
    agent_id: 'mock-agent-001',
    client_id: 'client-001',
    listing_id: 'listing-101',
    status: 'confirmed',
    confirmed_date: '2025-01-24T14:00:00Z',
    created_at: '2025-01-20T10:00:00Z',
  },
  {
    id: 'showing-002',
    agent_id: 'mock-agent-001',
    client_id: 'client-002',
    listing_id: 'listing-102',
    status: 'confirmed',
    confirmed_date: '2025-01-25T10:00:00Z',
    created_at: '2025-01-21T09:00:00Z',
  },
  {
    id: 'showing-003',
    agent_id: 'mock-agent-001',
    client_id: 'client-001',
    listing_id: 'listing-103',
    status: 'pending',
    preferred_date_1: '2025-01-26T15:00:00Z',
    created_at: '2025-01-22T16:00:00Z',
  },
];

/**
 * Mock Saved Properties (for clients)
 */
export const mockSavedProperties = new Set([
  'listing-101',
  'listing-105',
  'listing-108',
  'listing-112',
  'listing-115',
]);

/**
 * Mock Agent Connection (for clients)
 */
export const mockClientAgentConnection = {
  id: 'conn-client-001',
  client_id: 'mock-client-001',
  agent_id: 'agent-001',
  connection_type: 'platform',
  status: 'active',
  created_at: '2025-01-10T10:00:00Z',
  agent: {
    id: 'agent-001',
    user_id: 'user-agent-001',
    email: 'michael@homey.agent',
    full_name: 'Michael Roberts',
    avatar_url: undefined,
    professional_phone: '(555) 987-6543',
    professional_email: 'michael@cityrealty.com',
    brokerage_name: 'City Realty Group',
    license_number: 'RE-987654',
    years_experience: 10,
    specialties: ['Residential', 'Commercial'],
    bio: 'Experienced agent specializing in NYC real estate',
    created_at: '2023-01-01T00:00:00Z',
    user: {
      id: 'user-agent-001',
      full_name: 'Michael Roberts',
      email: 'michael@homey.agent',
      avatar_url: undefined,
    }
  }
};

/**
 * Mock User Preferences
 */
export const mockUserPreferences = {
  location: 'New York, NY',
  budgetMin: 2000,
  budgetMax: 4500,
  bedrooms: 2,
  bathrooms: 1,
  neighborhoods: ['Chelsea', 'West Village', 'Williamsburg'],
  displayName: 'Alex',
};

/**
 * Mock Swipe Stats
 */
export const mockSwipeStats = {
  total: 45,
  likes: 12,
  dislikes: 28,
  neutral: 5,
};

/**
 * Get mock data based on view mode
 */
export function getMockData(dataType: string) {
  switch (dataType) {
    case 'clientProfile':
      return mockClientProfile;
    case 'agentProfile':
      return mockAgentProfile;
    case 'agentConnections':
      return mockAgentConnections;
    case 'agentMessages':
      return mockAgentMessages;
    case 'agentShowings':
      return mockAgentShowings;
    case 'savedProperties':
      return mockSavedProperties;
    case 'clientAgentConnection':
      return mockClientAgentConnection;
    case 'userPreferences':
      return mockUserPreferences;
    case 'swipeStats':
      return mockSwipeStats;
    default:
      return null;
  }
}
