import SwiftUI

@main
struct HOMEY_iOSApp: App {
    @StateObject private var session = SessionManager()
    @StateObject private var appState = AppState() // if you have one

    var body: some Scene {
        WindowGroup {
            RootProviders { RootView() }
                .environmentObject(SessionManager.shared) // or whatever you use
        }
    }
}

