import SwiftUI

struct VizaVisionView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var viewModel = VizaVisionViewModel()
    @State private var selectedTool: VisionTool = .moodboard
    @State private var selectedColor: Color = .blue
    @State private var showingColorPicker = false
    @State private var showingARScanner = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AnimatedGradientBackground(for: .homey)
                    .ignoresSafeArea()
                    .overlay(
                        LinearGradient(
                            colors: [Color.black.opacity(0.25), .clear, Color.black.opacity(0.15)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()
                    )
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Hero Section
                        heroSection
                        
                        // Vision Tools Section
                        visionToolsSection
                        
                        // Active Tool Content
                        activeToolContent
                        
                        // Recent Projects
                        recentProjectsSection
                        
                        // Bottom padding for footer
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .sheet(isPresented: $showingColorPicker) {
            ColorPickerSheet(selectedColor: $selectedColor)
        }
    }
    
    private var heroSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Vision Studio")
                        .font(.custom("PlayfairDisplay-Bold", size: 32))
                        .foregroundColor(.white)
                    
                    Text("Bring your design ideas to life")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                }
                
                Spacer()
                
                Button(action: { viewModel.createNewProject() }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle().stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private var visionToolsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vision Tools")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(VisionTool.allCases, id: \.self) { tool in
                        VisionToolCard(
                            tool: tool,
                            isSelected: selectedTool == tool,
                            action: { selectedTool = tool }
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var activeToolContent: some View {
        VStack(spacing: 20) {
            switch selectedTool {
            case .moodboard:
                MoodboardView(viewModel: viewModel)
            case .colorPalette:
                ColorPaletteView(viewModel: viewModel, showingColorPicker: $showingColorPicker)
            case .floorPlan:
                FloorPlanView(viewModel: viewModel)
            case .ar3D:
                AR3DView(viewModel: viewModel)
            }
        }
    }
    
    private var recentProjectsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Projects")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("View All") {
                    viewModel.showAllProjects()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(viewModel.recentProjects) { project in
                    ProjectCard(project: project) {
                        viewModel.openProject(project)
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct VisionToolCard: View {
    let tool: VisionTool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: tool.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                
                Text(tool.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            }
            .frame(width: 80, height: 80)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(isSelected ? 0.3 : 0.15), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MoodboardView: View {
    @ObservedObject var viewModel: VizaVisionViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Moodboard Creator")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(0..<9) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.1))
                        .frame(height: 100)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.5))
                        )
                        .onTapGesture {
                            viewModel.addToMoodboard()
                        }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}

struct ColorPaletteView: View {
    @ObservedObject var viewModel: VizaVisionViewModel
    @Binding var showingColorPicker: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Color Palette Generator")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                ForEach(viewModel.colorPalette, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.3), lineWidth: 2)
                        )
                }
                
                Button(action: { showingColorPicker = true }) {
                    Circle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                        )
                }
            }
            
            Button("Generate New Palette") {
                viewModel.generateColorPalette()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25))
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .foregroundColor(.white)
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}

struct FloorPlanView: View {
    @ObservedObject var viewModel: VizaVisionViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Floor Plan Designer")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.1))
                .frame(height: 200)
                .overlay(
                    VStack(spacing: 12) {
                        Image(systemName: "square.grid.3x3")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("Tap to start designing")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                )
                .onTapGesture {
                    viewModel.startFloorPlanDesign()
                }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}

struct AR3DView: View {
    @ObservedObject var viewModel: VizaVisionViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("AR 3D Visualization")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.1))
                .frame(height: 200)
                .overlay(
                    VStack(spacing: 12) {
                        Image(systemName: "arkit")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("Launch AR Experience")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                )
                .onTapGesture {
                    viewModel.launchARExperience()
                }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}

struct ProjectCard: View {
    let project: VisionProject
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.1))
                    .frame(height: 100)
                    .overlay(
                        Image(systemName: project.icon)
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.5))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(project.lastModified)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ColorPickerSheet: View {
    @Binding var selectedColor: Color
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ColorPicker("Select Color", selection: $selectedColor)
                .padding()
                .navigationTitle("Color Picker")
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

// MARK: - Data Models

enum VisionTool: CaseIterable {
    case moodboard, colorPalette, floorPlan, ar3D
    
    var title: String {
        switch self {
        case .moodboard: return "Moodboard"
        case .colorPalette: return "Colors"
        case .floorPlan: return "Floor Plan"
        case .ar3D: return "AR 3D"
        }
    }
    
    var icon: String {
        switch self {
        case .moodboard: return "photo.on.rectangle"
        case .colorPalette: return "paintpalette"
        case .floorPlan: return "square.grid.3x3"
        case .ar3D: return "arkit"
        }
    }
}

struct VisionProject: Identifiable {
    let id = UUID()
    let name: String
    let lastModified: String
    let icon: String
}

// MARK: - Extensions

// MARK: - Preview

#Preview {
    VizaVisionView()
        .environmentObject(ThemeManager())
}