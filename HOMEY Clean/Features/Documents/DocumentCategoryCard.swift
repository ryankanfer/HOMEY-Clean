//
//  DocumentCategoryCard.swift
//  HOMEY Clean
//
//  Document Category Card Component
//

import SwiftUI

struct DocumentCategoryCard: View {
    let vault: DocumentVault
    let action: () -> Void
    @EnvironmentObject var contextManager: DocumentContextManager
    @State private var isHovering = false
    
    // Computed properties for document counts
    private var uploadedDocsCount: Int {
        vault.documents.filter { $0.status == .uploaded || $0.status == .verified }.count
    }
    
    private var totalDocsCount: Int {
        vault.documents.count
    }
    
    private var contextualGuidance: String {
        if vault.completionPercentage < 0.3 {
            return "📋 Start here - essential for applications"
        } else if vault.completionPercentage < 0.7 {
            return "⏳ Almost ready - just a few more docs"
        } else if vault.completionPercentage < 1.0 {
            return "🎯 Nearly complete - finishing touches"
        } else {
            return "✅ All set! Ready to go ✨"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    folderIcon
                    contentSection
                }
                
                progressBar
                
                noteView
            }
            .padding(20)
            .background(cardBackground)
            .scaleEffect(isHovering ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovering)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var folderIcon: some View {
        ZStack {
            // Glow effect for active folders
            if vault.completionPercentage > 0.5 {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        RadialGradient(
                            colors: [
                                vault.color.opacity(0.3),
                                vault.color.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 30
                        )
                    )
                    .frame(width: 64, height: 64)
                    .scaleEffect(vault.completionPercentage >= 1.0 ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: vault.completionPercentage)
            }
            
            // Main folder container with liquid glass
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    vault.color.opacity(0.2),
                                    vault.color.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .frame(width: 56, height: 56)
            
            // Folder icon
            Image(systemName: vault.completionPercentage >= 1.0 ? "folder.fill.badge.checkmark" : "folder.fill")
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [vault.color, vault.color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Status indicator
            if vault.completionPercentage >= 1.0 {
                Circle()
                    .fill(.green)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                    )
                    .offset(x: 20, y: -20)
            } else if vault.completionPercentage < 0.3 {
                Circle()
                    .fill(.orange)
                    .frame(width: 16, height: 16)
                    .overlay(
                        Image(systemName: "exclamationmark")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                    )
                    .offset(x: 20, y: -20)
            }
        }
        .onHover { hovering in
            isHovering = hovering
            if hovering, let documentType = DocumentType.allCases.first(where: { $0.displayName == vault.name }) {
                contextManager.showTooltip(for: documentType)
            } else if !hovering {
                contextManager.dismissTooltip()
            }
        }
    }

    @ViewBuilder
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(vault.name)
                    .homeyFont(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Info button for tooltip
                if let documentType = DocumentType.allCases.first(where: { $0.displayName == vault.name }) {
                    Button(action: {
                        contextManager.showTooltip(for: documentType)
                    }) {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Document count and status
            HStack(spacing: 8) {
                Circle()
                    .fill(vault.completionPercentage > 0.8 ? .green :
                          vault.completionPercentage > 0.5 ? .orange : .red)
                    .frame(width: 6, height: 6)
                
                Text("\(uploadedDocsCount) of \(totalDocsCount) documents")
                    .homeyFont(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Contextual guidance
            Text(contextualGuidance)
                .homeyFont(.caption2)
                .fontWeight(.regular)
                .foregroundColor(.white.opacity(0.6))
                .lineLimit(2)
        }
    }

    @ViewBuilder
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                    )
                    .frame(height: 6)
                
                // Progress fill with gradient
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                vault.color,
                                vault.color.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * vault.completionPercentage, height: 6)
                    .animation(.easeInOut(duration: 0.8), value: vault.completionPercentage)
            }
        }
        .frame(height: 6)
    }

    @ViewBuilder
    private var noteView: some View {
        if let note = vault.note {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                
                Text(note)
                    .homeyFont(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.1))
                    )
            )
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)
            .overlay(
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
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: vault.completionPercentage > 0.8 ? vault.color.opacity(0.3) : Color.black.opacity(0.1),
                radius: vault.completionPercentage > 0.8 ? 8 : 4,
                x: 0,
                y: 2
            )
    }
}