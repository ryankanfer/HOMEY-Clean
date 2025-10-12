//
//  NudgeService.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/18/25.
//

// NudgeService.swift
import Foundation

struct NudgeResult: Decodable { let ok: Bool }

enum NudgeError: LocalizedError {
    case badURL, notAuthed, http(Int), decode
    var errorDescription: String? {
        switch self {
        case .badURL: return "Bad URL"
        case .notAuthed: return "Missing auth"
        case let .http(c): return "HTTP \(c)"
        case .decode: return "Decode error"
        }
    }
}

final class NudgeService {
    private let base: URL
    
    init(projectURL: String) throws {
        guard let url = URL(string: "\(projectURL)/functions/v1/charlie_act") else { throw NudgeError.badURL }
        base = url
    }

    func nudge(clientId: String, userJWT: String) async throws {
        var req = URLRequest(url: base)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue("Bearer \(userJWT)", forHTTPHeaderField: "Authorization")
        req.httpBody = try JSONSerialization.data(withJSONObject: [
            "action": "nudge_client",
            "payload": ["client_id": clientId]
        ])

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw NudgeError.http(-1) }
        guard (200 ..< 300).contains(http.statusCode) else { throw NudgeError.http(http.statusCode) }
        guard let res = try? JSONDecoder().decode(NudgeResult.self, from: data), res.ok else {
            throw NudgeError.decode
        }
    }
}
