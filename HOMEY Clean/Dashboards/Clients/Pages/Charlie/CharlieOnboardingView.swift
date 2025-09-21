//
//  CharlieOnboardingView.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//

import SwiftUI

/// Charlie onboarding flow (self-contained)
/// Add to: Features/Charlie/Onboarding/CharlieOnboardingView.swift
@MainActor
public struct CharlieOnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: AppSessionManager
    @EnvironmentObject private var themeManager: ThemeManager

    @State private var step: Int = 0
    private let pages: [OnboardPage] = OnboardPage.defaultPages
    private let onFinished: (() -> Void)?

    /// onFinished is optional: caller can pass a closure to run after completion.
    public init(onFinished: (() -> Void)? = nil) {
        self.onFinished = onFinished
    }

    public var body: some View {
        ZStack {
            // Animated gradient background for Charlie onboarding
            AnimatedGradientBackground(for: .homey)
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 6) {
                    Text("Charlie says Hi")
                        .font(.title2.bold())
                    Text("Your concierge for a calmer real estate journey")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)
                // Pager
                TabView(selection: $step) {
                    ForEach(pages.indices, id: \.self) { idx in
                        OnboardCard(page: pages[idx])
                            .tag(idx)
                            .padding(.horizontal)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                .frame(maxHeight: 420)

                // Footer actions
                HStack {
                    if step > 0 {
                        Button("Back") { withAnimation { step -= 1 } }
                    } else {
                        Button("Skip") { finish() }
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if step < pages.count - 1 {
                        Button("Continue") { withAnimation { step += 1 } }
                            .buttonStyle(.borderedProminent)
                    } else {
                        Button(pages[step].cta ?? "Finish") { finish() }
                            .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal)

                Text(hintText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
            }
            .padScreen()
        }
        .accessibilityElement(children: .contain)
    }

    private var hintText: String {
        if session.userRole == "client", let seg = session.clientSegment?.capitalized {
            return "Tailored for \(seg) clients."
        }
        return "Tailored onboarding based on your role."
    }

    private func finish() {
        // Hook for caller; keep local state clean.
        onFinished?()
        dismiss()
    }
}

// MARK: - Supporting views (private, to avoid global collisions)

private struct OnboardCard: View {
    let page: OnboardPage
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(BackgroundGradient.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(.quaternary, lineWidth: 1)
                )
            VStack(spacing: 12) {
                if let systemImage = page.systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 44, weight: .semibold))
                        .padding(.bottom, 4)
                }
                Text(page.title)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                if let subtitle = page.subtitle {
                    Text(subtitle)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                if let bullets = page.bullets, !bullets.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(bullets, id: \.self) { b in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.seal.fill").imageScale(.small)
                                Text(b)
                            }
                        }
                    }
                    .padding(.top, 6)
                }
            }
            .padding(20)
        }
    }
}

private struct OnboardPage: Hashable {
    var title: String
    var subtitle: String?
    var bullets: [String]?
    var systemImage: String?
    var cta: String?

    static let defaultPages: [OnboardPage] = [
        .init(
            title: "Welcome to HOMEY",
            subtitle: "I’m Charlie. I’ll keep you organized and one step ahead — without the chaos.",
            bullets: ["Clear steps", "Smart reminders", "Human help when needed"],
            systemImage: "sparkles"
        ),
        .init(
            title: "What brings you here?",
            subtitle: "Renting, buying, selling, or just exploring — I tailor the plan to you.",
            bullets: ["Role-aware guidance", "Only what matters", "No fluff"],
            systemImage: "person.crop.circle.badge.questionmark"
        ),
        .init(
            title: "Your crew",
            subtitle: "Paige (paperwork), Scout (search), Isla (market), Viza (space), Drew (vendors).",
            bullets: ["All in one place", "Introduced at the right time", "No app-hopping"],
            systemImage: "person.3.fill"
        ),
        .init(
            title: "Ready to begin?",
            subtitle: "We’ll set your goals and get your next step queued up.",
            bullets: ["Takes two minutes", "You can change later"],
            systemImage: "flag.checkered.2.crossed",
            cta: "Let’s go"
        )
    ]
}

// MARK: - Minimal local theming (kept private so we don't clash with your Theme files)

private enum BackgroundGradient {
    static var primary: LinearGradient {
        LinearGradient(
            colors: [
                Color(.sRGB, red: 0.96, green: 0.97, blue: 0.98, opacity: 1),
                Color(.sRGB, red: 0.90, green: 0.92, blue: 0.96, opacity: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var card: LinearGradient {
        LinearGradient(
            colors: [Color.white, Color(.systemGray6)],
            startPoint: .top, endPoint: .bottom
        )
    }
}
