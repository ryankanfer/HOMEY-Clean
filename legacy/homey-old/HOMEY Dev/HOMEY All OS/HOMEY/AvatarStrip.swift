import SwiftUI

struct AvatarStrip: View {
    let homeys: [HomeyKind]
    @Binding var selected: HomeyKind?
    var onLongPress: (HomeyKind) -> Void = { _ in } // <— callback for chat
    var onTap: (HomeyKind) -> Void = { _ in } // <— callback for tap

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(homeys) { h in
                    VStack(spacing: 6) {
                        Image(h.assetName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 54, height: 54)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(selected == h ? Color.accentColor : .clear, lineWidth: 2)
                            )
                            .shadow(color: selected == h ? .accentColor.opacity(0.35) : .clear, radius: 6)

                        Text(h.displayName)
                            .font(.caption2)
                            .foregroundColor(selected == h ? .accentColor : .primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .contentShape(Rectangle()) // make the whole cell tappable
                    .onTapGesture {
                        selected = h
                        onTap(h)
                    } // select on tap and call onTap
                    .highPriorityGesture( // long-press for chat
                        LongPressGesture(minimumDuration: 0.35)
                            .onEnded { _ in
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                onLongPress(h)
                            }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
    }
}
