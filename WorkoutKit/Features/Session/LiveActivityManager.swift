import ActivityKit
import Foundation
import Observation
import os

private let logger = Logger(subsystem: "com.tomo.workoutkit", category: "LiveActivityManager")

@Observable @MainActor
final class LiveActivityManager {
    private var activity: Activity<WorkoutActivityAttributes>?
    private(set) var isActive: Bool = false

    func start(sessionID: UUID, initialState: WorkoutActivityAttributes.ContentState) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.warning("Live Activities not enabled")
            return
        }
        let attributes = WorkoutActivityAttributes(sessionID: sessionID)
        do {
            activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            isActive = true
            logger.info("Live Activity started: \(sessionID)")
        } catch {
            logger.error("Failed to start Live Activity: \(error)")
        }
    }

    func update(state: WorkoutActivityAttributes.ContentState) async {
        await activity?.update(.init(state: state, staleDate: nil))
    }

    func end(finalState: WorkoutActivityAttributes.ContentState) async {
        await activity?.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .default)
        isActive = false
        activity = nil
        logger.info("Live Activity ended")
    }
}
