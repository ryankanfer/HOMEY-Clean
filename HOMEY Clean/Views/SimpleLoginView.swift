import SwiftUI

struct SimpleLoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Simple Login")
                    .font(.largeTitle)
                    .padding()
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isEmailFocused)
                    .onSubmit {
                        isPasswordFocused = true
                    }
                    .submitLabel(.next)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isPasswordFocused)
                    .onSubmit {
                        print("Login attempted with email: \(email), password: \(password)")
                    }
                    .submitLabel(.go)
                
                Button("Login") {
                    print("Login button tapped with email: \(email), password: \(password)")
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SimpleLoginView()
}
