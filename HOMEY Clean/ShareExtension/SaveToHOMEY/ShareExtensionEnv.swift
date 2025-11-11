import Foundation

enum ShareExtensionEnv {
    static var projectURL: String {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String, !url.isEmpty else {
            fatalError("Missing SUPABASE_URL in Share Extension Info.plist")
        }
        return url
    }

    static var anonKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String, !key.isEmpty else {
            fatalError("Missing SUPABASE_ANON_KEY in Share Extension Info.plist")
        }
        return key
    }
}