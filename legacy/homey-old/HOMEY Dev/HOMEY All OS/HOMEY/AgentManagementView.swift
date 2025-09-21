// AgentManagementView.swift
// Full-featured CRUD management for agents (table + actions, stub for now)
import SwiftUI

struct REAgent: Identifiable {
    let id: UUID
    var name: String
    var email: String
    var referralCode: String
    var clientCount: Int
    var active: Bool
}

struct AgentManagementView: View {
    @State private var agents: [REAgent] = [
        REAgent(
            id: UUID(),
            name: "Alice Johnson",
            email: "alice@example.com",
            referralCode: "REF123",
            clientCount: 12,
            active: true
        ),
        REAgent(
            id: UUID(),
            name: "Bob Smith",
            email: "bob@example.com",
            referralCode: "REF456",
            clientCount: 8,
            active: false
        ),
        REAgent(
            id: UUID(),
            name: "Carol White",
            email: "carol@example.com",
            referralCode: "REF789",
            clientCount: 15,
            active: true
        ),
    ]
    @State private var showCreateEdit = false
    @State private var editingAgent: REAgent? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Agent Management")
                    .font(.largeTitle.bold())
                Spacer()
                Button("Create Agent") {
                    editingAgent = nil
                    showCreateEdit = true
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 10)

            List {
                ForEach($agents) { $agent in
                    HStack(spacing: 14) {
                        Text(agent.name).bold()
                        Text(agent.email).font(.subheadline).foregroundStyle(Theme.textMuted)
                        Text(agent.referralCode).font(.caption).foregroundColor(.purple)
                        Text("Clients: \(agent.clientCount)")
                            .font(.caption2).foregroundColor(.gray)
                        Toggle("Active", isOn: $agent.active)
                            .labelsHidden()
                        Button(action: {
                            editingAgent = agent
                            showCreateEdit = true
                        }) {
                            Image(systemName: "pencil")
                        }
                        Button(role: .destructive, action: {
                            if let index = agents.firstIndex(where: { $0.id == agent.id }) {
                                agents.remove(at: index)
                            }
                        }) {
                            Image(systemName: "trash")
                        }
                        Button(action: {
                            // View as agent action stub
                        }) {
                            Image(systemName: "eye")
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .sheet(isPresented: $showCreateEdit) {
            AgentCreateEditView(agent: $editingAgent, agents: $agents)
        }
        .padding()
    }
}

struct AgentCreateEditView: View {
    @Binding var agent: REAgent?
    @Binding var agents: [REAgent]

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var referralCode: String = ""
    @State private var clientCount: String = "0"
    @State private var active: Bool = true

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text(agent == nil ? "Create Agent" : "Edit Agent")
                .font(.headline)
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            let emailField = TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            #if os(iOS)
                emailField
                    .keyboardType(.emailAddress)
            #else
                emailField
            #endif

            TextField("Referral Code", text: $referralCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            let clientCountField = TextField("Client Count", text: $clientCount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            #if os(iOS)
                clientCountField
                    .keyboardType(.numberPad)
            #else
                clientCountField
            #endif

            Toggle("Active", isOn: $active)
            HStack {
                Button("Save") {
                    let count = Int(clientCount) ?? 0
                    if var existingAgent = agent {
                        // Edit existing agent
                        if let index = agents.firstIndex(where: { $0.id == existingAgent.id }) {
                            agents[index].name = name
                            agents[index].email = email
                            agents[index].referralCode = referralCode
                            agents[index].clientCount = count
                            agents[index].active = active
                        }
                    } else {
                        // Create new agent
                        let newAgent = REAgent(
                            id: UUID(),
                            name: name,
                            email: email,
                            referralCode: referralCode,
                            clientCount: count,
                            active: active
                        )
                        agents.append(newAgent)
                    }
                    dismiss()
                }
                .buttonStyle(.borderedProminent)

                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.red)
            }
        }
        .padding()
        .frame(width: 340)
        .onAppear {
            if let agent = agent {
                name = agent.name
                email = agent.email
                referralCode = agent.referralCode
                clientCount = String(agent.clientCount)
                active = agent.active
            } else {
                name = ""
                email = ""
                referralCode = ""
                clientCount = "0"
                active = true
            }
        }
    }
}
