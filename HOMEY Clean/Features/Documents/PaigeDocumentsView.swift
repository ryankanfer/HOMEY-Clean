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
import UIKit
import Supabase

// MARK: - Vault Filter
private enum VaultFilter: String, CaseIterable {
    case all = "All"
    case missing = "Missing"
    case completed = "Done"
}

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

struct DocumentVaultView: View {
    @StateObject var vm: DocumentsViewModel
    @StateObject var profileVM = ProfileViewModel()
    @StateObject private var contextManager = DocumentContextManager()
    @StateObject private var aiAvatarManager = AIAvatarManager()
    @State private var showImporter = false
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var presentation: PresentationController
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Celebration animation states
    @State private var showCelebration = false
    @State private var celebrationScale: CGFloat = 1.0
    @State private var confettiOffset: CGFloat = 0
    @State private var sparkleRotation: Double = 0
    
    @State private var showQuickActionsDialog = false
    @State private var selectedActionVault: DocumentVault?
    @State private var actionSheetActions: [OneClickAction] = []
    
    // Missing state variables
    @State private var scannedDocuments: [ScannedDocument] = []
    @State private var paigeMessage = ""
    @State private var showPaigeGuidance = false
    @State private var showShareWithAgentSheet = false
    
    // Document vaults data
    @State private var documentVaults: [DocumentVault] = DocumentVault.sampleVaults
    
    private var sortedVaults: [DocumentVault] {
        documentVaults.sorted { lhs, rhs in
            if lhs.completionPercentage == rhs.completionPercentage {
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            }
            return lhs.completionPercentage < rhs.completionPercentage
        }
    }
    
    private var filteredVaults: [DocumentVault] {
        let searched = sortedVaults.filter { vault in
            return matchesSearch(vault)
        }
        switch filter {
        case .all:
            return searched
        case .missing:
            return searched.filter { $0.completionPercentage < 1.0 }
        case .completed:
            return searched.filter { $0.completionPercentage >= 1.0 }
        }
    }
    
    private func matchesSearch(_ vault: DocumentVault) -> Bool {
        guard !searchText.isEmpty else { return true }
        let query = searchText.lowercased()

        var haystacks: [String] = [vault.name]

        if let ocr = extractStringProperty(named: "ocrText", from: vault) {
            haystacks.append(ocr)
        }
        if let tags = extractStringArrayProperty(named: "tags", from: vault) {
            haystacks.append(tags.joined(separator: " "))
        }
        if let metaValues = extractStringDictionaryProperty(named: "metadata", from: vault) {
            haystacks.append(metaValues.values.joined(separator: " "))
        }

        switch searchScope {
        case .all:
            return haystacks.contains { $0.localizedCaseInsensitiveContains(query) }
        case .content:
            return (extractStringProperty(named: "ocrText", from: vault) ?? "").localizedCaseInsensitiveContains(query)
        case .tags:
            let tagBlob = (extractStringArrayProperty(named: "tags", from: vault) ?? []).joined(separator: " ")
            return tagBlob.localizedCaseInsensitiveContains(query)
        case .metadata:
            let metaBlob = (extractStringDictionaryProperty(named: "metadata", from: vault) ?? [:]).values.joined(separator: " ")
            return metaBlob.localizedCaseInsensitiveContains(query)
        }
    }

    private func extractStringProperty(named key: String, from object: Any) -> String? {
        let mirror = Mirror(reflecting: object)
        for child in mirror.children {
            if child.label == key, let value = child.value as? String { return value }
        }
        return nil
    }

    private func extractStringArrayProperty(named key: String, from object: Any) -> [String]? {
        let mirror = Mirror(reflecting: object)
        for child in mirror.children {
            if child.label == key, let value = child.value as? [String] { return value }
        }
        return nil
    }

    private func extractStringDictionaryProperty(named key: String, from object: Any) -> [String: String]? {
        let mirror = Mirror(reflecting: object)
        for child in mirror.children {
            if child.label == key, let value = child.value as? [String: String] { return value }
        }
        return nil
    }
    
    // Scroll tracking for status notes
    @State private var scrollOffset: CGFloat = 0
    @State private var showScrollStatusNote = false
    @State private var currentStatusNote = ""
    
    // Filtering & search
    @State private var filter: VaultFilter = .all
    @State private var searchText: String = ""
    
    // Search scope
    enum SearchScope: String, CaseIterable { case all = "All", content = "Content", tags = "Tags", metadata = "Metadata" }
    @State private var searchScope: SearchScope = .all
    
    // Feature action toggles
    @State private var showTemplates = false
    @State private var showIntegrations = false
    @State private var showShareSheet = false
    @State private var showSharePicker = false
    @State private var shareURLs: [URL] = []
    @State private var showCommentsSheet = false
    @State private var showComplianceChecklist = false
    
    // New state variables as requested
    @State private var showARScannerSheet = false
    @State private var showIntegrationsSheet = false
    @State private var selectedIntegrationTitle: String? = nil
    @State private var showComplianceSheet = false
    @State private var showVersionHistorySheet = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // Batch upload HUD
    @State private var showUploadHUD = false
    @State private var batchTotal = 0
    @State private var batchCompleted = 0
    @State private var currentFileName = ""
    // Local vault detail sheet fallback
    @State private var selectedVaultForDetail: DocumentVault?
    
    // Calculate overall progress
    private var overallProgress: Double {
        let totalProgress = documentVaults.reduce(0) { $0 + $1.completionPercentage }
        return totalProgress / Double(documentVaults.count)
    }
    
    // Document upload tips
    private let documentTips = [
        "All documents must be official PDFs, no screenshots",
        "Don't forget to redact your social security numbers and bank account numbers (leaving last 4 digits visible)",
        "Ensure all documents are clear and readable",
        "Upload the most recent versions of your documents",
        "Check that all required fields are filled out completely"
    ]
    
    private func updateScrollStatusNote() {
        // Adaptive threshold based on screen height for consistent feel across devices
        let threshold = -UIScreen.main.bounds.height * 0.25
        let shouldShow = scrollOffset < threshold
        
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
            return "All categories complete! You're ready to go!"
        } else if completedCount > 0 {
            return "\(incompleteCount) categories need attention"
        } else {
            return "Start with Identity documents - they're needed most"
        }
    }
    
    var body: some View {
        ZStack {
            CinematicBackground(for: .documents)
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, 
                                  value: geometry.frame(in: .named("scroll")).minY)
                }
                .frame(height: 0)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Enhanced filing cabinet header
                    filingCabinetHeader
                    
                    // Overall progress card - moved to be first priority
                    OverallProgressCard(documentVaults: documentVaults)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(Text("Overall completion"))
                        .accessibilityValue(Text("\(Int(overallProgress * 100)) percent"))
                    
                    // AI-powered smart actions
                    smartActionsSection
                    
                    // Document vault grid with filing cabinet design
                    documentVaultGrid
                    
                    // Share with agent section
                    shareWithAgentSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .dropDestination(for: URL.self) { urls, _ in
                handleFiles(urls)
                return !urls.isEmpty
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(
                                ScrollOffsetPreferenceKey.self
                            ) { value in
                                scrollOffset = value
                                updateScrollStatusNote()
                            }
            
            // Celebration overlay
            if showCelebration {
                CelebrationOverlay(
                    showCelebration: $showCelebration,
                    celebrationScale: $celebrationScale,
                    confettiOffset: $confettiOffset,
                    sparkleRotation: $sparkleRotation
                )
                .allowsHitTesting(false)
            }
        }
        .task {
            await vm.refresh()
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.pdf, .image, .plainText],
            allowsMultipleSelection: true
        ) { result in
            handleFilesFromImporter(result)
        }
        .fileImporter(
            isPresented: $showSharePicker,
            allowedContentTypes: [.pdf, .image, .plainText],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                shareURLs = urls
                showShareSheet = !urls.isEmpty
            case .failure(let error):
                alertTitle = "Share"
                alertMessage = "Couldn't pick files to share: \(error.localizedDescription)"
                showAlert = true
            }
        }
        .confirmationDialog(
            "Quick Actions",
            isPresented: $showQuickActionsDialog,
            titleVisibility: .visible
        ) {
            ForEach(actionSheetActions, id: \.id) { action in
                Button(action.title) {
                    performOneClickAction(action)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Choose an action to help with your documents")
        }
        .safeAreaInset(edge: .top) {
            if showScrollStatusNote {
                HStack {
                    Spacer()
                    Text(currentStatusNote)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.orange.opacity(0.95))
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    Spacer()
                }
                .padding(.top, 4)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: showScrollStatusNote)
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic)) {
            ForEach(SearchScope.allCases, id: \.self) { scope in
                Text(scope.rawValue).searchCompletion(scope.rawValue)
            }
        }
        .searchScopes($searchScope) {
            Text("All").tag(SearchScope.all)
            Text("Content").tag(SearchScope.content)
            Text("Tags").tag(SearchScope.tags)
            Text("Metadata").tag(SearchScope.metadata)
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    DispatchQueue.main.async {
                        showSharePicker = true
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .imageScale(.large)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Section("Upload & Scan") {
                        Button("Multi-Page Scan") {
                            DispatchQueue.main.async {
                                performHapticTap()
                                showARScannerSheet = true
                            }
                        }
                        Button("Batch Process Scans") {
                            DispatchQueue.main.async {
                                performHapticTap()
                                alertTitle = "Batch Processing"
                                alertMessage = "We'll process your recent scans in the background."
                                showAlert = true
                            }
                        }
                    }
                    Section("Assist & Templates") {
                        Button("Document Templates") {
                            DispatchQueue.main.async { showTemplates = true }
                        }
                        Button("Compliance Checklist") {
                            DispatchQueue.main.async { showComplianceSheet = true }
                        }
                    }
                    Section("Integrations") {
                        Button("Connect Bank") {
                            DispatchQueue.main.async { selectedIntegrationTitle = "Connect Bank"; showIntegrationsSheet = true }
                        }
                        Button("Verify Employment") {
                            DispatchQueue.main.async { selectedIntegrationTitle = "Verify Employment"; showIntegrationsSheet = true }
                        }
                        Button("Government Services") {
                            DispatchQueue.main.async { selectedIntegrationTitle = "Government Services"; showIntegrationsSheet = true }
                        }
                    }
                    Section("Collaboration") {
                        Button("Share with a Pro") {
                            DispatchQueue.main.async { showSharePicker = true }
                        }
                        Button("Comments & Notes") {
                            DispatchQueue.main.async { showCommentsSheet = true }
                        }
                        Button("Version History") {
                            DispatchQueue.main.async {
                                showVersionHistorySheet = true
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .imageScale(.large)
                        .foregroundStyle(.primary)
                }
            }
        }
        .sheet(isPresented: $showTemplates) {
            TemplatesSheet { data, filename in
                Task { try? await vm.upload(data: data, filename: filename, mime: "application/pdf") }
            }
        }
        .sheet(isPresented: $showCommentsSheet) {
            CommentsSheet(vaults: documentVaults)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareDocumentsSheet(urls: shareURLs) {
                showShareSheet = false
                shareURLs.removeAll()
            }
        }
        .sheet(isPresented: $showARScannerSheet) { ScannerPlaceholderSheet() }
        .sheet(isPresented: $showIntegrationsSheet) { IntegrationsSheet(selectedTitle: selectedIntegrationTitle) }
        .sheet(isPresented: $showComplianceSheet) { ComplianceChecklistSheet() }
        .sheet(isPresented: $showVersionHistorySheet) { VersionHistorySheet() }
        .sheet(item: $selectedVaultForDetail) { vault in
            VaultDetailSheet(
                vault: vault,
                isPresented: Binding(
                    get: { selectedVaultForDetail != nil },
                    set: { if !$0 { selectedVaultForDetail = nil } }
                )
            )
        }
        .sheet(isPresented: $showShareWithAgentSheet) {
            ShareWithAgentSheet { _ in
                showShareWithAgentSheet = false
            }
        }
        .overlay(alignment: .bottom) {
            if showUploadHUD {
                HStack(spacing: 12) {
                    ProgressView(value: vm.uploadProgress)
                        .progressViewStyle(.linear)
                        .frame(width: 160)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Uploading \(min(batchCompleted + (vm.isUploading ? 1 : 0), batchTotal))/\(batchTotal)")
                            .font(.footnote.weight(.semibold))
                        Text(currentFileName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: Capsule())
                .shadow(radius: 8)
                .padding(.bottom, 24)
            }
        }
    }
    
    // MARK: - Document Vault Header
    private var paigeWelcomeHeader: some View {
        HStack {
            Text("Documents")
                .font(.largeTitle.bold())
                .gradientForeground(Theme.heroGradient(for: .paige))
            
            Spacer()
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
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickActionChip(
                        title: "Scan",
                        subtitle: "Camera capture",
                        systemImage: "camera.viewfinder",
                        gradient: LinearGradient(colors: [.green, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
                    ) {
                        performHapticTap()
                        showARScannerSheet = true
                    }
                    .accessibilityLabel("Scan documents")
                    .accessibilityHint("Open the camera to scan documents")
                    .accessibilityAddTraits(.isButton)

                    QuickActionChip(
                        title: "Smart Upload",
                        subtitle: "Multi-file • AI categorize",
                        systemImage: "icloud.and.arrow.up",
                        gradient: LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    ) {
                        performHapticTap()
                        showImporter = true
                    }
                    .accessibilityLabel("Smart Upload")
                    .accessibilityHint("Upload multiple documents for automatic categorization")
                    .accessibilityAddTraits(.isButton)

                    QuickActionChip(
                        title: "Templates",
                        subtitle: "Pre-filled docs",
                        systemImage: "doc.badge.gearshape.fill",
                        gradient: LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                    ) {
                        performHapticTap()
                        showTemplates = true
                    }
                    .accessibilityLabel("Document Templates")
                    .accessibilityHint("Open pre-filled templates for common documents")
                    .accessibilityAddTraits(.isButton)
                }
                .padding(.vertical, 4)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)
    }
    
    // MARK: - Document Categories Section
    private var documentCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Document Categories")
                    .font(.title2.bold())
                    .foregroundColor(.white)  // Improved contrast
                
                Spacer()
                
                Text("📁")
                    .font(.title3)
            }
            
            Text("We've placed your documents where they need to be")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .italic()
            
            Picker("Filter", selection: $filter) {
                Text("All").tag(VaultFilter.all)
                Text("Missing").tag(VaultFilter.missing)
                Text("Done").tag(VaultFilter.completed)
            }
            .pickerStyle(.segmented)
            
            VStack(spacing: 12) {
                ForEach(filteredVaults) { vault in
                    DocumentCategoryCard(vault: vault) {
                        selectedVaultForDetail = vault
                    }
                }
                .environmentObject(contextManager)
            }
            
            if filteredVaults.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.badge.plus")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No categories match your filter")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Try uploading or scanning to get started")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
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
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Filing Cabinet Header
    private var filingCabinetHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Document Vault")
                        .homeyFont(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Your digital filing cabinet")
                        .homeyFont(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // AI Assistant Avatar
                Button(action: {
                    showPaigeGuidance.toggle()
                }) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                            )
                        
                        Text("🤖")
                            .font(.title2)
                    }
                }
                .buttonStyle(.plain)
                .scaleEffect(showPaigeGuidance ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showPaigeGuidance)
            }
            
            if showPaigeGuidance {
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 Smart Tip")
                        .homeyFont(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    Text("Keep your documents organized by category. I'll help you identify what's missing and suggest next steps.")
                        .homeyFont(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(.blue.opacity(0.3), lineWidth: 1)
                        )
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showPaigeGuidance)
            }
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Smart Actions Section
    private var smartActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Quick Actions")
                    .homeyFont(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("⚡")
                    .font(.title3)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                // Scan Document
                Button(action: {
                    showARScannerSheet = true
                    performHapticTap()
                }) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                                )
                            
                            Image(systemName: "doc.viewfinder")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                        
                        Text("Scan")
                            .homeyFont(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                
                // Smart Upload
                Button(action: {
                    showImporter = true
                    performHapticTap()
                }) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                                )
                            
                            Image(systemName: "icloud.and.arrow.up")
                                .font(.title3)
                                .foregroundColor(.green)
                        }
                        
                        Text("Upload")
                            .homeyFont(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                
                // Templates
                Button(action: {
                    showTemplates = true
                    performHapticTap()
                }) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                                )
                            
                            Image(systemName: "doc.badge.plus")
                                .font(.title3)
                                .foregroundColor(.purple)
                        }
                        
                        Text("Templates")
                            .homeyFont(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Document Vault Grid
    private var documentVaultGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Document Categories")
                    .homeyFont(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("📁")
                    .font(.title3)
            }
            
            Text("Organized by category for easy access")
                .homeyFont(.subheadline)
                .foregroundStyle(.secondary)
            
            // Filter Picker
            Picker("Filter", selection: $filter) {
                Text("All").tag(VaultFilter.all)
                Text("Missing").tag(VaultFilter.missing)
                Text("Complete").tag(VaultFilter.completed)
            }
            .pickerStyle(.segmented)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            
            // Document Categories Grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(filteredVaults) { vault in
                    DocumentCategoryCard(vault: vault) {
                        selectedVaultForDetail = vault
                    }
                }
                .environmentObject(contextManager)
            }
            
            if filteredVaults.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    
                    Text("No categories match your filter")
                        .homeyFont(.headline)
                        .foregroundStyle(.primary)
                    
                    Text("Try uploading documents or changing your filter")
                        .homeyFont(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Share with Agent Section
    private var shareWithAgentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Share with Agent")
                        .homeyFont(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(getAgentSharingStatus())
                        .homeyFont(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showShareWithAgentSheet = true
                    performHapticTap(style: .medium)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .font(.title3)
                        
                        Text("Share")
                            .homeyFont(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }
            
            // Progress Indicator
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Completion Status")
                        .homeyFont(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(overallProgress * 100))%")
                        .homeyFont(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: overallProgress >= 1.0 ? [.green, .mint] : [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * overallProgress, height: 8)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: overallProgress)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private func getAgentSharingStatus() -> String {
        let incompleteCount = documentVaults.filter { $0.completionPercentage < 1.0 }.count
        if incompleteCount == 0 {
            return "All documents ready to share"
        } else {
            return "\(incompleteCount) categories need attention"
        }
    }
    
    // MARK: - Haptics
    private func performHapticTap(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Feature Placeholders
    private func presentTemplates() {
        presentation.presentAlert(title: "Templates", message: "Choose a template to pre-fill and export.")
    }
    private func presentIntegrations() {
        presentation.presentAlert(title: "Integrations", message: "Connect banks, employers, and government services to fetch documents.")
    }
    private func presentShare() {
        presentation.presentAlert(title: "Share", message: "Securely share selected documents with your pro team.")
    }
    private func presentComments() {
        presentation.presentAlert(title: "Comments", message: "Collaborate with notes and mentions on each document.")
    }
    private func presentCompliance() {
        presentation.presentAlert(title: "Compliance", message: "We’ll check redactions, formats, and required fields.")
    }
    
    // MARK: - File Import Handler
    private func handleFilesFromImporter(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            handleFiles(urls)
        case .failure(let error):
            alertTitle = "Upload Status"
            alertMessage = "Upload failed: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func handleFiles(_ urls: [URL]) {
        guard !urls.isEmpty else { return }
        Task { await batchUpload(urls) }
    }
    
    private func batchUpload(_ urls: [URL]) async {
        await MainActor.run {
            showUploadHUD = true
            batchTotal = urls.count
            batchCompleted = 0
            currentFileName = ""
        }
        
        for url in urls {
            await MainActor.run { currentFileName = url.lastPathComponent }
            do {
                let data = try Data(contentsOf: url)
                let mime = mimeType(for: url)
                try await vm.upload(data: data, filename: url.lastPathComponent, mime: mime)
                await MainActor.run { batchCompleted += 1 }
            } catch {
                await MainActor.run {
                    alertTitle = "Upload Failed"
                    alertMessage = "\(url.lastPathComponent): \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
        
        await MainActor.run {
            showUploadHUD = false
            alertTitle = "Upload Complete"
            alertMessage = "Uploaded \(batchCompleted) of \(batchTotal) files."
            showAlert = true
            triggerCelebrationAnimation()
        }
    }
    
    private func mimeType(for url: URL) -> String {
        if let type = UTType(filenameExtension: url.pathExtension), let mime = type.preferredMIMEType {
            return mime
        }
        return "application/octet-stream"
    }
    
    private func uploadPDFData(_ data: Data, filename: String) {
        Task { try? await vm.upload(data: data, filename: filename, mime: "application/pdf") }
    }
    
    // MARK: - AR Scan Handler
    private func handleScannedDocument(_ document: ScannedDocument) {
        // Append scanned document to local state and notify user
        scannedDocuments.append(document)
        alertTitle = "Scan Complete"
        alertMessage = "Document scanned successfully! Type: \(document.documentType.rawValue)"
        showAlert = true
        // Optionally, trigger celebration or categorize based on document type
        triggerCelebrationAnimation()
    }
    
    // Helper to safely describe the scanned document's type
    private func documentDescription(for document: ScannedDocument) -> String {
        " Type: \(document.documentType.rawValue)"
    }
    
    // MARK: - One-Click Actions
    private func showOneClickActions(for vault: DocumentVault) {
        selectedActionVault = vault
        actionSheetActions = getAvailableActions(for: vault)
        showQuickActionsDialog = true
    }
    
    private func getAvailableActions(for vault: DocumentVault) -> [OneClickAction] {
        var actions: [OneClickAction] = []
        
        // Add actions based on vault type and completion status
        if vault.completionPercentage < 1.0 {
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
            alertTitle = "Request Sent"
            alertMessage = "We'll help you get your \(action.documentType)."
        case .openWebsite:
            alertTitle = "Opening"
            alertMessage = "Opening \(action.documentType) resources..."
        case .contactSupport:
            alertTitle = "Support"
            alertMessage = "Connecting you with \(action.documentType) support..."
        case .scheduleReminder:
            alertTitle = "Reminder Set"
            alertMessage = "Reminder set for \(action.documentType) completion."
        case .findTemplate:
            alertTitle = "Template Ready"
            alertMessage = "Template for \(action.documentType) is ready to download."
        }
        showAlert = true
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
        if reduceMotion {
            withAnimation(.easeInOut(duration: 0.2)) {
                showCelebration = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeOut(duration: 0.2)) {
                    showCelebration = false
                }
            }
            return
        }
        
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

// MARK: - Placeholder Sheets for Menu Navigation
private struct ScannerPlaceholderSheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 40))
                Text("Scanner")
                    .font(.title2.bold())
                Text("A full scanner experience will appear here.")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Scan Documents")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }
}

private struct IntegrationsSheet: View {
    let selectedTitle: String?
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("Integration") {
                    Text(selectedTitle ?? "Integrations")
                }
                Section("Available") {
                    Label("Connect Bank", systemImage: "banknote")
                    Label("Verify Employment", systemImage: "briefcase")
                    Label("Government Services", systemImage: "building.2")
                }
            }
            .navigationTitle("Integrations")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }
}

private struct ComplianceChecklistSheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("Checklist") {
                    Label("Redactions present where required", systemImage: "checkmark.seal")
                    Label("PDF format verified", systemImage: "doc.richtext")
                    Label("Required fields complete", systemImage: "list.bullet.rectangle.portrait")
                }
            }
            .navigationTitle("Compliance Checklist")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }
}

private struct VersionHistorySheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("Version History") {
                    Text("Version history will appear per document.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Version History")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }
}

// MARK: - Quick Action Chip
private struct QuickActionChip: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let gradient: LinearGradient
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 36, height: 36)
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                    )
                    .background(
                        gradient.opacity(0.35)
                            .clipShape(Capsule())
                    )
            )
        }
        .buttonStyle(.plain)
        .contentShape(Capsule())
    }
}

// MARK: - Share Documents Sheet
private struct ShareDocumentsSheet: View {
    let urls: [URL]
    var onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if urls.isEmpty {
                    Text("No files selected to share")
                        .foregroundStyle(.secondary)
                } else {
                    Section("Selected Files") {
                        ForEach(urls, id: \.self) { url in
                            Text(url.lastPathComponent)
                        }
                    }
                }
            }
            .navigationTitle("Share Documents")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        onDismiss()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !urls.isEmpty {
                        ShareLink(items: urls) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Supabase Comments Repository
final class SupabaseCommentsRepository {
    static let shared = SupabaseCommentsRepository()
    private init() {}

    private var client: SupabaseClient { SupabaseClientProvider.client }

    struct Comment: Codable, Identifiable {
        let id: UUID
        let target_id: String
        let user_id: UUID
        let author: String
        let text: String
        let created_at: Date
        let updated_at: Date?
    }

    private struct InsertCommentPayload: Encodable {
        let target_id: String
        let user_id: String
        let author: String
        let text: String
    }

    private struct UpdateCommentPayload: Encodable {
        let text: String
        let updated_at: String
    }

    // Create
    func addComment(targetId: String, author: String, text: String) async {
        do {
            // Requires the user to be authenticated so RLS policies pass
            let session = try await client.auth.session
            let userId = session.user.id

            let payload = InsertCommentPayload(
                target_id: targetId,
                user_id: userId.uuidString,
                author: author,
                text: text
            )

            _ = try await client
                .from("comments")
                .insert(payload)
                .execute()
        } catch {
            print("Supabase addComment error:", error)
        }
    }

    // Read
    func fetchComments(targetId: String) async -> [Comment] {
        do {
            let response: PostgrestResponse<[Comment]> = try await client
                .from("comments")
                .select()
                .eq("target_id", value: targetId)
                .order("created_at", ascending: false)
                .execute()

            return response.value
        } catch {
            print("Supabase fetchComments error:", error)
            return []
        }
    }

    // Update (enforced by RLS to own comments only)
    func updateComment(id: UUID, newText: String) async {
        do {
            let values = UpdateCommentPayload(
                text: newText,
                updated_at: ISO8601DateFormatter().string(from: Date())
            )

            _ = try await client
                .from("comments")
                .update(values)
                .eq("id", value: id.uuidString)
                .execute()
        } catch {
            print("Supabase updateComment error:", error)
        }
    }

    // Delete (enforced by RLS to own comments only)
    func deleteComment(id: UUID) async {
        do {
            _ = try await client
                .from("comments")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
        } catch {
            print("Supabase deleteComment error:", error)
        }
    }
}

// MARK: - Share With Agent Sheet
private struct ShareWithAgentSheet: View {
    var onDismiss: (Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var agentEmail = ""
    @State private var isSharing = false
    @State private var shareSuccess = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if shareSuccess {
                    successView
                } else {
                    shareForm
                }
            }
            .padding()
            .navigationTitle("Share with Agent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                        onDismiss(false)
                    }
                }
            }
        }
    }
    
    private var shareForm: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Secure Document Sharing")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)
                
                Text("Share your complete document package with your real estate agent securely.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Agent's Email")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                
                TextField("Enter agent's email", text: $agentEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("What's Included")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("All uploaded documents")
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("AI-processed information")
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Progress tracking")
                        Spacer()
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Button(action: shareWithAgent) {
                HStack {
                    if isSharing {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(isSharing ? "Sharing..." : "Share Securely")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isSharing || agentEmail.isEmpty || !isValidEmail(agentEmail))
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var successView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            VStack(spacing: 12) {
                Text("Documents Shared!")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)
                
                Text("Your document package has been securely shared with your agent.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Done") {
                dismiss()
                onDismiss(true)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
    
    private func shareWithAgent() {
        isSharing = true
        errorMessage = ""
        
        // Simulate sharing process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isSharing = false
            if isValidEmail(agentEmail) {
                shareSuccess = true
            } else {
                errorMessage = "Please enter a valid email address"
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

// MARK: - Templates Sheet
private struct TemplatesSheet: View {
    let onGenerate: (Data, String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Common Templates") {
                    Button { generateTemplate(title: "Employment Verification", filename: "Employment_Verification.pdf") } label: {
                        Label("Employment Verification", systemImage: "briefcase.fill")
                    }
                    Button { generateTemplate(title: "Reference Letter", filename: "Reference_Letter.pdf") } label: {
                        Label("Reference Letter", systemImage: "person.2.fill")
                    }
                    Button { generateTemplate(title: "Landlord Reference", filename: "Landlord_Reference.pdf") } label: {
                        Label("Landlord Reference", systemImage: "house.fill")
                    }
                    Button { generateTemplate(title: "Identity Affidavit", filename: "Identity_Affidavit.pdf") } label: {
                        Label("Identity Affidavit", systemImage: "person.text.rectangle.fill")
                    }
                }
            }
            .navigationTitle("Templates")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }
    
    private func generateTemplate(title: String, filename: String) {
        let body = "Generated by HOMEY • \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))\n\nThis is a pre-filled template. Replace placeholder fields with your information."
        if let data = Self.renderPDF(title: title, body: body) {
            onGenerate(data, filename)
            dismiss()
        }
    }
    
    static func renderPDF(title: String, body: String) -> Data? {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        return renderer.pdfData { ctx in
            ctx.beginPage()
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold)
            ]
            let bodyAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14)
            ]
            let titleSize = (title as NSString).size(withAttributes: titleAttrs)
            (title as NSString).draw(at: CGPoint(x: 40, y: 40), withAttributes: titleAttrs)
            let bodyRect = CGRect(x: 40, y: 40 + titleSize.height + 16, width: pageRect.width - 80, height: pageRect.height - 120)
            (body as NSString).draw(in: bodyRect, withAttributes: bodyAttrs)
        }
    }
}

// MARK: - Comments Sheet
private struct CommentsSheet: View {
    let vaults: [DocumentVault]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex: Int = 0
    @State private var commentText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Category", selection: $selectedIndex) {
                    ForEach(vaults.indices, id: \.self) { i in
                        Text(vaults[i].name).tag(i)
                    }
                }
                .pickerStyle(.menu)
                
                TextEditor(text: $commentText)
                    .frame(minHeight: 160)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.2)))
                    .padding(.top, 6)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Comments & Notes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let targetId = String(describing: vaults[selectedIndex].id)
                        Task {
                            await SupabaseCommentsRepository.shared.addComment(targetId: targetId, author: "You", text: commentText)
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DocumentVaultView(vm: DocumentsViewModel())
    }
    .preferredColorScheme(.dark)
}