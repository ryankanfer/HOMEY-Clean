//
//  FurnitureToolbar.swift
//  HOMEY Clean
//
//  Created by Viza Vision Studio
//

import SwiftUI

struct FurnitureToolbar: View {
    @ObservedObject var viewModel: VizaVisionViewModel
    let geometry: GeometryProxy
    
    @State private var draggedItem: FurnitureItem?
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Toolbar Header
            toolbarHeader
            
            // Furniture Items Grid
            furnitureGrid
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    // MARK: - Toolbar Header
    
    private var toolbarHeader: some View {
        HStack {
            Image(systemName: "sofa.fill")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
            
            Text("Furniture")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            // Category filter (future enhancement)
            Button {
                // Toggle furniture categories
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
    
    // MARK: - Furniture Grid
    
    private var furnitureGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6),
            spacing: 8
        ) {
            ForEach(viewModel.availableFurniture) { furniture in
                furnitureItem(furniture)
            }
        }
    }
    
    private func furnitureItem(_ furniture: FurnitureItem) -> some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            // Furniture Image
            Image(furniture.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .colorMultiply(furniture.canRecolor ? furniture.primaryColor : .white)
                .scaleEffect(isDragging && draggedItem?.id == furniture.id ? 0.8 : 1.0)
                .opacity(isDragging && draggedItem?.id == furniture.id ? 0.5 : 1.0)
            
            // Drag overlay
            if isDragging && draggedItem?.id == furniture.id {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                    )
            }
        }
        .frame(width: 48, height: 48)
        .onDrag {
            // Start drag operation
            startDrag(with: furniture)
            return NSItemProvider(object: furniture.id.uuidString as NSString)
        }
        .simultaneousGesture(
            DragGesture(coordinateSpace: .global)
                .onChanged { value in
                    handleDragChanged(value, for: furniture)
                }
                .onEnded { value in
                    handleDragEnded(value, for: furniture)
                }
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
    }
    
    // MARK: - Drag Handling
    
    private func startDrag(with furniture: FurnitureItem) {
        draggedItem = furniture
        isDragging = true
        viewModel.selectedFurniture = furniture
        viewModel.isDragging = true
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func handleDragChanged(_ value: DragGesture.Value, for furniture: FurnitureItem) {
        guard draggedItem?.id == furniture.id else { return }
        
        dragOffset = value.translation
        viewModel.dragOffset = value.translation
        
        // Update drag position for preview
        let globalPosition = CGPoint(
            x: value.location.x + value.translation.width,
            y: value.location.y + value.translation.height
        )
        
        // Check if dragging over stage area
        let stageFrame = calculateStageFrame()
        let isOverStage = stageFrame.contains(globalPosition)
        
        // Visual feedback for valid drop zone
        viewModel.isOverValidDropZone = isOverStage
    }
    
    private func handleDragEnded(_ value: DragGesture.Value, for furniture: FurnitureItem) {
        guard draggedItem?.id == furniture.id else { return }
        
        let globalPosition = CGPoint(
            x: value.location.x + value.translation.width,
            y: value.location.y + value.translation.height
        )
        
        let stageFrame = calculateStageFrame()
        
        if stageFrame.contains(globalPosition) {
            // Convert global position to stage-relative position
            let stagePosition = CGPoint(
                x: globalPosition.x - stageFrame.minX,
                y: globalPosition.y - stageFrame.minY
            )
            
            // Snap to grid
            let snappedPosition = snapToGrid(stagePosition, in: stageFrame.size)
            
            // Create new furniture item for the stage
            var newFurniture = FurnitureItem(
                name: furniture.name,
                imageName: furniture.imageName,
                category: furniture.category,
                shadowType: furniture.shadowType
            )
            newFurniture.position = snappedPosition
            newFurniture.isPlaced = true
            newFurniture.primaryColorHex = furniture.primaryColorHex
            newFurniture.accentColorHex = furniture.accentColorHex
            newFurniture.canRecolor = furniture.canRecolor
            
            // Add to stage
            viewModel.addFurnitureToStage(newFurniture)
            
            // Success haptic
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
        } else {
            // Failed drop haptic
            let errorFeedback = UINotificationFeedbackGenerator()
            errorFeedback.notificationOccurred(.error)
        }
        
        // Reset drag state
        resetDragState()
    }
    
    private func resetDragState() {
        isDragging = false
        draggedItem = nil
        dragOffset = .zero
        viewModel.isDragging = false
        viewModel.selectedFurniture = nil
        viewModel.dragOffset = .zero
        viewModel.isOverValidDropZone = false
    }
    
    // MARK: - Helper Methods
    
    private func calculateStageFrame() -> CGRect {
        // Calculate the stage area frame in global coordinates
        // This would need to be coordinated with the main view's stage area
        let stageWidth: CGFloat = 200
        let stageHeight: CGFloat = 150
        let centerX = geometry.size.width / 2
        let centerY = geometry.size.height * 0.4 // Approximate stage center
        
        return CGRect(
            x: centerX - stageWidth / 2,
            y: centerY - stageHeight / 2,
            width: stageWidth,
            height: stageHeight
        )
    }
    
    private func snapToGrid(_ position: CGPoint, in size: CGSize) -> CGPoint {
        let gridSize: CGFloat = 20
        
        let snappedX = round(position.x / gridSize) * gridSize
        let snappedY = round(position.y / gridSize) * gridSize
        
        // Ensure position is within bounds
        let clampedX = max(0, min(snappedX, size.width))
        let clampedY = max(0, min(snappedY, size.height))
        
        return CGPoint(x: clampedX, y: clampedY)
    }
}

// MARK: - Drag Preview Component

struct FurnitureDragPreview: View {
    let furniture: FurnitureItem
    let offset: CGSize
    let isOverValidZone: Bool
    
    var body: some View {
        ZStack {
            // Shadow
            if furniture.shadowType != .none {
                Image(furniture.shadowType.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                    .opacity(0.4)
                    .offset(x: 2, y: 2)
            }
            
            // Furniture item
            Image(furniture.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .colorMultiply(furniture.canRecolor ? furniture.primaryColor : .white)
            
            // Valid drop zone indicator
            if isOverValidZone {
                Circle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: 50, height: 50)
                    .opacity(0.8)
            }
        }
        .scaleEffect(1.1)
        .opacity(0.9)
        .offset(offset)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: offset)
    }
}
