import SwiftUI

struct PersonalizationSettingsSection: View {
    @State private var defaultTab = "HOMEY"
    @State private var notificationTone = "Professional"
    @State private var seasonalModeEnabled = true
    @State private var betaFeaturesEnabled = false
    
    private let availableTabs = ["HOMEY", "Search", "Documents", "Matchmaker", "Next Up"]
    private let notificationTones = ["Professional", "Playful", "Minimal"]
    
    var body: some View {
        Section("Personalization") {
            // Default Starting Tab
            HStack {
                Image(systemName: "house.fill")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Default Starting Tab")
                        .font(.body)
                    Text(defaultTab)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Picker("Default Tab", selection: $defaultTab) {
                    ForEach(availableTabs, id: \.self) { tab in
                        Text(tab).tag(tab)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding(.vertical, 2)
            
            // Tab Order Customization
            NavigationLink(destination: TabOrderCustomizationView()) {
                HStack {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.orange)
                        .frame(width: 24)
                    
                    Text("Customize Tab Order")
                        .font(.body)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
            
            // Quick Actions Configuration
            NavigationLink(destination: QuickActionsView()) {
                HStack {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.yellow)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Quick Actions")
                            .font(.body)
                        Text("Long-press app icon actions")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
            
            // Notification Tone/Vibe
            HStack {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(.purple)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Notification Style")
                        .font(.body)
                    Text(notificationTone)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Picker("Notification Tone", selection: $notificationTone) {
                    ForEach(notificationTones, id: \.self) { tone in
                        Text(tone).tag(tone)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding(.vertical, 2)
            
            // Seasonal/Themed Modes
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.pink)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Seasonal Themes")
                        .font(.body)
                    Text("Holiday icons & animations")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $seasonalModeEnabled)
                    .labelsHidden()
            }
            .padding(.vertical, 2)
        }
        
        Section("Beta Features") {
            // Beta Features Toggle
            HStack {
                Image(systemName: "flask.fill")
                    .foregroundColor(.green)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Early Access Features")
                        .font(.body)
                    Text("Experimental functionality")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $betaFeaturesEnabled)
                    .labelsHidden()
            }
            .padding(.vertical, 2)
            
            if betaFeaturesEnabled {
                // Beta Features List
                VStack(alignment: .leading, spacing: 8) {
                    BetaFeatureRow(
                        name: "AI Property Recommendations",
                        description: "Enhanced ML-powered suggestions",
                        isEnabled: .constant(true)
                    )
                    
                    BetaFeatureRow(
                        name: "Voice Search",
                        description: "Search properties using voice commands",
                        isEnabled: .constant(false)
                    )
                    
                    BetaFeatureRow(
                        name: "AR Property Viewer",
                        description: "View properties in augmented reality",
                        isEnabled: .constant(false)
                    )
                }
                .padding(.leading, 32)
            }
            
            // Send Feedback
            Button(action: {
                // Open feedback form
            }) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("Send Feedback")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.vertical, 2)
            }
        }
    }
}

struct BetaFeatureRow: View {
    let name: String
    let description: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.body)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
        }
        .padding(.vertical, 2)
    }
}

// Placeholder views for navigation destinations
struct TabOrderCustomizationView: View {
    @State private var tabs = ["HOMEY", "Search", "Documents", "Matchmaker", "Next Up"]
    
    var body: some View {
        List {
            ForEach(tabs, id: \.self) { tab in
                HStack {
                    Image(systemName: tabIcon(for: tab))
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text(tab)
                        .font(.body)
                    
                    Spacer()
                    
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .onMove(perform: moveTab)
        }
        .navigationTitle("Tab Order")
        .toolbar {
            EditButton()
        }
    }
    
    private func moveTab(from source: IndexSet, to destination: Int) {
        tabs.move(fromOffsets: source, toOffset: destination)
    }
    
    private func tabIcon(for tab: String) -> String {
        switch tab {
        case "HOMEY": return "house.fill"
        case "Search": return "magnifyingglass"
        case "Documents": return "doc.fill"
        case "Matchmaker": return "heart.fill"
        case "Next Up": return "clock.fill"
        default: return "circle.fill"
        }
    }
}

struct QuickActionsView: View {
    @State private var quickSearchEnabled = true
    @State private var newDocumentEnabled = true
    @State private var contactAgentEnabled = false
    @State private var favoritePropertiesEnabled = true
    
    var body: some View {
        List {
            Section("Available Quick Actions") {
                QuickActionRow(
                    name: "Quick Search",
                    icon: "magnifyingglass",
                    color: .blue,
                    isEnabled: $quickSearchEnabled
                )
                
                QuickActionRow(
                    name: "New Document",
                    icon: "doc.badge.plus",
                    color: .green,
                    isEnabled: $newDocumentEnabled
                )
                
                QuickActionRow(
                    name: "Contact Agent",
                    icon: "phone.fill",
                    color: .orange,
                    isEnabled: $contactAgentEnabled
                )
                
                QuickActionRow(
                    name: "Favorite Properties",
                    icon: "heart.fill",
                    color: .red,
                    isEnabled: $favoritePropertiesEnabled
                )
            }
            
            Section {
                Text("Quick Actions appear when you long-press the HOMEY app icon on your home screen.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Quick Actions")
    }
}

struct QuickActionRow: View {
    let name: String
    let icon: String
    let color: Color
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(name)
                .font(.body)
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        List {
            PersonalizationSettingsSection()
        }
        .listStyle(GroupedListStyle())
    }
}