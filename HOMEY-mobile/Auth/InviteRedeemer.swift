import Foundation

enum InviteRedeemError: Error {
    case http(Int)
    case badResponse
}

enum InviteRedeemer {
    /// Call this from a place where you already have the user's access token.
    static func redeem(
        code: String,
        accessToken: String,
        projectRef: String
    ) async throws -> (ok: Bool, role: String?, already: Bool) {
        // Check if development bypass is enabled
        #if DEBUG
        if FeatureFlags.shared.devBypassReferralValidation {
            // In development mode, accept any non-empty referral code
            let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedCode.isEmpty {
                return (ok: true, role: "client", already: false)
            }
        }
        #endif
        let url = URL(string: "https://\(projectRef).functions.supabase.co/redeem_invite")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        req.httpBody = try JSONSerialization.data(withJSONObject: ["code": code], options: [])

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw InviteRedeemError.badResponse }
        guard 200 ..< 300 ~= http.statusCode else { throw InviteRedeemError.http(http.statusCode) }

        let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return (
            obj?["ok"] as? Bool ?? false,
            obj?["role"] as? String,
            obj?["already"] as? Bool ?? false
        )
    }
}
