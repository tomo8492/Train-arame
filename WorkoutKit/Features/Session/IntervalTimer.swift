import UIKit
import os

private let logger = Logger(subsystem: "com.tomo.workoutkit", category: "IntervalTimer")

actor IntervalTimer {
    private var currentTask: Task<Void, Never>?

    /// Emits remaining seconds from `seconds` down to 0, then finishes.
    /// Fires haptics at 3 s remaining and at 0 s.
    func start(seconds: Int) -> AsyncStream<Int> {
        currentTask?.cancel()
        return AsyncStream { continuation in
            self.currentTask = Task {
                for remaining in stride(from: seconds, through: 0, by: -1) {
                    guard !Task.isCancelled else { break }
                    continuation.yield(remaining)
                    await fireHaptic(at: remaining)
                    if remaining > 0 {
                        try? await Task.sleep(for: .seconds(1))
                    }
                }
                continuation.finish()
                logger.debug("IntervalTimer finished")
            }
        }
    }

    func cancel() {
        currentTask?.cancel()
        currentTask = nil
    }

    // MARK: - Private

    private func fireHaptic(at remaining: Int) async {
        await MainActor.run {
            switch remaining {
            case 3:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            case 0:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            default:
                break
            }
        }
    }
}
