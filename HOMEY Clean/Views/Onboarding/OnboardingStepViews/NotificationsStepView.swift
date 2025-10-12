//
//  NotificationsStepView.swift
//  HOMEY Clean
//
//  Notifications step view for mandatory onboarding flow
//

import SwiftUI
import UserNotifications

struct NotificationsStepView: View {
    @Binding var data: [String: String]
    
    @State private var pushNotificationsEnabled = false
    @State private var emailNotificationsEnabled = true
    @State private var marketUpdatesEnabled = true
    @State private var newListingsEnabled = true
    @State private var priceChangesEnabled = true
    @State private var tourRemindersEnabled = true
    @State private var agentMessagesEnabled = true
    
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Stay Updated")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                
                Text("Choose your notification preferences")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            Text("Get notified about new listings, price changes, and important updates. You can always change these settings later.")
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
            
            VStack(alignment: .leading, spacing: 20) {
                // Push Notifications
                VStack(alignment: .leading, spacing: 12) {
                    Text("Push Notifications")
                        .font(.headline.bold())
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Enable push notifications", isOn: $pushNotificationsEnabled)
                            .onChange(of: pushNotificationsEnabled) { value in
                                Task { @MainActor in
                                    data["pushNotifications"] = String(value)
                                    if value && notificationStatus != .authorized {
                                        requestNotificationPermission()
                                    }
                                }
                            }
                        
                        if pushNotificationsEnabled {
                            Text("Get instant alerts for new listings and important updates")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("You'll only receive email notifications")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // Email Notifications
                VStack(alignment: .leading, spacing: 12) {
                    Text("Email Notifications")
                        .font(.headline.bold())
                        .foregroundColor(.primary)
                    
                    Toggle("Enable email notifications", isOn: $emailNotificationsEnabled)
                        .onChange(of: emailNotificationsEnabled) { value in
                            Task { @MainActor in
                                data["emailNotifications"] = String(value)
                            }
                        }
                }
                
                // Notification Types
                if pushNotificationsEnabled || emailNotificationsEnabled {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What would you like to be notified about?")
                            .font(.headline.bold())
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            NotificationToggle(
                                title: "New Listings",
                                description: "Properties that match your criteria",
                                isEnabled: $newListingsEnabled,
                                dataKey: "newListings",
                                data: $data
                            )
                            
                            NotificationToggle(
                                title: "Price Changes",
                                description: "When saved properties change price",
                                isEnabled: $priceChangesEnabled,
                                dataKey: "priceChanges",
                                data: $data
                            )
                            
                            NotificationToggle(
                                title: "Market Updates",
                                description: "Weekly market insights for your area",
                                isEnabled: $marketUpdatesEnabled,
                                dataKey: "marketUpdates",
                                data: $data
                            )
                            
                            NotificationToggle(
                                title: "Tour Reminders",
                                description: "Upcoming property viewings",
                                isEnabled: $tourRemindersEnabled,
                                dataKey: "tourReminders",
                                data: $data
                            )
                            
                            NotificationToggle(
                                title: "Agent Messages",
                                description: "Messages from your real estate agent",
                                isEnabled: $agentMessagesEnabled,
                                dataKey: "agentMessages",
                                data: $data
                            )
                        }
                    }
                }
                
                // Privacy Note
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lock.shield.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Privacy & Control")
                                .font(.caption.bold())
                                .foregroundColor(.primary)
                            
                            Text("We respect your privacy. You can update these preferences anytime in Settings, and we'll never share your information with third parties.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineSpacing(2)
                        }
                    }
                }
            }
        }
        .onAppear {
            loadExistingData()
            checkNotificationStatus()
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    notificationStatus = .authorized
                } else {
                    notificationStatus = .denied
                    pushNotificationsEnabled = false
                    data["pushNotifications"] = "false"
                }
            }
        }
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationStatus = settings.authorizationStatus
                if notificationStatus == .denied {
                    pushNotificationsEnabled = false
                    data["pushNotifications"] = "false"
                }
            }
        }
    }
    
    private func loadExistingData() {
        if let pushStr = data["pushNotifications"] {
            pushNotificationsEnabled = Bool(pushStr) ?? false
        }
        
        if let emailStr = data["emailNotifications"] {
            emailNotificationsEnabled = Bool(emailStr) ?? true
        }
        
        if let marketStr = data["marketUpdates"] {
            marketUpdatesEnabled = Bool(marketStr) ?? true
        }
        
        if let listingsStr = data["newListings"] {
            newListingsEnabled = Bool(listingsStr) ?? true
        }
        
        if let priceStr = data["priceChanges"] {
            priceChangesEnabled = Bool(priceStr) ?? true
        }
        
        if let tourStr = data["tourReminders"] {
            tourRemindersEnabled = Bool(tourStr) ?? true
        }
        
        if let agentStr = data["agentMessages"] {
            agentMessagesEnabled = Bool(agentStr) ?? true
        }
    }
}

struct NotificationToggle: View {
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    let dataKey: String
    @Binding var data: [String: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(title, isOn: $isEnabled)
                .onChange(of: isEnabled) { value in
                    Task { @MainActor in
                        data[dataKey] = String(value)
                    }
                }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 32) // Align with toggle text
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NotificationsStepView(data: .constant([:]))
        .padding()
}