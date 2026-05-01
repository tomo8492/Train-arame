import Observation
import os

private let logger = Logger(subsystem: "com.tomo.workoutkit", category: "LibraryStore")

@Observable @MainActor
final class LibraryStore {

    // MARK: - Private state

    private let allExercises: [Exercise]

    // MARK: - Filter state

    var searchText: String = ""
    var selectedCategory: ExerciseCategory? = nil
    var selectedMuscle: MuscleGroup? = nil
    var selectedEquipment: Equipment? = nil

    // MARK: - Computed

    var filtered: [Exercise] {
        allExercises.filter { exercise in
            let matchesSearch: Bool = {
                guard !searchText.isEmpty else { return true }
                let query = searchText.lowercased()
                return exercise.name.lowercased().contains(query)
                    || exercise.nameEn.lowercased().contains(query)
                    || exercise.slug.lowercased().contains(query)
            }()

            let matchesCategory: Bool = {
                guard let cat = selectedCategory else { return true }
                return exercise.category == cat
            }()

            let matchesMuscle: Bool = {
                guard let muscle = selectedMuscle else { return true }
                return exercise.primaryMuscles.contains(muscle)
                    || exercise.secondaryMuscles.contains(muscle)
            }()

            let matchesEquipment: Bool = {
                guard let eq = selectedEquipment else { return true }
                return exercise.equipment == eq
            }()

            return matchesSearch && matchesCategory && matchesMuscle && matchesEquipment
        }
    }

    var hasActiveFilters: Bool {
        selectedCategory != nil || selectedMuscle != nil || selectedEquipment != nil
    }

    // MARK: - Init

    init(exercises: [Exercise]) {
        allExercises = exercises
        logger.debug("LibraryStore initialized with \(exercises.count) exercises")
    }

    // MARK: - Actions

    func clearFilters() {
        selectedCategory = nil
        selectedMuscle = nil
        selectedEquipment = nil
        logger.debug("Filters cleared")
    }
}
