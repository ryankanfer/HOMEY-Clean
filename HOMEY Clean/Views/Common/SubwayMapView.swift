import SwiftUI

// MARK: - Interactive Subway Map
struct SubwayMapView: View {
    let currentStation: Int
    let totalStations: Int
    let isMoving: Bool
    let doorState: SubwayLineProgress.DoorState
    
    @State private var trainPosition: CGFloat = 0
    @State private var mapOffset: CGFloat = 0
    
    private let stationSpacing: CGFloat = 80
    private let trackHeight: CGFloat = 4
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background tunnel effect
                tunnelBackground
                
                // Subway track
                subwayTrack(width: geometry.size.width)
                
                // Stations
                stationsView(width: geometry.size.width)
                
                // Moving train
                trainView
                    .offset(x: trainPosition)
                    .animation(.easeInOut(duration: 0.8), value: trainPosition)
            }
            .clipped()
            .onAppear {
                updateTrainPosition(containerWidth: geometry.size.width)
            }
            .onChange(of: currentStation) { _ in
                updateTrainPosition(containerWidth: geometry.size.width)
            }
        }
        .frame(height: 120)
    }
    
    private var tunnelBackground: some View {
        LinearGradient(
            colors: [
                Color.black.opacity(0.8),
                Color.gray.opacity(0.2),
                Color.black.opacity(0.8)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(
            // Tunnel lights effect
            HStack(spacing: 40) {
                ForEach(0..<10, id: \.self) { _ in
                    Circle()
                        .fill(Color.yellow.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 10)
            , alignment: .top
        )
    }
    
    private func subwayTrack(width: CGFloat) -> some View {
        VStack(spacing: 8) {
            // Upper rail
            Rectangle()
                .fill(Color.gray.opacity(0.8))
                .frame(height: trackHeight)
            
            // Track ties
            HStack(spacing: 12) {
                ForEach(0..<Int(width / 12), id: \.self) { _ in
                    Rectangle()
                        .fill(Color.brown.opacity(0.6))
                        .frame(width: 8, height: 16)
                }
            }
            
            // Lower rail
            Rectangle()
                .fill(Color.gray.opacity(0.8))
                .frame(height: trackHeight)
        }
    }
    
    private func stationsView(width: CGFloat) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<totalStations, id: \.self) { index in
                VStack(spacing: 4) {
                    // Station platform
                    Rectangle()
                        .fill(stationColor(for: index))
                        .frame(width: 12, height: 20)
                        .cornerRadius(6)
                        .overlay(
                            // Station number
                            Text("\(index + 1)")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                        )
                    
                    // Station name
                    if index < SubwayStation.allStations.count {
                        Text(SubwayStation.allStations[index].name.components(separatedBy: " ").first ?? "")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(stationTextColor(for: index))
                            .lineLimit(1)
                    }
                }
                .scaleEffect(index == currentStation ? 1.2 : 1.0)
                .animation(.spring(response: 0.3), value: currentStation)
                
                if index < totalStations - 1 {
                    // Track segment between stations
                    Rectangle()
                        .fill(trackSegmentColor(for: index))
                        .frame(width: stationSpacing - 12, height: 2)
                        .animation(.easeInOut(duration: 0.5), value: currentStation)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var trainView: some View {
        HStack(spacing: 2) {
            // Train cars
            ForEach(0..<3, id: \.self) { carIndex in
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [Color.orange, Color.red.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 16, height: 12)
                    .overlay(
                        // Windows
                        HStack(spacing: 2) {
                            ForEach(0..<2, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.yellow.opacity(0.8))
                                    .frame(width: 3, height: 6)
                                    .cornerRadius(1)
                            }
                        }
                    )
                    .scaleEffect(isMoving ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2).repeatCount(isMoving ? 10 : 1), value: isMoving)
            }
            
            // Train front light
            Circle()
                .fill(Color.white)
                .frame(width: 4, height: 4)
                .opacity(isMoving ? 1.0 : 0.7)
                .animation(.easeInOut(duration: 0.3).repeatForever(), value: isMoving)
        }
    }
    
    private func stationColor(for index: Int) -> Color {
        if index < currentStation {
            return .green.opacity(0.8) // Visited stations
        } else if index == currentStation {
            switch doorState {
            case .opening, .open:
                return .cyan
            case .closing, .closed:
                return .orange
            }
        } else {
            return .gray.opacity(0.4) // Future stations
        }
    }
    
    private func stationTextColor(for index: Int) -> Color {
        if index <= currentStation {
            return .white
        } else {
            return .gray.opacity(0.6)
        }
    }
    
    private func trackSegmentColor(for index: Int) -> Color {
        if index < currentStation {
            return .green.opacity(0.6)
        } else {
            return .gray.opacity(0.3)
        }
    }
    
    private func updateTrainPosition(containerWidth: CGFloat) {
        let totalTrackWidth = CGFloat(totalStations - 1) * stationSpacing
        let availableWidth = containerWidth - 60 // Account for padding
        let scale = availableWidth / totalTrackWidth
        
        let targetPosition = CGFloat(currentStation) * stationSpacing * scale
        trainPosition = targetPosition
    }
}

// MARK: - Enhanced Progress Line with Map Integration
struct EnhancedSubwayProgressLine: View {
    let currentStation: Int
    let totalStations: Int
    let isMoving: Bool
    let doorState: SubwayLineProgress.DoorState
    
    var body: some View {
        VStack(spacing: 16) {
            // Interactive subway map
            SubwayMapView(
                currentStation: currentStation,
                totalStations: totalStations,
                isMoving: isMoving,
                doorState: doorState
            )
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.cyan.opacity(0.3), lineWidth: 1)
                    )
            )
            
            // Journey status
            HStack {
                Image(systemName: isMoving ? "train.side.front.car" : "building.2")
                    .foregroundColor(isMoving ? .orange : .cyan)
                    .font(.caption)
                
                Text(isMoving ? "En Route..." : "At Station")
                    .font(.caption.bold())
                    .foregroundColor(isMoving ? .orange : .cyan)
                
                Spacer()
                
                Text("\(currentStation + 1) of \(totalStations)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        SubwayMapView(
            currentStation: 2,
            totalStations: 5,
            isMoving: false,
            doorState: .open
        )
        
        EnhancedSubwayProgressLine(
            currentStation: 2,
            totalStations: 5,
            isMoving: true,
            doorState: .closing
        )
    }
    .padding()
    .background(Color.black)
}