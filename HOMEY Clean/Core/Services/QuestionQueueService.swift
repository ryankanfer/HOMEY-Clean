import Foundation
import Supabase

// MARK: - Question Queue Service

class QuestionQueueService {
    static let shared = QuestionQueueService()
    
    private var supabase: SupabaseClient? {
        do {
            let authManager = try RealSupabaseAuthManager()
            return authManager.client
        } catch {
            print("Error initializing Supabase client: \(error)")
            return nil
        }
    }
    
    private let aiQuestionTriggerService = AIQuestionTriggerService.shared
    private let behavioralTrackingService = BehavioralTrackingService.shared
    
    private init() {}
    
    // MARK: - Question Queue Management
    
    func fetchQuestionQueue(for userId: UUID) async throws -> [QueuedAIQuestion] {
        guard let supabase = self.supabase else {
            throw QuestionQueueError.supabaseNotInitialized
        }
        
        let response: [QueuedAIQuestion] = try await supabase.database
            .from("ai_question_queue")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: true)
            .execute()
            .value
        
        return response
    }
    
    func addToQueue(_ questions: [AIQuestion], for userId: UUID) async throws {
        guard let supabase = self.supabase else {
            throw QuestionQueueError.supabaseNotInitialized
        }
        
        // Convert AIQuestion to QueuedAIQuestion
        let queuedQuestions = questions.map { question in
            QueuedAIQuestion(
                id: UUID(),
                userId: userId,
                questionId: question.id,
                avatar: question.avatar,
                category: question.category,
                questionText: question.questionText,
                options: question.options,
                priority: 1,
                status: .pending,
                createdAt: Date(),
                answeredAt: nil,
                triggeredBy: nil // This would be set by the trigger service
            )
        }
        
        try await supabase.database
            .from("ai_question_queue")
            .insert(queuedQuestions)
            .execute()
    }
    
    func removeFromQueue(_ questionIds: [UUID], for userId: UUID) async throws {
        guard let supabase = self.supabase else {
            throw QuestionQueueError.supabaseNotInitialized
        }
        
        try await supabase.database
            .from("ai_question_queue")
            .delete()
            .eq("user_id", value: userId)
            .in("id", values: questionIds.map { $0.uuidString })
            .execute()
    }
    
    func markQuestionAsAnswered(_ questionId: UUID, for userId: UUID) async throws {
        guard let supabase = self.supabase else {
            throw QuestionQueueError.supabaseNotInitialized
        }
        
        // Create a dictionary with consistent value types
        let updateData: [String: String] = [
            "status": QueuedAIQuestionStatus.answered.rawValue,
            "answered_at": ISO8601DateFormatter().string(from: Date())
        ]
        
        try await supabase.database
            .from("ai_question_queue")
            .update(updateData)
            .eq("id", value: questionId)
            .eq("user_id", value: userId)
            .execute()
    }
    
    func markQuestionAsSkipped(_ questionId: UUID, for userId: UUID) async throws {
        guard let supabase = self.supabase else {
            throw QuestionQueueError.supabaseNotInitialized
        }
        
        let updateData: [String: String] = [
            "status": QueuedAIQuestionStatus.skipped.rawValue
        ]
        
        try await supabase.database
            .from("ai_question_queue")
            .update(updateData)
            .eq("id", value: questionId)
            .eq("user_id", value: userId)
            .execute()
    }
    
    // MARK: - AI Question Generation and Queue Management
    
    func generateAndQueueAIQuestions(for userId: UUID) async {
        // This would be implemented when we have a proper AI question generation system
        print("Generating and queuing AI questions for user \(userId)")
    }
    
    // MARK: - Question Queue UI Integration
    
    func getTopQuestions(for userId: UUID, limit: Int = 5) async -> [QueuedAIQuestion] {
        do {
            let allQuestions = try await fetchQuestionQueue(for: userId)
            return Array(allQuestions.prefix(limit))
        } catch {
            print("Error fetching top questions: \(error)")
            return []
        }
    }
}

// MARK: - Queued AI Question Models

struct QueuedAIQuestion: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let questionId: String // Reference to the original AIQuestion ID
    let avatar: HomeyAvatar
    let category: TeachingSection
    let questionText: String
    let options: [String]
    let priority: Int
    let status: QueuedAIQuestionStatus
    let createdAt: Date
    let answeredAt: Date?
    let triggeredBy: String? // ID of the trigger that created this question
    
    enum CodingKeys: String, CodingKey {
        case id, userId = "user_id", questionId = "question_id", avatar, category, questionText = "question_text", options, priority, status, createdAt = "created_at", answeredAt = "answered_at", triggeredBy = "triggered_by"
    }
    
    init(id: UUID, userId: UUID, questionId: String, avatar: HomeyAvatar, category: TeachingSection, questionText: String, options: [String], priority: Int, status: QueuedAIQuestionStatus, createdAt: Date, answeredAt: Date? = nil, triggeredBy: String? = nil) {
        self.id = id
        self.userId = userId
        self.questionId = questionId
        self.avatar = avatar
        self.category = category
        self.questionText = questionText
        self.options = options
        self.priority = priority
        self.status = status
        self.createdAt = createdAt
        self.answeredAt = answeredAt
        self.triggeredBy = triggeredBy
    }
}

enum QueuedAIQuestionStatus: String, Codable {
    case pending = "pending"
    case answered = "answered"
    case skipped = "skipped"
}

// MARK: - Question Queue Error

enum QuestionQueueError: Error, LocalizedError {
    case supabaseNotInitialized
    case fetchFailed(Error)
    case updateFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .supabaseNotInitialized:
            return "Supabase client not initialized"
        case .fetchFailed(let error):
            return "Failed to fetch question queue: \(error.localizedDescription)"
        case .updateFailed(let error):
            return "Failed to update question queue: \(error.localizedDescription)"
        }
    }
}
