//
//  NavigationComponents.swift
//  HOMEY Clean
//
//  Navigation-related components extracted from ClientTabView
//

import SwiftUI

// MARK: - Tab Views

struct InsightsTabView: View {
    var body: some View {
        IslaRootView()
    }
}

struct DirectoryTabView: View {
    var body: some View {
        DrewDirectoryView()
    }
}

struct VisionTabView: View {
    var body: some View {
        VizaVisionView()
    }
}

struct DocumentsTabView: View {
    var body: some View {
        NavigationStack {
            DocumentVaultView(vm: DocumentsViewModel())
                .navigationTitle("Vault")
                .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SearchTabViewSimple: View {
    var body: some View {
        NavigationStack {
            SearchView()
                .navigationTitle("Discover")
                .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Placeholder Views

struct SettingsPlaceholderView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        NavigationStack {
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