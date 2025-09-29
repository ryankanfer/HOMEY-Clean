import SwiftUI

struct OnboardingMapModal: View {
    @Binding var isPresented: Bool
    let progress: Double
    let onSelectStation: (Int) -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { collapse() }

            VStack(spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.973, green: 0.961, blue: 0.929),
                                         Color(red: 0.949, green: 0.929, blue: 0.878)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 12)
                        .frame(height: 520)
                        .overlay {
                            MapCanvas(progress: progress, onSelectStation: onSelectStation)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                    Button(action: { collapse() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.black.opacity(0.7))
                            .padding(10)
                    }
                    .accessibilityLabel("Close map")
                }

                HStack(spacing: 12) {
                    LegendDot(color: Color(red: 0.00, green: 0.65, blue: 0.32), label: "Completed")
                    LegendDot(color: Color(red: 0.99, green: 0.80, blue: 0.19), label: "Current")
                    LegendDot(color: Color(red: 0.84, green: 0.83, blue: 0.80), label: "Upcoming")
                    Spacer()
                }
                .padding(10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2))
                )
            }
            .padding(.horizontal, 16)
        }
    }

    private func collapse() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isPresented = false
        }
        EventsManager.shared.recordEvent(.subwayMapCollapsed)
    }

    private struct LegendDot: View {
        let color: Color
        let label: String
        var body: some View {
            HStack(spacing: 6) {
                Circle().fill(color).frame(width: 10, height: 10)
                Text(label).font(.caption).foregroundStyle(.black.opacity(0.7))
            }
        }
    }

    private struct MapCanvas: View {
        let progress: Double
        let onSelectStation: (Int) -> Void

        var body: some View {
            GeometryReader { geo in
                let w = geo.size.width - 40
                let h = geo.size.height - 80
                let left: CGFloat = 20
                let top: CGFloat = 60
                let stationCount = 5

                ZStack {
                    Path { p in
                        p.move(to: CGPoint(x: left, y: top))
                        p.addLine(to: CGPoint(x: left + w, y: top))
                    }
                    .stroke(Color.black.opacity(0.2), style: StrokeStyle(lineWidth: 10, lineCap: .round))

                    Path { p in
                        p.move(to: CGPoint(x: left, y: top))
                        p.addLine(to: CGPoint(x: left + w * CGFloat(max(0, min(1, progress))), y: top))
                    }
                    .stroke(Color(red: 0.00, green: 0.65, blue: 0.32), style: StrokeStyle(lineWidth: 10, lineCap: .round))

                    let spacing = w / CGFloat(stationCount - 1)
                    ForEach(0..<stationCount, id: \.self) { idx in
                        let x = left + CGFloat(idx) * spacing
                        let pct = Double(idx+1) / Double(stationCount)
                        let stateColor: Color = (self.progress >= pct)
                            ? Color(red: 0.00, green: 0.65, blue: 0.32)
                            : (self.progress >= pct - 0.2)
                                ? Color(red: 0.99, green: 0.80, blue: 0.19)
                                : Color(red: 0.84, green: 0.83, blue: 0.80)

                        StationButton(index: idx + 1, center: CGPoint(x: x, y: top), ringColor: stateColor) {
                            onSelectStation(idx + 1)
                        }
                    }

                    ForEach(1..<4, id: \.self) { idx in
                        let spacing = w / CGFloat(stationCount - 1)
                        let x = left + CGFloat(idx) * spacing
                        Path { p in
                            p.move(to: CGPoint(x: x, y: top))
                            p.addLine(to: CGPoint(x: x, y: top + h * 0.55))
                        }
                        .stroke(Color(red: 1.0, green: 0.39, blue: 0.10), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    }
                }
            }
        }
    }

    private struct StationButton: View {
        let index: Int
        let center: CGPoint
        let ringColor: Color
        let action: () -> Void
        var body: some View {
            Button(action: action) {
                Text("\(index)")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 32, height: 32)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.6), lineWidth: 3))
                    .overlay(Circle().stroke(ringColor, lineWidth: 3))
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
            }
            .buttonStyle(.plain)
            .position(center)
            .accessibilityLabel("Station \(index)")
        }
    }
}