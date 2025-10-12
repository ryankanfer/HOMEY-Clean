import SwiftUI

struct WelcomeStepView: View {
    @State private var showContent = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("Welcome to HOMEY")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Your home search, simplified.")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)
            
            Text("We'll ask a few questions to personalize your search and find homes that truly match your lifestyle.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 20)

            Spacer()
            Spacer()
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showContent)
        .onAppear {
            showContent = true
        }
    }
}

#if DEBUG
struct WelcomeStepView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeStepView()
            .padding()
            .background(Color(.systemGroupedBackground))
            .preferredColorScheme(.dark)
    }
}
#endif