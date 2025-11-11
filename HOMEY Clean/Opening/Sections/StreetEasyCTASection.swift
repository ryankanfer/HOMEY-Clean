import SwiftUI

struct StreetEasyCTASection: View {
    let mergedFilters: LocalSearchFilters
    let canOpenStreetEasy: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                if let url = StreetEasyDeepLinkBuilder.searchURL(from: mergedFilters, query: nil) {
                    StreetEasyDeepLinkBuilder.open(url: url)
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.up.right.square")
                        .imageScale(.medium)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Search on StreetEasy")
                            .font(.callout.weight(.semibold))

                        Text("We’ll open a StreetEasy search using your HOMEY brief.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.primaryAction)
            .disabled(!canOpenStreetEasy)

            Text("You’ll browse on StreetEasy – your notes, saves, and next steps live in HOMEY.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}