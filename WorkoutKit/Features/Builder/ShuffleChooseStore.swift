import Observation
import os

private let logger = Logger(subsystem: "com.tomo.workoutkit", category: "ShuffleChooseStore")

// MARK: - ResultMode

enum ResultMode: String, CaseIterable {
    case shuffle
    case choose
}

// MARK: - ShuffleChooseStore

@Observable @MainActor
final class ShuffleChooseStore {

    // MARK: - State

    var lockedSlugs: Set<String> = []
    var mode: ResultMode = .shuffle

    // MARK: - Lock Management

    func toggleLock(slug: String) {
        if lockedSlugs.contains(slug) {
            lockedSlugs.remove(slug)
            logger.debug("Unlocked slug: \(slug)")
        } else {
            lockedSlugs.insert(slug)
            logger.debug("Locked slug: \(slug)")
        }
    }

    func isLocked(_ slug: String) -> Bool {
        lockedSlugs.contains(slug)
    }
}
