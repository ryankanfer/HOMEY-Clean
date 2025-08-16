//
//  ImpersonateBar.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/15/25.
//


struct ImpersonateBar: View {
    @State private var userId = ""
    let openAsClient: (String) -> Void
    let openAsAgent: (String) -> Void

    var body: some View {
        HStack {
            TextField("User ID or email", text: $userId)
                .textInputAutocapitalization(.none)
                .autocorrectionDisabled(true)
                .textFieldStyle(.roundedBorder)
            Menu("View as") {
                Button("Client") { openAsClient(userId) }
                Button("Agent") { openAsAgent(userId) }
            }
        }
    }
}