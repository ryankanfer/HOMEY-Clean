import SwiftUI

struct DashboardHeader: View {
    @EnvironmentObject var session: SessionManager
    var title: String
    var subtitle: String?

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 34, weight: .bold))
                if let subtitle {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button("Log out") {
                Task {
                    await session.logout()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial)
    }
}
