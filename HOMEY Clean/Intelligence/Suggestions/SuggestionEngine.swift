import Foundation
import SwiftUI

public final class SuggestionEngine {
    public static let shared = SuggestionEngine()
    private let freq = SuggestionFrequencyController()

    private init() {}

    public func suggestions(for page: AppPage?) async -> [Suggestion] {
        // Respect privacy controls up front
        let privacy = await GovernanceCenter.shared.privacy
        if !privacy.personalizedSuggestionsEnabled {
            return []
        }

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


        // Search → Docs: suggest pre-approval docs and board package templates
        if let lastSearch = state.lastSearch,
           userContext.journeyStage == .exploring || userContext.journeyStage == .researching {
            if freq.allow(page: .documents, type: .missingDocument) {
                pool.append(
                    Suggestion(
                        type: .missingDocument,
                        title: SuggestionCopy.recommendedForYou("Get your pre-approval docs ready"),
                        subtitle: "Bank statements, pay stubs and last year's tax return",
                        actionText: "Open Documents",
                        icon: "doc.badge.gearshape",
                        page: .documents,
                        priority: .high,
                        metadata: ["source": "search_to_docs", "at": "\(lastSearch.timestamp)"]
                    )
                )
            }
            if freq.allow(page: .documents, type: .missingDocument) {
                pool.append(
                    Suggestion(
                        type: .missingDocument,
                        title: SuggestionCopy.basedOnYourActivity("Start your board package"),
                        subtitle: "Use a template to collect what co-ops often ask for",
                        actionText: "Start Template",
                        icon: "doc.append",
                        page: .documents,
                        priority: .medium,
                        metadata: ["docType": DocumentType.boardForm.rawValue]
                    )
                )
            }
        }

        // Saves → Insights: personalize market cards based on recent saves
        let recentSaves = history.filter { $0.type == .propertySaved }
        if !recentSaves.isEmpty && freq.allow(page: .insights, type: .marketTrend) {
            let areaCount = max(1, userContext.preferences.neighborhoods.count)
            pool.append(
                Suggestion(
                    type: .marketTrend,
                    title: SuggestionCopy.recommendedForYou("Market trends for your saved areas"),
                    subtitle: "Personalized for \(areaCount) area\(areaCount == 1 ? "" : "s") you follow",
                    actionText: "View Insights",
                    icon: "chart.line.uptrend.xyaxis",
                    page: .insights,
                    priority: .medium,
                    metadata: ["source": "saves_to_insights", "savedCount": "\(recentSaves.count)"]
                )
            )
        }

        // Stage → Directory: filter to relevant pros
        switch userContext.journeyStage {
        case .exploring, .researching:
            if freq.allow(page: .directory, type: .directoryContact) {
                pool.append(
                    Suggestion(
                        type: .directoryContact,
                        title: SuggestionCopy.recommendedForYou("Talk to a lender"),
                        subtitle: "Get pre-approved to focus your search",
                        actionText: "Find Lender",
                        icon: "creditcard.fill",
                        page: .directory,
                        priority: .high,
                        metadata: ["role": "lender"]
                    )
                )
            }
        case .viewing, .negotiating:
            if freq.allow(page: .directory, type: .directoryContact) {
                pool.append(
                    Suggestion(
                        type: .directoryContact,
                        title: SuggestionCopy.basedOnYourActivity("Book an inspector"),
                        subtitle: "Line up inspection so you’re ready to move fast",
                        actionText: "Find Inspector",
                        icon: "magnifyingglass.circle.fill",
                        page: .directory,
                        priority: .high,
                        metadata: ["role": "inspector"]
                    )
                )
            }
        case .closing:
            if freq.allow(page: .directory, type: .directoryContact) {
                pool.append(
                    Suggestion(
                        type: .directoryContact,
                        title: SuggestionCopy.basedOnYourActivity("Talk to a closing attorney"),
                        subtitle: "Keep your closing on track",
                        actionText: "Find Attorney",
                        icon: "person.2.fill",
                        page: .directory,
                        priority: .urgent,
                        metadata: ["role": "attorney"]
                    )
                )
            }
        case .settled:
            break
        }

        // Views → Vision: floorplan extraction or staging presets
        let recentViews = history.filter { $0.type == .propertyViewed }
        if recentViews.count >= 3, freq.allow(page: .vision, type: .visionSuggestion) {
            pool.append(
                Suggestion(
                    type: .visionSuggestion,
                    title: SuggestionCopy.basedOnYourActivity("Extract a floorplan"),
                    subtitle: "Turn photos into a quick layout for your top pick",
                    actionText: "Open Vision",
                    icon: "square.grid.3x3.fill",
                    page: .vision,
                    priority: .medium,
                    metadata: ["feature": "floorplanExtraction"]
                )
            )
        } else if recentViews.count >= 1, freq.allow(page: .vision, type: .visionSuggestion) {
            pool.append(
                Suggestion(
                    type: .visionSuggestion,
                    title: SuggestionCopy.recommendedForYou("Try staging presets"),
                    subtitle: "Preview furniture and styles in a viewed home",
                    actionText: "Open Vision",
                    icon: "sofa.fill",
                    page: .vision,
                    priority: .low,
                    metadata: ["feature": "stagingPresets"]
                )
            )
        }

        // Uploads → Team/Directory: suggest relevant pro based on uploaded doc
        if let firstDoc = state.recentlyUploadedDocs.first, freq.allow(page: .directory, type: .directoryContact) {
            var role = "advisor"
            var title = "Connect with an advisor"
            var icon = "person.crop.circle.badge.questionmark"
            switch firstDoc {
            case .taxReturn, .w2Form:
                role = "accountant"; title = "Talk to an accountant"; icon = "tray.full.fill"
            case .bankStatement, .payStub, .creditReport:
                role = "lender"; title = "Share with a lender"; icon = "creditcard.fill"
            case .employmentLetter:
                role = "lender"; title = "Use your employment letter"; icon = "doc.text.fill"
            case .driversLicense, .passport, .id:
                role = "attorney"; title = "Verify ID with your attorney"; icon = "checkmark.seal.fill"
            default:
                role = "advisor"
            }
            pool.append(
                Suggestion(
                    type: .directoryContact,
                    title: SuggestionCopy.basedOnYourActivity(title),
                    subtitle: "We’ll filter the directory to the right pros",
                    actionText: "Open Directory",
                    icon: icon,
                    page: .directory,
                    priority: .medium,
                    metadata: ["docType": firstDoc.rawValue, "role": role]
                )
            )
        }

        // Existing doc reminder (keep)
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

        // Existing stage-based items (kept)
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
        let prelim = Array(filtered.prefix(maxCount))

        // APPLY Governance caps/snoozes last
        let governed = await GovernanceCenter.shared.filter(suggestions: prelim, for: page)

        // Track impressions
        for s in governed {
            Task { await MetricsTracker.shared.trackSuggestionImpression(s) }
        }

        for s in governed { freq.markShown(page: s.page, type: s.type) }
        return governed
    }
}