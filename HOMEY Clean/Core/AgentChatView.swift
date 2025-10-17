import SwiftUI

struct AgentChatView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                ChatMessageRow(message: message)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Message Input
                HStack(spacing: 12) {
                    TextField("Type your message...", text: $messageText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...4)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(messageText.isEmpty ? .gray : .blue)
                    }
                    .disabled(messageText.isEmpty || isLoading)
                }
                .padding()
                .background(.ultraThinMaterial)
            }
            .navigationTitle("Chat with Agent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadInitialMessages()
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let userMessage = ChatMessage(
            text: messageText,
            isFromUser: true,
            timestamp: Date()
        )
        
        messages.append(userMessage)
        let currentMessage = messageText
        messageText = ""
        
        // Simulate agent response
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let agentResponse = ChatMessage(
                text: generateAgentResponse(to: currentMessage),
                isFromUser: false,
                timestamp: Date()
            )
            messages.append(agentResponse)
            isLoading = false
        }
    }
    
    private func loadInitialMessages() {
        messages = [
            ChatMessage(
                text: "Hi! I'm Sarah, your real estate agent. How can I help you today?",
                isFromUser: false,
                timestamp: Date().addingTimeInterval(-300)
            )
        ]
    }
    
    private func generateAgentResponse(to message: String) -> String {
        let responses = [
            "I'd be happy to help you with that! Let me look into some options for you.",
            "That's a great question. Based on your preferences, I have a few suggestions.",
            "I understand what you're looking for. Let me schedule a time to discuss this further.",
            "Thanks for reaching out! I'll get back to you with some personalized recommendations.",
            "I'm here to help make your home search as smooth as possible. What specific area interests you most?"
        ]
        return responses.randomElement() ?? "Thanks for your message! I'll get back to you soon."
    }
}

// MARK: - Chat Message Row
struct ChatMessageRow: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(18)
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity * 0.75, alignment: .trailing)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(18)
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity * 0.75, alignment: .leading)
                
                Spacer()
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    AgentChatView()
}