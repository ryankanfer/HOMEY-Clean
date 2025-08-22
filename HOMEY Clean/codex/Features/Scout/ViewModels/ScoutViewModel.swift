import Foundation
import SwiftUI

@Observable
class ScoutViewModel {
    // MARK: - Properties

    private(set) var listings: [Listing] = []
    private(set) var activeLenses: [Lens] = []
    private(set) var shortlist: [ShortlistEntry] = []
    private(set) var progressState: ProgressState

    var selectedListing: Listing?
    var isShowingPeekCard = false
    var isShowingFullSheet = false
    var isShowingHoloMap = false

    // Lens viewport state
    var lensSize: LensSize = .medium
    var lensPosition: CGPoint = .zero
    var isDragging = false

    // Time of day state
    var timeOfDay: TimeOfDay = .day

    // Filter state
    var priceRange: ClosedRange<Double> = 0 ... 10_000_000
    var selectedBedrooms: Int = 0
    var selectedBathrooms: Int = 0

    // MARK: - Initialization

    init(progressState: ProgressState = ProgressState()) {
        self.progressState = progressState
        setupProgressionEventListener()
        loadInitialData()
    }

    // MARK: - Data Loading

    private func loadInitialData() {
        // TODO: Implement data loading from service
        listings = [] // Load from ListingService
        activeLenses = Lens.defaultLenses
    }

    // MARK: - Lens Management

    func toggleLens(_ lens: Lens) {
        if let index = activeLenses.firstIndex(where: { $0.id == lens.id }) {
            activeLenses.remove(at: index)
        } else {
            activeLenses.append(lens)
        }
        filterListings()
    }

    func isLensActive(_ lensType: LensType) -> Bool {
        return activeLenses.contains { $0.type == lensType }
    }

    func setLensSize(_ size: LensSize) {
        let previousSize = lensSize
        lensSize = size

        // Analytics tracking
        trackEvent("lens_size_changed", parameters: [
            "previous_size": previousSize.rawValue,
            "new_size": size.rawValue,
            "interaction_type": "manual" // vs "pinch"
        ])
    }

    func updateLensPosition(_ position: CGPoint) {
        lensPosition = position
        // TODO: Update visible listings based on lens position
    }

    // MARK: - Listing Management

    private func filterListings() {
        // Apply active lenses to filter listings
        let filteredListings = listings.filter { listing in
            activeLenses.allSatisfy { lens in
                lens.filterCriteria?.matches(listing: listing) ?? true
            }
        }

        // TODO: Update UI with filtered listings
    }

    // MARK: - Shortlist Management

    func addToShortlist(_ listing: Listing) {
        guard !shortlist.contains(where: { $0.listing.id == listing.id }) else { return }

        let entry = ShortlistEntry(
            listing: listing,
            order: shortlist.count
        )
        shortlist.append(entry)
        progressState.recordSave(in: listing.address) // TODO: Use proper neighborhood

        // Check for progression events
        checkForProgressionEvents()

        // Analytics tracking
        trackEvent("property_saved", parameters: [
            "listing_id": listing.id,
            "neighborhood": listing.neighborhood,
            "price": listing.price,
            "shortlist_count": shortlist.count
        ])
    }

    func removeFromShortlist(_ entry: ShortlistEntry) {
        let previousCount = shortlist.count
        shortlist.removeAll { $0.id == entry.id }

        // Analytics tracking
        trackEvent("property_removed", parameters: [
            "listing_id": entry.listing.id,
            "neighborhood": entry.listing.neighborhood,
            "time_in_shortlist": Date().timeIntervalSince(entry.savedDate),
            "shortlist_count": shortlist.count
        ])
    }

    func reorderShortlist(from source: IndexSet, to destination: Int) {
        shortlist.move(fromOffsets: source, toOffset: destination)
        // Update order property for affected entries
        for (index, var entry) in shortlist.enumerated() {
            entry.order = index
        }
    }

    // MARK: - View State Management

    func showPeekCard(for listing: Listing) {
        selectedListing = listing
        isShowingPeekCard = true

        // Analytics tracking
        trackEvent("peek_card_opened", parameters: [
            "listing_id": listing.id,
            "neighborhood": listing.neighborhood,
            "price": listing.price,
            "source": "lens_tap"
        ])
    }

    func showFullSheet(for listing: Listing) {
        selectedListing = listing
        isShowingFullSheet = true
        isShowingPeekCard = false

        // Analytics tracking
        trackEvent("full_sheet_opened", parameters: [
            "listing_id": listing.id,
            "neighborhood": listing.neighborhood,
            "price": listing.price,
            "source": "peek_card"
        ])
    }

    func toggleHoloMap() {
        isShowingHoloMap.toggle()
    }

    func toggleTimeOfDay() {
        timeOfDay = timeOfDay == .day ? .dusk : .day
    }

    // MARK: - Filter Updates

    func updatePriceRange(_ range: ClosedRange<Double>) {
        priceRange = range
        filterListings()
    }

    func updateBedrooms(_ count: Int) {
        selectedBedrooms = count
        filterListings()
    }

    func updateBathrooms(_ count: Int) {
        selectedBathrooms = count
        filterListings()
    }

    func setBedroomFilter(_ filter: String) {
        switch filter {
        case "Any":
            selectedBedrooms = 0
        case "1+":
            selectedBedrooms = 1
        case "2+":
            selectedBedrooms = 2
        case "3+":
            selectedBedrooms = 3
        case "4+":
            selectedBedrooms = 4
        default:
            selectedBedrooms = 0
        }
        filterListings()
    }

    func setBathroomFilter(_ filter: String) {
        switch filter {
        case "Any":
            selectedBathrooms = 0
        case "1+":
            selectedBathrooms = 1
        case "2+":
            selectedBathrooms = 2
        case "3+":
            selectedBathrooms = 3
        default:
            selectedBathrooms = 0
        }
        filterListings()
    }

    func resetFilters() {
        activeLenses.removeAll()
        priceRange = 0 ... 10_000_000
        selectedBedrooms = 0
        selectedBathrooms = 0
        filterListings()
    }

    // MARK: - Additional Actions

    func shareProperty(_ entry: ShortlistEntry) {
        // TODO: Implement property sharing functionality
        // This could use UIActivityViewController or similar
        print("Sharing property: \(entry.listing.address)")
    }

    // Sample data for development
    let sampleListings: [Listing] = []

    // Accessibility support
    var availableListings: [Listing] {
        return sampleListings // In real app, this would be filtered visible listings
    }

    var availableNeighborhoods: [String] {
        return Array(Set(sampleListings.map { $0.neighborhood })).sorted()
    }

    func startTrail() {
        // TODO: Implement trail/tour functionality
        // This could navigate to a tour planning view
        print("Starting trail with \(shortlist.count) properties")

        // Analytics tracking
        trackEvent("trail_started", parameters: [
            "property_count": shortlist.count,
            "neighborhoods": Array(Set(shortlist.map { $0.listing.neighborhood }))
        ])
    }

    // MARK: - Analytics

    private let sessionId = UUID().uuidString
    private var analyticsEvents: [AnalyticsEvent] = []

    // Progression Events
    var currentProgressionEvent: ProgressionEvent?
    private var eventQueue: [ProgressionEvent] = []

    private func trackEvent(_ eventName: String, parameters: [String: Any] = [:]) {
        var eventParameters = parameters
        eventParameters["timestamp"] = Date().timeIntervalSince1970
        eventParameters["session_id"] = sessionId
        eventParameters["user_progress_level"] = progressState.totalSaves

        // TODO: Send to analytics service
        print("📊 Analytics Event: \(eventName)")
        print("   Parameters: \(eventParameters)")

        // Store locally for debugging
        analyticsEvents.append(AnalyticsEvent(
            name: eventName,
            parameters: eventParameters,
            timestamp: Date()
        ))
    }

    func trackLensInteraction(at location: CGPoint, zoomLevel: Double) {
        trackEvent("lens_interaction", parameters: [
            "location_x": location.x,
            "location_y": location.y,
            "zoom_level": zoomLevel,
            "lens_size": lensSize.rawValue
        ])
    }

    // MARK: - Progression Events

    private func setupProgressionEventListener() {
        // Listen for progression events from ProgressState
        // In a real implementation, this would use NotificationCenter or Combine
        // For now, we'll manually trigger events
    }

    private func checkForProgressionEvents() {
        // Check for milestone achievements
        let saveCount = progressState.totalSaves

        // First save milestone
        if saveCount == 1 {
            showProgressionEvent(.trailStarted)
        }
        // Multiple saves milestone
        else if saveCount == 5 {
            if let milestone = Milestone.allMilestones.first(where: { $0.name == "First Steps" }) {
                showProgressionEvent(.milestoneReached(milestone))
            }
        } else if saveCount == 25 {
            if let milestone = Milestone.allMilestones.first(where: { $0.name == "Getting Serious" }) {
                showProgressionEvent(.milestoneReached(milestone))
            }
        }

        // Neighborhood exploration
        let uniqueNeighborhoods = Set(shortlist.map { $0.listing.neighborhood })
        if uniqueNeighborhoods.count >= 3 {
            let neighborhoodName = uniqueNeighborhoods.first ?? "Unknown"
            showProgressionEvent(.neighborhoodUnlocked(neighborhoodName))
        }
    }

    func showProgressionEvent(_ event: ProgressionEvent) {
        if currentProgressionEvent == nil {
            currentProgressionEvent = event
        } else {
            eventQueue.append(event)
        }
    }

    func dismissProgressionEvent() {
        currentProgressionEvent = nil

        // Show next event in queue if any
        if !eventQueue.isEmpty {
            let nextEvent = eventQueue.removeFirst()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.currentProgressionEvent = nextEvent
            }
        }
    }
}
