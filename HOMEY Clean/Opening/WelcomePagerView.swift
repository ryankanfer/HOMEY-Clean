import SwiftUI
import UIKit

public struct WelcomePagerView: View {
    @Environment(\.dismissWelcome) private var dismissWelcome
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0
    @State private var activeWave: HomeyKind?

    public init() {}

    public var body: some View {
        ZStack {
            AnimatedSkyGradient().ignoresSafeArea()

            LinearGradient(
                colors: [Color.black.opacity(0.35), .clear, Color.black.opacity(0.35)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // Do NOT pad the TabView itself; it breaks page width.
            TabView(selection: $page) {
                pageWelcome.tag(0)
                pageTeam.tag(1)
                pageProgress.tag(2)
                pageFeatures.tag(3)
                pageBegin.tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .onChange(of: page) { _, newValue in
                Haptics.lightTap()
                if newValue == 4 { Haptics.success() }
            }
        }
        .ignoresSafeArea(edges: [.top, .bottom])
        .safeAreaInset(edge: .top) {
            HStack {
                Spacer()
                Button("Skip") {
                    Haptics.lightTap()
                    dismissWelcome()
                }
                .font(.callout.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.top, 10)
                .padding(.trailing, 12)
                .accessibilityLabel("Skip welcome")
            }
        }
        .safeAreaInset(edge: .bottom) {
            if page == 4 {
                GlassCardContent(cornerRadius: 24, padding: 0) {
                    Button {
                        Haptics.success()
                        dismissWelcome()
                    } label: {
                        Text("Let’s Go →")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .foregroundStyle(.black)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
        }
    }

    // MARK: - Page 1: Lobby / Welcome

    private var pageWelcome: some View {
        VStack(spacing: 0) {
            Text("HOMEY")
                .font(.playfairDisplayBold(56))
                .tracking(2)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.45), radius: 10, x: 0, y: 6)
                .shadow(color: .black.opacity(0.25), radius: 20)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    // MARK: - Page 2: Team / Gallery (centered avatars grid, tappable)

    private var pageTeam: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 18) {
                Text("in your pocket. on your side.")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.6), radius: 6, x: 0, y: 3)
                    .multilineTextAlignment(.center)

                let columns: [GridItem] = [
                    GridItem(.flexible(minimum: 120), spacing: 14, alignment: .center),
                    GridItem(.flexible(minimum: 120), spacing: 14, alignment: .center)
                ]

                LazyVGrid(columns: columns, alignment: .center, spacing: 14) {
                    ForEach(Array(HomeyKind.allCases), id: \.self) { kind in
                        TeamTile(kind: kind)
                            .frame(maxWidth: .infinity, minHeight: 120)
                            .onTapGesture {
                                Haptics.mediumTap()
                                withAnimation(.easeInOut(duration: 0.25)) { activeWave = kind }
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .overlay {
            if let kind = activeWave {
                GeometryReader { geo in
                    ZStack {
                        Color.black.opacity(0.35).ignoresSafeArea()
                        VStack(spacing: 12) {
                            // 3x size presentation (bounded by screen)
                            if let img = UIImage(named: "\(kind.assetName)_wave") {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(
                                        width: min(geo.size.width * 0.8, 360),
                                        height: min(geo.size.height * 0.6, 520)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                    .shadow(radius: 12)
                            } else {
                                TeamTile(kind: kind)
                                    .frame(width: min(geo.size.width * 0.5, 300))
                            }
                            Text(kind.displayName)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.white)
                            Text(kind.role)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Button("Close") {
                                Haptics.lightTap()
                                withAnimation(.easeInOut(duration: 0.2)) { activeWave = nil }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding()
                    }
                }
                .transition(.opacity)
            }
        }
    }

    // MARK: - Page 3: Choose Your Path (visionOS‑style glass adventure cards)

    private var pageProgress: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 6) {
                    Text("Choose Your Path")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 6, x: 0, y: 3)
                    Text("Explore the journey that fits you best")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.92))
                        .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                }
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal, 20)

                let paths: [(title: String, subtitle: String)] = [
                    ("Renter", "From Search to Keys in Hand"),
                    ("Buyer", "From Offer to Closing Day"),
                    ("Seller", "From Listing to Sold"),
                    ("Landlord", "From Applications to Move‑In")
                ]

                VStack(spacing: 16) {
                    ForEach(paths, id: \.title) { p in
                        PathCard(title: p.title, subtitle: p.subtitle)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 24)
        }
    }

    // MARK: - Page 4: Features (grouped showcase)

    private var pageFeatures: some View {
        ScrollView {
            VStack(spacing: 22) {
                VStack(spacing: 6) {
                    Text("What You’ll Get with HOMEY")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 6, x: 0, y: 3)
                    Text("Powerful tools and a friendly team, designed for your journey")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.92))
                        .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                }
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal, 20)

                FeatureGroupCard(
                    title: "Search & Discover",
                    icon: "sparkles",
                    items: [
                        .init(icon: "magnifyingglass", text: "Smarter Searches, Faster Matches"),
                        .init(icon: "figure.walk.motion", text: "Find Your Place, Live Your Life"),
                        .init(icon: "chart.bar.xaxis", text: "Data That Gives You an Edge")
                    ]
                )
                FeatureGroupCard(
                    title: "Manage & Track",
                    icon: "checkmark.seal",
                    items: [
                        .init(icon: "doc.text.magnifyingglass", text: "All Your Paperwork, Organized"),
                        .init(icon: "checklist", text: "Stay on Track, Every Step"),
                        .init(icon: "rectangle.grid.2x2", text: "Your Journey, at a Glance")
                    ]
                )
                FeatureGroupCard(
                    title: "Support & Community",
                    icon: "person.3",
                    items: [
                        .init(icon: "person.text.rectangle", text: "Your Personal Dream Team"),
                        .init(icon: "wrench.and.screwdriver", text: "Trusted Help, One Tap Away"),
                        .init(icon: "key.fill", text: "We’re With You After the Keys"),
                        .init(icon: "paintpalette", text: "Beautiful, Intuitive, Effortless")
                    ]
                )
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Page 5: Begin

    private var pageBegin: some View {
        VStack(spacing: 24) {
            Image(systemName: "key.fill")
                .font(.system(size: 72))
                .symbolEffect(.pulse.byLayer, options: .repeating, value: true)
                .foregroundStyle(.yellow)
                .shadow(color: .yellow.opacity(0.5), radius: 18, x: 0, y: 0)

            Text("Let’s begin")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)

            Text("Swipe or tap Let’s Go to start your journey.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.85))
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

// MARK: - Components

private struct PathCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String
    let subtitle: String
    @State private var wobble = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous).fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(.white.opacity(0.14), lineWidth: 1)
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.title3.weight(.semibold)).foregroundStyle(.white.opacity(0.98))
                Text(subtitle).font(.subheadline).foregroundStyle(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .overlay(ReflectiveShimmer(cornerRadius: 22))
        .shadow(color: .black.opacity(0.28), radius: 18, x: 0, y: 10)
        .rotation3DEffect(.degrees(wobble ? 3 : -3), axis: (x: 0, y: 1, z: 0))
        .animation(reduceMotion ? .none : .easeInOut(duration: 4.5).repeatForever(autoreverses: true), value: wobble)
        .onAppear { wobble = true }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(subtitle)")
    }
}

private struct ReflectiveShimmer: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let cornerRadius: CGFloat

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let speed = reduceMotion ? 0.0 : 0.18
            let offset = CGFloat(sin(t * speed)) * 140

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.00), .white.opacity(0.16), .white.opacity(0.00)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blendMode(.plusLighter)
                .offset(x: offset, y: -offset)
                .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

private struct FeatureItem: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
    init(icon: String, text: String) {
        self.icon = icon
        self.text = text
    }
}

private struct FeatureGroupCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String
    let icon: String
    let items: [FeatureItem]
    @State private var appear = false
    @State private var tilt = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: icon).font(.title3.weight(.semibold)).foregroundStyle(.white.opacity(0.95))
                Text(title).font(.title3.weight(.semibold)).foregroundStyle(.white.opacity(0.98))
                Spacer()
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(items.enumerated()), id: \.element.id) { idx, item in
                    FeatureBulletRow(icon: item.icon, text: item.text)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 8)
                        .animation(
                            reduceMotion ? .none : .easeOut(duration: 0.35).delay(0.05 * Double(idx)),
                            value: appear
                        )
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(
            .white.opacity(0.14),
            lineWidth: 1
        ))
        .shadow(color: .black.opacity(0.28), radius: 18, x: 0, y: 10)
        .overlay(ReflectiveShimmer(cornerRadius: 22))
        .rotation3DEffect(.degrees(tilt ? 4 : -4), axis: (x: 0, y: 1, z: 0))
        .animation(reduceMotion ? .none : .easeInOut(duration: 5).repeatForever(autoreverses: true), value: tilt)
        .onAppear { appear = true; tilt = true }
    }
}

private struct FeatureBulletRow: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon).font(.headline.weight(.semibold)).foregroundStyle(.white).frame(width: 20)
            Text(text).font(.body).foregroundStyle(.white.opacity(0.95)).multilineTextAlignment(.leading)
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
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

// MARK: - Background

// AnimatedSkyGradient is now defined in OnboardingComponents.swift
