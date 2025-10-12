//
//  TabComponents.swift
//  HOMEY Clean
//
//  Extracted tab components from ClientTabView
//

import SwiftUI

// MARK: - Tab Options Sheet

struct TabOptionsSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedTab: Int
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 2.5)
                .fill(.secondary)
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 20)
            
            // Header
            VStack(spacing: 8) {
                Text("Quick Navigation")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                
                Text("Jump to any section")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 24)
            
            // Tab options
            VStack(spacing: 16) {
                TabOptionCard(
                    title: "Home",
                    subtitle: "Dashboard & overview",
                    icon: "house.fill",
                    tabIndex: 0,
                    selectedTab: $selectedTab,
                    isPresented: $isPresented
                )
                
                TabOptionCard(
                    title: "Search",
                    subtitle: "Find properties",
                    icon: "magnifyingglass",
                    tabIndex: 1,
                    selectedTab: $selectedTab,
                    isPresented: $isPresented
                )
                
                TabOptionCard(
                    title: "Favorites",
                    subtitle: "Saved properties",
                    icon: "heart.fill",
                    tabIndex: 2,
                    selectedTab: $selectedTab,
                    isPresented: $isPresented
                )
                
                TabOptionCard(
                    title: "Messages",
                    subtitle: "Chat & notifications",
                    icon: "message.fill",
                    tabIndex: 3,
                    selectedTab: $selectedTab,
                    isPresented: $isPresented
                )
                
                TabOptionCard(
                    title: "Profile",
                    subtitle: "Account & settings",
                    icon: "person.fill",
                    tabIndex: 4,
                    selectedTab: $selectedTab,
                    isPresented: $isPresented
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}

// MARK: - Tab Option Card

struct TabOptionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let tabIndex: Int
    @Binding var selectedTab: Int
    @Binding var isPresented: Bool
    
    var isSelected: Bool {
        selectedTab == tabIndex
    }
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedTab = tabIndex
                isPresented = false
            }
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : Theme.primaryAction)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(isSelected ? .white : .primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                }
            }
            .padding(16)
            .background(isSelected ? Theme.primaryAction : Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Second Tab Type Enum

enum SecondTabType: String, CaseIterable {
    case search = "search"
    case map = "map"
    case filters = "filters"
    
    var title: String {
        switch self {
        case .search: return "Search"
        case .map: return "Map"
        case .filters: return "Filters"
        }
    }
    
    var icon: String {
        switch self {
        case .search: return "magnifyingglass"
        case .map: return "map"
        case .filters: return "slider.horizontal.3"
        }
    }
}