import SwiftUI
import UIKit

struct ProfileTabView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject private var session: AppSessionManager
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showOnboarding = false
    @State private var showSettings = false
    @State private var showNotifications = false
    @State private var showMilestoneCelebration = false
    @State private var currentMilestone = ""
    @State private var showHomepageCustomization = false
    
    var body: some View {
        ZStack {
            // Use animated gradient background
            AnimatedGradient(colors: [
                Color(hex: "667eea"),
                Color(hex: "764ba2"),
                Color(hex: "f093fb"),
                Color(hex: "f5576c")
            ])
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Header section
                    headerSection
                    
                    // Journey Progress Card
                    journeyProgressCard
                    
                    // Profile Sections
                    profileSectionsView
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            
            // Milestone celebration overlay
            if showMilestoneCelebration {
                MilestoneCelebrationView(
                    milestone: currentMilestone,
                    isVisible: showMilestoneCelebration,
                    onComplete: {
                        showMilestoneCelebration = false
                    }
                )
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            themeManager.setCurrentPage(.profile)
            viewModel.loadProfile()
            if viewModel.needsOnboarding {
                showOnboarding = true
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingModalView(isPresented: $showOnboarding, onComplete: {
                viewModel.completeOnboarding()
            })
        }
        .sheet(isPresented: $showSettings) {
            ProfileSettingsSheet(isPresented: $showSettings)
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsSheet(isPresented: $showNotifications, notifications: viewModel.notifications)
        }
        .sheet(isPresented: $showHomepageCustomization) {
            HomepageCustomizationSheet()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                // User greeting at top left
                if let profile = session.userProfile {
                    Text("Hi, \(profile.fullName?.components(separatedBy: " ").first ?? "there")!")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                } else {
                    Text("Hi there!")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                
                Text("Your Profile")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Text("Manage • Track • Connect")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Profile avatar with progress ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: viewModel.overallProgress)
                    .stroke(
                        LinearGradient(
                            colors: themeManager.currentTheme.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 54, height: 54)
                
                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Journey Progress Card
    private var journeyProgressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.3), .pink.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "heart.fill")
                        .font(.headline.bold())
                        .foregroundColor(.pink)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.journeyStage.storyMilestone)
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .transition(.opacity.combined(with: .slide))
                        .animation(.easeInOut(duration: 0.5), value: viewModel.journeyStage)
                    
                    Text("\(Int(viewModel.overallProgress * 100))% of your journey complete")
                        .font(.subheadline)
                        .foregroundColor(viewModel.overallProgress > 0.8 ? .green : .gray)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.overallProgress)
                }
                
                Spacer()
            }
            
            // Story-driven progress visualization with enhanced animations
            VStack(alignment: .leading, spacing: 12) {
                Text(viewModel.journeyStage.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
                    .transition(.opacity.combined(with: .slide))
                    .animation(.easeInOut(duration: 0.5), value: viewModel.journeyStage)
                
                // Apple Ring-like circular progress indicator
                HStack(spacing: 20) {
                    ZStack {
                        // Background ring
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                            .frame(width: 80, height: 80)
                        
                        // Progress ring
                        Circle()
                            .trim(from: 0, to: viewModel.overallProgress)
                            .stroke(
                                LinearGradient(
                                    colors: [.pink, .purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1.0), value: viewModel.overallProgress)
                        
                        // Center percentage text
                        VStack(spacing: 2) {
                            Text("\(Int(viewModel.overallProgress * 100))")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            Text("%")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .onTapGesture {
                        if viewModel.overallProgress > 0.8 {
                            triggerMilestoneCelebration()
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Journey Progress")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                        
                        Text("Keep going! You're making great progress on your home buying journey.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(3)
                    }
                    
                    Spacer()
                }
                
                // Emotional context with gentle animation
                HStack {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundColor(.pink)
                        .scaleEffect(viewModel.overallProgress > 0.8 ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.6).repeatCount(viewModel.overallProgress > 0.8 ? 3 : 1, autoreverses: true), value: viewModel.overallProgress)
                    
                    Text(viewModel.journeyStage.emotionalContext)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .italic()
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                        .animation(.easeInOut(duration: 0.4), value: viewModel.journeyStage)
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: themeManager.currentTheme.gradientColors.map { $0.opacity(0.2) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: themeManager.currentTheme.gradientColors.map { $0.opacity(0.3) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    // MARK: - Quick Actions Card
    private var quickActionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "bolt.fill")
                        .font(.headline.bold())
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quick Actions")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    
                    Text("Manage your profile and settings")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            // Quick action buttons
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ProfileQuickActionButton(title: "Upload tax return to complete Vault", icon: "doc.badge.plus", color: .blue) {
                    // Handle vault completion
                }
                ProfileQuickActionButton(title: "Confirm showing at 500 Park", icon: "calendar.badge.clock", color: .orange) {
                    // Handle showing confirmation
                }
                ProfileQuickActionButton(title: "Sign board package draft", icon: "signature", color: .purple) {
                    // Handle document signing
                }
                ProfileQuickActionButton(title: "Settings", icon: "gearshape.fill", color: .gray) {
                    showSettings = true
                }
            }
        }
        .padding(20)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(16)
    }
    
    // MARK: - Profile Sections
    private var profileSectionsView: some View {
        VStack(spacing: 12) {
            ProfileSectionCard(
                title: "Homepage Customization",
                description: "Personalize your homepage layout and theme preferences",
                icon: "square.grid.2x2",
                color: .purple,
                hasNewContent: false
            ) {
                showHomepageCustomization = true
            }
            
            ProfileSectionCard(
                title: "Milestones",
                description: "Timeline view of completed and upcoming steps",
                icon: "flag.checkered",
                color: .green,
                hasNewContent: false
            ) {
                // Handle milestones tap
            }
            
            ProfileSectionCard(
                title: "Agent Updates",
                description: "Push notifications and messages from your agent",
                icon: "bell.badge.fill",
                color: .orange,
                hasNewContent: true
            ) {
                // Handle agent updates tap
            }
        }
    }
    
    // MARK: - Next Step CTA
    private var nextStepCTACard: some View {
        Button(action: {
            // Handle next step action based on journey state
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2.bold())
                        .foregroundColor(.purple)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next Step")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    
                    Text(getNextStepDescription())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getNextStepDescription() -> String {
        // Dynamic description based on user's journey state with emotional context
        switch viewModel.journeyStage {
        case .exploring:
            return "Let's start exploring properties that could steal your heart ✨"
        case .researching:
            return "Continue discovering neighborhoods where your story could unfold 🏡"
        case .viewing:
            return "Schedule your next property viewing - your perfect match awaits 💕"
        case .negotiating:
            return "Time to make your move - your dream home is within reach 🎯"
        case .closing:
            return "Almost there! Let's prepare for your keys-in-hand moment 🗝️"
        case .settled:
            return "Explore ways to make your new space uniquely yours 🌟"
        }
    }
    
    // MARK: - Celebration Functions
    
    private func triggerMilestoneCelebration() {
        currentMilestone = getMilestoneMessage()
        showMilestoneCelebration = true
    }
    
    private func getMilestoneMessage() -> String {
        switch viewModel.journeyStage {
        case .exploring:
            return "You've started your home journey! 🏠"
        case .researching:
            return "Research milestone achieved! 📚"
        case .viewing:
            return "Property viewing expert! 👀"
        case .negotiating:
            return "Negotiation skills unlocked! 💪"
        case .closing:
            return "Almost at the finish line! 🏁"
        case .settled:
            return "Welcome home! 🎉"
        }
    }
}

// MARK: - Profile Quick Action Button
struct ProfileQuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.headline.bold())
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Profile Section Card
struct ProfileSectionCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let hasNewContent: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title2.bold())
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.headline.bold())
                            .foregroundColor(.white)
                        
                        if hasNewContent {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                        }
                        
                        Spacer()
                    }
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Profile Settings Sheet
struct ProfileSettingsSheet: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Settings")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        // Settings content placeholder
                        VStack(spacing: 12) {
                            SettingsRow(title: "Account", icon: "person.circle.fill", color: .blue)
                            SettingsRow(title: "Notifications", icon: "bell.fill", color: .orange)
                            SettingsRow(title: "Privacy", icon: "lock.fill", color: .purple)
                            SettingsRow(title: "Support", icon: "questionmark.circle.fill", color: .green)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.headline.bold())
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(12)
    }
}

// MARK: - Notifications Sheet
struct NotificationsSheet: View {
    @Binding var isPresented: Bool
    let notifications: [ProfileNotification]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Notifications")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(notifications) { notification in
                                NotificationRowView(notification: notification)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                isPresented = false
            })
        }
    }
}

// MARK: - Liquid Glass Progress View
struct LiquidGlassProgressView: View {
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Journey Progress")
                .font(.title2)
                .fontWeight(.semibold)
            
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .frame(height: 60)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    }
                
                // Progress Fill
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.8),
                                Color.purple.opacity(0.6)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, CGFloat(progress) * (UIScreen.main.bounds.width - 32)), height: 60)
                    .overlay {
                        // Shimmer effect
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.3),
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: false), value: progress)
                    }
                
                // Progress Text
                HStack {
                    Text("\(Int(progress * 100))% Complete")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Quick Stats View
struct QuickStatsView: View {
    let marketInsights: MarketInsights?
    let vendorSuggestions: [VendorSuggestion]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Stats")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                // Market Insights
                if let insights = marketInsights {
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Market Snapshot - \(insights.area)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Median Rent")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(insights.medianRent)
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text("Median Sale")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(insights.medianSale)
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                HStack(spacing: 4) {
                                    Image(systemName: insights.trendDirection.icon)
                                        .font(.caption)
                                        .foregroundColor(insights.trendDirection.color)
                                    Text("\(insights.trendPercentage, specifier: "%.1f")%")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(insights.trendDirection.color)
                                }
                                
                                Text("\(insights.daysOnMarket) DOM")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Text(insights.pricePerSqFt + "/sqft")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                }
                
                // Vendor Suggestions
                if !vendorSuggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recommended for You")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ForEach(vendorSuggestions.prefix(2), id: \.id) { vendor in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(vendor.name)
                                        .font(.headline)
                                        .fontWeight(.medium)
                                    
                                    Text(vendor.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    HStack(spacing: 2) {
                                        Image(systemName: "star.fill")
                                            .font(.caption2)
                                            .foregroundColor(.yellow)
                                        Text("\(vendor.rating, specifier: "%.1f")")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    
                                    Text(vendor.category)
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(.blue.opacity(0.2))
                                        .cornerRadius(4)
                                }
                            }
                            .padding(.vertical, 8)
                            
                            if vendor.id != vendorSuggestions.prefix(2).last?.id {
                                Divider()
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                }
            }
        }
    }
}

// MARK: - Agent Card View
struct AgentCardView: View {
    let agent: Agent?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Agent")
                .font(.title2)
                .fontWeight(.semibold)
            
            if let agent = agent {
                HStack(spacing: 16) {
                    AsyncImage(url: URL(string: agent.avatarURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(.gray.opacity(0.3))
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(agent.name)
                            .font(.headline)
                        Text(agent.title)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(agent.experience) years experience")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Button("Message") {
                            // Handle message action
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        
                        Button("Call") {
                            // Handle call action
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            } else {
                VStack(spacing: 12) {
                    Text("No agent assigned")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Button("Find an Agent") {
                        // Handle agent assignment
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Notifications Feed View
struct NotificationsFeedView: View {
    let notifications: [ProfileNotification]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Updates")
                .font(.title2)
                .fontWeight(.semibold)
            
            if notifications.isEmpty {
                Text("No recent updates")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(notifications, id: \.id) { notification in
                        NotificationRowView(notification: notification)
                    }
                }
            }
        }
    }
}

struct NotificationRowView: View {
    let notification: ProfileNotification
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: notification.iconName)
                .font(.title3)
                .foregroundColor(notification.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(.headline)
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(notification.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !notification.isRead {
                Circle()
                    .fill(.blue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

#Preview {
    ProfileTabView()
}