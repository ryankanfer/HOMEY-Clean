import SwiftUI

struct CharlieDashboard: View {
    @State private var journeyProgress: Double = 0.48 // 48% progress
    @State private var showProgressSheet = false
    @State private var orbRotation: Double = 0
    @State private var orbGlow = false
    @State private var currentFeatureIndex = 0
    @State private var featureTimer: Timer?
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    // Sample data
    private let characterTasks = CharacterTask.sampleTasks
    private let tonightFeatures = TonightFeature.sampleFeatures
    private let upcomingTasks = UpcomingTask.sampleTasks
    private let storyStats = StoryStat.sampleStats
    private let learningCards = LearningCard.sampleCards

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Film grain background
                Image("film_grain_bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Hero Section
                        VStack(spacing: 24) {
                            // Header
                            VStack(spacing: 12) {
                                Text("Welcome back.")
                                    .font(.system(size: 32, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                    .opacity(0)
                                    .onAppear {
                                        withAnimation(.easeOut(duration: 0.35).delay(0.1)) {
                                            // Animation handled by opacity
                                        }
                                    }

                                Text("Your story is ready.")
                                    .font(.system(size: 24, weight: .regular))
                                    .foregroundColor(.white.opacity(0.9))
                                    .opacity(0)
                                    .onAppear {
                                        withAnimation(.easeOut(duration: 0.35).delay(0.2)) {
                                            // Animation handled by opacity
                                        }
                                    }
                            }

                            // Centered Progress Orb
                            EnhancedProgressOrb(
                                progress: journeyProgress,
                                rotation: $orbRotation,
                                glowing: $orbGlow,
                                geometry: geometry
                            ) {
                                showProgressSheet = true
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 60)

                        // Today - Character Task Chips
                        SectionView(title: "Today") {
                            CharacterTaskChipsView(tasks: characterTasks)
                        }

                        // Tonight's Features - Carousel
                        SectionView(title: "Tonight's Features") {
                            TonightFeaturesCarousel(
                                features: tonightFeatures,
                                currentIndex: $currentFeatureIndex
                            )
                        }

                        // Coming Up - Horizontal Scroll
                        SectionView(title: "Coming Up") {
                            ComingUpScrollView(tasks: upcomingTasks)
                        }

                        // Your Story So Far - Stats
                        SectionView(title: "Your Story So Far") {
                            StoryStatsView(stats: storyStats)
                        }

                        // Education Center - Learning Cards
                        SectionView(title: "Education Center") {
                            LearningCenterView(cards: learningCards)
                        }

                        Spacer(minLength: 100) // Space for navigation footer
                    }
                }
            }
        }
        .onAppear {
            startAnimations()
            startFeatureCarousel()
        }
        .onDisappear {
            featureTimer?.invalidate()
        }
        .sheet(isPresented: $showProgressSheet) {
            ProgressSheet(progress: journeyProgress, isPresented: $showProgressSheet)
        }
    }

    private func startAnimations() {
        // Start orb rotation (20s duration)
        if !reduceMotion {
            withAnimation(
                Animation.linear(duration: 20.0)
                    .repeatForever(autoreverses: false)
            ) {
                orbRotation = 360
            }
        }

        // Start breathing glow (6s cycle)
        withAnimation(
            Animation.easeInOut(duration: 6.0)
                .repeatForever(autoreverses: true)
        ) {
            orbGlow = true
        }
    }

    private func startFeatureCarousel() {
        featureTimer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentFeatureIndex = (currentFeatureIndex + 1) % tonightFeatures.count
            }
        }
    }
}

// MARK: - Enhanced Progress Orb

struct EnhancedProgressOrb: View {
    let progress: Double
    @Binding var rotation: Double
    @Binding var glowing: Bool
    let geometry: GeometryProxy
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    private var orbSize: CGFloat {
        // 48-56% of screen width on iPhone Pro Max
        let screenWidth = geometry.size.width
        return screenWidth * 0.52 // 52% as middle ground
    }

    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            action()
        }) {
            ZStack {
                // Base orb with breathing glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.blue.opacity(0.3),
                                Color.purple.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: orbSize * 0.3,
                            endRadius: orbSize * 0.6
                        )
                    )
                    .frame(width: orbSize, height: orbSize)
                    .scaleEffect(glowing ? 1.1 : 1.0)
                    .opacity(glowing ? 0.8 : 0.4)

                // Main orb
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.8), .purple.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: orbSize * 0.8, height: orbSize * 0.8)
                    .background(.ultraThinMaterial, in: Circle())
                    .rotationEffect(.degrees(reduceMotion ? 0 : rotation))

                // Progress arc
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: orbSize * 0.9, height: orbSize * 0.9)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 0.9, bounce: 0.25), value: progress)

                // Progress percentage
                Text("\(Int(progress * 100))%")
                    .font(.system(size: orbSize * 0.12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Journey progress: \(Int(progress * 100)) percent complete")
        .accessibilityHint("Tap to view detailed progress")
    }
}

// MARK: - Section View

struct SectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .opacity(0)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.35)) {
                        // Animation handled by opacity modifier
                    }
                }

            content
        }
    }
}

// MARK: - Character Task Chips View

struct CharacterTaskChipsView: View {
    let tasks: [CharacterTask]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(Array(tasks.prefix(6)), id: \.id) { task in
                    CharacterTaskChip(task: task)
                }
            }
            .padding(.horizontal, 24)
        }
        .scrollTargetBehavior(.paging)
    }
}

struct CharacterTaskChip: View {
    let task: CharacterTask
    @State private var isPressed = false

    var body: some View {
        Button {
            // Deep link to character section
        } label: {
            HStack(spacing: 12) {
                // Character avatar
                Circle()
                    .fill(task.character.primaryColor.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay {
                        Text(String(task.character.rawValue.first ?? "?"))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }

                // Task title
                Text(task.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)

                // Status dot
                Circle()
                    .fill(task.status == .completed ? .green : task.status == .inProgress ? .orange : .gray)
                    .frame(width: 8, height: 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) {} onPressingChanged: { pressing in
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                isPressed = pressing
            }
        }
    }
}

// MARK: - Tonight's Features Carousel

struct TonightFeaturesCarousel: View {
    let features: [TonightFeature]
    @Binding var currentIndex: Int

    var body: some View {
        VStack(spacing: 16) {
            // Feature cards
            TabView(selection: $currentIndex) {
                ForEach(Array(features.enumerated()), id: \.element.id) { index, feature in
                    TonightFeatureCard(feature: feature)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 120)

            // Progress dots
            HStack(spacing: 8) {
                ForEach(0 ..< features.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? .white : .white.opacity(0.3))
                        .frame(width: 6, height: 6)
                        .animation(.easeInOut(duration: 0.3), value: currentIndex)
                }
            }
        }
        .padding(.horizontal, 24)
    }
}

struct TonightFeatureCard: View {
    let feature: TonightFeature
    @State private var isPressed = false

    var body: some View {
        Button {
            // Handle feature action
        } label: {
            HStack(spacing: 16) {
                // Glowing icon
                ZStack {
                    Circle()
                        .fill(feature.glowColor.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .blur(radius: 8)

                    Image(systemName: feature.iconName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(feature.glowColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(feature.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)

                    Text(feature.subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            }
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 8)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) {} onPressingChanged: { pressing in
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                isPressed = pressing
            }
        }
    }
}

// MARK: - Coming Up Scroll View

struct ComingUpScrollView: View {
    let tasks: [UpcomingTask]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(tasks) { task in
                    ComingUpCard(task: task)
                }
            }
            .padding(.horizontal, 24)
        }
        .scrollTargetBehavior(.viewAligned)
    }
}

struct ComingUpCard: View {
    let task: UpcomingTask
    @State private var isPressed = false

    private var thumbnailView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(task.priority.color.opacity(0.3))
            .frame(width: 140, height: 100)
            .overlay {
                Image(systemName: task.thumbnailImageName)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(task.priority.color)
            }
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)

            Text(task.subtitle)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(1)
        }
    }

    var body: some View {
        Button {
            // Handle task action
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                thumbnailView
                textContent
            }
            .frame(width: 140)
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.5) {
            // Show preview
        } onPressingChanged: { pressing in
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                isPressed = pressing
            }
        }
    }
}

// MARK: - Story Stats View

struct StoryStatsView: View {
    let stats: [StoryStat]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(stats) { stat in
                    StoryStatTile(stat: stat)
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

struct StoryStatTile: View {
    let stat: StoryStat
    @State private var animatedValue: Int = 0
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: stat.iconName)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(stat.color)

            // Animated count
            Text("\(animatedValue)\(stat.totalValue.map { "/\($0)" } ?? "")")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .onAppear {
                    withAnimation(.easeOut(duration: 1.0)) {
                        animatedValue = stat.currentValue
                    }
                }
                .onChange(of: stat.currentValue) { _, newValue in
                    withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
                        animatedValue = newValue
                    }
                }

            // Title
            Text(stat.title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 100, height: 100)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .onTapGesture {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    isPressed = false
                }
            }
        }
    }
}

// MARK: - Learning Center View

struct LearningCenterView: View {
    let cards: [LearningCard]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(cards) { card in
                    LearningCardView(card: card)
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

struct LearningCardView: View {
    let card: LearningCard
    @State private var isPressed = false

    var body: some View {
        Button {
            // Open reader sheet
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Tag
                Text(card.tag)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.2), in: Capsule())

                // Title and read time
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    Text(card.estimatedReadTime)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                // Progress bar
                if card.progress > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.progressText)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))

                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.white.opacity(0.2))
                                .frame(height: 3)
                                .overlay(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(.white)
                                        .frame(width: geometry.size.width * card.progress, height: 3)
                                }
                        }
                        .frame(height: 3)
                    }
                }
            }
            .frame(width: 160, height: 140)
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) {} onPressingChanged: { pressing in
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                isPressed = pressing
            }
        }
    }
}

// MARK: - Progress Sheet

struct ProgressSheet: View {
    let progress: Double
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Progress visualization
                VStack(spacing: 16) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("Journey Complete")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 32)

                // Milestones
                VStack(alignment: .leading, spacing: 16) {
                    Text("Milestones")
                        .font(.headline)

                    VStack(spacing: 12) {
                        MilestoneRow(title: "Getting Started", isCompleted: progress > 0.25)
                        MilestoneRow(title: "Document Collection", isCompleted: progress > 0.5)
                        MilestoneRow(title: "Property Search", isCompleted: progress > 0.75)
                        MilestoneRow(title: "Offer & Closing", isCompleted: progress >= 1.0)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Your Progress")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct MilestoneRow: View {
    let title: String
    let isCompleted: Bool

    var body: some View {
        HStack {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isCompleted ? .green : .gray)

            Text(title)
                .foregroundColor(isCompleted ? .primary : .secondary)

            Spacer()
        }
    }
}

#Preview {
    CharlieDashboard()
}