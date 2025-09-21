import SwiftUI

struct DataRibbon: View {
    @State private var animationOffset: CGFloat = 0
    @State private var selectedSegment: RibbonSegment?
    
    let marketData: [RibbonSegment]
    let onSegmentTap: (RibbonSegment) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background ribbon textures
                ForEach(0..<3, id: \.self) { index in
                    Image("ribbon_0\(index + 1)")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width + 200)
                        .offset(x: animationOffset + CGFloat(index * 100))
                        .opacity(0.3)
                        .blendMode(.overlay)
                }
                
                // Flowing gradient overlay
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.6),
                        Color.purple.opacity(0.4),
                        Color.pink.opacity(0.6),
                        Color.orange.opacity(0.4)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(
                    RibbonPath()
                        .stroke(lineWidth: 60)
                )
                .offset(x: animationOffset)
                
                // Data segments
                HStack(spacing: 20) {
                    ForEach(marketData) { segment in
                        DataSegmentView(
                            segment: segment,
                            isSelected: selectedSegment?.id == segment.id
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                selectedSegment = segment
                            }
                            onSegmentTap(segment)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .frame(height: 120)
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        withAnimation(
            .linear(duration: 20)
            .repeatForever(autoreverses: false)
        ) {
            animationOffset = -400
        }
    }
}

struct RibbonPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midY = height / 2
        
        // Create flowing ribbon path
        path.move(to: CGPoint(x: 0, y: midY))
        
        for x in stride(from: 0, through: width, by: 10) {
            let normalizedX = x / width
            let wave1 = sin(normalizedX * .pi * 4) * 15
            let wave2 = cos(normalizedX * .pi * 6) * 8
            let y = midY + wave1 + wave2
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
}

struct DataSegmentView: View {
    let segment: RibbonSegment
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(segment.formattedValue)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(segment.title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 2) {
                Image(systemName: segment.trend == .up ? "arrow.up" : segment.trend == .down ? "arrow.down" : "minus")
                    .font(.caption2)
                Text(segment.formattedChange)
                    .font(.caption2)
            }
            .foregroundColor(segment.trend == .up ? .green : segment.trend == .down ? .red : .gray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? Color.white.opacity(0.6) : Color.clear,
                            lineWidth: 2
                        )
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

#Preview {
    DataRibbon(
        marketData: RibbonSegment.sampleData,
        onSegmentTap: { _ in }
    )
    .background(Color.black)
}