//
//  AuthGate.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//


import SwiftUI

struct AuthGate: View {
    var body: some View {
        NavigationStack {
            LoginView()              // your wired Login
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .principal) { Text("Sign In") } }
        }
    }
}