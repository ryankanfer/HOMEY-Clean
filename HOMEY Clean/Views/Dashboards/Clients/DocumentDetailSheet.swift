import SwiftUI

struct DocumentDetailSheet: View {
    let document: VaultDocument
    let vaultColor: Color
    @Binding var isPresented: Bool

    @State private var showActionSheet = false
    @State private var showShareSheet = false
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.95),
                        Color.gray.opacity(0.1),
                        Color.black.opacity(0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Document Preview
                        DocumentPreviewView(document: document, vaultColor: vaultColor)

                        // Document Information
                        DocumentInfoView(document: document, vaultColor: vaultColor)

                        // Document Actions
                        DocumentActionsView(
                            document: document,
                            vaultColor: vaultColor,
                            onShare: { showShareSheet = true },
                            onDelete: { showDeleteAlert = true },
                            onMore: { showActionSheet = true }
                        )

                        // Document History
                        DocumentHistoryView(document: document, vaultColor: vaultColor)

                        Spacer(minLength: 50)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle(document.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        isPresented = false
                    }
                    .foregroundColor(vaultColor)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        // Edit action
                    }
                    .foregroundColor(vaultColor)
                }
            }
        }
        .confirmationDialog("Document Actions", isPresented: $showActionSheet) {
            Button("Download") {
                // Download action
            }

            Button("Duplicate") {
                // Duplicate action
            }

            Button("Move to Another Vault") {
                // Move action
            }

            Button("Export as PDF") {
                // Export action
            }

            Button("Cancel", role: .cancel) {}
        }
        .alert("Delete Document", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                // Delete action
                isPresented = false
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this document? This action cannot be undone.")
        }
        .sheet(isPresented: $showShareSheet) {
            // Share sheet would go here
            Text("Share Sheet")
        }
    }
}

// MARK: - Document Preview View

struct DocumentPreviewView: View {
    let document: VaultDocument
    let vaultColor: Color

    var body: some View {
        VStack(spacing: 16) {
            // Document Thumbnail/Preview
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)

                if document.status == .uploaded || document.status == .verified {
                    // Simulated document preview
                    VStack(spacing: 12) {
                        Image(systemName: document.type.systemIcon)
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(vaultColor)

                        Text("Document Preview")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        Text("Tap to view full document")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(.orange)

                        Text("Pending Upload")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        Text("This document needs to be uploaded")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
            }

            // Status Badge
            HStack {
                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: document.status.systemIcon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(document.status.color)

                    Text(document.status.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(document.status.color)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(document.status.color.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(document.status.color.opacity(0.5), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Document Info View

struct DocumentInfoView: View {
    let document: VaultDocument
    let vaultColor: Color

    var body: some View {
        VStack(spacing: 16) {
            Text("Document Information")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                InfoRowView(
                    title: "Document Type",
                    value: document.type.rawValue,
                    icon: document.type.systemIcon,
                    color: vaultColor
                )

                InfoRowView(
                    title: "Status",
                    value: document.status.rawValue,
                    icon: document.status.systemIcon,
                    color: document.status.color
                )

                if let fileSize = document.fileSize {
                    InfoRowView(
                        title: "File Size",
                        value: fileSize,
                        icon: "externaldrive.fill",
                        color: .blue
                    )
                }

                if let uploadDate = document.uploadDate {
                    InfoRowView(
                        title: "Upload Date",
                        value: uploadDate.formatted(date: .abbreviated, time: .shortened),
                        icon: "calendar.fill",
                        color: .green
                    )
                }

                InfoRowView(
                    title: "Document ID",
                    value: String(document.id.uuidString.prefix(8)).uppercased(),
                    icon: "number.fill",
                    color: .gray
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Info Row View

struct InfoRowView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
                .frame(width: 20)

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Document Actions View

struct DocumentActionsView: View {
    let document: VaultDocument
    let vaultColor: Color
    let onShare: () -> Void
    let onDelete: () -> Void
    let onMore: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Actions")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                ActionButtonView(
                    title: "View",
                    icon: "eye.fill",
                    color: vaultColor
                ) {
                    // View action
                }

                ActionButtonView(
                    title: "Share",
                    icon: "square.and.arrow.up.fill",
                    color: .blue
                ) {
                    onShare()
                }
            }

            HStack(spacing: 16) {
                ActionButtonView(
                    title: "Download",
                    icon: "arrow.down.circle.fill",
                    color: .green
                ) {
                    // Download action
                }

                ActionButtonView(
                    title: "More",
                    icon: "ellipsis.circle.fill",
                    color: .orange
                ) {
                    onMore()
                }
            }

            // Delete button (separate and prominent)
            Button(action: onDelete) {
                HStack(spacing: 12) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)

                    Text("Delete Document")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.red.opacity(0.1),
                                    Color.red.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Action Button View

struct ActionButtonView: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color)

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Document History View

struct DocumentHistoryView: View {
    let document: VaultDocument
    let vaultColor: Color

    private var historyItems: [DocumentHistoryItem] {
        var items: [DocumentHistoryItem] = []

        if let uploadDate = document.uploadDate {
            items.append(DocumentHistoryItem(
                title: "Document Uploaded",
                description: "Document was successfully uploaded to the vault",
                date: uploadDate,
                icon: "arrow.up.circle.fill",
                color: .blue
            ))
        }

        if document.status == .verified {
            items.append(DocumentHistoryItem(
                title: "Document Verified",
                description: "Document has been verified and approved",
                date: Date().addingTimeInterval(-3600), // 1 hour ago
                icon: "checkmark.seal.fill",
                color: .green
            ))
        }

        items.append(DocumentHistoryItem(
            title: "Document Created",
            description: "Document entry was created in the system",
            date: document.uploadDate?.addingTimeInterval(-300) ?? Date().addingTimeInterval(-86400),
            // 5 minutes before upload or 1 day ago
            icon: "plus.circle.fill",
            color: vaultColor
        ))

        return items.sorted { $0.date > $1.date }
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Document History")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                ForEach(historyItems, id: \.title) { item in
                    HistoryItemView(item: item)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Document History Item

struct DocumentHistoryItem {
    let title: String
    let description: String
    let date: Date
    let icon: String
    let color: Color
}

// MARK: - History Item View

struct HistoryItemView: View {
    let item: DocumentHistoryItem

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: item.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(item.color)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)

                Text(item.description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(item.date, style: .relative)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}
