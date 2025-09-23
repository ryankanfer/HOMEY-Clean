import SwiftUI

// MARK: - App Pages for Theme Management
public enum AppPage: String, CaseIterable {
    case homey = "homey"
    case discover = "discover"
    case insights = "insights"
    case directory = "directory"
    case vision = "vision"
    case settings = "settings"
    case matchmaker = "matchmaker"
    case profile = "profile"
    case documents = "documents"
    
    var displayName: String {
        switch self {
        case .homey: return "HOMEY"
        case .discover: return "Discover"
        case .insights: return "Insights"
        case .directory: return "Directory"
        case .vision: return "Vision"
        case .settings: return "Settings"
        case .matchmaker: return "Matchmaker"
        case .profile: return "Profile"
        case .documents: return "Documents"
        }
    }
}

// MARK: - App Themes
public enum AppTheme: String, CaseIterable {
    case calmSkyflow = "calmSkyflow"
    case sunsetPulse = "sunsetPulse"
    case midnightLuxe = "midnightLuxe"
    case urbanEnergy = "urbanEnergy"
    case desertMirage = "desertMirage"
    case auroraFlow = "auroraFlow"
    case monochromeSheen = "monochromeSheen"
    case cinematicLounge = "cinematicLounge"
    
    var displayName: String {
        switch self {
        case .calmSkyflow: return "Calm Skyflow"
        case .sunsetPulse: return "Sunset Pulse"
        case .midnightLuxe: return "Midnight Luxe"
        case .urbanEnergy: return "Urban Energy"
        case .desertMirage: return "Desert Mirage"
        case .auroraFlow: return "Aurora Flow"
        case .monochromeSheen: return "Monochrome Sheen"
        case .cinematicLounge: return "Cinematic Lounge"
        }
    }
}

// MARK: - Theme Mode Management

public enum ThemeMode: String, CaseIterable {
    case auto = "auto"
    case light = "light"
    case dark = "dark"
    case dayMode = "dayMode" // High contrast light mode for accessibility
    case blackWhite = "blackWhite"
    
    var displayName: String {
        switch self {
        case .auto: return "Auto"
        case .light: return "Light"
        case .dark: return "Dark"
        case .dayMode: return "Day Mode"
        case .blackWhite: return "Black/White"
        }
    }
}

public class ThemeManager: ObservableObject {
    @Published public var currentMode: ThemeMode = .auto
    @Published public var currentPage: AppPage = .homey
    
    public static let shared = ThemeManager()
    
    // Default theme mappings for each page
    private let defaultThemes: [AppPage: AppTheme] = [
        .homey: .cinematicLounge,
        .discover: .sunsetPulse,
        .insights: .midnightLuxe,
        .directory: .urbanEnergy,
        .vision: .desertMirage,
        .settings: .auroraFlow,
        .matchmaker: .monochromeSheen,
        .profile: .calmSkyflow
    ]
    
    public init() {
        // Load saved theme preference
        if let savedMode = UserDefaults.standard.string(forKey: "ThemeMode"),
           let mode = ThemeMode(rawValue: savedMode) {
            currentMode = mode
        }
    }
    
    public func setTheme(_ mode: ThemeMode) {
        currentMode = mode
        UserDefaults.standard.set(mode.rawValue, forKey: "ThemeMode")
    }
    
    public func setCurrentPage(_ page: AppPage) {
        currentPage = page
    }
    
    public func currentTheme(for page: AppPage? = nil) -> AppTheme {
        let targetPage = page ?? currentPage
        return defaultThemes[targetPage] ?? .calmSkyflow
    }
    
    public func effectiveColorScheme(for systemScheme: SwiftUI.ColorScheme?) -> SwiftUI.ColorScheme? {
        switch currentMode {
        case .auto:
            return systemScheme
        case .light, .dayMode:
            return .light
        case .dark, .blackWhite:
            return .dark
        }
    }
    
    public var isDayMode: Bool {
        return currentMode == .dayMode
    }
    
    public var isBlackWhite: Bool {
        return currentMode == .blackWhite
    }
}

// Theme.swift (ensure tokens exist)
public enum Theme {
    // Core tokens
    public static let primary = Color("Primary")
    public static let text = Color("PrimaryText")
    public static let background = Color("Background")
    public static let accent = Color("Accent") // for TabBar tint
    public static let ctaBg = Color("CTABackground") // CTA background
    public static let ctaFg = Color("CTAForeground") // CTA foreground

    // Derived tokens
    public static let textMuted = text.opacity(0.6)

    // Back-compat for older references
    public static let primaryText = text
    public static let bg = background
    
    // MARK: - Day Mode Colors (High Contrast)

    public struct DayMode {
        // High contrast colors for accessibility compliance (WCAG AA)
        public static let background = Color.white
        public static let surface = Color(red: 0.98, green: 0.98, blue: 0.98) // #FAFAFA
        public static let surfaceElevated = Color.white
        
        // Text colors with high contrast ratios
        public static let textPrimary = Color.black // 21:1 contrast ratio
        public static let textSecondary = Color(red: 0.2, green: 0.2, blue: 0.2) // #333333 - 12.6:1 contrast
        public static let textTertiary = Color(red: 0.4, green: 0.4, blue: 0.4) // #666666 - 7:1 contrast
        
        // Interactive colors with high contrast
        public static let primary = Color(red: 0.0, green: 0.3, blue: 0.8) // #004DCC - High contrast blue
        public static let primaryHover = Color(red: 0.0, green: 0.25, blue: 0.7) // Darker for hover
        public static let accent = Color(red: 0.8, green: 0.4, blue: 0.0) // #CC6600 - High contrast orange
        
        // Status colors with high contrast
        public static let success = Color(red: 0.0, green: 0.5, blue: 0.0) // #008000
        public static let warning = Color(red: 0.8, green: 0.5, blue: 0.0) // #CC8000
        public static let error = Color(red: 0.8, green: 0.0, blue: 0.0) // #CC0000
        
        // Border colors
        public static let border = Color(red: 0.8, green: 0.8, blue: 0.8) // #CCCCCC
        public static let borderStrong = Color(red: 0.6, green: 0.6, blue: 0.6) // #999999
        
        // Shadow for depth
        public static let shadow = Color.black.opacity(0.15)
    }
    
    // MARK: - Warm Color Palette
    
    public struct Warm {
        // Warm base colors for emotional connection
        public static let sunset = Color(red: 1.0, green: 0.75, blue: 0.5) // #FFBF80 - Warm sunset
        public static let coral = Color(red: 1.0, green: 0.6, blue: 0.5) // #FF9980 - Coral warmth
        public static let amber = Color(red: 1.0, green: 0.8, blue: 0.4) // #FFCC66 - Golden amber
        public static let peach = Color(red: 1.0, green: 0.85, blue: 0.7) // #FFD9B3 - Soft peach
        public static let cream = Color(red: 0.98, green: 0.95, blue: 0.9) // #FAF2E6 - Warm cream
        
        // Warm gradients for emotional moments
        public static let celebrationGradient = LinearGradient(
            colors: [sunset, coral, amber],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        public static let progressGradient = LinearGradient(
            colors: [amber, peach],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        public static let backgroundGradient = LinearGradient(
            colors: [cream, Color.white],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Celebration Colors
    
    public struct Celebration {
        // Colors for milestone achievements and progress celebrations
        public static let gold = Color(red: 1.0, green: 0.84, blue: 0.0) // #FFD700 - Achievement gold
        public static let sparkle = Color(red: 1.0, green: 0.9, blue: 0.6) // #FFE699 - Sparkle effect
        public static let confetti = [
            Color(red: 1.0, green: 0.6, blue: 0.8), // Pink
            Color(red: 0.6, green: 0.8, blue: 1.0), // Light blue
            Color(red: 1.0, green: 0.8, blue: 0.4), // Yellow
            Color(red: 0.8, green: 1.0, blue: 0.6), // Light green
            Color(red: 1.0, green: 0.7, blue: 0.5)  // Orange
        ]
        
        public static let milestoneGradient = LinearGradient(
            colors: [gold, sparkle],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Gradient Theme Definitions
    
    public static func gradientForTheme(_ theme: AppTheme) -> LinearGradient {
        switch theme {
        case .calmSkyflow:
            return LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.7, blue: 1.0),
                    Color(red: 0.6, green: 0.9, blue: 1.0),
                    Color(red: 0.8, green: 0.95, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sunsetPulse:
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.4, blue: 0.2),
                    Color(red: 1.0, green: 0.6, blue: 0.3),
                    Color(red: 1.0, green: 0.8, blue: 0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .midnightLuxe:
            return LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color(red: 0.2, green: 0.2, blue: 0.5),
                    Color(red: 0.3, green: 0.3, blue: 0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .urbanEnergy:
            return LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.8, blue: 0.4),
                    Color(red: 0.4, green: 0.9, blue: 0.6),
                    Color(red: 0.6, green: 1.0, blue: 0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .desertMirage:
            return LinearGradient(
                colors: [
                    Color(red: 0.9, green: 0.7, blue: 0.4),
                    Color(red: 1.0, green: 0.8, blue: 0.5),
                    Color(red: 1.0, green: 0.9, blue: 0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .auroraFlow:
            return LinearGradient(
                colors: [
                    Color(red: 0.5, green: 0.2, blue: 0.8),
                    Color(red: 0.3, green: 0.6, blue: 0.9),
                    Color(red: 0.2, green: 0.8, blue: 0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .monochromeSheen:
            return LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.2, blue: 0.2),
                    Color(red: 0.5, green: 0.5, blue: 0.5),
                    Color(red: 0.8, green: 0.8, blue: 0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .cinematicLounge:
            return LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.15, blue: 0.18), // Dark slate gray
                    Color(red: 0.12, green: 0.12, blue: 0.15), // Deeper slate
                    Color(red: 0.08, green: 0.08, blue: 0.12)  // Near black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    public struct BlackWhite {
        public static let background = Color.black
        public static let surface = Color.black
        public static let textPrimary = Color.white
        public static let textSecondary = Color(white: 0.8)
        public static let primary = Color.white
        public static let accent = Color.white
        public static let border = Color.white.opacity(0.2)
        public static let shadow = Color.white.opacity(0.0)
    }
    
    // MARK: - Cinematic Lounge Theme Colors
    public struct CinematicLounge {
        // Background colors - slate gray to dark
        public static let background = Color(red: 0.15, green: 0.15, blue: 0.18) // #262629 - Slate gray
        public static let backgroundDark = Color(red: 0.08, green: 0.08, blue: 0.12) // #14141F - Near black
        
        // Glass-effect surfaces with subtle transparency
        public static let surface = Color(red: 0.18, green: 0.18, blue: 0.22).opacity(0.8) // Glassy surface
        public static let surfaceElevated = Color(red: 0.22, green: 0.22, blue: 0.26).opacity(0.9) // Elevated glass
        
        // Typography - clean white with variations
        public static let textPrimary = Color.white // Pure white for primary text
        public static let textSecondary = Color.white.opacity(0.8) // Muted white for secondary
        public static let textTertiary = Color.white.opacity(0.6) // Subtle white for tertiary
        
        // Accent colors - muted neutrals
        public static let primary = Color.white // White as primary accent
        public static let accent = Color(red: 0.9, green: 0.9, blue: 0.9) // Soft white accent
        public static let mutedIcon = Color(red: 0.7, green: 0.7, blue: 0.7) // Muted neutral icons
        
        // Borders and shadows for glass effect
        public static let border = Color.white.opacity(0.15) // Subtle white borders
        public static let borderStrong = Color.white.opacity(0.25) // Stronger borders
        public static let shadow = Color.black.opacity(0.4) // Soft shadows for depth
        public static let glassShadow = Color.black.opacity(0.2) // Glass element shadows
        
        // Gradient definitions
        public static let backgroundGradient = LinearGradient(
            colors: [background, backgroundDark],
            startPoint: .top,
            endPoint: .bottom
        )
        
        public static let glassGradient = LinearGradient(
            colors: [
                Color.white.opacity(0.1),
                Color.white.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // Dynamic Theme Functions
    public static func dynamicBackground(themeManager: ThemeManager = .shared) -> Color {
        if themeManager.isBlackWhite { return BlackWhite.background }
        return themeManager.isDayMode ? DayMode.background : background
    }
    
    public static func dynamicSurface(themeManager: ThemeManager = .shared) -> Color {
        if themeManager.isBlackWhite { return BlackWhite.surface }
        return themeManager.isDayMode ? DayMode.surface : Color("Surface")
    }
    
    public static func dynamicText(themeManager: ThemeManager = .shared) -> Color {
        if themeManager.isBlackWhite { return BlackWhite.textPrimary }
        return themeManager.isDayMode ? DayMode.textPrimary : text
    }
    
    public static func dynamicTextSecondary(themeManager: ThemeManager = .shared) -> Color {
        if themeManager.isBlackWhite { return BlackWhite.textSecondary }
        return themeManager.isDayMode ? DayMode.textSecondary : textMuted
    }
    
    public static func dynamicPrimary(themeManager: ThemeManager = .shared) -> Color {
        if themeManager.isBlackWhite { return BlackWhite.primary }
        return themeManager.isDayMode ? DayMode.primary : primary
    }
    
    public static func dynamicAccent(themeManager: ThemeManager = .shared) -> Color {
        if themeManager.isBlackWhite { return BlackWhite.accent }
        return themeManager.isDayMode ? DayMode.accent : accent
    }
}

extension View {
    func themedCardBackground() -> some View {
        background(Theme.dynamicBackground())
    }

    func themedText() -> some View {
        foregroundStyle(Theme.dynamicText())
    }

    func themedMuted() -> some View {
        foregroundStyle(Theme.dynamicTextSecondary())
    }
    
    func themedSurface() -> some View {
        background(Theme.dynamicSurface())
    }
    
    func themedPrimary() -> some View {
        foregroundStyle(Theme.dynamicPrimary())
    }

    /// Tight padding for chips/pills (optional)
    func padPill() -> some View {
        padding(.horizontal, 8)
            .padding(.vertical, 4)
    }
    
    /// Apply simple liquid glass effect with thin material
    func simpleLiquidGlass() -> some View {
        self
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
    
    /// Apply day mode aware liquid glass effect
    func dayModeAwareLiquidGlass(themeManager: ThemeManager = .shared) -> some View {
        Group {
            if themeManager.isDayMode {
                // High contrast version for day mode
                self
                    .background(Theme.DayMode.surfaceElevated, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Theme.DayMode.border, lineWidth: 1)
                    )
                    .shadow(color: Theme.DayMode.shadow, radius: 8, x: 0, y: 4)
            } else {
                // Standard liquid glass for other modes
                self.simpleLiquidGlass()
            }
        }
    }
    
    /// Apply theme-aware color scheme
    func themeAware(themeManager: ThemeManager = .shared) -> some View {
        self.preferredColorScheme(themeManager.effectiveColorScheme(for: nil))
    }
}