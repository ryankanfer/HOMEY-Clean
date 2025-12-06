// Predefined neighborhoods for The Pulse
// Update this list based on your target city/region

export const NEIGHBORHOODS = [
  // Manhattan
  'Chelsea',
  'East Village',
  'Greenwich Village',
  'Harlem',
  'Hell\'s Kitchen',
  'Lower East Side',
  'Midtown',
  'SoHo',
  'Tribeca',
  'Upper East Side',
  'Upper West Side',
  'West Village',
  'Financial District',
  'Murray Hill',
  'Gramercy',
  'Flatiron',

  // Brooklyn
  'Williamsburg',
  'Brooklyn Heights',
  'Park Slope',
  'DUMBO',
  'Fort Greene',
  'Bushwick',
  'Greenpoint',
  'Carroll Gardens',
  'Cobble Hill',
  'Prospect Heights',
  'Bedford-Stuyvesant',
  'Crown Heights',
  'Red Hook',

  // Queens
  'Astoria',
  'Long Island City',
  'Flushing',
  'Forest Hills',
  'Sunnyside',
  'Jackson Heights',

  // Bronx
  'Riverdale',
  'Fordham',
  'Belmont',

  // Staten Island
  'St. George',
  'Tompkinsville',
].sort();

export function searchNeighborhoods(query: string, limit = 5): string[] {
  if (!query) return [];

  const lowerQuery = query.toLowerCase();

  return NEIGHBORHOODS
    .filter(hood => hood.toLowerCase().includes(lowerQuery))
    .slice(0, limit);
}
