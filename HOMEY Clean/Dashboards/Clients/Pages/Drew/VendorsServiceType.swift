//
//  VendorsServiceType.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/18/25.
//

// VendorsService.swift
import Foundation

protocol VendorsServiceType { func fetch(userJWT: String) async throws -> [Vendor] }

final class VendorsService: VendorsServiceType {
    private let base =
        URL(
            string: "https://fafbjfajmmsjftiivhil.supabase.co/rest/v1/vendors?select=name,category,blurb,contact,website"
        )!
    private let anon: String
    init(anonKey: String) { anon = anonKey }
    func fetch(userJWT: String) async throws -> [Vendor] {
        var req = URLRequest(url: base)
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        req.addValue(anon, forHTTPHeaderField: "apikey")
        req.addValue("Bearer \(userJWT)", forHTTPHeaderField: "Authorization")
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse,
              200 ..< 300 ~= http.statusCode else { throw URLError(.badServerResponse) }
        struct Row: Decodable { let name, category, blurb: String; let contact: String?; let website: String? }
        let rows = try JSONDecoder().decode([Row].self, from: data)
        return rows.map { Vendor(
            name: $0.name,
            category: $0.category,
            blurb: $0.blurb,
            contact: $0.contact,
            website: $0.website
        ) }
    }
}
