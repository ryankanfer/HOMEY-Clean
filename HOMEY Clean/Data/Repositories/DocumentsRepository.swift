//
//  DocumentsRepository.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 9/16/25.
//

// Data/Repositories/DocumentsRepository.swift
import Foundation
import Supabase

struct DocumentRecord: Identifiable, Hashable, Codable, Sendable {
    let id: Int
    let user_id: String
    let name: String
    let mime: String
    let size: Int
    let storage_path: String
    let created_at: String
    let status: String?
    let doc_type: String?
    let extracted_payload: [String: DocumentsAnyCodable]?
    let agent_notes: String?

    var displayStatus: String {
        status ?? "uploaded"
    }
}

// Helper for encoding/decoding Any values in JSON
struct DocumentsAnyCodable: Codable, Hashable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let string = value as? String {
            try container.encode(string)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let bool = value as? Bool {
            try container.encode(bool)
        } else {
            try container.encodeNil()
        }
    }
    
    static func == (lhs: DocumentsAnyCodable, rhs: DocumentsAnyCodable) -> Bool {
        return String(describing: lhs.value) == String(describing: rhs.value)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: value))
    }
}

struct DocumentsRepository {
    let client: SupabaseClient

    func upload(data: Data, filename: String, mime: String = "application/pdf") async throws {
        let uid = try await client.auth.session.user.id.uuidString
        let fileId = UUID().uuidString
        let path = "documents/\(uid)/\(fileId).pdf"

        _ = try await client.storage.from("documents").upload(
            path,
            data: data,
            options: .init(contentType: mime, upsert: false)
        )

        struct InsertPayload: Encodable {
            let user_id: String
            let name: String
            let mime: String
            let size: Int
            let storage_path: String
        }

        _ = try await client.database.from("documents").insert(
            InsertPayload(
                user_id: uid,
                name: filename,
                mime: mime,
                size: data.count,
                storage_path: path
            )
        ).execute()

        Task.detached {
            await InteractionLogger.shared.captureDocUploadUnknown(name: filename, typeString: "Uploaded (\(mime))", page: .documents)
        }
    }
    
    // Enhanced upload method that returns document ID for AI processing
    func uploadDocument(data: Data, filename: String, mime: String = "application/pdf") async throws -> UUID {
        let uid = try await client.auth.session.user.id.uuidString
        let fileId = UUID().uuidString
        let path = "documents/\(uid)/\(fileId).pdf"

        _ = try await client.storage.from("documents").upload(
            path,
            data: data,
            options: .init(contentType: mime, upsert: false)
        )

        struct InsertPayload: Encodable {
            let user_id: String
            let name: String
            let mime: String
            let size: Int
            let storage_path: String
            let status: String
        }

        let response: PostgrestResponse<[DocumentRecord]> = try await client.database.from("documents").insert(
            InsertPayload(
                user_id: uid,
                name: filename,
                mime: mime,
                size: data.count,
                storage_path: path,
                status: "processing"
            )
        ).select().execute()
        
        guard let document = response.value.first else {
            throw NSError(domain: "DocumentsRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create document record"])
        }
        
        Task.detached {
            await InteractionLogger.shared.captureDocUploadUnknown(name: filename, typeString: "Processing (\(mime))", page: .documents)
        }
        
        // Convert integer ID to UUID - using a deterministic approach
        let idString = String(format: "%08d-0000-0000-0000-000000000000", document.id)
        return UUID(uuidString: idString) ?? UUID()
    }
    
    // Update document with AI results
    func updateDocumentAIResults(id: UUID, docType: DocumentType, extractedData: [String: Any]) async throws {
        struct UpdatePayload: Encodable {
            let doc_type: String
            let extracted_payload: [String: DocumentsAnyCodable]
            let status: String
        }
        
        let payload = UpdatePayload(
            doc_type: docType.rawValue,
            extracted_payload: extractedData.mapValues { DocumentsAnyCodable($0) },
            status: "pending"
        )
        
        _ = try await client.database.from("documents")
            .update(payload)
            .eq("id", value: id.uuidString)
            .execute()

        Task.detached {
            await InteractionLogger.shared.log(
                InteractionEvent(
                    type: .documentProcessed,
                    page: .documents,
                    userId: await InteractionLogger.shared.currentUserId(),
                    sessionId: InteractionLogger.shared.makeSessionId(),
                    metadata: ["id": .init(id.uuidString), "type": .init(docType.rawValue)]
                )
            )
        }
    }
    
    // Update document status (for agent use)
    func updateDocumentStatus(id: UUID, status: DocumentStatus, notes: String? = nil) async throws {
        struct UpdatePayload: Encodable {
            let status: String
            let agent_notes: String?
        }
        
        let payload = UpdatePayload(status: status.rawValue, agent_notes: notes)
        
        _ = try await client.database.from("documents")
            .update(payload)
            .eq("id", value: id.uuidString)
            .execute()

        Task.detached {
            await InteractionLogger.shared.log(
                InteractionEvent(
                    type: .documentStatusChanged,
                    page: .documents,
                    userId: await InteractionLogger.shared.currentUserId(),
                    sessionId: InteractionLogger.shared.makeSessionId(),
                    metadata: ["id": .init(id.uuidString), "status": .init(status.rawValue)]
                )
            )
        }
    }
    
    // Fetch documents with enhanced data
    func fetchDocuments() async throws -> [DocumentListItem] {
        let uid = try await client.auth.session.user.id.uuidString
        let response: PostgrestResponse<[DocumentRecord]> = try await client.database
            .from("documents")
            .select()
            .eq("user_id", value: uid)
            .order("created_at", ascending: false)
            .execute()

        return response.value.map { record in
            // Convert integer ID to UUID - using a deterministic approach
            let idString = String(format: "%08d-0000-0000-0000-000000000000", record.id)
            let documentId = UUID(uuidString: idString) ?? UUID()
            
            return DocumentListItem(
                id: documentId,
                name: record.name,
                displayStatus: record.displayStatus,
                extractedData: record.extracted_payload?.mapValues { $0.value },
                agentNotes: record.agent_notes,
                uploadedAt: ISO8601DateFormatter().date(from: record.created_at) ?? Date(),
                docType: record.doc_type.flatMap { DocumentType(rawValue: $0) },
                canDelete: true
            )
        }
    }
    
    // Delete document
    func deleteDocument(id: UUID) async throws {
        _ = try await client.database.from("documents")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()

        Task.detached {
            await InteractionLogger.shared.log(
                InteractionEvent(
                    type: .documentDeleted,
                    page: .documents,
                    userId: await InteractionLogger.shared.currentUserId(),
                    sessionId: InteractionLogger.shared.makeSessionId(),
                    metadata: ["id": .init(id.uuidString)]
                )
            )
        }
    }

    func listMine() async throws -> [DocumentRecord] {
        let uid = try await client.auth.session.user.id.uuidString
        let response: PostgrestResponse<[DocumentRecord]> = try await client.database
            .from("documents")
            .select()
            .eq("user_id", value: uid)
            .order("created_at", ascending: false)
            .execute()

        return response.value
    }

    func signedURL(for storagePath: String, expires seconds: Int = 60) async throws -> URL {
        try await client.storage.from("documents").createSignedURL(path: storagePath, expiresIn: seconds)
    }
}