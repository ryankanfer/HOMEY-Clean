import SwiftUI

struct AdminRoleSwitcher: ToolbarContent {
    @EnvironmentObject var session: SessionManager

    var body: some ToolbarContent {
        // Only show for real admins
        if (session.userRole ?? "").lowercased() == "admin" {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        session.activeRole = "admin"
                    } label: {
                        Label(
                            "Admin",
                            systemImage: session.effectiveRole == "admin" ? "checkmark.circle.fill" : "circle"
                        )
                    }

                    Button {
                        session.activeRole = "agent"
                    } label: {
                        Label(
                            "Agent",
                            systemImage: session.effectiveRole == "agent" ? "checkmark.circle.fill" : "circle"
                        )
                    }

                    Button {
                        session.activeRole = "client"
                    } label: {
                        Label(
                            "Client",
                            systemImage: session.effectiveRole == "client" ? "checkmark.circle.fill" : "circle"
                        )
                    }
                } label: {
                    Label("Mode", systemImage: "person.crop.square.filled.and.at.rectangle")
                }
            }
        }
    }
}
