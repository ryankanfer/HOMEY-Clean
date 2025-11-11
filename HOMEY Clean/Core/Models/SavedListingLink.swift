import Foundation

// Represents a URL saved from StreetEasy via the Share Extension.
// Minimal data required to render in the Saved Homes section and deep link back.
public struct SavedListingLink: Identifiable, Codable, Hashable {
    public let id: UUID
    public let userId: UUID
    public let url: URL
    public let title: String?
    public let createdAt: Date

    public init(id: UUID, userId: UUID, url: URL, title: String?, createdAt: Date) {
        self.id = id
        self.userId = userId
        self.url = url
        self.title = title
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case url
        case title
        case createdAt = "created_at"
    }
}