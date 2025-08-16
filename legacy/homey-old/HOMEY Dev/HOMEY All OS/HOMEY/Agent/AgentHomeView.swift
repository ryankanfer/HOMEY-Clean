// AgentHomeView.swift
// Simple placeholder for agent home page
import SwiftUI

struct AgentHomeView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.crop.rectangle.badge.checkmark")
                .resizable()
                .frame(width: 72, height: 72)
                .foregroundTheme.primary
            Text("Welcome, Agent!")
                .font(.largeTitle.bold())
            Text("This is your agent dashboard home.")
                .foregroundStyle(Theme.textMuted)
        }
        .padding()
    }
}
