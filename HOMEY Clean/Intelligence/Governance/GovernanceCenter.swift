import Foundation

public struct PrivacyControls: Codable {
    public var trackingEnabled: Bool
    public var personalizedSuggestionsEnabled: Bool

    public init(trackingEnabled: Bool = true, personalizedSuggestionsEnabled: Bool = true) {
        self.trackingEnabled = trackingEnabled
        self.personalizedSuggestionsEnabled = personalizedSuggestionsEnabled
    }
}

public actor GovernanceCenter {
    public static let shared = GovernanceCenter()

    private struct Snapshot: Codable {
        var privacy: PrivacyControls
        var perSurfaceCaps: [String: Int]
        var snoozedTypesUntil: [String: Date]
        var snoozedAllUntil: [String: Date]
    }

    private let storageKey = "governance.center.v1"

    public private(set) var privacy = PrivacyControls()
    private var caps: [String: Int] = [:]
    private var snoozedTypesUntil: [String: Date] = [:]
    private var snoozedAllUntil: [String: Date] = [:]

    private init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let snap = try? JSONDecoder().decode(Snapshot.self, from: data) {
            self.privacy = snap.privacy
            self.caps = snap.perSurfaceCaps
            self.snoozedTypesUntil = snap.snoozedTypesUntil
            self.snoozedAllUntil = snap.snoozedAllUntil
        } else {
            // defaults
            caps["homey"] = 3
            caps["discover"] = 3
            caps["insights"] = 3
            caps["directory"] = 2
            caps["vision"] = 2
            caps["documents"] = 3
        }
    }

    private func persist() {
        let snap = Snapshot(
            privacy: privacy,
            perSurfaceCaps: caps,
            snoozedTypesUntil: snoozedTypesUntil,
            snoozedAllUntil: snoozedAllUntil
        )
        if let data = try? JSONEncoder().encode(snap) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    // Privacy
    public func setPrivacy(_ p: PrivacyControls) {
        privacy = p
        persist()
    }

    // Caps
    public func setCap(for page: AppPage, count: Int) {
        caps[page.rawValue] = count
        persist()
    }

    public func cap(for page: AppPage?) -> Int {
        let key = (page?.rawValue ?? "homey")
        return caps[key] ?? 3
    }

    // Snooze
    public func snooze(type: SuggestionType, for duration: TimeInterval) {
        snoozedTypesUntil[type.rawValue] = Date().addingTimeInterval(duration)
        persist()
    }

    public func snoozeAll(on page: AppPage, for duration: TimeInterval) {
        snoozedAllUntil[page.rawValue] = Date().addingTimeInterval(duration)
        persist()
    }

    public func clearSnoozes() {
        snoozedTypesUntil.removeAll()
        snoozedAllUntil.removeAll()
        persist()
    }

    // Filtering
    public func filter(suggestions: [Suggestion], for page: AppPage?) -> [Suggestion] {
        if !privacy.personalizedSuggestionsEnabled { return [] }
        let now = Date()
        if let p = page, let until = snoozedAllUntil[p.rawValue], until > now {
            return []
        }
        let filtered = suggestions.filter { s in
            if let until = snoozedTypesUntil[s.type.rawValue], until > now { return false }
            return true
        }
        let cap = cap(for: page)
        return Array(filtered.prefix(cap))
    }
}