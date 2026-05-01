enum Equipment: String, Codable, CaseIterable, Sendable {
    case barbell
    case dumbbell
    case cable
    case machine
    case bodyweight
    case kettlebell
    case resistanceBand = "resistance_band"
    case foamRoller     = "foam_roller"
}
