import Testing
import Foundation
@testable import WorkoutKit

@Suite("LiveActivity")
struct LiveActivityTests {
    @Test("ContentState が正しくエンコード/デコードされる")
    func contentStateRoundTrip() throws {
        let state = WorkoutActivityAttributes.ContentState(
            currentExerciseName: "ベンチプレス",
            secondsRemaining: 90,
            completedSets: 3,
            totalSets: 15,
            isResting: true
        )
        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(WorkoutActivityAttributes.ContentState.self, from: data)
        #expect(decoded.currentExerciseName == state.currentExerciseName)
        #expect(decoded.secondsRemaining == state.secondsRemaining)
        #expect(decoded.completedSets == state.completedSets)
        #expect(decoded.isResting == state.isResting)
    }
}
