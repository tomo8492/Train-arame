import SwiftUI
import Observation

@Observable
final class UserPreferences {
    @ObservationIgnored
    @AppStorage("weightUnit") private var weightUnitRaw: String = WeightUnit.kg.rawValue

    var weightUnit: WeightUnit {
        get { WeightUnit(rawValue: weightUnitRaw) ?? .kg }
        set { weightUnitRaw = newValue.rawValue }
    }

    @ObservationIgnored
    @AppStorage("colorSchemePreference") private var colorSchemeRaw: String = "system"

    var colorSchemePreference: String {
        get { colorSchemeRaw }
        set { colorSchemeRaw = newValue }
    }
}
