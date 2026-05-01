enum MuscleGroup: String, Codable, CaseIterable, Sendable {
    case quadriceps
    case hamstrings
    case glutes
    case calves
    case hipFlexors      = "hip_flexors"
    case pectoralisMajor = "pectoralis_major"
    case pectoralisMinor = "pectoralis_minor"
    case latissimusDorsi = "latissimus_dorsi"
    case rhomboids
    case trapezius
    case erectorSpinae   = "erector_spinae"
    case deltoid
    case anteriorDeltoid = "anterior_deltoid"
    case rearDeltoid     = "rear_deltoid"
    case biceps
    case triceps
    case brachialis
    case forearms
    case core
    case rectusAbdominis    = "rectus_abdominis"
    case obliques
    case transverseAbdominis = "transverse_abdominis"
    case neck
    case chest
    case back
    case shoulders
    case arms
    case legs
}
