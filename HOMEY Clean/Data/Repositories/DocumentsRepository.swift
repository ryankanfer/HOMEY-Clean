// Data/Repositories/DocumentsRepository.swift
import Foundation
import Supabase

struct DocumentsRepository {
    let client: SupabaseClient

    func upload(data: Data, filename: String, mime: String = "application/pdf") async throws {
        let uid = try await client.auth.session.user.id.uuidString
        let fileId = UUID().uuidString
        let path = "documents/\(uid)/\(fileId).pdf"

        try await client.storage.from("documents").upload(
            path: path,
            file: data,
            fileOptions: .init(contentType: mime, upsert: false)
        )

        try await client.database.from("documents").insert([
            "user_id": uid,
            "name": filename,
            "mime": mime,
            "size": data.count,
            "storage_path": path
        ]).execute()
    }

    func listMine() async throws -> [[String: Any]] {
        let uid = try await client.auth.session.user.id.uuidString
        return try await client.database
            .from("documents")
            .select()
            .eq("user_id", value: uid)
            .order("created_at", ascending: false)
            .execute()
    }

    func signedURL(for storagePath: String, expires seconds: Int = 60) async throws -> URL {
        try await client.storage.from("documents").createSignedURL(path: storagePath, expiresIn: seconds)
    }
}