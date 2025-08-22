// ClientHomeView.swift
// Simple placeholder for client home page
import SwiftUI

struct ClientHomeView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "house.fill")
                .resizable()
                .frame(width: 72, height: 72)
                .foregroundColor(.purple)
            Text("Welcome, Client!")
                .font(.largeTitle.bold())
            Text("This is your client dashboard home.")
                .foregroundStyle(Theme.textMuted)
        }
        .padding()
    }
}
