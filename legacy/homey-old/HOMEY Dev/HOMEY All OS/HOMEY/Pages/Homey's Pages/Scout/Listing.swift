
import Foundation

public struct Listing: Identifiable, Hashable, Codable {
    public var id: UUID
    public var title: String
    public var subtitle: String
    public var price: Int

    public var address: String?
    public var neighborhood: String?
    public var beds: Int?
    public var baths: Double?
    public var imageURL: URL?
    public var createdAt: Date?

    // Additional properties for management
    public var agent: String?
    public var status: String?
    public var listingType: String?

    public init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        price: Int,
        address: String? = nil,
        neighborhood: String? = nil,
        beds: Int? = nil,
        baths: Double? = nil,
        imageURL: URL? = nil,
        createdAt: Date? = nil,
        agent: String? = nil,
        status: String? = nil,
        listingType: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.price = price
        self.address = address
        self.neighborhood = neighborhood
        self.beds = beds
        self.baths = baths
        self.imageURL = imageURL
        self.createdAt = createdAt
        self.agent = agent
        self.status = status
        self.listingType = listingType
    }

    public var priceFormatted: String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.maximumFractionDigits = 0
        return fmt.string(from: NSNumber(value: price)) ?? "$\(price)"
    }
}
