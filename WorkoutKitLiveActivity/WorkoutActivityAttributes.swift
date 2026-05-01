import ActivityKit
import Foundation

struct WorkoutActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var currentExerciseName: String
        var secondsRemaining: Int
        var completedSets: Int
        var totalSets: Int
        var isResting: Bool
    }

    let sessionID: UUID
}
