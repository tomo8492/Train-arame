import Foundation

enum ProFeature: String, CaseIterable {
    case unlimitedHistory
    case advancedCharts
    case manualEntry
    case customTemplates
}

@Observable @MainActor
final class ProFeatureGate {
    private(set) var isPremium: Bool

    init(isPremium: Bool = false) {
        self.isPremium = isPremium
    }

    func check(_ feature: ProFeature) -> Bool {
        switch feature {
        case .unlimitedHistory, .advancedCharts, .manualEntry, .customTemplates:
            return isPremium
        }
    }

    func unlock() {
        isPremium = true
    }
}
