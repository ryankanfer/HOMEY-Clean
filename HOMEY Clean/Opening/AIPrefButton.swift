import SwiftUI

struct AIPrefButton: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.thinMaterial, in: Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.12)))
        }
        .buttonStyle(.plain)
    }
}