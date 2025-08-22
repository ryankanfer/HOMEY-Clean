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
        }
    }

    func dislikeFeature(_ feature: String) {
        if !dislikedFeatures.contains(feature) {
            dislikedFeatures.append(feature)
            log("dislikeFeature: \(feature)")
        }
    }

    private func log(_ msg: String) {
        #if DEBUG
            print("[TasteStore]", msg)
        #endif
    }
}
