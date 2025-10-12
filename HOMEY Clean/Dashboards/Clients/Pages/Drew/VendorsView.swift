//
//  VendorsView.swift
//  HOMEY Clean
//
//  Created by Ryan Kanfer on 8/18/25.
//

// VendorsView.swift
import SwiftUI

struct Vendor: Identifiable, Hashable, Decodable {
    let id = UUID()
    let name: String
    let category: String
    let blurb: String
    let contact: String?
    let website: String?
}

public struct VendorsView: View {
    @State private var vendors: [Vendor] = []
    @State private var loading = true
    @State private var errorText: String?
    // inject real values
    private let service = VendorsService()
    @State private var userJWT: String = ""

    public init() {}

    public var body: some View {
        ZStack {
            GradientBackground(theme: heroTheme(for: .drew))
            List {
                if loading { ProgressView().listRowSeparator(.hidden) }
                if let e = errorText { Text(e).foregroundStyle(.red) }
                ForEach(vendors) { v in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(v.name).font(.headline); Spacer()
                            Text(v.category).font(.caption)
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(Capsule().fill(AnyShapeStyle(.ultraThinMaterial)))
                        }
                        Text(v.blurb).font(.subheadline).foregroundStyle(.secondary)
                        if let c = v.contact, !c.isEmpty { Text(c).font(.footnote).foregroundStyle(.secondary) }
                        if let w = v.website, !w.isEmpty { Text(w).font(.footnote).foregroundStyle(.blue) }
                    }
                    .padCard()
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .navigationTitle("Vendors")
            .task { await load() }
        }
    }

    private func load() async {
        loading = true; defer { loading = false }
        do { vendors = try await service.fetch(userJWT: userJWT) } catch { errorText = "Couldn’t load vendors." }
    }
}
