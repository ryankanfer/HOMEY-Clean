import SwiftUI

struct OverallProgressCard: View {
    let documentVaults: [DocumentVault]
    
    private var overallProgress: Double {
        let totalProgress = documentVaults.reduce(0) { $0 + $1.completionPercentage }
        return totalProgress / Double(documentVaults.count)
    }
    
    private var completedVaults: Int {
        documentVaults.filter { $0.completionPercentage >= 0.8 }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            progressBar
            footer
        }
        .padding(24)
        .background(cardBackground)
    }
    
    private var header: some View {
        HStack(spacing: 16) {
            aiAvatar
            progressInfo
        }
    }
    
    private var aiAvatar: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.orange.opacity(0.4),
                            Color.pink.opacity(0.3),
                            Color.purple.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 15,
                        endRadius: 45
                    )
                )
                .frame(width: 80, height: 80)
                .scaleEffect(overallProgress > 0.5 ? 1.3 : 1.1)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: overallProgress)
            
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.orange.opacity(0.3),
                                    Color.pink.opacity(0.2),
                                    Color.purple.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .frame(width: 64, height: 64)
            
            Image(systemName: "brain.head.profile")
                .font(.title2.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(overallProgress > 0.8 ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.5), value: overallProgress)
        }
    }
    
    private var progressInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Document Vault")
                    .homeyFont(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("\(completedVaults)")
                        .homeyFont(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("of")
                        .homeyFont(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(documentVaults.count)")
                        .homeyFont(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("ready")
                        .homeyFont(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Text(getAIInsight())
                .homeyFont(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(2)
        }
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .frame(height: 12)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.orange,
                                Color.pink,
                                Color.purple.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * overallProgress, height: 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.0),
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .offset(x: -geometry.size.width)
                            .animation(
                                .linear(duration: 2)
                                .repeatForever(autoreverses: false),
                                value: overallProgress
                            )
                    )
                    .animation(.easeInOut(duration: 1.2), value: overallProgress)
            }
        }
        .frame(height: 12)
    }
    
    private var footer: some View {
        HStack {
            Text("\(Int(overallProgress * 100))% Complete")
                .homeyFont(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {}) {
                HStack(spacing: 6) {
                    Image(systemName: getSmartActionIcon())
                        .font(.caption.bold())
                    Text(getSmartActionText())
                        .homeyFont(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.2))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: overallProgress > 0.7 ? Color.orange.opacity(0.3) : Color.black.opacity(0.1),
                radius: overallProgress > 0.7 ? 12 : 6,
                x: 0,
                y: 4
            )
    }
    
    private func getAIInsight() -> String {
        if overallProgress >= 0.9 {
            return "🎉 Excellent! Your documents are ready for applications"
        } else if overallProgress >= 0.7 {
            return "🚀 Almost there! Just a few more documents to complete"
        } else if overallProgress >= 0.5 {
            return "📈 Good progress! Focus on high-priority categories"
        } else if overallProgress >= 0.3 {
            return "📋 Getting started! Upload essential documents first"
        } else {
            return "✨ Welcome! Let's organize your documents together"
        }
    }
    
    private func getSmartActionIcon() -> String {
        if overallProgress >= 0.9 {
            return "checkmark.circle.fill"
        } else if overallProgress >= 0.7 {
            return "arrow.up.circle.fill"
        } else if overallProgress >= 0.5 {
            return "plus.circle.fill"
        } else {
            return "wand.and.stars"
        }
    }
    
    private func getSmartActionText() -> String {
        if overallProgress >= 0.9 {
            return "Share"
        } else if overallProgress >= 0.7 {
            return "Upload"
        } else if overallProgress >= 0.5 {
            return "Add More"
        } else {
            return "Smart Scan"
        }
    }
}