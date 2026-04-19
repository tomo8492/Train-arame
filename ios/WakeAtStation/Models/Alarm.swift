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

struct Alarm: Codable, Identifiable, Hashable {
    let id: UUID
    var station: Station
    var radius: AlarmRadius
    var isArmed: Bool
    var createdAt: Date

    init(station: Station, radius: AlarmRadius = .medium, isArmed: Bool = true) {
        self.id = UUID()
        self.station = station
        self.radius = radius
        self.isArmed = isArmed
        self.createdAt = Date()
    }
}
