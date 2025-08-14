//
//  SignInView.swift
//  HOMEY Clean
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var session: SessionManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            Text("HOMEY")
                .font(.largeTitle).bold()

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let msg = errorMessage {
                Text(msg).foregroundColor(.red)
            }

            Button {
                Task {
                    isLoading = true
                    defer { isLoading = false }
                    do {
                        try await session.signIn(email: email, password: password)
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || email.isEmpty || password.isEmpty)
            .padding(.top, 4)
        }
        .padding()
    }
}
