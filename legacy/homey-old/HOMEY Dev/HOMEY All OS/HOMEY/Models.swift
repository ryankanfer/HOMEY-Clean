import Foundation

// This model is used to decode the result when checking for an Agent's referral code.
struct AgentCodeCheck: Codable, Sendable {
    let name: String
}

// This model is used for checking general invitation codes like "HOMEY123".
// Note: This assumes your 'invitations' table has 'code' and 'inviter_name' columns.
struct InvitationCodeCheck: Codable, Sendable {
    let code: String
    let assigned_to: String?
    let type: String
    let active: Bool
    let inviter_id: UUID?
    let inviter_name: String?
}

// This model represents the data for creating a new user in your 'profiles' table.
struct ProfileData: Codable, Sendable {
    let user_id: String
    let display_name: String
    let user_type: String
    let code: String
    let invited_by: String?
    init(
        user_id: String,
        display_name: String,
        user_type: String,
        code: String,
        invited_by: String?
    ) {
        self.user_id = user_id
        self.display_name = display_name
        self.user_type = user_type
        self.code = code
        self.invited_by = invited_by
    }
}

struct AgentInsert: Codable, Sendable {
    let user_id: String
    let full_name: String
    let email: String
    let code: String
    let user_type: String
    let journey_stage: String
}

struct ClientInsert: Codable, Sendable {
    let user_id: String
    let full_name: String
    let email: String
    let code: String
    let user_type: String
    let journey_stage: String
}
