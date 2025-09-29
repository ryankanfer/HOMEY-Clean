import SwiftUI

struct ThemedBackground: View {
    var page: AppPage
    @ObservedObject private var theme = ThemeManager.shared
    
    private var currentPage: AppPage { page }
    
    private var featherOpacity: Double {
        switch theme.homeTimeMode {
        case .day: return 0.08
        case .sunset: return 0.15
        case .night: return 0.25
        case .auto: return 0.25
        }
    }
    
    var body: some View {
        ZStack {
            switch currentPage {
            case .homey:
                // Keep original HomeyHeroBackground for homepage
                LinearGradient(
                    colors: [
                        Color(red: 0.16, green: 0.42, blue: 0.66),
                        Color(red: 0.34, green: 0.71, blue: 0.86),
                        Color(red: 0.88, green: 0.93, blue: 0.97)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                RadialGradient(
                    colors: [Color.black.opacity(0.0), Color.black.opacity(0.22)],
                    center: .center,
                    startRadius: 300,
                    endRadius: 900
                )
                .blendMode(.multiply)
            default:
                // Use CinematicBackground for all other pages
                CinematicBackground(for: currentPage, intensity: 1.0)
            }
            
            // Keep existing feathering effect for homey page
            if currentPage == .homey {
                LinearGradient(
                    colors: [
                        Color.black.opacity(featherOpacity),
                        Color.black.opacity(featherOpacity * 0.7),
                        Color.black.opacity(featherOpacity * 0.4),
                        Color.clear,
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
}

extension View {
    func themedScreenBackground(_ page: AppPage) -> some View {
        self.background(
            ThemedBackground(page: page)
        )
    }
}
