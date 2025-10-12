import Foundation
import SwiftUI

@MainActor
final class CommentsRepository: ObservableObject {
    static let shared = CommentsRepository()
    
    struct Comment: Identifiable, Hashable {
        let id: UUID
        let targetId: String // document or category id
        let author: String
        let text: String
        let date: Date
    }
    
    @Published private(set) var comments: [Comment] = []
    
    private init() {}
    
    func addComment(targetId: String, author: String, text: String) async {
        let comment = Comment(id: UUID(), targetId: targetId, author: author, text: text, date: Date())
        comments.append(comment)
    }
    
    func comments(for targetId: String) -> [Comment] {
        comments.filter { $0.targetId == targetId }.sorted { $0.date < $1.date }
    }
    
    func delete(_ id: UUID) async {
        comments.removeAll { $0.id == id }
    }
}
