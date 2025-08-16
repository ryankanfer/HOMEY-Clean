import SwiftUI

@MainActor
public struct EducationCenterSectionView: View {
    public let docs: [EducationCenterStoreDoc]
    public var openEducation: () -> Void
    public var openDoc: (EducationCenterStoreDoc) -> Void

    private let grid = [GridItem(.adaptive(minimum: 160), spacing: 10)]

    public init(
        docs: [EducationCenterStoreDoc],
        openEducation: @escaping () -> Void = {},
        openDoc: @escaping (EducationCenterStoreDoc) -> Void = { _ in }
    ) {
        self.docs = docs
        self.openEducation = openEducation
        self.openDoc = openDoc
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Label("Education Center", systemImage: "book.fill")
                    .font(.headline)
                Spacer(minLength: 12)
                Button("Open", action: openEducation)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }

            if docs.isEmpty {
                Text("We’ll surface quick reads here as they’re ready.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                LazyVGrid(columns: grid, spacing: 10) {
                    ForEach(docs) { doc in
                        Button { openDoc(doc) } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "book.pages.fill")
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(doc.title).lineLimit(2)
                                    if let sub = doc.subtitle, !sub.isEmpty {
                                        Text(sub).font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .imageScale(.small)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text("Open \(doc.title)"))
                    }
                }
            }
        }
    }
}

public struct EducationCenterStoreDoc: Identifiable, Hashable {
    public let id: UUID
    public var title: String
    public var subtitle: String?

    public init(id: UUID = .init(), title: String, subtitle: String? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }
}