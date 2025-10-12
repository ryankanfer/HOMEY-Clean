import SwiftUI

struct ProgressTrackingStepView: View {
    @State private var showContent = false
    @State private var completedSteps = 0
    private let totalSteps = 4

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Track Your Journey")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                
                Text("From first look to final key turn, we're with you.")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : -20)

            VStack(alignment: .leading, spacing: 0) {
                // A visual representation of the home-buying journey
                ProgressStepItem(
                    icon: "sparkle.magnifyingglass",
                    title: "Discover",
                    description: "Find properties and save your favorites.",
                    isCompleted: completedSteps >= 1,
                    isCurrent: completedSteps == 0
                )
                
                ProgressLine()

                ProgressStepItem(
                    icon: "calendar.badge.clock",
                    title: "Viewing",
                    description: "Schedule tours and visit potential homes.",
                    isCompleted: completedSteps >= 2,
                    isCurrent: completedSteps == 1
                )
                
                ProgressLine()
                
                ProgressStepItem(
                    icon: "pencil.and.ruler.fill",
                    title: "Offer",
                    description: "Make competitive offers with your agent.",
                    isCompleted: completedSteps >= 3,
                    isCurrent: completedSteps == 2
                )
                
                ProgressLine()

                ProgressStepItem(
                    icon: "key.fill",
                    title: "Closing",
                    description: "Finalize paperwork and get your keys!",
                    isCompleted: completedSteps >= 4,
                    isCurrent: completedSteps == 3
                )
            }
            .opacity(showContent ? 1 : 0)
        }
        .padding(20)
        .onAppear {
            // Trigger animations when the view appears
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
            
            // Animate the progress indicator filling up
            guard completedSteps == 0 else { return } // Prevents re-animating
            for i in 1...totalSteps {
                withAnimation(.easeInOut(duration: 0.5).delay(0.8 + Double(i) * 0.6)) {
                    completedSteps = i
                }
            }
        }
    }
}

// MARK: - Supporting Views for Progress Tracking

private struct ProgressStepItem: View {
    let icon: String
    let title: String
    let description: String
    let isCompleted: Bool
    let isCurrent: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .strokeBorder(isCompleted ? .green : (isCurrent ? .blue : .gray.opacity(0.4)), lineWidth: 2)
                    .background(Circle().fill(isCompleted ? .green.opacity(0.15) : (isCurrent ? .blue.opacity(0.15) : .clear)))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(isCompleted ? .green : (isCurrent ? .blue : .secondary))
            }
            .animation(.easeOut.delay(0.2), value: isCompleted)
            .animation(.easeOut.delay(0.2), value: isCurrent)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

private struct ProgressLine: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 2, height: 30)
            .padding(.leading, 21) // Aligns with the center of the circle icon
    }
}


#if DEBUG
struct ProgressTrackingStepView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressTrackingStepView()
            .padding()
            .background(Color(.systemGroupedBackground))
            .preferredColorScheme(.dark)
    }
}
#endif