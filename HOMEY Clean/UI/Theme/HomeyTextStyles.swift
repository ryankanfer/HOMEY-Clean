//
//  HomeyTextStyles.swift
//  HOMEY Clean
//
//  Created by Trae AI
//  Global text styles for the HOMEY design system
//

import SwiftUI

/// Global text styles for the HOMEY design system
@available(*, deprecated, message: "Use the centralized TypographySystem and .homeyFont() modifier instead.")
struct HomeyTextStyles {
    
    // MARK: - Font Mappings
    
    /// Title style - Josefin Sans Bold
    static let title = Font.custom("JosefinSans-Bold", size: 28)
        .weight(.bold)
    
    /// Subtitle style - Josefin Sans Regular
    static let subtitle = Font.custom("JosefinSans-Regular", size: 20)
        .weight(.regular)
    
    /// Body style - Playfair Display Regular
    static let body = Font.custom("PlayfairDisplay-Regular", size: 16)
        .weight(.regular)
    
    /// Caption style - Playfair Display Italic
    static let caption = Font.custom("PlayfairDisplay-Italic", size: 14)
        .weight(.regular)
    
    /// Stat style - Josefin Sans Semibold
    static let stat = Font.custom("JosefinSans-SemiBold", size: 18)
        .weight(.semibold)
}

// MARK: - Text Style Enum

/// Enumeration of available Homey text styles
@available(*, deprecated, message: "Use the centralized TypographySystem and the HomeyFont enum instead.")
enum HomeyTextStyle {
    case title
    case subtitle
    case body
    case caption
    case stat
    
    var font: Font {
        switch self {
        case .title:
            return HomeyTextStyles.title
        case .subtitle:
            return HomeyTextStyles.subtitle
        case .body:
            return HomeyTextStyles.body
        case .caption:
            return HomeyTextStyles.caption
        case .stat:
            return HomeyTextStyles.stat
        }
    }
    
    var defaultColor: Color {
        switch self {
        case .title, .subtitle:
            return .semanticTextPrimary
        case .body:
            return .semanticTextPrimary
        case .caption:
            return Color.semantic(light: SemanticColors.Text.secondary, dark: SemanticColors.Dark.Text.secondary)
        case .stat:
            return .semanticTextPrimary
        }
    }
}

// MARK: - View Extensions

extension View {
    
    /// Apply a Homey text style to the view
    /// - Parameters:
    ///   - style: The HomeyTextStyle to apply
    ///   - color: Optional color override
    /// - Returns: Modified view with the applied text style
    @available(*, deprecated, message: "Use .homeyFont() with a HomeyFont case instead.")
    func homeyTextStyle(_ style: HomeyTextStyle, color: Color? = nil) -> some View {
        self
            .font(style.font)
            .foregroundColor(color ?? style.defaultColor)
    }
    
    /// Apply title text style
    @available(*, deprecated, message: "Use .homeyFont(.h1) instead.")
    func titleText(color: Color? = nil) -> some View {
        homeyTextStyle(.title, color: color)
    }
    
    /// Apply subtitle text style
    func subtitleText(color: Color? = nil) -> some View {
        homeyTextStyle(.subtitle, color: color)
    }
    
    /// Apply body text style
    @available(*, deprecated, message: "Use .homeyFont(.body) instead.")
    func bodyText(color: Color? = nil) -> some View {
        homeyTextStyle(.body, color: color)
    }
    
    /// Apply caption text style
    func captionText(color: Color? = nil) -> some View {
        homeyTextStyle(.caption, color: color)
    }
    
    /// Apply stat text style
    @available(*, deprecated, message: "Use .homeyFont(.body) with a specific color instead.")
    func statText(color: Color? = nil) -> some View {
        homeyTextStyle(.stat, color: color)
    }
}