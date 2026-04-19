import Foundation

final class StationRepository: ObservableObject {
    @Published private(set) var all: [Station] = []

    init() {
        load()
    }

    func load() {
        guard let url = Bundle.main.url(forResource: "stations", withExtension: "json") else {
            all = []
            return
        }
        do {
            let data = try Data(contentsOf: url)
            all = try JSONDecoder().decode([Station].self, from: data)
        } catch {
            all = []
        }
    }

    func search(_ query: String, limit: Int = 30) -> [Station] {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return [] }
        return all.filter { station in
            station.name.localizedCaseInsensitiveContains(q)
                || (station.nameKana?.localizedCaseInsensitiveContains(q) ?? false)
                || station.lineName.localizedCaseInsensitiveContains(q)
        }.prefix(limit).map { $0 }
    }
}
