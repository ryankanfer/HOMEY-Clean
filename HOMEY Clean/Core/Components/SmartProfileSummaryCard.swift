import SwiftUI

struct SmartProfileSummaryCard: View {
    let title: String
    let description: String
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Profile completion indicator
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
            
            // Progress tracking
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Profile Completion")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))% Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(y: 0.8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            Color(.systemBackground).opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
    }
}

#Preview {
    SmartProfileSummaryCard(
        title: "Your HOMEY Profile",
        description: "Demo is a renter looking for an apartment in Williamsburg up to $4,000/month",
        progress: 0.75
    )
    .padding()
}