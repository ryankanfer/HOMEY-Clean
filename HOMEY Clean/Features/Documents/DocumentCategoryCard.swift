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
            HStack(spacing: 16) {
                // Icon with status indicator
                ZStack {
                    Circle()
                        .fill(vault.color.opacity(vault.completionPercentage >= 1.0 ? 0.1 : 0.2))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(vault.completionPercentage > 0.8 ? .green : vault.color, lineWidth: 2)
                        )
                    
                    Image(systemName: vault.icon)
                        .font(.title2)
                        .foregroundColor(vault.completionPercentage >= 1.0 ? .gray : 
                                       vault.completionPercentage > 0.8 ? .green : vault.color)
                        .scaleEffect(vault.completionPercentage > 0.8 ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: vault.completionPercentage)
                    
                    // Status badges
                    if vault.completionPercentage < 0.3 {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                            .offset(x: 15, y: -15)
                    } else if vault.completionPercentage >= 1.0 {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                            .offset(x: 15, y: -15)
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
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(vault.name)
                            .font(.headline.bold())
                            .foregroundColor(vault.completionPercentage >= 1.0 ? .gray : .white)
                            .multilineTextAlignment(.leading)
                        
                        // Info button for tooltip
                        if let documentType = DocumentType.allCases.first(where: { $0.displayName == vault.name }) {
                            Button(action: {
                                contextManager.showTooltip(for: documentType)
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.caption)
                                    .foregroundColor(.blue.opacity(vault.completionPercentage >= 1.0 ? 0.4 : 0.7))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    HStack {
                        Circle()
                            .fill(vault.completionPercentage > 0.8 ? .green : 
                                  vault.completionPercentage > 0.5 ? .orange : .red)
                            .frame(width: 8, height: 8)
                        
                        Text("\(uploadedDocsCount)/\(totalDocsCount) docs")
                            .font(.subheadline)
                            .foregroundColor(vault.completionPercentage >= 1.0 ? .gray.opacity(0.7) : .gray)
                    }
                }
                
                Spacer()
                
                // Lock indicator
                if vault.isLocked {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(vault.completionPercentage > 0.8 ? .green.opacity(0.3) : .clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}