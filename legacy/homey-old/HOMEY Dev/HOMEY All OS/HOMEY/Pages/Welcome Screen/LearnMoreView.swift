import SwiftUI

struct LearnMoreView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Coming Soon")
                .font(.largeTitle.bold())
                .foregroundColor(.gray)
            Spacer()
        }
        .navigationTitle("Learn More")
    }
}
