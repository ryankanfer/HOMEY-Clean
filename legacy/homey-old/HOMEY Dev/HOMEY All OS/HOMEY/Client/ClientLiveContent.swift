import SwiftUI

struct ClientLiveContent: View {
    @State private var newUsers = ["Amy", "Brian", "Cara", "Derek"]
    @State private var assignedAgent = "Sam R."

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("New Users:")
                .font(.footnote.bold())
                .foregroundColor(.accentColor)

            HStack(spacing: 10) {
                ForEach(newUsers, id: \.self) {
                    Text($0.prefix(1))
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(.blue))
                }
                Spacer()
            }

            Text("Assigned Agent: \(assignedAgent)")
                .font(.footnote)
                .foregroundStyle(Theme.textMuted)
        }
    }
}
