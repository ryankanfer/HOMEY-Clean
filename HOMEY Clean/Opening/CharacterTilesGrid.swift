import SwiftUI

struct CharacterTilesGrid: View {
    @Binding var activeCharacter: HomeyKind?
    @State private var selectedCharacter: HomeyKind?
    @State private var showingDetail = false
    
    private let allCharacters = Array(HomeyKind.allCases)
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(allCharacters, id: \.self) { character in
                CharacterTileCard(character: character) {
                    TRAEHapticManager.shared.trigger(.medium)
                    selectedCharacter = character
                    activeCharacter = character
                    showingDetail = true
                }
                .scaleEffect(activeCharacter == character ? 1.05 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: activeCharacter)
            }
        }
        .sheet(isPresented: $showingDetail) {
            if let character = selectedCharacter {
                CharacterDetailView(character: character)
            }
        }
    }
}

struct CharacterTileCard: View {
    let character: HomeyKind
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var glowEffect = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Character avatar
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        }
                        .frame(height: 140)
                    
                    VStack(spacing: 8) {
                        // Avatar image
                        Group {
                            if UIImage(named: character.assetName) != nil {
                                Image(character.assetName)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Image(systemName: "person.crop.square")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        
                        // Character info
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Text(character.emoji)
                                    .font(.caption)
                                Text(character.displayName)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.white)
                            }
                            
                            Text(character.role)
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                    }
                    .padding(12)
                }
                .shadow(color: .black.opacity(0.2), radius: glowEffect ? 12 : 6)
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowEffect = true
            }
        }
    }
}

struct CharacterDetailView: View {
    let character: HomeyKind
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with character image
                    VStack(spacing: 16) {
                        Group {
                            if UIImage(named: character.assetName) != nil {
                                Image(character.assetName)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Image(systemName: "person.crop.square")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: .black.opacity(0.2), radius: 12)
                        
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Text(character.emoji)
                                    .font(.title)
                                Text(character.displayName)
                                    .font(.title.weight(.bold))
                            }
                            
                            Text(character.role)
                                .font(.headline.weight(.medium))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial, in: Capsule())
                        }
                    }
                    
                    // Character description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About \(character.displayName)")
                            .font(.title2.weight(.semibold))
                        
                        Text(character.blurb)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline.weight(.medium))
                }
            }
        }
    }
}

// MARK: - Haptics Helper