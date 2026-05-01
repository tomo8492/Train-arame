import Foundation

enum SessionSection: String, CaseIterable {
    case warmup, main, cooldown
}

struct ExerciseSet: Identifiable, Equatable {
    let id: UUID
    let exerciseSlug: String
    let exerciseName: String
    let exerciseNameEn: String
    var reps: Int
    var weightKg: Double
    var rpe: Int?        // 1-10, optional
    var isCompleted: Bool
    var section: SessionSection
}
