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

    private let stations: [String] = ["Explore", "Apply", "Approve", "Close"]
    private let currentIndex: Int = 1

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                RoomVibeBackground(kind: .charlie)

                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 16) {
                        WelcomeHeader(
                            title: "Welcome",
                            subtitle: "Let’s make your home journey smooth and successful."
                        )

                        SubwayProgressView(stations: stations, currentIndex: currentIndex)

                        TodayPathCard(steps: ["Docs Ready", "Search", "Apply"], next: "Search")

                        Text("Charlie’s Corner")
                            .font(.title3.weight(.semibold))
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
                .scrollContentBackground(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .principal) { Text("Charlie").font(.headline) } }
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
                ChatModal(target: target)
            }
        }
    }
}

private struct TodayPathCard: View {
    let steps: [String]
    let next: String
    var body: some View {
        GlassCardContent(cornerRadius: 16, padding: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Today’s Path")
                    .font(.headline)
                HStack(spacing: 6) {
                    ForEach(steps, id: \.self) { s in
                        Capsule().fill(Color.white.opacity(0.85)).frame(height: 8)
                            .overlay(Text(s).font(.caption2).foregroundStyle(.black.opacity(0.7)).padding(
                                .horizontal,
                                8
                            ))
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 4)
                Text("Next up: \(next)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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
            Text(title).font(.system(size: 32, weight: .bold))
            Text(subtitle)
                .font(.callout)
                .foregroundStyle(.secondary)
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
                    Text(title).font(.headline)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

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
