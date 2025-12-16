import Foundation
import Combine

// MARK: - Cache Manager Protocol

protocol CacheManagerProtocol {
    func get<T: Codable>(_ key: String, type: T.Type) -> T?
    func set<T: Codable>(_ value: T, forKey key: String, expiration: TimeInterval?)
    func remove(_ key: String)
    func clear()
    func isExpired(_ key: String) -> Bool
}

// MARK: - Cache Entry

private struct CacheEntry<T: Codable>: Codable {
    let value: T
    let timestamp: Date
    let expiration: TimeInterval?
    
    var isExpired: Bool {
        guard let expiration = expiration else { return false }
        return Date().timeIntervalSince(timestamp) > expiration
    }
}

// MARK: - Cache Manager Implementation

class CacheManager: CacheManagerProtocol {
    static let shared = CacheManager()
    
    private let userDefaults: UserDefaults
    private let keyPrefix: String
    private let queue = DispatchQueue(label: "com.homey.cache", qos: .utility)
    
    // Default cache durations
    struct CacheDuration {
        static let short: TimeInterval = 5 * 60 // 5 minutes
        static let medium: TimeInterval = 30 * 60 // 30 minutes
        static let long: TimeInterval = 2 * 60 * 60 // 2 hours
        static let veryLong: TimeInterval = 24 * 60 * 60 // 24 hours
    }
    
    init(userDefaults: UserDefaults = .standard, keyPrefix: String = "HomeyCache_") {
        self.userDefaults = userDefaults
        self.keyPrefix = keyPrefix
        
        // Clean up expired entries on initialization
        cleanupExpiredEntries()
    }
    
    func get<T: Codable>(_ key: String, type: T.Type) -> T? {
        return queue.sync {
            let fullKey = keyPrefix + key
            
            guard let data = userDefaults.data(forKey: fullKey) else {
                return nil
            }
            
            do {
                let entry = try JSONDecoder().decode(CacheEntry<T>.self, from: data)
                
                if entry.isExpired {
                    userDefaults.removeObject(forKey: fullKey)
                    return nil
                }
                
                return entry.value
            } catch {
                // If decoding fails, remove the corrupted entry
                userDefaults.removeObject(forKey: fullKey)
                return nil
            }
        }
    }
    
    func set<T: Codable>(_ value: T, forKey key: String, expiration: TimeInterval? = nil) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let fullKey = self.keyPrefix + key
            let entry = CacheEntry(value: value, timestamp: Date(), expiration: expiration)
            
            do {
                let data = try JSONEncoder().encode(entry)
                self.userDefaults.set(data, forKey: fullKey)
            } catch {
                print("CacheManager: Failed to encode value for key \(key): \(error)")
            }
        }
    }
    
    func remove(_ key: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let fullKey = self.keyPrefix + key
            self.userDefaults.removeObject(forKey: fullKey)
        }
    }
    
    func clear() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let keys = self.userDefaults.dictionaryRepresentation().keys
            for key in keys {
                if key.hasPrefix(self.keyPrefix) {
                    self.userDefaults.removeObject(forKey: key)
                }
            }
        }
    }
    
    func isExpired(_ key: String) -> Bool {
        return queue.sync {
            let fullKey = keyPrefix + key
            
            guard let data = userDefaults.data(forKey: fullKey) else {
                return true
            }
            
            do {
                let entry = try JSONDecoder().decode(CacheEntry<Data>.self, from: data)
                return entry.isExpired
            } catch {
                return true
            }
        }
    }
    
    private func cleanupExpiredEntries() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let keys = self.userDefaults.dictionaryRepresentation().keys
            let expiredKeys = keys.filter { key in
                guard key.hasPrefix(self.keyPrefix) else { return false }
                let cacheKey = String(key.dropFirst(self.keyPrefix.count))
                return self.isExpired(cacheKey)
            }
            
            for key in expiredKeys {
                self.userDefaults.removeObject(forKey: key)
            }
        }
    }
}

// MARK: - Cache Keys

extension CacheManager {
    struct Keys {
        // Scout cache keys
        static let propertyListings = "scout_property_listings"
        static let neighborhoodData = "scout_neighborhood_data"
        static let shortlistedProperties = "scout_shortlisted_properties"
        static let searchFilters = "scout_search_filters"
        static let userLocation = "scout_user_location"
        
        // Isla cache keys
        static let marketData = "isla_market_data"
        static let analyticsData = "isla_analytics_data"
        static let tickerData = "isla_ticker_data"
        static let portfolioData = "isla_portfolio_data"
        
        // Helper methods
        static func propertyListings(for searchParams: String) -> String {
            return "\(propertyListings)_\(searchParams.hash)"
        }
        
        static func neighborhoodData(for location: String) -> String {
            return "\(neighborhoodData)_\(location.hash)"
        }
    }
}

// MARK: - Mock Cache Manager for Testing

class MockCacheManager: CacheManagerProtocol {
    private var storage: [String: Any] = [:]
    private var timestamps: [String: Date] = [:]
    private var expirations: [String: TimeInterval] = [:]
    
    func get<T: Codable>(_ key: String, type: T.Type) -> T? {
        guard let value = storage[key] else { return nil }
        
        // Check expiration
        if let expiration = expirations[key],
           let timestamp = timestamps[key],
           Date().timeIntervalSince(timestamp) > expiration {
            remove(key)
            return nil
        }
        
        return value as? T
    }
    
    func set<T: Codable>(_ value: T, forKey key: String, expiration: TimeInterval? = nil) {
        storage[key] = value
        timestamps[key] = Date()
        if let expiration = expiration {
            expirations[key] = expiration
        }
    }
    
    func remove(_ key: String) {
        storage.removeValue(forKey: key)
        timestamps.removeValue(forKey: key)
        expirations.removeValue(forKey: key)
    }
    
    func clear() {
        storage.removeAll()
        timestamps.removeAll()
        expirations.removeAll()
    }
    
    func isExpired(_ key: String) -> Bool {
        guard let expiration = expirations[key],
              let timestamp = timestamps[key] else {
            return storage[key] == nil
        }
        
        return Date().timeIntervalSince(timestamp) > expiration
    }
}

// MARK: - Extensions

extension String {
    var hash: Int {
        return self.hashValue
    }
}