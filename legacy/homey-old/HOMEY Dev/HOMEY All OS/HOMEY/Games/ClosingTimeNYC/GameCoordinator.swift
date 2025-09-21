import Combine
import Foundation
import SpriteKit
import SwiftUI

enum GameEventKind: String, CaseIterable, Codable, Equatable {
    case negotiation
    case showing
    case appraisal
    case boardInterview
    case closing
}

protocol GameEventBridge: AnyObject {
    func present(event: GameEventKind)
}

@MainActor
final class GameCoordinator: ObservableObject, GameEventBridge {
    @Published var score: Int = 0
    @Published var timeLeft: Int = 60
    @Published var tipText: String? = "Buyer has a small dog — avoid no-pet co-ops."
    @Published var showEventCard = false
    @Published var nextEvent: GameEventKind = .negotiation

    private var countdownTimer: AnyCancellable?
    weak var scene: GameScene?

    func attach(scene: GameScene) { self.scene = scene }

    func start() {
        score = 0
        timeLeft = 60
        showEventCard = false
        tipText = "Buyer has a small dog — avoid no-pet co-ops."
        nextEvent = .negotiation
        startCountdown()
        present(event: nextEvent)
    }

    func stop() {
        countdownTimer?.cancel()
        countdownTimer = nil
    }

    func present(event _: GameEventKind) {
        withAnimation(.spring) { showEventCard = true }
        scene?.run(SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false))
    }

    func advanceToNextEvent() {
        guard let idx = GameEventKind.allCases.firstIndex(of: nextEvent) else {
            nextEvent = .negotiation
            return
        }
        let nextIdx = GameEventKind.allCases.index(after: idx)
        nextEvent = (nextIdx < GameEventKind.allCases.endIndex)
            ? GameEventKind.allCases[nextIdx]
            : .negotiation
        present(event: nextEvent)
    }

    private func startCountdown() {
        countdownTimer?.cancel()
        countdownTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.timeLeft > 0 { self.timeLeft -= 1 } else { self.stop() }
            }
    }
}
