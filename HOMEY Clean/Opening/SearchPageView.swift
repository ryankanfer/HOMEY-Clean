import SwiftUI
import Supabase

@available(*, deprecated, message: "This view has been replaced by the new SearchAndDiscoverView. Please use that instead.")
public struct SearchPageView: View {
    @StateObject private var viewModel = SearchViewModel()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var themeManager: ThemeManager

    @State private var query: String = ""
    @State private var heroIndex: Int = 0
    @State private var segment: Segment = .list
    @State private var showFilters: Bool = false
    @State private var selectedListing: Listing?
    @State private var showDetailSheet = false
    @State private var showInviteSheet = false

    public init() {}

    public var body: some View {
        ZStack {
            CinematicBackground(for: .discover)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HeaderBar()
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 16)

                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                    TextField("2 bed soho, dog friendly no walk up condo", text: $query)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        AIPrefButton(text: "$1m-$2m")
                        AIPrefButton(text: "2 beds")
                        AIPrefButton(text: "Williamsburg")
                        AIPrefButton(text: "Pet Friendly")
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)

                Picker("View Mode", selection: $segment) {
                    ForEach(Segment.allCases, id: \.self) { seg in Text(seg.title).tag(seg) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                if viewModel.isLoading {
                    ProgressView()
                    Spacer()
                } else {
                    content
                }
            }
        }
        .sheet(isPresented: $showDetailSheet) {
            if let listing = selectedListing {
                PropertyDetailView(listing: listing)
            }
        }
        .onAppear {
            viewModel.loadInitialData()
        }
        .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("ShowInviteAgentSheet"))) { _ in
            showInviteSheet = true
        }
        .sheet(isPresented: $showInviteSheet) {
            InviteAgentSheet()
        }
    }

    @ViewBuilder
    private var content: some View {
        if segment == .list {
            ScrollView {
                VStack(spacing: 24) {
                    HorizontalRowSection(
                        title: "My Homes",
                        items: Array(viewModel.listings.prefix(8))
                    ) { listing in
                        selectedListing = listing
                        showDetailSheet = true
                    }
                    HeroCarouselView(currentIndex: $heroIndex)
                    HorizontalRowSection(
                        title: "Popular this week",
                        items: Array(viewModel.listings.prefix(10))
                    ) { listing in
                        selectedListing = listing
                        showDetailSheet = true
                    }
                    HorizontalRowSection(
                        title: "New to market",
                        items: Array(viewModel.listings.shuffled().prefix(10))
                    ) { listing in
                        selectedListing = listing
                        showDetailSheet = true
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        } else {
            InteractiveMapViewPlaceholder(listings: viewModel.listings) { listing in
                selectedListing = listing
                showDetailSheet = true
            }
            .padding(.horizontal, 16)
            Spacer()
        }
    }
}


// MARK: - View Components

struct AIPrefButton: View {
    let text: String
    var body: some View {
        Button(action: {}) {
            Text(text)
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.thinMaterial, in: Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.12)))
        }
        .buttonStyle(.plain)
    }
}

struct InteractiveMapViewPlaceholder: View {
    let listings: [Listing]
    let onMarkerTap: (Listing) -> Void
    private let markerPositions: [CGPoint] = [CGPoint(x: 0.25, y: 0.3), CGPoint(x: 0.5, y: 0.45), CGPoint(x: 0.7, y: 0.6), CGPoint(x: 0.4, y: 0.75), CGPoint(x: 0.65, y: 0.2)]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 20).fill(Color.gray.opacity(0.2))
                ForEach(Array(zip(listings.prefix(markerPositions.count), markerPositions.indices)), id: \.0.id) { listing, index in
                    PropertyMarker(listing: listing)
                        .position(x: geometry.size.width * markerPositions[index].x, y: geometry.size.height * markerPositions[index].y)
                        .onTapGesture { onMarkerTap(listing) }
                }
            }
        }
    }
}

struct PropertyMarker: View {
    let listing: Listing
    var body: some View {
        Text(listing.displayPrice)
            .font(.caption).fontWeight(.bold).padding(.horizontal, 8).padding(.vertical, 4)
            .background(Color.white).foregroundColor(.black).cornerRadius(8).shadow(radius: 3)
    }
}


// MARK: - Segments
extension SearchPageView {
    enum Segment: CaseIterable { case list, map }
}

private extension SearchPageView.Segment {
    var title: String {
        switch self {
        case .list: return "List"; case .map: return "Map"
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
                Text("Featured").font(.title2.weight(.semibold)).padding(.horizontal, 4)
                TabView(selection: $currentIndex) {
                    ForEach(Array(heroes.enumerated()), id: \.offset) { idx, hero in
                        ZStack {
                            AsyncImage(url: URL(string: "https://picsum.photos/seed/hero\(idx)/1200/700")) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Rectangle().fill(Color.gray.opacity(0.25))
                            }
                            .frame(height: 220)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                LinearGradient(
                                    colors: [Color.black.opacity(0.0), Color.black.opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            )

                            VStack(alignment: .leading, spacing: 8) {
                                Spacer()
                                Text(hero.title).font(.title2.bold()).foregroundColor(.white)
                                Text(hero.subtitle).font(.subheadline).foregroundColor(.white.opacity(0.9))
                            }
                            .padding(16)
                        }
                        .frame(height: 220)
                        .shadow(radius: 18, x: 0, y: 12)
                        .padding(.vertical, 4)
                        .tag(idx)
                        .padding(.horizontal, 2)
                    }
                }.tabViewStyle(.page(indexDisplayMode: .automatic)).frame(height: 240)
            }
        }
    }
}

// MARK: - Header
extension SearchPageView {
    struct HeaderBar: View {
        var body: some View {
            HStack {
                Text("Find your next home").font(.largeTitle.bold())
                Spacer()
                Button {
                    NotificationCenter.default.post(name: .init("ShowInviteAgentSheet"), object: nil)
                } label: {
                    Label("Invite Agent", systemImage: "qrcode")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

// MARK: - Horizontal Row Section
extension SearchPageView {
    struct HorizontalRowSection: View {
        let title: String
        let items: [Listing]
        let onTap: (Listing) -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text(title).font(.title3.weight(.semibold)).padding(.horizontal, 4)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(items) { item in
                            ListingWideCardView(listing: item, onTap: onTap)
                        }
                    }.padding(.horizontal, 2)
                }
            }
        }
    }
}


// MARK: - Listing Cards with save icon
extension SearchPageView {
    struct ListingWideCardView: View {
        @EnvironmentObject var viewModel: SearchViewModel
        let listing: Listing
        let onTap: (Listing) -> Void
        
        var body: some View {
            let isSaved = viewModel.savedListingIDs.contains(listing.id)
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: ListingWideCardView.imageURL(for: listing))) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle().fill(Color.gray.opacity(0.25))
                    }
                    .frame(width: 260, height: 140)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        LinearGradient(
                            colors: [Color.black.opacity(0.0), Color.black.opacity(0.65)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    )
                    .overlay(
                        VStack(alignment: .leading, spacing: 4) {
                            Spacer()
                            Text(listing.address)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(listing.neighborhood)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .padding(10),
                        alignment: .bottomLeading
                    )
                    .onTapGesture { onTap(listing) }

                    Button(action: { viewModel.toggleSave(for: listing) }) {
                        Image(systemName: isSaved ? "heart.fill" : "heart")
                            .foregroundColor(isSaved ? .red : .white)
                            .padding(8)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .padding(10)
                }
                Text(listing.displayPrice).font(.headline)
            }.padding(8).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        
        static func imageURL(for listing: Listing) -> String {
            let url = listing.thumbnailURL
            if url.lowercased().hasPrefix("http") { return url }
            // Fallback to a stable stock image seeded by the listing ID
            let seed = listing.id.uuidString
            return "https://picsum.photos/seed/\(seed)/600/360"
        }
    }
}

struct HeroItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    static let sample: [HeroItem] = [
        .init(title: "Lofts with Skyline Views", subtitle: "See curated picks across Brooklyn"),
        .init(title: "Townhouses with Gardens", subtitle: "Outdoor space for warm evenings"),
        .init(title: "New Development Deals", subtitle: "Early incentives and closing credits")
    ]
}

#Preview {
    NavigationStack {
        SearchPageView()
            .environmentObject(ThemeManager.shared)
            .environmentObject(SearchViewModel())
    }
}

// MARK: - Invite Agent Sheet
struct InviteAgentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var link: ClientAgentLink?
    @State private var shareURL: URL?
    @State private var isCreating = false
    @State private var acceptanceStatus: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let link, let url = shareURL {
                    VStack(spacing: 12) {
                        // QR code
                        QRCodeView(string: url.absoluteString)
                            .frame(width: 180, height: 180)
                            .padding(8)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

                        Text("Share this code with your agent")
                            .font(.headline)
                        Text(link.code)
                            .font(.title2.monospacedDigit())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.thinMaterial, in: Capsule())

                        ShareLink(item: url) {
                            Label("Share Invite", systemImage: "square.and.arrow.up")
                        }
                    }

                    if !acceptanceStatus.isEmpty {
                        Text(acceptanceStatus)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.top, 6)
                    }
                } else {
                    if isCreating {
                        ProgressView("Creating invite...")
                    } else {
                        ContentUnavailableView("Invite not created", systemImage: "qrcode", description: Text("Tap Create to generate an invite"))
                    }
                }

                Spacer()
            }
            .padding(16)
            .navigationTitle("Invite Agent")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") { Task { await createInvite() } }
                        .disabled(isCreating)
                }
            }
            .task { if link == nil { await createInvite() } }
        }
    }

    private func createInvite() async {
        isCreating = true
        defer { isCreating = false }
        do {
            let created = try await ClientAgentLinkRepository.shared.createInvite()
            link = created
            shareURL = ClientAgentLinkRepository.shared.shareURL(for: created.code)
            // Start polling for acceptance
            Task {
                if let accepted = try await ClientAgentLinkRepository.shared.waitForAcceptance(code: created.code, timeout: 300, interval: 2) {
                    acceptanceStatus = "Connected with your agent!"
                }
            }
        } catch {
            acceptanceStatus = "Failed to create invite: \(error.localizedDescription)"
        }
    }
}

// Simple QR renderer
struct QRCodeView: View {
    let string: String
    var body: some View {
        if let img = generateQRCode(from: string) {
            Image(uiImage: img).resizable().interpolation(.none).scaledToFit()
        } else {
            Rectangle().fill(.secondary.opacity(0.2))
        }
    }
    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .ascii)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: 6, y: 6))
        return UIImage(ciImage: scaled)
    }
}