//
//  TRAEMotionSystem.swift
//  HOMEY Clean
//
//  TRAE Motion Design System - Core framework for micro-interactions
//

import SwiftUI
import CoreHaptics

// MARK: - TRAE Motion System Core

public struct TRAEMotionSystem {
    
    // MARK: - Shared Instance
    public static let shared = TRAEMotionSystem()
    
    private init() {}
    
    // MARK: - Animation Definitions
    
    public struct Animations {
        // Avatar animations
        public static let avatarBlink = Animation.easeInOut(duration: 0.15)
        public static let avatarBreathe = Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true)
        public static let avatarPoseShift = Animation.spring(response: 0.8, dampingFraction: 0.7)
        
        // Button animations
        public static let buttonPress = Animation.spring(response: 0.3, dampingFraction: 0.6)
        public static let buttonRelease = Animation.spring(response: 0.4, dampingFraction: 0.8)
        
        // Progress animations
        public static let liquidFill = Animation.easeOut(duration: 1.2)
        public static let progressPulse = Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)
        
        // Upload animations
        public static let documentFlyIn = Animation.spring(response: 0.6, dampingFraction: 0.8)
        public static let vaultReceive = Animation.easeOut(duration: 0.4)
        
        // Carousel animations
        public static let cardFlip = Animation.spring(response: 0.7, dampingFraction: 0.9)
        public static let cardPhysics = Animation.interactiveSpring(response: 0.5, dampingFraction: 0.8)
        
        // Search animations
        public static let lensShimmer = Animation.linear(duration: 1.5).repeatForever(autoreverses: false)
        public static let distortion = Animation.easeInOut(duration: 0.3)
        public static let parallax = Animation.interactiveSpring(response: 0.4, dampingFraction: 0.9)
    }
    
    // MARK: - Haptic Feedback Types
    
    /// Haptic feedback styles for TRAE animations
    public enum TRAEHapticStyle {
        case light
        case medium
        case heavy
        case success
        case warning
        case error
        case custom(intensity: CGFloat, sharpness: CGFloat)
    }
    
    // MARK: - Haptic Feedback
    
    public struct Haptics {
        private static var engine: CHHapticEngine?
        
        public static func initialize() {
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
            
            do {
                engine = try CHHapticEngine()
                try engine?.start()
            } catch {
                print("Haptic engine failed to start: \(error)")
            }
        }
        
        public static func buttonPress() {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
        
        public static func lightTap() {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        
        public static func success() {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
        }
        
        public static func customPattern() {
            guard let engine = engine else { return }
            
            var events = [CHHapticEvent]()
            
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
            events.append(event)
            
            do {
                let pattern = try CHHapticPattern(events: events, parameters: [])
                let player = try engine.makePlayer(with: pattern)
                try player.start(atTime: 0)
            } catch {
                print("Failed to play haptic pattern: \(error)")
            }
        }
        
        /// Trigger haptic feedback based on style
        public static func triggerHaptic(_ style: TRAEHapticStyle) {
            switch style {
            case .light:
                lightTap()
            case .medium:
                buttonPress()
            case .heavy:
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
            case .success:
                success()
            case .warning, .error:
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.warning)
            case .custom(let intensity, let sharpness):
                customPattern()
            }
        }
    }
    
    /// Instance method to trigger haptic feedback
    public func triggerHaptic(_ style: TRAEHapticStyle) {
        Haptics.triggerHaptic(style)
    }
    
    // MARK: - Visual Effects
    
    public struct Effects {
        
        // Glassmorphism effect
        public static func glassmorphism(opacity: Double = 0.1, blur: CGFloat = 20) -> some View {
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(opacity)
                .blur(radius: blur)
        }
        
        // Frosted gradient
        public static func frostedGradient(colors: [Color] = [.white.opacity(0.3), .clear]) -> some View {
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        // Soft shadow
        public static func softShadow(color: Color = .black, radius: CGFloat = 10, x: CGFloat = 0, y: CGFloat = 4) -> some ViewModifier {
            SoftShadowModifier(color: color, radius: radius, x: x, y: y)
        }
        
        // Shimmer effect
        public static func shimmer(angle: Double = 45, speed: Double = 1.5) -> some View {
            ShimmerEffect(angle: angle, speed: speed)
        }
    }
}

// MARK: - Supporting View Modifiers

struct SoftShadowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.1), radius: radius * 0.3, x: x * 0.3, y: y * 0.3)
            .shadow(color: color.opacity(0.2), radius: radius * 0.6, x: x * 0.6, y: y * 0.6)
            .shadow(color: color.opacity(0.3), radius: radius, x: x, y: y)
    }
}

struct ShimmerEffect: View {
    let angle: Double
    let speed: Double
    @State private var phase: Double = 0
    
    var body: some View {
        LinearGradient(
            colors: [
                .clear,
                .white.opacity(0.3),
                .white.opacity(0.6),
                .white.opacity(0.3),
                .clear
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .rotationEffect(.degrees(angle))
        .offset(x: phase)
        .onAppear {
            withAnimation(TRAEMotionSystem.Animations.lensShimmer) {
                phase = 200
            }
        }
    }
}

// MARK: - Extension for Easy Access

public extension View {
    func traeGlass(opacity: Double = 0.1, blur: CGFloat = 20) -> some View {
        self.background(TRAEMotionSystem.Effects.glassmorphism(opacity: opacity, blur: blur))
    }
    
    func traeSoftShadow(color: Color = .black, radius: CGFloat = 10, x: CGFloat = 0, y: CGFloat = 4) -> some View {
        self.modifier(TRAEMotionSystem.Effects.softShadow(color: color, radius: radius, x: x, y: y))
    }
    
    func traeShimmer(angle: Double = 45, speed: Double = 1.5) -> some View {
        self.overlay(TRAEMotionSystem.Effects.shimmer(angle: angle, speed: speed))
    }
}