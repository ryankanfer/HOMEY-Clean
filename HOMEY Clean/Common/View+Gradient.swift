import SwiftUI

extension View {
    public func gradientForeground(_ gradient: LinearGradient) -> some View {
        self.overlay(
            gradient
        )
        .mask(self)
    }
}