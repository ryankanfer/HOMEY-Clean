//
//  IntroductionService.swift
//  HOMEY Clean
//
//  Created by Drew's Directory
//

import Foundation
import Combine
import AVFoundation

@MainActor
class IntroductionService: ObservableObject {
    @Published var introductionRequests: [String: IntroductionStatus] = [:]
    @Published var notifications: [IntroductionNotification] = []
    @Published var hasNewNotifications: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var pollingTimer: Timer?
    private var audioPlayer: AVAudioPlayer?
    
    // Singleton instance
    static let shared = IntroductionService()
    
    private init() {
        setupAudioPlayer()
        startPolling()
    }
    
    deinit {
        stopPolling()
    }
    
    // MARK: - Audio Setup
    private func setupAudioPlayer() {
        guard let soundURL = Bundle.main.url(forResource: "soft_chime", withExtension: "wav") else {
            print("Could not find soft_chime.wav file")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error setting up audio player: \(error)")
        }
    }
    
    // MARK: - Introduction Request Management
    func requestIntroduction(for contactId: String) {
        // Update local state immediately
        introductionRequests[contactId] = .requested
        
        // Simulate API call
        Task {
            do {
                try await submitIntroductionRequest(contactId: contactId)
                print("Introduction request submitted for contact: \(contactId)")
            } catch {
                // Revert on error
                introductionRequests[contactId] = .none
                print("Failed to submit introduction request: \(error)")
            }
        }
    }
    
    func getIntroductionStatus(for contactId: String) -> IntroductionStatus {
        return introductionRequests[contactId] ?? .none
    }
    
    // MARK: - Real-time Updates
    private func startPolling() {
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.pollForUpdates()
            }
        }
    }
    
    nonisolated private func stopPolling() {
        Task { @MainActor in
            pollingTimer?.invalidate()
            pollingTimer = nil
        }
    }
    
    private func pollForUpdates() async {
        do {
            let updates = try await fetchIntroductionUpdates()
            processUpdates(updates)
        } catch {
            print("Error polling for updates: \(error)")
        }
    }
    
    private func processUpdates(_ updates: [IntroductionUpdate]) {
        for update in updates {
            let previousStatus = introductionRequests[update.contactId]
            introductionRequests[update.contactId] = update.status
            
            // Check if this is a status change that warrants a notification
            if let previous = previousStatus, previous != update.status {
                handleStatusChange(
                    contactId: update.contactId,
                    from: previous,
                    to: update.status,
                    contactName: update.contactName
                )
            }
        }
    }
    
    private func handleStatusChange(
        contactId: String,
        from previousStatus: IntroductionStatus,
        to newStatus: IntroductionStatus,
        contactName: String
    ) {
        let notification = IntroductionNotification(
            id: UUID().uuidString,
            contactId: contactId,
            contactName: contactName,
            message: generateNotificationMessage(for: newStatus, contactName: contactName),
            status: newStatus,
            timestamp: Date(),
            isRead: false
        )
        
        notifications.insert(notification, at: 0)
        hasNewNotifications = true
        
        // Play notification sound
        playNotificationSound()
        
        // Auto-remove notification after 10 seconds if not read
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if let index = self.notifications.firstIndex(where: { $0.id == notification.id }),
               !self.notifications[index].isRead {
                self.notifications.remove(at: index)
            }
        }
    }
    
    private func generateNotificationMessage(for status: IntroductionStatus, contactName: String) -> String {
        switch status {
        case .none:
            return ""
        case .requested:
            return "Introduction request sent to \(contactName)"
        case .pending:
            return "Introduction with \(contactName) is being arranged"
        case .accepted:
            return "Introduction with \(contactName) has been accepted! You can now connect."
        case .declined:
            return "Introduction request with \(contactName) was declined."
        }
    }
    
    private func playNotificationSound() {
        audioPlayer?.play()
    }
    
    // MARK: - Notification Management
    func markNotificationAsRead(_ notificationId: String) {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true
        }
        
        // Update hasNewNotifications flag
        hasNewNotifications = notifications.contains { !$0.isRead }
    }
    
    func clearAllNotifications() {
        notifications.removeAll()
        hasNewNotifications = false
    }
    
    func getUnreadNotificationCount() -> Int {
        return notifications.filter { !$0.isRead }.count
    }
    
    // MARK: - API Simulation
    private func submitIntroductionRequest(contactId: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Simulate random success/failure
        if Bool.random() {
            // Success - status will be updated via polling
        } else {
            throw IntroductionError.requestFailed
        }
    }
    
    private func fetchIntroductionUpdates() async throws -> [IntroductionUpdate] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Simulate some random updates
        var updates: [IntroductionUpdate] = []
        
        for (contactId, currentStatus) in introductionRequests {
            // Simulate status progression
            let shouldUpdate = Bool.random() && Double.random(in: 0...1) < 0.1 // 10% chance
            
            if shouldUpdate {
                let newStatus: IntroductionStatus
                switch currentStatus {
                case .none:
                    continue
                case .requested:
                    newStatus = .pending
                case .pending:
                    newStatus = .accepted
                case .accepted:
                    continue
                case .declined:
                    continue
                }
                
                updates.append(IntroductionUpdate(
                    contactId: contactId,
                    contactName: "Contact \(contactId.prefix(8))", // Simplified for demo
                    status: newStatus
                ))
            }
        }
        
        return updates
    }
}

// MARK: - Supporting Models
struct IntroductionUpdate {
    let contactId: String
    let contactName: String
    let status: IntroductionStatus
}

struct IntroductionNotification: Identifiable {
    let id: String
    let contactId: String
    let contactName: String
    let message: String
    let status: IntroductionStatus
    let timestamp: Date
    var isRead: Bool
}

enum IntroductionError: Error, LocalizedError {
    case requestFailed
    case networkError
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .requestFailed:
            return "Failed to submit introduction request"
        case .networkError:
            return "Network connection error"
        case .unauthorized:
            return "You are not authorized to make this request"
        }
    }
}

// MARK: - WebSocket Implementation (Future Enhancement)
/*
// This would be implemented for real-time WebSocket connections
class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlSession = URLSession.shared
    
    func connect() {
        guard let url = URL(string: "wss://api.homey.com/introductions") else { return }
        
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                self?.receiveMessage() // Continue listening
            case .failure(let error):
                print("WebSocket error: \(error)")
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            // Parse and handle introduction updates
            break
        case .data(let data):
            // Handle binary data if needed
            break
        @unknown default:
            break
        }
    }
}
*/