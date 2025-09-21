
import SwiftUI

struct EventSheetView: View {
    @EnvironmentObject var coordinator: GameCoordinator

    var body: some View {
        switch coordinator.nextEvent {
        case .negotiation: NegotiationCard()
        case .docdash: DocDashCard()
        }
    }
}

struct NegotiationCard: View {
    @EnvironmentObject var coordinator: GameCoordinator
    @State private var meter: CGFloat = 0.0
    @State private var running = true
    private let target = CGFloat.random(in: 0.35 ... 0.65)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Negotiation").font(.title3.bold())
            Text("Stop the slider in the sweet spot to lock the deal.")
                .font(.footnote).opacity(0.7)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial).frame(height: 44)
                RoundedRectangle(cornerRadius: 10)
                    .fill(.green.opacity(0.25))
                    .frame(width: 120, height: 36)
                    .offset(x: (target * 900) - 60)
                Circle()
                    .frame(width: 36, height: 36)
                    .offset(x: (meter * 900) - 18)
                    .shadow(radius: 4)
                    .animation(
                        running ? .linear(duration: 1.2).repeatForever(autoreverses: true) : .default,
                        value: meter
                    )
                    .onAppear { meter = 1.0 }
            }

            Button("Lock Offer") {
                running = false
                let diff = abs(meter - target)
                let points = max(5 - Int(diff * 20), 1) * 5
                coordinator.completeDeal(points: points)
                coordinator.showEventCard = false
            }
            .buttonStyle(.borderedProminent)

            Text("Tip: counter cleanly; avoid contingencies if the board is strict.")
                .font(.caption).opacity(0.6)
        }
        .padding(20)
    }
}

struct DocDashCard: View {
    @EnvironmentObject var coordinator: GameCoordinator
    @State private var docs = ["W-2", "1040", "2 Bank Statements", "Reference Letter", "Pay Stubs"]
    @State private var target = "Reference Letter"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Doc Dash").font(.title3.bold())
            Text("Tap the missing document before the rival snags the deal.")
                .font(.footnote).opacity(0.7)

            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
                ForEach(docs, id: \.self) { d in
                    Button {
                        let success = (d == target)
                        let points = success ? Int.random(in: 10 ... 25) : 5
                        coordinator.completeDeal(points: points)
                        coordinator.showEventCard = false
                    } label: {
                        Text(d)
                            .frame(maxWidth: .infinity).padding(.vertical, 14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("Hint: boards love clean, complete packages.")
                .font(.caption).opacity(0.6)
        }
        .padding(20)
        .onAppear {
            docs.shuffle()
            target = docs.randomElement() ?? "W-2"
        }
    }
}
