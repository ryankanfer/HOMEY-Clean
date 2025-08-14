/* InboxWatcher polling notifications */
import Foundation
import Combine

public final class InboxWatcher {
    public static let newItemNotification = Notification.Name("HOMEYInboxNewItem")
    public init() {}
    public func start() { /* no-op for now */ }
    public func stop() { /* no-op */ }
}
