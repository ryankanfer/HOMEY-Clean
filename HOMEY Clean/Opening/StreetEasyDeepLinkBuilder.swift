import SwiftUI
import Foundation
#if os(iOS)
import UIKit
#endif

enum StreetEasyDeepLinkBuilder {
    private static let webBase = "https://streeteasy.com"

    static func searchURL(from filters: LocalSearchFilters, query: String?) -> URL? {
        var components = URLComponents(string: "\(webBase)/search")
        var qParts: [String] = []

        if let n = filters.neighborhood?.trimmingCharacters(in: .whitespacesAndNewlines), !n.isEmpty {
            qParts.append(n)
        }
        if let beds = filters.minBeds, beds > 0 {
            qParts.append("\(beds)+ bed")
        }
        if let baths = filters.minBaths, baths > 0 {
            qParts.append("\(baths)+ bath")
        }
        if let lo = filters.minPrice, let hi = filters.maxPrice, lo > 0, hi > 0, hi >= lo {
            qParts.append("$\(lo)-$\(hi)")
        } else if let lo = filters.minPrice {
            qParts.append("min $\(lo)")
        } else if let hi = filters.maxPrice {
            qParts.append("max $\(hi)")
        }

        // Market type hint (rent/buy). If nil, we rely on free-text AI inference.
        if let isRent = filters.isRent {
            qParts.append(isRent ? "rent" : "sale")
        }

        // Amenities tokens to bias StreetEasy search
        if !filters.amenities.isEmpty {
            for a in filters.amenities { qParts.append(a.lowercased()) }
        }

        let freeText = (query ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !freeText.isEmpty {
            qParts.append(freeText)
        }

        guard !qParts.isEmpty else { return nil }

        let searchString = qParts.joined(separator: " ")
        components?.queryItems = [URLQueryItem(name: "query", value: searchString)]
        return components?.url
    }

    static func listingURL(for listing: Listing) -> URL? {
        let address = listing.address.trimmingCharacters(in: .whitespacesAndNewlines)
        let hood = listing.neighborhood.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !address.isEmpty else { return nil }

        var components = URLComponents(string: "\(webBase)/search")
        let q = hood.isEmpty ? address : "\(address) \(hood)"
        components?.queryItems = [URLQueryItem(name: "query", value: q)]
        return components?.url
    }

    static func open(url: URL) {
        #if os(iOS)
        // Ensure we’re on the main thread and verify scheme support before opening
        DispatchQueue.main.async {
            let app = UIApplication.shared
            if app.canOpenURL(url) {
                app.open(url, options: [:], completionHandler: nil)
            } else {
                // No-op if URL cannot be opened; consider surfacing a user-facing error if needed
            }
        }
        #else
        NSWorkspace.shared.open(url)
        #endif
    }
}