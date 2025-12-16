import SwiftUI

struct DoorSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDoorIndex: Int? = nil
    @State private var showingDoor: Bool = false
    @State private var currentOffset: CGFloat = 0

    var onDoorSelected: (DoorStyle) -> Void

    private let doors: [DoorStyle] = [
        .classic,
        .french,
        .rustic,
        .modern,
        .ornate,
        .bold
    ]

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.2, blue: 0.6),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if showingDoor, let index = selectedDoorIndex {
                // Full-screen door animation
                DoorView(style: doors[index])
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(10)
            } else {
                // Door carousel
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Welcome.")
                            .font(.custom("PlayfairDisplay-Regular", size: 42))
                            .foregroundStyle(.white)

                        Text("Choose your entrance.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 40)

                    // Scrollable door cards
                    TabView(selection: $selectedDoorIndex) {
                        ForEach(doors.indices, id: \.self) { index in
                            DoorCard(
                                style: doors[index],
                                isActive: selectedDoorIndex == index,
                                onSelect: {
                                    selectedDoorIndex = index
                                    withAnimation(.easeOut(duration: 0.5)) {
                                        showingDoor = true
                                    }

                                    // Call completion after animation
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        onDoorSelected(doors[index])
                                    }
                                }
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 500)

                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(doors.indices, id: \.self) { index in
                            Circle()
                                .fill(selectedDoorIndex == index ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut, value: selectedDoorIndex)
                        }
                    }
                    .padding(.top, 24)

                    Spacer()
                }
            }
        }
        .onAppear {
            selectedDoorIndex = 0
        }
    }
}

// MARK: - Door Card

private struct DoorCard: View {
    let style: DoorStyle
    let isActive: Bool
    let onSelect: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Door preview
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: style.gradientColors.map { Color($0) },
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .frame(height: 400)

                // Door icon/illustration
                VStack(spacing: 16) {
                    Image(systemName: style.iconName)
                        .font(.system(size: 80))
                        .foregroundStyle(.white.opacity(0.9))

                    Text(style.rawValue.capitalized)
                        .font(.custom("PlayfairDisplay-Regular", size: 28))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 20)

            // Enter button
            if isActive {
                Button {
                    onSelect()
                } label: {
                    HStack(spacing: 8) {
                        Text("Enter")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.white)
                    .foregroundStyle(.black)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.top, 24)
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
}

// MARK: - Full Door View

private struct DoorView: View {
    let style: DoorStyle

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: style.gradientColors.map { Color($0) },
                startPoint: .top,
                endPoint: .bottom
            )

            // Animated door opening effect
            VStack {
                Spacer()

                // Door icon
                Image(systemName: style.iconName)
                    .font(.system(size: 120))
                    .foregroundStyle(.white.opacity(0.3))

                Spacer()
            }
        }
    }
}

// MARK: - Door Style

enum DoorStyle: String, CaseIterable {
    case classic = "classic"
    case french = "french"
    case rustic = "rustic"
    case modern = "modern"
    case ornate = "ornate"
    case bold = "bold"

    var gradientColors: [UIColor] {
        switch self {
        case .classic:
            return [
                UIColor(red: 0.7, green: 0.6, blue: 0.5, alpha: 1.0),
                UIColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0)
            ]
        case .french:
            return [
                UIColor(red: 0.95, green: 0.95, blue: 0.9, alpha: 1.0),
                UIColor(red: 0.85, green: 0.82, blue: 0.75, alpha: 1.0)
            ]
        case .rustic:
            return [
                UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0),
                UIColor(red: 0.25, green: 0.2, blue: 0.15, alpha: 1.0)
            ]
        case .modern:
            return [
                UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0),
                UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
            ]
        case .ornate:
            return [
                UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0),
                UIColor(red: 0.5, green: 0.3, blue: 0.15, alpha: 1.0)
            ]
        case .bold:
            return [
                UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0),
                UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
            ]
        }
    }

    var iconName: String {
        switch self {
        case .classic:
            return "door.left.hand.closed"
        case .french:
            return "door.french.closed"
        case .rustic:
            return "house.lodge"
        case .modern:
            return "rectangle.portrait"
        case .ornate:
            return "crown"
        case .bold:
            return "square.split.2x2"
        }
    }
}
