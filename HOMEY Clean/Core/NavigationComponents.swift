//
//  NavigationComponents.swift
//  HOMEY Clean
//
//  Navigation-related components extracted from ClientTabView
//

import SwiftUI

// MARK: - Tab Views

struct InsightsTabView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ZStack {
            AnimatedGradientBackground(for: .insights)
                .ignoresSafeArea()

            // Lightweight, readable Insights overview (no video)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Market Insights")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.white.opacity(0.9))
                    }

                    // Key stats row
                    HStack(spacing: 12) {
                        InsightStatCard(title: "Median Price", value: "$845k", trend: "+2.1%", trendUp: true)
                        InsightStatCard(title: "Days on Market", value: "34", trend: "-4d", trendUp: true)
                        InsightStatCard(title: "Inventory", value: "1,284", trend: "-3.2%", trendUp: false)
                    }

                    // Simple sections
                    VStack(spacing: 12) {
                        InsightSectionCard(
                            title: "Neighborhood Trends",
                            subtitle: "See top 3 areas rising this month",
                            icon: "map.fill",
                            color: .blue
                        )

                        InsightSectionCard(
                            title: "Rate Watch",
                            subtitle: "Mortgage rates moved slightly this week",
                            icon: "percent",
                            color: .orange
                        )

                        InsightSectionCard(
                            title: "Buyer Signals",
                            subtitle: "High-intent activity in your saved areas",
                            icon: "bell.badge.fill",
                            color: .purple
                        )
                    }

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            themeManager.setCurrentPage(.insights)
        }
    }
}

private struct InsightStatCard: View {
    let title: String
    let value: String
    let trend: String
    let trendUp: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.white)
            HStack(spacing: 6) {
                Image(systemName: trendUp ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption)
                Text(trend)
                    .font(.caption)
            }
            .foregroundColor(trendUp ? .green : .red)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

private struct InsightSectionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.5))
                .font(.caption.bold())
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
    }
}

struct DirectoryTabView: View {
    var body: some View {
        DrewDirectoryView()
            .navigationTitle("Directory")
            .navigationBarTitleDisplayMode(.large)
    }
}

struct VisionTabView: View {
    var body: some View {
        VizaVisionView()
            .navigationTitle("Vision")
            .navigationBarTitleDisplayMode(.large)
    }
}

struct DocumentsTabView: View {
    var body: some View {
        DocumentVaultView(vm: DocumentsViewModel())
            .navigationTitle("Vault")
            .navigationBarTitleDisplayMode(.large)
    }
}

struct SearchTabViewSimple: View {
    var body: some View {
        SearchView()
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Placeholder Views

struct SettingsPlaceholderView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            
            Text("Settings coming soon")
                .padding()
                .foregroundColor(.white)
        }
        .navigationTitle("Settings")
        .onAppear {
            themeManager.setCurrentPage(.settings)
        }
    }
}

struct MatchmakerPlaceholderView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundColor(.pink)
            
            Text("Matchmaker")
                .font(.title.bold())
            
            Text("Find your perfect property match")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct ARFeaturesPlaceholderView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "arkit")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("AR Features")
                .font(.title.bold())
            
            Text("Explore properties with augmented reality")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Coming Soon") {
                // Placeholder action
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}