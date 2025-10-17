// ... existing code ...
        } else {
            // Read Supabase credentials from Info.plist
            guard let supabaseURLString = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String,
                  let supabaseURL = URL(string: supabaseURLString),
                  let supabaseKey = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String,
                  !supabaseURLString.isEmpty, !supabaseKey.isEmpty
            else {
                #if DEBUG
// ... existing code ...