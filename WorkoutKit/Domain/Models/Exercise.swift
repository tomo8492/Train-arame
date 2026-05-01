struct Exercise: Identifiable, Codable, Sendable, Hashable {
    let slug: String
    let name: String
    let nameEn: String
    let category: ExerciseCategory
    let primaryMuscles: [MuscleGroup]
    let secondaryMuscles: [MuscleGroup]
    let equipment: Equipment

    var id: String { slug }

    var allMuscles: Set<MuscleGroup> {
        Set(primaryMuscles).union(secondaryMuscles)
    }
}
