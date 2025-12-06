// Holiday theme configuration
// Update dates each year or set to null to disable

export interface HolidayConfig {
  enabled: boolean;
  startDate: Date | null;
  endDate: Date | null;
  theme: 'winter' | 'christmas' | 'new-year' | null;
}

// Winter/Holiday Season Configuration
export const HOLIDAY_CONFIG: HolidayConfig = {
  enabled: true,
  startDate: new Date('2024-12-01'), // December 1st
  endDate: new Date('2025-01-07'),   // January 7th (after New Year)
  theme: 'winter',
};

/**
 * Check if we're currently in the holiday period
 */
export function isHolidaySeason(): boolean {
  if (!HOLIDAY_CONFIG.enabled) return false;
  if (!HOLIDAY_CONFIG.startDate || !HOLIDAY_CONFIG.endDate) return false;

  const now = new Date();
  return now >= HOLIDAY_CONFIG.startDate && now <= HOLIDAY_CONFIG.endDate;
}

/**
 * Get days until holiday season ends (or null if not in season)
 */
export function daysUntilHolidayEnd(): number | null {
  if (!isHolidaySeason() || !HOLIDAY_CONFIG.endDate) return null;

  const now = new Date();
  const diffTime = HOLIDAY_CONFIG.endDate.getTime() - now.getTime();
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

  return diffDays;
}
