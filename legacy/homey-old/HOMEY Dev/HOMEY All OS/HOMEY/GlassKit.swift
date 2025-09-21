import SwiftUI

public enum GlassKit {
    public struct Card<Content: View>: View {
        public var corner: CGFloat
        public var content: () -> Content
        @State private var isPressed = false

        public init(corner: CGFloat = 24, @ViewBuilder content: @escaping () -> Content) {
            self.corner = corner
            self.content = content
        }

        public var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: corner, style: .continuous)
                            .fill(
                                .linearGradient(
                                    colors: [.white.opacity(0.10), .white.opacity(0.03)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: corner, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.66), .cyan.opacity(0.55), .mint.opacity(0.45), .clear],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .blendMode(.screen)
                    )
                    .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)

                content().padding(16)
            }
            .contentShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            .onTapGesture {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) { isPressed.toggle() }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { isPressed = false }
            }
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
    }

    // MARK: - Nav Bar (glassy bevel)

    public struct NavBar: View {
        let title: String
        let trailing: AnyView?

        public init(_ title: String, trailing: AnyView? = nil) {
            self.title = title
            self.trailing = trailing
        }

        public var body: some View {
            HStack {
                Text(title).font(.title3.weight(.semibold))
                Spacer()
                if let trailing { trailing }
            }
            .padding(14)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
    }

    public struct PrimaryButtonStyle: ButtonStyle {
        public var primary: Bool
        public init(primary: Bool = false) { self.primary = primary }

        public func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline.weight(.semibold))
                .foregroundStyle(primary ? AnyShapeStyle(.white) : AnyShapeStyle(.white.opacity(0.9)))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule().stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.7),
                                        primary ? .mint.opacity(0.6) : .cyan.opacity(0.45),
                                        .clear,
                                    ],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                        )
                )
                .shadow(
                    color: .black.opacity(configuration.isPressed ? 0.15 : 0.25),
                    radius: configuration.isPressed ? 6 : 12,
                    x: 0,
                    y: configuration.isPressed ? 6 : 12
                )
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .animation(.spring(response: 0.28, dampingFraction: 0.82), value: configuration.isPressed)
        }
    }

    public struct Pill: View {
        public var title: String
        public init(_ title: String) { self.title = title }
        public var body: some View {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(.ultraThinMaterial)
                        .overlay(
                            Capsule().stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.6), .cyan.opacity(0.45), .clear],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                        )
                )
        }
    }

    public struct Background: View {
        public init() {}
        public var body: some View {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(.sRGB, red: 0.90, green: 0.93, blue: 0.96, opacity: 1.0),
                        Color(.sRGB, red: 0.86, green: 0.88, blue: 0.92, opacity: 1.0),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
            }
        }
    }
}

// Back-compat typealiases (must be outside the enum)
public typealias GlassBackground = GlassKit.Background
public typealias GlassCard = GlassKit.Card
public typealias GlassButtonStyle = GlassKit.PrimaryButtonStyle
public typealias GlassChip = GlassKit.Pill
public typealias GlassNavBar = GlassKit.NavBar
