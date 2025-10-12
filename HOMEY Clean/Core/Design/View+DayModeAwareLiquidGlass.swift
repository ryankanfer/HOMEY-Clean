import SwiftUI

extension View {
    @ViewBuilder
    func dayModeAwareLiquidGlass(themeManager: ThemeManager) -> some View {
        let isDarkMode = themeManager.currentMode == .dark
        let tintColor = isDarkMode ? Theme.surface.opacity(0.8) : Theme.surface.opacity(0.9)
        
        self.liquidGlass(
            tintColor: tintColor
        )
    }
}