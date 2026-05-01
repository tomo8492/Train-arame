enum WorkoutGoal: String, Codable, CaseIterable, Sendable {
    case strength
    case hypertrophy
    case endurance
    case flexibility
    case generalFitness = "general_fitness"

    /// compound 種目の目標比率（0.0〜1.0）
    var compoundRatio: Double {
        switch self {
        case .strength:      return 0.9
        case .hypertrophy:   return 0.6
        case .endurance:     return 0.4
        case .flexibility:   return 0.0
        case .generalFitness: return 0.5
        }
    }

    /// 1種目あたりの平均所要時間（分）
    var minutesPerExercise: Int {
        switch self {
        case .strength:      return 5
        case .hypertrophy:   return 4
        case .endurance:     return 3
        case .flexibility:   return 3
        case .generalFitness: return 4
        }
    }

    /// main ブロックを持たないゴール
    var skipMain: Bool { self == .flexibility }
}
