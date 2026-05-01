import Foundation
import SwiftData

@Model
final class WorkoutTemplate {
    var id: UUID
    var name: String
    var exerciseSlugs: [String]
    var isPreset: Bool
    var createdAt: Date

    init(name: String, exerciseSlugs: [String], isPreset: Bool = false) {
        self.id = UUID()
        self.name = name
        self.exerciseSlugs = exerciseSlugs
        self.isPreset = isPreset
        self.createdAt = .now
    }
}
