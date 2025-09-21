import SwiftUI

struct MilestoneProgressView: View {
    let milestones: [String]
    let currentStep: Int
    var body: some View {
        HStack {
            ForEach(milestones.indices, id: \.self) { idx in
                VStack {
                    Circle()
                        .fill(idx <= currentStep ? Color.purple : Color.gray.opacity(0.2))
                        .frame(width: 28, height: 28)
                        .overlay(Text("\(idx + 1)").foregroundColor(.white).bold())
                    Text(milestones[idx]).font(.caption)
                }
                if idx < milestones.count - 1 {
                    Rectangle()
                        .fill(idx < currentStep ? Color.purple : Color.gray.opacity(0.4))
                        .frame(width: 24, height: 4)
                }
            }
        }
        .padding(8)
    }
}
