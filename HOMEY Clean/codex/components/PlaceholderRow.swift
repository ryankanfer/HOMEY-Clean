import SwiftUI

public struct PlaceholderRow: View {
    let label: String

    public init(label: String) {
        self.label = label
    }

    public var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 2).frame(width: 10, height: 10)
            Text(label)
            Spacer()
            Text("—").foregroundStyle(Theme.secondaryText)
        }
        .font(.subheadline)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 8) {
        PlaceholderRow(label: "Sample Row")
        PlaceholderRow(label: "Another Row")
        PlaceholderRow(label: "Third Row")
    }
    .padding()
}