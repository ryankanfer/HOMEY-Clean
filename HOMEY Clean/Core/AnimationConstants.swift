//
//  AnimationConstants.swift
//  HOMEY Clean
//
//  Animation timing constants for consistent UX
//

import SwiftUI

public struct AnimationConstants {
    // MARK: - Standard Durations
    
    /// Quick interactions (0.25s) - button presses, toggles, micro-interactions
    public static let quick: TimeInterval = 0.25
    
    /// Medium transitions (0.5s) - page transitions, modal presentations
    public static let medium: TimeInterval = 0.5
    
    /// Ambient animations (1.2s) - background effects, breathing animations
    public static let ambient: TimeInterval = 1.2
    
    /// Extended animations (2.4s) - complex state changes, onboarding
    public static let extended: TimeInterval = 2.4
    
    // MARK: - Standard Animation Curves
    
    /// Quick spring animation for micro-interactions
    public static let quickSpring = Animation.spring(response: quick, dampingFraction: 0.8)
    
    /// Medium spring animation for transitions
    public static let mediumSpring = Animation.spring(response: medium, dampingFraction: 0.9)
    
    /// Ambient spring animation for background effects
    public static let ambientSpring = Animation.spring(response: ambient, dampingFraction: 0.95)
    
    /// Quick ease-in-out for standard interactions
    public static let quickEase = Animation.easeInOut(duration: quick)
    
    /// Medium ease-in-out for transitions
    public static let mediumEase = Animation.easeInOut(duration: medium)
    
    /// Ambient ease-in-out for background effects
    public static let ambientEase = Animation.easeInOut(duration: ambient)
    
    /// Linear animation for continuous motion
    public static func linear(duration: TimeInterval) -> Animation {
        Animation.linear(duration: duration)
    }
    
    // MARK: - Accessibility Support
    
    /// Returns appropriate animation based on accessibility settings
    public static func accessible(_ animation: Animation) -> Animation? {
        return UIAccessibility.isReduceMotionEnabled ? nil : animation
    }
    
    /// Returns appropriate animation with custom reduceMotion override
    public static func accessible(_ animation: Animation, reduceMotion: Bool) -> Animation? {
        return reduceMotion ? nil : animation
    }
    
    /// Cross-fade animation for accessibility
    public static let crossFade = Animation.easeInOut(duration: quick)
}

// MARK: - Animation Extensions

public extension Animation {
    /// Quick animation shorthand
    static var quick: Animation { AnimationConstants.quickEase }
    
    /// Medium animation shorthand
    static var medium: Animation { AnimationConstants.mediumEase }
    
    /// Ambient animation shorthand
    static var ambient: Animation { AnimationConstants.ambientEase }
}