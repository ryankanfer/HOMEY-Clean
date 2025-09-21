//
//  DrewDirectoryView.swift
//  HOMEY Clean
//
//  Created by Assistant - Brand New Implementation
//

import SwiftUI

struct DrewDirectoryView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var viewModel = DrewDirectoryViewModel()
    @State private var searchText = ""
    @State private var selectedCategory: ProfessionalCategory = .all
    @State private var showingFilters = false
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradient(
                colors: [
                    Color(hex: "FF6B6B"),
                    Color(hex: "4ECDC4"),
                    Color(hex: "45B7D1"),
                    Color(hex: "96CEB4")
                ],
                speed: 0.8
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Section
                    heroSection
                    
                    // Search and Filters
                    searchSection
                    
                    // Professional Categories
                    categoriesSection
                    
                    // Featured Professionals
                    featuredSection
                    
                    // All Professionals Grid
                    professionalsGrid
                    
                    // HOMEY Footer
                    HomeyFooter()
                        .padding(.top, 40)
                }
            }
        }
        .onAppear {
            viewModel.loadContacts()
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Drew's Directory")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Connect with trusted professionals")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Drew Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        VStack(spacing: 16) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.7))
                
                TextField("Search professionals...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .onChange(of: searchText) { _, newValue in
                        viewModel.searchContacts(query: newValue)
                    }
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.2))
                    .background(.ultraThinMaterial)
            )
            .padding(.horizontal, 24)
            
            // Filter Button
            Button(action: { showingFilters.toggle() }) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("Filters")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.2))
                )
            }
        }
    }
    
    // MARK: - Categories Section
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Categories")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ProfessionalCategory.allCases, id: \.self) { category in
                        DrewCategoryCard(
                            category: category,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Featured Section
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Featured Professionals")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.featuredContacts) { contact in
                        FeaturedProfessionalCard(contact: contact)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Professionals Grid
    private var professionalsGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Professionals")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(viewModel.filteredContacts) { contact in
                    DrewProfessionalCard(contact: contact)
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 20)
    }
}

// MARK: - Supporting Views

struct DrewCategoryCard: View {
    let category: ProfessionalCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                
                Text(category.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
}

struct FeaturedProfessionalCard: View {
    let contact: Contact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Profile Image
            if let urlString = contact.avatarURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white.opacity(0.5))
                        )
                }
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white.opacity(0.5))
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(contact.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(contact.role.displayName)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(contact.displayTrustScore)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .frame(width: 140)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
                .background(.ultraThinMaterial)
        )
    }
}

struct DrewProfessionalCard: View {
    let contact: Contact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Profile Image
            if let urlString = contact.avatarURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white.opacity(0.5))
                        )
                }
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.15))
                    .frame(height: 100)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white.opacity(0.5))
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(contact.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text(contact.role.displayName)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                
                if let company = contact.company {
                    Text(company)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(contact.displayTrustScore)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(contact.yearsExperience) yrs")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
                .background(.ultraThinMaterial)
        )
    }
}

// MARK: - Data Models (local category enum used by this view)

enum ProfessionalCategory: CaseIterable {
    case all, realEstate, legal, financial, inspection, insurance, moving
    
    var title: String {
        switch self {
        case .all: return "All"
        case .realEstate: return "Real Estate"
        case .legal: return "Legal"
        case .financial: return "Financial"
        case .inspection: return "Inspection"
        case .insurance: return "Insurance"
        case .moving: return "Moving"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "grid.circle.fill"
        case .realEstate: return "house.fill"
        case .legal: return "scale.3d"
        case .financial: return "dollarsign.circle.fill"
        case .inspection: return "magnifyingglass.circle.fill"
        case .insurance: return "shield.fill"
        case .moving: return "truck.box.fill"
        }
    }
}

#Preview {
    DrewDirectoryView()
        .environmentObject(ThemeManager.shared)
}