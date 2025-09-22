//
//  AdvancedSettingsHub.swift
//  HOMEY Clean
//
//  Comprehensive settings view with all core sections and enhanced features
//

import SwiftUI

struct AdvancedSettingsHub: View {
    @StateObject private var userProfileManager = UserProfileManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var searchText = ""
    @State private var showingDebugInfo = false
    @State private var showingBetaFeatures = false
    
    // Notification settings
    @State private var pushNotificationsEnabled = true
    @State private var newListingsEnabled = true
    @State private var agentMessagesEnabled = true
    @State private var marketUpdatesEnabled = false
    @State private var vendorOffersEnabled = true
    @State private var quietHoursEnabled = false
    @State private var quietStartTime = Date()
    @State private var quietEndTime = Date()
    
    // Privacy & Security settings
    @State private var twoFactorEnabled = false
    @State private var locationPermissionEnabled = true
    @State private var contactsPermissionEnabled = false
    
    // Integration settings
    @State private var calendarSyncEnabled = false
    @State private var googleDriveExportEnabled = false
    @State private var notionExportEnabled = false
    @State private var crmConnectionsEnabled = false
    
    // Personalization settings
    @State private var defaultTab = "Home"
    @State private var notificationTone = "Professional"
    @State private var seasonalModesEnabled = true
    @State private var quickActionsEnabled = true
    
    // Beta features
    @State private var betaFeaturesEnabled = false
    @State private var experimentalUIEnabled = false
    @State private var advancedAnalyticsEnabled = false
    
    var body: some View {
        NavigationStack {
            List {
                // Search Bar
                if !searchText.isEmpty {
                    SearchBar(text: $searchText)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                }
                
                // Account Section
                if shouldShowSection("Account") {
                    AccountSettingsSection()
                }
                
                // Appearance Section
                if shouldShowSection("Appearance") {
                    AppearanceSettingsSection()
                }
                
                // Notifications Section
                if shouldShowSection("Notifications") {
                    NotificationsSettingsSection()
                }
                
                // Privacy & Security Section
                if shouldShowSection("Privacy") || shouldShowSection("Security") {
                    PrivacySecuritySettingsSection()
                }
                
                // Integrations Section
                if shouldShowSection("Integrations") {
                    IntegrationsSettingsSection()
                }
                
                // Personalization Section
                if shouldShowSection("Personalization") || shouldShowSection("Customize") {
                    PersonalizationSettingsSection()
                }
                
                // Beta Features Section
                if shouldShowSection("Beta") || shouldShowSection("Experimental") {
                    BetaFeaturesSection(
                        betaFeaturesEnabled: $betaFeaturesEnabled,
                        experimentalUIEnabled: $experimentalUIEnabled,
                        advancedAnalyticsEnabled: $advancedAnalyticsEnabled
                    )
                }
                
                // Help & Support Section
                if shouldShowSection("Help") || shouldShowSection("Support") {
                    HelpSupportSettingsSection()
                }
                
                // Actions Section
                if shouldShowSection("Actions") || shouldShowSection("Debug") {
                    ActionsSection(showingDebugInfo: $showingDebugInfo)
                }
            }
            .listStyle(GroupedListStyle())
            .searchable(text: $searchText, prompt: "Search settings...")
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingDebugInfo) {
                DebugInfoView()
            }
        }
    }
    
    private func shouldShowSection(_ sectionName: String) -> Bool {
        guard !searchText.isEmpty else { return true }
        return sectionName.localizedCaseInsensitiveContains(searchText)
    }
}

// MARK: - Search Bar Component
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search settings...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Beta Features Section
struct BetaFeaturesSection: View {
    @Binding var betaFeaturesEnabled: Bool
    @Binding var experimentalUIEnabled: Bool
    @Binding var advancedAnalyticsEnabled: Bool
    
    var body: some View {
        Section(header: Text("Beta Features")) {
            HStack {
                Image(systemName: "flask")
                    .foregroundColor(.orange)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Early Access")
                        .font(.body)
                    Text("Get access to experimental features")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $betaFeaturesEnabled)
            }
            
            if betaFeaturesEnabled {
                HStack {
                    Image(systemName: "paintbrush")
                        .foregroundColor(.purple)
                        .frame(width: 24)
                    
                    Text("Experimental UI")
                    
                    Spacer()
                    
                    Toggle("", isOn: $experimentalUIEnabled)
                }
                
                HStack {
                    Image(systemName: "chart.bar")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("Advanced Analytics")
                    
                    Spacer()
                    
                    Toggle("", isOn: $advancedAnalyticsEnabled)
                }
                
                Button(action: sendBetaFeedback) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        Text("Send Feedback")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
        }
    }
    
    private func sendBetaFeedback() {
        // TODO: Implement feedback functionality
        print("Opening beta feedback form...")
    }
}

// MARK: - Actions Section
struct ActionsSection: View {
    @Binding var showingDebugInfo: Bool
    
    var body: some View {
        Section(header: Text("Actions")) {
            Button(action: clearCache) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .frame(width: 24)
                    
                    Text("Clear Cache")
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
            }
            
            Button(action: exportData) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("Export Data")
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
            }
            
            Button(action: { showingDebugInfo = true }) {
                HStack {
                    Image(systemName: "ladybug")
                        .foregroundColor(.orange)
                        .frame(width: 24)
                    
                    Text("Debug Information")
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
    }
    
    private func clearCache() {
        // TODO: Implement cache clearing
        print("Clearing cache...")
    }
    
    private func exportData() {
        // TODO: Implement data export
        print("Exporting user data...")
    }
}

// MARK: - Debug Info View
struct DebugInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("App Information") {
                    DebugRow(title: "Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                    DebugRow(title: "Build", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
                    DebugRow(title: "Bundle ID", value: Bundle.main.bundleIdentifier ?? "Unknown")
                }
                
                Section("Device Information") {
                    DebugRow(title: "Device", value: UIDevice.current.model)
                    DebugRow(title: "iOS Version", value: UIDevice.current.systemVersion)
                    DebugRow(title: "Device ID", value: UIDevice.current.identifierForVendor?.uuidString ?? "Unknown")
                }
                
                Section("User Information") {
                    DebugRow(title: "User ID", value: UserProfileManager.shared.currentProfile?.id.uuidString ?? "Not logged in")
                    DebugRow(title: "Role", value: UserProfileManager.shared.currentProfile?.role ?? "Unknown")
                    DebugRow(title: "Segment", value: UserProfileManager.shared.currentProfile?.clientSegment ?? "Unknown")
                }
            }
            .navigationTitle("Debug Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DebugRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Preview
struct AdvancedSettingsHub_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSettingsHub()
            .environmentObject(UserProfileManager.shared)
            .environmentObject(ThemeManager.shared)
    }
}