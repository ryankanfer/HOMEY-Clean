import SwiftUI

public struct SearchPageView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var themeManager: ThemeManager

    @State private var query: String = ""
    @State private var selectedFilters: Set<FilterChip> = []
    @State private var listings: [Listing] = Listing.sample
    @State private var isLoadingMore: Bool = false
    @State private var heroIndex: Int = 0
    @State private var segment: Segment = .discover
    @State private var showFilters: Bool = false

    public init() {}

    public var body: some View {
        ZStack {
            AnimatedGradientBackground(for: .homey)
                .environmentObject(ThemeManager.shared)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header at top
                    HeaderBar()
                        .padding(.top, 8)

                    // Filter + Query Zone (search bar directly under header)
                    FilterQueryZoneView(
                        query: $query,
                        selected: $selectedFilters,
                        onAISuggestion: handleAISuggestion,
                        onShowFilters: { showFilters = true }
                    )

                    // Segmented control moved below search bar
                    Picker("Mode", selection: $segment) {
                        ForEach(Segment.allCases, id: \.self) { seg in
                            Text(seg.title).tag(seg)
                        }
                    }
                    .pickerStyle(.segmented)

                    if segment == .discover {
                        // My Homes section
                        HorizontalRowSection(title: "My Homes", items: Array(listings.prefix(8)))

                        // Featured
                        HeroCarouselView(currentIndex: $heroIndex)

                        // Additional rows
                        HorizontalRowSection(title: "Popular this week", items: Array(listings.prefix(10)))
                        HorizontalRowSection(title: "New to market", items: Array(listings.shuffled().prefix(10)))
                        RecommendationModulesSection()
                        MarketHighlightsSection()
                        EducationGuidesSection()
                    } else {
                        // All results grid
                        ResultGridSection(listings: $listings,
                                          isLoadingMore: $isLoadingMore,
                                          onLoadMore: loadMore)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFilters) {
            FiltersSheet(
                initial: selectedFilters,
                onApply: { newSelection in
                    selectedFilters = newSelection
                }
            )
            .presentationDetents([.fraction(0.25), .medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Segments
extension SearchPageView {
    enum Segment: CaseIterable { case discover, results }
    // Titles for the segmented control
    static func segmentTitle(_ seg: Segment) -> String { seg == .discover ? "Discover" : "All results" }
}
private extension SearchPageView.Segment {
    var title: String { self == .discover ? "Discover" : "All results" }
}

// MARK: - Actions
private extension SearchPageView {
    func handleAISuggestion(_ suggestion: AISuggestion) {
        switch suggestion {
        case .expandToWilliamsburg:
            selectedFilters.insert(.init(kind: .neighborhood("Williamsburg")))
        case .openToCoops:
            selectedFilters.insert(.init(kind: .propertyType("Co-op")))
        case .petFriendlyOnly:
            selectedFilters.insert(.init(kind: .pets(true)))
        }
    }

    func loadMore() {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        DispatchQueue.main.asyncAfter(deadline: .now() + (reduceMotion ? 0.0 : 0.6)) {
            listings.append(contentsOf: Listing.moreSample)
            isLoadingMore = false
        }
    }
}

// MARK: - Hero / Featured Section
extension SearchPageView {
    struct HeroCarouselView: View {
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @Binding var currentIndex: Int
        let heroes: [HeroItem] = HeroItem.sample

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Featured")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Theme.dynamicText())
                    .padding(.horizontal, 4)

                TabView(selection: $currentIndex) {
                    ForEach(Array(heroes.enumerated()), id: \.offset) { idx, hero in
                        ZStack(alignment: .bottomLeading) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    LinearGradient(colors: [Color.black.opacity(0.3), Color.black.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                                )
                                .overlay(
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(hero.title)
                                            .font(.title2.bold())
                                            .foregroundStyle(Theme.dynamicText())
                                        Text(hero.subtitle)
                                            .font(.subheadline)
                                            .foregroundStyle(Theme.dynamicText().opacity(0.85))
                                    }
                                    .padding(16), alignment: .bottomLeading
                                )
                                .frame(height: 220)
                                .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 12)
                                .padding(.vertical, 4)
                        }
                        .tag(idx)
                        .padding(.horizontal, 2)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .frame(height: 240)
                .animation(reduceMotion ? .none : .easeOut(duration: 0.35), value: currentIndex)
            }
        }
    }
}

// MARK: - Header
extension SearchPageView {
    struct HeaderBar: View {
        @EnvironmentObject private var themeManager: ThemeManager
        var body: some View {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Search")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Theme.dynamicText())
                    Text("Find your next home")
                        .font(.subheadline)
                        .foregroundStyle(Theme.dynamicText().opacity(0.85))
                }
                Spacer()
                Image(systemName: "house.fill")
                    .foregroundStyle(Theme.dynamicText().opacity(0.9))
                    .imageScale(.large)
                    .padding(10)
                    .background(.thinMaterial, in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.1)))
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Filter + Query Zone
extension SearchPageView {
    struct FilterQueryZoneView: View {
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @Binding var query: String
        @Binding var selected: Set<FilterChip>
        var onAISuggestion: (AISuggestion) -> Void
        var onShowFilters: () -> Void

        private let chips: [FilterChip] = FilterChip.common
        private let suggestions: [AISuggestion] = [.expandToWilliamsburg, .openToCoops, .petFriendlyOnly]

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                // Query field
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Theme.dynamicText().opacity(0.8))
                    TextField("Search homes, neighborhoods, or MLS#", text: $query)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .foregroundStyle(Theme.dynamicText())
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(.white.opacity(0.08))
                )

                // Filter chips + Filters button
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        Button(action: onShowFilters) {
                            HStack(spacing: 6) {
                                Image(systemName: "slider.horizontal.3")
                                Text("Filters")
                            }
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Theme.dynamicText())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.thinMaterial, in: Capsule())
                            .overlay(Capsule().stroke(.white.opacity(0.12)))
                        }
                        .buttonStyle(.plain)

                        ForEach(chips) { chip in
                            let isSelected = selected.contains(chip)
                            Button(action: {
                                if isSelected { selected.remove(chip) } else { selected.insert(chip) }
                            }) {
                                HStack(spacing: 6) {
                                    if let sys = chip.systemImage { Image(systemName: sys) }
                                    Text(chip.title)
                                }
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(isSelected ? .black : Theme.dynamicText().opacity(0.9))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(isSelected ? Color.white : Color.white.opacity(0.12))
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(isSelected ? 0.15 : 0.0), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 2)
                }

                // AI refinement suggestions
                VStack(alignment: .leading, spacing: 10) {
                    Text("Refine with AI")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.dynamicText().opacity(0.9))
                        .padding(.horizontal, 4)

                    HStack(spacing: 8) {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Button(action: { onAISuggestion(suggestion) }) {
                                HStack(spacing: 6) {
                                    Image(systemName: suggestion.icon)
                                    Text(suggestion.title)
                                }
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Theme.dynamicText().opacity(0.95))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(.thinMaterial, in: Capsule())
                                .overlay(Capsule().stroke(.white.opacity(0.12)))
                            }
                            .buttonStyle(.plain)
                            .transition(.opacity.combined(with: .scale))
                            .animation(reduceMotion ? .none : .spring(response: 0.35, dampingFraction: 0.88), value: suggestions)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Result Grid / Feed
extension SearchPageView {
    struct ResultGridSection: View {
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        @Binding var listings: [Listing]
        @Binding var isLoadingMore: Bool
        var onLoadMore: () -> Void

        private let columns: [GridItem] = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("All results")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.dynamicText().opacity(0.95))
                    .padding(.horizontal, 4)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(listings.enumerated()), id: \.offset) { idx, item in
                        ListingCardView(listing: item)
                            .onAppear {
                                if idx >= listings.count - 3 { onLoadMore() }
                            }
                    }
                }

                if isLoadingMore {
                    HStack(spacing: 8) {
                        ProgressView().tint(.white)
                        Text("Loading more…")
                            .foregroundStyle(Theme.dynamicText().opacity(0.9))
                            .font(.footnote)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

// MARK: - Horizontal Row Section (Netflix-style)
extension SearchPageView {
    struct HorizontalRowSection: View {
        let title: String
        let items: [Listing]

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.dynamicText().opacity(0.95))
                    .padding(.horizontal, 4)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(items) { item in
                            ListingWideCardView(listing: item)
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
    }
}

// MARK: - Recommendation Modules
extension SearchPageView {
    struct RecommendationModulesSection: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Recommended for you")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.dynamicText().opacity(0.95))
                    .padding(.horizontal, 4)

                VStack(spacing: 12) {
                    RecommendationCard(avatar: .scout,
                                        title: "Homes you may like",
                                        subtitle: "Based on your recent views and saves.")
                    RecommendationCard(avatar: .isla,
                                        title: "Market insights",
                                        subtitle: "Trends tied to your current search.")
                    RecommendationCard(avatar: .paige,
                                        title: "Docs to prepare",
                                        subtitle: "Be ready to move fast on these properties.")
                    RecommendationCard(avatar: .charlie,
                                        title: "Talk to your agent",
                                        subtitle: "Shortcuts to connect now.")
                }
            }
        }
    }

    struct RecommendationCard: View {
        let avatar: HomeyAvatar
        let title: String
        let subtitle: String

        var body: some View {
            HStack(alignment: .center, spacing: 12) {
                avatar.view
                    .frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundStyle(Theme.dynamicText())
                        .font(.headline)
                    Text(subtitle)
                        .foregroundStyle(Theme.dynamicText().opacity(0.85))
                        .font(.subheadline)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.dynamicText().opacity(0.7))
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.08)))
            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 8)
        }
    }
}

// MARK: - Market Highlights
extension SearchPageView {
    struct MarketHighlightsSection: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Neighborhood & market highlights")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.dynamicText().opacity(0.95))
                    .padding(.horizontal, 4)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        MetricCard(title: "Price / sq ft", value: "$1,325", trend: .up)
                        MetricCard(title: "Days on market", value: "22", trend: .down)
                        MetricCard(title: "Inventory", value: "+8%", trend: .up)
                        StoryCard(title: "Why people are moving to Harlem",
                                  subtitle: "Culture, transit, and new developments are drawing buyers.")
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
    }

    struct MetricCard: View {
        enum Trend { case up, down, flat }
        let title: String
        let value: String
        let trend: Trend

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Theme.dynamicText().opacity(0.8))
                HStack(spacing: 6) {
                    Text(value)
                        .font(.title3.bold())
                        .foregroundStyle(Theme.dynamicText())
                    Image(systemName: trend == .up ? "arrow.up.right" : (trend == .down ? "arrow.down.right" : "arrow.right"))
                        .foregroundStyle(trend == .down ? Color.red.opacity(0.8) : (trend == .up ? Color.green.opacity(0.8) : Theme.dynamicText().opacity(0.8)))
                }
            }
            .padding(14)
            .frame(width: 180, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.08)))
            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 8)
        }
    }

    struct StoryCard: View {
        let title: String
        let subtitle: String

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Theme.dynamicText())
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.dynamicText().opacity(0.85))
                    .lineLimit(3)
            }
            .padding(14)
            .frame(width: 260, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.08)))
            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 8)
        }
    }
}

// MARK: - Education + Guides
extension SearchPageView {
    struct EducationGuidesSection: View {
        let guides: [GuideTile] = GuideTile.sample

        private let columns: [GridItem] = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Guides & explainers")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.dynamicText().opacity(0.95))
                    .padding(.horizontal, 4)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(guides) { guide in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Image(systemName: guide.icon)
                                    .foregroundStyle(Theme.dynamicText())
                                Text(guide.title)
                                    .foregroundStyle(Theme.dynamicText())
                                    .font(.headline)
                            }
                            Text(guide.subtitle)
                                .foregroundStyle(Theme.dynamicText().opacity(0.85))
                                .font(.subheadline)
                                .lineLimit(2)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.08)))
                        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 8)
                    }
                }
            }
        }
    }
}

// MARK: - Listing Cards with subtle particles
extension SearchPageView {
    struct ListingCardView: View {
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        let listing: Listing

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .background(ParticleBackground().opacity(0.35).clipShape(RoundedRectangle(cornerRadius: 12)))
                        .frame(height: 140)
                        .overlay(
                            LinearGradient(colors: [Color.black.opacity(0.35), Color.black.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                        )
                    Text(listing.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.dynamicText())
                        .padding(8)
                }
                HStack(spacing: 6) {
                    Text(listing.price)
                        .foregroundStyle(Theme.dynamicText())
                        .font(.headline)
                    Text("·")
                        .foregroundStyle(Theme.dynamicText().opacity(0.7))
                    Text(listing.details)
                        .foregroundStyle(Theme.dynamicText().opacity(0.85))
                        .font(.footnote)
                }
            }
            .padding(8)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.08)))
            .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 6)
            .scaleEffect(reduceMotion ? 1.0 : 1.0)
        }
    }

    struct ListingWideCardView: View {
        let listing: Listing

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .background(ParticleBackground().opacity(0.35).clipShape(RoundedRectangle(cornerRadius: 16)))
                        .frame(width: 260, height: 140)
                        .overlay(
                            LinearGradient(colors: [Color.black.opacity(0.35), Color.black.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                        )
                    Text(listing.title)
                        .font(.headline)
                        .foregroundStyle(Theme.dynamicText())
                        .padding(10)
                }
                Text(listing.price)
                    .foregroundStyle(Theme.dynamicText())
                    .font(.headline)
            }
            .padding(8)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.08)))
            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 8)
        }
    }

    // Subtle particle background using Canvas. Respects Reduce Motion by lowering dynamics.
    struct ParticleBackground: View {
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        private let count: Int = 14

        var body: some View {
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    let baseSpeed = reduceMotion ? 0.0 : 0.25
                    for i in 0..<count {
                        let phase = (Double(i) / Double(count)) * .pi * 2.0
                        let radius = 1.5 + 1.5 * sin(phase * 3.0)
                        let x = size.width * (0.5 + 0.45 * sin(phase + t * baseSpeed))
                        let y = size.height * (0.5 + 0.45 * cos(phase * 1.3 + t * baseSpeed))
                        let circle = Path(ellipseIn: CGRect(x: x, y: y, width: radius * 3.0, height: radius * 3.0))
                        context.fill(circle, with: .color(Color.white.opacity(0.12)))
                    }
                }
            }
            .allowsHitTesting(false)
        }
    }
}

// MARK: - Filters Sheet (collapsible via detents)
extension SearchPageView {
    struct FiltersSheet: View {
        @Environment(\.dismiss) private var dismiss

        @State private var priceRange: ClosedRange<Double> = 400_000...1_600_000
        @State private var minBeds: Int = 2
        @State private var minBaths: Int = 2
        @State private var petsAllowed: Bool = true
        @State private var propertyType: String = "Any"
        @State private var neighborhoods: Set<String> = ["Williamsburg"]
        @State private var amenities: Set<String> = ["Elevator"]

        let initial: Set<FilterChip>
        var onApply: (Set<FilterChip>) -> Void

        // Disclosure controls
        @State private var showBasics = true
        @State private var showLocation = true
        @State private var showAmenities = false

        var body: some View {
            NavigationStack {
                Form {
                    Section {
                        DisclosureGroup(isExpanded: $showBasics) {
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading) {
                                    Text("Price range")
                                    RangeSlider(value: $priceRange, bounds: 100_000...5_000_000, step: 25_000)
                                    HStack {
                                        Text("$\(Int(priceRange.lowerBound), format: .number)")
                                        Spacer()
                                        Text("$\(Int(priceRange.upperBound), format: .number)")
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }
                                Stepper("Beds: \(minBeds)+", value: $minBeds, in: 0...5)
                                Stepper("Baths: \(minBaths)+", value: $minBaths, in: 0...5)
                                Toggle("Pets allowed", isOn: $petsAllowed)
                                Picker("Property type", selection: $propertyType) {
                                    Text("Any").tag("Any")
                                    Text("Condo").tag("Condo")
                                    Text("Co-op").tag("Co-op")
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding(.vertical, 6)
                        } label: {
                            Label("Basics", systemImage: "slider.horizontal.3")
                        }
                    }

                    Section {
                        DisclosureGroup(isExpanded: $showLocation) {
                            TagCloud(title: "Neighborhoods", options: ["Williamsburg", "Harlem", "DUMBO", "Park Slope", "LIC"], selection: $neighborhoods)
                        } label: {
                            Label("Location", systemImage: "mappin.and.ellipse")
                        }
                    }

                    Section {
                        DisclosureGroup(isExpanded: $showAmenities) {
                            TagCloud(title: "Amenities", options: ["Elevator", "Doorman", "Gym", "Roof Deck"], selection: $amenities)
                        } label: {
                            Label("Amenities", systemImage: "sparkles")
                        }
                    }
                }
                .navigationTitle("Filters")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Apply") {
                            var chips = Set<FilterChip>()
                            let priceLabel = "$\(Int(priceRange.lowerBound/1000))k–$\(Int(priceRange.upperBound/1000))k"
                            chips.insert(.init(kind: .price(priceLabel)))
                            if minBeds > 0 { chips.insert(.init(kind: .beds(minBeds))) }
                            if minBaths > 0 { chips.insert(.init(kind: .baths(minBaths))) }
                            chips.insert(.init(kind: .pets(petsAllowed)))
                            if propertyType != "Any" { chips.insert(.init(kind: .propertyType(propertyType))) }
                            neighborhoods.forEach { chips.insert(.init(kind: .neighborhood($0))) }
                            amenities.forEach { chips.insert(.init(kind: .amenity($0))) }
                            onApply(chips)
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    // Simple range slider built from two sliders for demo purposes
    struct RangeSlider: View {
        @Binding var value: ClosedRange<Double>
        let bounds: ClosedRange<Double>
        let step: Double

        var body: some View {
            VStack {
                Slider(value: Binding(get: { value.lowerBound }, set: { value = max(bounds.lowerBound, min($0, value.upperBound))...value.upperBound }), in: bounds, step: step)
                Slider(value: Binding(get: { value.upperBound }, set: { value = value.lowerBound...min(bounds.upperBound, max($0, value.lowerBound)) }), in: bounds, step: step)
            }
        }
    }

    struct TagCloud: View {
        let title: String
        let options: [String]
        @Binding var selection: Set<String>

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(.subheadline).foregroundStyle(.secondary)
                FlexibleWrap(options) { option in
                    let isSelected = selection.contains(option)
                    Button(action: {
                        if isSelected { selection.remove(option) } else { selection.insert(option) }
                    }) {
                        Text(option)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(isSelected ? .black : .primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(isSelected ? Color.white : Color.secondary.opacity(0.15), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 4)
            }
        }
    }

    // Simple flexible wrap layout using Flow-like behavior
    struct FlexibleWrap<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
        let data: Data
        let content: (Data.Element) -> Content

        init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
            self.data = data
            self.content = content
        }

        var body: some View {
            var width: CGFloat = 0
            var height: CGFloat = 0

            return GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    ForEach(Array(data), id: \.self) { item in
                        content(item)
                            .padding(4)
                            .alignmentGuide(.leading) { d in
                                if (abs(width - d.width) > geo.size.width) {
                                    width = 0
                                    height -= d.height
                                }
                                let result = width
                                width -= d.width
                                return result
                            }
                            .alignmentGuide(.top) { _ in
                                let result = height
                                return result
                            }
                    }
                }
            }
            .frame(height: 120)
        }
    }
}

// MARK: - Models & Helpers (namespaced)
extension SearchPageView {
    struct Listing: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let price: String
        let details: String
    }

    enum AISuggestion: Hashable {
        case expandToWilliamsburg
        case openToCoops
        case petFriendlyOnly

        var title: String {
            switch self {
            case .expandToWilliamsburg: return "Expand to Williamsburg?"
            case .openToCoops: return "Open to co-ops?"
            case .petFriendlyOnly: return "Pet-friendly only"
            }
        }
        var icon: String {
            switch self {
            case .expandToWilliamsburg: return "arrow.up.right.circle"
            case .openToCoops: return "building.2"
            case .petFriendlyOnly: return "pawprint"
            }
        }
    }

    struct FilterChip: Identifiable, Hashable {
        enum Kind: Hashable {
            case price(String)
            case beds(Int)
            case baths(Int)
            case neighborhood(String)
            case amenity(String)
            case propertyType(String)
            case pets(Bool)
        }
        let id = UUID()
        let kind: Kind

        var title: String {
            switch kind {
            case .price(let s): return s
            case .beds(let n): return "Beds: \(n)+"
            case .baths(let n): return "Baths: \(n)+"
            case .neighborhood(let n): return n
            case .amenity(let a): return a
            case .propertyType(let t): return t
            case .pets(let allowed): return allowed ? "Pets allowed" : "No pets"
            }
        }

        var systemImage: String? {
            switch kind {
            case .price: return "dollarsign.circle"
            case .beds: return "bed.double"
            case .baths: return "shower"
            case .neighborhood: return "mappin.and.ellipse"
            case .amenity: return "sparkles"
            case .propertyType: return "building.2"
            case .pets: return "pawprint"
            }
        }
    }

    enum HomeyAvatar {
        case scout, isla, paige, charlie
        @ViewBuilder var view: some View {
            switch self {
            case .scout:
                AvatarCircle(gradient: Gradient(colors: [Color.blue, Color.purple]), label: "S")
            case .isla:
                AvatarCircle(gradient: Gradient(colors: [Color.green, Color.teal]), label: "I")
            case .paige:
                AvatarCircle(gradient: Gradient(colors: [Color.orange, Color.pink]), label: "P")
            case .charlie:
                AvatarCircle(gradient: Gradient(colors: [Color.indigo, Color.cyan]), label: "C")
            }
        }
    }

    struct AvatarCircle: View {
        let gradient: Gradient
        let label: String
        var body: some View {
            ZStack {
                Circle().fill(LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                Text(label)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
            }
        }
    }

    struct GuideTile: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let subtitle: String
    }

    struct HeroItem: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
    }
}

// MARK: - Sample Data
private extension SearchPageView.Listing {
    static let sample: [SearchPageView.Listing] = [
        .init(title: "Loft with skyline views", price: "$1.2M", details: "2 bd · 2 ba · Williamsburg"),
        .init(title: "Sunlit corner condo", price: "$899k", details: "1 bd · 1 ba · Long Island City"),
        .init(title: "Classic pre-war charm", price: "$1.05M", details: "2 bd · 1.5 ba · Upper West Side"),
        .init(title: "Modern duplex with terrace", price: "$1.8M", details: "3 bd · 2 ba · Dumbo"),
        .init(title: "Co-op near the park", price: "$650k", details: "1 bd · 1 ba · Prospect Heights"),
        .init(title: "Penthouse panorama", price: "$2.9M", details: "3 bd · 3 ba · Midtown"),
        .init(title: "Townhouse garden level", price: "$1.35M", details: "2 bd · 2 ba · Carroll Gardens"),
        .init(title: "Artist studio loft", price: "$780k", details: "1 bd · 1 ba · Bushwick"),
        .init(title: "Riverside condo", price: "$1.1M", details: "2 bd · 2 ba · Astoria"),
        .init(title: "High-rise glass condo", price: "$1.6M", details: "2 bd · 2 ba · Financial District")
    ]

    static let moreSample: [SearchPageView.Listing] = [
        .init(title: "Brownstone floor-through", price: "$1.25M", details: "2 bd · 2 ba · Park Slope"),
        .init(title: "Loft w/ exposed brick", price: "$995k", details: "1 bd · 1 ba · Tribeca"),
        .init(title: "New development studio", price: "$550k", details: "0 bd · 1 ba · Long Island City"),
        .init(title: "Corner two-bedroom", price: "$1.3M", details: "2 bd · 2 ba · Williamsburg")
    ]
}

private extension SearchPageView.FilterChip {
    static let common: [SearchPageView.FilterChip] = [
        .init(kind: .price("$500k–$1.5M")),
        .init(kind: .beds(2)),
        .init(kind: .baths(2)),
        .init(kind: .neighborhood("Williamsburg")),
        .init(kind: .neighborhood("Harlem")),
        .init(kind: .amenity("Elevator")),
        .init(kind: .amenity("Doorman")),
        .init(kind: .propertyType("Condo")),
        .init(kind: .propertyType("Co-op")),
        .init(kind: .pets(true))
    ]
}

private extension SearchPageView.GuideTile {
    static let sample: [SearchPageView.GuideTile] = [
        .init(icon: "building.columns", title: "Co-op vs Condo", subtitle: "Understand the tradeoffs and approval process."),
        .init(icon: "doc.text", title: "First-time buyer", subtitle: "Crash course to get you ready fast."),
        .init(icon: "creditcard", title: "Financing basics", subtitle: "Rates, pre-approvals, and what lenders look for."),
        .init(icon: "key", title: "Making an offer", subtitle: "How to be competitive in today's market.")
    ]
}

private extension SearchPageView.HeroItem {
    static let sample: [SearchPageView.HeroItem] = [
        .init(title: "Lofts with Skyline Views", subtitle: "See curated picks across Brooklyn"),
        .init(title: "Townhouses with Gardens", subtitle: "Outdoor space for warm evenings"),
        .init(title: "New Development Deals", subtitle: "Early incentives and closing credits")
    ]
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SearchPageView()
            .environmentObject(ThemeManager.shared)
    }
}

