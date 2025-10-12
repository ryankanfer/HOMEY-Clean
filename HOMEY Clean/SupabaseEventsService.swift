//
//  SupabaseEventsService.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/18/25.
//

// SupabaseEventsService.swift
import Foundation

protocol EventsServiceType { func fetchRecent(userJWT: String) async throws -> [JourneyEvent] }

final class SupabaseEventsService: EventsServiceType {
    private let base = URL(string:
        "https://mzqswvyfnblghgvcgxpw.supabase.co//rest/v1/journey_events" +
            "?select=id,kind,created_at,note&order=created_at.desc&limit=50"
    )!
    
    init() {}

    func fetchRecent(userJWT: String) async throws -> [JourneyEvent] {
        var req = URLRequest(url: base)
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        req.addValue("Bearer \(userJWT)", forHTTPHeaderField: "Authorization") // RLS
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, 200 ..< 300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([JourneyEvent].self, from: data)
    }
}
