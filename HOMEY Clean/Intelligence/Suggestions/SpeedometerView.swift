import SwiftUI

public struct SpeedometerView: View {
    public let value: Double // 0...100
    public let label: String

    public init(value: Double, label: String) {
        self.value = max(0, min(100, value))
        self.label = label
    }

    public var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .trim(from: 0.0, to: 0.5)
                    .stroke(Theme.secondaryText.opacity(0.2), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(180))

                Circle()
                    .trim(from: 0.0, to: CGFloat(0.5 * (value / 100.0)))
                    .stroke(Theme.primaryAction, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(180))

                Text("\(Int(value))")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Theme.primaryText)
            }
            .frame(width: 120, height: 60)

            Text(label)
                .font(.caption)
                .foregroundStyle(Theme.secondaryText)
        }
        .padding(10)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 12))
    }
}