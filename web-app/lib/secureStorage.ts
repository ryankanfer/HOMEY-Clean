/**
 * Secure Storage Utility
 *
 * Provides safe localStorage/sessionStorage wrappers that:
 * 1. Prevent storing sensitive PII
 * 2. Auto-expire data
 * 3. Clear on logout
 * 4. Validate data before storage
 */

// List of sensitive fields that should NEVER be stored in localStorage
const SENSITIVE_FIELDS = [
  'ssn',
  'social_security',
  'account_number',
  'routing_number',
  'credit_card',
  'cvv',
  'password',
  'token',
  'api_key',
  'secret',
  'monthly_income',
  'annual_income',
  'salary',
  'bank_balance',
  'credit_score',
];

interface StorageOptions {
  expiresIn?: number; // Expiration in milliseconds
  sensitive?: boolean; // If true, store in sessionStorage instead
}

interface StoredData {
  value: any;
  expiresAt?: number;
}

/**
 * Check if an object contains sensitive data
 */
function containsSensitiveData(data: any, path: string = ''): boolean {
  if (typeof data !== 'object' || data === null) {
    return false;
  }

  for (const key in data) {
    const fullPath = path ? `${path}.${key}` : key;
    const lowerKey = key.toLowerCase();

    // Check if key matches sensitive fields
    if (SENSITIVE_FIELDS.some(field => lowerKey.includes(field))) {
      console.warn(`🚨 Attempted to store sensitive field: ${fullPath}`);
      return true;
    }

    // Recursively check nested objects
    if (typeof data[key] === 'object' && data[key] !== null) {
      if (containsSensitiveData(data[key], fullPath)) {
        return true;
      }
    }
  }

  return false;
}

/**
 * Sanitize data before storage (remove sensitive fields)
 */
function sanitizeData(data: any): any {
  if (typeof data !== 'object' || data === null) {
    return data;
  }

  const sanitized: any = Array.isArray(data) ? [] : {};

  for (const key in data) {
    const lowerKey = key.toLowerCase();

    // Skip sensitive fields
    if (SENSITIVE_FIELDS.some(field => lowerKey.includes(field))) {
      console.warn(`🚨 Removed sensitive field from storage: ${key}`);
      continue;
    }

    // Recursively sanitize nested objects
    if (typeof data[key] === 'object' && data[key] !== null) {
      sanitized[key] = sanitizeData(data[key]);
    } else {
      sanitized[key] = data[key];
    }
  }

  return sanitized;
}

/**
 * Set item in storage with security checks
 */
export function setSecureItem(
  key: string,
  value: any,
  options: StorageOptions = {}
): boolean {
  try {
    // Validate and sanitize data
    const sanitized = sanitizeData(value);

    // Wrap with expiration metadata
    const stored: StoredData = {
      value: sanitized,
      expiresAt: options.expiresIn ? Date.now() + options.expiresIn : undefined,
    };

    const storage = options.sensitive ? sessionStorage : localStorage;
    storage.setItem(key, JSON.stringify(stored));

    return true;
  } catch (error) {
    console.error('Failed to store data:', error);
    return false;
  }
}

/**
 * Get item from storage with expiration check
 */
export function getSecureItem<T = any>(
  key: string,
  options: { sensitive?: boolean } = {}
): T | null {
  try {
    const storage = options.sensitive ? sessionStorage : localStorage;
    const item = storage.getItem(key);

    if (!item) {
      return null;
    }

    const stored: StoredData = JSON.parse(item);

    // Check expiration
    if (stored.expiresAt && Date.now() > stored.expiresAt) {
      storage.removeItem(key);
      return null;
    }

    return stored.value as T;
  } catch (error) {
    console.error('Failed to retrieve data:', error);
    return null;
  }
}

/**
 * Remove item from storage
 */
export function removeSecureItem(key: string, options: { sensitive?: boolean } = {}): void {
  const storage = options.sensitive ? sessionStorage : localStorage;
  storage.removeItem(key);
}

/**
 * Clear all HOMEY-related data from storage
 * Call this on logout
 */
export function clearAllSecureData(): void {
  // Clear all keys starting with 'homey_'
  const keysToRemove: string[] = [];

  // localStorage
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    if (key && key.startsWith('homey_')) {
      keysToRemove.push(key);
    }
  }

  keysToRemove.forEach(key => localStorage.removeItem(key));

  // sessionStorage
  sessionStorage.clear();

  console.log(`🧹 Cleared ${keysToRemove.length} items from storage`);
}

/**
 * Clean up expired items from storage
 */
export function cleanupExpiredData(): void {
  const keysToRemove: string[] = [];

  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    if (!key || !key.startsWith('homey_')) continue;

    try {
      const item = localStorage.getItem(key);
      if (!item) continue;

      const stored: StoredData = JSON.parse(item);
      if (stored.expiresAt && Date.now() > stored.expiresAt) {
        keysToRemove.push(key);
      }
    } catch (error) {
      // Invalid JSON, remove it
      keysToRemove.push(key);
    }
  }

  keysToRemove.forEach(key => localStorage.removeItem(key));

  if (keysToRemove.length > 0) {
    console.log(`🧹 Cleaned up ${keysToRemove.length} expired items`);
  }
}

// Auto-cleanup on page load
if (typeof window !== 'undefined') {
  cleanupExpiredData();
}
