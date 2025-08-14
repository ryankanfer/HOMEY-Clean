import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var session: SessionManager
    @State private var notifications = true
    @State private var marketingEmails = false

    var body: some View {
        Form {
            Section("Account") {
                Text("Email: \(session.email ?? "—")")
                Text("Role: \(session.effectiveRole)")
            }
            Section("Preferences") {
                Toggle("Notifications", isOn: $notifications)
                Toggle("Marketing Emails", isOn: $marketingEmails)
            }
            Section {
                Button(role: .destructive) { Task { await session.logout() } } label: {
                    Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                }

            }
        }
    }
}
