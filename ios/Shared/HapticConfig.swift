import Foundation

enum HapticIntensity: String, CaseIterable, Identifiable, Codable {
    case soft
    case medium
    case strong

    var id: String { rawValue }

    var label: String {
        switch self {
        case .soft: return "弱"
        case .medium: return "標準"
        case .strong: return "強"
        }
    }

    /// Watch のバイブ間隔（秒）。短いほど刺激が連続して目覚めやすい。
    var watchInterval: TimeInterval {
        switch self {
        case .soft: return 1.5
        case .medium: return 1.0
        case .strong: return 0.7
        }
    }
}

enum HapticDuration: Int, CaseIterable, Identifiable, Codable {
    case sec30 = 30
    case sec60 = 60
    case sec120 = 120
    case sec180 = 180

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .sec30: return "30秒"
        case .sec60: return "1分"
        case .sec120: return "2分"
        case .sec180: return "3分"
        }
    }

    var seconds: TimeInterval { TimeInterval(rawValue) }
}
