import SwiftUI

struct ListingsManagementView: View {
    @State private var listings: [Listing] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Listings Management")
                .font(.largeTitle.bold())
                .padding(.top, 10)

            List {
                ForEach(listings) { listing in
                    HStack {
                        Text(listing.address ?? "Unknown Address")
                            .bold()
                        Text(listing.agent ?? "Unknown Agent")
                            .foregroundColor(.purple)
                        Text(listing.status ?? "Unknown Status")
                            .font(.caption2)
                            .foregroundColor((listing.status ?? "") == "Active" ? .green : .red)
                    }
                }
            }
            .listStyle(.plain)
        }
        .padding()
    }
}

