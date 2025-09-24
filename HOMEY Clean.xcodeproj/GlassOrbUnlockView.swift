import SwiftUI

// MARK: - Glass Orb Unlock View
public struct GlassOrbUnlockView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var userProfileManager: UserProfileManager
    @EnvironmentObject private var session: AppSessionManager

    @State private var isPressing = false
    @State private var unlocked = false
    @State private var showActions = false
    @State private var phase: CGFloat = 0
    @State private var neonColors: [Color] = GlassOrbUnlockView.randomNeon()
    @State private var keyTurn: CGFloat = 0 // degrees

    private let longPress = LongPressGesture(minimumDuration: 0.8, maximumDistance: 20)

    public init() {}

    public var body: some View {
        VStack(spacing: 24) {
            ZStack {
                // ORB
                if !unlocked {
                    orb
                        .transition(.asymmetric(insertion: .opacity, removal: .opacity.combined(with: .scale)))
                }

                // KEY
                if unlocked {
                    key
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                }
            }
            .frame(height: 340)
            .contentShape(Rectangle())
            .gesture(
                longPress
                    .onChanged { pressing in
                        if !isPressing && !unlocked {
                            isPressing = true
                            withAnimation(.easeInOut(duration: 0.8)) { phase += 2.0 }
                        }
                    }
                    .onEnded { success in
                        isPressing = false
                        if success && !unlocked {
                            unlock()
                        }
                    }
            )
            .accessibilityAddTraits(.isButton)

            if !showActions {
                Text("Long press to unlock actions")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if showActions {
                OrbActionBubblesView(actions: contextualActions(), neonColor: neonColors.first ?? .cyan) { action in
                    router.route = action.route
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear { startOrbAnimation() }
    }

    private var orb: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                // Dynamic colorful core using MeshGradient if available
                if #available(iOS 17.0, *) {
                    MeshGradient(
                        width: 3, height: 3,
                        points: [
                            .init(x: 0, y: 0), .init(x: 0.5, y: 0), .init(x: 1, y: 0),
                            .init(x: 0, y: 0.5), .init(x: 0.5, y: 0.5), .init(x: 1, y: 0.5),
                            .init(x: 0, y: 1), .init(x: 0.5, y: 1), .init(x: 1, y: 1)
                        ],
                        colors: [
                            .blue, .purple, .pink,
                            .cyan, .indigo, .mint,
                            .orange, .red, .yellow
                        ],
                        background: .clear
                    )
                    .blur(radius: 30)
                    .scaleEffect(1.15)
                    .animation(.linear(duration: 12).repeatForever(autoreverses: true), value: phase)
                } else {
                    RadialGradient(colors: [.purple, .blue, .pink, .indigo], center: .center, startRadius: 2, endRadius: size * 0.6)
                        .blur(radius: 18)
                }
            }
            .frame(width: size, height: size)
            .clipShape(BlobShape(phase: phase, amplitude: 0.12, frequency: 6))
            .overlay(
                BlobShape(phase: phase, amplitude: 0.12, frequency: 6)
                    .stroke(AngularGradient(gradient: Gradient(colors: neonColors), center: .center), lineWidth: 3)
                    .shadow(color: (neonColors.first ?? .cyan).opacity(0.6), radius: 14, x: 0, y: 0)
                    .blur(radius: isPressing ? 0 : 0)
            )
            .background(
                Circle()
                    .fill(.ultraThinMaterial)
                    .blur(radius: 22)
                    .opacity(0.55)
                    .scaleEffect(0.98)
            )
            .overlay(
                // Specular highlight
                Circle()
                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    .blur(radius: 0)
                    .opacity(0.9)
                    .blendMode(.plusLighter)
                    .padding(size * 0.04)
            )
            .scaleEffect(isPressing ? 0.96 : 1.0)
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: isPressing)
        }
    }

    private var key: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                KeyShape()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        LinearGradient(colors: [Color.white.opacity(0.35), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                            .blendMode(.plusLighter)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 12)

                KeyShape()
                    .stroke(AngularGradient(gradient: Gradient(colors: neonColors), center: .center), lineWidth: 3)
                    .shadow(color: (neonColors.first ?? .cyan).opacity(0.6), radius: 14)
            }
            .frame(width: size * 0.9, height: size * 0.9)
            .rotationEffect(.degrees(keyTurn))
            .scaleEffect(0.98)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                    keyTurn = 18
                }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.25)) {
                    keyTurn = 0
                }
            }
        }
    }

    private func startOrbAnimation() {
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: true)) {
            phase = 2.0
        }
    }

    private func unlock() {
        // Randomize neon palette
        neonColors = Self.randomNeon()
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()

        withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
            unlocked = true
        }
        // Reveal actions after the key settles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                showActions = true
            }
        }
    }

    private func contextualActions() -> [OrbContextAction] {
        let fullName = userProfileManager.currentProfile?.fullName ?? ""
        let name = fullName.split(separator: " ").first.map(String.init) ?? "You"
        return [
            .init(title: "Documents", subtitle: "Upload 1040s", icon: "doc.fill", route: .documents),
            .init(title: "Directory", subtitle: "Find pros", icon: "person.2.fill", route: .directory),
            .init(title: "Insights", subtitle: "Market trends", icon: "chart.line.uptrend.xyaxis", route: .insights),
            .init(title: "Search", subtitle: "Welcome, \(name)", icon: "magnifyingglass", route: .search)
        ]
    }

    static func randomNeon() -> [Color] {
        let hues = (0..<5).map { _ in Double.random(in: 0...1) }.sorted()
        return hues.map { Color(hue: $0, saturation: 0.95, brightness: 1.0) }
    }
}

// MARK: - Contextual Actions UI
struct OrbContextAction: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let route: AppRoute
}

struct OrbActionBubblesView: View {
    let actions: [OrbContextAction]
    let neonColor: Color
    let onSelect: (OrbContextAction) -> Void
    @State private var appear = false

    var body: some View {
        let columns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]
        LazyVGrid(columns: columns, alignment: .center, spacing: 24) {
            ForEach(actions.indices, id: \.self) { idx in
                OrbActionBubble(action: actions[idx], neonColor: neonColor) {
                    onSelect(actions[idx])
                }
                .opacity(appear ? 1 : 0)
                .scaleEffect(appear ? 1 : 0.85)
                .animation(.spring(response: 0.55, dampingFraction: 0.85).delay(0.05 * Double(idx)), value: appear)
            }
        }
        .frame(maxWidth: 320)
        .frame(maxWidth: .infinity)
        .onAppear { appear = true }
    }
}

struct OrbActionBubble: View {
    let action: OrbContextAction
    let neonColor: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 64, height: 64)
                        .overlay(
                            Circle().stroke(neonColor.opacity(0.85), lineWidth: 2)
                        )
                        .shadow(color: neonColor.opacity(0.5), radius: 10)

                    Image(systemName: action.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(neonColor)
                }
                Text(action.title)
                    .font(.system(size: 12, weight: .semibold))
                Text(action.subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Shapes
struct BlobShape: Shape {
    var phase: CGFloat // animatable phase
    var amplitude: CGFloat = 0.12
    var frequency: CGFloat = 6
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let base = min(rect.width, rect.height) * 0.5
        var p = Path()
        let steps = 120
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps) * .pi * 2
            let r = base * (1 + amplitude * sin(frequency * t + phase))
            let x = center.x + r * cos(t)
            let y = center.y + r * sin(t)
            if i == 0 { p.move(to: CGPoint(x: x, y: y)) } else { p.addLine(to: CGPoint(x: x, y: y)) }
        }
        p.closeSubpath()
        return p
    }
}

struct KeyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height

        // Key head (circle)
        let headR = min(w, h) * 0.22
        let headCenter = CGPoint(x: w * 0.28, y: h * 0.36)
        p.addEllipse(in: CGRect(x: headCenter.x - headR, y: headCenter.y - headR, width: headR * 2, height: headR * 2))

        // Key ring hole
        let holeR = headR * 0.45
        p.addEllipse(in: CGRect(x: headCenter.x - holeR, y: headCenter.y - holeR, width: holeR * 2, height: holeR * 2))
        p.addRect(.zero) // even-odd fill fix
        p = p.eoFilledPath()

        // Shaft
        let shaftH: CGFloat = headR * 0.9
        let shaftTop = headCenter.y - shaftH / 2
        let shaftRect = CGRect(x: headCenter.x + headR * 0.7, y: shaftTop, width: w * 0.5, height: shaftH)
        p.addRoundedRect(in: shaftRect, cornerSize: CGSize(width: shaftH/3, height: shaftH/3))

        // Teeth
        let toothW = shaftRect.width * 0.16
        let toothH = shaftH * 0.45
        let tooth1 = CGRect(x: shaftRect.maxX - toothW * 2.6, y: shaftRect.maxY - toothH, width: toothW, height: toothH)
        let tooth2 = CGRect(x: shaftRect.maxX - toothW * 1.2, y: shaftRect.maxY - toothH * 0.7, width: toothW, height: toothH * 0.7)
        p.addRect(tooth1)
        p.addRect(tooth2)

        return p
    }
}

private extension Path {
    func eoFilledPath() -> Path {
        var m = self
        m.usesEvenOddFillRule = true
        return m
    }
}

// MARK: - Preview
#Preview {
    GlassOrbUnlockView()
        .environmentObject(AppRouter())
        .environmentObject(AppSessionManager.shared)
        .environmentObject(UserProfileManager.shared)
        .padding()
        .background(
            LinearGradient(colors: [.black, .black.opacity(0.98)], startPoint: .top, endPoint: .bottom)
        )
        .preferredColorScheme(.dark)
}
