//
//  TypographySystem.swift
//  HOMEY Clean
//
//  Created by Trae AI
//  Consolidated, official typography system for the HOMEY brand.
//  PRIMARY FONT: Josefin Sans (Body, UI, captions)
//  SECONDARY FONT: Playfair Display (Headings, titles, emphasis)
//

import SwiftUI

/// The official, consolidated typography system for the HOMEY app.
/// This struct provides a consistent and hierarchical set of font styles.
struct TypographySystem {
    
    // MARK: - Font Family Definitions
    
    /// Defines the font names for the primary font family, Josefin Sans.
    struct JosefinSans {
        static let thin = "JosefinSans-Thin"
        static let regular = "JosefinSans-Regular"
        static let bold = "JosefinSans-Bold"
    }
    
    /// Defines the font names for the secondary font family, Playfair Display.
    struct PlayfairDisplay {
        static let regular = "PlayfairDisplay-Regular"
        static let black = "PlayfairDisplay-Black"
    }
    
    // MARK: - Modular Scale for Font Sizes
    
    /// A consistent, scalable set of font sizes.
    struct Scale {
        static let xs: CGFloat = 12
        static let sm: CGFloat = 14
        static let base: CGFloat = 16
        static let lg: CGFloat = 18
        static let xl: CGFloat = 20
        static let xl2: CGFloat = 24
        static let xl3: CGFloat = 30
        static let xl4: CGFloat = 36
        static let xl5: CGFloat = 48
        static let xl6: CGFloat = 60
    }
    
    // MARK: - Heading Styles (Playfair Display)
    
    /// Styles for headings, using the secondary font for a sophisticated look.
    struct Headings {
        /// `hero`: For primary, impactful marketing titles.
        static let hero = Font.custom(PlayfairDisplay.black, size: Scale.xl6)
        
        /// `h1`: For main page titles.
        static let h1 = Font.custom(PlayfairDisplay.black, size: Scale.xl5)
        
        /// `h2`: For section titles.
        static let h2 = Font.custom(PlayfairDisplay.regular, size: Scale.xl4)
        
        /// `h3`: For subsection titles.
        static let h3 = Font.custom(PlayfairDisplay.regular, size: Scale.xl3)
    }
    
    // MARK: - Body & UI Styles (Josefin Sans)
    
    /// Styles for all body copy and standard interface elements, using the primary font for readability.
    struct BodyAndUI {
        /// `body`: The standard text style for all paragraphs and long-form content.
        static let body = Font.custom(JosefinSans.regular, size: Scale.base)
        
        /// `bodyThin`: A lighter version of the body text for less emphasis.
        static let bodyThin = Font.custom(JosefinSans.thin, size: Scale.base)
        
        /// `button`: The standard style for text inside buttons.
        static let button = Font.custom(JosefinSans.bold, size: Scale.base)
        
        /// `caption`: For small, descriptive text, often used below images or in sidebars.
        static let caption = Font.custom(JosefinSans.thin, size: Scale.sm)
        
        /// `label`: For form labels and other descriptive UI elements.
        static let label = Font.custom(JosefinSans.regular, size: Scale.sm)
    }
    
    // MARK: - Static Members for Legacy Compatibility
    
    /// Legacy compatibility static members that map to the nested structure
    static let hero = Headings.hero
    static let title = Headings.h1  // Map title to h1
    static let titleMedium = Headings.h2  // Map titleMedium to h2
    static let title3 = Font.custom(PlayfairDisplay.regular, size: Scale.xl2)
    static let subtitle = Headings.h3  // Map subtitle to h3
    static let heading = Headings.h2  // Map heading to h2
    static let headline = Font.custom(JosefinSans.bold, size: Scale.lg)
    static let subheadline = Font.custom(JosefinSans.regular, size: Scale.base)
    
    static let bodyLarge = Font.custom(JosefinSans.regular, size: Scale.lg)
    static let body = BodyAndUI.body
    static let bodyMedium = BodyAndUI.body  // Same as body for now
    static let bodySmall = Font.custom(JosefinSans.regular, size: Scale.sm)
    
    static let caption = BodyAndUI.caption
    static let caption2 = Font.custom(JosefinSans.thin, size: Scale.xs)
    static let button = BodyAndUI.button
    static let buttonLarge = Font.custom(JosefinSans.bold, size: Scale.lg)
    static let buttonSmall = Font.custom(JosefinSans.bold, size: Scale.sm)
    
    static let navigation = Font.custom(JosefinSans.bold, size: Scale.base)
    static let tabBar = Font.custom(JosefinSans.regular, size: Scale.sm)
    static let label = BodyAndUI.label
    
    static let quote = Font.custom(PlayfairDisplay.regular, size: Scale.lg)
    static let emphasis = Font.custom(JosefinSans.bold, size: Scale.base)
    static let numeric = Font.custom(JosefinSans.regular, size: Scale.base)
}

// MARK: - View+Typography Extension

/// A View extension to simplify the application of the official HOMEY typography.
extension View {
    
    /// Applies a specific font style from the HOMEY typography system.
    /// - Parameter style: The `HomeyFont` style to apply.
    /// - Returns: A view with the specified font style applied.
    func homeyFont(_ style: HomeyFont) -> some View {
        self.font(style.font)
    }
}

/// An enumeration of all available font styles in the HOMEY design system.
/// This provides a clean, readable API for applying text styles.
enum HomeyFont {
    // Headings
    case hero
    case h1
    case h2
    case h3
    case heading
    case title
    case title3
    case largeTitle
    case headline
    case subheadline
    
    // Body and UI
    case body
    case bodyLarge
    case bodyMedium
    case bodyThin
    case button
    case caption
    case caption2
    case label
    
    /// Computed property that returns the appropriate Font for each case.
    var font: Font {
        switch self {
        case .hero:
            return TypographySystem.Headings.hero
        case .h1:
            return TypographySystem.Headings.h1
        case .h2:
            return TypographySystem.Headings.h2
        case .h3:
            return TypographySystem.Headings.h3
        case .heading:
            return TypographySystem.heading
        case .title:
            return TypographySystem.title
        case .title3:
            return TypographySystem.title3
        case .largeTitle:
            return TypographySystem.hero
        case .headline:
            return TypographySystem.headline
        case .subheadline:
            return TypographySystem.subheadline
        case .body:
            return TypographySystem.BodyAndUI.body
        case .bodyLarge:
            return TypographySystem.bodyLarge
        case .bodyMedium:
            return TypographySystem.bodyMedium
        case .bodyThin:
            return TypographySystem.BodyAndUI.bodyThin
        case .button:
            return TypographySystem.BodyAndUI.button
        case .caption:
            return TypographySystem.BodyAndUI.caption
        case .caption2:
            return TypographySystem.caption2
        case .label:
            return TypographySystem.BodyAndUI.label
        }
    }
}