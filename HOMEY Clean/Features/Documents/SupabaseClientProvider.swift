//  SupabaseClientProvider.swift
//  HOMEY Clean
//
//  Centralized Supabase client configuration. For production, consider moving
//  secrets to a secure store and using environment-specific configs.

import Foundation
import Supabase

enum SupabaseConfig {
    static let url = URL(string: "https://mzqswvyfnblghgvcgxpw.supabase.co")!
    // IMPORTANT: This is the public anon key. Do NOT include the service role key in the app.
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im16cXN3dnlmbmJsZ2hndmNneHB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgwNjY0NzIsImV4cCI6MjA3MzY0MjQ3Mn0.0Tu75LEAY04Z1kbt98NJbXtYl3a_ChWA7qEEwWRauo0"
}

enum SupabaseClientProvider {
    static let client: SupabaseClient = {
        let client = SupabaseClient(supabaseURL: SupabaseConfig.url, supabaseKey: SupabaseConfig.anonKey)
        return client
    }()
}
