import SwiftUI

/// Displays a header + grid of Education docs.
/// (Renamed from `EducationCenterSection` to avoid collision with your model type.)
@MainActor
struct EducationCenterSectionView: View {
    let docs: [EducationCenterStore.Doc]
    var openEducation: () -> Void = {}
    var openDoc: (EducationCenterStore.Doc) -> Void = { _ in }

    private let grid = [GridItem(.adaptive(minimum: 160), spacing: 10)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(alignment: .firstTextBaseline) {
                Label("Education Center", systemImage: "book.fill")
                    .font(.headline)
                Spacer(minLength: 12)
                Button("Open", action: openEducation)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }

            // Content
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
                                    Text(doc.title)
                                        .lineLimit(2)
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
                            .background(
                                .ultraThinMaterial,
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text("Open \(doc.title)"))
                    }
                }
            }
        }
    }
}
