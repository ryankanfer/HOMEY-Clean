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

    private let chapters = [
        "Discovery",
        "Connection",
        "Journey",
        "Transformation",
        "Beginning"
    ]

    public init() {}

    public var body: some View {
        ZStack {
            // Immersive background that evolves with story
            storyBackground
                .ignoresSafeArea()

            // Story content
            TabView(selection: $currentChapter) {
                chapterDiscovery.tag(0)
                chapterConnection.tag(1)
                chapterJourney.tag(2)
                chapterTransformation.tag(3)
                chapterBeginning.tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: currentChapter) { _, newValue in
                Haptics.lightTap()
                withAnimation(.easeInOut(duration: 0.8)) {
                    storyProgress = Double(newValue) / Double(chapters.count - 1)
                }
                if newValue == chapters.count - 1 {
                    Haptics.success()
                }
            }

            // Story navigation overlay
            VStack {
                // Top navigation
                HStack {
                    // Progress indicator
                    StoryProgressBar(progress: storyProgress, chapters: chapters)

                    Spacer()

                    Button("Skip Story") {
                        Haptics.lightTap()
                        dismissWelcome()
                    }
                    .font(.callout.weight(.medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .foregroundStyle(.white)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                Spacer()

                // Bottom action area
                if currentChapter == chapters.count - 1 {
                    VStack(spacing: 16) {
                        Text("Your story begins now")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.white.opacity(0.9))
                            .multilineTextAlignment(.center)

                        Button {
                            Haptics.success()
                            dismissWelcome()
                        } label: {
                            HStack(spacing: 8) {
                                Text("Enter HOMEY")
                                    .font(.headline.weight(.semibold))
                                Image(systemName: "arrow.right")
                                    .font(.headline.weight(.bold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .foregroundStyle(.black)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.white)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
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
            // Base animated background
            AnimatedSkyGradient()

            // Chapter-specific overlays
            Group {
                switch currentChapter {
                case 0:
                    // Discovery - warm sunrise
                    LinearGradient(
                        colors: [Color.orange.opacity(0.3), Color.clear, Color.purple.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                case 1:
                    // Connection - social blues
                    LinearGradient(
                        colors: [Color.blue.opacity(0.2), Color.clear, Color.cyan.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                case 2:
                    // Journey - dynamic movement
                    LinearGradient(
                        colors: [Color.green.opacity(0.2), Color.clear, Color.teal.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                case 3:
                    // Transformation - magical purples
                    LinearGradient(
                        colors: [Color.purple.opacity(0.3), Color.clear, Color.pink.opacity(0.2)],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                default:
                    // Beginning - golden hour
                    LinearGradient(
                        colors: [Color.yellow.opacity(0.2), Color.clear, Color.orange.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            }
            .animation(.easeInOut(duration: 1.2), value: currentChapter)

            // Atmospheric overlay
            LinearGradient(
                colors: [Color.black.opacity(0.4), .clear, Color.black.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    // MARK: - Story Chapters

    private var chapterDiscovery: some View {
        StoryChapter(
            title: "Welcome to HOMEY",
            subtitle: "Where every home tells a story"
        ) {
            VStack(spacing: 24) {
                // Animated HOMEY wordmark
                Text("HOMEY")
                    .font(.playfairDisplayBold(64))
                    .tracking(3)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 6)
                    .scaleEffect(showContent ? 1.0 : 0.8)
                    .opacity(showContent ? 1 : 0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3), value: showContent)

                Text("Your journey to the perfect home begins with a single step into possibility.")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.8), value: showContent)
            }
        }
    }

    private var chapterConnection: some View {
        StoryChapter(
            title: "Meet Your Homies",
            subtitle: "Your personal real estate dream team"
        ) {
            VStack(spacing: 20) {
                Text("Every great story needs great characters. Meet the team that will guide your journey.")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                // Interactive character grid
                let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Array(HomeyKind.allCases), id: \.self) { kind in
                        CharacterCard(kind: kind, isActive: activeCharacter == kind)
                            .onTapGesture {
                                Haptics.mediumTap()
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    activeCharacter = activeCharacter == kind ? nil : kind
                                }
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var chapterJourney: some View {
        StoryChapter(
            title: "Your Path Forward",
            subtitle: "Every step is guided, every moment supported"
        ) {
            VStack(spacing: 24) {
                Text("From first search to final signature, you're never alone in this journey.")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                // Journey steps visualization
                JourneyStepsView()
            }
        }
    }

    private var chapterTransformation: some View {
        StoryChapter(
            title: "Transform Your Future",
            subtitle: "Where dreams become addresses"
        ) {
            VStack(spacing: 24) {
                Text("Watch as possibilities transform into reality, guided by expertise and powered by innovation.")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                // Transformation animation placeholder
                TransformationVisualization()
            }
        }
    }

    private var chapterBeginning: some View {
        StoryChapter(
            title: "Your Story Starts Now",
            subtitle: "Ready to write the next chapter?"
        ) {
            VStack(spacing: 32) {
                Text("Every ending is a new beginning. Your perfect home is waiting to become part of your story.")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)

                // Call to action preview
                VStack(spacing: 16) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.9))
                        .symbolEffect(.bounce.up, options: .repeat(.continuous))

                    Text("Let's find your home")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 24)
            }
        }
    }
}

// MARK: - Supporting Views

private struct StoryChapter<Content: View>: View {
    let title: String
    let subtitle: String
    let content: Content

    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Chapter header
                VStack(spacing: 12) {
                    Text(title)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                // Chapter content
                content
                    .padding(.horizontal, 20)

                Spacer(minLength: 100)
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

private struct CharacterCard: View {
    let kind: HomeyKind
    let isActive: Bool

    var body: some View {
        VStack(spacing: 12) {
            TeamTile(kind: kind)
                .scaleEffect(isActive ? 1.1 : 1.0)
                .shadow(color: .black.opacity(isActive ? 0.3 : 0.1), radius: isActive ? 12 : 4)

            if isActive {
                VStack(spacing: 4) {
                    Text(kind.displayName)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)

                    Text(kind.role)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isActive)
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

// MARK: - Haptics

private enum Haptics {
    static func lightTap() {
        let g = UIImpactFeedbackGenerator(style: .light)
        g.impactOccurred()
    }

    static func mediumTap() {
        let g = UIImpactFeedbackGenerator(style: .medium)
        g.impactOccurred()
    }

    static func success() {
        let g = UINotificationFeedbackGenerator()
        g.notificationOccurred(.success)
    }
}
