import SwiftUI
#if canImport(Supabase)
import Supabase
#endif

@main
struct HOMEY_CleanApp: App {
    @StateObject private var appState = AppState()

    private let sessionManager: SessionManager = {
        #if DEBUG
        let auth: AuthProviding = FakeAuthManager()
        let profiles: ProfilesProviding = FakeProfilesService()
        #else
        let auth = try! RealSupabaseAuthManager()
        #if canImport(Supabase)
        let profiles = RealSupabaseProfilesService(client: auth.client)
        #else
        let profiles = FakeProfilesService()
        #endif
        #endif
        return SessionManager(auth: auth, profiles: profiles)
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(sessionManager)
        }
    }
}
