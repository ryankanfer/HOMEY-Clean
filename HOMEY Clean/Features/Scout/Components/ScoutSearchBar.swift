import SwiftUI

struct ScoutSearchBar: View {
    @Binding var searchText: String
    @Binding var isSearchFocused: Bool
    @State private var isEditing = false
    @State private var showingClearButton = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Search field container
            HStack(spacing: 8) {
                // Search icon
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isEditing ? .cyan : .white.opacity(0.7))
                    .animation(.easeInOut(duration: 0.2), value: isEditing)
                
                // Text field
                TextField("Search neighborhoods, addresses...", text: $searchText)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .accentColor(.cyan)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditing = true
                            isSearchFocused = true
                        }
                    }
                    .onChange(of: searchText) { _, newValue in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingClearButton = !newValue.isEmpty
                        }
                    }
                
                Spacer()
                
                // Clear button
                if showingClearButton {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            searchText = ""
                            showingClearButton = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    // Base glass material
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                    
                    // Futuristic border glow
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    isEditing ? .cyan.opacity(0.8) : .cyan.opacity(0.4),
                                    isEditing ? .blue.opacity(0.6) : .blue.opacity(0.2),
                                    isEditing ? .cyan.opacity(0.6) : .cyan.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: isEditing ? 2 : 1.5
                        )
                        .opacity(0.8)
                        .animation(.easeInOut(duration: 0.2), value: isEditing)
                }
            )
            .shadow(
                color: isEditing ? .cyan.opacity(0.3) : .cyan.opacity(0.1),
                radius: isEditing ? 12 : 6,
                x: 0,
                y: isEditing ? 6 : 3
            )
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            .animation(.easeInOut(duration: 0.2), value: isEditing)
            
            // Voice search button (optional)
            if isEditing {
                Button(action: {
                    // TODO: Implement voice search
                }) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.cyan.opacity(0.8), .blue.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: .cyan.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onTapGesture {
            // Dismiss editing when tapping outside
            if isEditing {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isEditing = false
                    isSearchFocused = false
                }
                hideKeyboard()
            }
        }
    }
}

// MARK: - Helper Extensions

struct HideKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                hideKeyboard()
            }
    }
}

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

extension View {
    func hideKeyboardOnTap() -> some View {
        modifier(HideKeyboardModifier())
    }
}

// MARK: - Preview

#Preview {
    ScoutSearchBar(
        searchText: .constant(""),
        isSearchFocused: .constant(false)
    )
    .padding()
    .background(Color.black)
}