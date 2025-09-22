import Foundation
import SwiftUI

struct CourseProgress: Codable, Hashable {
    var completedLessonIDs: Set<UUID> = []
    var lastLessonID: UUID?
    var updatedAt: Date = .now
}

@MainActor
final class EducationProgressStore: ObservableObject {
    static let shared = EducationProgressStore()

    @Published private(set) var progressMap: [UUID: CourseProgress] = [:]

    private let storageKey = "education.progress.v1"
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private init() {
        load()
    }

    func progress(for course: EducationCourse) -> Double {
        guard !course.lessons.isEmpty else { return 0 }
        let completed = progressMap[course.id]?.completedLessonIDs.count ?? 0
        return Double(completed) / Double(course.lessons.count)
    }

    func isLessonCompleted(for course: EducationCourse, lesson: EducationLesson) -> Bool {
        guard let p = progressMap[course.id] else { return false }
        return p.completedLessonIDs.contains(lesson.id)
    }

    func toggleLesson(for course: EducationCourse, lesson: EducationLesson) {
        var cp = progressMap[course.id] ?? CourseProgress()
        if cp.completedLessonIDs.contains(lesson.id) {
            cp.completedLessonIDs.remove(lesson.id)
        } else {
            cp.completedLessonIDs.insert(lesson.id)
            cp.lastLessonID = lesson.id
        }
        cp.updatedAt = .now
        progressMap[course.id] = cp
        save()
    }

    func nextUnfinishedLesson(for course: EducationCourse) -> EducationLesson? {
        let completed = progressMap[course.id]?.completedLessonIDs ?? []
        return course.lessons.first(where: { !completed.contains($0.id) })
    }

    func continueCourse(from courses: [EducationCourse]) -> EducationCourse? {
        let candidates = courses
            .map { ($0, progress(for: $0), progressMap[$0.id]?.updatedAt ?? .distantPast) }
            .filter { $0.1 > 0 && $0.1 < 1 }

        if let best = candidates.max(by: { $0.2 < $1.2 })?.0 {
            return best
        }

        return nil
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        if let decoded = try? decoder.decode([UUID: CourseProgress].self, from: data) {
            progressMap = decoded
        }
    }

    private func save() {
        if let data = try? encoder.encode(progressMap) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}