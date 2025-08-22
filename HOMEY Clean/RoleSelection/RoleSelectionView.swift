import SwiftUI

struct RoleSelectionView: View {
    @EnvironmentObject private var session: AppSessionManager

    var body: some View {
        ZStack {
            GradientBackground(theme: heroTheme(for: .drew))
            VStack(spacing: 16) {
                Text("Choose Role")
                    .font(.title.bold())

                HStack(spacing: 12) {
                    RoleButton("Client") { select("client") }
                    RoleButton("Agent") { select("agent") }
                    RoleButton("Admin") { select("admin") }
                }

                if session.userRole == "client" {
                    SegmentedClientType(selected: Binding(
                        get: { session.clientSegment ?? "renter" },
                        set: { session.clientSegment = $0 }
                    ))
                }
            }
            .padScreen()
        }
    }

    private func select(_ role: String) {
        session.setActiveRole(role)
    }
}

private struct RoleButton: View {
    let title: String
    let action: () -> Void
    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(title, action: action)
            .buttonStyle(.borderedProminent)
    }
}

private struct SegmentedClientType: View {
    @Binding var selected: String
    private let options = ["renter", "buyer", "seller", "landlord"]
    var body: some View {
        Picker("Client Type", selection: $selected) {
            ForEach(options, id: \.self) { Text($0.capitalized).tag($0) }
        }
        .pickerStyle(.segmented)
    }
}
