//
//  JourneyNavigationView.swift
//  HOMEY Clean
//
//  Navigation wrapper for the journey episode system
//

import SwiftUI

struct JourneyNavigationView: View {
    @State private var selectedTab: JourneyTab = .episodes
    @State private var showingProfile = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.black, .purple.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom navigation header
                    navigationHeader
                    
                    // Tab content
                    TabView(selection: $selectedTab) {
                        // Episodes tab
                        JourneyEpisodeInterface()
                            .tag(JourneyTab.episodes)
                        
                        // Progress tab
                        JourneyProgressView()
                            .tag(JourneyTab.progress)
                        
                        // Achievements tab
                        JourneyAchievementsView()
                            .tag(JourneyTab.achievements)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Custom tab bar
                    customTabBar
                }
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
    }
    
    // MARK: - Navigation Header
    
    private var navigationHeader: some View {
        HStack {
            // HOMEY logo/title
            VStack(alignment: .leading, spacing: 2) {
                Text("HOMEY")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Your Journey")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Profile button
            Button {
                showingProfile = true
            } label: {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial)
                    
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    // MARK: - Custom Tab Bar
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(JourneyTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.title3)
                            .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.6))
                        
                        Text(tab.title)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedTab == tab ? .white.opacity(0.2) : .clear)
                            .animation(.easeInOut(duration: 0.2), value: selectedTab)
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Journey Tab Enum

enum JourneyTab: CaseIterable {
    case episodes
    case progress
    case achievements
    
    var title: String {
        switch self {
        case .episodes: return "Episodes"
        case .progress: return "Progress"
        case .achievements: return "Rewards"
        }
    }
    
    var icon: String {
        switch self {
        case .episodes: return "play.rectangle.fill"
        case .progress: return "chart.line.uptrend.xyaxis"
        case .achievements: return "trophy.fill"
        }
    }
}

// MARK: - Placeholder Views

struct JourneyProgressView: View {
    @State private var overallProgress: Double = 0.65 // Mock progress - will be dynamic
    @State private var animateProgress = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.black, .purple.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Circular Progress Tracker
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 12)
                        .frame(width: 200, height: 200)
                    
                    // Progress circle
                    Circle()
                        .trim(from: 0, to: animateProgress ? overallProgress : 0)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.5), value: animateProgress)
                    
                    // Center content
                    VStack(spacing: 8) {
                        Text("\(Int(overallProgress * 100))%")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Complete")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                // Progress Details
                VStack(spacing: 16) {
                    Text("Journey Progress")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        ProgressDetailRow(
                            title: "Documents",
                            progress: 0.8,
                            icon: "doc.fill",
                            color: .blue
                        )
                        
                        ProgressDetailRow(
                            title: "Property Search",
                            progress: 0.6,
                            icon: "house.fill",
                            color: .green
                        )
                        
                        ProgressDetailRow(
                            title: "Financial Prep",
                            progress: 0.4,
                            icon: "dollarsign.circle.fill",
                            color: .orange
                        )
                        
                        ProgressDetailRow(
                            title: "Agent Connection",
                            progress: 1.0,
                            icon: "person.2.fill",
                            color: .purple
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).delay(0.3)) {
                animateProgress = true
            }
        }
    }
}

// MARK: - Progress Detail Row
struct ProgressDetailRow: View {
    let title: String
    let progress: Double
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Title
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            // Mini progress bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 60, height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: 60 * progress, height: 8)
            }
            
            // Percentage
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .frame(width: 30, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

struct JourneyAchievementsView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.black, .purple.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.6))
                
                VStack(spacing: 8) {
                    Text("Achievements & Rewards")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Coming Soon")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
}

// ProfileView is already defined in ContentView.swift

// MARK: - Preview

#Preview {
    JourneyNavigationView()
        .preferredColorScheme(.dark)
}