//
//  EducationCenterView.swift
//  HOMEY Clean
//
//  Education Center with Masterclass-style layout
//

import SwiftUI

struct EducationCourse {
    let id = UUID()
    let title: String
    let instructor: String
    let duration: String
    let description: String
    let thumbnailImage: String
    let category: String
    let difficulty: String
    let lessons: [EducationLesson]
    let isCompleted: Bool
    let progress: Double
}

struct EducationLesson {
    let id = UUID()
    let title: String
    let duration: String
    let isCompleted: Bool
    let videoURL: String?
}

struct EducationCenterView: View {
    @State private var selectedCategory = "All"
    @State private var searchText = ""
    @State private var showCourseDetail = false
    @State private var selectedCourse: EducationCourse?
    
    private let categories = ["All", "Home Buying", "Financing", "Legal", "Inspection", "Moving"]
    
    private let courses = [
        EducationCourse(
            title: "First-Time Home Buyer Masterclass",
            instructor: "Sarah Johnson",
            duration: "2h 30m",
            description: "Complete guide to buying your first home, from pre-approval to closing.",
            thumbnailImage: "house.fill",
            category: "Home Buying",
            difficulty: "Beginner",
            lessons: [
                EducationLesson(title: "Getting Pre-Approved", duration: "15m", isCompleted: true, videoURL: nil),
                EducationLesson(title: "Finding the Right Agent", duration: "12m", isCompleted: true, videoURL: nil),
                EducationLesson(title: "House Hunting Strategies", duration: "20m", isCompleted: false, videoURL: nil)
            ],
            isCompleted: false,
            progress: 0.4
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
                EducationLesson(title: "Fixed vs Variable Rates", duration: "18m", isCompleted: false, videoURL: nil),
                EducationLesson(title: "Down Payment Strategies", duration: "22m", isCompleted: false, videoURL: nil)
            ],
            isCompleted: false,
            progress: 0.0
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
                EducationLesson(title: "Structural Red Flags", duration: "25m", isCompleted: false, videoURL: nil),
                EducationLesson(title: "Electrical & Plumbing", duration: "30m", isCompleted: false, videoURL: nil)
            ],
            isCompleted: false,
            progress: 0.0
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
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated gradient background
                AnimatedGradient(colors: [
                    Color(hex: "FF6B6B"),
                    Color(hex: "4ECDC4"),
                    Color(hex: "45B7D1"),
                    Color(hex: "96CEB4")
                ])
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        headerSection
                        
                        // Search bar
                        searchSection
                        
                        // Category filters
                        categorySection
                        
                        // Featured course
                        featuredCourseSection
                        
                        // Course grid
                        coursesGridSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showCourseDetail) {
            if let course = selectedCourse {
                CourseDetailView(course: course, isPresented: $showCourseDetail)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Education Center")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    // Close action
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Text("Master the home buying process with expert-led courses")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.top, 20)
    }
    
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search courses, instructors...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
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
                            .foregroundColor(selectedCategory == category ? .black : .white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedCategory == category ? Color.white : Color.white.opacity(0.1))
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
                .foregroundColor(.white)
            
            if let featuredCourse = courses.first {
                FeaturedCourseCard(course: featuredCourse) {
                    selectedCourse = featuredCourse
                    showCourseDetail = true
                }
            }
        }
    }
    
    private var coursesGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Courses")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(filteredCourses, id: \.id) { course in
                    CourseCard(course: course) {
                        selectedCourse = course
                        showCourseDetail = true
                    }
                }
            }
        }
    }
}

struct FeaturedCourseCard: View {
    let course: EducationCourse
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                // Thumbnail
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange, Color.red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 200)
                    
                    Image(systemName: course.thumbnailImage)
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(course.title)
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        
                        Text("with \(course.instructor)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Text(course.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    HStack {
                        Text(course.duration)
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Text(course.difficulty)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.2))
                            )
                    }
                    
                    // Progress bar
                    if course.progress > 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Progress")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text("\(Int(course.progress * 100))%")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                            
                            ProgressView(value: course.progress)
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
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

struct CourseCard: View {
    let course: EducationCourse
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                // Thumbnail
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 120)
                    
                    Image(systemName: course.thumbnailImage)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(course.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Text("with \(course.instructor)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text(course.duration)
                            .font(.caption2)
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        if course.progress > 0 {
                            Text("\(Int(course.progress * 100))%")
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
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

struct CourseDetailView: View {
    let course: EducationCourse
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Course header
                        VStack(alignment: .leading, spacing: 12) {
                            Text(course.title)
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                            
                            Text("with \(course.instructor)")
                                .font(.title3)
                                .foregroundColor(.gray)
                            
                            Text(course.description)
                                .font(.body)
                                .foregroundColor(.gray)
                            
                            HStack {
                                Label(course.duration, systemImage: "clock")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                
                                Spacer()
                                
                                Text(course.difficulty)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.2))
                                    )
                            }
                        }
                        .padding()
                        
                        // Lessons list
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Lessons")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ForEach(course.lessons, id: \.id) { lesson in
                                LessonRow(lesson: lesson)
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct LessonRow: View {
    let lesson: EducationLesson
    
    var body: some View {
        HStack {
            Image(systemName: lesson.isCompleted ? "checkmark.circle.fill" : "play.circle")
                .font(.title3)
                .foregroundColor(lesson.isCompleted ? .green : .orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(lesson.duration)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if lesson.isCompleted {
                Image(systemName: "checkmark")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        .padding(.horizontal)
    }
}

#Preview {
    EducationCenterView()
        .preferredColorScheme(.dark)
}