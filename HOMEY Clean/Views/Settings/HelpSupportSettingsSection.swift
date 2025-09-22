import SwiftUI

struct HelpSupportSettingsSection: View {
    var body: some View {
        Section("Help & Support") {
            // FAQ / Knowledge Base
            NavigationLink(destination: FAQView()) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("FAQ & Knowledge Base")
                        .font(.body)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
            
            // Contact Support
            NavigationLink(destination: ContactSupportView()) {
                HStack {
                    Image(systemName: "headphones")
                        .foregroundColor(.green)
                        .frame(width: 24)
                    
                    Text("Contact Support")
                        .font(.body)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
            
            // Report a Bug
            NavigationLink(destination: ReportBugView()) {
                HStack {
                    Image(systemName: "ladybug.fill")
                        .foregroundColor(.red)
                        .frame(width: 24)
                    
                    Text("Report a Bug")
                        .font(.body)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
            
            // About
            NavigationLink(destination: AboutView()) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.purple)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("About HOMEY")
                            .font(.body)
                        Text("Version 2.1.0 (Build 42)")
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
        }
        
        Section("Legal") {
            // Terms of Service
            NavigationLink(destination: LegalDocumentView(title: "Terms of Service", content: "Terms content...")) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.gray)
                        .frame(width: 24)
                    
                    Text("Terms of Service")
                        .font(.body)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
            
            // Privacy Policy
            NavigationLink(destination: LegalDocumentView(title: "Privacy Policy", content: "Privacy policy content...")) {
                HStack {
                    Image(systemName: "hand.raised.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("Privacy Policy")
                        .font(.body)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
            
            // Open Source Licenses
            NavigationLink(destination: LicensesView()) {
                HStack {
                    Image(systemName: "scroll.fill")
                        .foregroundColor(.orange)
                        .frame(width: 24)
                    
                    Text("Open Source Licenses")
                        .font(.body)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
            
            // Credits
            NavigationLink(destination: CreditsView()) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.pink)
                        .frame(width: 24)
                    
                    Text("Credits")
                        .font(.body)
                    
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

// Placeholder views for navigation destinations
struct FAQView: View {
    var body: some View {
        List {
            Section("Getting Started") {
                Text("How do I search for properties?")
                Text("How do I save my favorite listings?")
                Text("How do I contact an agent?")
            }
            
            Section("Account & Profile") {
                Text("How do I update my profile?")
                Text("How do I change my password?")
                Text("How do I delete my account?")
            }
        }
        .navigationTitle("FAQ")
    }
}

struct ContactSupportView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "headphones")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Need Help?")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Our support team is here to help you with any questions or issues.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Button("Email Support") {
                    // Open email
                }
                .buttonStyle(.borderedProminent)
                
                Button("Live Chat") {
                    // Open chat
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Contact Support")
    }
}

struct ReportBugView: View {
    @State private var bugDescription = ""
    @State private var stepsToReproduce = ""
    
    var body: some View {
        Form {
            Section("Bug Description") {
                TextEditor(text: $bugDescription)
                    .frame(minHeight: 100)
            }
            
            Section("Steps to Reproduce") {
                TextEditor(text: $stepsToReproduce)
                    .frame(minHeight: 100)
            }
            
            Section {
                Button("Submit Bug Report") {
                    // Submit bug report
                }
                .disabled(bugDescription.isEmpty)
            }
        }
        .navigationTitle("Report a Bug")
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "house.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("HOMEY")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your AI-powered home buying companion")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 8) {
                Text("Version 2.1.0")
                    .font(.body)
                Text("Build 42")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("© 2024 HOMEY Inc. All rights reserved.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle("About")
    }
}

struct LegalDocumentView: View {
    let title: String
    let content: String
    
    var body: some View {
        ScrollView {
            Text(content)
                .padding()
        }
        .navigationTitle(title)
    }
}

struct LicensesView: View {
    var body: some View {
        List {
            LicenseRow(name: "SwiftUI", license: "MIT")
            LicenseRow(name: "Supabase Swift", license: "MIT")
            LicenseRow(name: "Alamofire", license: "MIT")
        }
        .navigationTitle("Open Source Licenses")
    }
}

struct LicenseRow: View {
    let name: String
    let license: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.body)
                .fontWeight(.medium)
            Text(license)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

struct CreditsView: View {
    var body: some View {
        List {
            Section("Development Team") {
                CreditRow(name: "Ryan Kanfer", role: "Lead Developer")
                CreditRow(name: "Design Team", role: "UI/UX Design")
            }
            
            Section("Special Thanks") {
                CreditRow(name: "Beta Testers", role: "Quality Assurance")
                CreditRow(name: "Community", role: "Feedback & Support")
            }
        }
        .navigationTitle("Credits")
    }
}

struct CreditRow: View {
    let name: String
    let role: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.body)
                .fontWeight(.medium)
            Text(role)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        List {
            HelpSupportSettingsSection()
        }
        .listStyle(GroupedListStyle())
    }
}