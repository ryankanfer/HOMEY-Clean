//
//  RoleSelectionView.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//


import SwiftUI

/// Pretty, brand-aligned role picker. Honors existing profile role.
/// If admin, shows all three choices. Everyone else sees their own role and continues.
struct RoleSelectionView: View {
    @EnvironmentObject private var session: SessionManager
    @State private var isUpdating = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.white, Color(.systemGray6)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            VStack(spacing: 24) {
                Image("HOMEYMark").resizable().scaledToFit().frame(width: 64, height: 64)
                Text("Who are you here as?")
                    .font(.title2.weight(.semibold))

                if let err = errorMessage {
                    Text(err).font(.footnote).foregroundColor(.red)
                }

                VStack(spacing: 12) {
                    if session.userRole == "admin" {
                        RoleButton(title: "Client", subtitle: "View client dashboard") {
                            Task { await go(role: "client") }
                        }
                        RoleButton(title: "Agent", subtitle: "Work as an agent") {
                            Task { await go(role: "agent") }
                        }
                        RoleButton(title: "Admin", subtitle: "Full access") {
                            Task { await go(role: "admin") }
                        }
                    } else {
                        RoleButton(title: prettyRole(session.userRole), subtitle: "Continue") {
                            Task { await go(role: session.userRole) }
                        }
                    }
                }
                .disabled(isUpdating)

                if isUpdating { ProgressView().padding(.top, 4) }
                Spacer()
            }
            .padding(24)
        }
        .navigationBarBackButtonHidden(true)
    }

    @MainActor
    private func go(role: String) async {
        errorMessage = nil
        isUpdating = true
        defer { isUpdating = false }

        // Optional: if you want to persist a user-selected role for admins,
        // call a lightweight profile update. If you don't, simply set
        // a transient "selectedRole" on SessionManager.
        do {
            try await session.setActiveRole(role)   // implement below
        } catch {
            errorMessage = "Couldn’t switch role. \(error.localizedDescription)"
        }
    }

    private func prettyRole(_ role: String) -> String {
        switch role {
        case "admin": return "Admin"
        case "agent": return "Agent"
        default: return "Client"
        }
    }
}

private struct RoleButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.subheadline).foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.headline)
            }
            .padding(16)
            .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, y: 8)
        }
    }
}