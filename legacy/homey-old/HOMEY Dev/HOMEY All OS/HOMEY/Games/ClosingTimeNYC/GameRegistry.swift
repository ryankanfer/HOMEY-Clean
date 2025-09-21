
import SwiftUI

enum GameType: Hashable {
    case closingTimeNYC
}

enum GameAssignment {
    static let forHomey: [String: GameType] = [
        "Scout": .closingTimeNYC,
    ]
}

struct ClosingTimeGameView: View {
    var body: some View {
        GameContainerView()
    }
}

struct GameHostView: View {
    let game: GameType
    var body: some View {
        switch game {
        case .closingTimeNYC:
            ClosingTimeGameView()
        }
    }
}
