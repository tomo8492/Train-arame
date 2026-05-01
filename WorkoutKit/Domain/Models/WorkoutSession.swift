import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var id: UUID
    var startedAt: Date
    var finishedAt: Date?
    var totalSets: Int
    var completedSets: Int

    init(startedAt: Date = .now) {
        self.id = UUID()
        self.startedAt = startedAt
        self.finishedAt = nil
        self.totalSets = 0
        self.completedSets = 0
    }
}
