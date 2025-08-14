import Foundation
#if canImport(Supabase)
import Supabase
#endif

public struct ProfileInfo {
    public let role: String
    public let clientSegment: String? // "renter"|"buyer"|"seller"|"landlord" when role == "client"
}

public protocol ProfilesProviding {
    func fetchProfile(for userId: UUID) async throws -> ProfileInfo
}

/// Dev stub
public final class FakeProfilesService: ProfilesProviding {
    public init() {}
    public func fetchProfile(for userId: UUID) async throws -> ProfileInfo {
        ProfileInfo(role: "client", clientSegment: nil)
    }
}

/// Real Supabase-backed implementation
public final class RealSupabaseProfilesService: ProfilesProviding {
    #if canImport(Supabase)
    private let client: SupabaseClient
    public init(client: SupabaseClient) { self.client = client }
    #else
    public init() {}
    #endif

    public func fetchProfile(for userId: UUID) async throws -> ProfileInfo {
        #if canImport(Supabase)
        struct Row: Decodable { let role: String?; let client_segment: String? }
        let response: PostgrestResponse<Row> = try await client
            .from("profiles")
            .select("role, client_segment")
            .eq("id", value: userId)
            .single()
            .execute()

        let row = response.value

        let role = (row.role ?? "client").lowercased()
        let seg = row.client_segment?.lowercased()
        return ProfileInfo(role: role, clientSegment: seg)
        #else
        return ProfileInfo(role: "client", clientSegment: nil)
        #endif
    }
}
