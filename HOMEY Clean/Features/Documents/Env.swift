import Foundation

// A small helper for accessing critical project environment values from Info.plist
public enum Env {
    /// The Supabase project URL, from Info.plist key SUPABASE_URL
    public static var projectURL: String {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String, !url.isEmpty else {
            fatalError("Missing or empty SUPABASE_URL in Info.plist")
        }
        return url
    }

    /// The Supabase anon key, from Info.plist key SUPABASE_ANON_KEY
    public static var anonKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String, !key.isEmpty else {
            fatalError("Missing or empty SUPABASE_ANON_KEY in Info.plist")
        }
        return key
    }
}
