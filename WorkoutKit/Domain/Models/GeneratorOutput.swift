struct GeneratorOutput: Sendable {
    let warmup: [Exercise]
    let main: [Exercise]
    let cooldown: [Exercise]

    var isEmpty: Bool {
        warmup.isEmpty && main.isEmpty && cooldown.isEmpty
    }

    var totalExerciseCount: Int {
        warmup.count + main.count + cooldown.count
    }
}
