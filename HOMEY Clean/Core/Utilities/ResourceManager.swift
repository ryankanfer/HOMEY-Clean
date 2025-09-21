//
//  ResourceManager.swift
//  HOMEY Clean
//
//  Created by Trae AI
//  Resource management with memory monitoring and image caching
//

import SwiftUI
import UIKit
import Combine

/// Manages app resources including memory monitoring and image caching
class ResourceManager: ObservableObject {
    static let shared = ResourceManager()
    
    // MARK: - Memory Monitoring
    
    @Published var memoryUsage: MemoryUsage = MemoryUsage()
    @Published var isMemoryPressureHigh: Bool = false
    
    private var memoryTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Image Caching
    
    private let imageCache = NSCache<NSString, UIImage>()
    private let avatarCache = NSCache<NSString, UIImage>()
    private let backgroundCache = NSCache<NSString, UIImage>()
    
    // MARK: - Configuration
    
    private struct CacheConfig {
        static let maxImageCacheSize: Int = 50 * 1024 * 1024 // 50MB
        static let maxAvatarCacheSize: Int = 10 * 1024 * 1024 // 10MB
        static let maxBackgroundCacheSize: Int = 30 * 1024 * 1024 // 30MB
        static let memoryCheckInterval: TimeInterval = 2.0
        static let memoryPressureThreshold: Double = 0.8 // 80%
    }
    
    private init() {
        setupCaches()
        startMemoryMonitoring()
        setupMemoryPressureHandling()
    }
    
    deinit {
        stopMemoryMonitoring()
    }
    
    // MARK: - Cache Setup
    
    private func setupCaches() {
        // Configure image cache
        imageCache.totalCostLimit = CacheConfig.maxImageCacheSize
        imageCache.countLimit = 100
        
        // Configure avatar cache
        avatarCache.totalCostLimit = CacheConfig.maxAvatarCacheSize
        avatarCache.countLimit = 50
        
        // Configure background cache
        backgroundCache.totalCostLimit = CacheConfig.maxBackgroundCacheSize
        backgroundCache.countLimit = 20
        
        // Set up cache eviction policies
        imageCache.evictsObjectsWithDiscardedContent = true
        avatarCache.evictsObjectsWithDiscardedContent = true
        backgroundCache.evictsObjectsWithDiscardedContent = true
    }
    
    // MARK: - Memory Monitoring
    
    private func startMemoryMonitoring() {
        memoryTimer = Timer.scheduledTimer(withTimeInterval: CacheConfig.memoryCheckInterval, repeats: true) { [weak self] _ in
            self?.updateMemoryUsage()
        }
    }
    
    private func stopMemoryMonitoring() {
        memoryTimer?.invalidate()
        memoryTimer = nil
    }
    
    private func updateMemoryUsage() {
        let usage = getCurrentMemoryUsage()
        
        DispatchQueue.main.async { [weak self] in
            self?.memoryUsage = usage
            self?.isMemoryPressureHigh = usage.pressureLevel > CacheConfig.memoryPressureThreshold
        }
    }
    
    private func getCurrentMemoryUsage() -> MemoryUsage {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard kerr == KERN_SUCCESS else {
            return MemoryUsage()
        }
        
        let usedMemory = Double(info.resident_size)
        let totalMemory = Double(ProcessInfo.processInfo.physicalMemory)
        
        return MemoryUsage(
            usedBytes: Int64(usedMemory),
            totalBytes: Int64(totalMemory),
            pressureLevel: usedMemory / totalMemory
        )
    }
    
    private func setupMemoryPressureHandling() {
        $isMemoryPressureHigh
            .sink { [weak self] isHigh in
                if isHigh {
                    self?.handleMemoryPressure()
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleMemoryPressure() {
        // Clear caches in order of priority
        imageCache.removeAllObjects()
        backgroundCache.removeAllObjects()
        
        // Keep avatars as they're most frequently accessed
        if memoryUsage.pressureLevel > 0.9 {
            avatarCache.removeAllObjects()
        }
        
        // Force garbage collection
        DispatchQueue.global(qos: .utility).async {
            // Trigger memory cleanup
        }
    }
    
    // MARK: - Image Caching API
    
    func cachedImage(for key: String, type: ImageType = .general) -> UIImage? {
        let cache = cacheForType(type)
        return cache.object(forKey: NSString(string: key))
    }
    
    func cacheImage(_ image: UIImage, for key: String, type: ImageType = .general) {
        let cache = cacheForType(type)
        let cost = estimateImageCost(image)
        cache.setObject(image, forKey: NSString(string: key), cost: cost)
    }
    
    func removeImage(for key: String, type: ImageType = .general) {
        let cache = cacheForType(type)
        cache.removeObject(forKey: NSString(string: key))
    }
    
    func clearCache(type: ImageType? = nil) {
        if let type = type {
            cacheForType(type).removeAllObjects()
        } else {
            imageCache.removeAllObjects()
            avatarCache.removeAllObjects()
            backgroundCache.removeAllObjects()
        }
    }
    
    // MARK: - Helper Methods
    
    private func cacheForType(_ type: ImageType) -> NSCache<NSString, UIImage> {
        switch type {
        case .avatar:
            return avatarCache
        case .background:
            return backgroundCache
        case .general:
            return imageCache
        }
    }
    
    private func estimateImageCost(_ image: UIImage) -> Int {
        let bytesPerPixel = 4 // RGBA
        let width = Int(image.size.width * image.scale)
        let height = Int(image.size.height * image.scale)
        return width * height * bytesPerPixel
    }
    
    // MARK: - Public API
    
    func getCacheStats() -> CacheStats {
        return CacheStats(
            imageCacheCount: imageCache.countLimit,
            avatarCacheCount: avatarCache.countLimit,
            backgroundCacheCount: backgroundCache.countLimit,
            totalMemoryUsage: memoryUsage
        )
    }
}

// MARK: - Supporting Types

struct MemoryUsage {
    let usedBytes: Int64
    let totalBytes: Int64
    let pressureLevel: Double
    
    init(usedBytes: Int64 = 0, totalBytes: Int64 = 0, pressureLevel: Double = 0) {
        self.usedBytes = usedBytes
        self.totalBytes = totalBytes
        self.pressureLevel = pressureLevel
    }
    
    var usedMB: Double {
        Double(usedBytes) / (1024 * 1024)
    }
    
    var totalMB: Double {
        Double(totalBytes) / (1024 * 1024)
    }
    
    var formattedUsage: String {
        String(format: "%.1f MB / %.1f MB (%.1f%%)", usedMB, totalMB, pressureLevel * 100)
    }
}

enum ImageType {
    case avatar
    case background
    case general
}

struct CacheStats {
    let imageCacheCount: Int
    let avatarCacheCount: Int
    let backgroundCacheCount: Int
    let totalMemoryUsage: MemoryUsage
}

// MARK: - SwiftUI Integration

struct CachedAsyncImage: View {
    let url: URL?
    let type: ImageType
    let placeholder: AnyView
    
    @StateObject private var resourceManager = ResourceManager.shared
    @State private var image: UIImage?
    @State private var isLoading = false
    
    init<Placeholder: View>(
        url: URL?,
        type: ImageType = .general,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.url = url
        self.type = type
        self.placeholder = AnyView(placeholder())
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            } else if isLoading {
                placeholder
            } else {
                placeholder
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        guard let url = url else { return }
        
        let cacheKey = url.absoluteString
        
        // Check cache first
        if let cachedImage = resourceManager.cachedImage(for: cacheKey, type: type) {
            self.image = cachedImage
            return
        }
        
        // Load from network
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
                
                guard let data = data,
                      error == nil,
                      let loadedImage = UIImage(data: data) else {
                    return
                }
                
                // Cache the image
                resourceManager.cacheImage(loadedImage, for: cacheKey, type: type)
                self.image = loadedImage
            }
        }.resume()
    }
}