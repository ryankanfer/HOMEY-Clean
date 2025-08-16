//
//  LoginView.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/13/25.
//


import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Sign in to HOMEY")
                    .font(.title)
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                SecureField("Password", text: $password)
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                if let msg = errorMessage {
                    Text(msg).foregroundStyle(.red)
                }

                Button {
                    Task {
                        await signIn()
                    }
                } label: {
                    HStack {
                        if isLoading { ProgressView() }
                        Text("Sign In")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                .padding(.top, 8)

                HStack {
                    Text("New here?")
                        .foregroundStyle(.secondary)
                    NavigationLink("Create account") {
                        SignupView()
                    }
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding()
            .navigationTitle("Login")
        }
    }

    @MainActor
    private func signIn() async {
        errorMessage = nil
        isLoading = true
        do {
            try await session.signIn(email: email, password: password)
        } catch {
            errorMessage = "Couldn’t sign in. Try again."
        }
        isLoading = false
    }
}

