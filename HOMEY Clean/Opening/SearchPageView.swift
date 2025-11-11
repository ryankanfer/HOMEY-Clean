import SwiftUI
import Supabase
import UIKit

public struct SearchPageView: View {
    @StateObject private var viewModel = SearchViewModel()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var session: AppSessionManager

    // Core search brief state
    @State private var query: String = ""
    @State private var filters = LocalSearchFilters(
        neighborhood: nil,
        minBeds: nil,
        minBaths: nil,
        minPrice: nil,
        maxPrice: nil,
        isRent: nil,
        amenities: []
    )

    // Collapsed vs expanded criteria
    @State private var isExpanded = false

    // Background parallax tracking
    @State private var scrollOffset: CGFloat = 0

    // First-time onboarding
    @AppStorage("hasSeenSearchOnboarding") private var hasSeenSearchOnboarding = false
    @AppStorage("lastStreetEasySearchSummary") private var lastStreetEasySearchSummary: String?
    @State private var showOnboarding = false

    // Listing selection + sheets
    @State private var selectedListing: Listing?
    @State private var showDetailSheet = false
    @State private var showInviteSheet = false

    // Drawers
    @State private var showLeftDrawer = false
    @State private var showRightDrawer = false

    public init() {}

    // MARK: - Derived filters for StreetEasy CTA

    private var mergedFilters: LocalSearchFilters {
        let parsed = SearchBrief.parseBrief(query)
        return SearchBrief.mergeFilters(priority: filters, fallback: parsed)
    }

    private var canOpenStreetEasy: Bool {
        StreetEasyDeepLinkBuilder.searchURL(from: mergedFilters, query: nil) != nil
    }

    private var currentSavedListings: [Listing] {
        viewModel.listings.filter { viewModel.savedListingIDs.contains($0.id) }
    }

    public var body: some View {
        ZStack {
            CinematicBackground(for: .discover)
                .offset(y: backgroundParallaxOffset)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HeaderBar()
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Track scroll for subtle background parallax
                        GeometryReader { proxy in
                            Color.clear.preference(key: ScrollOffsetKey.self, value: proxy.frame(in: .named("searchScroll")).minY)
                        }
                        .frame(height: 0)

                        // Centered hero with single Invite pill just below
                        heroHeaderSection

                        // Description and “How this works” pill (no duplicate Invite here)
                        introDescriptionSection

                        // Collapsed/expanded content
                        if isExpanded {
                            describeBoxCollapsedLabelSection(showExpand: false)
                            CriteriaExpandedSection(
                                filters: $filters,
                                query: $query,
                                onCollapse: {
                                    // Collapse and synthesize back to the natural language box
                                    query = SearchBrief.synthesizeBrief(from: filters, existing: query)
                                    withAppropriateAnimation { isExpanded = false }
                                }
                            )
                            quickFiltersPillsSection
                        } else {
                            describeBoxCollapsedLabelSection(showExpand: true)
                            SavedHomesSection(
                                isLoading: viewModel.isLoading,
                                savedListings: currentSavedListings,
                                savedLinks: viewModel.savedStreetEasyLinks,
                                savedIDs: viewModel.savedListingIDs,
                                onToggleSave: { listing in
                                    viewModel.toggleSave(for: listing)
                                },
                                onTap: { listing in
                                    selectedListing = listing
                                    showDetailSheet = true
                                },
                                onOpenStreetEasy: { listing in
                                    let url = StreetEasyDeepLinkBuilder.listingURL(for: listing) ??
                                        StreetEasyDeepLinkBuilder.searchURL(
                                            from: LocalSearchFilters(
                                                neighborhood: listing.neighborhood,
                                                minBeds: nil,
                                                minBaths: nil,
                                                minPrice: nil,
                                                maxPrice: nil
                                            ),
                                            query: nil
                                        )
                                    if let url { StreetEasyDeepLinkBuilder.open(url: url) }
                                }
                            )
                        }
                        streetEasyCTASection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
                .coordinateSpace(name: "searchScroll")
            }
        }
        // Left drawer edge-swipe
        .leftEdgeSwipe(isDrawerPresented: $showLeftDrawer)
        // Right drawer edge-swipe (mirror of ClientTabView overlay gesture)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 24)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 8)
                        .onEnded { value in
                            if value.translation.width < -40 { // Leftward drag from right edge
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                                    showRightDrawer = true
                                }
                            }
                        }
                )
        }
        // Drawers overlays
        .overlay {
            LeftNavigationDrawer(isPresented: $showLeftDrawer)
                .environmentObject(router)
                .environmentObject(session)
                .allowsHitTesting(showLeftDrawer)
                .opacity(showLeftDrawer ? 1 : 0)
        }
        .overlay {
            RightDrawerView(isPresented: $showRightDrawer) {
                SimplifiedProfileView(closeDrawerAction: {
                    showRightDrawer = false
                })
                .environmentObject(router)
                .environmentObject(session)
            }
            .allowsHitTesting(showRightDrawer)
            .opacity(showRightDrawer ? 1 : 0)
        }
        .onPreferenceChange(ScrollOffsetKey.self) { offset in
            scrollOffset = offset
        }
        .sheet(isPresented: $showDetailSheet) {
            if let listing = selectedListing {
                PropertyDetailView(listing: listing)
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) {
                            Button {
                                if let url = StreetEasyDeepLinkBuilder.listingURL(for: listing) ??
                                    StreetEasyDeepLinkBuilder.searchURL(
                                        from: LocalSearchFilters(
                                            neighborhood: listing.neighborhood,
                                            minBeds: nil,
                                            minBaths: nil,
                                            minPrice: nil,
                                            maxPrice: nil
                                        ),
                                        query: nil
                                    ) {
                                    StreetEasyDeepLinkBuilder.open(url: url)
                                }
                            } label: {
                                Label("View on StreetEasy", systemImage: "link")
                            }
                        }
                    }
            }
        }
        .onAppear {
            viewModel.loadInitialData()
            if !hasSeenSearchOnboarding {
                showOnboarding = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Refresh saved StreetEasy links and saved IDs on foreground
            viewModel.loadInitialData()
        }
        .fullScreenCover(isPresented: $showOnboarding, onDismiss: {
            hasSeenSearchOnboarding = true
        }) {
            OnboardingCardStack {
                hasSeenSearchOnboarding = true
                showOnboarding = false
            }
        }
        .alert(
            "Error",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { newValue in
                    if !newValue { viewModel.errorMessage = nil }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("ShowInviteAgentSheet"))) { _ in
            showInviteSheet = true
        }
        .sheet(isPresented: $showInviteSheet) {
            InviteAgentSheet()
        }
    }

    // MARK: - Sections

    // Centered hero: “Find your” + gradient “next home”, with a single Invite pill directly below
    private var heroHeaderSection: some View {
        VStack(spacing: 14) {
            VStack(spacing: 8) {
                Text("Find your")
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.95))
                    .frame(maxWidth: .infinity, alignment: .center)

                LinearGradient(
                    colors: [
                        Theme.primaryAction.opacity(0.95),
                        .white.opacity(0.9)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(
                    Text("next home")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                )
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top, 8)

            // Single Invite pill directly under the centered headline
            Button {
                showInviteSheet = true
            } label: {
                HStack(spacing: 10) {
                    Text("🤝")
                    Text("Invite your agent")
                        .font(.subheadline.weight(.semibold))
                }
                .frame(height: 44)
                .padding(.horizontal, 16)
                .background(.ultraThinMaterial, in: Capsule(style: .continuous))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Theme.primaryAction.opacity(0.35),
                                    .white.opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 6)
            }
            .buttonStyle(.plain)

            // Small tagline under the hero, centered
            Text("HOMEY + StreetEasy, working together.")
                .font(.callout.weight(.semibold))
                .foregroundStyle(.white.opacity(0.55))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity)
    }

    // Intro paragraph and “How this works” pill (no duplicate Invite here)
    private var introDescriptionSection: some View {
        VStack(spacing: 16) {
            Text("A single place to describe what you want. We turn it into a StreetEasy search and a HOMEY workspace.")
                .font(.callout.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)

            HStack {
                infoPillSection
                Spacer()
            }
        }
        .padding(.top, 6)
    }

    private var infoPillSection: some View {
        Button {
            showOnboarding = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                Text("How this works")
                    .font(.footnote.weight(.semibold))
            }
            .frame(height: 40)
            .padding(.horizontal, 14)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [Theme.primaryAction.opacity(0.25), .white.opacity(0.12)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ), lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("How this works")
    }

    // Collapsed describe box (also used above expanded criteria as a simple text input)
    private func describeBoxCollapsedLabelSection(showExpand: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Describe your search")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))

            // Using TextEditor to feel like a textarea
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 22)
                    .fill(.thinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.12), Theme.primaryAction.opacity(0.25)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: .black.opacity(0.22), radius: 12, x: 0, y: 8)

                TextEditor(text: $query)
                    .scrollContentBackground(.hidden)
                    .padding(14)
                    .frame(minHeight: 110)
                    .onSubmit {
                        let parsed = SearchBrief.parseBrief(query)
                        applyParsedFilters(parsed)
                    }

                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Natural light, close to work, quiet street…")
                        .foregroundStyle(.white.opacity(0.55))
                        .font(.body)
                        .padding(18)
                        .allowsHitTesting(false)
                }
            }
            .frame(minHeight: 110)

            // Suggested filters under the type box
            let amenitySuggestions = SearchBrief.suggestedAmenities(from: query, existing: filters.amenities)
            if !amenitySuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Suggested filters")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.secondary)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(amenitySuggestions, id: \.self) { s in
                                AIPrefButton(text: s) {
                                    // Add to structured filters and reflect in text for transparency
                                    filters.amenities.insert(s)
                                    appendToQueryIfNeeded(s.lowercased())
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            if showExpand {
                Button {
                    // Expand and seed structured filters from the current text
                    let parsed = SearchBrief.parseBrief(query)
                    filters = SearchBrief.mergeFilters(priority: filters, fallback: parsed)
                    withAppropriateAnimation {
                        isExpanded = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text("Add details")
                        Image(systemName: "chevron.down")
                            .font(.footnote.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.2)))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // Expanded criteria section moved to Opening/Sections/CriteriaExpandedSection.swift

    private var streetEasyCTASection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                if let url = StreetEasyDeepLinkBuilder.searchURL(from: mergedFilters, query: nil) {
                    StreetEasyDeepLinkBuilder.open(url: url)
                    lastStreetEasySearchSummary = searchSummary(from: mergedFilters)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.right.square.fill")
                        .imageScale(.medium)
                    Text("Browse on StreetEasy")
                        .font(.subheadline.weight(.semibold))
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Theme.primaryAction.opacity(0.35),
                                    .white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            }
            .buttonStyle(.plain)
            .disabled(!canOpenStreetEasy)
            .opacity(canOpenStreetEasy ? 1.0 : 0.5)

            Text("Save your favorites back into HOMEY.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            if let summary = lastStreetEasySearchSummary, !summary.isEmpty {
                Text("Last search: \(summary)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }

    private var quickFiltersPillsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick filters")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    AIPrefButton(text: "Elevator") {
                        // No structured field yet — append to natural language
                        appendToQueryIfNeeded("elevator")
                    }
                    AIPrefButton(text: "Laundry") {
                        appendToQueryIfNeeded("laundry")
                    }
                    AIPrefButton(text: "Pet friendly") {
                        appendToQueryIfNeeded("pet friendly")
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Helpers

    private func withAppropriateAnimation(_ changes: @escaping () -> Void) {
        if reduceMotion {
            changes()
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                changes()
            }
        }
    }

    private func appendToQueryIfNeeded(_ token: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            query = token
        } else if !trimmed.lowercased().contains(token.lowercased()) {
            query = trimmed + (trimmed.last?.isWhitespace == true ? "" : " ") + token
        }
    }

    // Apply parsed filters to current chips (used on TextField submit for visual feedback)
    private func applyParsedFilters(_ parsed: LocalSearchFilters) {
        // Only set if not already set by chips (chips win)
        if filters.neighborhood == nil { filters.neighborhood = parsed.neighborhood }
        if filters.minBeds == nil { filters.minBeds = parsed.minBeds }
        if filters.minBaths == nil { filters.minBaths = parsed.minBaths }
        if filters.minPrice == nil { filters.minPrice = parsed.minPrice }
        if filters.maxPrice == nil { filters.maxPrice = parsed.maxPrice }
        if filters.isRent == nil { filters.isRent = parsed.isRent }
        filters.amenities.formUnion(parsed.amenities)
    }

    private func searchSummary(from filters: LocalSearchFilters) -> String {
        var parts: [String] = []

        if let neighborhood = filters.neighborhood, !neighborhood.isEmpty {
            parts.append(neighborhood)
        }

        if let beds = filters.minBeds {
            parts.append("\(beds)+ beds")
        }

        if let baths = filters.minBaths {
            parts.append("\(baths)+ baths")
        }

        if let minPrice = filters.minPrice, let maxPrice = filters.maxPrice {
            let minString = String(describing: minPrice)
            let maxString = String(describing: maxPrice)
            parts.append("$\(minString)–$\(maxString)")
        } else if let minPrice = filters.minPrice {
            let minString = String(describing: minPrice)
            parts.append("from $\(minString)")
        } else if let maxPrice = filters.maxPrice {
            let maxString = String(describing: maxPrice)
            parts.append("up to $\(maxString)")
        }

        if let isRent = filters.isRent {
            parts.append(isRent ? "for rent" : "for sale")
        }

        if parts.isEmpty {
            return "All listings"
        }

        return parts.joined(separator: " · ")
    }
}

// MARK: - Parallax helpers

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private extension SearchPageView {
    var backgroundParallaxOffset: CGFloat {
        if reduceMotion { return 0 }
        let raw = -scrollOffset * 0.06 // subtle parallax
        return max(min(raw, 20), -20)
    }
}

// MARK: - Quick tip chip (icon + text)

private struct QuickTipChip: View {
    let text: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .imageScale(.small)
                Text(text)
                    .font(.footnote.weight(.semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.thinMaterial, in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.12)))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SearchPageView()
            .environmentObject(ThemeManager.shared)
            .environmentObject(AppRouter())
            .environmentObject(AppSessionManager.shared)
    }
}
