import SwiftUI

struct ChatModal: View {
    let target: ChatTarget
    @Environment(\.dismiss) private var dismiss

    // simple message model so we can show user vs assistant bubbles later
    struct Msg: Identifiable {
        let id = UUID()
        let text: String
        let isUser: Bool
    }

    @State private var input = ""
    @State private var messages: [Msg] = [
        .init(text: "Hi! How can I help today?", isUser: false),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages
                List(messages) { m in
                    HStack {
                        if m.isUser { Spacer() }
                        Text(m.text)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(m.isUser ? Color.blue.opacity(0.12) : Color.gray.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        if !m.isUser { Spacer() }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)

                // Composer
                HStack(spacing: 8) {
                    TextField("Type a message…", text: $input, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1 ... 4)

                    Button {
                        send()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.title3)
                    }
                    .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(12)
                .background(.ultraThinMaterial)
            }
            .navigationTitle(target.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func send() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(.init(text: trimmed, isUser: true))
        input = ""

        // stub assistant reply (replace with your real chat call)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            let who = target.title.replacingOccurrences(of: "Chat · ", with: "")
            messages.append(.init(text: "\(who) is thinking…", isUser: false))
        }
    }
}
