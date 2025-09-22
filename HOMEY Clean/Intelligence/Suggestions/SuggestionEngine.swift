import Foundation
import SwiftUI

public final class SuggestionEngine {
    public static let shared = SuggestionEngine()
    private let freq = SuggestionFrequencyController()

    private init() {}

    public func suggestions(for page: AppPage?) async -> [Suggestion] {
        let output = await IntelligenceHub.shared.compute()
        let history = await InteractionLogger.shared.history(limit: 200)
        let level = freq.engagementLevel(from: history)

        let ctxSnapshot = await MainActor.run {
            (CrossScreenContext.shared.userContext, CrossScreenContext.shared.state)
        }
        let userContext = ctxSnapshot.0
        let state = ctxSnapshot.1

        var pool: [Suggestion] = []

        for item in output.nextActions {
            let s = Suggestion(
                type: .nextAction,
                title: SuggestionCopy.heresWhatsNext(item.title),
                subtitle: item.subtitle,
                actionText: item.actionText,
                icon: item.type.icon,
                page: page ?? .homey,
                priority: item.priority,
                metadata: item.metadata
            )
            pool.append(s)
        }

        if let docsFirst = state.recentlyUploadedDocs.first {
            pool.append(
                Suggestion(
                    type: .missingDocument,
                    title: SuggestionCopy.recommendedForYou("Verify your \(docsFirst.displayName)"),
                    subtitle: "Double-check that your upload is complete",
                    actionText: "Open Documents",
                    icon: "doc.text.fill",
                    page: .documents,
                    priority: .high,
                    metadata: ["docType": docsFirst.rawValue]
                )
            )
        }

        if userContext.journeyStage == .closing {
            pool.append(
                Suggestion(
                    type: .directoryContact,
                    title: SuggestionCopy.basedOnYourActivity("Talk to a closing attorney"),
                    subtitle: "Get support to keep your closing on track",
                    actionText: "Find Attorney",
                    icon: "person.2.fill",
                    page: .directory,
                    priority: .urgent
                )
            )
        }

        if userContext.journeyStage == .researching {
            pool.append(
                Suggestion(
                    type: .marketTrend,
                    title: SuggestionCopy.recommendedForYou("Local market update"),
                    subtitle: "See recent price trends for saved areas",
                    actionText: "View Insights",
                    icon: "chart.line.uptrend.xyaxis",
                    page: .insights,
                    priority: .medium
                )
            )
        }

        if userContext.journeyStage == .viewing {
            pool.append(
                Suggestion(
                    type: .visionSuggestion,
                    title: SuggestionCopy.basedOnYourActivity("Visualize a renovation"),
                    subtitle: "Preview changes in your top property",
                    actionText: "Open Vision",
                    icon: "sparkles",
                    page: .vision,
                    priority: .low
                )
            )
        }

        let filtered = pool
            .filter { freq.allow(page: $0.page, type: $0.type) }
            .sorted { lhs, rhs in
                if lhs.priority.sortOrder != rhs.priority.sortOrder {
                    return lhs.priority.sortOrder < rhs.priority.sortOrder
                }
                return lhs.createdAt > rhs.createdAt
            }

        let maxCount = freq.maxForPage(level: level)
        let result = Array(filtered.prefix(maxCount))
        for s in result { freq.markShown(page: s.page, type: s.type) }
        return result
    }
}