import SwiftUI
#if canImport(Supabase)
import Supabase
#endif

@main
struct HOMEY_CleanApp: App {
    @StateObject private var appState = AppState()

    private let sessionManager: SessionManager = {
        #if DEBUG
        let profiles: ProfilesProviding = FakeProfilesService()
        return SessionManager(profiles: profiles)
        #else
        let auth = try! RealSupabaseAuthManager()
        let profiles = RealSupabaseProfilesService(client: auth.client)
        return SessionManager(client: auth.client, profiles: profiles)
        #endif
    }()

    var body: some Scene {
        WindowGroup {
            // Example inside HOMEY_CleanApp.swift or wherever you create the root:
            RootView()
                .environmentObject(sessionManager)
                .journeyWatched()
        }
    }
}
