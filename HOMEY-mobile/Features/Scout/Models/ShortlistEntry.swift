import Foundation
import SwiftUI

// MARK: - Shortlist Entry Model

struct ShortlistEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let listing: Listing
    let savedDate: Date
    var order: Int
    let notes: String?
    let tags: [String]
    let isViewed: Bool
    let viewedDate: Date?
    let compareGroup: String? // For grouping in comparison view

    init(listing: Listing, order: Int = 0, notes: String? = nil, tags: [String] = []) {
        id = UUID()
        self.listing = listing
        savedDate = Date()
        self.order = order
        self.notes = notes
        self.tags = tags
        isViewed = false
        viewedDate = nil
        compareGroup = nil
    }

    // MARK: - Computed Properties

    var displayTitle: String {
        return listing.address
    }

    var displaySubtitle: String {
        return "\(listing.neighborhood) • \(listing.bedroomBathroomText)"
    }

    var displayPrice: String {
        return listing.displayPrice
    }

    var timeSinceSaved: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: savedDate, relativeTo: Date())
    }

    var hasNotes: Bool {
        return notes?.isEmpty == false
    }

    var hasTags: Bool {
        return !tags.isEmpty
    }
}

// MARK: - Shortlist Management

struct Shortlist: Codable {
    private(set) var entries: [ShortlistEntry]
    private(set) var lastUpdated: Date

    init() {
        entries = []
        lastUpdated = Date()
    }

    // MARK: - Computed Properties

    var count: Int {
        return entries.count
    }

    var isEmpty: Bool {
        return entries.isEmpty
    }

    var orderedEntries: [ShortlistEntry] {
        return entries.sorted { $0.order < $1.order }
    }

    var totalEstimatedValue: Int {
        return entries.reduce(0) { $0 + $1.listing.price }
    }

    var averagePrice: Int {
        guard !entries.isEmpty else { return 0 }
        return totalEstimatedValue / entries.count
    }

    var neighborhoods: Set<String> {
        return Set(entries.map { $0.listing.neighborhood })
    }

    // MARK: - Mutating Methods

    mutating func add(_ listing: Listing, notes: String? = nil, tags: [String] = []) {
        let newOrder = entries.map { $0.order }.max() ?? -1
        let entry = ShortlistEntry(listing: listing, order: newOrder + 1, notes: notes, tags: tags)
        entries.append(entry)
        lastUpdated = Date()
    }

    mutating func remove(_ entryId: UUID) {
        entries.removeAll { $0.id == entryId }
        reorderEntries()
        lastUpdated = Date()
    }

    mutating func remove(_ listing: Listing) {
        entries.removeAll { $0.listing.id == listing.id }
        reorderEntries()
        lastUpdated = Date()
    }

    mutating func reorder(from source: IndexSet, to destination: Int) {
        entries.move(fromOffsets: source, toOffset: destination)
        reorderEntries()
        lastUpdated = Date()
    }

    mutating func updateNotes(for entryId: UUID, notes: String?) {
        if let index = entries.firstIndex(where: { $0.id == entryId }) {
            var entry = entries[index]
            entry = ShortlistEntry(
                listing: entry.listing,
                order: entry.order,
                notes: notes,
                tags: entry.tags
            )
            entries[index] = entry
            lastUpdated = Date()
        }
    }

    mutating func addTag(to entryId: UUID, tag: String) {
        if let index = entries.firstIndex(where: { $0.id == entryId }) {
            var entry = entries[index]
            var newTags = entry.tags
            if !newTags.contains(tag) {
                newTags.append(tag)
                entry = ShortlistEntry(
                    listing: entry.listing,
                    order: entry.order,
                    notes: entry.notes,
                    tags: newTags
                )
                entries[index] = entry
                lastUpdated = Date()
            }
        }
    }

    mutating func removeTag(from entryId: UUID, tag: String) {
        if let index = entries.firstIndex(where: { $0.id == entryId }) {
            var entry = entries[index]
            var newTags = entry.tags
            newTags.removeAll { $0 == tag }
            entry = ShortlistEntry(
                listing: entry.listing,
                order: entry.order,
                notes: entry.notes,
                tags: newTags
            )
            entries[index] = entry
            lastUpdated = Date()
        }
    }

    mutating func markAsViewed(_ entryId: UUID) {
        if let index = entries.firstIndex(where: { $0.id == entryId }) {
            var entry = entries[index]
            if !entry.isViewed {
                // Create new entry with viewed status
                let newEntry = ShortlistEntry(
                    listing: entry.listing,
                    order: entry.order,
                    notes: entry.notes,
                    tags: entry.tags
                )
                entries[index] = newEntry
                lastUpdated = Date()
            }
        }
    }

    mutating func clear() {
        entries.removeAll()
        lastUpdated = Date()
    }

    // MARK: - Private Methods

    private mutating func reorderEntries() {
        for index in entries.indices {
            entries[index].order = index
        }
    }

    // MARK: - Query Methods

    func contains(_ listing: Listing) -> Bool {
        return entries.contains { $0.listing.id == listing.id }
    }

    func entry(for listing: Listing) -> ShortlistEntry? {
        return entries.first { $0.listing.id == listing.id }
    }

    func entriesWithTag(_ tag: String) -> [ShortlistEntry] {
        return entries.filter { $0.tags.contains(tag) }
    }

    func entriesInNeighborhood(_ neighborhood: String) -> [ShortlistEntry] {
        return entries.filter { $0.listing.neighborhood == neighborhood }
    }
}

// MARK: - Tour Route

struct TourRoute {
    let entries: [ShortlistEntry]
    let totalDistance: Double // in miles
    let estimatedDuration: TimeInterval // in seconds
    let optimizedOrder: [ShortlistEntry]
    let waypoints: [Coordinates]

    init(entries: [ShortlistEntry]) {
        self.entries = entries
        waypoints = entries.map { $0.listing.coordinates }

        // Simple distance calculation (in a real app, use MapKit routing)
        totalDistance = TourRoute.calculateTotalDistance(waypoints: waypoints)
        estimatedDuration = totalDistance * 300 // ~5 minutes per mile walking
        optimizedOrder = TourRoute.optimizeRoute(entries: entries)
    }

    var formattedDuration: String {
        let hours = Int(estimatedDuration) / 3600
        let minutes = (Int(estimatedDuration) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var formattedDistance: String {
        return String(format: "%.1f mi", totalDistance)
    }

    // MARK: - Private Methods

    private static func calculateTotalDistance(waypoints: [Coordinates]) -> Double {
        guard waypoints.count > 1 else { return 0 }

        var totalDistance: Double = 0
        for i in 0 ..< (waypoints.count - 1) {
            let from = waypoints[i]
            let to = waypoints[i + 1]
            totalDistance += haversineDistance(from: from, to: to)
        }
        return totalDistance
    }

    private static func haversineDistance(from: Coordinates, to: Coordinates) -> Double {
        let R = 3959.0 // Earth's radius in miles
        let dLat = (to.latitude - from.latitude) * .pi / 180
        let dLon = (to.longitude - from.longitude) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2) + cos(from.latitude * .pi / 180) * cos(to.latitude * .pi / 180) *
            sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c
    }

    private static func optimizeRoute(entries: [ShortlistEntry]) -> [ShortlistEntry] {
        // Simple nearest neighbor optimization
        // In a real app, use more sophisticated TSP algorithms
        guard entries.count > 2 else { return entries }

        var optimized: [ShortlistEntry] = []
        var remaining = entries

        // Start with first entry
        optimized.append(remaining.removeFirst())

        while !remaining.isEmpty {
            guard let current = optimized.last else { break }
            guard let nearest = remaining.min(by: { entry1, entry2 in
                let dist1 = haversineDistance(from: current.listing.coordinates, to: entry1.listing.coordinates)
                let dist2 = haversineDistance(from: current.listing.coordinates, to: entry2.listing.coordinates)
                return dist1 < dist2
            }) else { break }

            optimized.append(nearest)
            remaining.removeAll { $0.id == nearest.id }
        }

        return optimized
    }
}

// MARK: - Sample Data

extension ShortlistEntry {
    static let sampleEntries: [ShortlistEntry] = [
        ShortlistEntry(
            listing: Listing.sampleListings[0],
            order: 0,
            notes: "Great natural light, close to subway",
            tags: ["favorite", "urgent"]
        ),
        ShortlistEntry(
            listing: Listing.sampleListings[1],
            order: 1,
            notes: "Pet-friendly building",
            tags: ["pet-friendly"]
        )
    ]
}
