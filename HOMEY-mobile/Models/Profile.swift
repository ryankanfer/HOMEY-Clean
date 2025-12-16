import Foundation

struct Profile: Identifiable, Decodable {
    let id: UUID
    let email: String?
    let full_name: String?
    let role: String?
}