import SwiftUI
#if canImport(Supabase)
import Supabase
#endif

@main
struct HOMEY_CleanApp: App {
    @StateObject private var flags = FeatureFlags()

    #if canImport(Supabase)
    private let supabase: SupabaseClient
    @StateObject private var session: AppSessionManager

    init() {
        // Read from Info.plist to avoid hardcoding secrets in source.
        let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
        let anonKey   = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String

        #if DEBUG
        // In Debug, provide a harmless fallback so the app can still launch UI without crashing.
        let fallbackURL = URL(string: "https://example.supabase.co")!
        let client: SupabaseClient
        if let u = urlString, let url = URL(string: u), let key = anonKey, !key.isEmpty {
            client = SupabaseClient(supabaseURL: url, supabaseKey: key)
        } else {
            print("[HOMEY] Missing SUPABASE_URL / SUPABASE_ANON_KEY in Info.plist. Using DEBUG fallback client.")
            client = SupabaseClient(supabaseURL: fallbackURL, supabaseKey: "debug-key")
        }
        self.supabase = client
        _session = StateObject(wrappedValue: AppSessionManager(client: client))
        #else
        // In Release, be strict: if config is missing, crash early with a clear message.
        guard let u = urlString, let url = URL(string: u), let key = anonKey, !key.isEmpty else {
            fatalError("SUPABASE_URL or SUPABASE_ANON_KEY missing in Info.plist")
        }
        let client = SupabaseClient(supabaseURL: url, supabaseKey: key)
        self.supabase = client
        _session = StateObject(wrappedValue: AppSessionManager(client: client))
        #endif
    }
    #else
    @StateObject private var session = AppSessionManager()
    #endif

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .environmentObject(flags)
                .task { await session.restoreIfPossible() }
        }
    }
}
