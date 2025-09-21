import Foundation
import Supabase

enum SupabaseConfig {
    static let url: URL = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let url = URL(string: urlString)
        else {
            fatalError("SUPABASE_URL not found in Info.plist")
        }
        return url
    }()

    static let anon: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String else {
            fatalError("SUPABASE_ANON_KEY not found in Info.plist")
        }
        return key
    }()

    static let client: SupabaseClient = .init(supabaseURL: url, supabaseKey: anon)
}
