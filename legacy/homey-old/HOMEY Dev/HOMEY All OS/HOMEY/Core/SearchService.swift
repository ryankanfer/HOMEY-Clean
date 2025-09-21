//
//  SearchService.swift
//  HOMIE
//
//  Created by Ryan Kanfer on 8/9/25.
//

import Foundation
import Supabase

@MainActor
final class SearchService {
    private let client: SupabaseClient
    init(client: SupabaseClient) { self.client = client }

    /// Table-only search to avoid RPC/Sendable headaches for now.
    func searchListings(
        query _: String,
        taste _: String, // kept for future ranking
        page: Int,
        pageSize: Int
    ) async throws -> [HomeyListing] {
        let offset = page * pageSize

        var builder = await client.database
            .from("listings")
            .select()
            .order("created_at", ascending: false)
            .range(from: offset, to: offset + pageSize - 1)

        // If your SDK exposes `.ilike`, enable this:
        // if !q.isEmpty { builder = builder.ilike("search_text", "%\(q)%") }

        let resp = try await builder.execute()

        if let data = resp.data as? Data {
            return try JSONDecoder().decode([HomeyListing].self, from: data)
        } else {
            let data = try JSONSerialization.data(withJSONObject: resp.data, options: [])
            return try JSONDecoder().decode([HomeyListing].self, from: data)
        }
    }
}
