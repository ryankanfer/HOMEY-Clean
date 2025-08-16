//
//  ChatModal.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//


import SwiftUI

struct ChatModal: View {
    let target: ChatTarget
    @Environment(\.dismiss) private var dismiss

    struct Msg: Identifiable {
        let id = UUID()
        let text: String
        let isUser: Bool
    }

    @State private var input = ""
    @State private var messages: [Msg] = [
        .init(text: "Hi! How can I help today?", isUser: false)
    ]

    init(target: ChatTarget) {
        self.target = target
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List(messages) { m in
                    HStack {
                        if m.isUser { Spacer() }
                        Text(m.text)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(m.isUser ? Color.blue.opacity(0.12) : Color.gray.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        if !m.isUser { Spacer() }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)

                HStack(spacing: 8) {
                    TextField("Type a message…", text: $input, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...4)

                    Button {
                        send()
                    } label: {
                        Image(systemName: "paperplane.fill").font(.title3)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            switch target {
            case .agent:
                messages.append(.init(text: "Your agent is typing…", isUser: false))
            case .homey(let kind):
                messages.append(.init(text: "\(kind.displayName) is thinking…", isUser: false))
            }
        }
    }
}
