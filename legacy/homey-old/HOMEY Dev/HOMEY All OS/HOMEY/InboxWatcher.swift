/* InboxWatcher polling notifications */
import Combine
import Foundation

public final class InboxWatcher {
    public static let newItemNotification = Notification.Name("HOMEYInboxNewItem")
    public init() {}
    public func start() { /* no-op for now */ }
    public func stop() { /* no-op */ }
}
