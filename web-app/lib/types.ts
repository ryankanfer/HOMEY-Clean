// Database types for HOMEY

export interface Listing {
  id: string;
  address: string;
  neighborhood: string;
  price: number;
  bedrooms: number;
  bathrooms: number;
  square_footage: number | null;
  listing_type: 'sale' | 'rental';
  property_type: 'apartment' | 'condo' | 'townhouse' | 'house' | 'studio' | 'loft' | null;
  latitude: number;
  longitude: number;
  image_urls: string[];
  thumbnail_url: string | null;
  features: string[];
  amenities: string[];
  monthly_hoa: number;
  monthly_maintenance: number;
  monthly_taxes: number;
  monthly_insurance: number;
  sun_hours: number | null;
  noise_level: 'quiet' | 'moderate' | 'busy' | null;
  walk_score: number | null;
  transit_score: number | null;
  school_rating: number | null;
  is_new_to_market: boolean;
  has_open_house: boolean;
  is_featured: boolean;
  is_active: boolean;
  description: string | null;
  available_date: string | null;
  agent_name: string | null;
  agent_phone: string | null;
  agent_email: string | null;
  brokerage_name: string | null;
  brokerage_phone: string | null;
  listing_date: string;
  last_updated: string;
  created_at: string;
  updated_at: string;
  external_id: string | null;
  source: string | null;
}

export interface SavedProperty {
  id: string;
  user_id: string;
  listing_id: string;
  notes: string | null;
  created_at: string;
  updated_at: string;
}

export interface SearchFilters {
  minPrice?: number;
  maxPrice?: number;
  minBedrooms?: number;
  minBathrooms?: number;
  listingType?: 'sale' | 'rental';
  propertyType?: string;
  neighborhood?: string;
  features?: string[];
  maxResults?: number;
}

export interface Profile {
  id: string;
  email: string;
  first_name: string | null;
  last_name: string | null;
  role: 'client' | 'agent' | 'admin';
  company_name: string | null;
  phone: string | null;
  profile_complete: boolean;
  onboarding_complete: boolean;
  status: 'active' | 'inactive' | 'pending' | 'suspended';
  metadata: Record<string, any>;
  created_at: string;
  updated_at: string;
}
