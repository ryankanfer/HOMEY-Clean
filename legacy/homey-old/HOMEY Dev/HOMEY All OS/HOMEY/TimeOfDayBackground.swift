import SwiftUI

struct TimeOfDayBackground: View {
    var body: some View {
        let hour = Calendar.current.component(.hour, from: Date())
        let colors: [Color]

        switch hour {
        case 5 ..< 12:
            colors = [.mint.opacity(0.5), .blue.opacity(0.3)]
        case 12 ..< 18:
            colors = [.blue.opacity(0.45), .purple.opacity(0.25)]
        default:
            colors = [.indigo.opacity(0.5), .black.opacity(0.6)]
        }

        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            RadialGradient(
                colors: [.white.opacity(0.08), .clear],
                center: .topTrailing,
                startRadius: 40,
                endRadius: 420
            )
        )
        .ignoresSafeArea()
    }
}
