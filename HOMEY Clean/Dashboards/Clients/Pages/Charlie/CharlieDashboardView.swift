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
    @State private var activeChat: ChatTarget? = nil

    // Simple placeholder stations; replace with your real pipeline
    private let stations: [String] = ["Explore", "Apply", "Approve", "Close"]
    private let currentIndex: Int = 1

    public init() {}

    public var body: some View {
        ZStack {
            Rectangle()
                .fill(HomeyKind.charlie.gradients.background)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header (swap with DashboardHeader when ready)
                    WelcomeHeader(
                        title: "Welcome",
                        subtitle: "Let's make your home journey smooth and successful."
                    )

                    // Progress overview (uses your provided SubwayProgressView)
                    SubwayProgressView(stations: stations, currentIndex: currentIndex)

                    // Section: Charlie's Corner
                    Text("Charlie")
                        .foregroundStyle(HomeyKind.charlie.palette.tint)

                    VStack(spacing: 14) {
                        // Card 1: Education Center
                        CornerCard(
                            leadingSystemImage: "book.closed.fill",
                            title: "Education Center",
                            subtitle: "Short lessons, real approvals. No fluff.",
                            buttonTitle: "Browse Modules",
                            action: { showEducation = true }
                        )

                        // Card 2: Chat with Charlie
                        CornerCard(
                            leadingSystemImage: "text.bubble.fill",
                            title: "Chat with Charlie",
                            subtitle: "Got a board interview? Bring your chaos. We’ll tidy it up.",
                            buttonTitle: "Open Chat",
                            action: { activeChat = .homey(.charlie) }
                        )
                    }

                    // Primary CTA row (optional, keep for dev)
                    HStack(spacing: 12) {
                        Button("Start Onboarding") { showOnboarding = true }
                            .buttonStyle(.borderedProminent)
                            .tint(HomeyKind.charlie.palette.pill)
                            .foregroundStyle(HomeyKind.charlie.palette.tint)

                        Button("Education Center") { showEducation = true }
                            .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
        }
        // Sheets
        .sheet(isPresented: $showOnboarding) {
            CharlieOnboardingView {}
                .environmentObject(session)
        }
        .sheet(isPresented: $showEducation) {
            NavigationStack {
                EducationCenterSectionView(
                    docs: [
                        EducationCenterStoreDoc(title: "First-time buyer basics", subtitle: "10 min"),
                        EducationCenterStoreDoc(title: "Rental checklist", subtitle: "8 min")
                    ]
                )
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

// MARK: - Local, file-scoped helpers (safe to delete when you paste legacy views)

private struct WelcomeHeader: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.largeTitle.bold())
            Text(subtitle)
                .font(.subheadline)
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
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: leadingSystemImage)
                .font(.title3)
                .frame(width: 28, height: 28)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))

            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button(buttonTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .tint(HomeyKind.charlie.palette.pill)
                    .foregroundStyle(HomeyKind.charlie.palette.tint)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(HomeyKind.charlie.gradients.accent)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(HomeyKind.charlie.palette.tint.opacity(0.12), lineWidth: 1)
                )
        )
    }
}
