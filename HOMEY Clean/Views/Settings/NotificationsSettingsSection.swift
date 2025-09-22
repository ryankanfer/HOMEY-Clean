//
//  NotificationsSettingsSection.swift
//  HOMEY Clean
//
//  Notifications settings section with push notifications, preferences, and quiet hours
//

import SwiftUI

struct NotificationsSettingsSection: View {
    @State private var pushNotificationsEnabled = true
    @State private var newListingsEnabled = true
    @State private var agentMessagesEnabled = true
    @State private var marketUpdatesEnabled = false
    @State private var vendorOffersEnabled = true
    @State private var quietHoursEnabled = false
    @State private var quietStartTime = Date()
    @State private var quietEndTime = Date()
    @State private var showingQuietHoursConfig = false
    
    var body: some View {
        Section(header: Text("Notifications")) {
            // Master Push Notifications Toggle
            HStack {
                Image(systemName: "bell")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Push Notifications")
                        .font(.body)
                    Text("Allow notifications from HOMEY")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $pushNotificationsEnabled)
            }
            
            if pushNotificationsEnabled {
                // Notification Preferences
                Group {
                    HStack {
                        Image(systemName: "house")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("New Listings")
                                .font(.body)
                            Text("Properties matching your criteria")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $newListingsEnabled)
                    }
                    
                    HStack {
                        Image(systemName: "message")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Agent Messages")
                                .font(.body)
                            Text("Direct messages from your agent")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $agentMessagesEnabled)
                    }
                    
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Market Updates")
                                .font(.body)
                            Text("Price changes and market insights")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $marketUpdatesEnabled)
                    }
                    
                    HStack {
                        Image(systemName: "tag")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Vendor Offers")
                                .font(.body)
                            Text("Special deals and promotions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $vendorOffersEnabled)
                    }
                }
                
                // Quiet Hours
                Button(action: { showingQuietHoursConfig = true }) {
                    HStack {
                        Image(systemName: "moon")
                            .foregroundColor(.indigo)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Quiet Hours")
                                .font(.body)
                                .foregroundColor(.primary)
                            Text(quietHoursEnabled ? quietHoursDescription : "Not configured")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
        }
        .sheet(isPresented: $showingQuietHoursConfig) {
            QuietHoursConfigView(
                isEnabled: $quietHoursEnabled,
                startTime: $quietStartTime,
                endTime: $quietEndTime
            )
        }
    }
    
    private var quietHoursDescription: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: quietStartTime)) - \(formatter.string(from: quietEndTime))"
    }
}

// MARK: - Quiet Hours Configuration View
struct QuietHoursConfigView: View {
    @Binding var isEnabled: Bool
    @Binding var startTime: Date
    @Binding var endTime: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Enable Quiet Hours")
                            .font(.body)
                        
                        Spacer()
                        
                        Toggle("", isOn: $isEnabled)
                    }
                } footer: {
                    Text("During quiet hours, you won't receive notifications except for urgent messages from your agent.")
                }
                
                if isEnabled {
                    Section("Schedule") {
                        DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                    }
                    
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                                Text("What's Silenced")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                quietHourFeature(
                                    icon: "house",
                                    title: "New Listings",
                                    description: "Property notifications will be delayed"
                                )
                                
                                quietHourFeature(
                                    icon: "chart.line.uptrend.xyaxis",
                                    title: "Market Updates",
                                    description: "Market insights will be delivered later"
                                )
                                
                                quietHourFeature(
                                    icon: "tag",
                                    title: "Vendor Offers",
                                    description: "Promotional notifications will wait"
                                )
                            }
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("Quiet Hours Details")
                    }
                    
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                Text("Still Delivered")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                quietHourFeature(
                                    icon: "message",
                                    title: "Agent Messages",
                                    description: "Direct messages from your agent"
                                )
                                
                                quietHourFeature(
                                    icon: "bell.badge",
                                    title: "Urgent Notifications",
                                    description: "Time-sensitive alerts and updates"
                                )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Quiet Hours")
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
    
    private func quietHourFeature(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview
struct NotificationsSettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            NotificationsSettingsSection()
        }
        .listStyle(GroupedListStyle())
    }
}