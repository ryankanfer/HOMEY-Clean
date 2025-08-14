import SwiftUI

struct EducationCenterSectionList<Section>: View {
    let sections: [Section]
    var tap: (Section) -> Void
    var title: (Section) -> String

    init(
        sections: [Section],
        tap: @escaping (Section) -> Void,
        title: @escaping (Section) -> String = { String(describing: $0) }
    ) {
        self.sections = sections
        self.tap = tap
        self.title = title
    }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                Button {
                    tap(section)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "book").imageScale(.medium).opacity(0.7)
                        Text(title(section)).font(.body).foregroundStyle(.primary).lineLimit(2)
                        Spacer()
                        Image(systemName: "chevron.right").imageScale(.small).opacity(0.35)
                    }
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
