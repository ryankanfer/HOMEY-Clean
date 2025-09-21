//
//  SaveExportSheet.swift
//  HOMEY Clean
//
//  Created by Viza Vision Studio
//

import SwiftUI

struct SaveExportSheet: View {
    @ObservedObject var viewModel: VizaVisionViewModel
    @ObservedObject var saveManager: SaveExportManager
    @Binding var isPresented: Bool
    
    @State private var selectedTab = 0
    @State private var showingBeforeAfter = false
    @State private var exportInProgress = false
    @State private var showingShareSheet = false
    @State private var shareURL: URL?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                tabSelector
                
                // Content
                TabView(selection: $selectedTab) {
                    // Save Look Tab
                    saveLookTab
                        .tag(0)
                    
                    // Saved Looks Tab
                    savedLooksTab
                        .tag(1)
                    
                    // Export Tab
                    exportTab
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Save & Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = shareURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            tabButton(title: "Save", icon: "bookmark.fill", index: 0)
            tabButton(title: "Saved", icon: "folder.fill", index: 1)
            tabButton(title: "Export", icon: "square.and.arrow.up", index: 2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
    }
    
    private func tabButton(title: String, icon: String, index: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(selectedTab == index ? .blue : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedTab == index ? Color.blue.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Save Look Tab
    
    private var saveLookTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Current Look Preview
                currentLookPreview
                
                // Save Options
                saveOptionsSection
                
                // Before/After Comparison
                if showingBeforeAfter {
                    beforeAfterSection
                }
                
                Spacer(minLength: 100)
            }
            .padding()
        }
    }
    
    private var currentLookPreview: some View {
        VStack(spacing: 12) {
            Text("Current Look")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Snapshot preview placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "camera.viewfinder")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        
                        Text("Live Preview")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                )
        }
    }
    
    private var saveOptionsSection: some View {
        VStack(spacing: 16) {
            // Save Look Button
            Button {
                Task {
                    await saveLook()
                }
            } label: {
                HStack {
                    Image(systemName: "bookmark.fill")
                    Text("Save This Look")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            
            // Before/After Toggle
            Button {
                withAnimation {
                    showingBeforeAfter.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.left.arrow.right")
                    Text("Compare Before/After")
                    Spacer()
                    Image(systemName: showingBeforeAfter ? "chevron.up" : "chevron.down")
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    private var beforeAfterSection: some View {
        VStack(spacing: 12) {
            Text("Before vs After")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                // Before
                VStack {
                    Text("BEFORE")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 120)
                        .overlay(
                            Text("Original")
                                .font(.caption)
                                .foregroundColor(.gray)
                        )
                }
                
                // After
                VStack {
                    Text("AFTER")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 120)
                        .overlay(
                            Text("Styled")
                                .font(.caption)
                                .foregroundColor(.gray)
                        )
                }
            }
        }
    }
    
    // MARK: - Saved Looks Tab
    
    private var savedLooksTab: some View {
        Group {
            if saveManager.savedLooks.isEmpty {
                emptyStateView
            } else {
                savedLooksList
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "bookmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Saved Looks")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text("Save your first look to get started")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button("Save Current Look") {
                selectedTab = 0
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(25)
            
            Spacer()
        }
        .padding()
    }
    
    private var savedLooksList: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(saveManager.savedLooks) { look in
                    savedLookCard(look)
                }
            }
            .padding()
        }
    }
    
    private func savedLookCard(_ look: SavedLook) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Snapshot
            Group {
                if let snapshot = look.snapshot {
                    Image(uiImage: snapshot)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
            }
            .frame(height: 120)
            .clipped()
            .cornerRadius(8)
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(look.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(DateFormatter.localizedString(from: look.timestamp, dateStyle: .short, timeStyle: .none))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // Tags
                if !look.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(look.tags.prefix(2), id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .contextMenu {
            Button("Export", systemImage: "square.and.arrow.up") {
                exportLook(look)
            }
            
            Button("Delete", systemImage: "trash", role: .destructive) {
                saveManager.deleteSavedLook(look)
            }
        }
    }
    
    // MARK: - Export Tab
    
    private var exportTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Export Options
                exportOptionsSection
                
                // Recent Exports
                if saveManager.lastExportedURL != nil {
                    recentExportsSection
                }
                
                Spacer(minLength: 100)
            }
            .padding()
        }
    }
    
    private var exportOptionsSection: some View {
        VStack(spacing: 16) {
            Text("Export Options")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Export Current Look
            exportOptionButton(
                title: "Export Current Look",
                subtitle: "Generate PDF moodboard",
                icon: "doc.richtext",
                action: exportCurrentLook
            )
            
            // Export All Saved Looks
            if !saveManager.savedLooks.isEmpty {
                exportOptionButton(
                    title: "Export All Saved Looks",
                    subtitle: "\(saveManager.savedLooks.count) looks",
                    icon: "folder",
                    action: exportAllLooks
                )
            }
        }
    }
    
    private func exportOptionButton(title: String, subtitle: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if exportInProgress {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .disabled(exportInProgress)
    }
    
    private var recentExportsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Export")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let url = saveManager.lastExportedURL {
                HStack {
                    Image(systemName: "doc.richtext")
                        .foregroundColor(.red)
                    
                    VStack(alignment: .leading) {
                        Text(url.lastPathComponent)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("PDF Document")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button("Share") {
                        shareURL = url
                        showingShareSheet = true
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveLook() async {
        // Capture snapshot of current view
        // This would need to be implemented with proper view capture
        let placeholderImage = UIImage(systemName: "photo")!
        
        let savedLook = saveManager.saveLook(
            from: viewModel.currentSession,
            snapshot: placeholderImage,
            onSaved: {
                viewModel.onLookSaved()
            }
        )
        
        // Show success feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Switch to saved looks tab
        withAnimation {
            selectedTab = 1
        }
    }
    
    private func exportCurrentLook() {
        exportInProgress = true
        
        // Create a temporary saved look for export
        let placeholderImage = UIImage(systemName: "photo")!
        let tempLook = SavedLook(
            id: UUID().uuidString,
            name: "Current Look",
            timestamp: Date(),
            snapshot: placeholderImage,
            session: viewModel.currentSession,
            tags: []
        )
        
        exportLook(tempLook)
    }
    
    private func exportLook(_ look: SavedLook) {
        exportInProgress = true
        
        saveManager.exportToPDF(look: look) { result in
            DispatchQueue.main.async {
                exportInProgress = false
                
                switch result {
                case .success(let url):
                    shareURL = url
                    showingShareSheet = true
                case .failure(let error):
                    print("Export failed: \(error.localizedDescription)")
                    // Show error alert
                }
            }
        }
    }
    
    private func exportAllLooks() {
        // Future enhancement: Export multiple looks as a collection
    }
}

// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
