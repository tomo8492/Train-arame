enum ExerciseCategory: String, Codable, CaseIterable, Sendable {
    case warmup
    case strengthCompound = "strength_compound"
    case strengthIsolation = "strength_isolation"
    case calisthenics
    case stretching
    case cardio

    var isMainCategory: Bool {
        switch self {
        case .strengthCompound, .strengthIsolation, .calisthenics, .cardio: return true
        case .warmup, .stretching: return false
        }
    }

    var isCompound: Bool {
        self == .strengthCompound || self == .calisthenics
    }
}
