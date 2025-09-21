import SwiftUI

// MARK: - Emotional Context Data

struct EmotionalContextData {
    let context: EmotionalContext
    let emoji: String
    let label: String
    let color: Color
}

// MARK: - Emotional Context Picker

struct EmotionalContextPicker: View {
    @Binding var selectedContext: EmotionalContext
    
    private let contexts: [EmotionalContextData] = [
        EmotionalContextData(context: .excited, emoji: "🎉", label: "Excited", color: .orange),
        EmotionalContextData(context: .focused, emoji: "🎯", label: "Focused", color: .blue),
        EmotionalContextData(context: .anxious, emoji: "😰", label: "Cautious", color: .purple),
        EmotionalContextData(context: .neutral, emoji: "😊", label: "Relaxed", color: .green)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How are you feeling about your search?")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                ForEach(contexts, id: \.context) { contextData in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedContext = contextData.context
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(contextData.emoji)
                                .font(.title2)
                            
                            Text(contextData.label)
                                .font(.caption.weight(.medium))
                                .foregroundColor(selectedContext == contextData.context ? .white : contextData.color)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedContext == contextData.context ? contextData.color : contextData.color.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(contextData.color.opacity(selectedContext == contextData.context ? 0 : 0.3), lineWidth: 1)
                        )
                    }
                    .scaleEffect(selectedContext == contextData.context ? 1.05 : 1.0)
                }
            }
        }
    }
}

// MARK: - Emotional Context Extension

extension EmotionalContext {
    var description: String {
        switch self {
        case .excited:
            return "Ready to explore amazing options and discover something special!"
        case .focused:
            return "Looking for specific criteria and practical solutions."
        case .anxious:
            return "Want to feel secure and confident about your choices."
        case .neutral:
            return "Open to exploring different possibilities at your own pace."
        }
    }
    
    var searchHint: String {
        switch self {
        case .excited:
            return "Try: 'Show me trendy places with character and great vibes'"
        case .focused:
            return "Try: 'Find 2BR under $3000 with parking near subway'"
        case .anxious:
            return "Try: 'Show me safe, quiet neighborhoods with good reviews'"
        case .neutral:
            return "Try: 'What are some good options in my price range?'"
        }
    }
}

#Preview {
    VStack {
        EmotionalContextPicker(selectedContext: .constant(.neutral))
            .padding()
        
        Spacer()
    }
    .background(Color(.systemBackground))
}