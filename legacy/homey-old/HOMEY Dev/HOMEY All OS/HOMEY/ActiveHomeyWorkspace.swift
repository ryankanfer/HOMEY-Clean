import SwiftUI

struct ActiveHomeyWorkspace: View {
    @Binding var active: HomeyKind
    var openChat: (ChatTarget) -> Void
    var openDocuments: () -> Void

    var body: some View {
        Group {
            switch active {
            case .charlie:
                CharliesCorner(openChat: { openChat(.homey(.charlie)) })

            case .paige:
                PaigesPlace(
                    openChat: { openChat(.homey(.paige)) },
                    openDocuments: openDocuments
                )

            case .scout:
                ScoutView(
                    openMatches: { active = .scout },
                    openChat: { openChat(.homey(.scout)) }
                )

            case .isla:
                IslasInsights(
                    areaName: "Upper West Side",
                    areaValues: .init(medianRent: "$4,500", daysOnMarket: "28", pricePerSqft: "$7.50"),
                    baselineName: "Manhattan",
                    baselineValues: .init(medianRent: "$4,250", daysOnMarket: "42", pricePerSqft: "$6.85"),
                    openInsights: { /* route */ },
                    openChat: { openChat(.homey(.isla)) }
                )

            case .viza:
                VizasVision(
                    openChat: { openChat(.homey(.viza)) },
                    showAR: { /* present AR/Camera */ },
                    uploadPhoto: { /* picker */ }
                )

            case .drew:
                DrewsDirectory(openChat: { openChat(.homey(.drew)) })
            }
        }
        .transition(.opacity.combined(with: .move(edge: .trailing)))
        .animation(.easeInOut(duration: 0.25), value: active)
    }
}
