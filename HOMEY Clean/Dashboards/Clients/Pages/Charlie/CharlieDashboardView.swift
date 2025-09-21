//
//  CharlieDashboardView.swift
//  HOMEY Clean
//
//  Updated to match legacy "Charlie's Corner" layout and integrate provided components.
//

import SwiftUI

// MARK: - Public entry

public struct CharlieDashboardView: View {
    @EnvironmentObject private var session: AppSessionManager
    @State private var showOnboarding = false
    @State private var showEducation = false
    @State private var activeChat: ChatTarget?
    @State private var scrollOffset: CGFloat = 0
    @State private var showSilhouette = false

    private let stations: [String] = ["Explore", "Apply", "Approve", "Close"]
    private let currentIndex: Int = 1

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                RoomVibeBackground(kind: .charlie)
                
                // Charlie Silhouette Background - appears after scrolling past hero
                if showSilhouette {
                    GeometryReader { geometry in
                        // Handle both spellings, prefer the correctly spelled asset if available
                        let correct = UIImage(named: "charlie_silhouette") != nil
                        let assetName = correct ? "charlie_silhouette" : "charlie_silhoutte"
                        if UIImage(named: assetName) != nil {
                            Image(assetName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width * 0.6)
                                .position(
                                    x: geometry.size.width * 0.85,
                                    y: geometry.size.height * 0.7
                                )
                                .opacity(0.5)
                                .animation(.easeInOut(duration: 0.3), value: showSilhouette)
                        }
                    }
                    .allowsHitTesting(false)
                }

                ScrollViewReader { proxy in
                    ScrollView(.vertical) {
                        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: []) {
                            // Immersive Hero Banner - Edge to Edge
                            HeroVideoView(
                                character: .charlie,
                                title: "Charlie says Hi",
                                subtitle: "Your HOMEY Teammate",
                                onContinue: {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        proxy.scrollTo("charlie.contentStart", anchor: .top)
                                    }
                                }
                            )
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                                }
                            )
                            
                            // Anchor for hero continue action
                            Color.clear
                                .frame(height: 1)
                                .id("charlie.contentStart")
                            
                            // Charlie Update Box - positioned below hero
                            CharlieUpdateBox()
                                .padding(.top, 20)
                            
                            // Main Content with proper spacing
                            VStack(alignment: .leading, spacing: 16) {
                            
                            WelcomeHeader(
                                title: "Welcome",
                                subtitle: "Let's make your home journey smooth and successful."
                            )

                            SubwayProgressView(stations: stations, currentIndex: currentIndex)

                            TodayPathCard(steps: ["Docs Ready", "Search", "Apply"], next: "Search")

                            Text("Charlie's Corner")
                                .subtitleText()
                                .foregroundStyle(HomeyKind.charlie.gradients.accent)
                                .padding(.top, 4)

                            VStack(spacing: 12) {
                                CornerCard(
                                    leadingSystemImage: "book.closed.fill",
                                    title: "Education Center",
                                    subtitle: "Short lessons, real approvals. No fluff.",
                                    buttonTitle: "Browse Modules"
                                ) { showEducation = true }

                                CornerCard(
                                    leadingSystemImage: "text.bubble.fill",
                                    title: "Chat with Charlie",
                                    subtitle: "Got a board interview? Bring your chaos. We’ll tidy it up.",
                                    buttonTitle: "Open Chat"
                                ) { activeChat = .homey(.charlie) }
                            }

                            Button("✨ Ask Charlie") {
                                activeChat = .homey(.charlie)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.regular)
                            .tint(HomeyKind.charlie.gradients.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                        // Show silhouette when scrolled past hero section (approximately 400pt)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSilhouette = scrollOffset < -400
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .principal) { Text("Charlie").subtitleText() } }
            .sheet(isPresented: $showOnboarding) {
                CharlieOnboardingView {}.environmentObject(session)
            }
            .sheet(isPresented: $showEducation) {
                NavigationStack {
                    EducationCenterSectionView(docs: [
                        EducationCenterStoreDoc(title: "First-time buyer basics", subtitle: "10 min"),
                        EducationCenterStoreDoc(title: "Rental checklist", subtitle: "8 min")
                    ])
                    .padding()
                    .navigationTitle("Education Center")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            .sheet(item: $activeChat) { target in
                ChatModal(target: target, currentContext: .dashboard)
            }
        }
        .floatingAvatar(.charlie, context: .dashboard, position: .bottomTrailing)
        .chatAvatar(.charlie, context: .dashboard)
    }
}

private struct TodayPathCard: View {
    let steps: [String]
    let next: String
    var body: some View {
        GlassCardContent(cornerRadius: 16, padding: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Today's Path")
                    .subtitleText()
                HStack(spacing: 6) {
                    ForEach(steps, id: \.self) { s in
                        Capsule().fill(Color.white.opacity(0.85)).frame(height: 8)
                            .overlay(Text(s).captionText(color: .black.opacity(0.7)).padding(
                                .horizontal,
                                8
                            ))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 4)
                Text("Next up: \(next)")
                    .bodyText(color: .secondary)
            }
        }
    }
}

// MARK: - Local, file-scoped helpers

// Liquid Glass modifier (single definition to avoid "Invalid redeclaration")
private struct LiquidGlass: ViewModifier {
    var corner: CGFloat = 16
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: corner, style: .continuous))
            // subtle inner highlight + tint
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .strokeBorder(LinearGradient(
                        colors: [Color.white.opacity(0.55), Color.white.opacity(0.12)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ), lineWidth: 1)
            )
            // animated sheen
            .overlay(
                TimelineView(.animation) { timeline in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    let x = CGFloat((sin(t * 0.6) + 1) / 2) // 0…1
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.00),
                            Color.white.opacity(0.10),
                            Color.white.opacity(0.00)
                        ],
                        startPoint: .init(x: x - 0.4, y: 0),
                        endPoint: .init(x: x + 0.4, y: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
                    .allowsHitTesting(false)
                }
            )
            // depth
            .shadow(color: Color.black.opacity(0.10), radius: 20, x: 0, y: 10)
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

private extension View {
    func liquidGlass(corner: CGFloat = 16) -> some View { modifier(LiquidGlass(corner: corner)) }
}

private struct WelcomeHeader: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).titleText()
            Text(subtitle)
                .bodyText(color: .secondary)
        }
    }
}

private struct CornerCard: View {
    let leadingSystemImage: String
    let title: String
    let subtitle: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        GlassCardContent(cornerRadius: 16, padding: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: leadingSystemImage)
                    .font(.subheadline.weight(.semibold))
                    .frame(width: 28, height: 28)
                    .padding(8)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(title).subtitleText()
                    Text(subtitle)
                        .bodyText(color: .secondary)

                    Button(buttonTitle, action: action)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .tint(HomeyKind.charlie.gradients.accent)
                }
                Spacer(minLength: 0)
            }
        }
    }
}