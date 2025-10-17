import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp: Date
    var properties: [PropertyListingCard]? = nil
    var quickReplies: [String]? = nil
}