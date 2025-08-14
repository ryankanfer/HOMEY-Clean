
import SwiftUI

struct HUDView: View {
    @EnvironmentObject var coordinator: GameCoordinator

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                CapsuleStat(title: "Time", value: "\(coordinator.timeLeft)s")
                CapsuleStat(title: "Commission", value: "$\(coordinator.score)k")
                Spacer()
                Text("Closing Time: NYC")
                    .font(.headline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.thinMaterial, in: Capsule())
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)

            Spacer()

            if let tip = coordinator.tipText {
                HStack {
                    Text("Charlie: \(tip)")
                        .font(.callout)
                        .lineLimit(1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .shadow(radius: 6, y: 3)
                    Spacer()
                }
                .padding(.leading, 18)
            }

            HStack(spacing: 14) {
                DockButton(systemName: "map") { }
                DockButton(systemName: "person.2.fill") { }
                DockButton(systemName: "bolt.fill") { }
            }
            .padding(.bottom, 22)
        }
        .foregroundStyle(.white)
    }
}

private struct CapsuleStat: View {
    let title: String
    let value: String
    var body: some View {
        HStack(spacing: 8) {
            Text(title).font(.caption2).opacity(0.8)
            Text(value).font(.footnote.bold())
        }
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
    }
}

private struct DockButton: View {
    let systemName: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title3.weight(.semibold))
                .frame(width: 56, height: 56)
                .background(.thinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .shadow(radius: 8, y: 4)
    }
}
