import Foundation
import Supabase

@MainActor
public final class SupabaseFunctionsService: HomeyAPI {
    private let client: SupabaseClient
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()

    public init(client: SupabaseClient) {
        self.client = client
    }

    // MARK: - HomeyAPI

    public func referralSignup(_ body: ReferralSignupRequest) async throws -> ReferralSignupResponse {
        try await invokeFunction("referral-signup", body: body)
    }

    public func createAdminUser(_ body: AdminUserCreationRequest) async throws -> AdminUserCreationResponse {
        // Token goes in headers only; body is scrubbed
        let headers = ["X-Admin-Token": body.token]
        let payload = AdminUserCreationRequest(
            email: body.email,
            password: body.password,
            token: "",                    // don't echo token back in body
            referral_code: body.referral_code
        )
        return try await invokeFunction("create-admin-user", body: payload, headers: headers)
    }

    public func verifyAdmin(_ body: AdminVerificationRequest, jwt: String) async throws -> AdminVerificationResponse {
        try await invokeFunction("rapid-responder", body: body, headers: ["Authorization": "Bearer \(jwt)"])
    }

    public func askCharlie(_ body: AskCharlieRequest, jwt: String) async throws -> AskCharlieResponse {
        try await invokeFunction("ask-charlie", body: body, headers: ["Authorization": "Bearer \(jwt)"])
    }

    public func classifyDocument(_ body: DocumentClassificationRequest, jwt: String) async throws -> DocumentClassificationResponse {
        try await invokeFunction("classify-document", body: body, headers: ["Authorization": "Bearer \(jwt)"])
    }

    // MARK: - Helper

    /// Unified invoker for supabase-swift 2.5.x.
    /// Uses the generic invoke overload to decode directly into the expected response type.
    private func invokeFunction<TReq: Encodable, TRes: Decodable>(
        _ name: String,
        body: TReq,
        headers: [String: String] = [:]
    ) async throws -> TRes {
        do {
            let options = FunctionInvokeOptions(headers: headers, body: body)
            let response: TRes = try await client.functions.invoke(name, options: options, decoder: jsonDecoder)
            return response
        } catch let api as APIError {
            throw api
        } catch {
            throw APIError.transport(underlying: error)
        }
    }
}