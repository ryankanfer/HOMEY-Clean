import type { SavedLocation, CommuteInfo } from './types';

/**
 * Calculate distance between two points using Haversine formula
 * Returns distance in miles
 */
export function calculateDistance(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 3959; // Earth's radius in miles
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) *
      Math.cos(toRad(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const distance = R * c;

  return distance;
}

function toRad(degrees: number): number {
  return (degrees * Math.PI) / 180;
}

/**
 * Estimate commute time based on distance and mode of transport
 * Returns time in minutes
 */
export function estimateCommuteTime(
  distanceInMiles: number,
  mode: 'walk' | 'bike' | 'transit' | 'drive'
): number {
  // Average speeds in mph
  const speeds = {
    walk: 3, // 3 mph
    bike: 12, // 12 mph
    transit: 15, // 15 mph (accounting for stops)
    drive: 25, // 25 mph (accounting for city traffic)
  };

  const timeInHours = distanceInMiles / speeds[mode];
  const timeInMinutes = Math.round(timeInHours * 60);

  return timeInMinutes;
}

/**
 * Get the best commute mode based on distance
 */
export function getBestCommuteMode(
  distanceInMiles: number
): 'walk' | 'bike' | 'transit' | 'drive' {
  if (distanceInMiles < 0.5) return 'walk';
  if (distanceInMiles < 2) return 'bike';
  if (distanceInMiles < 5) return 'transit';
  return 'drive';
}

/**
 * Get icon for location type
 */
export function getLocationIcon(type: string): string {
  const icons: Record<string, string> = {
    work: '💼',
    gym: '💪',
    favorite: '⭐',
    school: '🎓',
    custom: '📍',
  };

  return icons[type] || '📍';
}

/**
 * Get icon for commute mode
 */
export function getCommuteIcon(mode: 'walk' | 'bike' | 'transit' | 'drive'): string {
  const icons = {
    walk: '🚶',
    bike: '🚲',
    transit: '🚇',
    drive: '🚗',
  };

  return icons[mode];
}

/**
 * Calculate commute info for a listing from all saved locations
 * Returns the closest/fastest location
 */
export function calculateCommutes(
  listingLat: number,
  listingLon: number,
  savedLocations: SavedLocation[]
): CommuteInfo[] {
  if (!savedLocations || savedLocations.length === 0) {
    return [];
  }

  const commutes = savedLocations.map((location) => {
    const distance = calculateDistance(
      listingLat,
      listingLon,
      location.latitude,
      location.longitude
    );

    const mode = getBestCommuteMode(distance);
    const duration = estimateCommuteTime(distance, mode);

    return {
      locationName: location.name,
      locationType: location.type,
      distance: Math.round(distance * 10) / 10, // Round to 1 decimal
      duration,
      mode,
      icon: getCommuteIcon(mode),
    };
  });

  // Sort by duration (fastest first)
  return commutes.sort((a, b) => a.duration - b.duration);
}

/**
 * Get the primary commute (usually work, or the closest location)
 */
export function getPrimaryCommute(commutes: CommuteInfo[]): CommuteInfo | null {
  if (commutes.length === 0) return null;

  // Prioritize work location
  const workCommute = commutes.find((c) => c.locationType === 'work');
  if (workCommute) return workCommute;

  // Otherwise return the fastest commute
  return commutes[0];
}

/**
 * Format commute time for display
 * Examples: "5m", "23m", "1h 15m"
 */
export function formatCommuteTime(minutes: number): string {
  if (minutes < 60) {
    return `${minutes}m`;
  }

  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;

  if (mins === 0) {
    return `${hours}h`;
  }

  return `${hours}h ${mins}m`;
}

/**
 * Get demo saved locations for testing
 */
export function getDemoSavedLocations(): SavedLocation[] {
  return [
    {
      id: '1',
      name: 'Work',
      type: 'work',
      address: '123 Tech Street, San Francisco, CA',
      latitude: 37.7749,
      longitude: -122.4194,
      icon: '💼',
    },
    {
      id: '2',
      name: 'Equinox Gym',
      type: 'gym',
      address: '456 Fitness Ave, San Francisco, CA',
      latitude: 37.7849,
      longitude: -122.4094,
      icon: '💪',
    },
    {
      id: '3',
      name: 'Blue Bottle Coffee',
      type: 'favorite',
      address: '789 Coffee Lane, San Francisco, CA',
      latitude: 37.7649,
      longitude: -122.4294,
      icon: '☕',
    },
  ];
}
