//
//  DrewDirectoryView.swift
//  HOMEY Clean
//
//  Created by Assistant - Brand New Implementation
//  Refactored to a modern, chic, tab-based rolodex.
//

import SwiftUI

struct DrewDirectoryView: View {
    @StateObject private var viewModel = DrewDirectoryViewModel()
    @State private var selectedTab: DirectoryTab = .myTeam
    
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                tabSelector
                
                // Content area that switches based on the selected tab
                TabView(selection: $selectedTab) {
                    MyTeamView(teamMembers: viewModel.myTeam)
                        .tag(DirectoryTab.myTeam)
                    
                    SuggestedView(suggestedProfessionals: viewModel.suggestedProfessionals)
                        .tag(DirectoryTab.suggested)
                    
                    SearchView(viewModel: viewModel)
                        .tag(DirectoryTab.search)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .onAppear {
            viewModel.loadContacts()
        }
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Directory")
                .homeyFont(.heading)
                .foregroundColor(Theme.primaryText)
            
            Text("Your trusted professional network")
                .homeyFont(.bodyMedium)
                .foregroundColor(Theme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(DirectoryTab.allCases) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 8) {
                        Text(tab.rawValue)
                            .homeyFont(.bodyMedium)
                            .foregroundColor(selectedTab == tab ? Theme.primaryText : Theme.secondaryText)
                        
                        Rectangle()
                            .fill(selectedTab == tab ? Theme.skyBlue : Color.clear)
                            .frame(height: 2)
                            .animation(.easeInOut(duration: 0.3), value: selectedTab)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}

// MARK: - Directory Tabs Enum
private enum DirectoryTab: String, CaseIterable, Identifiable {
    case myTeam = "My Team"
    case suggested = "Suggested Team"
    case search = "Search"
    
    var id: String { self.rawValue }
}

// MARK: - "My Team" View
private struct MyTeamView: View {
    let teamMembers: [Contact]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if teamMembers.isEmpty {
                    EmptyStateView(
                        icon: "person.2.circle",
                        title: "Build Your Team",
                        subtitle: "Connect with trusted professionals to get started"
                    )
                    .padding(.top, 60)
                } else {
                    ForEach(teamMembers) { member in
                        TeamMemberCard(contact: member)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - "Suggested" View
private struct SuggestedView: View {
    let suggestedProfessionals: [Contact]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Recommended for You")
                    .homeyFont(.title)
                    .foregroundColor(Theme.primaryText)
                    .padding(.horizontal, 24)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(suggestedProfessionals.prefix(6)) { professional in
                            SuggestedProfessionalCard(contact: professional)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
            .padding(.vertical, 16)
        }
    }
}

// MARK: - "Search" View
private struct SearchView: View {
    @ObservedObject var viewModel: DrewDirectoryViewModel
    @State private var searchText = ""
    @State private var selectedCategory: ProfessionalCategory = .all
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Theme.secondaryText)
                        .font(.system(size: 16, weight: .medium))
                    
                    TextField("Search by name, role, or expertise...", text: $searchText)
                        .homeyFont(.bodyMedium)
                        .foregroundColor(Theme.primaryText)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                        
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Theme.skyBlue.opacity(0.3), lineWidth: 1)
                    }
                )
                
                // Category Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(ProfessionalCategory.allCases) { category in
                            CategoryPill(
                                category: category,
                                isSelected: selectedCategory == category,
                                action: { 
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedCategory = category 
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                // Search Results
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.filteredContacts) { contact in
                        SearchResultCard(contact: contact)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - Empty State View
private struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(Theme.skyBlue.opacity(0.6))
            
            VStack(spacing: 8) {
                Text(title)
                    .homeyFont(.title)
                    .foregroundColor(Theme.primaryText)
                
                Text(subtitle)
                    .homeyFont(.bodyMedium)
                    .foregroundColor(Theme.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
    }
}

// MARK: - Reusable UI Components

private struct TeamMemberCard: View {
    let contact: Contact
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Theme.skyBlue.opacity(0.8), Theme.skyBlue.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 56, height: 56)
                .overlay {
                    Text(String(contact.name.prefix(1)))
                        .homeyFont(.title)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
            
            // Contact Info
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .homeyFont(.bodyLarge)
                    .foregroundColor(Theme.primaryText)
                
                Text(contact.role.displayName)
                    .homeyFont(.bodyMedium)
                    .foregroundColor(Theme.secondaryText)
                
                if let company = contact.company {
                    Text(company)
                        .homeyFont(.caption)
                        .foregroundColor(Theme.secondaryText.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Quick Actions
            HStack(spacing: 16) {
                Button(action: {}) {
                    Image(systemName: "message.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Theme.skyBlue)
                }
                
                Button(action: {}) {
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Theme.skyBlue)
                }
            }
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [Theme.skyBlue.opacity(0.3), Theme.skyBlue.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
    }
}

private struct SuggestedProfessionalCard: View {
    let contact: Contact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Avatar and Rating
            HStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.skyBlue.opacity(0.8), Theme.skyBlue.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay {
                        Text(String(contact.name.prefix(1)))
                            .homeyFont(.bodyLarge)
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    
                    Text(contact.displayTrustScore)
                        .homeyFont(.caption)
                        .foregroundColor(Theme.secondaryText)
                }
            }
            
            // Contact Info
            VStack(alignment: .leading, spacing: 6) {
                Text(contact.name)
                    .homeyFont(.bodyLarge)
                    .foregroundColor(Theme.primaryText)
                    .lineLimit(1)
                
                Text(contact.role.displayName)
                    .homeyFont(.bodyMedium)
                    .foregroundColor(Theme.secondaryText)
                    .lineLimit(1)
                
                if let company = contact.company {
                    Text(company)
                        .homeyFont(.caption)
                        .foregroundColor(Theme.secondaryText.opacity(0.8))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Connect Button
            Button(action: {}) {
                Text("Connect")
                    .homeyFont(.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Theme.skyBlue)
                    )
            }
        }
        .frame(width: 180, height: 220)
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [Theme.skyBlue.opacity(0.2), Theme.skyBlue.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
    }
}

private struct CategoryPill: View {
    let category: ProfessionalCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.title)
                .homeyFont(.button)
                .foregroundColor(isSelected ? .white : Theme.primaryText)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    ZStack {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Theme.skyBlue)
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                            
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Theme.skyBlue.opacity(0.3), lineWidth: 1)
                        }
                    }
                )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

private struct SearchResultCard: View {
    let contact: Contact
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Theme.skyBlue.opacity(0.8), Theme.skyBlue.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, height: 48)
                .overlay {
                    Text(String(contact.name.prefix(1)))
                        .homeyFont(.bodyLarge)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
            
            // Contact Info
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .homeyFont(.bodyLarge)
                    .foregroundColor(Theme.primaryText)
                
                Text(contact.role.displayName)
                    .homeyFont(.bodyMedium)
                    .foregroundColor(Theme.secondaryText)
                
                if let company = contact.company {
                    Text(company)
                        .homeyFont(.caption)
                        .foregroundColor(Theme.secondaryText.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Rating and Action
            VStack(alignment: .trailing, spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    
                    Text(contact.displayTrustScore)
                        .homeyFont(.caption)
                        .foregroundColor(Theme.secondaryText)
                }
                
                Button(action: {}) {
                    Text("View")
                        .homeyFont(.button)
                        .foregroundColor(Theme.skyBlue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Theme.skyBlue, lineWidth: 1)
                        )
                }
            }
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.skyBlue.opacity(0.2), lineWidth: 1)
            }
        )
    }
}


// MARK: - Professional Categories
private enum ProfessionalCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case realEstate = "Real Estate"
    case legal = "Legal"
    case financial = "Financial"
    case inspection = "Inspection"
    case insurance = "Insurance"
    case mortgage = "Mortgage"
    
    var id: String { self.rawValue }
    var title: String { self.rawValue }
}

#if DEBUG
struct DrewDirectoryView_Previews: PreviewProvider {
    static var previews: some View {
        DrewDirectoryView()
            .preferredColorScheme(.dark)
    }
}
#endif