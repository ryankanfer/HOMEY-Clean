import SwiftUI

// MARK: - RootView updated to present the new onboarding flow safely

struct RootView: View {
    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var appState: AppState

    @State private var showReview = false
    @State private var showOnboarding = false

    var body: some View {
        Group {
            switch session.effectiveRole {
            case "admin": AdminDashboardView()
            case "agent": AgentDashboardView()
            default: ClientDashboardView()
            }
        }
        .withGlassScaffold(
            items: HomeyUI.footerItems,
            selectedTitle: appState.selectedHomeyDisplayTitle,
            showFooterBackground: false,
            footerBottomPadding: 12,
            onSelectPersona: { item in
                appState.selectedHomey = mapTitleToKind(item.title)
            },
            onAskCTA: { appState.askHomey = appState.selectedHomey }
        )

        .sheet(
            isPresented: Binding<Bool>(
                get: { appState.askHomey != nil },
                set: { if !$0 { appState.askHomey = nil } }
            )
        ) {
            ChatModal(target: .homey(appState.askHomey ?? .charlie))
        }
        .sheet(isPresented: $showReview, onDismiss: { showReview = false }) {
            ScoutViewSheetStyle()
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingHost {
                UserDefaults.standard.set(true, forKey: "didCompleteOnboarding")
                showOnboarding = false
            }
        }
        .onAppear {
            // Present onboarding if not completed yet. Safe default that doesn't depend on external app state.
            if !UserDefaults.standard.bool(forKey: "didCompleteOnboarding") {
                showOnboarding = true
            }
        }
        .onChange(of: appState.pendingInbox) { _, new in
            if new { showReview = true; appState.pendingInbox = false }
        }
        .onChange(of: appState.pendingURL) { _, s in
            guard let s, let url = URL(string: s) else { return }
            handleDeepLink(url); appState.pendingURL = nil
        }
        .id(session.effectiveRole)
    }

    // Avoids relying on any extension so this always compiles here
    private func mapTitleToKind(_ t: String) -> HomeyKind {
        switch t.lowercased() {
        case "charlie": return .charlie
        case "paige": return .paige
        case "scout": return .scout
        case "isla": return .isla
        case "viza": return .viza
        case "drew": return .drew
        default: return .charlie
        }
    }

    private func handleDeepLink(_ url: URL) {
        switch url.host ?? "" {
        case "matches":
            appState.intentGoToMatches = true
        case "listing":
            if let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let idStr = comps.path.split(separator: "/").dropFirst().first,
               let uuid = UUID(uuidString: String(idStr))
            {
                appState.intentOpenListingId = uuid
            }
        default: break
        }
    }
}

private extension AppState {
    var selectedHomeyDisplayTitle: String {
        switch selectedHomey {
        case .charlie: "Charlie"
        case .paige: "Paige"
        case .scout: "Scout"
        case .isla: "Isla"
        case .viza: "Viza"
        case .drew: "Drew"
        }
    }
}

// MARK: - OnboardingHost wraps your OnboardingCoordinator and provides a close action

// This compiles even if you haven't added Lottie or any agent-specific flows yet.
// Assumes you've added the previously provided OnboardingCoordinator and its supporting types.
private struct OnboardingHost: View {
    var onFinish: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            OnboardingCoordinator()
                .ignoresSafeArea()

            // A persistent close button in case you need to escape during testing;
            // in production you might hide this or only show on the final step.
            Button {
                onFinish()
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
                    .padding(.top, 8)
                    .padding(.trailing, 8)
            }
            .accessibilityLabel("Close Onboarding")
        }
    }
}
