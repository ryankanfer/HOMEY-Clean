//
//  RootView.swift
//  HOMEY Clean
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var session: SessionManager

    var body: some View {
        Group {
            if session.isLoggedIn {
                ClientDashboardView()
            } else {
                SignInView()
            }
        }
        .task {
            // Try to restore a previous session on launch
            await session.restore()
        }
    }
}
