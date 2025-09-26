//
//  SettingsView.swift
//  HOMEY Clean
//
//  Created by Assistant on 8/25/25.
//

import SwiftUI
import Supabase

@available(*, deprecated, message: "Use ComprehensiveSettingsView via AppRoute.settings")
struct SettingsView: View {
    @EnvironmentObject private var session: AppSessionManager
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground(for: .homey)
                    .ignoresSafeArea()
                
                List {
                // User Info Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Current Role")
                                    .captionText(color: .secondary)
                                Text(session.userRole.capitalized)
                                    .subtitleText()
                            }
                            Spacer()
                        }
                        
                        if session.userRole == "client", let segment = session.clientSegment {
                            HStack {
                                Image(systemName: "tag.fill")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Client Segment")
                                        .captionText(color: .secondary)
                                    Text(segment.capitalized)
                                        .bodyText()
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Account")
                }
                
                // App Settings Section
                Section {
                    NavigationLink(destination: HomepageCustomizationSheet()) {
                        HStack {
                            Image(systemName: "paintpalette")
                                .foregroundStyle(.purple)
                            Text("Theme & Homepage Settings").bodyText()
                        }
                    }
                } header: {
                    Text("Appearance")
                }
                
                // App Info Section
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.blue)
                        Text("App Version").bodyText()
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "hammer")
                            .foregroundStyle(.orange)
                        Text("Build Number").bodyText()
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("User Information")
                }
                
                // Role Selection Section (for admin users)
                // DEBUG only to prevent privilege escalation in Release builds
                #if DEBUG
                if session.userRole == "admin" || session.userRole == "agent" {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Switch Role")
                                 .subtitleText()
                            
                            HStack(spacing: 12) {
                                RoleButton("Client", isSelected: session.userRole == "client") {
                                    session.setActiveRole("client")
                                }
                                RoleButton("Agent", isSelected: session.userRole == "agent") {
                                    session.setActiveRole("agent")
                                }
                                RoleButton("Admin", isSelected: session.userRole == "admin") {
                                    session.setActiveRole("admin")
                                }
                            }
                            
                            if session.userRole == "client" {
                                Picker("Client Type", selection: Binding(
                                    get: { session.clientSegment ?? "renter" },
                                    set: { session.clientSegment = $0 }
                                )) {
                                    Text("Renter").tag("renter")
                                    Text("Buyer").tag("buyer")
                                    Text("Seller").tag("seller")
                                    Text("Landlord").tag("landlord")
                                }
                                .pickerStyle(.segmented)
                                .padding(.top, 8)
                            }
                        }
                    } header: {
                        Text("Role Management (Debug)")
                    } footer: {
                        Text("Debug mode: As an admin, you can switch between different roles to test the app experience.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                #endif
                
                // Actions Section
                Section {
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundStyle(.red)
                            Text("Sign Out")
                                .bodyText(color: .red)
                        }
                    }
                } header: {
                    Text("Actions")
                } footer: {
                    Text("Signing out will return you to the login screen. You can sign in with different credentials to switch roles.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // TEMPORARY: Font Debug Section
                Section {
                    #if DEBUG
                    Toggle("Force Admin Tabs", isOn: Binding(
                        get: { UserDefaults.standard.bool(forKey: "dev_show_admin_tabs") },
                        set: { UserDefaults.standard.set($0, forKey: "dev_show_admin_tabs") }
                    ))
                    .foregroundColor(Theme.text)
                    #endif
                    
                    NavigationLink("Font Debug") {
                        FontDebugView()
                    }
                } header: {
                    Text("Debug")
                } footer: {
                    #if DEBUG
                    Text("Force Admin Tabs: Enables admin dashboard access regardless of user role (Debug builds only)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    #endif
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        }
        .alert("Sign Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                Task {
                    await session.signOut()
                }
            }
        } message: {
            Text("Are you sure you want to sign out? You'll need to sign in again to access the app.")
        }
    }
}

// MARK: - Supporting Views

private struct RoleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    init(_ title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .captionText(color: isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppSessionManager.shared)
}
