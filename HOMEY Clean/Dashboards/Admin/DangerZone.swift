//
//  DangerZone.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//


struct DangerZone: View {
    @EnvironmentObject private var session: SessionManager
    var body: some View {
        SectionCard(title: "Danger zone", subtitle: "Use carefully") {
            Button("Clear local cache/AppStorage") {
                UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            }
            .foregroundStyle(.red)
            Button("Re-authenticate session") {
                Task { await session.refreshSession() }
            }
        }
    }
}