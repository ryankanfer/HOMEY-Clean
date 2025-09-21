import SwiftUI

struct IslaHeaderView: View {
    let marketStatus: MarketStatus
    let currentTime: String
    let onProfileTap: () -> Void
    
    var body: some View {
        HStack {
            // Left side - Market Pulse title and status
            VStack(alignment: .leading, spacing: 4) {
                Text("Market Pulse")
                    .font(.custom("JosefinSans-Bold", size: 28))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(marketStatus.color)
                        .frame(width: 8, height: 8)
                        .shadow(color: marketStatus.color, radius: 4)
                    
                    Text(marketStatus.displayText)
                        .font(.custom("PlayfairDisplay-Regular", size: 14))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text(currentTime)
                        .font(.custom("PlayfairDisplay-Regular", size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Right side - Isla avatar and controls
            HStack(spacing: 16) {
                // Market health indicator
                VStack(spacing: 2) {
                    Text("Health")
                        .font(.custom("JosefinSans-Regular", size: 12))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("87%")
                        .font(.custom("JosefinSans-SemiBold", size: 16))
                        .foregroundColor(.green)
                }
                
                // Isla avatar
                Button(action: onProfileTap) {
                    Image("islaAvatar")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 8)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MarketStatus enum is defined in IslaDataService.swift

#Preview {
    IslaHeaderView(
        marketStatus: .open,
        currentTime: "2:34 PM EST",
        onProfileTap: {}
    )
    .background(Color.black)
}