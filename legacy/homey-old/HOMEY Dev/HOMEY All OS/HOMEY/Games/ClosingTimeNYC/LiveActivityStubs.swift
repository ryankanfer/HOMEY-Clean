
import Foundation
#if canImport(ActivityKit)
import ActivityKit

@available(iOS 16.1, *)
struct DealActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var timeRemaining: Int
        var district: String
    }
}
#endif
