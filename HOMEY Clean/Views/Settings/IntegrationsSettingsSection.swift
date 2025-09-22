import SwiftUI

struct IntegrationsSettingsSection: View {
    @State private var calendarSyncEnabled = false
    @State private var googleDriveEnabled = true
    @State private var notionEnabled = false
    @State private var crmConnected = false
    
    var body: some View {
        Section("Integrations") {
            // Calendar Sync
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.red)
                        .frame(width: 24)
                    
                    Text("Calendar Sync")
                        .font(.body)
                    
                    Spacer()
                    
                    Toggle("", isOn: $calendarSyncEnabled)
                        .labelsHidden()
                }
                
                if calendarSyncEnabled {
                    VStack(spacing: 4) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("iCal")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.leading, 32)
                        
                        HStack {
                            Image(systemName: "circle")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text("Google Calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("Connect") {
                                // Implement Google Calendar connection
                            }
                            .font(.caption)
                        }
                        .padding(.leading, 32)
                    }
                }
            }
            .padding(.vertical, 2)
            
            // Google Drive Export
            HStack {
                Image(systemName: "externaldrive.fill")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Google Drive Export")
                        .font(.body)
                    Text(googleDriveEnabled ? "Connected" : "Not connected")
                        .font(.caption)
                        .foregroundColor(googleDriveEnabled ? .green : .secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $googleDriveEnabled)
                    .labelsHidden()
            }
            .padding(.vertical, 2)
            
            // Notion Export
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.black)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Notion Export")
                        .font(.body)
                    Text(notionEnabled ? "Connected" : "Not connected")
                        .font(.caption)
                        .foregroundColor(notionEnabled ? .green : .secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $notionEnabled)
                    .labelsHidden()
            }
            .padding(.vertical, 2)
            
            // CRM Connections (for agents/admins)
            NavigationLink(destination: CRMConnectionsView()) {
                HStack {
                    Image(systemName: "building.2.fill")
                        .foregroundColor(.purple)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CRM Connections")
                            .font(.body)
                        Text(crmConnected ? "Salesforce connected" : "No connections")
                            .font(.caption)
                            .foregroundColor(crmConnected ? .green : .secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
        }
    }
}

// Placeholder view for navigation destination
struct CRMConnectionsView: View {
    @State private var salesforceConnected = false
    @State private var hubspotConnected = false
    @State private var pipedriveConnected = false
    
    var body: some View {
        List {
            Section("Available CRM Systems") {
                CRMRow(name: "Salesforce", isConnected: $salesforceConnected, icon: "building.2.fill", color: .blue)
                CRMRow(name: "HubSpot", isConnected: $hubspotConnected, icon: "chart.pie.fill", color: .orange)
                CRMRow(name: "Pipedrive", isConnected: $pipedriveConnected, icon: "pipe.and.drop.fill", color: .green)
            }
        }
        .navigationTitle("CRM Connections")
    }
}

struct CRMRow: View {
    let name: String
    @Binding var isConnected: Bool
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.body)
                Text(isConnected ? "Connected" : "Not connected")
                    .font(.caption)
                    .foregroundColor(isConnected ? .green : .secondary)
            }
            
            Spacer()
            
            Button(isConnected ? "Disconnect" : "Connect") {
                isConnected.toggle()
            }
            .font(.caption)
            .foregroundColor(isConnected ? .red : .blue)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        List {
            IntegrationsSettingsSection()
        }
        .listStyle(GroupedListStyle())
    }
}