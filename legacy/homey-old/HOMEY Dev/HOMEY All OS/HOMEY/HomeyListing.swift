//
//  HomeyListing.swift
//  HOMIE
//
//  Created by Ryan Kanfer on 8/9/25.
//


import Foundation

public struct HomeyListing: Identifiable, Decodable, Hashable, Sendable {
    public let id: UUID
    public let address: String
    public let neighborhood: String?
    public let price: Int
    public let beds: Int?
    public let baths: Double?
    public let sqft: Int?
    public let photo_url: String?
}