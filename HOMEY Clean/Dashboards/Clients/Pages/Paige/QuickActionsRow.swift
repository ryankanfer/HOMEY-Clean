//
//  QuickActionsRow.swift
//  HOMEY Clean
//
//  Quick action buttons for the Document Vault
//

import SwiftUI

struct QuickActionsRow: View {
    let onUploadDocument: () -> Void

    @State private var showScanSheet = false
    @State private var showExportSheet = false
    @State private var showSecuritySheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.custom("PlayfairDisplay-Regular", size: 20))
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                // Upload Document
                QuickActionButton(
                    icon: "doc.badge.plus",
                    title: "Upload Document",
                    color: Color(hex: "2ECC71")
                ) {
                    onUploadDocument()
                    HapticManager.shared.impact(.medium)
                }

                // Scan Document
                QuickActionButton(
                    icon: "doc.viewfinder",
                    title: "Scan Document",
                    color: Color(hex: "2E86DE")
                ) {
                    showScanSheet = true
                    HapticManager.shared.impact(.medium)
                }

                // Export All
                QuickActionButton(
                    icon: "square.and.arrow.up",
                    title: "Export All",
                    color: Color(hex: "FF9F43")
                ) {
                    showExportSheet = true
                    HapticManager.shared.impact(.medium)
                }

                // Security Settings
                QuickActionButton(
                    icon: "lock.shield",
                    title: "Security Settings",
                    color: Color(hex: "E74C3C")
                ) {
                    showSecuritySheet = true
                    HapticManager.shared.impact(.medium)
                }
            }
        }
        .sheet(isPresented: $showScanSheet) {
            ScanDocumentSheet()
        }
        .sheet(isPresented: $showExportSheet) {
            ExportAllSheet()
        }
        .sheet(isPresented: $showSecuritySheet) {
            SecuritySettingsSheet()
        }
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon with glow
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    color.opacity(0.25),
                                    color.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 15,
                                endRadius: 30
                            )
                        )
                        .frame(width: 44, height: 44)
                        .scaleEffect(isPressed ? 1.1 : 1.0)

                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                        )

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(color)
                        .symbolRenderingMode(.hierarchical)
                }

                Text(title)
                    .font(.custom("Lato-Regular", size: 12))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.08), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Haptic Manager

class HapticManager {
    static let shared = HapticManager()
    private init() {}

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(type)
    }
}

// MARK: - Placeholder Sheets

struct ScanDocumentSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "doc.viewfinder")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)

                Text("Scan Document")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Camera scanning functionality will be implemented here.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Scan Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ExportAllSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)

                Text("Export All Documents")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Export functionality will be implemented here.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Export All")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SecuritySettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)

                Text("Security Settings")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Security settings will be implemented here.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()
            }
            .padding()
            .navigationTitle("Security Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    QuickActionsRow {
        print("Upload document tapped")
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
