//
//  AnimationManager.swift
//  HOMEY Clean
//
//  Animation pooling and lifecycle management system
//

import SwiftUI
import Combine

@MainActor
public final class AnimationManager: ObservableObject {
    public static let shared = AnimationManager()
    
    private var activeAnimations: Set<AnimationToken> = []
    private var animationTimers: [AnimationToken: Timer] = [:]
    private var cancellables: Set<AnyCancellable> = []
    
    private init() {}
    
    // MARK: - Animation Token System
    
    public struct AnimationToken: Hashable, Identifiable {
        public let id = UUID()
        let name: String
        let duration: TimeInterval
        let isRepeating: Bool
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    // MARK: - Animation Registration
    
    /// Register a new animation and get a token for cleanup
    public func registerAnimation(
        name: String,
        duration: TimeInterval,
        isRepeating: Bool = false
    ) -> AnimationToken {
        let token = AnimationToken(
            name: name,
            duration: duration,
            isRepeating: isRepeating
        )
        
        activeAnimations.insert(token)
        
        // Auto-cleanup for non-repeating animations
        if !isRepeating {
            let timer = Timer.scheduledTimer(withTimeInterval: duration + 0.1, repeats: false) { [weak self] _ in
                self?.cleanup(token: token)
            }
            animationTimers[token] = timer
        }
        
        return token
    }
    
    /// Cleanup specific animation
    public func cleanup(token: AnimationToken) {
        activeAnimations.remove(token)
        animationTimers[token]?.invalidate()
        animationTimers.removeValue(forKey: token)
    }
    
    /// Cleanup all animations for a specific view
    public func cleanupAnimations(containing name: String) {
        let tokensToRemove = activeAnimations.filter { $0.name.contains(name) }
        tokensToRemove.forEach { cleanup(token: $0) }
    }
    
    /// Emergency cleanup - stops all animations
    public func cleanupAll() {
        animationTimers.values.forEach { $0.invalidate() }
        animationTimers.removeAll()
        activeAnimations.removeAll()
    }
    
    // MARK: - Animation Helpers
    
    /// Safe animation wrapper with automatic cleanup
    public func withManagedAnimation<Result>(
        _ animation: Animation?,
        name: String,
        duration: TimeInterval = AnimationConstants.medium,
        body: () throws -> Result
    ) rethrows -> Result {
        let token = registerAnimation(name: name, duration: duration)
        
        defer {
            // Cleanup after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                Task { @MainActor in
                    self.cleanup(token: token)
                }
            }
        }
        
        return try withAnimation(animation, body)
    }
    
    /// Safe repeating animation with token for manual cleanup
    public func withRepeatingAnimation<Result>(
        _ animation: Animation,
        name: String,
        body: () throws -> Result
    ) rethrows -> (result: Result, token: AnimationToken) {
        let token = registerAnimation(name: name, duration: 0, isRepeating: true)
        let result = try withAnimation(animation, body)
        return (result, token)
    }
    
    // MARK: - Performance Monitoring
    
    public var activeAnimationCount: Int {
        activeAnimations.count
    }
    
    public var isOverloaded: Bool {
        activeAnimations.count > 10 // Threshold for too many concurrent animations
    }
    
    public func getActiveAnimations() -> [String] {
        activeAnimations.map { $0.name }
    }
}

// MARK: - View Extensions

public extension View {
    /// Managed animation that automatically cleans up
    func withManagedAnimation<V: Equatable>(
        _ animation: Animation?,
        value: V,
        name: String,
        duration: TimeInterval = AnimationConstants.medium
    ) -> some View {
        self.animation(animation, value: value)
            .onDisappear {
                AnimationManager.shared.cleanupAnimations(containing: name)
            }
    }
    
    /// Cleanup animations when view disappears
    func cleanupAnimationsOnDisappear(name: String) -> some View {
        self.onDisappear {
            AnimationManager.shared.cleanupAnimations(containing: name)
        }
    }
}

// MARK: - Timer Extensions

public extension Timer {
    /// Create a managed timer that gets cleaned up automatically
    static func managedTimer(
        withTimeInterval interval: TimeInterval,
        repeats: Bool,
        name: String,
        block: @escaping (Timer) -> Void
    ) -> Timer {
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats, block: block)
        
        // Register with animation manager for cleanup on main actor
        Task { @MainActor in
            let _ = AnimationManager.shared.registerAnimation(
                name: "timer_\(name)",
                duration: repeats ? .infinity : interval,
                isRepeating: repeats
            )
        }
        
        return timer
    }
}