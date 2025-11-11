import SwiftUI

struct RightDrawerView<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content

    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Dimmed background
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            isPresented = false
                        }
                    }
                    .transition(.opacity)
            }

            // Drawer content
            HStack {
                Spacer()

                // Replace inner content with ActivityFeedView so it slides in as a right drawer.
                ActivityFeedView(onClose: {
                    withAnimation(.easeInOut) {
                        isPresented = false
                    }
                })
                .frame(width: UIScreen.main.bounds.width * 0.85)
                .background(Color.black)
                .offset(x: isPresented ? 0 : UIScreen.main.bounds.width)
                .transition(.move(edge: .trailing))
            }
            .ignoresSafeArea()
        }
        .animation(.easeInOut, value: isPresented)
    }
}

// MARK: - Main Activity Feed View (Frosted Glass with Adaptive Blur)

struct ActivityFeedView: View {
    @State private var viewMode: ViewMode = .dashboard
    @State private var completedTasks: Set<Int> = []
    @State private var expandedCategories: Set<String> = ["urgent", "today"]
    @State private var scrollOffset: CGFloat = 0
    @Environment(\.colorScheme) var colorScheme

    // Optional close action for when presented inside RightDrawerView
    var onClose: (() -> Void)? = nil

    enum ViewMode {
        case dashboard, timeline
    }

    var body: some View {
        ZStack {
            // Ambient Background Blur Elements
            ambientBackground

            VStack(spacing: 0) {
                // Header with Adaptive Blur
                header

                // Content
                if viewMode == .dashboard {
                    dashboardView
                } else {
                    timelineView
                }
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Ambient Background

    private var ambientBackground: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.12),
                    Color(red: 0.08, green: 0.08, blue: 0.1),
                    Color(red: 0.1, green: 0.1, blue: 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Ambient blur orbs
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 400, height: 400)
                .blur(radius: 100)
                .offset(x: 150, y: -200)

            Circle()
                .fill(Color.purple.opacity(0.1))
                .frame(width: 400, height: 400)
                .blur(radius: 100)
                .offset(x: -150, y: 300)
        }
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 0) {
            // Adaptive blur based on scroll
            Color.clear
                .frame(height: 0)
                .background(
                    VisualEffectBlur(blurStyle: .systemUltraThinMaterial, intensity: min(scrollOffset / 50, 1.0))
                        .ignoresSafeArea(edges: .top)
                )

            VStack(spacing: 16) {
                // Top bar
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Activity")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Wednesday, Nov 5")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Button(action: { onClose?() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                VisualEffectBlur(blurStyle: .systemUltraThinMaterial, intensity: 0.5)
                            )
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // View Toggle
                HStack(spacing: 8) {
                    ViewToggleButton(
                        title: "Dashboard",
                        isSelected: viewMode == .dashboard,
                        action: { withAnimation(.spring(response: 0.3)) { viewMode = .dashboard } }
                    )

                    ViewToggleButton(
                        title: "Timeline",
                        isSelected: viewMode == .timeline,
                        action: { withAnimation(.spring(response: 0.3)) { viewMode = .timeline } }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .background(
                VisualEffectBlur(blurStyle: .systemUltraThinMaterial, intensity: 0.8)
            )
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1),
                alignment: .bottom
            )
        }
    }

    // MARK: - Dashboard View

    private var dashboardView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // AI Recommended Card
                AIRecommendedCard()
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                // Stats Bar
                HStack(spacing: 12) {
                    StatCard(value: 3, label: "Urgent", color: .red)
                    StatCard(value: 5, label: "Today", color: .blue)
                    StatCard(value: 8, label: "This Week", color: .purple)
                }
                .padding(.horizontal, 20)

                // Action Categories
                VStack(spacing: 16) {
                    ActionCategory(
                        title: "🔥 Urgent",
                        count: 3,
                        color: .red,
                        isExpanded: expandedCategories.contains("urgent"),
                        tasks: [
                            ActivityTask(id: 1, title: "Application Deadline", subtitle: "789 Bedford Ave", time: "Due in 3 days", progress: 80),
                            ActivityTask(id: 2, title: "Schedule Follow-up Viewing", subtitle: "Modern 1BR - High interest", time: "Before Friday", progress: 0),
                        ],
                        completedTasks: $completedTasks,
                        onToggle: { toggleCategory("urgent") }
                    )

                    ActionCategory(
                        title: "📅 Today's Focus",
                        count: 5,
                        color: .blue,
                        isExpanded: expandedCategories.contains("today"),
                        tasks: [
                            ActivityTask(id: 3, title: "Apartment Viewing", subtitle: "123 Kent Ave • 2:00 PM", time: "In 3 hours", progress: 100),
                            ActivityTask(id: 4, title: "Upload Pay Stubs", subtitle: "Last 2 months needed", time: "Est. 5 minutes", progress: 0),
                            ActivityTask(id: 5, title: "Review Market Report", subtitle: "Williamsburg price trends", time: "15 min read", progress: 50),
                        ],
                        completedTasks: $completedTasks,
                        onToggle: { toggleCategory("today") }
                    )

                    ActionCategory(
                        title: "📆 This Week",
                        count: 8,
                        color: .purple,
                        isExpanded: expandedCategories.contains("week"),
                        tasks: [
                            ActivityTask(id: 6, title: "Virtual Tour", subtitle: "Thu 3:30 PM", time: "In 2 days", progress: 0),
                            ActivityTask(id: 7, title: "Connect with Moving Company", subtitle: "Drew has 3 recommendations", time: "Flexible", progress: 0),
                        ],
                        completedTasks: $completedTasks,
                        onToggle: { toggleCategory("week") }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .named("scroll")).minY
                    )
                }
            )
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = -value
        }
    }

    // MARK: - Timeline View

    private var timelineView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Critical Milestone
                CriticalMilestoneCard()
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                // Timeline
                VStack(spacing: 24) {
                    TimelineSection(
                        date: "Today",
                        items: [
                            TimelineItem(icon: "🏠", title: "Apartment Viewing", time: "2:00 PM", location: "123 Kent Ave"),
                            TimelineItem(icon: "📄", title: "Upload Pay Stubs", time: "Evening", location: "5 min task")
                        ]
                    )

                    TimelineSection(
                        date: "Tomorrow",
                        items: [
                            TimelineItem(icon: "📹", title: "Virtual Tour", time: "3:30 PM", location: "456 Berry St"),
                        ]
                    )

                    TimelineSection(
                        date: "This Week",
                        items: [
                            TimelineItem(icon: "💳", title: "Credit Check Expires", time: "Thu, Nov 7", location: "Pull new report"),
                            TimelineItem(icon: "⏰", title: "Application Deadline", time: "Fri, Nov 8", location: "789 Bedford Ave")
                        ]
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Helper Functions

    private func toggleCategory(_ category: String) {
        withAnimation(.spring(response: 0.3)) {
            if expandedCategories.contains(category) {
                expandedCategories.remove(category)
            } else {
                expandedCategories.insert(category)
            }
        }
    }
}

// MARK: - Visual Effect Blur (Adaptive)

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    var intensity: CGFloat = 1.0

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
        uiView.alpha = intensity
    }
}

// MARK: - View Toggle Button

struct ViewToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    ZStack {
                        if isSelected {
                            VisualEffectBlur(blurStyle: .systemUltraThinMaterial, intensity: 0.8)
                            Color.white.opacity(0.1)
                        }
                    }
                )
                .cornerRadius(12)
        }
    }
}

// MARK: - AI Recommended Card

struct AIRecommendedCard: View {
    var body: some View {
        ZStack {
            // Glow effect
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.2), Color.yellow.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blur(radius: 20)

            // Main card
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.yellow)
                        .frame(width: 32, height: 32)
                        .background(
                            VisualEffectBlur(blurStyle: .systemUltraThinMaterial, intensity: 0.8)
                        )
                        .clipShape(Circle())

                    Text("AI Recommended")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.yellow.opacity(0.9))

                    Spacer()
                }

                Text("Complete Application Package")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)

                Text("2 viewings next week. Be ready to apply immediately.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineSpacing(4)

                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "target")
                            .font(.system(size: 11))
                        Text("High Impact")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.gray)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text("10 min")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.gray)
                }

                Button(action: {}) {
                    HStack {
                        Text("Start Now")
                            .font(.system(size: 15, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        VisualEffectBlur(blurStyle: .systemUltraThinMaterial, intensity: 0.8)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(12)
                }
            }
            .padding(20)
            .background(
                VisualEffectBlur(blurStyle: .systemUltraThinMaterial, intensity: 0.8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text("\(value)")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            VisualEffectBlur(blurStyle: .systemUltraThinMaterial, intensity: 0.5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .cornerRadius(16)
    }
}

// MARK: - Activity Task Model (renamed to avoid shadowing Swift Concurrency Task)

struct ActivityTask: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let time: String
    let progress: Int
}

// MARK: - Action Category

struct ActionCategory: View {
    let title: String
    let count: Int
    let color: Color
    let isExpanded: Bool
    let tasks: [ActivityTask]
    @Binding var completedTasks: Set<Int>
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: onToggle) {
                HStack {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)

                    Text("\(count)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(color.opacity(0.9))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            VisualEffectBlur(blurStyle: .systemUltraThinMaterial, intensity: 0.8)
                        )
                        .overlay(
                            Capsule()
                                .stroke(color.opacity(0.3), lineWidth: 1)
                        )
                        .clipShape(Capsule())

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(16)
                .background(
                    VisualEffectBlur(blurStyle: .systemUltraThinMaterial, intensity: 0.5)
                )
            }

            // Tasks
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(tasks) { task in
                        TaskRow(task: task, isCompleted: completedTasks.contains(task.id)) {
                            if completedTasks.contains(task.id) {
                                completedTasks.remove(task.id)
                            } else {
                                completedTasks.insert(task.id)
                            }
                        }
                    }
                }
                .padding(16)
                .background(
                    VisualEffectBlur(blurStyle: .systemUltraThinMaterial, intensity: 0.3)
                )
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
    }
}

// MARK: - Task Row

struct TaskRow: View {
    let task: ActivityTask
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .stroke(isCompleted ? Color.green : Color.gray, lineWidth: 2)
                        .frame(width: 22, height: 22)

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .strikethrough(isCompleted)

                Text(task.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)

                Text(task.time)
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.8))

                if task.progress > 0 && task.progress < 100 {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.blue)
                                .frame(width: geometry.size.width * CGFloat(task.progress) / 100, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.top, 4)
                }
            }

            Spacer()
        }
        .padding(12)
        .background(
            VisualEffectBlur(blurStyle: .systemUltraThinMaterial, intensity: 0.5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// MARK: - Critical Milestone Card

struct CriticalMilestoneCard: View {
    var body: some View {
        ZStack {
            // Glow
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.red.opacity(0.2))
                .blur(radius: 20)

            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Text("🎯")
                        .font(.system(size: 32))
                        .frame(width: 48, height: 48)
                        .background(
                            VisualEffectBlur(blurStyle: .systemUltraThinMaterial, intensity: 0.8)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Application Deadline")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)

                            Text("In 3 days")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.red.opacity(0.9))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red.opacity(0.2))
                                .clipShape(Capsule())
                        }

                        Text("789 Bedford Ave • You need 2 more documents")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                }

                Button(action: {}) {
                    Text("Complete Application")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.6))
                        .cornerRadius(12)
                }
            }
            .padding(20)
            .background(
                VisualEffectBlur(blurStyle: .systemUltraThinMaterial, intensity: 0.8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(24)
        }
    }
}

// MARK: - Timeline Section

struct TimelineSection: View {
    let date: String
    let items: [TimelineItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: 3)
                    )

                Text(date)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 12) {
                ForEach(items.indices, id: \.self) { index in
                    TimelineItemView(item: items[index])
                }
            }
            .padding(.leading, 24)
        }
    }
}

// MARK: - Timeline Item Model

struct TimelineItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let time: String
    let location: String
}

// MARK: - Timeline Item View

struct TimelineItemView: View {
    let item: TimelineItem

    var body: some View {
        HStack(spacing: 12) {
            Text(item.icon)
                .font(.system(size: 24))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(item.time)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                }

                Text(item.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)

                Text(item.location)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(16)
        .background(
            VisualEffectBlur(blurStyle: .systemUltraThinMaterial, intensity: 0.5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .cornerRadius(16)
    }
}

// MARK: - Preview

struct ActivityFeedView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityFeedView()
    }
}
