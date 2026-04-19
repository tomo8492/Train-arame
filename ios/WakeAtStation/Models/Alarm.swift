import Foundation

enum AlarmRadius: Int, Codable, CaseIterable, Identifiable {
    case short = 500
    case medium = 1000
    case long = 2000

    var id: Int { rawValue }
    var label: String {
        switch self {
        case .short: return "500m"
        case .medium: return "1km"
        case .long: return "2km"
        }
    }
}

enum AlarmStage: String, Codable {
    case preAlert
    case arrival

    var title: String {
        switch self {
        case .preAlert: return "まもなく降車駅（予告）"
        case .arrival: return "起きて！目的地です"
        }
    }
}

struct Alarm: Codable, Identifiable, Hashable {
    let id: UUID
    var station: Station
    var radius: AlarmRadius
    var isArmed: Bool
    var enableTwoStage: Bool
    var createdAt: Date

    init(station: Station,
         radius: AlarmRadius = .medium,
         isArmed: Bool = true,
         enableTwoStage: Bool = true) {
        self.id = UUID()
        self.station = station
        self.radius = radius
        self.isArmed = isArmed
        self.enableTwoStage = enableTwoStage
        self.createdAt = Date()
    }

    var innerRadiusMeters: Double { Double(radius.rawValue) }
    var outerRadiusMeters: Double { Double(radius.rawValue) * 2 }

    func regionIdentifier(for stage: AlarmStage) -> String {
        "\(id.uuidString)-\(stage.rawValue)"
    }
}
