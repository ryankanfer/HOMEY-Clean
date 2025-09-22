import SwiftUI

struct FallbackUnavailableView: View {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let icon: String

    init(isPresented: Binding<Bool>, title: String, message: String, icon: String = "exclamationmark.triangle.fill") {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.icon = icon
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundColor(.orange)
                    .padding(.bottom, 4)

                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                Button {
                    isPresented = false
                } label: {
                    Text("OK")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Unavailable")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { isPresented = false }
                }
            }
        }
    }
}