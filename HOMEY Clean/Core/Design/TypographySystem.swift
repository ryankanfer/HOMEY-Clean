//
//  TypographySystem.swift
//  HOMEY Clean
//
//  Created by Trae AI
//  Comprehensive typography system with Josefin Sans and Playfair fonts
//

import SwiftUI

/// Typography system providing consistent font hierarchy and styling
struct TypographySystem {
    
    // MARK: - Font Families
    
    /// Josefin Sans - Modern sans-serif for titles and headings
    struct JosefinSans {
        static let thin = "JosefinSans-Thin"
        static let extraLight = "JosefinSans-ExtraLight"
        static let light = "JosefinSans-Light"
        static let regular = "JosefinSans-Regular"
        static let medium = "JosefinSans-Medium"
        static let semiBold = "JosefinSans-SemiBold"
        static let bold = "JosefinSans-Bold"
        static let extraBold = "JosefinSans-ExtraBold"
        
        static let thinItalic = "JosefinSans-ThinItalic"
        static let extraLightItalic = "JosefinSans-ExtraLightItalic"
        static let lightItalic = "JosefinSans-LightItalic"
        static let italic = "JosefinSans-Italic"
        static let mediumItalic = "JosefinSans-MediumItalic"
        static let semiBoldItalic = "JosefinSans-SemiBoldItalic"
        static let boldItalic = "JosefinSans-BoldItalic"
        static let extraBoldItalic = "JosefinSans-ExtraBoldItalic"
    }
    
    /// Playfair Display - Elegant serif for body text and emphasis
    struct PlayfairDisplay {
        static let regular = "PlayfairDisplay-Regular"
        static let medium = "PlayfairDisplay-Medium"
        static let semiBold = "PlayfairDisplay-SemiBold"
        static let bold = "PlayfairDisplay-Bold"
        static let extraBold = "PlayfairDisplay-ExtraBold"
        static let black = "PlayfairDisplay-Black"
        
        static let italic = "PlayfairDisplay-Italic"
        static let mediumItalic = "PlayfairDisplay-MediumItalic"
        static let semiBoldItalic = "PlayfairDisplay-SemiBoldItalic"
        static let boldItalic = "PlayfairDisplay-BoldItalic"
        static let extraBoldItalic = "PlayfairDisplay-ExtraBoldItalic"
        static let blackItalic = "PlayfairDisplay-BlackItalic"
    }
    
    // MARK: - Typography Scale
    
    /// Font sizes following a modular scale (1.25 ratio)
    struct Scale {
        static let xs: CGFloat = 12      // 0.75rem
        static let sm: CGFloat = 14      // 0.875rem
        static let base: CGFloat = 16    // 1rem
        static let lg: CGFloat = 18      // 1.125rem
        static let xl: CGFloat = 20      // 1.25rem
        static let xl2: CGFloat = 24     // 1.5rem
        static let xl3: CGFloat = 30     // 1.875rem
        static let xl4: CGFloat = 36     // 2.25rem
        static let xl5: CGFloat = 48     // 3rem
        static let xl6: CGFloat = 60     // 3.75rem
        static let xl7: CGFloat = 72     // 4.5rem
        static let xl8: CGFloat = 96     // 6rem
        static let xl9: CGFloat = 128    // 8rem
    }
    
    // MARK: - Line Heights
    
    /// Line height multipliers for optimal readability
    struct LineHeight {
        static let tight: CGFloat = 1.1
        static let snug: CGFloat = 1.2
        static let normal: CGFloat = 1.4
        static let relaxed: CGFloat = 1.6
        static let loose: CGFloat = 1.8
    }
    
    // MARK: - Letter Spacing
    
    /// Letter spacing values for different contexts
    struct LetterSpacing {
        static let tighter: CGFloat = -0.05
        static let tight: CGFloat = -0.025
        static let normal: CGFloat = 0
        static let wide: CGFloat = 0.025
        static let wider: CGFloat = 0.05
        static let widest: CGFloat = 0.1
    }
    
    // MARK: - Heading Styles
    
    /// Heading hierarchy using Josefin Sans
    struct Headings {
        
        /// Display - Largest heading for hero sections
        static let display = Font.custom(JosefinSans.bold, size: Scale.xl9)
            .weight(.bold)
        
        /// H1 - Primary page headings
        static let h1 = Font.custom(JosefinSans.bold, size: Scale.xl6)
            .weight(.bold)
        
        /// H2 - Section headings
        static let h2 = Font.custom(JosefinSans.semiBold, size: Scale.xl5)
            .weight(.semibold)
        
        /// H3 - Subsection headings
        static let h3 = Font.custom(JosefinSans.semiBold, size: Scale.xl4)
            .weight(.semibold)
        
        /// H4 - Component headings
        static let h4 = Font.custom(JosefinSans.medium, size: Scale.xl3)
            .weight(.medium)
        
        /// H5 - Small headings
        static let h5 = Font.custom(JosefinSans.medium, size: Scale.xl2)
            .weight(.medium)
        
        /// H6 - Smallest headings
        static let h6 = Font.custom(JosefinSans.medium, size: Scale.xl)
            .weight(.medium)
    }
    
    // MARK: - Body Text Styles
    
    /// Body text hierarchy using Playfair Display
    struct Body {
        
        /// Large body text for emphasis
        static let large = Font.custom(PlayfairDisplay.regular, size: Scale.lg)
            .weight(.regular)
        
        /// Regular body text
        static let regular = Font.custom(PlayfairDisplay.regular, size: Scale.base)
            .weight(.regular)
        
        /// Small body text
        static let small = Font.custom(PlayfairDisplay.regular, size: Scale.sm)
            .weight(.regular)
        
        /// Extra small body text
        static let extraSmall = Font.custom(PlayfairDisplay.regular, size: Scale.xs)
            .weight(.regular)
        
        /// Medium weight body text for emphasis
        static let medium = Font.custom(PlayfairDisplay.medium, size: Scale.base)
            .weight(.medium)
        
        /// Semibold body text for strong emphasis
        static let semibold = Font.custom(PlayfairDisplay.semiBold, size: Scale.base)
            .weight(.semibold)
    }
    
    // MARK: - UI Text Styles
    
    /// Interface text using Josefin Sans for consistency
    struct UI {
        
        /// Button text
        static let button = Font.custom(JosefinSans.medium, size: Scale.base)
            .weight(.medium)
        
        /// Large button text
        static let buttonLarge = Font.custom(JosefinSans.medium, size: Scale.lg)
            .weight(.medium)
        
        /// Small button text
        static let buttonSmall = Font.custom(JosefinSans.medium, size: Scale.sm)
            .weight(.medium)
        
        /// Navigation text
        static let navigation = Font.custom(JosefinSans.medium, size: Scale.base)
            .weight(.medium)
        
        /// Tab bar text
        static let tabBar = Font.custom(JosefinSans.regular, size: Scale.xs)
            .weight(.regular)
        
        /// Caption text
        static let caption = Font.custom(JosefinSans.regular, size: Scale.xs)
            .weight(.regular)
        
        /// Label text
        static let label = Font.custom(JosefinSans.medium, size: Scale.sm)
            .weight(.medium)
        
        /// Input field text
        static let input = Font.custom(PlayfairDisplay.regular, size: Scale.base)
            .weight(.regular)
        
        /// Placeholder text
        static let placeholder = Font.custom(PlayfairDisplay.regular, size: Scale.base)
            .weight(.regular)
    }
    
    // MARK: - Specialized Styles
    
    /// Specialized typography for specific contexts
    struct Specialized {
        
        /// Code and monospaced text
        static let code = Font.system(size: Scale.sm, design: .monospaced)
        
        /// Numbers and data
        static let numeric = Font.custom(JosefinSans.medium, size: Scale.base)
            .weight(.medium)
            .monospacedDigit()
        
        /// Large numeric displays
        static let numericLarge = Font.custom(JosefinSans.bold, size: Scale.xl4)
            .weight(.bold)
            .monospacedDigit()
        
        /// Quote text
        static let quote = Font.custom(PlayfairDisplay.italic, size: Scale.lg)
            .weight(.regular)
        
        /// Emphasis text
        static let emphasis = Font.custom(PlayfairDisplay.italic, size: Scale.base)
            .weight(.regular)
        
        /// Strong emphasis
        static let strong = Font.custom(PlayfairDisplay.bold, size: Scale.base)
            .weight(.bold)
    }
}

// MARK: - Typography Modifiers

struct TypographyModifier: ViewModifier {
    let style: TypographyStyle
    let color: Color?
    let lineHeight: CGFloat?
    let letterSpacing: CGFloat?
    let alignment: TextAlignment
    
    init(
        style: TypographyStyle,
        color: Color? = nil,
        lineHeight: CGFloat? = nil,
        letterSpacing: CGFloat? = nil,
        alignment: TextAlignment = .leading
    ) {
        self.style = style
        self.color = color
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
        self.alignment = alignment
    }
    
    func body(content: Content) -> some View {
        content
            .font(style.font)
            .foregroundColor(color ?? style.defaultColor)
            .lineSpacing(lineHeight ?? style.defaultLineHeight)
            .tracking(letterSpacing ?? style.defaultLetterSpacing)
            .multilineTextAlignment(alignment)
    }
}

// MARK: - Typography Style Enum

enum TypographyStyle {
    // Headings
    case display, h1, h2, h3, h4, h5, h6
    
    // Body
    case bodyLarge, body, bodySmall, bodyExtraSmall
    case bodyMedium, bodySemibold
    
    // UI
    case button, buttonLarge, buttonSmall
    case navigation, tabBar, caption, label
    case input, placeholder
    
    // Specialized
    case code, numeric, numericLarge
    case quote, emphasis, strong
    
    var font: Font {
        switch self {
        // Headings
        case .display: return TypographySystem.Headings.display
        case .h1: return TypographySystem.Headings.h1
        case .h2: return TypographySystem.Headings.h2
        case .h3: return TypographySystem.Headings.h3
        case .h4: return TypographySystem.Headings.h4
        case .h5: return TypographySystem.Headings.h5
        case .h6: return TypographySystem.Headings.h6
        
        // Body
        case .bodyLarge: return TypographySystem.Body.large
        case .body: return TypographySystem.Body.regular
        case .bodySmall: return TypographySystem.Body.small
        case .bodyExtraSmall: return TypographySystem.Body.extraSmall
        case .bodyMedium: return TypographySystem.Body.medium
        case .bodySemibold: return TypographySystem.Body.semibold
        
        // UI
        case .button: return TypographySystem.UI.button
        case .buttonLarge: return TypographySystem.UI.buttonLarge
        case .buttonSmall: return TypographySystem.UI.buttonSmall
        case .navigation: return TypographySystem.UI.navigation
        case .tabBar: return TypographySystem.UI.tabBar
        case .caption: return TypographySystem.UI.caption
        case .label: return TypographySystem.UI.label
        case .input: return TypographySystem.UI.input
        case .placeholder: return TypographySystem.UI.placeholder
        
        // Specialized
        case .code: return TypographySystem.Specialized.code
        case .numeric: return TypographySystem.Specialized.numeric
        case .numericLarge: return TypographySystem.Specialized.numericLarge
        case .quote: return TypographySystem.Specialized.quote
        case .emphasis: return TypographySystem.Specialized.emphasis
        case .strong: return TypographySystem.Specialized.strong
        }
    }
    
    var defaultColor: Color {
        switch self {
        case .display, .h1, .h2, .h3, .h4, .h5, .h6:
            return .semanticTextPrimary
        case .body, .bodyLarge, .bodyMedium, .bodySemibold:
            return .semanticTextPrimary
        case .bodySmall, .bodyExtraSmall:
            return Color.semantic(light: SemanticColors.Text.secondary, dark: SemanticColors.Dark.Text.secondary)
        case .button, .buttonLarge, .buttonSmall, .navigation:
            return .semanticTextPrimary
        case .tabBar, .caption, .label:
            return Color.semantic(light: SemanticColors.Text.secondary, dark: SemanticColors.Dark.Text.secondary)
        case .input:
            return .semanticTextPrimary
        case .placeholder:
            return Color.semantic(light: SemanticColors.Text.tertiary, dark: SemanticColors.Dark.Text.tertiary)
        case .code, .numeric, .numericLarge:
            return .semanticTextPrimary
        case .quote, .emphasis:
            return Color.semantic(light: SemanticColors.Text.secondary, dark: SemanticColors.Dark.Text.secondary)
        case .strong:
            return .semanticTextPrimary
        }
    }
    
    var defaultLineHeight: CGFloat {
        switch self {
        case .display, .h1, .h2:
            return TypographySystem.LineHeight.tight
        case .h3, .h4, .h5, .h6:
            return TypographySystem.LineHeight.snug
        case .body, .bodyLarge, .bodyMedium, .bodySemibold:
            return TypographySystem.LineHeight.relaxed
        case .bodySmall, .bodyExtraSmall:
            return TypographySystem.LineHeight.normal
        case .button, .buttonLarge, .buttonSmall:
            return TypographySystem.LineHeight.snug
        case .navigation, .tabBar, .caption, .label:
            return TypographySystem.LineHeight.normal
        case .input, .placeholder:
            return TypographySystem.LineHeight.normal
        case .code:
            return TypographySystem.LineHeight.normal
        case .numeric, .numericLarge:
            return TypographySystem.LineHeight.tight
        case .quote:
            return TypographySystem.LineHeight.relaxed
        case .emphasis, .strong:
            return TypographySystem.LineHeight.normal
        }
    }
    
    var defaultLetterSpacing: CGFloat {
        switch self {
        case .display, .h1, .h2:
            return TypographySystem.LetterSpacing.tight
        case .h3, .h4, .h5, .h6:
            return TypographySystem.LetterSpacing.normal
        case .body, .bodyLarge, .bodyMedium, .bodySemibold, .bodySmall, .bodyExtraSmall:
            return TypographySystem.LetterSpacing.normal
        case .button, .buttonLarge, .buttonSmall:
            return TypographySystem.LetterSpacing.wide
        case .navigation, .tabBar:
            return TypographySystem.LetterSpacing.wide
        case .caption, .label:
            return TypographySystem.LetterSpacing.normal
        case .input, .placeholder:
            return TypographySystem.LetterSpacing.normal
        case .code:
            return TypographySystem.LetterSpacing.normal
        case .numeric, .numericLarge:
            return TypographySystem.LetterSpacing.normal
        case .quote, .emphasis, .strong:
            return TypographySystem.LetterSpacing.normal
        }
    }
}

// MARK: - View Extensions

extension View {
    
    /// Apply typography style with optional customizations
    func typography(
        _ style: TypographyStyle,
        color: Color? = nil,
        lineHeight: CGFloat? = nil,
        letterSpacing: CGFloat? = nil,
        alignment: TextAlignment = .leading
    ) -> some View {
        modifier(TypographyModifier(
            style: style,
            color: color,
            lineHeight: lineHeight,
            letterSpacing: letterSpacing,
            alignment: alignment
        ))
    }
    
    /// Quick access to common typography styles
    func displayText(color: Color? = nil) -> some View {
        typography(.display, color: color)
    }
    
    func headingText(_ level: Int = 1, color: Color? = nil) -> some View {
        let style: TypographyStyle = {
            switch level {
            case 1: return .h1
            case 2: return .h2
            case 3: return .h3
            case 4: return .h4
            case 5: return .h5
            case 6: return .h6
            default: return .h1
            }
        }()
        return typography(style, color: color)
    }
    
    func bodyText(size: BodySize = .regular, weight: BodyWeight = .regular, color: Color? = nil) -> some View {
        let style: TypographyStyle = {
            switch (size, weight) {
            case (.large, .regular): return .bodyLarge
            case (.regular, .regular): return .body
            case (.small, .regular): return .bodySmall
            case (.extraSmall, .regular): return .bodyExtraSmall
            case (.regular, .medium): return .bodyMedium
            case (.regular, .semibold): return .bodySemibold
            default: return .body
            }
        }()
        return typography(style, color: color)
    }
    
    func buttonText(size: ButtonSize = .regular) -> some View {
        let style: TypographyStyle = {
            switch size {
            case .small: return .buttonSmall
            case .regular: return .button
            case .large: return .buttonLarge
            }
        }()
        return typography(style)
    }
}

// MARK: - Supporting Enums

enum BodySize {
    case extraSmall, small, regular, large
}

enum BodyWeight {
    case regular, medium, semibold
}

enum ButtonSize {
    case small, regular, large
}