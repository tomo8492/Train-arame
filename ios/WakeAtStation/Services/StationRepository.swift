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

    func overrideAll(_ stations: [Station]) {
        all = stations
    }

    func search(_ query: String, limit: Int = 30) -> [Station] {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return [] }
        let qHira = Self.toHiragana(q)
        let matched = all.filter { station in
            station.name.localizedCaseInsensitiveContains(q)
                || (station.nameKana.map { $0.contains(qHira) } ?? false)
                || station.lines.contains { $0.localizedCaseInsensitiveContains(q) }
        }
        return matched.sorted { lhs, rhs in
            let lhsExact = lhs.name == q || lhs.nameKana == qHira
            let rhsExact = rhs.name == q || rhs.nameKana == qHira
            if lhsExact != rhsExact { return lhsExact }
            if lhs.lines.count != rhs.lines.count { return lhs.lines.count > rhs.lines.count }
            return lhs.name < rhs.name
        }.prefix(limit).map { $0 }
    }

    static func toHiragana(_ s: String) -> String {
        let mutable = NSMutableString(string: s) as CFMutableString
        CFStringTransform(mutable, nil, kCFStringTransformHiraganaKatakana, true)
        return (mutable as String).lowercased()
    }
}
