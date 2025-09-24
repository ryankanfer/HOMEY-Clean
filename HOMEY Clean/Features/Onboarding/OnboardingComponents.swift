//
//  OnboardingComponents.swift
//  HOMEY Clean
//
//  Supporting UI components for comprehensive onboarding
//

import SwiftUI

// MARK: - Stage View Container

struct OnboardingStageView<Content: View>: View {
    let title: String
    let subtitle: String
    let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(title)
                        .font(.custom("PlayfairDisplay-Bold", size: 32))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(.custom("PlayfairDisplay-Regular", size: 18))
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                // Frosted Card Content
                VStack {
                    content()
                        .padding(20)
                }
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 6)
                .padding(.horizontal, 16)

                Spacer(minLength: 100) // Space for navigation footer
            }
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - Progress Header

struct OnboardingProgressHeader: View {
    let stage: OnboardingStage
    let progress: Double
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(OnboardingStage.allCases, id: \.self) { stageCase in
                        Circle()
                            .fill(stageCase.rawValue <= stage.rawValue ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(stageCase == stage ? 1.2 : 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: stage)
                    }
                }

                Spacer()

                // Skip button
                Button("Skip", action: onSkip)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.horizontal, 24)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 2)

                    Rectangle()
                        .fill(Color.white)
                        .frame(width: geometry.size.width * progress, height: 2)
                        .animation(.easeInOut(duration: 0.6), value: progress)
                }
            }
            .frame(height: 2)
            .padding(.horizontal, 24)
        }
        .padding(.top, 8)
    }
}

// MARK: - Navigation Footer

struct OnboardingNavigationFooter: View {
    let stage: OnboardingStage
    let canProceed: Bool
    let onBack: () -> Void
    let onNext: () -> Void
    let onComplete: () -> Void

    private var isFirstStage: Bool {
        stage == OnboardingStage.allCases.first
    }

    private var isLastStage: Bool {
        stage == OnboardingStage.allCases.last
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.white.opacity(0.2))

            HStack(spacing: 16) {
                // Back button
                if !isFirstStage {
                    Button(action: onBack) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .medium))
                            Text("Back")
                                .font(.callout.weight(.medium))
                        }
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                } else {
                    Spacer()
                }

                Spacer()

                // Next/Complete button
                Button(action: isLastStage ? onComplete : onNext) {
                    HStack(spacing: 8) {
                        Text(isLastStage ? "Enter HOMEY" : "Continue")
                            .font(.callout.weight(.semibold))

                        if !isLastStage {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    .foregroundStyle(canProceed ? .black : .white.opacity(0.5))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(canProceed ? Color.white : Color.white.opacity(0.2))
                    )
                }
                .disabled(!canProceed)
                .animation(.easeInOut(duration: 0.2), value: canProceed)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - Role Selection Card

struct RoleSelectionCard: View {
    let role: String
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(isSelected ? .black : .white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.white : Color.white.opacity(0.2))
                    )

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(isSelected ? .black : .white)

                    Text(description)
                        .font(.callout)
                        .foregroundStyle(isSelected ? .black.opacity(0.7) : .white.opacity(0.7))
                }

                Spacer()

                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(isSelected ? .green : .white.opacity(0.5))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white : Color.white.opacity(0.1))
                    .stroke(isSelected ? Color.clear : Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
    }
}

// MARK: - Client Segment Picker

struct ClientSegmentPicker: View {
    @Binding var selectedSegment: String

    private let segments = [
        ("renter", "Renter", "key.fill"),
        ("buyer", "Buyer", "house.fill"),
        ("seller", "Seller", "dollarsign.circle.fill"),
        ("landlord", "Landlord", "building.2.fill")
    ]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
            ForEach(segments, id: \.0) { segment in
                Button(action: { selectedSegment = segment.0 }) {
                    VStack(spacing: 8) {
                        Image(systemName: segment.2)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(selectedSegment == segment.0 ? .black : .white)

                        Text(segment.1)
                            .font(.callout.weight(.medium))
                            .foregroundStyle(selectedSegment == segment.0 ? .black : .white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedSegment == segment.0 ? Color.white : Color.white.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Goal Selection Card

struct GoalSelectionCard: View {
    let goal: OnboardingGoal
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: goal.icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(isSelected ? .black : .white)

                Text(goal.title)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(isSelected ? .black : .white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white : Color.white.opacity(0.1))
                    .stroke(isSelected ? Color.clear : Color.white.opacity(0.2), lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
    }
}

// MARK: - Preference Components

struct PreferenceSection<Content: View>: View {
    let title: String
    let icon: String
    let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)

                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
            }

            content()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct PreferenceToggle: View {
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.white)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .green))
        }
    }
}

// MARK: - Team Member Card

struct TeamMemberIntroCard: View {
    let kind: HomeyKind

    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(LinearGradient(
                    colors: [kind.primaryColor, kind.secondaryColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(kind.emoji)
                        .font(.system(size: 28))
                )

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(kind.displayName)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)

                Text(kind.tagline)
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.8))

                Text(kind.expertise)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Summary Card

struct OnboardingSummaryCard: View {
    let role: String
    let segment: String?
    let goalCount: Int

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Role")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                    Text(role.capitalized)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                }

                if let segment = segment {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Type")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white.opacity(0.7))
                        Text(segment.capitalized)
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                }
            }

            Divider()
                .background(Color.white.opacity(0.3))

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Goals Selected")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                    Text("\(goalCount) goal\(goalCount == 1 ? "" : "s")")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.white)
                }

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.green)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Animated Sky Background

struct AnimatedSkyGradient: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.8),
                Color.purple.opacity(0.6),
                Color.pink.opacity(0.4),
                Color.orange.opacity(0.3)
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Extensions

extension HomeyKind {
    var primaryColor: Color {
        switch self {
        case .charlie: return .blue
        case .paige: return .green
        case .scout: return .orange
        case .isla: return .purple
        case .viza: return .pink
        case .drew: return .teal
        }
    }

    var secondaryColor: Color {
        switch self {
        case .charlie: return .cyan
        case .paige: return .mint
        case .scout: return .yellow
        case .isla: return .indigo
        case .viza: return .red
        case .drew: return .blue
        }
    }

    var tagline: String {
        switch self {
        case .charlie: return "Your AI real estate guide"
        case .paige: return "Market analysis expert"
        case .scout: return "Financing specialist"
        case .isla: return "Negotiation pro"
        case .viza: return "Legal advisor"
        case .drew: return "Moving coordinator"
        }
    }

    var expertise: String {
        switch self {
        case .charlie: return "General guidance & support"
        case .paige: return "Market trends & pricing"
        case .scout: return "Loans & mortgages"
        case .isla: return "Deal negotiation"
        case .viza: return "Contracts & legal matters"
        case .drew: return "Logistics & coordination"
        }
    }
}