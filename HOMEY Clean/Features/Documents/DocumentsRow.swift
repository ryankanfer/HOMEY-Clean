import Foundation

public struct DocumentsRow: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var title: String
    public var content: String?
    public var ownerId: UUID?
    public var createdAt: Date
    public var updatedAt: Date?

    public init(
        id: UUID,
        title: String,
        content: String? = nil,
        ownerId: UUID? = nil,
        createdAt: Date,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.ownerId = ownerId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension DocumentsRow {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case ownerId = "owner_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public extension JSONDecoder {
    static func documentsDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

public extension JSONEncoder {
    static func documentsEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}
