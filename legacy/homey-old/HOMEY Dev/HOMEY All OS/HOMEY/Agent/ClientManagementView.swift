// ClientManagementView.swift
// Stub for managing clients (table layout, ready for expansion)
import SwiftUI

struct ManagedClient: Identifiable {
    let id: UUID
    let name: String
    let email: String
    let status: String
}

struct ClientManagementView: View {
    @State private var clients: [ManagedClient] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Client Management")
                .font(.largeTitle.bold())
                .padding(.top, 10)
            List {
                ForEach(clients) { client in
                    HStack {
                        Text(client.name).bold()
                        Text(client.email).foregroundColor(.gray)
                        Text(client.status)
                            .font(.caption2)
                            .foregroundColor(client.status == "Active" ? .green : .red)
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}
