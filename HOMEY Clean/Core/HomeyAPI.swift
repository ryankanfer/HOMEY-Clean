import Foundation

public enum UserType: String, Codable, Sendable {
    case admin, agent, client
}

public struct ReferralSignupRequest: Codable, Sendable {
    public let email: String
    public let password: String
    public let full_name: String
    public let referral_code: String
}

public struct ReferralSignupResponse: Codable, Sendable {
    public let message: String
    public let user_id: String
}

public struct AdminUserCreationRequest: Codable, Sendable {
    public let email: String
    public let password: String
    public let token: String
    public let referral_code: String
}

public struct AdminUserCreationResponse: Codable, Sendable {
    public let message: String
    public let user_id: String
}

public struct AdminVerificationRequest: Codable, Sendable {
    public let email: String
}

public struct AdminVerificationResponse: Codable, Sendable {
    public let isAdmin: Bool
}

public struct AskCharlieRequest: Codable, Sendable {
    public let prompt: String
    public let userId: String
    public let conversationHistory: [String]?
    public let userProfile: [String: String]?
    public init(prompt: String, userId: String,
                conversationHistory: [String]? = nil,
                userProfile: [String: String]? = nil) {
        self.prompt = prompt
        self.userId = userId
        self.conversationHistory = conversationHistory
        self.userProfile = userProfile
    }
}

public struct AskCharlieResponse: Codable, Sendable {
    public let message: String
    public let emotion: String
    public let contextTags: [String]
}

public struct DocumentClassificationRequest: Codable, Sendable {
    public let fileName: String
    public let userId: String
}

public struct DocumentClassificationResponse: Codable, Sendable {
    public let category: String
    public let confidence: Double
    public let suggestions: [String]
}

public enum APIError: Error, LocalizedError {
    case authMissing
    case decoding
    case server(String)
    case transport(underlying: Error)

    public var errorDescription: String? {
        switch self {
        case .authMissing: return "Authentication required."
        case .decoding: return "Failed to decode server response."
        case .server(let m): return m
        case .transport(let e): return e.localizedDescription
        }
    }
}

public protocol HomeyAPI: AnyObject {
    func referralSignup(_ body: ReferralSignupRequest) async throws -> ReferralSignupResponse
    func createAdminUser(_ body: AdminUserCreationRequest) async throws -> AdminUserCreationResponse
    func verifyAdmin(_ body: AdminVerificationRequest, jwt: String) async throws -> AdminVerificationResponse
    func askCharlie(_ body: AskCharlieRequest, jwt: String) async throws -> AskCharlieResponse
    func classifyDocument(_ body: DocumentClassificationRequest, jwt: String) async throws -> DocumentClassificationResponse
}