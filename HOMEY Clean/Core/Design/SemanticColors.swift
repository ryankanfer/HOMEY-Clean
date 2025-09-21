//
//  SemanticColors.swift
//  HOMEY Clean
//
//  Created by Trae AI
//  Semantic color system with contextual tokens
//

import SwiftUI

/// Semantic color system providing contextual color tokens
struct SemanticColors {
    
    // MARK: - Status Colors
    
    /// Success states - operations completed successfully
    struct Success {
        static let primary = Color(red: 0.13, green: 0.70, blue: 0.67)     // Teal #22B3AB
        static let secondary = Color(red: 0.10, green: 0.56, blue: 0.53)   // Darker teal #1A8F87
        static let background = Color(red: 0.94, green: 0.99, blue: 0.98)  // Light teal #F0FCFB
        static let border = Color(red: 0.80, green: 0.95, blue: 0.94)      // Soft teal #CCF2F0
        static let text = Color(red: 0.05, green: 0.35, blue: 0.33)        // Deep teal #0D5954
    }
    
    /// Warning states - attention required, non-critical
    struct Warning {
        static let primary = Color(red: 1.00, green: 0.73, blue: 0.20)     // Amber #FFBA33
        static let secondary = Color(red: 0.85, green: 0.62, blue: 0.17)   // Darker amber #D99E2B
        static let background = Color(red: 1.00, green: 0.98, blue: 0.93)  // Light amber #FFFAED
        static let border = Color(red: 1.00, green: 0.91, blue: 0.73)      // Soft amber #FFE8BA
        static let text = Color(red: 0.60, green: 0.44, blue: 0.12)        // Deep amber #99701F
    }
    
    /// Error states - critical issues, failures
    struct Error {
        static let primary = Color(red: 0.96, green: 0.26, blue: 0.21)     // Red #F54336
        static let secondary = Color(red: 0.83, green: 0.18, blue: 0.18)   // Darker red #D32F2F
        static let background = Color(red: 1.00, green: 0.95, blue: 0.95)  // Light red #FFF2F2
        static let border = Color(red: 1.00, green: 0.82, blue: 0.82)      // Soft red #FFD1D1
        static let text = Color(red: 0.58, green: 0.13, blue: 0.13)        // Deep red #942121
    }
    
    // MARK: - Information Colors
    
    /// Informational states - neutral information
    struct Info {
        static let primary = Color(red: 0.13, green: 0.59, blue: 0.95)     // Blue #2196F3
        static let secondary = Color(red: 0.10, green: 0.46, blue: 0.82)   // Darker blue #1976D2
        static let background = Color(red: 0.93, green: 0.97, blue: 1.00)  // Light blue #EDF7FF
        static let border = Color(red: 0.73, green: 0.87, blue: 1.00)      // Soft blue #BBDEFB
        static let text = Color(red: 0.05, green: 0.28, blue: 0.63)        // Deep blue #0D47A1
    }
    
    // MARK: - Interactive States
    
    /// Interactive element states
    struct Interactive {
        static let primary = Color(red: 0.40, green: 0.23, blue: 0.72)     // Purple #663AB7
        static let hover = Color(red: 0.35, green: 0.20, blue: 0.65)       // Darker purple #5A339F
        static let pressed = Color(red: 0.30, green: 0.17, blue: 0.58)     // Even darker purple #4D2C94
        static let disabled = Color(red: 0.78, green: 0.78, blue: 0.78)    // Gray #C7C7C7
        static let focus = Color(red: 0.13, green: 0.59, blue: 0.95)       // Blue #2196F3
    }
    
    // MARK: - Surface Colors
    
    /// Surface and background colors
    struct Surface {
        static let primary = Color(red: 1.00, green: 1.00, blue: 1.00)     // White #FFFFFF
        static let secondary = Color(red: 0.98, green: 0.98, blue: 0.98)   // Light gray #FAFAFA
        static let tertiary = Color(red: 0.96, green: 0.96, blue: 0.96)    // Lighter gray #F5F5F5
        static let elevated = Color(red: 1.00, green: 1.00, blue: 1.00)    // White with shadow
        static let overlay = Color.black.opacity(0.5)                      // Semi-transparent black
    }
    
    // MARK: - Text Colors
    
    /// Text hierarchy colors
    struct Text {
        static let primary = Color(red: 0.13, green: 0.13, blue: 0.13)     // Dark gray #212121
        static let secondary = Color(red: 0.38, green: 0.38, blue: 0.38)   // Medium gray #616161
        static let tertiary = Color(red: 0.62, green: 0.62, blue: 0.62)    // Light gray #9E9E9E
        static let disabled = Color(red: 0.78, green: 0.78, blue: 0.78)    // Very light gray #C7C7C7
        static let inverse = Color(red: 1.00, green: 1.00, blue: 1.00)     // White #FFFFFF
    }
    
    // MARK: - Border Colors
    
    /// Border and divider colors
    struct Border {
        static let primary = Color(red: 0.88, green: 0.88, blue: 0.88)     // Light gray #E0E0E0
        static let secondary = Color(red: 0.95, green: 0.95, blue: 0.95)   // Very light gray #F2F2F2
        static let focus = Color(red: 0.13, green: 0.59, blue: 0.95)       // Blue #2196F3
        static let error = Error.primary
        static let success = Success.primary
        static let warning = Warning.primary
    }
    
    // MARK: - Brand Colors (Homey Specific)
    
    /// Brand-specific colors for Homey app
    struct Brand {
        static let primary = Color(red: 0.40, green: 0.23, blue: 0.72)     // Purple #663AB7
        static let secondary = Color(red: 0.13, green: 0.70, blue: 0.67)   // Teal #22B3AB
        static let accent = Color(red: 1.00, green: 0.73, blue: 0.20)      // Amber #FFBA33
        static let gradient = LinearGradient(
            colors: [primary, secondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Dark Mode Support
    
    /// Dark mode color variants
    struct Dark {
        struct Success {
            static let primary = Color(red: 0.26, green: 0.84, blue: 0.81)     // Lighter teal
            static let background = Color(red: 0.05, green: 0.15, blue: 0.14)  // Dark teal
            static let text = Color(red: 0.80, green: 0.95, blue: 0.94)        // Light teal
        }
        
        struct Warning {
            static let primary = Color(red: 1.00, green: 0.85, blue: 0.40)     // Lighter amber
            static let background = Color(red: 0.20, green: 0.15, blue: 0.05)  // Dark amber
            static let text = Color(red: 1.00, green: 0.91, blue: 0.73)        // Light amber
        }
        
        struct Error {
            static let primary = Color(red: 1.00, green: 0.45, blue: 0.40)     // Lighter red
            static let background = Color(red: 0.20, green: 0.05, blue: 0.05)  // Dark red
            static let text = Color(red: 1.00, green: 0.82, blue: 0.82)        // Light red
        }
        
        struct Surface {
            static let primary = Color(red: 0.08, green: 0.08, blue: 0.08)     // Dark gray
            static let secondary = Color(red: 0.12, green: 0.12, blue: 0.12)   // Darker gray
            static let tertiary = Color(red: 0.16, green: 0.16, blue: 0.16)    // Medium dark gray
        }
        
        struct Text {
            static let primary = Color(red: 0.95, green: 0.95, blue: 0.95)     // Light gray
            static let secondary = Color(red: 0.78, green: 0.78, blue: 0.78)   // Medium gray
            static let tertiary = Color(red: 0.62, green: 0.62, blue: 0.62)    // Darker gray
        }
    }
}

// MARK: - Color Extensions

extension Color {
    
    /// Creates a semantic color that adapts to light/dark mode
    static func semantic(
        light: Color,
        dark: Color
    ) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
            UIColor(dark) : UIColor(light)
        })
    }
    
    /// Success color that adapts to color scheme
    static var semanticSuccess: Color {
        semantic(
            light: SemanticColors.Success.primary,
            dark: SemanticColors.Dark.Success.primary
        )
    }
    
    /// Warning color that adapts to color scheme
    static var semanticWarning: Color {
        semantic(
            light: SemanticColors.Warning.primary,
            dark: SemanticColors.Dark.Warning.primary
        )
    }
    
    /// Error color that adapts to color scheme
    static var semanticError: Color {
        semantic(
            light: SemanticColors.Error.primary,
            dark: SemanticColors.Dark.Error.primary
        )
    }
    
    /// Surface color that adapts to color scheme
    static var semanticSurface: Color {
        semantic(
            light: SemanticColors.Surface.primary,
            dark: SemanticColors.Dark.Surface.primary
        )
    }
    
    /// Primary text color that adapts to color scheme
    static var semanticTextPrimary: Color {
        semantic(
            light: SemanticColors.Text.primary,
            dark: SemanticColors.Dark.Text.primary
        )
    }
}

// MARK: - SwiftUI View Modifiers

struct SemanticColorModifier: ViewModifier {
    let colorType: SemanticColorType
    let variant: SemanticColorVariant
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
    }
    
    private var foregroundColor: Color {
        switch (colorType, variant) {
        case (.success, .primary): return .semanticSuccess
        case (.warning, .primary): return .semanticWarning
        case (.error, .primary): return .semanticError
        case (.success, .text): return Color.semantic(light: SemanticColors.Success.text, dark: SemanticColors.Dark.Success.text)
        case (.warning, .text): return Color.semantic(light: SemanticColors.Warning.text, dark: SemanticColors.Dark.Warning.text)
        case (.error, .text): return Color.semantic(light: SemanticColors.Error.text, dark: SemanticColors.Dark.Error.text)
        default: return .semanticTextPrimary
        }
    }
    
    private var backgroundColor: Color {
        switch (colorType, variant) {
        case (.success, .background): return Color.semantic(light: SemanticColors.Success.background, dark: SemanticColors.Dark.Success.background)
        case (.warning, .background): return Color.semantic(light: SemanticColors.Warning.background, dark: SemanticColors.Dark.Warning.background)
        case (.error, .background): return Color.semantic(light: SemanticColors.Error.background, dark: SemanticColors.Dark.Error.background)
        default: return .clear
        }
    }
}

enum SemanticColorType {
    case success, warning, error, info, interactive, surface, text, border, brand
}

enum SemanticColorVariant {
    case primary, secondary, background, border, text
}

extension View {
    func semanticColor(_ type: SemanticColorType, variant: SemanticColorVariant = .primary) -> some View {
        modifier(SemanticColorModifier(colorType: type, variant: variant))
    }
}