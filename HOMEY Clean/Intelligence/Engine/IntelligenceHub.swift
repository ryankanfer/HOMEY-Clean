import Foundation
import SwiftUI

public struct IntelligenceOutput {
    public let nextActions: [NextUpContent]
    public let pagePriorities: [AppPage: Double] // 0...100
}

public actor IntelligenceHub {
    public static let shared = IntelligenceHub()

    public func compute() async -> IntelligenceOutput {
        let (userContext, state) = await MainActor.run {
            (CrossScreenContext.shared.userContext, CrossScreenContext.shared.state)
        }
        let recent = await InteractionLogger.shared.history(limit: 300, since: userContext.recentWindowStart)

        let actions = makeNextActions(userContext: userContext, state: state, recent: recent)
        let priorities = makePagePriorities(userContext: userContext, state: state, recent: recent)

        return IntelligenceOutput(nextActions: actions, pagePriorities: priorities)
    }

    // MARK: - Deterministic rules v1

    private func makeNextActions(userContext: UserContext, state: CrossScreenState, recent: [InteractionEvent]) -> [NextUpContent] {
        var items: [NextUpContent] = []

        // Rule: If in researching/viewing and there's a last search but no recent saves, nudge saving
        if (userContext.journeyStage == .researching || userContext.journeyStage == .viewing),
           let lastSearch = state.lastSearch {
            let recentSaves = recent.filter { $0.type == .propertySaved && $0.occurredAt > (lastSearch.timestamp.addingTimeInterval(-3600)) }
            if recentSaves.isEmpty {
                items.append(
                    NextUpContent(
                        type: .recommendation,
                        title: "Save your favorites",
                        subtitle: "Tap the heart to keep track of homes you like",
                        actionText: "Start saving",
                        priority: .high,
                        metadata: ["source": "rule:no_saves_after_search"]
                    )
                )
            }
        }

        // Rule: If documents were uploaded recently, suggest reviewing status
        if let firstDoc = state.recentlyUploadedDocs.first {
            items.append(
                NextUpContent(
                    type: .task,
                    title: "Review your \(firstDoc.displayName)",
                    subtitle: "Make sure everything looks correct",
                    actionText: "Open Documents",
                    priority: .high,
                    metadata: ["docType": firstDoc.rawValue]
                )
            )
        }

        // Rule: Based on journey stage, suggest stage-specific action
        switch userContext.journeyStage {
        case .exploring:
            items.append(
                NextUpContent(
                    type: .recommendation,
                    title: "Set your budget",
                    subtitle: "Get a feel for your price range",
                    actionText: "Open Budget",
                    priority: .medium,
                    metadata: ["stage": "exploring"]
                )
            )
        case .researching:
            items.append(
                NextUpContent(
                    type: .recommendation,
                    title: "Refine neighborhoods",
                    subtitle: "Fine-tune areas to focus your search",
                    actionText: "Edit Preferences",
                    priority: .medium,
                    metadata: ["stage": "researching"]
                )
            )
        case .viewing:
            items.append(
                NextUpContent(
                    type: .task,
                    title: "Schedule a tour",
                    subtitle: "See your top picks in person",
                    actionText: "Request tour",
                    priority: .high,
                    metadata: ["stage": "viewing"]
                )
            )
        case .negotiating:
            items.append(
                NextUpContent(
                    type: .task,
                    title: "Prepare your offer",
                    subtitle: "Review comps and draft your terms",
                    actionText: "Open Offer Tools",
                    priority: .urgent,
                    metadata: ["stage": "negotiating"]
                )
            )
        case .closing:
            items.append(
                NextUpContent(
                    type: .reminder,
                    title: "Closing checklist",
                    subtitle: "Keep everything on track",
                    actionText: "View checklist",
                    priority: .urgent,
                    metadata: ["stage": "closing"]
                )
            )
        case .settled:
            items.append(
                NextUpContent(
                    type: .milestone,
                    title: "Welcome home",
                    subtitle: "Explore home care and local services",
                    actionText: "Get started",
                    priority: .low,
                    metadata: ["stage": "settled"]
                )
            )
        }

        // Rule: If agent messaged recently, surface a quick reply
        if let lastAgentMsg = state.lastMessageFromAgentAt {
            let hours = Date().timeIntervalSince(lastAgentMsg) / 3600
            if hours < 12 {
                items.append(
                    NextUpContent(
                        type: .reminder,
                        title: "New message from your agent",
                        subtitle: "Reply to keep momentum",
                        actionText: "Open Messages",
                        priority: .high,
                        metadata: ["source": "recent_agent_message"]
                    )
                )
            }
        }

        // Sort by priority sortOrder then recency if needed
        return items.sorted { lhs, rhs in
            if lhs.priority.sortOrder != rhs.priority.sortOrder {
                return lhs.priority.sortOrder < rhs.priority.sortOrder
            }
            return lhs.timestamp > rhs.timestamp
        }
    }

    private func makePagePriorities(userContext: UserContext, state: CrossScreenState, recent: [InteractionEvent]) -> [AppPage: Double] {
        var base: [AppPage: Double] = [
            .homey: 60,
            .discover: 60,
            .insights: 50,
            .directory: 40,
            .vision: 35,
            .settings: 20,
            .matchmaker: 50,
            .profile: 30,
            .documents: 45
        ]

        // Stage-driven adjustments
        switch userContext.journeyStage {
        case .exploring:
            base[.discover, default: 0] += 10
            base[.vision, default: 0] += 5
        case .researching:
            base[.discover, default: 0] += 15
            base[.insights, default: 0] += 10
            base[.matchmaker, default: 0] += 5
        case .viewing:
            base[.matchmaker, default: 0] += 15
            base[.discover, default: 0] += 5
            base[.documents, default: 0] += 5
        case .negotiating:
            base[.documents, default: 0] += 15
            base[.directory, default: 0] += 10
        case .closing:
            base[.documents, default: 0] += 20
            base[.directory, default: 0] += 10
        case .settled:
            base[.insights, default: 0] += 10
            base[.directory, default: 0] += 5
        }

        // Recent document uploads -> Documents up
        if !state.recentlyUploadedDocs.isEmpty {
            base[.documents, default: 0] += 10
        }

        // Recent search but no saves -> Discover up to help refine
        if let lastSearch = state.lastSearch {
            let saves = recent.filter { $0.type == .propertySaved && $0.occurredAt >= lastSearch.timestamp }
            if saves.isEmpty {
                base[.discover, default: 0] += 10
            }
        }

        // Clamp 0...100
        for (k, v) in base {
            base[k] = max(0, min(100, v))
        }

        return base
    }
}