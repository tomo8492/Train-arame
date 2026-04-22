import Foundation

@MainActor
final class AlarmStore: ObservableObject {
    @Published var favorites: [Station] = []
    @Published var recents: [Station] = []

    private let favoritesKey = "favorites.v2"
    private let recentsKey = "recents.v1"
    private let recentsLimit = 10

    init() {
        load()
    }

    func toggleFavorite(_ station: Station) {
        if let idx = favorites.firstIndex(of: station) {
            favorites.remove(at: idx)
        } else {
            favorites.append(station)
        }
        save()
    }

    func isFavorite(_ station: Station) -> Bool {
        favorites.contains(station)
    }

    func pushRecent(_ station: Station) {
        recents.removeAll { $0 == station }
        recents.insert(station, at: 0)
        if recents.count > recentsLimit {
            recents = Array(recents.prefix(recentsLimit))
        }
        save()
    }

    func clearRecents() {
        recents.removeAll()
        save()
    }

    private func load() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? decoder.decode([Station].self, from: data) {
            favorites = decoded
        }
        if let data = UserDefaults.standard.data(forKey: recentsKey),
           let decoded = try? decoder.decode([Station].self, from: data) {
            recents = decoded
        }
    }

    private func save() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(favorites) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
        if let data = try? encoder.encode(recents) {
            UserDefaults.standard.set(data, forKey: recentsKey)
        }
    }
}
