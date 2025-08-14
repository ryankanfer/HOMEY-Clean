
import SwiftUI

struct ScoutViewSheetStyle: View {
    @State private var showGame = false

    var body: some View {
        List {
            Section("Play") {
                Button {
                    showGame = true
                } label: {
                    HStack {
                        Image(systemName: "gamecontroller.fill")
                        Text("Play Closing Time: NYC")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote).opacity(0.4)
                    }
                }
            }
        }
        .navigationTitle("Scout")
        .sheet(isPresented: $showGame) {
            NavigationStack {
                GameHostView(game: .closingTimeNYC)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Close") { showGame = false }
                        }
                    }
            }
            .presentationCornerRadius(24)
            .presentationDetents([.large])
        }
    }
}
