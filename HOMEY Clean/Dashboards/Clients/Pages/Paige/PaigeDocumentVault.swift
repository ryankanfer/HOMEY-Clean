//
//  PaigeDocumentVault.swift
//  HOMEY Clean
//
//  Document Vault - Paige's warm, inviting archive with frosted-glass "plates"
//

import Foundation
import SwiftUI

// MARK: - Data Models

public struct DocumentCategory: Identifiable {
    public let id = UUID()
    public let name: String
    public let icon: String
    public let color: Color
    public let progress: Double
    public let documents: [Document]

    var hasCriticalMissingDocs: Bool {
        documents.contains { $0.isCritical && $0.status != "Uploaded" }
    }

    public var isLocked: Bool {
        progress < 1.0
    }

    public var documentCount: Int {
        documents.count
    }

    public var isCritical: Bool {
        hasCriticalMissingDocs
    }
}

public struct Document: Identifiable {
    public let id: String
    public let name: String
    public let type: String // Changed from DocumentType to String
    public let size: String
    public let status: String // Changed from DocumentStatus to String
    public let uploadedDate: Date
    public let isCritical: Bool

    var systemIcon: String {
        switch type {
        case "Bank Statement":
            return "building.columns.fill"
        case "Tax Return":
            return "doc.text.fill"
        case "Pay Stub":
            return "dollarsign.square.fill"
        case "Driver's License":
            return "car.fill"
        case "Employment Letter":
            return "briefcase.fill"
        default:
            return "doc.fill"
        }
    }

    var statusColor: Color {
        switch status {
        case "Uploaded":
            return .blue
        case "Verified":
            return .green
        case "Pending":
            return .orange
        case "Rejected":
            return .red
        default:
            return .gray
        }
    }

    var displayName: String {
        return status
    }
}

// MARK: - Main Document Vault View

struct PaigeDocumentVault: View {
    @State private var categories: [DocumentCategory] = [
        DocumentCategory(
            name: "Financial Records",
            icon: "building.columns.fill",
            color: Color(hex: "2ECC71"),
            progress: 0.75,
            documents: [
                Document(
                    id: "1",
                    name: "Bank Statement - January 2024",
                    type: "Bank Statement",
                    size: "2.4 MB",
                    status: "Uploaded",
                    uploadedDate: Date(),
                    isCritical: false
                ),
                Document(
                    id: "2",
                    name: "Tax Return 2023",
                    type: "Tax Return",
                    size: "1.8 MB",
                    status: "Verified",
                    uploadedDate: Date().addingTimeInterval(-86400),
                    isCritical: true
                )
            ]
        ),
        DocumentCategory(
            name: "Identity & Legal",
            icon: "person.text.rectangle.fill",
            color: Color(hex: "2E86DE"),
            progress: 0.60,
            documents: [
                Document(
                    id: "3",
                    name: "Driver's License",
                    type: "Driver's License",
                    size: "1.2 MB",
                    status: "Uploaded",
                    uploadedDate: Date().addingTimeInterval(-172_800),
                    isCritical: true
                )
            ]
        ),
        DocumentCategory(
            name: "Property History",
            icon: "house.fill",
            color: Color(hex: "A66BFF"),
            progress: 0.40,
            documents: []
        ),
        DocumentCategory(
            name: "Employment",
            icon: "briefcase.fill",
            color: Color(hex: "FF9F43"),
            progress: 0.90,
            documents: [
                Document(
                    id: "4",
                    name: "Employment Letter",
                    type: "Employment Letter",
                    size: "856 KB",
                    status: "Uploaded",
                    uploadedDate: Date().addingTimeInterval(-259_200),
                    isCritical: true
                ),
                Document(
                    id: "5",
                    name: "Pay Stub - December 2023",
                    type: "Pay Stub",
                    size: "1.1 MB",
                    status: "Uploaded",
                    uploadedDate: Date().addingTimeInterval(-345_600),
                    isCritical: false
                )
            ]
        ),
        DocumentCategory(
            name: "Insurance",
            icon: "shield.lefthalf.filled",
            color: Color(hex: "E74C3C"),
            progress: 0.30,
            documents: []
        ),
        DocumentCategory(
            name: "References",
            icon: "person.2.fill",
            color: Color(hex: "20C5D8"),
            progress: 0.80,
            documents: [
                Document(
                    id: "6",
                    name: "Previous Landlord Reference",
                    type: "Reference",
                    size: "645 KB",
                    status: "Pending",
                    uploadedDate: Date().addingTimeInterval(-432_000),
                    isCritical: false
                )
            ]
        )
    ]

    @State private var showMissingDocsSheet = false
    @State private var showUploadSheet = false
    @State private var selectedCategory: DocumentCategory?
    @State private var animationOffset: CGFloat = 0
    @State private var showPaigeAvatar = false
    @State private var showConfetti = false
    @State private var showRedHalo = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var overallProgress: Double {
        categories.reduce(0) { $0 + $1.progress } / Double(categories.count)
    }

    private var progressRingView: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 8)
                .frame(width: 80, height: 80)

            Circle()
                .trim(from: 0, to: overallProgress)
                .stroke(
                    LinearGradient(
                        colors: [Color.pink, Color.pink.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: overallProgress)

            VStack(spacing: 2) {
                Text("\(Int(overallProgress * 100))%")
                    .font(.custom("Lato-Regular", size: 18))
                    .fontWeight(.bold)
                    .monospacedDigit()

                Text("Complete")
                    .font(.custom("Lato-Regular", size: 10))
                    .foregroundColor(.secondary)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Warm archive background
                Color.pink.opacity(0.1).ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Top Progress Ring Section
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Document Vault")
                                        .font(.custom("PlayfairDisplay-Regular", size: 28))
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)

                                    Text("Secure • Organized • Accessible")
                                        .font(.custom("Lato-Regular", size: 16))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                // Progress Ring
                                Button {
                                    showMissingDocsSheet = true
                                } label: {
                                    progressRingView
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        }

                        // Categories Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 14),
                            GridItem(.flexible(), spacing: 14)
                        ], spacing: 14) {
                            ForEach(categories, id: \.id) { category in
                                CategoryCard(category: category) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // Quick Actions Row
                        QuickActionsRow {
                            showUploadSheet = true
                        }
                        .padding(.horizontal, 20)

                        // Bottom spacing for tab bar
                        Color.clear.frame(height: 100)
                    }
                }
                .scrollContentBackground(.hidden)

                // Paige Avatar Animation Overlay
                if showPaigeAvatar && !reduceMotion {
                    PaigeAvatarAnimation()
                        .allowsHitTesting(false)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showMissingDocsSheet) {
            MissingDocsSheet(categories: categories)
        }
        .sheet(item: $selectedCategory) { category in
            CategoryDetailModal(
                category: category,
                isPresented: Binding(
                    get: { selectedCategory != nil },
                    set: { if !$0 { selectedCategory = nil } }
                )
            ) {
                showUploadSheet = true
            }
        }
        .sheet(isPresented: $showUploadSheet) {
            UploadDocumentFlow { success in
                if success {
                    triggerPaigeAnimation()
                }
                showUploadSheet = false
            }
        }
        .overlay(
            // Paige Avatar Animation
            Group {
                if showPaigeAvatar {
                    PaigeAvatarAnimation()
                }
            }
        )
        .overlay(
            // Global confetti overlay
            Group {
                if showConfetti {
                    ConfettiView()
                }
            }
        )
    }

    // MARK: - Missing Docs Sheet

    struct MissingDocsSheet: View {
        let categories: [DocumentCategory]
        @Environment(\.dismiss) private var dismiss

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("What's Missing")
                            .font(.custom("PlayfairDisplay-Regular", size: 28))
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)

                        ForEach(categories.filter { $0.progress < 1.0 }) { category in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: category.icon)
                                        .foregroundStyle(category.color)
                                        .font(.title2)

                                    Text(category.name)
                                        .font(.custom("Lato-Regular", size: 18))
                                        .fontWeight(.semibold)

                                    Spacer()

                                    Text("\(Int(category.progress * 100))%")
                                        .font(.custom("Lato-Regular", size: 14))
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                }

                                Text("Missing documents needed to complete this category")
                                    .font(.custom("Lato-Regular", size: 14))
                                    .foregroundColor(.secondary)

                                Button("Add Documents") {
                                    // Handle add documents
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(category.color)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 20)
                }
                .navigationTitle("Missing Documents")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Upload Document Flow

    struct UploadDocumentFlow: View {
        let onComplete: (Bool) -> Void
        @Environment(\.dismiss) private var dismiss

        var body: some View {
            NavigationStack {
                VStack(spacing: 20) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)

                    Text("Upload Document")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Document upload flow will be implemented here.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button("Simulate Upload") {
                        onComplete(true)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)

                    Spacer()
                }
                .padding()
                .navigationTitle("Upload Document")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Category Card

    struct CategoryCard: View {
        let category: DocumentCategory
        let onTap: () -> Void
        @State private var showConfetti = false
        @State private var showRedHalo = false

        var body: some View {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: category.icon)
                            .font(.title2)
                            .foregroundStyle(category.color)

                        Spacer()

                        Text("\(Int(category.progress * 100))%")
                            .font(.custom("Lato-Regular", size: 12))
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }

                    Text(category.name)
                        .font(.custom("Lato-Regular", size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)

                    ProgressView(value: category.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: category.color))
                        .scaleEffect(y: 0.8)

                    Text("\(category.documents.count) documents")
                        .font(.custom("Lato-Regular", size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            // Red halo for missing critical docs
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red.opacity(showRedHalo ? 0.6 : 0), lineWidth: 2)
                                .scaleEffect(showRedHalo ? 1.05 : 1.0)
                                .opacity(showRedHalo ? 1 : 0)
                        )
                )
                .overlay(
                    // Confetti for completion
                    ConfettiView()
                        .opacity(showConfetti ? 1 : 0)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .onAppear {
                // Check for confetti trigger (90% completion)
                if category.progress >= 0.9 && !showConfetti {
                    triggerConfetti()
                }

                // Check for red halo (critical missing docs)
                if category.hasCriticalMissingDocs {
                    startRedHaloPulse()
                }
            }
            .onChange(of: category.progress) { _, newProgress in
                if newProgress >= 0.9 && !showConfetti {
                    triggerConfetti()
                }
            }
        }

        private func triggerConfetti() {
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showConfetti = false
            }
        }

        private func startRedHaloPulse() {
            Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { _ in
                if category.hasCriticalMissingDocs {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        showRedHalo = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            showRedHalo = false
                        }
                    }
                }
            }
        }
    }

    // MARK: - Quick Actions Row

    struct QuickActionsRow: View {
        let onUpload: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Actions")
                    .font(.custom("PlayfairDisplay-Regular", size: 20))
                    .fontWeight(.semibold)

                HStack(spacing: 12) {
                    Button(action: onUpload) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Upload")
                        }
                        .font(.custom("Lato-Regular", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient(
                                    colors: [Color(hex: "2ECC71"), Color(hex: "2ECC71").opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        )
                    }

                    Spacer()
                }
            }
        }
    }

    // MARK: - Category Detail Modal

    struct CategoryDetailModal: View {
        let category: DocumentCategory
        @Binding var isPresented: Bool
        let onUpload: () -> Void

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Category header
                        HStack {
                            Image(systemName: category.icon)
                                .font(.title)
                                .foregroundStyle(category.color)

                            VStack(alignment: .leading) {
                                Text(category.name)
                                    .font(.custom("PlayfairDisplay-Regular", size: 24))
                                    .fontWeight(.bold)

                                Text("\(category.documents.count) documents")
                                    .font(.custom("Lato-Regular", size: 14))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 20)

                        // Documents list
                        ForEach(category.documents, id: \.id) { document in
                            DocumentRow(document: document)
                                .padding(.horizontal, 20)
                        }

                        if category.documents.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "doc.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.secondary)

                                Text("No documents yet")
                                    .font(.custom("Lato-Regular", size: 16))
                                    .foregroundColor(.secondary)

                                Button("Add First Document") {
                                    onUpload()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(category.color)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }
                    }
                    .padding(.vertical, 20)
                }
                .navigationTitle(category.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            isPresented = false
                        }
                    }
                }
            }
        }
    }

    // MARK: - Document Row

    struct DocumentRow: View {
        let document: Document

        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: document.systemIcon)
                    .font(.title2)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(document.name)
                        .font(.custom("Lato-Regular", size: 16))
                        .fontWeight(.medium)

                    HStack {
                        Text(document.size)
                            .font(.custom("Lato-Regular", size: 12))
                            .foregroundColor(.secondary)

                        Text("•")
                            .font(.custom("Lato-Regular", size: 12))
                            .foregroundColor(.secondary)

                        Text(document.displayName)
                            .font(.custom("Lato-Regular", size: 12))
                            .foregroundColor(document.statusColor)
                    }
                }

                Spacer()

                Circle()
                    .fill(document.statusColor)
                    .frame(width: 8, height: 8)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
        }
    }

    // MARK: - Paige Avatar Animation

    struct PaigeAvatarAnimation: View {
        @State private var scale: CGFloat = 0.5
        @State private var opacity: Double = 0

        var body: some View {
            VStack {
                Spacer()

                HStack {
                    Spacer()

                    VStack(spacing: 8) {
                        Circle()
                            .fill(Color(hex: "2ECC71"))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text("P")
                                    .font(.custom("PlayfairDisplay-Regular", size: 24))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )

                        Text("Document uploaded!")
                            .font(.custom("Lato-Regular", size: 14))
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                            )
                    }
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            scale = 1.0
                            opacity = 1.0
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                opacity = 0
                            }
                        }
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 120)
            }
        }
    }

    private func triggerPaigeAnimation() {
        guard !reduceMotion else { return }
        showPaigeAvatar = true
        showConfetti = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showPaigeAvatar = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showConfetti = false
        }
    }
}
