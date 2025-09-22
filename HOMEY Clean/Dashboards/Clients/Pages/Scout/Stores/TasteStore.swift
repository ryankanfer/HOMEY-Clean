//
//  TasteStore.swift
//  HOMEY Clean
//

import Foundation

@MainActor
final class TasteStore: ObservableObject {
    @Published var likedNeighborhoods: [String] = []
    @Published var dislikedFeatures: [String] = []

    func likeNeighborhood(_ name: String) {
        if !likedNeighborhoods.contains(name) {
            likedNeighborhoods.append(name)
            log("likeNeighborhood: \(name)")
            Task.detached {
                await InteractionLogger.shared.log(
                    InteractionEvent(
                        type: .filterApplied,
                        page: .discover,
                        userId: await InteractionLogger.shared.currentUserId(),
                        sessionId: InteractionLogger.shared.makeSessionId(),
                        metadata: ["scope": .init("neighborhood_like"), "value": .init(name)]
                    )
                )
            }
        }
    }

    func dislikeFeature(_ feature: String) {
        if !dislikedFeatures.contains(feature) {
            dislikedFeatures.append(feature)
            log("dislikeFeature: \(feature)")
            Task.detached {
                await InteractionLogger.shared.log(
                    InteractionEvent(
                        type: .filterApplied,
                        page: .discover,
                        userId: await InteractionLogger.shared.currentUserId(),
                        sessionId: InteractionLogger.shared.makeSessionId(),
                        metadata: ["scope": .init("feature_dislike"), "value": .init(feature)]
                    )
                )
            }
        }
    }

    private func log(_ msg: String) {
        #if DEBUG
            print("[TasteStore]", msg)
        #endif
    }
}