//
//  WelcomeStoryboardView.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/19/25.
//

import SwiftUI

public struct WelcomeStoryboardView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismissWelcome) private var dismissWelcome
    @State private var stage = 0
    @State private var currentStageIndex: Int = 0
    private let stages = ["Lobby", "Application", "Interview", "Approval"]
    public init() {}

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                panelWelcome()
                panelTeam()
                panelProgress()
                panelSpotlight()
                    .padding(.bottom, 24)
            }
            .onAppear { currentStageIndex = 0 }
        }
        .background(AnimatedLuxeBackground())
        .safeAreaInset(edge: .top) {
            HStack {
                Spacer()
                Button("Skip") { dismissWelcome() }
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
            GlassDock(ctaTitle: "✨ Ask Charlie") { /* CTA */ }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
        }
    }

    // MARK: - Panels

    private func panelWelcome() -> some View {
        VStack(spacing: 18) {
            GlassCardContent(cornerRadius: 24, padding: 12) {
                Text("Welcome to HOMEY")
                    .font(.system(size: 36, weight: .semibold, design: .serif))
                    .foregroundStyle(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
            }
            GlassCardContent(cornerRadius: 40, padding: 0) {
                Button { /* ring action */ } label: {
                    Image(systemName: "bell.fill")
                        .font(.title2.weight(.semibold))
                        .padding(18)
                }
            }
            .symbolEffect(.bounce, value: !reduceMotion && currentStageIndex == 0)
            .accessibilityLabel("Notifications")
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 28)
    }

    @ViewBuilder
    private func panelTeam() -> some View {
        let kinds: [HomeyKind] = Array(HomeyKind.allCases)
        VStack(alignment: .leading, spacing: 12) {
            Text("Meet your Homies")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(kinds, id: \.self) { kind in
                        TeamTile(kind: kind)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal, 20)
    }

    private func panelProgress() -> some View {
        VStack(spacing: 12) {
            GlassCardContent {
                HStack(spacing: 18) {
                    ForEach(stages.indices, id: \.self) { idx in
                        let isCurrent = idx == currentStageIndex
                        VStack(spacing: 6) {
                            Circle()
                                .fill(isCurrent ? Color.white.opacity(0.95) : Color.white.opacity(0.55))
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            isCurrent ? Color.yellow.opacity(0.7) : Color.yellow.opacity(0.4),
                                            lineWidth: 0.7
                                        )
                                )
                                .scaleEffect(isCurrent ? 1.15 : 1.0)
                                .animation(
                                    .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                                    value: isCurrent
                                )
                            Text(stages[idx])
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { withAnimation(.spring()) { currentStageIndex = idx } }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(16)
            }
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func panelSpotlight() -> some View {
        VStack(spacing: 12) {
            spotlightCard(title: "Education Center", sub: "Refined lessons, bite‑size clarity", cta: "Browse")
            spotlightCard(title: "Concierge Chat", sub: "Questions, prep, lifestyle guidance", cta: "Start")
        }
        .padding(.horizontal, 20)
    }

    private func spotlightCard(title: String, sub: String, cta: String) -> some View {
        GlassCardContent {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title).font(.headline)
                    Text(sub).font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                Button(cta) {}
                    .buttonStyle(.bordered)
            }
            .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .hoverEffect(.lift)
        }
    }
}

public struct GlassDock: View {
    let ctaTitle: String
    let action: () -> Void
    public init(ctaTitle: String, action: @escaping () -> Void) {
        self.ctaTitle = ctaTitle
        self.action = action
    }

    public var body: some View {
        GlassCardContent(cornerRadius: 24, padding: 0) {
            Button(ctaTitle, action: action)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .buttonStyle(.bordered)
        }
    }
}
