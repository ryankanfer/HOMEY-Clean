import SwiftUI
import UIKit

struct CinematicHomeyLandingView: View {
    @Binding var selectedTab: Int
    @Binding var showLeftDrawer: Bool

    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var animateIn = false

    var body: some View {
        ZStack {
            // Static cinematic hero gradient (custom to match reference)
            HomeyHeroBackground()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                topBar

                Spacer(minLength: 12)

                header

                // Glassy search pill that routes to Search/Discover
                SearchPillView(placeholder: "3 bed soho, 1040 form, lawyer Matt") {
                    router.route = .search
                }
                .padding(.horizontal, 24)

                // Four primary actions
                ActionGridRow(
                    onDocuments: { router.route = .documents },
                    onDirectory: { router.route = .directory },
                    onInsights: { router.route = .insights },
                    onSearch: { router.route = .search }
                )
                .padding(.horizontal, 20)

                Spacer()
            }
            .padding(.top, 12)
        }
        .overlay(alignment: .bottom) {
            SilhouetteBand()
                .ignoresSafeArea(edges: .bottom)
        }
        .onAppear {
            themeManager.setCurrentPage(.homey)
            if reduceMotion {
                animateIn = true
            } else {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.88).delay(0.08)) {
                    animateIn = true
                }
            }
        }
    }

    // MARK: - Top Bar (hamburger + profile)
    private var topBar: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                    showLeftDrawer = true
                }
            } label: {
                Circle()
                    .fill(Color.black.opacity(0.28))
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.15), lineWidth: 0.6)
                    )
                    .overlay(
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.white)
                            .imageScale(.large)
                    )
                    .frame(width: 40, height: 40)
                    .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 8)
                    .accessibilityLabel("Open menu")
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                router.route = .profile
            } label: {
                Circle()
                    .fill(Color.black.opacity(0.28))
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.15), lineWidth: 0.6)
                    )
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundStyle(.white)
                            .imageScale(.medium)
                    )
                    .frame(width: 40, height: 40)
                    .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 8)
                    .accessibilityLabel("Profile")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : -10)
        .animation(reduceMotion ? .none : .spring(response: 0.6, dampingFraction: 0.9).delay(0.05), value: animateIn)
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 8) {
            Text("HOMEY")
                .font(.custom("PlayfairDisplay-Bold", size: 60))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 8)

            Text("Welcome home, friend.")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
        }
        .multilineTextAlignment(.center)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 10)
        .animation(reduceMotion ? .none : .spring(response: 0.6, dampingFraction: 0.9).delay(0.12), value: animateIn)
    }
}

// MARK: - Search Pill
private struct SearchPillView: View {
    let placeholder: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.9))
                Text(placeholder)
                    .foregroundStyle(.white.opacity(0.72))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.black.opacity(0.28))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.4), radius: 18, x: 0, y: 12)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Search")
    }
}

// MARK: - Action Grid Row
private struct ActionGridRow: View {
    var onDocuments: () -> Void
    var onDirectory: () -> Void
    var onInsights: () -> Void
    var onSearch: () -> Void

    var body: some View {
        HStack(spacing: 18) {
            ActionTile(title: "Documents", subtitle: "Upload 1040s", systemImage: "doc.fill", action: onDocuments)
            ActionTile(title: "Directory", subtitle: "Find pros", systemImage: "person.2.fill", action: onDirectory)
            ActionTile(title: "Insights", subtitle: "Market trends", systemImage: "chart.line.uptrend.xyaxis", action: onInsights)
            ActionTile(title: "Search", subtitle: "Find anything", systemImage: "magnifyingglass", action: onSearch)
        }
    }
}

private struct ActionTile: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 9) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
                        .frame(width: 66, height: 66)
                        .shadow(color: .black.opacity(0.28), radius: 10, x: 0, y: 6)

                    Image(systemName: systemImage)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(1)
                }
                .multilineTextAlignment(.center)
            }
            .frame(width: 86)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Homey Hero Background
private struct HomeyHeroBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.42, blue: 0.66),   // deep sky blue (top)
                    Color(red: 0.34, green: 0.71, blue: 0.86),   // cyan mid
                    Color(red: 0.88, green: 0.93, blue: 0.97)    // misty bottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            // Slight vignette for edge depth
            RadialGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.22)],
                center: .center,
                startRadius: 300,
                endRadius: 900
            )
            .blendMode(.multiply)
        }
    }
}

// MARK: - Bottom Silhouette Band
private struct SilhouetteBand: View {
    // Try several common asset names so we don't break if the name changed
    private let candidateNames = [
        "silhouette_group",
        "silhoutte_group", // common misspelling
        "group_silhouette",
        "homey_silhouette"
    ]
    var height: CGFloat = 260

    var body: some View {
        Group {
            if let ui = loadImage() {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .clipped()
                    .blur(radius: 8)
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.0),
                                Color.black.opacity(0.12),
                                Color.black.opacity(0.30)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                // Fallback subtle band if asset is missing
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.05),
                        Color.white.opacity(0.12)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: height)
                .blur(radius: 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
        // Fade the band into content above
        .mask(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .allowsHitTesting(false)
    }

    private func loadImage() -> UIImage? {
        for name in candidateNames {
            if let img = UIImage(named: name) { return img }
        }
        return nil
    }
}

#if DEBUG
struct CinematicHomeyLandingView_Previews: PreviewProvider {
    struct Wrapper: View {
        @State private var selectedTab = 0
        @State private var showLeftDrawer = false
        @StateObject private var router = AppRouter()
        @StateObject private var themeManager = ThemeManager()

        var body: some View {
            CinematicHomeyLandingView(selectedTab: $selectedTab, showLeftDrawer: $showLeftDrawer)
                .environmentObject(router)
                .environmentObject(themeManager)
        }
    }

    static var previews: some View {
        Wrapper()
            .previewDisplayName("CinematicHomeyLandingView")
    }
}
#endif
