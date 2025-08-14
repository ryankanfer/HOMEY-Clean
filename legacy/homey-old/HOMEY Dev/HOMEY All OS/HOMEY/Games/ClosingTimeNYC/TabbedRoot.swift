
import SwiftUI

struct TabbedRoot: View {
    var body: some View {
        TabView {
            Text("HOMEY Dashboard")
                .tabItem { Label("Home", systemImage: "house.fill") }

            ScoutView() // or ScoutViewSheetStyle()
                .tabItem { Label("Scout", systemImage: "binoculars.fill") }

            GameContainerView()
                .tabItem { Label("Game", systemImage: "gamecontroller.fill") }
        }
    }
}
