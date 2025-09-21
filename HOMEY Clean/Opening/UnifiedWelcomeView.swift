//
//  UnifiedWelcomeView.swift
//  HOMEY Clean
//
//  Unified immersive welcome experience with storytelling
//

import SwiftUI
import UIKit

public struct UnifiedWelcomeView: View {
    @Environment(\.dismissWelcome) private var dismissWelcome
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var currentChapter = 0
    @State private var showContent = false
    @State private var activeCharacter: HomeyKind?
    @State private var storyProgress: Double = 0
    @State private var backgroundLoaded = false

    private let chapters = [
        "Welcome",
        "Meet Your Team",
        "Let's Begin"
    ]

    public init() {}

    public var body: some View {
        ZStack {
            // Immersive background that evolves with story
            storyBackground
                .ignoresSafeArea()

            // Story content
            TabView(selection: $currentChapter) {
                chapterWelcome.tag(0)
                chapterTeam.tag(1)
                chapterBegin.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: currentChapter) { _, newValue in
                TRAEHapticManager.shared.trigger(.light)
                withAnimation(.easeInOut(duration: 0.8)) {
                    storyProgress = Double(newValue) / Double(chapters.count - 1)
                }
                if newValue == chapters.count - 1 {
                    TRAEHapticManager.shared.trigger(.success)
                }
            }

            // Story navigation overlay
            VStack {
                // Top navigation - centered progress bar
                HStack {
                    Spacer()
                    StoryProgressBar(progress: storyProgress, chapters: chapters)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                Spacer()

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                showContent = true
            }
        }
    }

    // MARK: - Story Background

    @ViewBuilder
    private var storyBackground: some View {
        ZStack {
            // Use the new animated gradient background system
            AnimatedGradientBackground(for: .homey)
                .environmentObject(ThemeManager.shared)
            
            // Subtle vignette effect for readability
            LinearGradient(
                colors: [Color.black.opacity(0.2), .clear, Color.black.opacity(0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    // MARK: - Story Chapters

    private var chapterWelcome: some View {
        StoryChapter(
            title: "",
            subtitle: ""
        ) {
            VStack(spacing: 40) {
                // Hero logo with enhanced presentation
                VStack(spacing: 24) {
                    // Use the actual logo image for consistency
                    Group {
                        if UIImage(named: "homey_logo") != nil {
                            Image("homey_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        } else {
                            // Fallback to text if image not found
                            Text("HOMEY")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                    }
                    .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 6)
                    
                    Text("Find your perfect home with AI guidance")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .tracking(1)
                        .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 6)
                        .scaleEffect(showContent ? 1.0 : 0.8)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3), value: showContent)
                }
                
                // Value propositions with icons
                VStack(spacing: 20) {
                    WelcomeFeature(
                        icon: "brain.head.profile",
                        title: "AI-Powered Search",
                        description: "Smart recommendations tailored to your lifestyle",
                        delay: 0.9
                    )
                    
                    WelcomeFeature(
                        icon: "person.2.fill",
                        title: "Expert Team",
                        description: "Professional agents ready to guide your journey",
                        delay: 1.1
                    )
                    
                    WelcomeFeature(
                        icon: "map.fill",
                        title: "Market Insights",
                        description: "Real-time data and neighborhood analytics",
                        delay: 1.3
                    )
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
                .animation(.spring(response: 0.9, dampingFraction: 0.8).delay(0.8), value: showContent)
                
                // Call to action preview
                VStack(spacing: 12) {
                    Text("Ready to start your journey?")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                    
                    Text("Swipe to meet your team →")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial.opacity(0.3), in: Capsule())
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.8).delay(1.5), value: showContent)
            }
        }
    }

    private var chapterTeam: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header section
                VStack(spacing: 16) {
                    Text("Meet Your Cast")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .tracking(0.5)
                        .padding(.top, 50)

                    Text("Your ensemble of real estate experts")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    Text("Meet your personal dream team. Tap any character to see their role, swipe to explore.")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.horizontal, 24)
                
                // Character carousel - fills remaining space
                CharacterCarousel(activeCharacter: $activeCharacter)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private var chapterBegin: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Main content area
                StoryChapter(
                    title: "Welcome to the Club",
                    subtitle: "You've been invited to something exclusive"
                ) {
                    VStack(spacing: 40) {
                        // Exclusive membership messaging
                        VStack(spacing: 20) {
                            Text("🏆")
                                .font(.system(size: 64))
                                .scaleEffect(showContent ? 1.0 : 0.8)
                                .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3), value: showContent)
                            
                            Text("Congratulations")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .tracking(1)
                                .opacity(showContent ? 1 : 0)
                                .animation(.easeOut(duration: 0.8).delay(0.5), value: showContent)
                            
                            Text("You're now part of an exclusive community of discerning home seekers who demand excellence.")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                                .opacity(showContent ? 1 : 0)
                                .animation(.easeOut(duration: 0.8).delay(0.7), value: showContent)
                        }
                        
                        // Premium benefits showcase
                        VStack(spacing: 24) {
                            Text("Your Membership Includes")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.8))
                                .tracking(0.5)
                            
                            VStack(spacing: 16) {
                                PremiumBenefit(
                                    icon: "crown.fill",
                                    title: "VIP Access",
                                    description: "First look at exclusive listings",
                                    delay: 0.9
                                )
                                
                                PremiumBenefit(
                                    icon: "person.2.badge.key.fill",
                                    title: "Concierge Service",
                                    description: "White-glove personal assistance",
                                    delay: 1.1
                                )
                                
                                PremiumBenefit(
                                    icon: "sparkles",
                                    title: "AI-Powered Insights",
                                    description: "Market intelligence at your fingertips",
                                    delay: 1.3
                                )
                            }
                        }
                    }
                }
                
                // Bottom action area in scrollable content
                VStack(spacing: 20) {
                    Text("Your story begins now")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .tracking(0.3)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeOut(duration: 0.8).delay(1.5), value: showContent)

                    EnhancedCTAButton(
                        title: "Enter HOMEY",
                        icon: "arrow.right",
                        action: {
                            TRAEHapticManager.shared.trigger(.success)
                            dismissWelcome()
                        }
                    )
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(1.7), value: showContent)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
                .padding(.top, 40)
            }
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - Supporting Views

private struct StoryChapter<Content: View>: View {
    let title: String
    let subtitle: String
    let content: Content
    @State private var headerAppear = false
    @State private var contentAppear = false

    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Enhanced Header with better typography
                VStack(spacing: 16) {
                    Text(title)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .tracking(0.5)
                        .opacity(headerAppear ? 1 : 0)
                        .offset(y: headerAppear ? 0 : 20)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: headerAppear)

                    Text(subtitle)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .opacity(headerAppear ? 1 : 0)
                        .offset(y: headerAppear ? 0 : 15)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: headerAppear)
                }
                .padding(.top, 50)
                .padding(.horizontal, 24)

                // Enhanced Content with staggered animation
                content
                    .padding(.horizontal, 24)
                    .opacity(contentAppear ? 1 : 0)
                    .offset(y: contentAppear ? 0 : 30)
                    .animation(.spring(response: 0.9, dampingFraction: 0.8).delay(0.6), value: contentAppear)

                Spacer(minLength: 120)
            }
        }
        .onAppear {
            withAnimation {
                headerAppear = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    contentAppear = true
                }
            }
        }
    }
}

private struct StoryProgressBar: View {
    let progress: Double
    let chapters: [String]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(chapters.indices, id: \.self) { index in
                let isActive = progress >= Double(index) / Double(chapters.count - 1)

                Circle()
                    .fill(isActive ? Color.white : Color.white.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(isActive ? 1.2 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isActive)

                if index < chapters.count - 1 {
                    Rectangle()
                        .fill(progress > Double(index) / Double(chapters.count - 1) ? Color.white.opacity(0.6) : Color
                            .white.opacity(0.2)
                        )
                        .frame(width: 20, height: 2)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
        }
    }
}

// Character components moved to CharacterTilesGrid.swift

private struct CharacterCard: View {
    let kind: HomeyKind
    let isActive: Bool
    
    @State private var pulseEffect = false
    @State private var rotationEffect = 0.0

    var body: some View {
        VStack(spacing: 12) {
            TeamTile(kind: kind)
                .scaleEffect(isActive ? 1.15 : 1.0)
                .rotationEffect(.degrees(isActive ? rotationEffect : 0))
                .shadow(color: .black.opacity(isActive ? 0.4 : 0.1), radius: isActive ? 16 : 4)
                .overlay {
                    if isActive {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.6), .white.opacity(0.2), .white.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .scaleEffect(pulseEffect ? 1.1 : 1.0)
                            .opacity(pulseEffect ? 0.3 : 0.8)
                            .animation(
                                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                                value: pulseEffect
                            )
                    }
                }

            if isActive {
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Text(kind.emoji)
                            .font(.title2)
                        
                        Text(kind.displayName)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                    }

                    Text(kind.role)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: Capsule())
                    
                    Text(kind.blurb)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 8)
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.8)),
                        removal: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.8))
                    )
                )
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isActive)
        .onAppear {
            if isActive {
                pulseEffect = true
                withAnimation(.easeInOut(duration: 0.3).repeatCount(3, autoreverses: true)) {
                    rotationEffect = 2.0
                }
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                pulseEffect = true
                withAnimation(.easeInOut(duration: 0.3).repeatCount(3, autoreverses: true)) {
                    rotationEffect = 2.0
                }
            } else {
                pulseEffect = false
                rotationEffect = 0.0
            }
        }
    }
}

private struct JourneyStepsView: View {
    private let steps = [
        ("Search", "house.fill"),
        ("Connect", "person.2.fill"),
        ("Explore", "map.fill"),
        ("Decide", "checkmark.circle.fill")
    ]

    var body: some View {
        VStack(spacing: 20) {
            ForEach(Array(steps.enumerated()), id: \.offset) { _, step in
                HStack(spacing: 16) {
                    Image(systemName: step.1)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())

                    Text(step.0)
                        .font(.headline.weight(.medium))
                        .foregroundStyle(.white)

                    Spacer()
                }
                .opacity(0.8)
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct TransformationVisualization: View {
    @State private var animate = false

    var body: some View {
        HStack(spacing: 20) {
            // Before
            VStack(spacing: 8) {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(0.6))

                Text("Searching")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))
            }

            // Arrow
            Image(systemName: "arrow.right")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .scaleEffect(animate ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animate)

            // After
            VStack(spacing: 8) {
                Image(systemName: "house.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)

                Text("Home")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white)
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Welcome Feature Component

private struct WelcomeFeature: View {
    let icon: String
    let title: String
    let description: String
    let delay: Double
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial.opacity(0.3), in: Circle())
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -30)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(delay), value: isVisible)
        .onAppear {
            isVisible = true
        }
    }
}

// MARK: - Enhanced CTA Button

private struct PremiumBenefit: View {
    let icon: String
    let title: String
    let description: String
    let delay: Double
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Premium icon with golden accent
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.yellow.opacity(0.3), .orange.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .overlay {
                Circle()
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -40)
        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(delay), value: isVisible)
        .onAppear {
            isVisible = true
        }
    }
}

private struct ExclusiveEntryButton: View {
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var shimmerEffect = false
    @State private var pulseEffect = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: "key.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.black)
                    .rotationEffect(.degrees(shimmerEffect ? 15 : -15))
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: shimmerEffect)
                
                Text("Enter the Club")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.black)
                    .tracking(0.5)
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.black)
                    .scaleEffect(pulseEffect ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseEffect)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 18)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.9), .white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.yellow.opacity(0.6), .orange.opacity(0.4), .yellow.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    }
                    .shadow(color: .white.opacity(0.4), radius: shimmerEffect ? 25 : 15)
                    .shadow(color: .yellow.opacity(0.3), radius: shimmerEffect ? 35 : 20)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onAppear {
            shimmerEffect = true
            pulseEffect = true
        }
    }
}

private struct EnhancedCTAButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var glowEffect = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                
                Image(systemName: icon)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .scaleEffect(glowEffect ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowEffect)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    }
                    .shadow(color: .white.opacity(0.2), radius: glowEffect ? 20 : 8)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onAppear {
            glowEffect = true
        }
    }
}
