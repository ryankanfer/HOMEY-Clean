import SwiftUI

struct AgentLiveContent: View {
    @State private var onlineAgents = ["J", "M", "S", "L"]
    @State private var offlineAgents = ["A", "T"]
    @State private var approvalCount = 6
    @State private var filters = ["Active", "Pending", "Rejected"]
    @State private var selectedFilter = "Active"

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: -8) {
                    ForEach(onlineAgents, id: \.self) {
                        Circle()
                            .fill(Color.green.opacity(0.7))
                            .frame(width: 24, height: 24)
                            .overlay(Text($0).font(.caption.bold()).foregroundColor(.white))
                    }
                }
                Text("\(onlineAgents.count) online")
                    .font(.footnote.bold())
                    .foregroundColor(.green)

                Spacer()

                HStack(spacing: -8) {
                    ForEach(offlineAgents, id: \.self) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 24, height: 24)
                            .overlay(Text($0).font(.caption.bold()).foregroundColor(.gray))
                    }
                }
                Text("\(offlineAgents.count) offline")
                    .font(.footnote.bold())
                    .foregroundColor(.gray)
            }

            HStack(spacing: 12) {
                Label("\(approvalCount) Approvals", systemImage: "checkmark.seal.fill")
                    .font(.footnote.bold())
                    .foregroundColor(.accentColor)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.self) { filter in
                            Text(filter)
                                .font(.caption2.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(selectedFilter == filter ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.15))
                                .foregroundColor(selectedFilter == filter ? .accentColor : .secondary)
                                .clipShape(Capsule())
                                .onTapGesture {
                                    selectedFilter = filter
                                }
                        }
                    }
                }
            }
        }
    }
}
