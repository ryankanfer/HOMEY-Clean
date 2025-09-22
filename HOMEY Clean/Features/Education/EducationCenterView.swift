//
//  EducationCenterView.swift
//  HOMEY Clean
//
//  Education Center with Masterclass-style layout
//

import SwiftUI

struct EducationCourse: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let instructor: String
    let duration: String
    let description: String
    let thumbnailImage: String
    let category: String
    let difficulty: String
    let lessons: [EducationLesson]

    init(
        id: UUID = UUID(),
        title: String,
        instructor: String,
        duration: String,
        description: String,
        thumbnailImage: String,
        category: String,
        difficulty: String,
        lessons: [EducationLesson]
    ) {
        self.id = id
        self.title = title
        self.instructor = instructor
        self.duration = duration
        self.description = description
        self.thumbnailImage = thumbnailImage
        self.category = category
        self.difficulty = difficulty
        self.lessons = lessons
    }
}

struct EducationLesson: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let duration: String
    let videoURL: String?

    init(
        id: UUID = UUID(),
        title: String,
        duration: String,
        videoURL: String? = nil
    ) {
        self.id = id
        self.title = title
        self.duration = duration
        self.videoURL = videoURL
    }
}

struct EducationCenterView: View {
    @State private var selectedCategory = "All"
    @State private var searchText = ""
    @State private var selectedCourse: EducationCourse?

    @StateObject private var progressStore = EducationProgressStore.shared

    private let categories = ["All", "Home Buying", "Financing", "Legal", "Inspection", "Moving"]

    private let courses: [EducationCourse] = [
        EducationCourse(
            title: "First-Time Home Buyer Masterclass",
            instructor: "Sarah Johnson",
            duration: "2h 30m",
            description: "Complete guide to buying your first home, from pre-approval to closing.",
            thumbnailImage: "house.fill",
            category: "Home Buying",
            difficulty: "Beginner",
            lessons: [
                EducationLesson(title: "Getting Pre-Approved", duration: "15m"),
                EducationLesson(title: "Finding the Right Agent", duration: "12m"),
                EducationLesson(title: "House Hunting Strategies", duration: "20m")
            ]
        ),
        EducationCourse(
            title: "Understanding Mortgages",
            instructor: "Michael Chen",
            duration: "1h 45m",
            description: "Deep dive into mortgage types, rates, and choosing the right loan.",
            thumbnailImage: "percent",
            category: "Financing",
            difficulty: "Intermediate",
            lessons: [
                EducationLesson(title: "Fixed vs Variable Rates", duration: "18m"),
                EducationLesson(title: "Down Payment Strategies", duration: "22m")
            ]
        ),
        EducationCourse(
            title: "Home Inspection Essentials",
            instructor: "Lisa Rodriguez",
            duration: "1h 20m",
            description: "What to look for during inspections and how to negotiate repairs.",
            thumbnailImage: "magnifyingglass",
            category: "Inspection",
            difficulty: "Beginner",
            lessons: [
                EducationLesson(title: "Structural Red Flags", duration: "25m"),
                EducationLesson(title: "Electrical & Plumbing", duration: "30m")
            ]
        )
    ]

    var filteredCourses: [EducationCourse] {
        let categoryFiltered = selectedCategory == "All" ? courses : courses.filter { $0.category == selectedCategory }

        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { course in
                course.title.localizedCaseInsensitiveContains(searchText) ||
                course.instructor.localizedCaseInsensitiveContains(searchText) ||
                course.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var continueCourse: EducationCourse? {
        progressStore.continueCourse(from: filteredCourses)
    }

    var body: some View {
        ZStack {
            AnimatedGradientBackground(for: nil)
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    searchSection
                    if let cont = continueCourse {
                        continueCTA(for: cont)
                    }
                    categorySection
                    featuredCourseSection
                    coursesGridSection
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Education")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(item: $selectedCourse) { course in
            CourseDetailView(course: course)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Education Center")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Theme.dynamicText())

                Spacer()
            }

            Text("Master the home buying process with expert-led courses")
                .font(.subheadline)
                .foregroundStyle(Theme.dynamicTextSecondary())
        }
        .padding(.top, 20)
    }

    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.dynamicTextSecondary())

            TextField("Search courses, instructors...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundStyle(Theme.dynamicText())
                .submitLabel(.search)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.dynamicSurface())
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.dynamicTextSecondary().opacity(0.15), lineWidth: 1)
                )
        )
    }

    private func continueCTA(for course: EducationCourse) -> some View {
        Button {
            selectedCourse = course
        } label: {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Theme.dynamicSurface())
                        .frame(width: 44, height: 44)
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Continue where you left off")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.dynamicText())
                    Text("\(course.title)")
                        .font(.caption)
                        .foregroundStyle(Theme.dynamicTextSecondary())
                        .lineLimit(1)
                        .truncationMode(.tail)
                }

                Spacer()

                Text("\(Int(progressStore.progress(for: course) * 100))%")
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(Theme.dynamicSurface())
                    )

                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.dynamicTextSecondary())
                    .font(.caption.weight(.semibold))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Theme.dynamicSurface())
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Theme.dynamicTextSecondary().opacity(0.12), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Continue \(course.title)"))
    }

    private var categorySection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.dynamicText())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedCategory == category ? Theme.dynamicText().opacity(0.12) : Theme.dynamicSurface())
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, -20)
    }

    private var featuredCourseSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Featured Course")
                .font(.title2.bold())
                .foregroundStyle(Theme.dynamicText())

            if let featuredCourse = courses.first {
                Button {
                    selectedCourse = featuredCourse
                } label: {
                    FeaturedCourseCard(
                        course: featuredCourse,
                        progress: progressStore.progress(for: featuredCourse)
                    ) { }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var coursesGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Courses")
                .font(.title2.bold())
                .foregroundStyle(Theme.dynamicText())

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(filteredCourses) { course in
                    Button {
                        selectedCourse = course
                    } label: {
                        CourseCard(
                            course: course,
                            progress: progressStore.progress(for: course)
                        ) { }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("Open \(course.title)"))
                }
            }
        }
    }
}

struct FeaturedCourseCard: View {
    let course: EducationCourse
    let progress: Double
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    Rectangle()
                        .fill(Theme.gradientForTheme(ThemeManager.shared.currentTheme(for: nil)))
                        .frame(height: 200)

                    Image(systemName: course.thumbnailImage)
                        .font(.system(size: 40))
                        .foregroundStyle(Theme.dynamicText())
                }

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(course.title)
                            .font(.title3.bold())
                            .foregroundStyle(Theme.dynamicText())
                            .multilineTextAlignment(.leading)

                        Text("with \(course.instructor)")
                            .font(.subheadline)
                            .foregroundStyle(Theme.dynamicTextSecondary())
                    }

                    Text(course.description)
                        .font(.caption)
                        .foregroundStyle(Theme.dynamicTextSecondary())
                        .lineLimit(2)

                    HStack {
                        Text(course.duration)
                            .font(.caption)
                            .foregroundColor(.orange)

                        Spacer()

                        Text(course.difficulty)
                            .font(.caption)
                            .foregroundStyle(Theme.dynamicText())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Theme.dynamicSurface())
                            )
                    }

                    if progress > 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Progress")
                                    .font(.caption2)
                                    .foregroundStyle(Theme.dynamicTextSecondary())

                                Spacer()

                                Text("\(Int(progress * 100))%")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }

                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                        }
                    }
                }
                .padding(16)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.dynamicSurface())
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.dynamicTextSecondary().opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Theme.dynamicText().opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

struct CourseCard: View {
    let course: EducationCourse
    let progress: Double
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    Rectangle()
                        .fill(Theme.gradientForTheme(ThemeManager.shared.currentTheme(for: nil)))
                        .frame(height: 120)

                    Image(systemName: course.thumbnailImage)
                        .font(.system(size: 24))
                        .foregroundStyle(Theme.dynamicText())
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(course.title)
                        .font(.headline)
                        .foregroundStyle(Theme.dynamicText())
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)

                    Text("with \(course.instructor)")
                        .font(.caption)
                        .foregroundStyle(Theme.dynamicTextSecondary())

                    HStack {
                        Text(course.duration)
                            .font(.caption2)
                            .foregroundColor(.orange)

                        Spacer()

                        if progress > 0 {
                            Text("\(Int(progress * 100))%")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(12)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.dynamicSurface())
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.dynamicTextSecondary().opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Theme.dynamicText().opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

struct CourseDetailView: View {
    let course: EducationCourse

    @ObservedObject private var progressStore = EducationProgressStore.shared

    var body: some View {
        ZStack {
            Theme.dynamicBackground().ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(course.title)
                            .font(.largeTitle.bold())
                            .foregroundStyle(Theme.dynamicText())

                        Text("with \(course.instructor)")
                            .font(.title3)
                            .foregroundStyle(Theme.dynamicTextSecondary())

                        Text(course.description)
                            .font(.body)
                            .foregroundStyle(Theme.dynamicTextSecondary())

                        HStack {
                            Label(course.duration, systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(.orange)

                            Spacer()

                            Text(course.difficulty)
                                .font(.caption)
                                .foregroundStyle(Theme.dynamicText())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Theme.dynamicSurface())
                                )
                        }

                        let p = progressStore.progress(for: course)
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Progress")
                                    .font(.caption)
                                    .foregroundStyle(Theme.dynamicTextSecondary())
                                Spacer()
                                Text("\(Int(p * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            ProgressView(value: p)
                                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                        }
                    }
                    .padding()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Lessons")
                            .font(.title2.bold())
                            .foregroundStyle(Theme.dynamicText())
                            .padding(.horizontal)

                        ForEach(course.lessons) { lesson in
                            let isCompleted = progressStore.isLessonCompleted(for: course, lesson: lesson)
                            LessonRow(
                                lesson: lesson,
                                isCompleted: isCompleted
                            ) {
                                progressStore.toggleLesson(for: course, lesson: lesson)
                            }
                        }
                    }

                    Spacer(minLength: 100)
                }
            }
        }
        .navigationTitle("Course")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LessonRow: View {
    let lesson: EducationLesson
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "play.circle")
                .font(.title3)
                .foregroundColor(isCompleted ? .green : .orange)

            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.headline)
                    .foregroundStyle(Theme.dynamicText())

                Text(lesson.duration)
                    .font(.caption)
                    .foregroundStyle(Theme.dynamicTextSecondary())
            }

            Spacer()

            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.dynamicSurface())
        )
        .padding(.horizontal)
        .contentShape(Rectangle())
        .onTapGesture(perform: onToggle)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(lesson.title), \(lesson.duration)"))
        .accessibilityHint(Text(isCompleted ? "Completed. Double tap to mark incomplete." : "Double tap to mark complete."))
    }
}

#Preview {
    NavigationStack {
        EducationCenterView()
            .preferredColorScheme(.dark)
    }
}