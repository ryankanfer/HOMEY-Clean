import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        let headers = [
            "X-Client-Info": "supabase-swift/2.7.0"
        ]

        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://mzqswvyfnblghgvcgxpw.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im16cXN3dnlmbmJsZ2hndmNneHB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNjY0NzIsImV4cCI6MjA3MzY0MjQ3Mn0.0Tu75LEAY04Z1kbt98NJbXtYl3a_ChWA7qEEwWRauo0",
            options: .init(
                auth: .init(
                    storage: KeychainLocalStorage(
                        service: "com.homey.app.supabase",
                        accessGroup: "group.com.homey.app.sharing"
                    ),
                    // Opt-in to the new initial session behavior to avoid advisory:
                    emitLocalSessionAsInitialSession: true
                ),
                global: .init(
                    headers: headers
                )
            )
        )
    }
}
