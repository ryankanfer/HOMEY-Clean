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

public enum HomeTimeMode: String, CaseIterable {
    case auto
    case day
    case sunset
    case night
}

public class ThemeManager: ObservableObject {
    @Published public var currentMode: ThemeMode = .dark
    @Published public var currentPage: AppPage = .homey
    @Published public var homeTimeMode: HomeTimeMode = .auto
    
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
        .profile: .calmSkyflow,
        .documents: .auroraFlow
    ]
    
    public init() {
        if let saved = UserDefaults.standard.string(forKey: "ThemeMode"),
           let mode = ThemeMode(rawValue: saved) {
            currentMode = mode
        } else {
            currentMode = .dark
            UserDefaults.standard.set(ThemeMode.dark.rawValue, forKey: "ThemeMode")
        }
        if let raw = UserDefaults.standard.string(forKey: "HomeTimeMode"),
           let hm = HomeTimeMode(rawValue: raw) {
            homeTimeMode = hm
        } else {
            homeTimeMode = .auto
        }
    }
    
    public func setTheme(_ mode: ThemeMode) {
        currentMode = mode
        UserDefaults.standard.set(mode.rawValue, forKey: "ThemeMode")
    }
    
    public func setHomeTimeMode(_ mode: HomeTimeMode) {
        homeTimeMode = mode
        UserDefaults.standard.set(mode.rawValue, forKey: "HomeTimeMode")
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
            return nil
        case .light, .dayMode:
            return .light
        case .dark, .blackWhite:
            return .dark
        }
    }
    
    public var isDayMode: Bool {
        return currentMode == .dayMode
    }
    
    public var isLightish: Bool {
        return currentMode == .light || currentMode == .dayMode
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
        public static let background = Color(red: 0.90, green: 0.91, blue: 0.92) // slate-200 #E5E7EB
        public static let surface = Color.white
        public static let surfaceElevated = Color.white
        
        public static let textPrimary = Color(red: 0.12, green: 0.16, blue: 0.22) // deep charcoal #1F2937
        public static let textSecondary = Color(red: 0.29, green: 0.33, blue: 0.39) // darker gray #4B5563
        public static let textTertiary = Color(red: 0.42, green: 0.45, blue: 0.50) // mid gray #6B7280
        
        // Interactive colors (unchanged)
        public static let primary = Color(red: 0.0, green: 0.3, blue: 0.8)
        public static let primaryHover = Color(red: 0.0, green: 0.25, blue: 0.7)
        public static let accent = Color(red: 0.8, green: 0.4, blue: 0.0)
        
        // Status colors (unchanged)
        public static let success = Color(red: 0.0, green: 0.5, blue: 0.0)
        public static let warning = Color(red: 0.8, green: 0.5, blue: 0.0)
        public static let error = Color(red: 0.8, green: 0.0, blue: 0.0)
        
        // Borders and shadow tuned for light UI
        public static let border = Color(red: 0.82, green: 0.84, blue: 0.88) // slate-300 #D1D5DB
        public static let borderStrong = Color(red: 0.67, green: 0.70, blue: 0.75) // slate-400 #9CA3AF
        
        public static let shadow = Color.black.opacity(0.08)
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
    
    public static func accentForTheme(_ theme: AppTheme) -> Color {
        switch theme {
        case .calmSkyflow:
            return Color(red: 0.25, green: 0.55, blue: 0.98)
        case .sunsetPulse:
            return Color(red: 0.98, green: 0.52, blue: 0.28)
        case .midnightLuxe:
            return Color(red: 0.52, green: 0.56, blue: 0.92)
        case .urbanEnergy:
            return Color(red: 0.20, green: 0.85, blue: 0.55)
        case .desertMirage:
            return Color(red: 0.94, green: 0.76, blue: 0.46)
        case .auroraFlow:
            return Color(red: 0.44, green: 0.54, blue: 0.98)
        case .monochromeSheen:
            return Color(white: 0.85)
        case .cinematicLounge:
            return CinematicLounge.accent
        }
    }
    
    public static let brandAccent = Color(red: 0x7A/255.0, green: 0x6E/255.0, blue: 0xE6/255.0)
    public static let focusRing = brandAccent

    private static func hex(_ rgb: Int) -> Color {
        Color(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
    
    public static func currentHomeTimeMode(themeManager: ThemeManager = .shared) -> HomeTimeMode {
        if themeManager.homeTimeMode != .auto {
            return themeManager.homeTimeMode
        }
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<17: return .day
        case 17..<20: return .sunset
        default: return .night
        }
    }
    
    private static var gradHomeDay: LinearGradient {
        LinearGradient(
            colors: [hex(0xF7F3ED), hex(0xCFE6F9)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    private static var gradHomeSunset: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: hex(0xFAD6A5), location: 0.0),
                .init(color: hex(0xE6A0A2), location: 0.45),
                .init(color: hex(0x7A6EE6), location: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    private static var gradHomeNight: LinearGradient {
        LinearGradient(
            colors: [hex(0x0E1220), hex(0x1C1A32)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    public static func homeGradient(themeManager: ThemeManager = .shared) -> LinearGradient {
        switch currentHomeTimeMode(themeManager: themeManager) {
        case .day: return gradHomeDay
        case .sunset: return gradHomeSunset
        case .night: return gradHomeNight
        case .auto: return gradHomeNight
        }
    }
    
    private static func pageTokenGradient(for page: AppPage) -> LinearGradient? {
        switch page {
        case .homey:
            return nil
        case .discover:
            return LinearGradient(
                colors: [hex(0xE8F3FF), hex(0xB8D7FF)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .directory:
            return LinearGradient(
                colors: [hex(0xF2EEFF), hex(0xCFC4FF)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .insights:
            return LinearGradient(
                colors: [hex(0xE9FBF2), hex(0xBDEFD3)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .documents:
            return LinearGradient(
                colors: [hex(0xF4F7FA), hex(0xD9E2EC)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .settings:
            return LinearGradient(
                colors: [hex(0xF6F6F8), hex(0xE4E4EA)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .profile:
            return LinearGradient(
                colors: [hex(0xF6F6F8), hex(0xE4E4EA)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .vision:
            return LinearGradient(
                colors: [hex(0xFFF0F3), hex(0xFFC3CF)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .matchmaker:
            return LinearGradient(
                colors: [hex(0xFFF3E9), hex(0xFFD0A6)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    public static func heroGradient(for page: AppPage? = nil, themeManager: ThemeManager = .shared) -> LinearGradient {
        if let p = page {
            if p == .homey {
                return homeGradient(themeManager: themeManager)
            }
            if let token = pageTokenGradient(for: p) {
                return token
            }
        }
        let theme = themeManager.currentTheme(for: page)
        return gradientForTheme(theme)
    }

    public static func pageAccent(for page: AppPage) -> Color {
        switch page {
        case .documents: return hex(0x3B82F6)
        case .directory: return hex(0x7A6EE6)
        case .insights: return hex(0x10B981)
        case .vision: return hex(0xF43F5E)
        case .matchmaker: return hex(0xFB923C)
        case .profile: return hex(0x64748B)
        case .discover: return hex(0x2563EB)
        case .homey: return brandAccent
        case .settings: return brandAccent
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
        public static let background = Color(red: 0.12, green: 0.12, blue: 0.14)
        public static let backgroundDark = Color(red: 0.06, green: 0.06, blue: 0.09)
        
        public static let surface = Color(red: 0.18, green: 0.18, blue: 0.22).opacity(0.8)
        public static let surfaceElevated = Color(red: 0.22, green: 0.22, blue: 0.26).opacity(0.9)
        
        public static let textPrimary = Color.white
        public static let textSecondary = Color.white.opacity(0.78)
        public static let textTertiary = Color.white.opacity(0.6)
        
        public static let primary = Color.white
        public static let accent = Color(red: 0.9, green: 0.9, blue: 0.9)
        public static let mutedIcon = Color(red: 0.7, green: 0.7, blue: 0.7)
        
        public static let border = Color.white.opacity(0.15)
        public static let borderStrong = Color.white.opacity(0.25)
        public static let shadow = Color.black.opacity(0.4)
        public static let glassShadow = Color.black.opacity(0.2)
        
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
        return background
    }
    
    public static func dynamicSurface(themeManager: ThemeManager = .shared) -> Color {
        return Color("Surface")
    }
    
    public static func dynamicText(themeManager: ThemeManager = .shared) -> Color {
        return text
    }
    
    public static func dynamicTextSecondary(themeManager: ThemeManager = .shared) -> Color {
        return textMuted
    }
    
    public static func dynamicPrimary(themeManager: ThemeManager = .shared) -> Color {
        return primary
    }
    
    public static func dynamicAccent(themeManager: ThemeManager = .shared) -> Color {
        return accent
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
    
    func gradientForeground(_ gradient: LinearGradient) -> some View {
        self
            .overlay(gradient)
            .mask(self)
    }
}