import SwiftUI

struct HomepageCustomizationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTheme: String = "Quantum"
    @State private var selectedLayout: String = "Immersive"
    @State private var holographicRotation: Double = 0
    @State private var neuralPulse: Double = 0.5
    @State private var dimensionalShift: Double = 0
    
    let themes = ["Quantum", "Neural", "Professional", "Digital"]
    let layouts = ["Immersive", "Classic", "Minimal", "Advanced"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Deep space consciousness background
                Color.black
                    .ignoresSafeArea()
                
                // Neural network overlay
                ImmersiveProfileSystem.neuralNetwork(intensity: 0.3, nodes: 12)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Theme Selection
                        customizationSection(
                            title: "Reality Theme",
                            subtitle: "Choose your dimensional interface",
                            options: themes,
                            selectedOption: $selectedTheme
                        )
                        
                        // Layout Selection
                        customizationSection(
                            title: "Consciousness Layout",
                            subtitle: "Organize your digital space",
                            options: layouts,
                            selectedOption: $selectedLayout
                        )
                        
                        // Preview Section
                        previewSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Reality Customization")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        applyCustomizations()
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            startQuantumAnimations()
        }
    }
    
    private func customizationSection(
        title: String,
        subtitle: String,
        options: [String],
        selectedOption: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Options Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(options, id: \.self) { option in
                    QuantumOptionCard(
                        title: option,
                        isSelected: selectedOption.wrappedValue == option
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedOption.wrappedValue = option
                        }
                    }
                }
            }
        }
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reality Preview")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            ZStack {
                // Preview background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 200)
                
                // Preview content
                VStack(spacing: 12) {
                    Text("Your \(selectedTheme) Interface")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(selectedLayout) Layout Active")
                        .font(.subheadline)
                        .foregroundColor(.cyan)
                    
                    // Animated preview elements
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color.cyan.opacity(0.6))
                                .frame(width: 12, height: 12)
                                .scaleEffect(neuralPulse + Double(index) * 0.1)
                        }
                    }
                }
                
                // Holographic border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color.cyan.opacity(0.6),
                                Color.clear,
                                Color.purple.opacity(0.3),
                                Color.clear,
                                Color.cyan.opacity(0.6)
                            ],
                            center: .center,
                            angle: .degrees(holographicRotation)
                        ),
                        lineWidth: 2
                    )
            }
        }
    }
    
    private func startQuantumAnimations() {
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            holographicRotation = 360
        }
        
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            neuralPulse = 1.0
        }
        
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            dimensionalShift = 1.0
        }
    }
    
    private func applyCustomizations() {
        // Apply the selected theme and layout
        // This would typically save to UserDefaults or a settings manager
        UserDefaults.standard.set(selectedTheme, forKey: "SelectedTheme")
        UserDefaults.standard.set(selectedLayout, forKey: "SelectedLayout")
    }
}

struct QuantumOptionCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @State private var cardHover: Bool = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon based on title
                Image(systemName: iconForOption(title))
                    .font(.title2)
                    .foregroundColor(isSelected ? .cyan : .white.opacity(0.7))
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .cyan : .white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                ZStack {
                    // Base layer
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(isSelected ? 0.1 : 0.05))
                    
                    // Selection glow
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.cyan.opacity(0.2),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 80
                                )
                            )
                    }
                    
                    // Holographic border
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? Color.cyan.opacity(0.8) : Color.white.opacity(0.2),
                            lineWidth: isSelected ? 2 : 1
                        )
                }
            )
            .scaleEffect(cardHover ? 1.05 : 1.0)
            .rotation3DEffect(
                .degrees(cardHover ? 5 : 0),
                axis: (x: 1, y: 1, z: 0)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                cardHover = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                    cardHover = false
                }
            }
        }
    }
    
    private func iconForOption(_ option: String) -> String {
        switch option {
        case "Quantum": return "atom"
        case "Neural": return "brain.head.profile"
        case "Professional": return "briefcase"
        case "Digital": return "cpu"
        case "Immersive": return "cube.transparent"
        case "Classic": return "rectangle.grid.1x2"
        case "Minimal": return "circle"
        case "Advanced": return "gear"
        default: return "circle"
        }
    }
}

#Preview {
    HomepageCustomizationSheet()
}