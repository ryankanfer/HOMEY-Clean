import SwiftUI

struct CharacterCarousel: View {
    @Binding var activeCharacter: HomeyKind?
    @State private var currentIndex = 0
    @State private var showingRole = false
    @State private var roleDisplayTimer: Timer?
    
    private let allCharacters = Array(HomeyKind.allCases)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background blur for current character
                if let currentCharacter = getCurrentCharacter() {
                    CharacterBackgroundView(character: currentCharacter)
                        .ignoresSafeArea()
                }
                
                // Main carousel
                TabView(selection: $currentIndex) {
                    ForEach(Array(allCharacters.enumerated()), id: \.offset) { index, character in
                        CharacterCarouselCard(
                            character: character,
                            showingRole: showingRole && currentIndex == index
                        ) {
                            handleCharacterTap()
                        }
                        .tag(index)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentIndex) { _, newIndex in
                    TRAEHapticManager.shared.trigger(.light)
                    activeCharacter = allCharacters[safe: newIndex]
                    hideRole()
                }
                
                // Character indicators
                VStack {
                    Spacer()
                    
                    HStack(spacing: 8) {
                        ForEach(0..<allCharacters.count, id: \.self) { index in
                            Circle()
                                .fill(currentIndex == index ? .white : .white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentIndex == index ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            activeCharacter = allCharacters.first
        }
    }
    
    private func getCurrentCharacter() -> HomeyKind? {
        return allCharacters[safe: currentIndex]
    }
    
    private func handleCharacterTap() {
        TRAEHapticManager.shared.trigger(.medium)
        showRole()
    }
    
    private func showRole() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showingRole = true
        }
        
        // Auto-hide after 3 seconds
        roleDisplayTimer?.invalidate()
        roleDisplayTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            hideRole()
        }
    }
    
    private func hideRole() {
        roleDisplayTimer?.invalidate()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showingRole = false
        }
    }
}

struct CharacterCarouselCard: View {
    let character: HomeyKind
    let showingRole: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var floatingAnimation = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                
                // Main character display
                ZStack {
                    // Character image
                    Button(action: onTap) {
                        Group {
                            let waveName = "\(character.rawValue)_wave"
                            if showingRole, UIImage(named: waveName) != nil {
                                Image(waveName)
                                    .resizable()
                                    .scaledToFit()
                            } else if UIImage(named: character.assetName) != nil {
                                Image(character.assetName)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Image(systemName: "person.crop.square")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                        }
                        .frame(width: min(geometry.size.width * 0.7, 300),
                               height: min(geometry.size.height * 0.6, 400))
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                        .scaleEffect(isPressed ? 0.95 : 1.0)
                        .offset(y: floatingAnimation ? -10 : 0)
                        .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: floatingAnimation)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(maxWidth: .infinity, alignment: .center)
                    .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                        isPressed = pressing
                    }, perform: {})
                    
                    // Role display overlay
                    if showingRole {
                        VStack {
                            Spacer()
                            
                            VStack(spacing: 12) {
                                HStack(spacing: 8) {
                                    Text(character.emoji)
                                        .font(.title)
                                    Text(character.displayName)
                                        .font(.title.weight(.bold))
                                        .foregroundStyle(.white)
                                }
                                
                                Text(character.role)
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.9))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(.ultraThinMaterial.opacity(0.8), in: Capsule())
                                    .overlay {
                                        Capsule()
                                            .stroke(.white.opacity(0.3), lineWidth: 1)
                                    }
                            }
                            .padding(.bottom, 60)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            // Stagger the floating animation for each character
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...1)) {
                floatingAnimation = true
            }
        }
    }
}

struct CharacterBackgroundView: View {
    let character: HomeyKind
    
    var body: some View {
        ZStack {
            // Base animated gradient
            AnimatedGradientBackground(for: .homey)
            
            // Character-specific accent
            LinearGradient(
                colors: characterAccentColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.3)
            
            // Subtle texture overlay
            LinearGradient(
                colors: [Color.black.opacity(0.2), .clear, Color.black.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    private var characterAccentColors: [Color] {
        switch character {
        case .charlie:
            return [.orange.opacity(0.4), .red.opacity(0.3)]
        case .paige:
            return [.purple.opacity(0.4), .pink.opacity(0.3)]
        case .scout:
            return [.blue.opacity(0.4), .cyan.opacity(0.3)]
        case .isla:
            return [.green.opacity(0.4), .mint.opacity(0.3)]
        case .viza:
            return [.yellow.opacity(0.4), .orange.opacity(0.3)]
        case .drew:
            return [.indigo.opacity(0.4), .blue.opacity(0.3)]
        }
    }
}

// Safe array access extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}