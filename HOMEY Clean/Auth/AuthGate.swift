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
    @State private var checkTimeout = false
    
    var body: some View {
        Group {
            if isCheckingSession && !checkTimeout {
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
            } else if checkTimeout {
                // Show timeout message
                VStack(spacing: 16) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    Text("Unable to check authentication")
                        .font(.headline)
                    Text("Please check your internet connection and try again")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
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
            // But add a timeout to prevent indefinite hanging
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isCheckingSession = false
            }
            
            // Add a longer timeout as a fallback
            DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
                if isCheckingSession {
                    checkTimeout = true
                    isCheckingSession = false
                }
            }
        }
    }
}