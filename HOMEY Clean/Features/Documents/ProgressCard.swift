import SwiftUI

struct OverallProgressCard: View {
    let documentVaults: [DocumentVault]
    
    private var overallProgress: Double {
        let totalProgress = documentVaults.reduce(0) { $0 + $1.completionPercentage }
        return totalProgress / Double(documentVaults.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header with enhanced avatar and progress
            HStack {
                ZStack {
                    // Animated background glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.orange.opacity(0.3),
                                    Color.pink.opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 35
                            )
                        )
                        .frame(width: 70, height: 70)
                        .scaleEffect(overallProgress > 0.5 ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: overallProgress)
                    
                    // Main avatar circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.orange.opacity(0.9),
                                    Color.pink.opacity(0.7),
                                    Color.purple.opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: .orange.opacity(0.4), radius: 16, x: 0, y: 8)
                    
                    Text("📊")
                        .font(.title)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your Progress")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Text("Document vault completion")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(overallProgress * 100))%")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Text("Complete")
                        .font(.caption.bold())
                        .foregroundColor(.orange.opacity(0.8))
                        .textCase(.uppercase)
                        .tracking(1)
                }
            }
            
            // Enhanced progress details with micro-interactions
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Overall Completion")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    let completedVaults = documentVaults.filter { $0.completionPercentage >= 0.8 }.count
                    HStack(spacing: 4) {
                        Text("\(completedVaults)")
                            .font(.subheadline.bold())
                            .foregroundColor(.orange)
                        Text("of")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                        Text("\(documentVaults.count)")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                        Text("ready")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                // Enhanced progress bar with organic feel
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track with subtle gradient
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        
                        // Animated progress fill with warm gradient
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.orange.opacity(0.9),
                                        Color.pink.opacity(0.8),
                                        Color.purple.opacity(0.7)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * overallProgress, height: 20)
                            .shadow(color: .orange.opacity(0.4), radius: 8, x: 0, y: 4)
                            .animation(.spring(response: 1.2, dampingFraction: 0.8), value: overallProgress)
                        
                        // Shimmer effect for active progress
                        if overallProgress > 0 {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.clear,
                                            Color.white.opacity(0.3),
                                            Color.clear
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * overallProgress, height: 20)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: false), value: overallProgress)
                        }
                        
                        // Progress indicator dot
                        Circle()
                            .fill(Color.white)
                            .frame(width: 16, height: 16)
                            .shadow(color: .orange.opacity(0.6), radius: 6, x: 0, y: 2)
                            .offset(x: max(8, (geometry.size.width * overallProgress) - 8))
                            .animation(.spring(response: 1.2, dampingFraction: 0.8), value: overallProgress)
                    }
                }
                .frame(height: 20)
                
                // Refined progress labels
                HStack {
                    Text("0%")
                        .font(.caption2.bold())
                        .foregroundColor(.white.opacity(0.5))
                    
                    Spacer()
                    
                    Text("50%")
                        .font(.caption2.bold())
                        .foregroundColor(.white.opacity(0.5))
                    
                    Spacer()
                    
                    Text("100%")
                        .font(.caption2.bold())
                        .foregroundColor(.orange.opacity(0.8))
                }
            }
        }
        .padding(28)
        .background(
            ZStack {
                // Main card background with warm gradient
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.4),
                                Color.purple.opacity(0.15),
                                Color.black.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Subtle border with warm accent
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.3),
                                Color.pink.opacity(0.2),
                                Color.purple.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                
                // Organic glow effect
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.orange.opacity(0.08),
                                Color.clear
                            ],
                            center: .topTrailing,
                            startRadius: 50,
                            endRadius: 200
                        )
                    )
            }
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .shadow(color: .orange.opacity(0.1), radius: 40, x: 0, y: 20)
    }
}