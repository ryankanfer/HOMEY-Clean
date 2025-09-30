import SwiftUI
import Combine


import UIKit

struct CinematicHomeyLandingView: View {
    @Binding var selectedTab: Int
    @Binding var showLeftDrawer: Bool

    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var animateIn = false
    @State private var searchQuery: String = ""

    @StateObject private var questionTriggerService = AIQuestionTriggerService.shared

    var body: some View {
        ZStack {
            // Static cinematic hero gradient (custom to match reference)
            HomeyHeroBackground()
                .ignoresSafeArea()

            // Place silhouette behind particles and content - increased height and better positioning
            SilhouetteBand(height: 320)
                .ignoresSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .offset(y: 40) // Extended offset to prevent any bottom cutoff

            // Ambient particles above background/silhouette but behind content
            HomeyParticlesView()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 16) {
                header

                // Typable search bar that routes based on query
                HomeSearchBar(
                    placeholder: "3 bed soho, 1040 form, lawyer Matt",
                    text: $searchQuery,
                    onSubmit: { handleHomeQuery($0) }
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                // Four primary actions
                ActionGridRow(
                    appear: animateIn,
                    onDocuments: { router.route = .documents },
                    onDirectory: { router.route = .directory },
                    onInsights: { router.route = .insights },
                    onSearch: { router.route = .search }
                )
                .padding(.horizontal, 16)

                // AI Question Queue
                AIQuestionQueueView()
                    .padding(.top, 8)

                Spacer()
            }
            .padding(.top, 112)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .overlay(alignment: .top) {
            topBar
                .padding(.top, 8)
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
        .onReceive(NotificationCenter.default.publisher(for: .mapDidExpand)) { _ in
            GlobalModalPresenter.presentOverlayWindow(
                MapExpandedSheet()
            )
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
                            .imageScale(.medium)
                    )
                    .frame(width: 36, height: 36)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 6)
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
                            .imageScale(.small)
                    )
                    .frame(width: 36, height: 36)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 6)
                    .accessibilityLabel("Profile")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : -8)
        .animation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.9).delay(0.04), value: animateIn)
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 6) {
            Text("HOMEY")
                .font(.custom("PlayfairDisplay-Bold", size: 48))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 6)
                .shadow(color: .black.opacity(0.45), radius: 2, x: 0, y: 1)

            Text("Welcome home, friend.")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                .shadow(color: .black.opacity(0.35), radius: 1.5, x: 0, y: 1)
        }
        .multilineTextAlignment(.center)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 8)
        .animation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.9).delay(0.10), value: animateIn)
    }

    // MARK: - Query Routing
    private func handleHomeQuery(_ raw: String) {
        let q = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else {
            router.route = .search
            return
        }
        let lower = q.lowercased()
        // Documents related: tax forms, uploads
        if lower.contains("1040") || lower.contains("w2") || lower.contains("w-2") || lower.contains("tax") || lower.contains("form") || lower.contains("forms") || lower.contains("document") || lower.contains("documents") || lower.contains("doc") || lower.contains("pdf") || lower.contains("upload") {
            router.route = .documents
            return
        }
        // Insights related: rates, mortgage, market
        if lower.contains("rate") || lower.contains("rates") || lower.contains("interest") || lower.contains("mortgage") || lower.contains("market") {
            router.route = .insights
            return
        }
        // Directory related: names/people/professionals
        if lower.contains("matt") || lower.contains("agent") || lower.contains("lawyer") || lower.contains("lender") || lower.contains("broker") || lower.contains("realtor") || lower.contains("attorney") || lower.contains("inspector") || lower.contains("mover") || lower.contains("contractor") || lower.contains("plumber") || lower.contains("electrician") || lower.contains("architect") || lower.contains("designer") || lower.contains("directory") {
            router.route = .directory
            return
        }
        // Default: search/discover
        router.route = .search
    }
}

// MARK: - Search Pill
private struct SearchPillView: View {
    let placeholder: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.9))
                Text(placeholder)
                    .foregroundStyle(.white.opacity(0.72))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.black.opacity(0.28))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Search")
    }
}

// MARK: - Home Search Bar (inline)
private struct HomeSearchBar: View {
    let placeholder: String
    @Binding var text: String
    let onSubmit: (String) -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.9))
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .foregroundStyle(.white)
                .submitLabel(.search)
                .focused($isFocused)
                .onSubmit { onSubmit(text) }
            if !text.isEmpty {
                Button {
                    text = ""
                    isFocused = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
            Button {
                onSubmit(text)
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundStyle(.white.opacity(0.9))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black.opacity(0.28))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 8)
    }
}

// MARK: - Home Search Sheet
private struct HomeSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var query: String
    let onSubmit: (String) -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Try: 3 bed soho, 1040, lawyer Matt, rates", text: $query)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .submitLabel(.search)
                        .onSubmit { onSubmit(query); dismiss() }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(.white.opacity(0.08))
                )

                HStack {
                    Button("Cancel") { dismiss() }
                        .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button {
                        onSubmit(query)
                        dismiss()
                    } label: {
                        Label("Go", systemImage: "arrow.right.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top, 4)

                // AI Question Queue
                AIQuestionQueueView()
                    .padding(.top, 8)

                Spacer()
            }
            .padding(16)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Action Grid Row
private struct ActionGridRow: View {
    var appear: Bool
    var onDocuments: () -> Void
    var onDirectory: () -> Void
    var onInsights: () -> Void
    var onSearch: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ActionTile(title: "Documents", subtitle: "Upload 1040s", systemImage: "doc.fill", yOffset: -6, appear: appear, delay: 0.10, action: onDocuments)
            ActionTile(title: "Directory", subtitle: "Find pros", systemImage: "person.2.fill", yOffset: 6, appear: appear, delay: 0.16, action: onDirectory)
            ActionTile(title: "Insights", subtitle: "Market trends", systemImage: "chart.line.uptrend.xyaxis", yOffset: -6, appear: appear, delay: 0.22, action: onInsights)
            ActionTile(title: "Search", subtitle: "Find anything", systemImage: "magnifyingglass", yOffset: 6, appear: appear, delay: 0.28, action: onSearch)
        }
    }
}

private struct ActionTile: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let yOffset: CGFloat
    let appear: Bool
    let delay: Double
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
                        .frame(width: 54, height: 54)
                        .shadow(color: .black.opacity(0.22), radius: 8, x: 0, y: 5)

                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(spacing: 1) {
                    Text(title)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.35), radius: 2, x: 0, y: 1)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                }
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 72)
            .opacity(appear ? 1 : 0)
            .offset(y: yOffset + (appear ? 0 : 14))
            .animation(reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.85).delay(delay), value: appear)
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

// MARK: - Particles Layer (ambient)
private struct HomeyParticlesView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let count = 36

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                context.blendMode = .plusLighter
                context.addFilter(.shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 1))

                for i in 0..<count {
                    let seed = Double(i)
                    let speed = 0.02 + (sin(seed * 1.73).magnitude) * 0.04
                    let phase = t * (reduceMotion ? 0.0 : speed) + seed * 0.37

                    let baseX = fract(sin(seed * 12.9898) * 43758.5453)
                    let drift = sin(phase * 0.8 + seed) * 0.08
                    let x = (baseX + drift).truncatingRemainder(dividingBy: 1.0) * size.width

                    let yProgress = fract(phase * 0.12)
                    let y = (1.0 - yProgress) * size.height

                    let r = 2.0 + (fract(cos(seed * 78.233) * 12345.6789) * 3.0)
                    let rect = CGRect(x: x, y: y, width: r, height: r)
                    let path = Path(ellipseIn: rect)

                    context.fill(path, with: .color(Color.white.opacity(0.12)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

@inline(__always) private func fract(_ x: Double) -> Double { x - floor(x) }

// MARK: - Bottom Silhouette Band
private struct SilhouetteBand: View {
    // Try several common asset names so we don't break if the name changed
    private let candidateNames = [
        "silhouette_group",
        "silhoutte_group", // common misspelling
        "silhouetteGroup",
        "silhoutteGroup",
        "SilhouetteGroup",
        "SilhoutteGroup",
        "silhouette",
        "Silhouette",
        "silhouette-band",
        "SilhouetteBand",
        "silhouette_band",
        "group_silhouette",
        "people_silhouette",
        "peopleSilhouette",
        "homey_silhouette",
        "HomeySilhouette",
        "bottom_silhouette",
        "BottomSilhouette",
        "bottomBand",
        "BottomBand"
    ]
    var height: CGFloat = 260

    var body: some View {
        Group {
            if let ui = loadImage() {
                Image(uiImage: ui)
                    .resizable()
                    .interpolation(.medium)
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .clipped()
                    // Removed blur effect for crisp silhouette
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.0),
                                Color.black.opacity(0.08),
                                Color.black.opacity(0.18)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                // Fallback subtle band if asset is missing
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.08),
                        Color.white.opacity(0.18)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: height)
                // Removed blur from fallback as well
            }
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
        // Fade the band into content above
        .mask(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.25),
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
        #if DEBUG
        print("[SilhouetteBand] Unable to find silhouette asset. Tried: \(candidateNames)")
        #endif
        return nil
    }
}

// MARK: - Map Expanded Sheet
struct MapExpandedSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "map.fill")
                        .foregroundStyle(.secondary)
                    Text("Map expanded")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }

                Text("You expanded the map. Here you can show filters, summary stats, or actions relevant to the expanded map state.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // AI Question Queue
                AIQuestionQueueView()
                    .padding(.top, 8)

                Spacer()

                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark.circle.fill")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(16)
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension Notification.Name {
    static let mapDidExpand = Notification.Name("MapDidExpand")
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