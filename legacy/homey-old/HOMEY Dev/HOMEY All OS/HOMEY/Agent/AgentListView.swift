// AgentListView.swift
// SwiftUI view for listing agents

import SwiftUI

struct AgentListView: View {
    @State private var agents: [Agent] = []
    @State private var isLoading: Bool = false
    @State private var error: String?
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading agents...")
                } else if let error = error {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                } else {
                    List(agents) { agent in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(agent.name)
                                    .font(.headline)
                                if !agent.active {
                                    Text("Inactive")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.red.opacity(0.11))
                                        .cornerRadius(8)
                                }
                            }
                            Text(agent.email)
                                .font(.subheadline)
                                .foregroundStyle(Theme.textMuted)
                            HStack(spacing: 16) {
                                Text("Referrer: \(agent.referrer_code)")
                                    .font(.caption)
                                    .foregroundColor(.purple)
                                Text("Clients: \(agent.client_count)")
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Agents")
            .toolbar {
                Button("Refresh") { fetchAgents() }
            }
        }
        .onAppear {
            fetchAgents()
        }
    }
    
    private func fetchAgents() {
        isLoading = true
        error = nil
        Task {
            do {
                let fetched = try await AgentService.shared.fetchAgents()
                agents = fetched
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }
}

