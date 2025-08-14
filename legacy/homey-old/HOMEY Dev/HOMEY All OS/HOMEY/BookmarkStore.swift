/* BookmarkStore actor */
import Foundation

public struct BookmarkPayload: Codable {
    public let createdAt: String?
    public let source: String?
    public let url: String?
    public let text: String?
    public let imageURL: String?
}

public actor BookmarkStore {
    public static let shared = BookmarkStore()
    public func loadAll() -> [BookmarkPayload] { [] }
}
