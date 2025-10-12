import SwiftUI

struct FeaturesStepView: View {
    // Defines the features to be displayed with their animations
    private let features: [AnimatedFeature] = [
        AnimatedFeature(
            icon: "sparkles",
            title: "Smart Search",
            description: "Find homes that match your lifestyle, not just a checklist.",
            color: .purple
        ),
        AnimatedFeature(
            icon: "shield.lefthalf.filled",
            title: "Expert Guidance",
            description: "Your personal agent is with you every step of the way.",
            color: .blue
        ),
        AnimatedFeature(
            icon: "chart.line.uptrend.xyaxis",
            title: "Clear Progress",
            description: "Always know exactly where you are in your journey.",
            color: .green
        )
    ]
    
    @State private var showContent = false

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What makes HOMEY different?")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                
                Text("We're more than just a listing app.")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : -20)
            
            VStack(spacing: 24) {
                // Iterates through features and applies a staggered animation
                ForEach(features.indices, id: \.self) { index in
                    FeatureRowView(feature: features[index])
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.7)
                            .delay(0.2 * Double(index)),
                            value: showContent
                        )
                }
            }
        }
        .padding(20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
    }
}

// MARK: - Supporting Types and Views

private struct AnimatedFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let color: Color
}

private struct FeatureRowView: View {
    let feature: AnimatedFeature

    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: feature.icon)
                .font(.title.bold())
                .foregroundColor(feature.color)
                .frame(width: 40, alignment: .center)
                
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(feature.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineSpacing(3)
            }
        }
    }
}

#if DEBUG
struct FeaturesStepView_Previews: PreviewProvider {
    static var previews: some View {
        FeaturesStepView()
            .padding()
            .background(Color(.systemGroupedBackground))
            .preferredColorScheme(.dark)
    }
}
#endif