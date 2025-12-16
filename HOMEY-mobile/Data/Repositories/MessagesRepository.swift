//
//  MessagesRepository.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 1/25/25.
//

import Foundation
import Supabase

// MARK: - Message Models
struct MessageRecord: Codable, Identifiable {
    let id: UUID
    let conversationId: UUID
    let senderId: UUID
    let recipientId: UUID
    let content: String
    let messageType: String
    let attachments: [MessageAttachment]?
    let readAt: Date?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case recipientId = "recipient_id"
        case content
        case messageType = "message_type"
        case attachments
        case readAt = "read_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct MessageAttachment: Codable {
    let url: String
    let type: String
    let name: String
    let size: Int?
}

struct ConversationRecord: Codable, Identifiable {
    let id: UUID
    let participants: [UUID]
    let lastMessageId: UUID?
    let lastMessageAt: Date?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case participants
        case lastMessageId = "last_message_id"
        case lastMessageAt = "last_message_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct SendMessageRequest: Codable {
    let conversationId: UUID
    let recipientId: UUID
    let content: String
    let messageType: String
    let attachments: [MessageAttachment]?
    
    enum CodingKeys: String, CodingKey {
        case conversationId = "conversation_id"
        case recipientId = "recipient_id"
        case content
        case messageType = "message_type"
        case attachments
    }
}

// MARK: - Messages Repository
class MessagesRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    @MainActor
    convenience init() {
        self.init(client: AppSessionManager.shared.supabaseClient)
    }

    // MARK: - Conversation Management
    
    func fetchConversations() async throws -> [ConversationRecord] {
        let user = try await client.auth.user()
        
        let response: PostgrestResponse<[ConversationRecord]> = try await client
            .from("conversations")
            .select("*")
            .contains("participants", value: [user.id])
            .order("last_message_at", ascending: false)
            .execute()
        
        return response.value
    }
    
    func fetchConversation(id: UUID) async throws -> ConversationRecord {
        let response: PostgrestResponse<ConversationRecord> = try await client
            .from("conversations")
            .select("*")
            .eq("id", value: id)
            .single()
            .execute()
        
        return response.value
    }
    
    func createConversation(with participantId: UUID) async throws -> ConversationRecord {
        let user = try await client.auth.user()
        
        struct CreateConversationRequest: Codable {
            let id: UUID
            let participants: [UUID]
        }
        
        let request = CreateConversationRequest(
            id: UUID(),
            participants: [user.id, participantId]
        )
        
        let response: PostgrestResponse<ConversationRecord> = try await client
            .from("conversations")
            .insert(request)
            .select("*")
            .single()
            .execute()
        
        return response.value
    }
    
    func findOrCreateConversation(with participantId: UUID) async throws -> ConversationRecord {
        let user = try await client.auth.user()
        
        // Try to find existing conversation
        let existingResponse: PostgrestResponse<[ConversationRecord]> = try await client
            .from("conversations")
            .select("*")
            .contains("participants", value: [user.id, participantId])
            .execute()
        
        if let existing = existingResponse.value.first {
            return existing
        } else {
            return try await createConversation(with: participantId)
        }
    }
    
    // MARK: - Message Management
    
    func fetchMessages(for conversationId: UUID, limit: Int = 50, offset: Int = 0) async throws -> [MessageRecord] {
        let response: PostgrestResponse<[MessageRecord]> = try await client
            .from("messages")
            .select("*")
            .eq("conversation_id", value: conversationId)
            .order("created_at", ascending: false)
            .limit(limit)
            .range(from: offset, to: offset + limit - 1)
            .execute()
        
        return response.value.reversed() // Return in chronological order
    }
    
    func sendMessage(_ request: SendMessageRequest) async throws -> MessageRecord {
        let user = try await client.auth.user()
        
        struct CreateMessageRequest: Codable {
            let id: UUID
            let conversationId: UUID
            let senderId: UUID
            let recipientId: UUID
            let content: String
            let messageType: String
            let attachments: [MessageAttachment]?
            
            enum CodingKeys: String, CodingKey {
                case id
                case conversationId = "conversation_id"
                case senderId = "sender_id"
                case recipientId = "recipient_id"
                case content
                case messageType = "message_type"
                case attachments
            }
        }
        
        let messageRequest = CreateMessageRequest(
            id: UUID(),
            conversationId: request.conversationId,
            senderId: user.id,
            recipientId: request.recipientId,
            content: request.content,
            messageType: request.messageType,
            attachments: request.attachments
        )
        
        let response: PostgrestResponse<MessageRecord> = try await client
            .from("messages")
            .insert(messageRequest)
            .select("*")
            .single()
            .execute()
        
        // Update conversation's last message
        try await updateConversationLastMessage(
            conversationId: request.conversationId,
            messageId: response.value.id
        )

        Task.detached {
            await InteractionLogger.shared.log(
                InteractionEvent(
                    type: .messageSent,
                    page: .homey,
                    userId: await InteractionLogger.shared.currentUserId(),
                    sessionId: InteractionLogger.shared.makeSessionId(),
                    metadata: ["conversation_id": .init(request.conversationId.uuidString)]
                )
            )
        }
        
        return response.value
    }
    
    func markMessageAsRead(messageId: UUID) async throws {
        try await client
            .from("messages")
            .update(["read_at": Date()])
            .eq("id", value: messageId)
            .execute()
    }
    
    func markConversationAsRead(conversationId: UUID) async throws {
        let user = try await client.auth.user()
        
        try await client
            .from("messages")
            .update(["read_at": Date()])
            .eq("conversation_id", value: conversationId)
            .eq("recipient_id", value: user.id)
            .is("read_at", value: nil)
            .execute()
    }
    
    func deleteMessage(messageId: UUID) async throws {
        try await client
            .from("messages")
            .delete()
            .eq("id", value: messageId)
            .execute()
    }
    
    // MARK: - Unread Messages
    
    func fetchUnreadCount() async throws -> Int {
        let user = try await client.auth.user()
        
        let response: PostgrestResponse<[MessageRecord]> = try await client
            .from("messages")
            .select("id")
            .eq("recipient_id", value: user.id)
            .is("read_at", value: nil)
            .execute()
        
        return response.value.count
    }
    
    func fetchUnreadMessages() async throws -> [MessageRecord] {
        let user = try await client.auth.user()
        
        let response: PostgrestResponse<[MessageRecord]> = try await client
            .from("messages")
            .select("*")
            .eq("recipient_id", value: user.id)
            .is("read_at", value: nil)
            .order("created_at", ascending: false)
            .execute()
        
        return response.value
    }
    
    // MARK: - Private Helpers
    
    private func updateConversationLastMessage(conversationId: UUID, messageId: UUID) async throws {
        struct UpdateLastMessage: Codable {
            let lastMessageId: UUID
            let lastMessageAt: Date
            
            enum CodingKeys: String, CodingKey {
                case lastMessageId = "last_message_id"
                case lastMessageAt = "last_message_at"
            }
        }
        
        let update = UpdateLastMessage(
            lastMessageId: messageId,
            lastMessageAt: Date()
        )
        
        try await client
            .from("conversations")
            .update(update)
            .eq("id", value: conversationId)
            .execute()
    }
}