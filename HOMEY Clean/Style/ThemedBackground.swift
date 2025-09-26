import SwiftUI

struct ThemedBackground: View {
    var page: AppPage
    @ObservedObject private var theme = ThemeManager.shared
    
    var body: some View {
        ZStack {
            Theme.heroGradient(for: page, themeManager: theme)
                .ignoresSafeArea()
            
            if page == .homey {
                let mode = Theme.currentHomeTimeMode(themeManager: theme)
                
                // Create a feathering gradient that bleeds down from top
                let featheringGradient: LinearGradient = {
                    switch mode {
                    case .day:
                        return LinearGradient(
                            colors: [
                                Color.black.opacity(0.08),
                                Color.black.opacity(0.04),
                                Color.black.opacity(0.02),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    case .sunset:
                        return LinearGradient(
                            colors: [
                                Color.black.opacity(0.12),
                                Color.black.opacity(0.08),
                                Color.black.opacity(0.04),
                                Color.black.opacity(0.02),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    case .night, .auto:
                        return LinearGradient(
                            colors: [
                                Color.black.opacity(0.18),
                                Color.black.opacity(0.12),
                                Color.black.opacity(0.08),
                                Color.black.opacity(0.04),
                                Color.black.opacity(0.02),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }()
                
                featheringGradient
                    .ignoresSafeArea()
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