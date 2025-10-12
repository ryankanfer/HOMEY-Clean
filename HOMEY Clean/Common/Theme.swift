import SwiftUI

// MARK: - Core Theme Definition

/// Defines the core color palette and reusable components for the HOMEY brand identity.
public enum Theme {
    
    // MARK: - Official Color Palette
    
    /// A shade of blue that is modern, friendly, and trustworthy.
    public static let skyBlue = Color(hex: 0x87CEEB)
    
    /// A clean, crisp white for backgrounds and primary text in dark mode.
    public static let white = Color.white
    
    /// A deep black for primary text in light mode and backgrounds in dark mode.
    public static let black = Color.black
    
    /// A sophisticated, neutral gray for secondary text and UI elements.
    public static let slateGray = Color(hex: 0x708090)
    
    // MARK: - Semantic Colors
    
    /// `primaryAction`: The main color for buttons, interactive elements, and highlights.
    public static let primaryAction = skyBlue
    
    /// `background`: The base color for screen backgrounds. Adapts to light/dark mode.
    public static let background = Color.adaptive(light: white, dark: black)
    
    /// `surface`: A color for cards and other surfaces elevated above the background.
    public static let surface = Color.adaptive(light: white, dark: slateGray.opacity(0.2))
    
    /// `primaryText`: For headings and important text. Adapts to light/dark mode.
    public static let primaryText = Color.adaptive(light: black, dark: white)
    
    /// `secondaryText`: For body copy, labels, and less-emphasized text.
    public static let secondaryText = Color.adaptive(light: slateGray, dark: white.opacity(0.8))
    
    /// `accent`: The accent color for highlights and special elements.
    public static let accent = primaryAction
}

// MARK: - Theme Manager

/// Manages the application's current theme (light/dark mode) and provides environment access.
public class ThemeManager: ObservableObject {
    @Published public var currentMode: ThemeMode = .dark
    
    public static let shared = ThemeManager()
    
    public init() {
        // Load the saved theme mode or default to dark.
        if let saved = UserDefaults.standard.string(forKey: "ThemeMode"),
           let mode = ThemeMode(rawValue: saved) {
            currentMode = mode
        } else {
            currentMode = .dark
            UserDefaults.standard.set(ThemeMode.dark.rawValue, forKey: "ThemeMode")
        }
    }
    
    /// Updates and saves the current theme mode.
    public func setTheme(_ mode: ThemeMode) {
        currentMode = mode
        UserDefaults.standard.set(mode.rawValue, forKey: "ThemeMode")
    }
    
    /// Determines the appropriate color scheme for the current theme mode.
    public func effectiveColorScheme(for systemScheme: SwiftUI.ColorScheme?) -> SwiftUI.ColorScheme? {
        switch currentMode {
        case .auto:
            return nil // Let the system decide
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

/// The available theme modes for the app.
public enum ThemeMode: String, CaseIterable {
    case auto
    case light
    case dark
    
    var displayName: String {
        switch self {
        case .auto: return "Automatic"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

// MARK: - Utility Extensions

/// A helper extension to create adaptive colors for light and dark modes.
fileprivate extension Color {
    static func adaptive(light: Color, dark: Color) -> Color {
        return Color(UIColor { (traitCollection: UITraitCollection) -> UIColor in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

/// A convenience extension for initializing colors from hex values.
fileprivate extension Color {
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}