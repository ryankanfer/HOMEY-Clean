import Foundation

public final class MockAnalytics: Analytics {
    public private(set) var recorded: [AnalyticsEvent] = []
    private let lock = NSLock()

    public init() {}

    public func track(_ event: AnalyticsEvent) {
        lock.lock()
        recorded.append(event)
        lock.unlock()
    }

    public func reset() {
        lock.lock()
        recorded.removeAll()
        lock.unlock()
    }
}