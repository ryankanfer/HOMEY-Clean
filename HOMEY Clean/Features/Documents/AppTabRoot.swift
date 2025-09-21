import SwiftUI

// Temporary wrapper to avoid duplicate roots. Prefer using AppTabRootStyle directly.
struct AppTabRoot: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "app.dashed")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("AppTabRootStyle is not available in this target.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}

#Preview {
    AppTabRoot()
}