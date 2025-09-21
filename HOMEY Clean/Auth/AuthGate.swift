//
//  AuthGate.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//

import SwiftUI

struct AuthGate: View {
    @EnvironmentObject private var session: AppSessionManager
    @State private var isCheckingSession = true
    
    var body: some View {
        Group {
            if isCheckingSession {
                // Show loading state while checking for existing session
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Checking authentication...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else {
                NavigationStack {
                    LoginView()
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar { ToolbarItem(placement: .principal) { Text("Sign In") } }
                }
            }
        }
        .onAppear {
            // Give the session manager a moment to check for existing session
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isCheckingSession = false
            }
        }
    }
}
