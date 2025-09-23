import Foundation

public struct SuggestionConfig {
    public var perPageCooldown: TimeInterval = 60 * 10
    public var globalCooldown: TimeInterval = 60 * 2
    public var doNotDisturbWindows: [(startHour: Int, endHour: Int)] = [(22, 7)] // 10pm-7am
    public var maxPerPageByEngagement: (low: Int, medium: Int, high: Int) = (1, 2, 3)
    public var perTypeCooldowns: [SuggestionType: TimeInterval] = [
        .nextAction: 60 * 5,
        .missingDocument: 60 * 30,
        .directoryContact: 60 * 20,
        .insight: 60 * 10,
        .marketTrend: 60 * 20,
        .visionSuggestion: 60 * 15
    ]

    public init() { }
}

public enum EngagementLevel {
    case low, medium, high
}

public final class SuggestionFrequencyController {
    private let storageKey = "suggestion.rate.limit.v1"
    private var lastShown: [String: Date] = [:] // keyed by page/type
    private let config: SuggestionConfig

    public init(config: SuggestionConfig = SuggestionConfig()) {
        self.config = config
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([String: Date].self, from: data) {
            lastShown = decoded
        }
    }

    public func engagementLevel(from events: [InteractionEvent]) -> EngagementLevel {
        let now = Date()
        let recent = events.filter { now.timeIntervalSince($0.occurredAt) < 3600 } // 1h
        if recent.count >= 12 { return .high }
        if recent.count >= 4 { return .medium }
        return .low
    }

    public func allow(page: AppPage?, type: SuggestionType) -> Bool {
        if isDND() { return false }
        let now = Date()
        if let last = lastShown["global"], now.timeIntervalSince(last) < config.globalCooldown { return false }
        let pageKey = page?.rawValue ?? "global"
        let key = "\(pageKey)#\(type.rawValue)"
        if let last = lastShown[key], now.timeIntervalSince(last) < config.perPageCooldown { return false }
        let typeKey = "type#\(type.rawValue)"
        if let last = lastShown[typeKey],
           let minGap = config.perTypeCooldowns[type],
           now.timeIntervalSince(last) < minGap { return false }
        return true
    }

    public func markShown(page: AppPage?, type: SuggestionType) {
        let now = Date()
        lastShown["global"] = now
        let pageKey = page?.rawValue ?? "global"
        let key = "\(pageKey)#\(type.rawValue)"
        lastShown[key] = now
        let typeKey = "type#\(type.rawValue)"
        lastShown[typeKey] = now
        persist()
    }

    public func maxForPage(level: EngagementLevel) -> Int {
        switch level {
        case .low: return config.maxPerPageByEngagement.low
        case .medium: return config.maxPerPageByEngagement.medium
        case .high: return config.maxPerPageByEngagement.high
        }
    }

    private func isDND() -> Bool {
        let cal = Calendar.current
        let hour = cal.component(.hour, from: Date())
        for win in config.doNotDisturbWindows {
            if win.startHour < win.endHour {
                if hour >= win.startHour && hour < win.endHour { return true }
            } else {
                if hour >= win.startHour || hour < win.endHour { return true }
            }
        }
        return false
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(lastShown) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}