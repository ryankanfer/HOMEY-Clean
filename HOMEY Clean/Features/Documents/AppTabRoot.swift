import SwiftUI
import ClientView
import AgentView
import DocumentsView
import DocumentsViewModel
import DocumentsRepository

struct ContentView: View {
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            ClientView()
                .tabItem {
                    Label("Client", systemImage: "person")
                }
                .tag(0)

            AgentView()
                .tabItem {
                    Label("Agent", systemImage: "person.2")
                }
                .tag(1)

            DocumentsView(vm: DocumentsViewModel(repo: DocumentsRepository(client: AppServices.supabase)))
                .tabItem {
                    Label("Documents", systemImage: "doc.richtext")
                }
                .tag(2)
        }
    }
}
