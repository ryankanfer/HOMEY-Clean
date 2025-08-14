// AdminShellView.swift
// Wrapping shell for admin portal with header, HOMIE logo, central nav, and user menu
import SwiftUI

struct AdminShellView<Content: View>: View {
    @EnvironmentObject var session: SessionManager
    let content: () -> Content
    @State private var selection: AdminSection? = nil
    @State private var showAccountMenu = false
    @State private var showNotifications = false
    @State private var showMessages = false
    let adminEmail = "control.homie@gmail.com"
    
    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0.16)
            content()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(white: 0.95), .white]),
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()
        )
    }
    
    var header: some View {
        HStack {
            Image("logo_black")
                .resizable()
                .frame(width: 48, height: 48)
            Text("Admin Portal")
                .font(.title2.bold())
                .padding(.leading, 8)
            Spacer()
            Group {
                navItem("Clients", .clients)
                navItem("Listings", .listings)
                navItem("Agents", .agents)
            }.padding(.horizontal, 10)
            Spacer()
            HStack(spacing: 18) {
                Button(action: { showMessages.toggle() }) {
                    Image(systemName: "envelope")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                Button(action: { showNotifications.toggle() }) {
                    Image(systemName: "bell")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                Menu {
                    Button("Settings", action: {})
                    Button("Log out") {
                        Task {
                            await session.logout()
                        }
                    }
                } label: {
                    Image(systemName: "person.crop.circle")
                        .font(.largeTitle)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 18)
        .background(Color.white.opacity(0.98))
    }
    
    func navItem(_ title: String, _ section: AdminSection) -> some View {
        Button(action: { selection = section }) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, 13)
                .padding(.vertical, 8)
                .background(selection == section ? Color.blue.opacity(0.14) : .clear)
                .cornerRadius(9)
        }
    }
}

enum AdminSection: Hashable {
    case clients, listings, agents
}