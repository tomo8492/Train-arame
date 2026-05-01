import Foundation
import Observation
import os

private let logger = Logger(subsystem: "com.tomo.workoutkit", category: "SessionStore")

@Observable @MainActor
final class SessionStore {

    // MARK: - State

    private(set) var sets: [ExerciseSet]
    private(set) var currentIndex: Int = 0
    private(set) var secondsRemaining: Int = 0
    private(set) var isResting: Bool = false
    private var restTimer: Timer?
    private let restSeconds: Int
    private var session: WorkoutSession

    // MARK: - Callback for persistence

    /// Called by the parent view when the session finishes, to persist the WorkoutSession.
    var onFinish: ((WorkoutSession) -> Void)?

    // MARK: - Computed

    var currentSet: ExerciseSet? { sets[safe: currentIndex] }

    var progress: Double {
        guard !sets.isEmpty else { return 0 }
        let completed = sets.filter(\.isCompleted).count
        return Double(completed) / Double(sets.count)
    }

    var isFinished: Bool { sets.allSatisfy(\.isCompleted) }

    // MARK: - Init

    init(output: GeneratorOutput, restSeconds: Int = 90) {
        self.restSeconds = restSeconds
        self.session = WorkoutSession()

        var built: [ExerciseSet] = []

        for exercise in output.warmup {
            built.append(ExerciseSet(
                id: UUID(),
                exerciseSlug: exercise.slug,
                exerciseName: exercise.name,
                exerciseNameEn: exercise.nameEn,
                reps: 15,
                weightKg: 0,
                rpe: nil,
                isCompleted: false,
                section: .warmup
            ))
        }

        for exercise in output.main {
            for _ in 0..<3 {
                built.append(ExerciseSet(
                    id: UUID(),
                    exerciseSlug: exercise.slug,
                    exerciseName: exercise.name,
                    exerciseNameEn: exercise.nameEn,
                    reps: 10,
                    weightKg: 0,
                    rpe: nil,
                    isCompleted: false,
                    section: .main
                ))
            }
        }

        for exercise in output.cooldown {
            built.append(ExerciseSet(
                id: UUID(),
                exerciseSlug: exercise.slug,
                exerciseName: exercise.name,
                exerciseNameEn: exercise.nameEn,
                reps: 30,
                weightKg: 0,
                rpe: nil,
                isCompleted: false,
                section: .cooldown
            ))
        }

        self.sets = built
        self.session.totalSets = built.count
        logger.info("SessionStore initialized with \(built.count) sets")
    }

    // MARK: - Actions

    func completeCurrentSet(reps: Int, weightKg: Double, rpe: Int?) {
        guard currentIndex < sets.count else { return }
        sets[currentIndex].reps = reps
        sets[currentIndex].weightKg = weightKg
        sets[currentIndex].rpe = rpe
        sets[currentIndex].isCompleted = true
        session.completedSets = sets.filter(\.isCompleted).count
        logger.debug("Set \(self.currentIndex) completed — reps:\(reps) weight:\(weightKg)")
        advanceToNextIncomplete()
        if !isFinished {
            startRestTimer()
        }
    }

    func skipCurrentSet() {
        guard currentIndex < sets.count else { return }
        logger.debug("Set \(self.currentIndex) skipped")
        sets[currentIndex].isCompleted = true
        session.completedSets = sets.filter(\.isCompleted).count
        advanceToNextIncomplete()
    }

    func startRestTimer() {
        cancelRestTimer()
        secondsRemaining = restSeconds
        isResting = true
        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if self.secondsRemaining > 0 {
                    self.secondsRemaining -= 1
                } else {
                    self.cancelRestTimer()
                }
            }
        }
        logger.debug("Rest timer started: \(self.restSeconds)s")
    }

    func cancelRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
        isResting = false
        secondsRemaining = 0
    }

    func replaceExercise(at index: Int, with exercise: Exercise) {
        guard index < sets.count else { return }
        sets[index] = ExerciseSet(
            id: UUID(),
            exerciseSlug: exercise.slug,
            exerciseName: exercise.name,
            exerciseNameEn: exercise.nameEn,
            reps: sets[index].reps,
            weightKg: sets[index].weightKg,
            rpe: sets[index].rpe,
            isCompleted: false,
            section: sets[index].section
        )
        logger.debug("Set \(index) replaced with exercise \(exercise.slug)")
    }

    func finish() {
        cancelRestTimer()
        session.finishedAt = .now
        session.completedSets = sets.filter(\.isCompleted).count
        logger.info("Session finished — completed \(self.session.completedSets)/\(self.session.totalSets) sets")
        onFinish?(session)
    }

    // MARK: - Private

    private func advanceToNextIncomplete() {
        let nextIdx = sets.indices.first(where: { $0 > currentIndex && !sets[$0].isCompleted })
        if let next = nextIdx {
            currentIndex = next
        } else if let any = sets.indices.first(where: { !sets[$0].isCompleted }) {
            currentIndex = any
        }
    }
}

// MARK: - Array safe subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
