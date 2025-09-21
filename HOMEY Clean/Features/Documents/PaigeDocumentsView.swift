//
//  DocumentVaultView.swift
//  HOMEY Clean
//
//  Document Vault - Secure, Organized, Accessible
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers
import VisionKit

// MARK: - One-Click Action Model
struct OneClickAction {
    let id = UUID()
    let title: String
    let description: String
    let actionType: ActionType
    let documentType: String
    
    enum ActionType {
        case requestDocument
        case findTemplate
        case scheduleReminder
        case contactSupport
        case openWebsite
    }
    
}

// MARK: - Document Vault View Extensions

extension DocumentVaultView {
    private func updateScrollStatusNote() {
        let shouldShow = scrollOffset < -400 // Show when scrolled past categories
        
        if shouldShow && !showScrollStatusNote {
            currentStatusNote = getScrollStatusMessage()
            withAnimation(.easeInOut(duration: 0.3)) {
                showScrollStatusNote = true
            }
            
            // Auto-hide after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showScrollStatusNote = false
                }
            }
        } else if !shouldShow && showScrollStatusNote {
            withAnimation(.easeInOut(duration: 0.3)) {
                showScrollStatusNote = false
            }
        }
    }
    
    private func getScrollStatusMessage() -> String {
        let completedCount = documentVaults.filter { $0.completionPercentage >= 1.0 }.count
        let totalCount = documentVaults.count
        let incompleteCount = totalCount - completedCount
        
        if completedCount == totalCount {
            return "🎉 All categories complete! You're ready to go!"
        } else if completedCount > 0 {
            return "📋 \(incompleteCount) categories need attention"
        } else {
            return "📋 Start with Identity documents - they're needed most"
        }
    }
}

struct DocumentVaultView: View {
    @StateObject var vm: DocumentsViewModel
    @StateObject var profileVM = ProfileViewModel()
    @StateObject private var contextManager = DocumentContextManager()
    @StateObject private var aiAvatarManager = AIAvatarManager()
    @State private var showImporter = false
    @State private var alertMessage: String?
    @State private var selectedVault: DocumentVault?
    @State private var showVaultDetail = false
    @EnvironmentObject private var themeManager: ThemeManager

    
    // Celebration animation states
    @State private var showCelebration = false
    @State private var celebrationScale: CGFloat = 1.0
    @State private var confettiOffset: CGFloat = 0
    @State private var sparkleRotation: Double = 0
    
    // Action sheet states
    @State private var showActionSheet = false
    @State private var selectedActionVault: DocumentVault?
    @State private var actionSheetActions: [OneClickAction] = []
    @State private var showARScanner = false
    @State private var showEducationCenter = false
    
    // Missing state variables
    @State private var scannedDocuments: [ScannedDocument] = []
    @State private var paigeMessage = ""
    @State private var showPaigeGuidance = false
    
    // Document vaults data
    @State private var documentVaults: [DocumentVault] = DocumentVault.sampleVaults
    
    // Scroll tracking for status notes
    @State private var scrollOffset: CGFloat = 0
    @State private var showScrollStatusNote = false
    @State private var currentStatusNote = ""
    
    // Calculate overall progress
    private var overallProgress: Double {
        let totalProgress = documentVaults.reduce(0) { $0 + $1.completionPercentage }
        return totalProgress / Double(documentVaults.count)
    }
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground(for: .documents)
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, 
                                  value: geometry.frame(in: .named("scroll")).minY)
                }
                .frame(height: 0)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Paige Welcome Header with Avatar
                    paigeWelcomeHeader
                    
                    // Overall progress card - moved to be first priority
                    OverallProgressCard(documentVaults: documentVaults)
                    
                    // Quick Actions section
                    quickActionsSection
                    
                    // Document categories
                    documentCategoriesSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(
                                ScrollOffsetPreferenceKey.self
                            ) { value in
                                scrollOffset = value
                                updateScrollStatusNote()
                            }
            
            // Scroll Status Note Overlay
            if showScrollStatusNote {
                VStack {
                    HStack {
                        Spacer()
                        
                        Text(currentStatusNote)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.orange.opacity(0.9))
                                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                            .padding(.trailing, 20)
                    }
                    .padding(.top, 100)
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: showScrollStatusNote)
            }

            
            // Celebration overlay
            if showCelebration {
                CelebrationOverlay(
                    showCelebration: $showCelebration,
                    celebrationScale: $celebrationScale,
                    confettiOffset: $confettiOffset,
                    sparkleRotation: $sparkleRotation
                )
            }
        }
        .task {
            await vm.refresh()
        }
        .onAppear {
            // Removed Paige guidance functionality
        }
        .sheet(isPresented: $showVaultDetail) {
            if let vault = selectedVault {
                VaultDetailSheet(vault: vault, isPresented: $showVaultDetail)
            }
        }
        .fileImporter(isPresented: $showImporter,
                      allowedContentTypes: [.pdf, .image, .plainText]) { result in
            handleFileImport(result)
        }
        .sheet(isPresented: $showARScanner) {
            if #available(iOS 16.0, *) {
                ARDocumentScannerView(
                    scannedDocuments: $scannedDocuments,
                    isPresented: $showARScanner,
                    onDocumentScanned: { document in
                        handleScannedDocument(document)
                    }
                )
            }
        }
        .alert("Upload Status", isPresented: .constant(alertMessage != nil)) {
            Button("OK") { alertMessage = nil }
        } message: {
            if let message = alertMessage {
                Text(message)
            }
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Quick Actions"),
                message: Text("Choose an action to help with your documents"),
                buttons: actionSheetActions.map { action in
                    .default(Text(action.title)) {
                        performOneClickAction(action)
                    }
                } + [.cancel()]
            )
        }
        .sheet(isPresented: $showEducationCenter) {
            EducationCenterView()
        }
    }
    
    // MARK: - Document Vault Header
    private var paigeWelcomeHeader: some View {
        HStack {
            Text("Document Vault")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            
            Spacer()
            
            // Context-aware tip button
            Button(action: {
                showEducationCenter = true
            }) {
                HStack(spacing: 6) {
                    Text("💡")
                        .font(.caption)
                    Text("Tips")
                        .font(.caption.bold())
                }
                .foregroundColor(.orange)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "bolt.fill")
                        .font(.headline.bold())
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quick Actions")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    
                    Text("Fast-track your document preparation")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionCard(
                    title: "AR Scan",
                    description: "Scan documents with AR",
                    icon: "camera.viewfinder",
                    color: .green
                ) {
                    showARScanner = true
                }
                
                QuickActionCard(
                    title: "Smart Upload",
                    description: "Upload & categorize",
                    icon: "icloud.and.arrow.up",
                    color: .blue
                ) {
                    showImporter = true
                }
                
                QuickActionCard(
                    title: "Find Missing",
                    description: "Identify gaps",
                    icon: "magnifyingglass.circle",
                    color: .orange
                ) {
                    // Find incomplete vaults
                    let incompleteVaults = documentVaults.filter { $0.completionPercentage < 0.8 }
                    if let firstIncomplete = incompleteVaults.first {
                        selectedVault = firstIncomplete
                        showVaultDetail = true
                    }
                }
                
                QuickActionCard(
                    title: "Get Help",
                    description: "Contact support",
                    icon: "questionmark.circle",
                    color: .purple
                ) {
                    // Contact support logic
                }
            }
        }
        .padding(24)
        .background(
            ZStack {
                // Main background with warm gradient
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.35),
                                Color.purple.opacity(0.12),
                                Color.black.opacity(0.25)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Subtle border with warm accent
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.25),
                                Color.pink.opacity(0.15),
                                Color.purple.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
                
                // Organic glow effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.orange.opacity(0.06),
                                Color.clear
                            ],
                            center: .topTrailing,
                            startRadius: 40,
                            endRadius: 160
                        )
                    )
            }
        )
        .shadow(color: .black.opacity(0.25), radius: 15, x: 0, y: 8)
        .shadow(color: .orange.opacity(0.08), radius: 30, x: 0, y: 15)
    }
    
    // MARK: - Document Categories Section
    private var documentCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Document Categories")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("📁")
                    .font(.title3)
            }
            
            VStack(spacing: 12) {
                // Sort vaults: incomplete first, then completed
                let sortedVaults = documentVaults.sorted { vault1, vault2 in
                    if vault1.completionPercentage >= 1.0 && vault2.completionPercentage < 1.0 {
                        return false // vault1 (completed) goes after vault2 (incomplete)
                    } else if vault1.completionPercentage < 1.0 && vault2.completionPercentage >= 1.0 {
                        return true // vault1 (incomplete) goes before vault2 (completed)
                    } else {
                        // Both are in same completion state, maintain original order
                        return false
                    }
                }
                
                ForEach(sortedVaults) { vault in
                    DocumentCategoryCard(vault: vault) {
                        selectedVault = vault
                        showVaultDetail = true
                    }
                    .environmentObject(contextManager)
                }
            }
            
            // Document Context Tooltip Overlay
            if let activeType = contextManager.activeTooltip {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        contextManager.dismissTooltip()
                    }
                
                VStack {
                    Spacer()
                    
                    DocumentContextTooltip(
                        documentType: activeType,
                        isVisible: true,
                        onDismiss: {
                            contextManager.dismissTooltip()
                        }
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: contextManager.activeTooltip != nil)
            }
        }
        .padding(24)
        .background(
            ZStack {
                // Main background with warm gradient
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.3),
                                Color.purple.opacity(0.1),
                                Color.black.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Subtle border with warm accent
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.2),
                                Color.pink.opacity(0.12),
                                Color.purple.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
                
                // Organic glow effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.orange.opacity(0.04),
                                Color.clear
                            ],
                            center: .topTrailing,
                            startRadius: 30,
                            endRadius: 140
                        )
                    )
            }
        )
        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
        .shadow(color: .orange.opacity(0.06), radius: 25, x: 0, y: 12)
    }
    
    // MARK: - File Import Handler
    private func handleFileImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            alertMessage = "Document uploaded successfully!"
            triggerCelebrationAnimation()
        case .failure(let error):
            alertMessage = "Upload failed: \(error.localizedDescription)"
        }
    }
    
    // MARK: - AR Scan Handler
    private func handleScannedDocument(_ document: ScannedDocument) {
        // Append scanned document to local state and notify user
        scannedDocuments.append(document)
        alertMessage = "Document scanned successfully!\(documentDescription(for: document))"
        // Optionally, trigger celebration or categorize based on document type
        triggerCelebrationAnimation()
    }
    
    // Helper to safely describe the scanned document's type
    private func documentDescription(for document: ScannedDocument) -> String {
        // If ScannedDocument has a documentType with a rawValue, surface it.
        // Otherwise, fall back to a generic message.
        #if compiler(>=5.9)
        // Use optional chaining to avoid compile errors if the property doesn't exist
        if let any = (document as AnyObject) as? NSObject, any.responds(to: Selector(("documentType"))) {
            // Best-effort KVC lookup to avoid tight coupling if the type isn't in this file
            let value = any.value(forKey: "documentType")
            if let raw = value as? CustomStringConvertible {
                return " Type: \(raw)"
            }
        }
        #endif
        return ""
    }
    
    // MARK: - One-Click Actions
    private func showOneClickActions(for vault: DocumentVault) {
        selectedActionVault = vault
        actionSheetActions = getAvailableActions(for: vault)
        showActionSheet = true
    }
    
    private func getAvailableActions(for vault: DocumentVault) -> [OneClickAction] {
        var actions: [OneClickAction] = []
        
        // Add actions based on vault type and completion status
        if vault.completionPercentage < 100 {
            switch vault.name.lowercased() {
            case let name where name.contains("tax"):
                actions.append(OneClickAction(
                    title: "Request W-2 from Employer",
                    description: "We'll help you contact your employer",
                    actionType: .requestDocument,
                    documentType: "W-2"
                ))
                actions.append(OneClickAction(
                    title: "Find Tax Forms Online",
                    description: "Access IRS forms and instructions",
                    actionType: .openWebsite,
                    documentType: "Tax Forms"
                ))
            case let name where name.contains("income"):
                actions.append(OneClickAction(
                    title: "Download Bank Statements",
                    description: "Connect to your bank securely",
                    actionType: .openWebsite,
                    documentType: "Bank Statements"
                ))
                actions.append(OneClickAction(
                    title: "Request Pay Stubs",
                    description: "Contact HR or payroll department",
                    actionType: .requestDocument,
                    documentType: "Pay Stubs"
                ))
            case let name where name.contains("insurance"):
                actions.append(OneClickAction(
                    title: "Contact Insurance Provider",
                    description: "Get your policy documents",
                    actionType: .contactSupport,
                    documentType: "Insurance"
                ))
            default:
                actions.append(OneClickAction(
                    title: "Set Reminder",
                    description: "Get notified to complete this category",
                    actionType: .scheduleReminder,
                    documentType: vault.name
                ))
            }
        }
        
        return actions
    }
    
    private func performOneClickAction(_ action: OneClickAction) {
        switch action.actionType {
        case .requestDocument:
            // Simulate document request
            alertMessage = "Request sent! We'll help you get your \(action.documentType)."
        case .openWebsite:
            // Simulate opening relevant website
            alertMessage = "Opening \(action.documentType) resources..."
        case .contactSupport:
            // Simulate contacting support
            alertMessage = "Connecting you with \(action.documentType) support..."
        case .scheduleReminder:
            // Simulate scheduling reminder
            alertMessage = "Reminder set for \(action.documentType) completion."
        case .findTemplate:
            // Simulate finding template
            alertMessage = "Template for \(action.documentType) is ready to download."
        }
    }
    
    // MARK: - Header Functions
    private func getSmartSuggestion() -> String? {
        if overallProgress < 0.3 {
            return "Upload missing documents to improve your vault health"
        } else if overallProgress > 0.8 {
            return "Great job! Your documents are well organized"
        } else {
            return "Consider organizing your documents by category"
        }
    }
    
    private func getHealthColor() -> Color {
        if overallProgress < 0.3 {
            return .red
        } else if overallProgress < 0.7 {
            return .orange
        } else {
            return .green
        }
    }
    
    // MARK: - Celebration Animation
    private func showPaigeGuidanceForContext(_ context: String) {
        guard let paige = aiAvatarManager.getAvatar(by: "paige") else { return }
        
        // Smart contextual messages based on user's actual document status
        let contextMessages = getSmartContextualMessage(for: context)
        
        paigeMessage = contextMessages
        
        withAnimation(.easeInOut(duration: 0.4)) {
            showPaigeGuidance = true
        }
        
        // Auto-dismiss after 10 seconds for longer messages
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showPaigeGuidance = false
            }
        }
    }
    
    private func getSmartContextualMessage(for context: String) -> String {
        switch context {
        case "welcome":
            return "Hi! I'm Paige, your document companion. I'll help you organize and understand why each document matters for your home journey."
            
        case "upload":
            // Check for specific missing documents
            let incompleteVaults = documentVaults.filter { $0.completionPercentage < 1.0 }
            if let taxVault = incompleteVaults.first(where: { $0.name.lowercased().contains("financial") }) {
                 return "Still waiting on that tax return? No worries - I can help you request it from the IRS or your accountant. Every document brings you closer to your keys! 🗝️"
             } else if let employmentVault = incompleteVaults.first(where: { $0.name.lowercased().contains("employment") }) {
                 return "Need help getting that employment verification letter? I can draft a template for your HR department. Let's keep the momentum going! 💪"
            }
            return "Great job uploading documents! Each one brings you closer to your dream home. Need help understanding what any document is for?"
            
        case "progress":
            let completedCount = documentVaults.filter { $0.completionPercentage >= 1.0 }.count
            let totalCount = documentVaults.count
            
            if completedCount == 0 {
                return "Just getting started? Perfect! I recommend beginning with your Identity documents - they're usually the easiest to gather and will give you quick wins! 🎯"
            } else if completedCount < totalCount / 2 {
                return "You're building great momentum! Have you seen Sarah's note on your reference letter? She mentioned it could be stronger with specific examples of your reliability. 📝"
            } else if completedCount == totalCount - 1 {
                return "So close! Just one more category to complete. You're practically holding those keys already! 🔑✨"
            }
            return "You're making excellent progress! Remember, having organized documents shows lenders you're serious and prepared."
            
        case "missing":
            // Provide specific guidance based on what's actually missing
            let incompleteVaults = documentVaults.filter { $0.completionPercentage < 1.0 }
            if let firstIncomplete = incompleteVaults.first {
                return "Missing documents in \(firstIncomplete.name)? I can help you get them! Click on the category to see exactly what you need and I'll show you the fastest way to obtain each one. 🚀"
            }
            return "Don't worry about missing documents - we can help you get them. Click on any category to see exactly what you need and why it matters."
            
        case "completion":
            return "Congratulations! Your document vault is looking fantastic. You're well-prepared for your next steps in the home buying process."
            
        default:
            return "I'm here to help with your documents!"
        }
    }
    
    private func triggerCelebrationAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
           showCelebration = true
           celebrationScale = 1.2
       }
       
       withAnimation(.linear(duration: 2.0)) {
           confettiOffset = -100
           sparkleRotation = 360
       }
       
       DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
           withAnimation(.easeOut(duration: 0.5)) {
               showCelebration = false
               celebrationScale = 1.0
               confettiOffset = 0
               sparkleRotation = 0
           }
       }
   }
}

#Preview {
    NavigationView {
        DocumentVaultView(vm: DocumentsViewModel())
    }
    .preferredColorScheme(.dark)
}