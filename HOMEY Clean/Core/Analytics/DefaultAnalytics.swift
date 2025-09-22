import Foundation
import os

public final class DefaultAnalytics: Analytics {
    public static let shared = DefaultAnalytics()
    private let logger: Logger

    public init(subsystem: String = Bundle.main.bundleIdentifier ?? "HOMEY.Clean", category: String = "analytics") {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    public func track(_ event: AnalyticsEvent) {
        let name = event.name
        let params = event.parameters
        let json = DefaultAnalytics.jsonString(params)
        logger.info("event=\(name, privacy: .public) params=\(json, privacy: .public)")
    }

    private static func jsonString(_ dict: [String: String]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
              let str = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return str
    }
}