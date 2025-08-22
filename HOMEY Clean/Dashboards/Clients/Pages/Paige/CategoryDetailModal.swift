//
//  CategoryDetailModal.swift
//  HOMEY Clean
//
//  Detailed modal view for document categories
//

import SwiftUI

struct CategoryDetailModal: View {
    let category: DocumentCategory
    @Binding var isPresented: Bool
    let onAddDocument: () -> Void

    @State private var showAddDocumentSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with progress
                    headerSection

                    // Document list
                    documentListSection

                    // Microcopy section
                    microcopySection

                    Spacer(minLength: 100) // Space for floating button
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(
                LinearGradient(
                    colors: [
                        category.color.opacity(0.05),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle(category.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .fontWeight(.medium)
                }
            }
            .overlay(alignment: .bottom) {
                // Floating Add Document Button
                addDocumentButton
            }
        }
        .sheet(isPresented: $showAddDocumentSheet) {
            AddDocumentSheet(category: category)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Category icon and info
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    category.color.opacity(0.3),
                                    category.color.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 40
                            )
                        )
                        .frame(width: 60, height: 60)

                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                        )

                    Image(systemName: category.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(category.color)
                        .symbolRenderingMode(.hierarchical)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.custom("PlayfairDisplay-Regular", size: 24))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text("\(category.documents.count) documents")
                        .font(.custom("Lato-Regular", size: 14))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.custom("Lato-Regular", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(Int(category.progress * 100))%")
                        .font(.custom("Lato-Regular", size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .monospacedDigit()
                }

                ProgressView(value: category.progress)
                    .progressViewStyle(CustomProgressViewStyle(color: category.color))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
    }

    // MARK: - Document List Section

    private var documentListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Documents")
                .font(.custom("PlayfairDisplay-Regular", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            if category.documents.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(category.documents) { document in
                        DocumentRow(document: document, categoryColor: category.color)
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 40))
                .foregroundStyle(Color.secondary)

            Text("No documents yet")
                .font(.custom("Lato-Regular", size: 16))
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            Text("Add your first document to get started")
                .font(.custom("Lato-Regular", size: 14))
                .foregroundColor(Color.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(0.05), lineWidth: 1)
                )
        )
    }

    // MARK: - Microcopy Section

    private var microcopySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What qualifies?")
                .font(.custom("PlayfairDisplay-Regular", size: 18))
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text(microcopyText)
                .font(.custom("Lato-Regular", size: 14))
                .foregroundColor(.secondary)
                .lineSpacing(2)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(0.05), lineWidth: 1)
                )
        )
    }

    // MARK: - Add Document Button

    private var addDocumentButton: some View {
        Button {
            showAddDocumentSheet = true
            HapticManager.shared.impact(.medium)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))

                Text("Add Document")
                    .font(.custom("Lato-Regular", size: 16))
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                category.color,
                                category.color.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: category.color.opacity(0.3), radius: 12, x: 0, y: 6)
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 34) // Account for safe area
    }

    // MARK: - Microcopy Text

    private var microcopyText: String {
        switch category.name {
        case "Financial Records":
            return "Bank statements, tax returns, credit reports, investment accounts, loan documents, and other financial records from the past 2-3 years."
        case "Identity & Legal":
            return "Driver's license, passport, Social Security card, birth certificate, marriage certificate, and other government-issued identification."
        case "Property History":
            return "Lease agreements, rental history, property deeds, mortgage documents, and records of previous addresses."
        case "Employment":
            return "Pay stubs, W-2 forms, employment letters, offer letters, and documentation of your work history and income."
        case "Insurance":
            return "Health, auto, renters, life insurance policies, and coverage documentation that shows your responsibility and protection."
        case "References":
            return "Contact information and letters from previous landlords, employers, personal references, and character witnesses."
        default:
            return "Upload relevant documents that support your application and demonstrate your qualifications."
        }
    }
}

// MARK: - Document Row

struct DocumentRow: View {
    let document: Document
    let categoryColor: Color

    var body: some View {
        HStack(spacing: 16) {
            // Document type icon
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.1))
                    .frame(width: 40, height: 40)

                Image(systemName: documentTypeIcon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(categoryColor)
            }

            // Document info
            VStack(alignment: .leading, spacing: 4) {
                Text(document.name)
                    .font(.custom("Lato-Regular", size: 15))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(document.type.rawValue)
                        .font(.custom("Lato-Regular", size: 12))
                        .foregroundColor(.secondary)

                    Text("•")
                        .font(.custom("Lato-Regular", size: 12))
                        .foregroundColor(Color.secondary)

                    Text(document.size)
                        .font(.custom("Lato-Regular", size: 12))
                        .foregroundColor(.secondary)

                    Text("•")
                        .font(.custom("Lato-Regular", size: 12))
                        .foregroundColor(Color.secondary)

                    Text(document.uploadedDate, style: .date)
                        .font(.custom("Lato-Regular", size: 12))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Status badge
            statusBadge
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.white.opacity(0.05), lineWidth: 1)
                )
        )
    }

    private var documentTypeIcon: String {
        return document.systemIcon
    }

    private var statusBadge: some View {
        Text(document.status)
            .font(.custom("Lato-Regular", size: 11))
            .fontWeight(.medium)
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(statusColor.opacity(0.1))
            )
    }

    private var statusColor: Color {
        return document.statusColor
    }
}

// MARK: - Custom Progress View Style

struct CustomProgressViewStyle: ProgressViewStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(height: 8)

                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                color,
                                color.opacity(0.7)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * CGFloat(configuration.fractionCompleted ?? 0),
                        height: 8
                    )
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: configuration.fractionCompleted)
            }
        }
        .frame(height: 8)
    }
}

// MARK: - Add Document Sheet Placeholder

struct AddDocumentSheet: View {
    let category: DocumentCategory
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "doc.badge.plus")
                    .font(.system(size: 60))
                    .foregroundStyle(category.color)

                Text("Add Document")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Document upload flow will be implemented here.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Add to \(category.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
