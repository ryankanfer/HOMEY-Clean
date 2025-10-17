import Foundation

struct PropertyListingCard: Identifiable {
    let id = UUID()
    let title: String
    let price: String
    let match: String
    let icon: String
}