import Foundation

// A small helper for accessing critical project environment values from a separate Supabase-Info.plist
public enum Env {
    private static let info: [String: Any]? = {
        guard let path = Bundle.main.path(forResource: "Supabase-Info", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            print("❌ Supabase-Info.plist not found. Please create one with SUPABASE_URL and SUPABASE_ANON_KEY.")
            return nil
        }
        return dict
    }()

    /// The Supabase project URL, from Supabase-Info.plist key SUPABASE_URL
    public static var projectURL: String {
        guard let url = info?["SUPABASE_URL"] as? String, !url.isEmpty, url != "YOUR_SUPABASE_URL" else {
            print("🛑 Missing or placeholder SUPABASE_URL in Supabase-Info.plist")
            return ""
        }
        return url
    }

    /// The Supabase anon key, from Supabase-Info.plist key SUPABASE_ANON_KEY
    public static var anonKey: String {
        guard let key = info?["SUPABASE_ANON_KEY"] as? String, !key.isEmpty, key != "YOUR_SUPABASE_ANON_KEY" else {
            print("🛑 Missing or placeholder SUPABASE_ANON_KEY in Supabase-Info.plist")
            return ""
        }
        return key
    }
}