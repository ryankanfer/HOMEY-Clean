//
//  ComprehensiveOnboardingFlow.swift
//  HOMEY Clean
//
//  Comprehensive onboarding with immersive storytelling
//

import SwiftUI

public struct ComprehensiveOnboardingFlow: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: AppSessionManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var currentStage: OnboardingStage = .welcome
    @State private var progress: Double = 0
    @State private var showContent = false
    @State private var selectedRole: String?
    @State private var selectedSegment: String?
    @State private var userGoals: Set<String> = []
    @State private var preferences = OnboardingFlowPreferences()

    private let onComplete: (() -> Void)?

    public init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
    }

    public var body: some View {
        ZStack {
            // Dynamic background based on current stage
            stageBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress header
                OnboardingProgressHeader(
                    stage: currentStage,
                    progress: progress,
                    onSkip: completeOnboarding
                )

                // Main content area
                TabView(selection: Binding(
                    get: { currentStage },
                    set: { newStage in
                        withAnimation(.easeInOut(duration: 0.6)) {
                            currentStage = newStage
                            updateProgress()
                        }
                    }
                )) {
                    welcomeStage.tag(OnboardingStage.welcome)
                    roleSelectionStage.tag(OnboardingStage.roleSelection)
                    goalSettingStage.tag(OnboardingStage.goalSetting)
                    preferencesStage.tag(OnboardingStage.preferences)
                    teamIntroductionStage.tag(OnboardingStage.teamIntroduction)
                    readyStage.tag(OnboardingStage.ready)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.4), value: currentStage)

                // Navigation footer
                OnboardingNavigationFooter(
                    stage: currentStage,
                    canProceed: canProceedFromCurrentStage,
                    onBack: goBack,
                    onNext: goNext,
                    onComplete: completeOnboarding
                )
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                showContent = true
            }
        }
    }

    // MARK: - Stage Backgrounds

    @ViewBuilder
    private var stageBackground: some View {
        ZStack {
            AnimatedSkyGradient()

            Group {
                switch currentStage {
                case .welcome:
                    LinearGradient(
                        colors: [Color.blue.opacity(0.3), Color.clear, Color.purple.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                case .roleSelection:
                    LinearGradient(
                        colors: [Color.green.opacity(0.2), Color.clear, Color.teal.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                case .goalSetting:
                    LinearGradient(
                        colors: [Color.orange.opacity(0.2), Color.clear, Color.yellow.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                case .preferences:
                    LinearGradient(
                        colors: [Color.purple.opacity(0.2), Color.clear, Color.pink.opacity(0.3)],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                case .teamIntroduction:
                    LinearGradient(
                        colors: [Color.cyan.opacity(0.2), Color.clear, Color.blue.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                case .ready:
                    LinearGradient(
                        colors: [Color.green.opacity(0.3), Color.clear, Color.mint.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
            .animation(.easeInOut(duration: 1.0), value: currentStage)

            LinearGradient(
                colors: [Color.black.opacity(0.3), .clear, Color.black.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    // MARK: - Onboarding Stages

    private var welcomeStage: some View {
        OnboardingStageView(
            title: "Welcome to Your Journey",
            subtitle: "Let's create your personalized HOMEY experience"
        ) {
            VStack(spacing: 32) {
                // Animated welcome illustration
                VStack(spacing: 16) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.white)
                        .symbolEffect(.bounce.up, options: .repeat(.continuous).speed(0.5))

                    Text("Your story begins here")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .scaleEffect(showContent ? 1.0 : 0.8)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3), value: showContent)

                // Welcome message
                VStack(spacing: 16) {
                    Text("Every great home story starts with understanding what matters most to you.")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)

                    Text(
                        "In the next few minutes, we'll learn about your goals, preferences, and introduce you to your personal real estate team."
                    )
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.8).delay(0.8), value: showContent)
            }
        }
    }

    private var roleSelectionStage: some View {
        OnboardingStageView(
            title: "What brings you to HOMEY?",
            subtitle: "Choose your primary role to personalize your experience"
        ) {
            VStack(spacing: 24) {
                // Role selection cards
                VStack(spacing: 16) {
                    RoleSelectionCard(
                        role: "client",
                        title: "I'm looking for a home",
                        description: "Buying, renting, or selling property",
                        icon: "house.fill",
                        isSelected: selectedRole == "client"
                    ) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            selectedRole = "client"
                        }
                    }

                    RoleSelectionCard(
                        role: "agent",
                        title: "I'm a real estate professional",
                        description: "Agent, broker, or industry expert",
                        icon: "person.badge.key.fill",
                        isSelected: selectedRole == "agent"
                    ) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            selectedRole = "agent"
                        }
                    }
                }

                // Client segment selection (if client role selected)
                if selectedRole == "client" {
                    VStack(spacing: 12) {
                        Text("What type of client are you?")
                            .font(.headline.weight(.medium))
                            .foregroundStyle(.white)

                        ClientSegmentPicker(selectedSegment: Binding(
                            get: { selectedSegment ?? "renter" },
                            set: { selectedSegment = $0 }
                        ))
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }

    private var goalSettingStage: some View {
        OnboardingStageView(
            title: "What are your goals?",
            subtitle: "Select all that apply to customize your experience"
        ) {
            VStack(spacing: 20) {
                let goals = getGoalsForRole(selectedRole ?? "client")

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(goals, id: \.id) { goal in
                        GoalSelectionCard(
                            goal: goal,
                            isSelected: userGoals.contains(goal.id)
                        ) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                if userGoals.contains(goal.id) {
                                    userGoals.remove(goal.id)
                                } else {
                                    userGoals.insert(goal.id)
                                }
                            }
                        }
                    }
                }

                if !userGoals.isEmpty {
                    Text("\(userGoals.count) goal\(userGoals.count == 1 ? "" : "s") selected")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .transition(.opacity)
                }
            }
        }
    }

    private var preferencesStage: some View {
        OnboardingStageView(
            title: "Fine-tune your preferences",
            subtitle: "Help us personalize your HOMEY experience"
        ) {
            VStack(spacing: 24) {
                PreferenceSection(
                    title: "Communication",
                    icon: "message.fill"
                ) {
                    VStack(spacing: 12) {
                        PreferenceToggle(
                            title: "Push notifications",
                            description: "Get updates on your home search",
                            isOn: $preferences.pushNotifications
                        )

                        PreferenceToggle(
                            title: "Email summaries",
                            description: "Weekly digest of your activity",
                            isOn: $preferences.emailSummaries
                        )
                    }
                }

                PreferenceSection(
                    title: "Experience",
                    icon: "sparkles"
                ) {
                    VStack(spacing: 12) {
                        PreferenceToggle(
                            title: "Guided tours",
                            description: "Show helpful tips as you explore",
                            isOn: $preferences.guidedTours
                        )

                        PreferenceToggle(
                            title: "Advanced features",
                            description: "Enable power-user tools",
                            isOn: $preferences.advancedFeatures
                        )
                    }
                }
            }
        }
    }

    private var teamIntroductionStage: some View {
        OnboardingStageView(
            title: "Meet Your Dream Team",
            subtitle: "Your personal HOMEY crew, ready to help"
        ) {
            VStack(spacing: 20) {
                Text(
                    "Each team member specializes in different aspects of your real estate journey. They'll appear when you need them most."
                )
                .font(.body.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)

                // Team member cards
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(HomeyKind.allCases), id: \.self) { kind in
                            TeamMemberIntroCard(kind: kind)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .frame(maxHeight: 300)
            }
        }
    }

    private var readyStage: some View {
        OnboardingStageView(
            title: "You're All Set!",
            subtitle: "Your personalized HOMEY experience awaits"
        ) {
            VStack(spacing: 32) {
                // Success animation
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.green)
                        .symbolEffect(.bounce.up, options: .repeat(.continuous).speed(0.3))

                    Text("Welcome to HOMEY!")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                }

                // Summary of selections
                OnboardingSummaryCard(
                    role: selectedRole ?? "client",
                    segment: selectedSegment,
                    goalCount: userGoals.count
                )

                Text("Your journey to the perfect home starts now. Let's make it happen together.")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Navigation Logic

    private var canProceedFromCurrentStage: Bool {
        switch currentStage {
        case .welcome:
            return true
        case .roleSelection:
            return selectedRole != nil
        case .goalSetting:
            return !userGoals.isEmpty
        case .preferences:
            return true
        case .teamIntroduction:
            return true
        case .ready:
            return true
        }
    }

    private func goBack() {
        guard let currentIndex = OnboardingStage.allCases.firstIndex(of: currentStage),
              currentIndex > 0 else { return }

        withAnimation(.easeInOut(duration: 0.6)) {
            currentStage = OnboardingStage.allCases[currentIndex - 1]
            updateProgress()
        }
    }

    private func goNext() {
        guard canProceedFromCurrentStage,
              let currentIndex = OnboardingStage.allCases.firstIndex(of: currentStage),
              currentIndex < OnboardingStage.allCases.count - 1 else { return }

        withAnimation(.easeInOut(duration: 0.6)) {
            currentStage = OnboardingStage.allCases[currentIndex + 1]
            updateProgress()
        }
    }

    private func updateProgress() {
        let currentIndex = OnboardingStage.allCases.firstIndex(of: currentStage) ?? 0
        progress = Double(currentIndex) / Double(OnboardingStage.allCases.count - 1)
    }

    private func completeOnboarding() {
        // Save user selections
        if let role = selectedRole {
            #if DEBUG
            session.setActiveRole(role)
            #endif
        }
        if let segment = selectedSegment {
            session.clientSegment = segment
        }

        // Save preferences and goals to UserDefaults or backend
        saveOnboardingData()

        onComplete?()
        dismiss()
    }

    private func saveOnboardingData() {
        UserDefaults.standard.set(Array(userGoals), forKey: "user_goals")
        UserDefaults.standard.set(preferences.pushNotifications, forKey: "pref_push_notifications")
        UserDefaults.standard.set(preferences.emailSummaries, forKey: "pref_email_summaries")
        UserDefaults.standard.set(preferences.guidedTours, forKey: "pref_guided_tours")
        UserDefaults.standard.set(preferences.advancedFeatures, forKey: "pref_advanced_features")
        UserDefaults.standard.set(true, forKey: "onboarding_completed")
    }

    private func getGoalsForRole(_ role: String) -> [OnboardingGoal] {
        switch role {
        case "client":
            return [
                OnboardingGoal(id: "find_home", title: "Find my dream home", icon: "house.fill"),
                OnboardingGoal(
                    id: "understand_market",
                    title: "Understand the market",
                    icon: "chart.line.uptrend.xyaxis"
                ),
                OnboardingGoal(id: "get_financing", title: "Secure financing", icon: "creditcard.fill"),
                OnboardingGoal(id: "negotiate_deal", title: "Negotiate the best deal", icon: "handshake.fill"),
                OnboardingGoal(id: "smooth_process", title: "Have a smooth process", icon: "checkmark.seal.fill"),
                OnboardingGoal(id: "save_time", title: "Save time and effort", icon: "clock.fill")
            ]
        case "agent":
            return [
                OnboardingGoal(id: "manage_clients", title: "Manage clients better", icon: "person.2.fill"),
                OnboardingGoal(id: "close_deals", title: "Close more deals", icon: "target"),
                OnboardingGoal(id: "market_insights", title: "Get market insights", icon: "chart.bar.fill"),
                OnboardingGoal(
                    id: "streamline_workflow",
                    title: "Streamline workflow",
                    icon: "arrow.triangle.2.circlepath"
                ),
                OnboardingGoal(id: "grow_business", title: "Grow my business", icon: "arrow.up.right.circle.fill"),
                OnboardingGoal(id: "client_satisfaction", title: "Improve client satisfaction", icon: "star.fill")
            ]
        default:
            return []
        }
    }
}

// MARK: - Supporting Types

enum OnboardingStage: String, CaseIterable {
    case welcome
    case roleSelection
    case goalSetting
    case preferences
    case teamIntroduction
    case ready

    var title: String {
        switch self {
        case .welcome: return "Welcome"
        case .roleSelection: return "Role"
        case .goalSetting: return "Goals"
        case .preferences: return "Preferences"
        case .teamIntroduction: return "Team"
        case .ready: return "Ready"
        }
    }
}

struct OnboardingGoal {
    let id: String
    let title: String
    let icon: String
}

struct OnboardingFlowPreferences {
    var pushNotifications: Bool = true
    var emailSummaries: Bool = true
    var guidedTours: Bool = true
    var advancedFeatures: Bool = false
}