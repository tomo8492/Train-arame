import Foundation

struct AlarmSharedState: Codable, Equatable {
    let stationName: String?
    let lines: [String]
    let isMonitoring: Bool

    static let empty = AlarmSharedState(stationName: nil, lines: [], isMonitoring: false)
}

enum SharedAppGroup {
    static let id = "group.com.tomo.wakeatstation"
    private static let alarmStateKey = "alarmState.v1"

    static var defaults: UserDefaults? {
        UserDefaults(suiteName: id)
    }

    static func save(_ state: AlarmSharedState) {
        guard let defaults = defaults,
              let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: alarmStateKey)
    }

    static func load() -> AlarmSharedState {
        guard let defaults = defaults,
              let data = defaults.data(forKey: alarmStateKey),
              let state = try? JSONDecoder().decode(AlarmSharedState.self, from: data) else {
            return .empty
        }
        return state
    }
}
