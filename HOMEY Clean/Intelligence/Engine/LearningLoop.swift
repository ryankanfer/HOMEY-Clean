import Foundation

public actor LearningLoop {
    public static let shared = LearningLoop()

    private var lastStageUpdateAt: Date?
    private let minStageUpdateGap: TimeInterval = 60 * 30 // 30 min

    public func observe(_ event: InteractionEvent) async {
        // Avoid reacting to our own stage-change events to prevent loops
        if event.type == .journeyStageChanged { return }

        // Snapshot context
        let (context, state) = await MainActor.run {
            (CrossScreenContext.shared.userContext, CrossScreenContext.shared.state)
        }
        let recent = await InteractionLogger.shared.history(limit: 300, since: context.recentWindowStart)
        let inference = StageDetector.inferStage(recent: recent, context: context, state: state)

        // Rate-limit updates
        let now = Date()
        if let last = lastStageUpdateAt, now.timeIntervalSince(last) < minStageUpdateGap {
            await writeSummary(inference: inference, context: context, recent: recent)
            return
        }

        // Update stage if confidently different
        if inference.recommended != context.journeyStage, inference.confidence >= 0.75 {
            lastStageUpdateAt = now
            await MainActor.run {
                Task {
                    await AppSessionManager.shared.updateJourneyStage(inference.recommended)
                }
            }
        }

        await writeSummary(inference: inference, context: context, recent: recent)
    }

    private func writeSummary(inference: StageInference, context: UserContext, recent: [InteractionEvent]) async {
        guard let uid = await InteractionLogger.shared.currentUserId() else { return }

        // Compute counters for storage
        let now = Date()
        let last24h = recent.filter { now.timeIntervalSince($0.occurredAt) <= 24 * 3600 }
        let counters = RecommendationSummary.Counters(
            searches24: last24h.filter { $0.type == .searchPerformed }.count,
            views24: last24h.filter { $0.type == .propertyViewed }.count,
            saves24: last24h.filter { $0.type == .propertySaved }.count
        )

        let prefs = RecommendationSummary.PreferencesSnapshot(
            budgetMin: context.preferences.budgetMin,
            budgetMax: context.preferences.budgetMax,
            propertyTypes: context.preferences.propertyTypes,
            neighborhoods: context.preferences.neighborhoods,
            bedrooms: context.preferences.bedrooms,
            bathrooms: context.preferences.bathrooms
        )

        let summary = RecommendationSummary(
            userId: uid,
            currentStage: context.journeyStage,
            inferredStage: inference.recommended,
            confidence: inference.confidence,
            reasons: inference.reasons,
            preferences: prefs,
            counters: counters,
            updatedAt: .now
        )

        await RecommendationEngineWriter.shared.write(summary: summary)
    }
}