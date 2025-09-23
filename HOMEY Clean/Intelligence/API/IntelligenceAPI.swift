import Foundation
import SwiftUI

public struct IntelligenceContextResponse: Codable {
    public let userContext: UserContext
    public let state: CrossScreenState
    public let snapshotAt: Date
}

public struct SuggestionsResponse: Codable {
    public let page: AppPage?
    public let suggestions: [Suggestion]
    public let generatedAt: Date
}

public struct PersonalizationResponse: Codable {
    public let journeyStage: JourneyStage
    public let pagePriorities: [AppPage: Double]
    public let inferredBehaviors: [BehaviorTag]
    public let updatedAt: Date
}

public actor IntelligenceAPI {
    public static let shared = IntelligenceAPI()

    // GET /intelligence/context
    public func context() async -> IntelligenceContextResponse {
        let (uc, st) = await MainActor.run {
            (CrossScreenContext.shared.userContext, CrossScreenContext.shared.state)
        }
        return IntelligenceContextResponse(userContext: uc, state: st, snapshotAt: .now)
    }

    // GET /intelligence/suggestions?page=
    public func suggestions(for page: AppPage?) async -> SuggestionsResponse {
        let items = await SuggestionEngine.shared.suggestions(for: page)
        return SuggestionsResponse(page: page, suggestions: items, generatedAt: .now)
    }

    // POST /intelligence/update
    public func update(with interactions: [InteractionEvent]) async {
        for ev in interactions {
            await InteractionLogger.shared.log(ev)
        }
    }

    // POST /intelligence/personalize
    public func personalize() async -> PersonalizationResponse {
        let output = await IntelligenceHub.shared.compute()
        let uc = await MainActor.run { CrossScreenContext.shared.userContext }
        return PersonalizationResponse(
            journeyStage: uc.journeyStage,
            pagePriorities: output.pagePriorities,
            inferredBehaviors: Array(uc.inferredBehaviors),
            updatedAt: .now
        )
    }
}