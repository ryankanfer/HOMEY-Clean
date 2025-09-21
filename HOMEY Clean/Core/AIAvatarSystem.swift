//
//  AIAvatarSystem.swift
//  HOMEY Clean
//
//  AI Avatar System inspired by Emergent.sh methodology
//  Created by Trae AI on 1/27/25.
//

import Foundation
import SwiftUI

// MARK: - AI Avatar Model
struct AIAvatar: Identifiable, Codable {
    let id: String
    let name: String
    let role: String
    let description: String
    let personality: [String]
    let expertise: [String]
    let accentColor: Color
    
    var isActive: Bool = true
    var conversationHistory: [AIConversationMessage] = []
    
    // Regular initializer
    init(id: String, name: String, role: String, description: String, personality: [String], expertise: [String], accentColor: Color) {
        self.id = id
        self.name = name
        self.role = role
        self.description = description
        self.personality = personality
        self.expertise = expertise
        self.accentColor = accentColor
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, role, description, personality, expertise
        case isActive, conversationHistory, accentColorName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        role = try container.decode(String.self, forKey: .role)
        description = try container.decode(String.self, forKey: .description)
        personality = try container.decode([String].self, forKey: .personality)
         expertise = try container.decode([String].self, forKey: .expertise)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        conversationHistory = try container.decode([AIConversationMessage].self, forKey: .conversationHistory)
        
        let colorName = try container.decode(String.self, forKey: .accentColorName)
        switch colorName {
        case "pink": accentColor = Color.pink
        case "blue": accentColor = Color.blue
        case "green": accentColor = Color.green
        case "purple": accentColor = Color.purple
        case "orange": accentColor = Color.orange
        case "red": accentColor = Color.red
        case "yellow": accentColor = Color.yellow
        default: accentColor = Color.blue
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(role, forKey: .role)
        try container.encode(description, forKey: .description)
        try container.encode(personality, forKey: .personality)
         try container.encode(expertise, forKey: .expertise)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(conversationHistory, forKey: .conversationHistory)
        
        // Convert Color to string for encoding
        let colorName: String
        switch accentColor {
        case Color.pink: colorName = "pink"
        case Color.blue: colorName = "blue"
        case Color.green: colorName = "green"
        case Color.purple: colorName = "purple"
        case Color.orange: colorName = "orange"
        case Color.red: colorName = "red"
        case Color.yellow: colorName = "yellow"
        default: colorName = "blue"
        }
        try container.encode(colorName, forKey: .accentColorName)
    }
}

// MARK: - AI Personality
struct AIPersonality: Codable {
    let tone: String // "friendly", "professional", "creative", "analytical"
    let communicationStyle: String // "conversational", "direct", "detailed", "concise"
    let expertise: [String]
    let traits: [String]
}

// MARK: - AI Capabilities
enum AICapability: String, Codable, CaseIterable {
    case conversation = "conversation"
    case recommendations = "recommendations"
    case dataAnalysis = "data_analysis"
    case taskManagement = "task_management"
    case documentProcessing = "document_processing"
    case marketInsights = "market_insights"
    case scheduling = "scheduling"
    case vendorConnections = "vendor_connections"
    case designSuggestions = "design_suggestions"
    
    var displayName: String {
        switch self {
        case .conversation: return "AI Conversations"
        case .recommendations: return "Smart Recommendations"
        case .dataAnalysis: return "Data Analysis"
        case .taskManagement: return "Task Management"
        case .documentProcessing: return "Document Processing"
        case .marketInsights: return "Market Insights"
        case .scheduling: return "Smart Scheduling"
        case .vendorConnections: return "Vendor Network"
        case .designSuggestions: return "Design Suggestions"
        }
    }
}

// MARK: - AI Conversation Message Model
struct AIConversationMessage: Identifiable, Codable {
    let id: UUID
    let text: String
    let isFromUser: Bool
    let timestamp: Date
    let avatarId: String
    let messageType: MessageType
    let metadata: [String: String]?
    
    enum MessageType: String, Codable {
        case text = "text"
        case recommendation = "recommendation"
        case insight = "insight"
        case action = "action"
        case system = "system"
    }
    
    init(text: String, isFromUser: Bool, avatarId: String, messageType: MessageType = .text, metadata: [String: String]? = nil) {
        self.id = UUID()
        self.text = text
        self.isFromUser = isFromUser
        self.timestamp = Date()
        self.avatarId = avatarId
        self.messageType = messageType
        self.metadata = metadata
    }
}

// MARK: - AI Avatar Manager
@MainActor
class AIAvatarManager: ObservableObject {
    @Published var avatars: [AIAvatar] = []
    @Published var activeAvatar: AIAvatar?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
        setupDefaultAvatars()
    }
    
    // MARK: - Setup Default Avatars (Inspired by Emergent.sh)
    private func setupDefaultAvatars() {
        avatars = [
            // Charlie - Journey Guide (like Emergent's Charlie)
            AIAvatar(
                id: "charlie",
                name: "Charlie",
                role: "Journey Guide",
                description: "Your AI concierge for personalized cleaning guidance",
                personality: ["helpful", "encouraging", "knowledgeable"],
                expertise: ["cleaning guidance", "personalization", "user onboarding"],
                accentColor: .blue
            ),
            
            // Scout - Smart Discovery (like Emergent's Scout)
            AIAvatar(
                id: "scout",
                name: "Scout",
                role: "Smart Discovery",
                description: "Intelligent cleaning task discovery and optimization",
                personality: ["thorough", "systematic", "insightful"],
                expertise: ["task optimization", "efficiency analysis", "smart scheduling"],
                accentColor: .green
            ),
            
            // Isla - Insights & Analytics (like Emergent's Isla)
            AIAvatar(
                id: "isla",
                name: "Isla",
                role: "Insights & Analytics",
                description: "Deep cleaning analytics and performance insights",
                personality: ["precise", "analytical", "insightful"],
                expertise: ["data visualization", "performance metrics", "trend analysis"],
                accentColor: .purple
            ),
            
            // Viza - Visual & Design (like Emergent's Viza)
            AIAvatar(
                id: "viza",
                name: "Viza",
                role: "Visual & Design",
                description: "Aesthetic guidance and visual organization",
                personality: ["creative", "inspiring", "detail-oriented"],
                expertise: ["interior design", "organization", "aesthetics"],
                accentColor: Color.pink
            ),
            
            // Drew - Directory & Connections
            AIAvatar(
                id: "drew",
                name: "Drew",
                role: "Directory & Connections",
                description: "Professional network and service connections",
                personality: ["social", "connected", "resourceful"],
                expertise: ["networking", "professional services", "vendor connections"],
                accentColor: .orange
            ),
            
            // Paige - Paperwork & Documentation
            AIAvatar(
                id: "paige",
                name: "Paige",
                role: "Paperwork & Documentation",
                description: "Document management and paperwork organization",
                personality: ["organized", "meticulous", "efficient"],
                expertise: ["document processing", "paperwork management", "organization systems"],
                accentColor: .yellow
            )
        ]
        
        // Set Charlie as default active avatar
        activeAvatar = avatars.first { $0.id == "charlie" }
    }
    
    // MARK: - Avatar Management
    func selectAvatar(_ avatar: AIAvatar) {
        activeAvatar = avatar
    }
    
    func getAvatar(by id: String) -> AIAvatar? {
        return avatars.first { $0.id == id }
    }
    
    // MARK: - Conversation Management
    func sendMessage(_ text: String, to avatarId: String) async throws -> AIConversationMessage {
        guard let avatarIndex = avatars.firstIndex(where: { $0.id == avatarId }) else {
            throw AIAvatarError.avatarNotFound
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // Add user message to conversation history
        let userMessage = AIConversationMessage(text: text, isFromUser: true, avatarId: avatarId, messageType: .text)
        avatars[avatarIndex].conversationHistory.append(userMessage)
        
        // Generate AI response using the avatar's system prompt and personality
        let aiResponse = try await generateAIResponse(for: avatars[avatarIndex], userMessage: text)
        
        // Add AI response to conversation history
        avatars[avatarIndex].conversationHistory.append(aiResponse)
        
        return aiResponse
    }
    
    private func generateAIResponse(for avatar: AIAvatar, userMessage: String) async throws -> AIConversationMessage {
        // This would integrate with OpenAI API similar to Emergent's approach
        // For now, return a mock response
        let mockResponse = "Hi! I'm \(avatar.name), your \(avatar.role). \(avatar.description) How can I help you today?"
        
        return AIConversationMessage(
            text: mockResponse,
            isFromUser: false,
            avatarId: avatar.id,
            messageType: .text
        )
    }
}

// MARK: - Errors
enum AIAvatarError: LocalizedError {
    case avatarNotFound
    case apiError(String)
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .avatarNotFound:
            return "Avatar not found"
        case .apiError(let message):
            return "API Error: \(message)"
        case .networkError:
            return "Network connection error"
        }
    }
}

// MARK: - Color Extensions
extension Color {
    static let avatarBlue = Color(red: 0.2, green: 0.6, blue: 1.0)
    static let avatarGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let avatarPurple = Color(red: 0.6, green: 0.2, blue: 0.8)
    static let avatarPink = Color(red: 1.0, green: 0.4, blue: 0.6)
    static let avatarOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let avatarYellow = Color(red: 1.0, green: 0.8, blue: 0.2)
}