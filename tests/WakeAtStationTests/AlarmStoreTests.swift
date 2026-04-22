import XCTest
@testable import WakeAtStation

@MainActor
final class AlarmStoreTests: XCTestCase {
    private func make(_ name: String) -> Station {
        Station(id: name, name: name, nameKana: nil,
                lines: ["テスト線"], latitude: 0, longitude: 0)
    }

    override func setUp() async throws {
        UserDefaults.standard.removeObject(forKey: "favorites.v2")
        UserDefaults.standard.removeObject(forKey: "recents.v1")
    }

    func test_favorites_toggle() {
        let store = AlarmStore()
        let s = make("A")
        XCTAssertFalse(store.isFavorite(s))
        store.toggleFavorite(s)
        XCTAssertTrue(store.isFavorite(s))
        store.toggleFavorite(s)
        XCTAssertFalse(store.isFavorite(s))
    }

    func test_pushRecent_dedupesAndCaps() {
        let store = AlarmStore()
        for i in 0..<15 {
            store.pushRecent(make("S\(i)"))
        }
        XCTAssertEqual(store.recents.count, 10)
        XCTAssertEqual(store.recents.first?.name, "S14")
    }

    func test_pushRecent_movesExistingToFront() {
        let store = AlarmStore()
        store.pushRecent(make("A"))
        store.pushRecent(make("B"))
        store.pushRecent(make("A"))
        XCTAssertEqual(store.recents.map(\.name), ["A", "B"])
    }
}
