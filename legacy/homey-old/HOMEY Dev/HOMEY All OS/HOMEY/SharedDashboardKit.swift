import SwiftUI

// MARK: - Section header
struct SectionHeader: View {
    let title: String
    init(_ title: String) { self.title = title }
    var body: some View {
        Text(title)
            .font(.title3.bold())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 6)
    }
}

// MARK: - Card container
struct Card<Content: View>: View {
    let title: String?
    let content: Content
    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                if let title { Text(title).font(.headline) }
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
    }
}

// MARK: - Small bullet row
struct Bullet: View {
    let text: String
    let systemName: String
    init(_ text: String, systemName: String) {
        self.text = text; self.systemName = systemName
    }
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemName)
                .foregroundStyle(Color.accentColor)
            Text(text)
        }
    }
}

// MARK: - KPI tile
struct KPI: View {
    let title: String
    let value: Int
    let tint: Color
    init(_ title: String, value: Int, tint: Color) {
        self.title = title; self.value = value; self.tint = tint
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text("\(value)").font(.system(size: 34, weight: .bold))
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 18).fill(.ultraThinMaterial))
    }
}

// MARK: - One-row card
struct CardRow: View {
    let icon: String
    let title: String
    init(icon: String, title: String) { self.icon = icon; self.title = title }
    var body: some View {
        GroupBox {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                Text(title)
                Spacer()
            }
            .padding(.vertical, 6)
        }
        .padding(.horizontal)
    }
}

// MARK: - Big tappable button card
struct CardButton: View {
    var title: String
    var system: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: system)
                .padding(.vertical, 8) // <— add here
        }
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Activity row
struct ActivityRow: View {
    let symbol: String
    let text: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(.secondary)
            Text(text)
            Spacer()
        }
    }
}

// MARK: - Simple Chat sheet
struct ChatView: View {
    let homey: HomeyKind
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chatting with \(homey.displayTitle)…")
                            .font(.headline)
                            .padding(.bottom, 4)
                        Text("This is a placeholder chat view.")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                HStack {
                    TextField("Type a message…", text: $draft)
                        .textFieldStyle(.roundedBorder)
                    Button("Send") { draft = "" }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle(homey.displayTitle)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Admin referral codes (placeholder)
struct AdminInviteCodesView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("Active Codes") {
                    Label("RE-PAIGE-2025", systemImage: "key")
                    Label("RE-SCOUT-2025", systemImage: "key")
                    Label("RE-DREW-2025",  systemImage: "key")
                }
            }
            .navigationTitle("Referral Codes")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Close") { dismiss() } } }
        }
    }
}

