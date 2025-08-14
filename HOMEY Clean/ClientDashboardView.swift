//
//  ClientDashboardView.swift
//  HOMEY Clean
//

import SwiftUI

struct ClientDashboardView: View {
    @EnvironmentObject var session: SessionManager
    @StateObject private var journey = JourneyWatcher.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Welcome to HOMEY")
                    .font(.title).bold()
                Text("Journey event: \(journey.lastEvent)")
                    .font(.subheadline)

                NavigationLink("Open Scout") {
                    Text("Scout coming soon")
                        .navigationTitle("Scout")
                }

                Button("Sign Out") {
                    Task { await session.signOut() }
                }
                .buttonStyle(.bordered)
                .padding(.top, 12)
            }
            .padding()
            .onAppear { journey.log("dashboard_open") }
            .navigationTitle("Dashboard")
        }
    }
}
