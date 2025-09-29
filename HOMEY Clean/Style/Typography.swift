//
//  Typography.swift
//  HOMEY Clean
//
//  Enhanced typography system using Playfair Display app-wide
//  with Josefin Sans for UI elements
//

import SwiftUI

/// Comprehensive typography system for HOMEY Clean
enum Typography {
    
    // MARK: - Display & Titles (Playfair Display)
    static let hero = Font.custom("PlayfairDisplay-Bold", size: 48)
        .weight(.bold)
    
    static let title = Font.custom("PlayfairDisplay-Bold", size: 32)
        .weight(.bold)
    
    static let titleMedium = Font.custom("PlayfairDisplay-SemiBold", size: 28)
        .weight(.semibold)
    
    static let subtitle = Font.custom("PlayfairDisplay-Medium", size: 24)
        .weight(.medium)
    
    static let heading = Font.custom("PlayfairDisplay-SemiBold", size: 20)
        .weight(.semibold)
    
    // MARK: - Body Text (Playfair Display)
    static let bodyLarge = Font.custom("PlayfairDisplay-Regular", size: 18)
        .weight(.regular)
    
    static let body = Font.custom("PlayfairDisplay-Regular", size: 16)
        .weight(.regular)
    
    static let bodyMedium = Font.custom("PlayfairDisplay-Medium", size: 16)
        .weight(.medium)
    
    static let bodySmall = Font.custom("PlayfairDisplay-Regular", size: 14)
        .weight(.regular)
    
    static let caption = Font.custom("PlayfairDisplay-Regular", size: 12)
        .weight(.regular)
    
    // MARK: - UI Elements (Josefin Sans for consistency)
    static let button = Font.custom("JosefinSans-SemiBold", size: 16)
        .weight(.semibold)
    
    static let buttonLarge = Font.custom("JosefinSans-SemiBold", size: 18)
        .weight(.semibold)
    
    static let buttonSmall = Font.custom("JosefinSans-Medium", size: 14)
        .weight(.medium)
    
    static let navigation = Font.custom("JosefinSans-Medium", size: 16)
        .weight(.medium)
    
    static let tabBar = Font.custom("JosefinSans-Regular", size: 12)
        .weight(.regular)
    
    static let label = Font.custom("JosefinSans-Medium", size: 14)
        .weight(.medium)
    
    // MARK: - Specialized
    static let quote = Font.custom("PlayfairDisplay-Italic", size: 18)
        .weight(.regular)
    
    static let emphasis = Font.custom("PlayfairDisplay-Italic", size: 16)
        .weight(.regular)
    
    static let numeric = Font.custom("JosefinSans-Medium", size: 16)
        .weight(.medium)
        .monospacedDigit()
}

// MARK: - Typography Extensions for SwiftUI
extension Text {
    func homeyHero() -> Text {
        self.font(Typography.hero)
    }
    
    func homeyTitle() -> Text {
        self.font(Typography.title)
    }
    
    func homeySubtitle() -> Text {
        self.font(Typography.subtitle)
    }
    
    func homeyHeading() -> Text {
        self.font(Typography.heading)
    }
    
    func homeyBody() -> Text {
        self.font(Typography.body)
    }
    
    func homeyBodyLarge() -> Text {
        self.font(Typography.bodyLarge)
    }
    
    func homeyCaption() -> Text {
        self.font(Typography.caption)
    }
    
    func homeyButton() -> Text {
        self.font(Typography.button)
    }
    
    func homeyNavigation() -> Text {
        self.font(Typography.navigation)
    }
}
