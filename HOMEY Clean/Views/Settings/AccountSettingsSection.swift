//
//  AccountSettingsSection.swift
//  HOMEY Clean
//
//  Account settings section with role, profile, and linked accounts
//

import SwiftUI

struct AccountSettingsSection: View {
    @StateObject private var userProfileManager = UserProfileManager.shared
    @State private var showingProfileEdit = false
    @State private var showingLinkedAccounts = false
    
    var body: some View {
        Section(header: Text("Account")) {
            // Current Role & Segment
            HStack {
                Image(systemName: "person.badge.key")
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Role & Segment")
                        .font(.body)
                    if let profile = userProfileManager.currentProfile {
                        Text("\(profile.role.capitalized) • \(profile.clientSegment?.capitalized ?? "General")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Not set")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                // TODO: Navigate to role/segment selection
            }
            
            // Profile Information
            Button(action: { showingProfileEdit = true }) {
                HStack {
                    Image(systemName: "person.circle")
                        .foregroundColor(.green)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Profile")
                            .font(.body)
                            .foregroundColor(.primary)
                        if let profile = userProfileManager.currentProfile {
                            Text("\(profile.fullName ?? "No name") • \(profile.email)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Complete your profile")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            // Linked Accounts
            Button(action: { showingLinkedAccounts = true }) {
                HStack {
                    Image(systemName: "link")
                        .foregroundColor(.orange)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Linked Accounts")
                            .font(.body)
                            .foregroundColor(.primary)
                        Text("Google, Apple ID, and more")
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
        .sheet(isPresented: $showingProfileEdit) {
            ProfileEditView()
        }
        .sheet(isPresented: $showingLinkedAccounts) {
            LinkedAccountsView()
        }
    }
}

// MARK: - Placeholder Views
struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var userProfileManager = UserProfileManager.shared
    @State private var fullName = ""
    @State private var email = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    TextField("Full Name", text: $fullName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let profile = userProfileManager.currentProfile {
                    fullName = profile.fullName ?? ""
                    email = profile.email
                }
            }
        }
    }
    
    private func saveProfile() {
        // TODO: Implement profile saving
        print("Saving profile: \(fullName), \(email)")
    }
}

struct LinkedAccountsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var googleConnected = false
    @State private var appleConnected = true
    @State private var facebookConnected = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Connected Accounts") {
                    HStack {
                        Image(systemName: "applelogo")
                            .foregroundColor(.primary)
                            .frame(width: 24)
                        
                        Text("Apple ID")
                        
                        Spacer()
                        
                        if appleConnected {
                            Text("Connected")
                                .foregroundColor(.green)
                                .font(.caption)
                        } else {
                            Button("Connect") {
                                // TODO: Connect Apple ID
                            }
                            .font(.caption)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        
                        Text("Google")
                        
                        Spacer()
                        
                        if googleConnected {
                            Button("Disconnect") {
                                googleConnected = false
                            }
                            .foregroundColor(.red)
                            .font(.caption)
                        } else {
                            Button("Connect") {
                                googleConnected = true
                            }
                            .font(.caption)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "f.square")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Facebook")
                        
                        Spacer()
                        
                        if facebookConnected {
                            Button("Disconnect") {
                                facebookConnected = false
                            }
                            .foregroundColor(.red)
                            .font(.caption)
                        } else {
                            Button("Connect") {
                                facebookConnected = true
                            }
                            .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Linked Accounts")
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

// MARK: - Preview
struct AccountSettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            AccountSettingsSection()
        }
        .listStyle(GroupedListStyle())
        .environmentObject(UserProfileManager.shared)
    }
}