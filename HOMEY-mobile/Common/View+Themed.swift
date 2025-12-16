import SwiftUI

extension View {
    func themedText() -> some View {
        self.foregroundColor(Theme.primaryText)
    }
    
    func themedMuted() -> some View {
        self.foregroundColor(Theme.secondaryText)
    }
    
    func themedCardBackground() -> some View {
        self.background(Theme.surface)
    }
    
    func themedPrimary() -> some View {
        self.tint(Theme.primaryAction)
    }
}