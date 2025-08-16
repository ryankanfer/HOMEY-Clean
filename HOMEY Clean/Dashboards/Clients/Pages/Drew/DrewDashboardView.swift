import SwiftUI

public struct DrewDashboardView: View {
    public init() {}
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Drew").font(.title2.bold())
                Text("Trusted pros").foregroundStyle(.secondary)
                // Drop legacy Drew UI here
                Label("Lenders", systemImage: "banknote.fill")
                Label("Inspectors", systemImage: "stethoscope")
                Label("Movers", systemImage: "truck.box.fill")
            }
            .padding()
        }
    }
}