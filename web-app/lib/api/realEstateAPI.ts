// Real Estate Data API Integration
// Supports multiple providers: RapidAPI, Rentcast, Realty Mole

const RAPIDAPI_KEY = process.env.NEXT_PUBLIC_RAPIDAPI_KEY || '';
const RAPIDAPI_HOST = process.env.NEXT_PUBLIC_RAPIDAPI_HOST || 'zillow-com1.p.rapidapi.com';

export interface PropertySearchParams {
  location: string;
  status_type?: 'ForSale' | 'ForRent';
  home_type?: string;
  minPrice?: number;
  maxPrice?: number;
  beds_min?: number;
  baths_min?: number;
  page?: number;
}

export interface RawAPIProperty {
  zpid?: string;
  id?: string;
  address?: string;
  streetAddress?: string;
  city?: string;
  state?: string;
  zipcode?: string;
  price?: number;
  bedrooms?: number;
  bathrooms?: number;
  livingArea?: number;
  sqft?: number;
  propertyType?: string;
  homeType?: string;
  latitude?: number;
  longitude?: number;
  lat?: number;
  lng?: number;
  imgSrc?: string;
  carouselPhotos?: Array<{ url: string }>;
  photos?: string[];
  description?: string;
  listingDateTime?: string;
  daysOnZillow?: number;
}

// Transform API data to our Listing format
export function transformAPIPropertyToListing(apiProperty: RawAPIProperty): any {
  // Extract price from various possible fields
  const price = apiProperty.price ||
                apiProperty.unformattedPrice ||
                (apiProperty.hdpData?.homeInfo?.price) ||
                0;

  // Extract neighborhood from address if city not provided
  const address = apiProperty.streetAddress || apiProperty.address || '';
  let neighborhood = apiProperty.city || '';

  if (!neighborhood && address) {
    // Try to extract neighborhood from address (e.g., "123 Main St, Brooklyn, NY")
    const parts = address.split(',');
    if (parts.length >= 2) {
      neighborhood = parts[parts.length - 2].trim(); // Get second-to-last part (usually the city)
    }
  }

  return {
    // Basic info
    address: address,
    neighborhood: neighborhood,
    price: price,
    bedrooms: apiProperty.bedrooms || 0,
    bathrooms: apiProperty.bathrooms || 0,
    square_footage: apiProperty.livingArea || apiProperty.sqft || apiProperty.area || null,

    // Type
    listing_type: 'rental', // Will be determined by search params
    property_type: (apiProperty.propertyType || apiProperty.homeType || 'apartment').toLowerCase(),

    // Location
    latitude: apiProperty.latitude || apiProperty.lat || 0,
    longitude: apiProperty.longitude || apiProperty.lng || 0,

    // Images
    image_urls: apiProperty.carouselPhotos?.map(p => p.url) ||
                apiProperty.photos ||
                (apiProperty.imgSrc ? [apiProperty.imgSrc] : []),
    thumbnail_url: apiProperty.imgSrc ||
                   apiProperty.carouselPhotos?.[0]?.url ||
                   apiProperty.photos?.[0] || null,

    // Details
    description: apiProperty.description || null,

    // Status
    is_new_to_market: (apiProperty.daysOnZillow || 999) <= 3,
    is_featured: false,
    is_active: true,

    // External reference
    external_id: apiProperty.zpid || apiProperty.id || null,
    source: 'zillow',

    // Defaults
    features: [],
    amenities: [],
    monthly_hoa: 0,
    monthly_maintenance: 0,
    monthly_taxes: 0,
    monthly_insurance: 0,
  };
}

// Fetch properties from RapidAPI Zillow
export async function searchPropertiesRapidAPI(params: PropertySearchParams) {
  if (!RAPIDAPI_KEY) {
    throw new Error('RAPIDAPI_KEY not configured');
  }

  const url = `https://${RAPIDAPI_HOST}/propertyExtendedSearch`;

  const queryParams = new URLSearchParams({
    location: params.location,
    status_type: params.status_type || 'ForRent',
    ...(params.home_type && { home_type: params.home_type }),
    ...(params.minPrice && { minPrice: params.minPrice.toString() }),
    ...(params.maxPrice && { maxPrice: params.maxPrice.toString() }),
    ...(params.beds_min && { beds_min: params.beds_min.toString() }),
    ...(params.baths_min && { baths_min: params.baths_min.toString() }),
    page: (params.page || 1).toString(),
  });

  try {
    const response = await fetch(`${url}?${queryParams}`, {
      method: 'GET',
      headers: {
        'X-RapidAPI-Key': RAPIDAPI_KEY,
        'X-RapidAPI-Host': RAPIDAPI_HOST,
      },
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`API request failed: ${response.status} - ${errorText}`);
    }

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Failed to fetch properties from RapidAPI:', error);
    throw error;
  }
}

// Alternative: Rentcast API (good for rentals)
export async function searchPropertiesRentcast(params: PropertySearchParams) {
  const RENTCAST_KEY = process.env.NEXT_PUBLIC_RENTCAST_KEY || '';

  if (!RENTCAST_KEY) {
    throw new Error('RENTCAST_KEY not configured');
  }

  const url = 'https://api.rentcast.io/v1/listings';

  const queryParams = new URLSearchParams({
    city: params.location,
    ...(params.minPrice && { minPrice: params.minPrice.toString() }),
    ...(params.maxPrice && { maxPrice: params.maxPrice.toString() }),
    ...(params.beds_min && { bedrooms: params.beds_min.toString() }),
    limit: '50',
  });

  try {
    const response = await fetch(`${url}?${queryParams}`, {
      method: 'GET',
      headers: {
        'X-Api-Key': RENTCAST_KEY,
      },
    });

    if (!response.ok) {
      throw new Error(`Rentcast API request failed: ${response.status}`);
    }

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Failed to fetch properties from Rentcast:', error);
    throw error;
  }
}

// Main search function - tries multiple providers
export async function searchRealEstateData(params: PropertySearchParams) {
  // Try RapidAPI first
  if (RAPIDAPI_KEY) {
    try {
      console.log('Fetching from RapidAPI Zillow...');
      const data = await searchPropertiesRapidAPI(params);
      console.log('🔍 Raw API response:', data);

      // Transform results
      const properties = data.props || data.results || data.data || [];
      console.log('📊 Found properties array:', properties.length);

      if (properties.length > 0) {
        console.log('🏠 Sample raw property:', properties[0]);
      }

      const transformed = properties.map(transformAPIPropertyToListing);

      // Filter out listings without prices
      const withPrices = transformed.filter(listing => listing.price > 0);
      console.log(`💰 Filtered to ${withPrices.length} listings with prices (from ${transformed.length} total)`);

      return withPrices;
    } catch (error) {
      console.error('RapidAPI failed, trying alternatives...', error);
    }
  }

  // Fallback to Rentcast
  const RENTCAST_KEY = process.env.NEXT_PUBLIC_RENTCAST_KEY || '';
  if (RENTCAST_KEY) {
    try {
      console.log('Fetching from Rentcast...');
      const data = await searchPropertiesRentcast(params);
      return (data.listings || []).map(transformAPIPropertyToListing);
    } catch (error) {
      console.error('Rentcast failed:', error);
    }
  }

  throw new Error('No API keys configured. Please add NEXT_PUBLIC_RAPIDAPI_KEY or NEXT_PUBLIC_RENTCAST_KEY to .env.local');
}

export default searchRealEstateData;
