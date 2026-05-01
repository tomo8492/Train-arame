import Observation
import os

private let logger = Logger(subsystem: "com.tomo.workoutkit", category: "BuilderStore")

@Observable @MainActor
final class BuilderStore {

    // MARK: - Step

    enum Step: CaseIterable {
        case goal, muscle, equipment, time, result
    }

    // MARK: - State

    private(set) var currentStep: Step = .goal
    private(set) var output: GeneratorOutput?
    private(set) var errorMessage: String?
    var isLoading: Bool = false

    // MARK: - User selections

    var selectedGoal: WorkoutGoal = .generalFitness
    var selectedMuscles: Set<MuscleGroup> = []
    var selectedEquipment: Set<Equipment> = []
    var minutesAvailable: Double = 45
    var includeWarmup: Bool = true
    var includeCooldown: Bool = true

    // MARK: - Private

    private let generator: WorkoutGenerator

    // MARK: - Init

    init(exercisePool: [Exercise]) {
        generator = WorkoutGenerator(exercisePool: exercisePool)
    }

    // MARK: - Navigation

    var canGoNext: Bool {
        currentStep != .result
    }

    var canGoBack: Bool {
        currentStep != .goal
    }

    func next() {
        let all = Step.allCases
        guard let idx = all.firstIndex(of: currentStep),
              idx + 1 < all.count else { return }
        currentStep = all[idx + 1]
        let stepName = String(describing: self.currentStep)
        logger.debug("Step advanced to \(stepName)")
    }

    func back() {
        let all = Step.allCases
        guard let idx = all.firstIndex(of: currentStep),
              idx > 0 else { return }
        currentStep = all[idx - 1]
        let stepName = String(describing: self.currentStep)
        logger.debug("Step moved back to \(stepName)")
    }

    // MARK: - Generation

    func confirm() async {
        isLoading = true
        errorMessage = nil
        output = nil

        let input = GeneratorInput(
            lockedExerciseSlugs: [],
            equipment: Array(selectedEquipment),
            primaryMuscles: Array(selectedMuscles),
            goal: selectedGoal,
            minutesAvailable: Int(minutesAvailable),
            includeWarmup: includeWarmup,
            includeCooldown: includeCooldown,
            randomSeed: nil
        )

        do {
            let result = try generator.generate(input: input)
            output = result
            logger.info("Generation succeeded: \(result.totalExerciseCount) exercises")
        } catch AppError.generatorEmpty {
            errorMessage = String(localized: "error.generator.empty")
            logger.warning("Generator returned empty result")
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Generation failed: \(error)")
        }

        isLoading = false
    }
}
