//
//  ComprehensiveSettingsView.swift
//  HOMEY Clean
//
//  Created by Assistant on 1/25/25.
//

import SwiftUI
import Supabase

struct ComprehensiveSettingsView: View {
    @EnvironmentObject private var session: AppSessionManager
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var searchText = ""
    @State private var showingLogoutAlert = false
    @State private var showingClearDataAlert = false
    @State private var showingContactSupport = false
    
    // Notification Settings
    @State private var pushNotificationsEnabled = true
    @State private var newListingsNotifications = true
    @State private var agentMessagesNotifications = true
    @State private var marketUpdatesNotifications = false
    @State private var vendorOffersNotifications = true
    @State private var quietHoursEnabled = false
    @State private var quietHoursStart = Date()
    @State private var quietHoursEnd = Date()
    
    // Accessibility Settings
    @State private var textSize: Double = 1.0
    @State private var highContrastEnabled = false
    @State private var hapticsEnabled = true
    @State private var reduceMotionEnabled = false
    @State private var subtleAnimations = false
    
    // Privacy & Security
    @State private var twoFactorEnabled = false
    @State private var locationPermissionEnabled = true
    @State private var contactsPermissionEnabled = false
    
    // Integrations
    @State private var calendarSyncEnabled = false
    @State private var googleDriveExportEnabled = false
    @State private var notionExportEnabled = false
    @State private var crmConnectionEnabled = false
    
    // Personalization
    @State private var selectedNotificationTone = "Professional"
    @State private var defaultStartingTab = "HOMEY"
    @State private var seasonalModesEnabled = true
    @State private var betaFeaturesEnabled = false

    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            SearchBar(text: $searchText)
                .padding(.horizontal)
                .padding(.top, 8)
            
            List {
                // Account Section
                if searchText.isEmpty || "account profile role".contains(searchText.lowercased()) {
                    accountSection
                }
                
                // Appearance Section
                if searchText.isEmpty || "appearance theme dark light accessibility".contains(searchText.lowercased()) {
                    appearanceSection
                }
                
                // Notifications Section
                if searchText.isEmpty || "notifications push alerts quiet".contains(searchText.lowercased()) {
                    notificationsSection
                }
                
                // Privacy & Security Section
                if searchText.isEmpty || "privacy security data permissions location".contains(searchText.lowercased()) {
                    privacySecuritySection
                }
                
                // Integrations Section
                if searchText.isEmpty || "integrations calendar sync export drive".contains(searchText.lowercased()) {
                    integrationsSection
                }
                
                // Personalization Section
                if searchText.isEmpty || "personalization customize quick actions".contains(searchText.lowercased()) {
                    personalizationSection
                }
                
                // Help & Support Section
                if searchText.isEmpty || "help support faq contact bug report".contains(searchText.lowercased()) {
                    helpSupportSection
                }
                
                // Actions Section
                if searchText.isEmpty || "logout sign out".contains(searchText.lowercased()) {
                    actionsSection
                }
                
                // Debug Section (Debug builds only)
                #if DEBUG
                if searchText.isEmpty || "debug admin force".contains(searchText.lowercased()) {
                    debugSection
                }
                #endif
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            hapticsEnabled = HapticsManager.shared.enabled
        }
        .onChange(of: hapticsEnabled) { _, newValue in
            HapticsManager.shared.enabled = newValue
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
        .alert("Clear Cached Data", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear Data", role: .destructive) {
                clearCachedData()
            }
        } message: {
            Text("This will clear all locally cached data including saved searches and preferences. This action cannot be undone.")
        }
        .sheet(isPresented: $showingContactSupport) {
            ContactSupportView()
        }
    }
    
    // MARK: - Account Section
    private var accountSection: some View {
        Section {
            // Current Role & Profile
            VStack(alignment: .leading, spacing: 12) {
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
                
                if let profile = session.userProfile {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Email")
                                .captionText(color: .secondary)
                            Text(profile.email)
                                .bodyText()
                        }
                    }
                    
                    if let fullName = profile.fullName {
                        HStack {
                            Image(systemName: "person.text.rectangle.fill")
                                .font(.caption)
                                .foregroundStyle(.purple)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Full Name")
                                    .captionText(color: .secondary)
                                Text(fullName)
                                    .bodyText()
                            }
                        }
                    }
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
            
            // Linked Accounts
            NavigationLink(destination: LinkedAccountsView()) {
                HStack {
                    Image(systemName: "link")
                        .foregroundStyle(.indigo)
                    Text("Linked Accounts")
                        .bodyText()
                    Spacer()
                    Text("Google, Apple")
                        .captionText(color: .secondary)
                }
            }
            
        } header: {
            Text("Account")
        }
    }
    
    // MARK: - Appearance Section
    private var appearanceSection: some View {
        Section {
            HStack {
                Image(systemName: "paintpalette.fill")
                    .foregroundStyle(.purple)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Theme")
                        .bodyText()
                    Text("Midnight Black")
                        .captionText(color: .secondary)
                }
                Spacer()
            }
            
            // Accessibility Settings
            NavigationLink(value: AppRoute.settingsDetail(.accessibility)) {
                HStack {
                    Image(systemName: "accessibility")
                        .foregroundStyle(.blue)
                    Text("Accessibility")
                        .bodyText()
                    Spacer()
                }
            }
            
            // Haptics toggle (global)
            HStack {
                Image(systemName: "hand.tap")
                    .foregroundStyle(.green)
                Text("Haptic Feedback")
                    .bodyText()
                Spacer()
                Toggle("", isOn: $hapticsEnabled)
            }
            
            // Animations / Reduce Motion
            HStack {
                Image(systemName: "wand.and.stars")
                    .foregroundStyle(.pink)
                Text("Reduce Motion")
                    .bodyText()
                Spacer()
                Toggle("", isOn: $reduceMotionEnabled)
            }
            
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.yellow)
                Text("Subtle Animations")
                    .bodyText()
                Spacer()
                Toggle("", isOn: $subtleAnimations)
            }
            
        } header: {
            Text("Appearance")
        } footer: {
            Text("Appearance is optimized for deep midnight black.")
        }
    }
    
    // MARK: - Notifications Section
    private var notificationsSection: some View {
        Section {
            // Push Notifications Toggle
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundStyle(.red)
                Text("Push Notifications")
                    .bodyText()
                Spacer()
                Toggle("", isOn: $pushNotificationsEnabled)
            }
            
            if pushNotificationsEnabled {
                // Notification Preferences
                HStack {
                    Image(systemName: "house.fill")
                        .foregroundStyle(.blue)
                    Text("New Listings")
                        .bodyText()
                    Spacer()
                    Toggle("", isOn: $newListingsNotifications)
                }
                
                HStack {
                    Image(systemName: "message.fill")
                        .foregroundStyle(.green)
                    Text("Agent Messages")
                        .bodyText()
                    Spacer()
                    Toggle("", isOn: $agentMessagesNotifications)
                }
                
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundStyle(.orange)
                    Text("Market Updates")
                        .bodyText()
                    Spacer()
                    Toggle("", isOn: $marketUpdatesNotifications)
                }
                
                HStack {
                    Image(systemName: "tag.fill")
                        .foregroundStyle(.purple)
                    Text("Vendor Offers")
                        .bodyText()
                    Spacer()
                    Toggle("", isOn: $vendorOffersNotifications)
                }
                
                // Quiet Hours
                NavigationLink(destination: QuietHoursView()) {
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundStyle(.indigo)
                        Text("Quiet Hours")
                            .bodyText()
                        Spacer()
                        Text(quietHoursEnabled ? "Enabled" : "Disabled")
                            .captionText(color: .secondary)
                    }
                }
            }
            
        } header: {
            Text("Notifications")
        } footer: {
            Text("Control which notifications you receive and when.")
        }
    }
    
    // MARK: - Privacy & Security Section
    private var privacySecuritySection: some View {
        Section {
            // Manage Connected Devices
            NavigationLink(destination: ConnectedDevicesView()) {
                HStack {
                    Image(systemName: "iphone")
                        .foregroundStyle(.blue)
                    Text("Connected Devices")
                        .bodyText()
                    Spacer()
                }
            }
            
            // Two-Factor Authentication
            HStack {
                Image(systemName: "lock.shield.fill")
                    .foregroundStyle(.green)
                Text("Two-Factor Authentication")
                    .bodyText()
                Spacer()
                Toggle("", isOn: $twoFactorEnabled)
            }
            
            // Data Permissions
            NavigationLink(destination: DataPermissionsView(
                locationEnabled: $locationPermissionEnabled,
                contactsEnabled: $contactsPermissionEnabled
            )) {
                HStack {
                    Image(systemName: "hand.raised.fill")
                        .foregroundStyle(.orange)
                    Text("Data Permissions")
                        .bodyText()
                    Spacer()
                }
            }
            
            // Clear Cached Data
            Button(action: {
                showingClearDataAlert = true
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                        .foregroundStyle(.red)
                    Text("Clear Cached Data")
                        .bodyText(color: .red)
                    Spacer()
                }
            }
            
        } header: {
            Text("Privacy & Security")
        } footer: {
            Text("Manage your privacy settings and security preferences.")
        }
    }
    
    // MARK: - Integrations Section
    private var integrationsSection: some View {
        Section {
            // Calendar Sync
            NavigationLink(value: AppRoute.settingsDetail(.integrations)) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.red)
                    Text("Calendar Sync")
                        .bodyText()
                    Spacer()
                    Text(calendarSyncEnabled ? "Connected" : "Not Connected")
                        .captionText(color: .secondary)
                }
            }
            
            // Export to Google Drive
            HStack {
                Image(systemName: "externaldrive.fill")
                    .foregroundStyle(.blue)
                Text("Google Drive Export")
                    .bodyText()
                Spacer()
                Toggle("", isOn: $googleDriveExportEnabled)
            }
            
            // Export to Notion
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundStyle(.black)
                Text("Notion Export")
                    .bodyText()
                Spacer()
                Toggle("", isOn: $notionExportEnabled)
            }
            
            // CRM Connections (for agents/admins)
            if session.userRole == "agent" || session.userRole == "admin" {
                NavigationLink(destination: CRMConnectionsView()) {
                    HStack {
                        Image(systemName: "person.3.fill")
                            .foregroundStyle(.purple)
                        Text("CRM Connections")
                            .bodyText()
                        Spacer()
                        Text(crmConnectionEnabled ? "Connected" : "Not Connected")
                            .captionText(color: .secondary)
                    }
                }
            }
            
        } header: {
            Text("Integrations")
        } footer: {
            Text("Connect HOMEY with your favorite productivity tools.")
        }
    }
    
    // MARK: - Personalization Section
    private var personalizationSection: some View {
        Section {
            // Customize Home Screen Tab Order
            NavigationLink(value: AppRoute.settingsDetail(.personalizationTabOrder)) {
                HStack {
                    Image(systemName: "square.grid.3x3.fill")
                        .foregroundStyle(.blue)
                    Text("Tab Order")
                        .bodyText()
                    Spacer()
                }
            }
            
            // Quick Actions Configuration
            NavigationLink(value: AppRoute.settingsDetail(.personalizationQuickActions)) {
                HStack {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(.yellow)
                    Text("Quick Actions")
                        .bodyText()
                    Spacer()
                }
            }
            
            // Notification Tone
            HStack {
                Image(systemName: "speaker.wave.3.fill")
                    .foregroundStyle(.purple)
                Text("Notification Tone")
                    .bodyText()
                Spacer()
                Text(selectedNotificationTone)
                    .captionText(color: .secondary)
            }
            
            // Default Starting Tab
            HStack {
                Image(systemName: "house.fill")
                    .foregroundStyle(.green)
                Text("Default Starting Tab")
                    .bodyText()
                Spacer()
                Text(defaultStartingTab)
                    .captionText(color: .secondary)
            }
            
            // Seasonal Modes
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(.green)
                Text("Seasonal Themes")
                    .bodyText()
                Spacer()
                Toggle("", isOn: $seasonalModesEnabled)
            }
            
        } header: {
            Text("Personalization")
        } footer: {
            Text("Customize HOMEY to match your preferences and workflow.")
        }
    }
    
    // MARK: - Help & Support Section
    private var helpSupportSection: some View {
        Section {
            // FAQ/Knowledge Base
            NavigationLink(destination: FAQView()) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundStyle(.blue)
                    Text("FAQ & Help")
                        .bodyText()
                    Spacer()
                }
            }
            
            // Contact Support
            Button(action: {
                showingContactSupport = true
            }) {
                HStack {
                    Image(systemName: "headphones")
                        .foregroundStyle(.green)
                    Text("Contact Support")
                        .bodyText()
                    Spacer()
                }
            }
            
            // Report a Bug
            Button(action: {
                // TODO: Implement bug reporting functionality
            }) {
                HStack {
                    Image(systemName: "ladybug.fill")
                        .foregroundStyle(.red)
                    Text("Report a Bug")
                        .bodyText()
                    Spacer()
                }
            }
            
            // Beta Features
            HStack {
                Image(systemName: "flask.fill")
                    .foregroundStyle(.orange)
                Text("Beta Features")
                    .bodyText()
                Spacer()
                Toggle("", isOn: $betaFeaturesEnabled)
            }
            
            // Send Feedback
            Button(action: {
                // TODO: Implement feedback functionality
            }) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.pink)
                    Text("Send Feedback")
                        .bodyText()
                    Spacer()
                }
            }
            
            // About Section
            NavigationLink(value: AppRoute.settingsDetail(.about)) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                    Text("About HOMEY")
                        .bodyText()
                    Spacer()
                }
            }
            
            // App Version & Build
            HStack {
                Image(systemName: "gear")
                    .foregroundStyle(.gray)
                Text("App Version")
                    .bodyText()
                Spacer()
                Text("\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"))")
                    .captionText(color: .secondary)
            }
            
            // Legal Documents
            Button(action: {
                // TODO: Implement legal documents view
            }) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(.indigo)
                    Text("Legal & Privacy")
                        .bodyText()
                    Spacer()
                }
            }
            
            // Credits
            NavigationLink(destination: CreditsView()) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("Credits")
                        .bodyText()
                    Spacer()
                }
            }
            
        } header: {
            Text("Help & Support")
        } footer: {
            Text("Get help, report issues, and learn more about HOMEY.")
        }
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        Section {
            Button(action: {
                showingLogoutAlert = true
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundStyle(.red)
                    Text("Sign Out")
                        .bodyText(color: .red)
                    Spacer()
                }
            }
        } header: {
            Text("Actions")
        } footer: {
            Text("Signing out will return you to the login screen.")
        }
    }
    
    // MARK: - Debug Section
    #if DEBUG
    private var debugSection: some View {
        Section {
            Toggle("Force Admin Tabs", isOn: Binding(
                get: { UserDefaults.standard.bool(forKey: "dev_show_admin_tabs") },
                set: { UserDefaults.standard.set($0, forKey: "dev_show_admin_tabs") }
            ))
            
            NavigationLink("Font Debug") {
                FontDebugView()
            }
            
            // Role Selection (for admin users)
            if session.userRole == "admin" || session.userRole == "agent" {
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
            }
            
        } header: {
            Text("Debug")
        } footer: {
            Text("Debug mode features for development and testing.")
        }
    }
    #endif
    
    // MARK: - Helper Functions
    private func clearCachedData() {
        // Clear UserDefaults cache
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "cached_user_profile")
        defaults.removeObject(forKey: "user_preferences")
        defaults.removeObject(forKey: "journey_state")
        
        // Clear any other cached data
        URLCache.shared.removeAllCachedResponses()
        
        // Show success feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        HapticsManager.shared.impact(.medium)
    }
}

// MARK: - Role Button Component
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

// MARK: - Placeholder Views for Navigation Destinations
struct AccessibilitySettingsView: View {
    var body: some View {
        Text("Accessibility Settings")
            .navigationTitle("Accessibility")
    }
}

struct QuietHoursView: View {
    var body: some View {
        Text("Quiet Hours Configuration")
            .navigationTitle("Quiet Hours")
    }
}

struct ConnectedDevicesView: View {
    var body: some View {
        Text("Connected Devices")
            .navigationTitle("Connected Devices")
    }
}

struct CalendarSyncView: View {
    var body: some View {
        Text("Calendar Sync Settings")
            .navigationTitle("Calendar Sync")
    }
}

#Preview {
    ComprehensiveSettingsView()
        .environmentObject(AppSessionManager.shared)
        .environmentObject(ThemeManager.shared)
}