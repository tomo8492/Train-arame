import Foundation

@MainActor
final class AlarmStore: ObservableObject {
    @Published var alarms: [Alarm] = []
    @Published var favorites: [Station] = []

    private let alarmsKey = "alarms.v1"
    private let favoritesKey = "favorites.v1"

    init() {
        load()
    }

    func add(_ alarm: Alarm) {
        alarms.append(alarm)
        save()
    }

    func remove(_ alarm: Alarm) {
        alarms.removeAll { $0.id == alarm.id }
        save()
    }

    func toggleFavorite(_ station: Station) {
        if let idx = favorites.firstIndex(of: station) {
            favorites.remove(at: idx)
        } else {
            favorites.append(station)
        }
        save()
    }

    private func load() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: alarmsKey),
           let decoded = try? decoder.decode([Alarm].self, from: data) {
            alarms = decoded
        }
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? decoder.decode([Station].self, from: data) {
            favorites = decoded
        }
    }

    private func save() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(alarms) {
            UserDefaults.standard.set(data, forKey: alarmsKey)
        }
        if let data = try? encoder.encode(favorites) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
}
