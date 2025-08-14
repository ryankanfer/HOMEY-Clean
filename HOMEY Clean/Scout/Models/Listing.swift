//
//  Listing.swift
//  HOMEY Clean
//

import Foundation

enum ListingStatus: String, Codable, Sendable {
    case active
    case pending
    case rented
    case sold
}

enum ListingType: String, Codable, Sendable {
    case rental
    case sale
}

struct Listing: Identifiable, Codable, Sendable, Equatable {
    var id: UUID
    var address: String
    var price: Int?
    var agent: String?
    var status: ListingStatus
    var listingType: ListingType
    var createdAt: Date

    init(
        id: UUID = UUID(),
        address: String,
        price: Int? = nil,
        agent: String? = nil,
        status: ListingStatus = .active,
        listingType: ListingType = .rental,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.address = address
        self.price = price
        self.agent = agent
        self.status = status
        self.listingType = listingType
        self.createdAt = createdAt
    }
}
