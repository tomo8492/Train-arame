import Foundation

enum WeightUnit: String, CaseIterable, Identifiable {
    case kg
    case lbs

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .kg:  return "kg"
        case .lbs: return "lbs"
        }
    }

    func convert(_ value: Double, to target: WeightUnit) -> Double {
        guard self != target else { return value }
        switch (self, target) {
        case (.kg, .lbs):  return value * 2.20462
        case (.lbs, .kg):  return value / 2.20462
        default:           return value
        }
    }

    func formatted(_ value: Double) -> String {
        String(format: "%.1f %@", value, displayName)
    }
}
