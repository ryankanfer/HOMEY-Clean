//
//  PrivacySecuritySettingsSection.swift
//  HOMEY Clean
//
//  Privacy & Security settings section with device management, 2FA, and permissions
//

import SwiftUI

struct PrivacySecuritySettingsSection: View {
    @State private var twoFactorEnabled = false
    @State private var locationPermissionEnabled = true
    @State private var contactsPermissionEnabled = false
    @State private var biometricAuthEnabled = true
    @State private var showingDeviceManagement = false
    @State private var showingDataPermissions = false
    @State private var showingClearDataAlert = false
    
    var body: some View {
        Section(header: Text("Privacy & Security")) {
            // Two-Factor Authentication
            HStack {
                Image(systemName: "lock.shield")
                    .foregroundColor(.green)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Two-Factor Authentication")
                        .font(.body)
                    Text(twoFactorEnabled ? "Enabled" : "Recommended for security")
                        .font(.caption)
                        .foregroundColor(twoFactorEnabled ? .green : .secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $twoFactorEnabled)
            }
            
            // Biometric Authentication
            HStack {
                Image(systemName: "faceid")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Biometric Authentication")
                        .font(.body)
                    Text("Use Face ID or Touch ID to unlock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $biometricAuthEnabled)
            }
            
            // Connected Devices
            Button(action: { showingDeviceManagement = true }) {
                HStack {
                    Image(systemName: "iphone.and.ipad")
                        .foregroundColor(.purple)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Connected Devices")
                            .font(.body)
                            .foregroundColor(.primary)
                        Text("Manage devices with access to your account")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            // Data Permissions
            Button(action: { showingDataPermissions = true }) {
                HStack {
                    Image(systemName: "hand.raised")
                        .foregroundColor(.orange)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Data Permissions")
                            .font(.body)
                            .foregroundColor(.primary)
                        Text("Control app access to your data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            // Clear Cached Data
            Button(action: { showingClearDataAlert = true }) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Clear Cached Data")
                            .font(.body)
                            .foregroundColor(.red)
                        Text("Free up storage space")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showingDeviceManagement) {
            DeviceManagementView()
        }
        .sheet(isPresented: $showingDataPermissions) {
            DataPermissionsView(
                locationEnabled: $locationPermissionEnabled,
                contactsEnabled: $contactsPermissionEnabled
            )
        }
        .alert("Clear Cached Data", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearCachedData()
            }
        } message: {
            Text("This will clear all cached images, documents, and temporary files. Your personal data and settings will not be affected.")
        }
    }
    
    private func clearCachedData() {
        // Implementation for clearing cached data
        // This would typically involve clearing URLCache, temporary files, etc.
    }
}

// MARK: - Device Management View
struct DeviceManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var connectedDevices = [
        ConnectedDevice(name: "iPhone 15 Pro", type: .iPhone, lastActive: Date(), isCurrentDevice: true),
        ConnectedDevice(name: "iPad Air", type: .iPad, lastActive: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), isCurrentDevice: false),
        ConnectedDevice(name: "MacBook Pro", type: .mac, lastActive: Calendar.current.date(byAdding: .hour, value: -6, to: Date()) ?? Date(), isCurrentDevice: false)
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(connectedDevices) { device in
                        HStack {
                            Image(systemName: device.type.iconName)
                                .foregroundColor(device.isCurrentDevice ? .blue : .secondary)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(device.name)
                                        .font(.body)
                                    
                                    if device.isCurrentDevice {
                                        Text("(This Device)")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(4)
                                    }
                                }
                                
                                Text("Last active: \(device.lastActiveDescription)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if !device.isCurrentDevice {
                                Button("Remove") {
                                    removeDevice(device)
                                }
                                .font(.caption)
                                .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Connected Devices")
                } footer: {
                    Text("These devices have access to your HOMEY account. Remove any devices you no longer use or recognize.")
                }
            }
            .navigationTitle("Device Management")
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
    
    private func removeDevice(_ device: ConnectedDevice) {
        connectedDevices.removeAll { $0.id == device.id }
    }
}

// MARK: - Data Permissions View
struct DataPermissionsView: View {
    @Binding var locationEnabled: Bool
    @Binding var contactsEnabled: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var cameraEnabled = true
    @State private var photosEnabled = false
    @State private var notificationsEnabled = true
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    PermissionRow(
                        icon: "location",
                        iconColor: .blue,
                        title: "Location",
                        description: "Find nearby properties and agents",
                        isEnabled: $locationEnabled
                    )
                    
                    PermissionRow(
                        icon: "person.2",
                        iconColor: .green,
                        title: "Contacts",
                        description: "Share property details with contacts",
                        isEnabled: $contactsEnabled
                    )
                    
                    PermissionRow(
                        icon: "camera",
                        iconColor: .purple,
                        title: "Camera",
                        description: "Take photos for property documentation",
                        isEnabled: $cameraEnabled
                    )
                    
                    PermissionRow(
                        icon: "photo",
                        iconColor: .orange,
                        title: "Photos",
                        description: "Access photos for property listings",
                        isEnabled: $photosEnabled
                    )
                    
                    PermissionRow(
                        icon: "bell",
                        iconColor: .red,
                        title: "Notifications",
                        description: "Receive alerts and updates",
                        isEnabled: $notificationsEnabled
                    )
                } header: {
                    Text("App Permissions")
                } footer: {
                    Text("These permissions help HOMEY provide you with the best experience. You can change these settings in your device's Settings app.")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("Privacy Information")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            privacyInfoItem(
                                title: "Data Collection",
                                description: "We only collect data necessary to provide our services"
                            )
                            
                            privacyInfoItem(
                                title: "Data Sharing",
                                description: "Your personal data is never sold to third parties"
                            )
                            
                            privacyInfoItem(
                                title: "Data Security",
                                description: "All data is encrypted and stored securely"
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Data Permissions")
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
    
    private func privacyInfoItem(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline.weight(.medium))
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Permission Row Component
struct PermissionRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
        }
    }
}

// MARK: - Connected Device Model
struct ConnectedDevice: Identifiable {
    let id = UUID()
    let name: String
    let type: DeviceType
    let lastActive: Date
    let isCurrentDevice: Bool
    
    var lastActiveDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastActive, relativeTo: Date())
    }
    
    enum DeviceType {
        case iPhone, iPad, mac, unknown
        
        var iconName: String {
            switch self {
            case .iPhone: return "iphone"
            case .iPad: return "ipad"
            case .mac: return "laptopcomputer"
            case .unknown: return "questionmark.circle"
            }
        }
    }
}

// MARK: - Preview
struct PrivacySecuritySettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PrivacySecuritySettingsSection()
        }
        .listStyle(GroupedListStyle())
    }
}