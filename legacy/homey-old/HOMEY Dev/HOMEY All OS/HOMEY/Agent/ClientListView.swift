import SwiftUI

struct AppClient: Identifiable {
    let id = UUID()
    let fullName: String
    let journeyStage: String
}

struct ClientListView: View {
    let clients: [AppClient] = [
        AppClient(fullName: "Alex Rivera", journeyStage: "Interview Scheduled"),
        AppClient(fullName: "Jamie Lin", journeyStage: "Application Submitted"),
        AppClient(fullName: "Morgan Patel", journeyStage: "Board Approval"),
    ]
    var body: some View {
        VStack(alignment: .leading) {
            Text("Active Clients").font(.headline)
            List(clients) { client in
                VStack(alignment: .leading) {
                    Text(client.fullName).bold()
                    Text(client.journeyStage).font(.caption)
                }
            }
            .frame(height: 180) // Prevents taking over the whole screen
        }
        .padding()
    }
}
