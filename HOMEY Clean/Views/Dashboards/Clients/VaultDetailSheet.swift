import SwiftUI

struct VaultDetailSheet: View {
    let vault: DocumentVault
    @Binding var isPresented: Bool
    @State private var showUploadSheet = false
    @State private var selectedDocument: VaultDocument?
    @State private var showDocumentDetail = false

    var body: some View {
        NavigationStack {
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
                        // Vault Header
                        VaultHeaderView(vault: vault)

                        // Explanatory Text Section
                        VaultExplanationView(vault: vault)

                        // Documents List
                        VStack(spacing: 16) {
                            HStack {
                                Text("Documents")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)

                                Spacer()

                                Button("Add Document") {
                                    showUploadSheet = true
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(vault.color)
                            }

                            LazyVStack(spacing: 12) {
                                ForEach(vault.documents) { document in
                                    VaultDocumentRowView(document: document, vaultColor: vault.color) {
                                        selectedDocument = document
                                        showDocumentDetail = true
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // Vault Statistics
                        VaultStatsView(vault: vault)
                            .padding(.horizontal, 20)

                        Spacer(minLength: 50)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle(vault.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        isPresented = false
                    }
                    .foregroundColor(vault.color)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Export Vault", systemImage: "square.and.arrow.up") {
                            // Export action
                        }

                        Button("Share Vault", systemImage: "square.and.arrow.up.on.square") {
                            // Share action
                        }

                        Divider()

                        Button("Vault Settings", systemImage: "gear") {
                            // Settings action
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(vault.color)
                    }
                }
            }
        }
        .sheet(isPresented: $showUploadSheet) {
            DocumentUploadSheet(isPresented: $showUploadSheet, targetVault: vault)
        }
        .sheet(isPresented: $showDocumentDetail) {
            if let document = selectedDocument {
                DocumentDetailSheet(document: document, vaultColor: vault.color, isPresented: $showDocumentDetail)
            }
        }
    }
}

// MARK: - Vault Header View

struct VaultHeaderView: View {
    let vault: DocumentVault

    var body: some View {
        VStack(spacing: 20) {
            // Vault Icon and Info
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    vault.color.opacity(0.3),
                                    vault.color.opacity(0.1)
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: vault.icon)
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(vault.color)

                    if vault.isLocked {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.red)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.8))
                                            .frame(width: 28, height: 28)
                                    )
                            }
                        }
                        .frame(width: 120, height: 120)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(vault.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text(vault.description)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)

                    Spacer()
                }

                Spacer()
            }

            // Progress Section
            VStack(spacing: 12) {
                HStack {
                    Text("Completion Progress")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(Int(vault.completionPercentage * 100))%")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(vault.color)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 12)
                            .cornerRadius(6)

                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [vault.color.opacity(0.8), vault.color],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * vault.completionPercentage, height: 12)
                            .cornerRadius(6)
                    }
                }
                .frame(height: 12)
            }
        }
        .padding(24)
        .background(
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
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    vault.color.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Vault Explanation View

struct VaultExplanationView: View {
    let vault: DocumentVault
    
    private var explanationText: String {
        switch vault.name {
        case "Identity":
            return "Essential identity documents for verification and legal purposes. These documents establish who you are and are required for most applications and processes."
        case "Employment":
            return "Employment-related documents including pay stubs, tax forms, and work verification. These documents prove your income and employment status for financial applications."
        case "Financial Records":
            return "Bank statements, investment records, and financial documentation. These documents provide a complete picture of your financial health and history."
        case "References":
            return "Professional and personal references, recommendation letters, and contact information. These documents support your applications with third-party validation."
        case "Everything Else":
            return "Additional documents that don't fit into other categories but may be important for your specific needs. Keep miscellaneous but valuable documents organized here."
        default:
            return "Important documents for your records and applications. Keep these organized and up-to-date for easy access when needed."
        }
    }
    
    private var tips: [String] {
        switch vault.name {
        case "Identity":
            return [
                "Keep copies of both front and back of ID cards",
                "Ensure documents are current and not expired",
                "Store originals in a safe place"
            ]
        case "Employment":
            return [
                "Include recent pay stubs (last 2-3 months)",
                "Keep tax returns from previous years",
                "Update employment verification letters annually"
            ]
        case "Financial Records":
            return [
                "Include statements from all accounts",
                "Keep records for at least 7 years",
                "Organize by account type and date"
            ]
        case "References":
            return [
                "Keep contact information current",
                "Include a mix of professional and personal references",
                "Ask permission before listing someone as a reference"
            ]
        case "Everything Else":
            return [
                "Label documents clearly for easy identification",
                "Review periodically to remove outdated items",
                "Consider if items belong in other categories"
            ]
        default:
            return [
                "Keep documents organized and labeled",
                "Review and update regularly",
                "Store securely with backup copies"
            ]
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Main explanation
            VStack(alignment: .leading, spacing: 8) {
                Text("About This Category")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(explanationText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.gray)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
            
            // Tips section
            VStack(alignment: .leading, spacing: 12) {
                Text("Tips & Best Practices")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(vault.color)
                                .frame(width: 16, height: 16)
                            
                            Text(tip)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
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
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    vault.color.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Vault Document Row View

struct VaultDocumentRowView: View {
    let document: VaultDocument
    let vaultColor: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Document Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    document.status.color.opacity(0.2),
                                    document.status.color.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)

                    Image(systemName: document.type.systemIcon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(document.status.color)
                }

                // Document Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(document.type.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)

                    if let uploadDate = document.uploadDate {
                        Text("Uploaded \(uploadDate, style: .relative) ago")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                // Status and Size
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: document.status.systemIcon)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(document.status.color)

                        Text(document.status.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(document.status.color)
                    }

                    if let fileSize = document.fileSize {
                        Text(fileSize)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
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
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Vault Stats View

struct VaultStatsView: View {
    let vault: DocumentVault

    private var uploadedCount: Int {
        vault.documents.filter { $0.status == .uploaded || $0.status == .verified }.count
    }

    private var pendingCount: Int {
        vault.documents.filter { $0.status == .pending }.count
    }

    private var totalSize: String {
        let sizes = vault.documents.compactMap { $0.fileSize }
        // Simple calculation - in real app would parse actual sizes
        return "\(sizes.count * 2).\(Int.random(in: 1 ... 9)) MB"
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Vault Statistics")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                StatCardView(
                    title: "Total Documents",
                    value: "\(vault.documents.count)",
                    icon: "doc.fill",
                    color: vault.color
                )

                StatCardView(
                    title: "Uploaded",
                    value: "\(uploadedCount)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }

            HStack(spacing: 16) {
                StatCardView(
                    title: "Pending",
                    value: "\(pendingCount)",
                    icon: "clock.fill",
                    color: .orange
                )

                StatCardView(
                    title: "Total Size",
                    value: totalSize,
                    icon: "externaldrive.fill",
                    color: .blue
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
    }
}

// MARK: - Stat Card View

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
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
}