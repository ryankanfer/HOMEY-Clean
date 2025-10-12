import SwiftUI

// MARK: - Dissolving Outline Effect Component
struct DissolvingOutlineEffect: View {
    let onComplete: () -> Void
    
    @State private var dissolveProgress: CGFloat = 0
    @State private var isDissolving = false
    @State private var particleOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Horizontal dissolving lines pattern
            VStack(spacing: 2) {
                ForEach(0..<20, id: \.self) { index in
                    HStack(spacing: 1) {
                        ForEach(0..<30, id: \.self) { segmentIndex in
                            Rectangle()
                                .fill(.white.opacity(0.8))
                                .frame(width: 4, height: 1)
                                .opacity(getSegmentOpacity(lineIndex: index, segmentIndex: segmentIndex))
                                .animation(
                                    .easeOut(duration: 0.3)
                                    .delay(Double(index) * 0.02 + Double(segmentIndex) * 0.005),
                                    value: dissolveProgress
                                )
                        }
                    }
                }
            }
            .opacity(particleOpacity)
        }
        .onTapGesture {
            startDissolving()
        }
    }
    
    private func getSegmentOpacity(lineIndex: Int, segmentIndex: Int) -> Double {
        let totalProgress = dissolveProgress
        let lineProgress = max(0, min(1, (totalProgress * 25) - Double(lineIndex)))
        let segmentProgress = max(0, min(1, (lineProgress * 35) - Double(segmentIndex)))
        
        return isDissolving ? (1.0 - segmentProgress) : 0
    }
    
    private func startDissolving() {
        guard !isDissolving else { return }
        
        isDissolving = true
        
        withAnimation(.easeIn(duration: 0.1)) {
            particleOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 1.2)) {
            dissolveProgress = 1.0
        }
        
        // Complete the dissolving effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            onComplete()
        }
    }
}

// MARK: - Dissolving Orb View
struct DissolvingOrbView: View {
    let onComplete: () -> Void
    
    @State private var showDissolveEffect = false
    @State private var orbOpacity: Double = 1.0
    @State private var isPressing = false
    @State private var pressProgress: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Original orb outline (invisible but maintains hit area)
            Circle()
                .stroke(.clear, lineWidth: 2)
                .opacity(orbOpacity)
            
            // Press progress indicator
            Circle()
                .trim(from: 0, to: pressProgress)
                .stroke(.white.opacity(0.8), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .opacity(isPressing ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isPressing)
            
            // Dissolving effect overlay
            if showDissolveEffect {
                DissolvingOutlineEffect {
                    // When dissolving completes, fade out and trigger completion
                    withAnimation(.easeOut(duration: 0.3)) {
                        orbOpacity = 0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onComplete()
                    }
                }
                .transition(.opacity)
            }
        }
        .gesture(
            LongPressGesture(minimumDuration: 1.0, maximumDistance: 50)
                .onChanged { pressing in
                    if pressing && !isPressing && !showDissolveEffect {
                        isPressing = true
                        startPressAnimation()
                    }
                    if !pressing && isPressing {
                        cancelPress()
                    }
                }
                .onEnded { success in
                    isPressing = false
                    if success && !showDissolveEffect {
                        completePress()
                    } else {
                        cancelPress()
                    }
                }
        )
    }
    
    private func startPressAnimation() {
        withAnimation(.linear(duration: 1.0)) {
            pressProgress = 1.0
        }
    }
    
    private func cancelPress() {
        withAnimation(.easeOut(duration: 0.3)) {
            pressProgress = 0
            isPressing = false
        }
    }
    
    private func completePress() {
        guard !showDissolveEffect else { return }
        
        withAnimation(.easeIn(duration: 0.2)) {
            showDissolveEffect = true
            pressProgress = 0
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        DissolvingOrbView {
            print("Dissolving completed!")
        }
        .frame(width: 200, height: 200)
    }
}