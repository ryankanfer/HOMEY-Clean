import SwiftUI

public struct LaunchView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showFirst = false
    @State private var showSecond = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Use the new animated gradient background system
            AnimatedGradientBackground(for: .homey)
                .environmentObject(ThemeManager.shared)
                .ignoresSafeArea()
            
            // Content
            VStack(spacing: 16) {
                Spacer()
                
                // Single-line tagline with staged fade-ins
                HStack(spacing: 6) {
                    Text("in your pocket.")
                        .font(.custom("JosefinSans-Regular", size: 18))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("on your side.")
                        .font(.custom("JosefinSans-Regular", size: 18))
                        .foregroundColor(.white.opacity(0.9))
                        .opacity(showSecond ? 1.0 : 0.0)
                        .animation(reduceMotion ? .none : .easeOut(duration: 0.6), value: showSecond)
                }
                .opacity(showFirst ? 1.0 : 0.0)
                .offset(y: showFirst ? 0 : 10)
                .animation(reduceMotion ? .none : .easeOut(duration: 0.8), value: showFirst)
                
                Spacer()
            }
        }
        .onAppear {
            // First phrase fades in immediately
            withAnimation(reduceMotion ? .none : .easeOut(duration: 0.8)) {
                showFirst = true
            }
            
            // Second phrase fades in shortly after
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(reduceMotion ? .none : .easeOut(duration: 0.6)) {
                    showSecond = true
                }
            }
        }
    }
    
    private struct AnimatedSkyBlueBackground: View {
        let phase: CGFloat
        
        var body: some View {
            ZStack {
                // Base sky blue gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.4, green: 0.7, blue: 1.0), // Light sky blue
                        Color(red: 0.2, green: 0.5, blue: 0.9), // Medium sky blue
                        Color(red: 0.1, green: 0.4, blue: 0.8)  // Deeper sky blue
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Animated overlay gradients for movement effect
                LinearGradient(
                    colors: [
                        Color(red: 0.3, green: 0.6, blue: 0.95).opacity(0.6),
                        Color.clear,
                        Color(red: 0.2, green: 0.5, blue: 0.9).opacity(0.4)
                    ],
                    startPoint: UnitPoint(
                        x: 0.5 + 0.3 * cos(phase * 2 * Double.pi),
                        y: 0.5 + 0.3 * sin(phase * 2 * Double.pi)
                    ),
                    endPoint: UnitPoint(
                        x: 0.5 - 0.3 * cos(phase * 2 * Double.pi),
                        y: 0.5 - 0.3 * sin(phase * 2 * Double.pi)
                    )
                )
                
                // Secondary animated layer for depth
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color(red: 0.5, green: 0.8, blue: 1.0).opacity(0.3),
                        Color.clear
                    ],
                    startPoint: UnitPoint(
                        x: 0.3 + 0.4 * cos(phase * 1.5 * Double.pi),
                        y: 0.3 + 0.4 * sin(phase * 1.5 * Double.pi)
                    ),
                    endPoint: UnitPoint(
                        x: 0.7 - 0.4 * cos(phase * 1.5 * Double.pi),
                        y: 0.7 - 0.4 * sin(phase * 1.5 * Double.pi)
                    )
                )
                
                // White cloud wisps
                CloudWispsView(phase: phase)
            }
        }
    }
    
    private struct CloudWispsView: View {
        let phase: CGFloat
        
        var body: some View {
            ZStack {
                // Large cloud wisp 1
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 80)
                    .offset(
                        x: -100 + 50 * cos(phase * 0.8 * Double.pi),
                        y: -150 + 30 * sin(phase * 0.6 * Double.pi)
                    )
                    .opacity(0.6 + 0.2 * sin(phase * 1.2 * Double.pi))
                
                // Large cloud wisp 2
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.35),
                                Color.white.opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 15,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 70)
                    .offset(
                        x: 120 + 40 * cos(phase * 1.1 * Double.pi),
                        y: -100 + 25 * sin(phase * 0.9 * Double.pi)
                    )
                    .opacity(0.5 + 0.3 * sin(phase * 0.8 * Double.pi))
                
                // Medium cloud wisp 3
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 50)
                    .offset(
                        x: 0 + 60 * cos(phase * 1.3 * Double.pi),
                        y: 50 + 40 * sin(phase * 1.1 * Double.pi)
                    )
                    .opacity(0.4 + 0.2 * sin(phase * 1.5 * Double.pi))
                
                // Small cloud wisp 4
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                Color.white.opacity(0.08),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: 35
                        )
                    )
                    .frame(width: 70, height: 35)
                    .offset(
                        x: -80 + 35 * cos(phase * 1.6 * Double.pi),
                        y: 100 + 20 * sin(phase * 1.4 * Double.pi)
                    )
                    .opacity(0.3 + 0.2 * sin(phase * 1.8 * Double.pi))
                
                // Small cloud wisp 5
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 25
                        )
                    )
                    .frame(width: 50, height: 25)
                    .offset(
                        x: 90 + 25 * cos(phase * 2.1 * Double.pi),
                        y: -50 + 15 * sin(phase * 1.7 * Double.pi)
                    )
                    .opacity(0.2 + 0.15 * sin(phase * 2.2 * Double.pi))
            }
        }
    }
    
    private struct GlassWordmark: View {
        @Environment(\.accessibilityReduceMotion) private var reduceMotion
        let text: String
        var visible: Bool
        
        var body: some View {
            let mark = Text(text)
                .font(.playfairDisplayBold(56))
                .tracking(2)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            
            return ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .mask(mark)
                    .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                
                LinearGradient(
                    colors: [Color.white.opacity(0.95), Color.white.opacity(0.35)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .mask(mark)
                .opacity(0.65)
            }
            .opacity(visible ? 1 : 0)
            .scaleEffect(visible ? 1.0 : 0.96)
            .blur(radius: visible || reduceMotion ? 0 : 1.5)
            .animation(reduceMotion ? .none : .easeOut(duration: 0.5).delay(0.1), value: visible)
        }
    }
}
