//
//  ContentView.swift
//  HOMEY Clean Codex
//
//  Main navigation structure for the app
//

import SwiftUI

// MARK: - Tab Item Model

struct TabItem {
    let id: Int
    let title: String
    let icon: String
}

struct ContentView: View {
    @State private var selectedTab = 0

    private let tabs = [
        TabItem(id: 0, title: "Scout", icon: "scope"),
        TabItem(id: 1, title: "Isla", icon: "chart.line.uptrend.xyaxis"),
        TabItem(id: 2, title: "Dashboard", icon: "house.fill"),
        TabItem(id: 3, title: "Profile", icon: "person.fill")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Main content area
            Group {
                switch selectedTab {
                case 0:
                    ScoutRootView()
                case 1:
                    IslaRootView()
                case 2:
                    DashboardView()
                case 3:
                    ProfileView()
                default:
                    ScoutRootView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom horizontally scrollable footer
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(tabs, id: \.id) { tab in
                        Button(action: {
                            selectedTab = tab.id
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(selectedTab == tab.id ? .blue : .gray)

                                Text(tab.title)
                                    .font(.caption)
                                    .foregroundColor(selectedTab == tab.id ? .blue : .gray)
                            }
                            .frame(minWidth: 80, maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            .background(.ultraThinMaterial)
            .frame(height: 60)
        }
    }
}

// MARK: - Placeholder Views

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "house.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Your property insights and analytics")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .navigationTitle("Dashboard")
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "person.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Manage your account and preferences")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}