import Supabase
import SwiftUI

@MainActor
struct AdminLoginView: View {
    @StateObject private var vm: AdminLoginViewModel
    @FocusState private var focused: Field?

    enum Field { case email, password }

    // Inject your SupabaseClient so this stays testable and doesn’t hardcode keys.
    init(supabase: SupabaseClient) {
        _vm = StateObject(wrappedValue: AdminLoginViewModel(supabase: supabase))
    }

    var body: some View {
        ZStack {
            // Optional—remove if you don’t use GlassKit
            GlassKit.Background()

            VStack(spacing: 22) {
                Image("logo_black")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .opacity(0.9)
                    .padding(.top, 16)

                Text("Admin Portal Login")
                    .font(.title2.weight(.semibold))

                GlassKit.Card {
                    VStack(spacing: 12) {
                        TextField("Email", text: $vm.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($focused, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focused = .password }

                        SecureField("Password", text: $vm.password)
                            .focused($focused, equals: .password)
                            .submitLabel(.go)
                            .onSubmit { Task { await vm.signIn() } }
                    }
                }

                Button {
                    Task { await vm.signIn() }
                } label: {
                    if vm.isLoading {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Log In").bold().frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(GlassKit.PrimaryButtonStyle(primary: true))
                .disabled(vm.isLoading || vm.email.isEmpty || vm.password.isEmpty)

                if let error = vm.error {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: 520)
        }
        .animation(.easeInOut, value: vm.isLoggedIn)
    }
}
