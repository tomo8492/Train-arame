import XCTest
@testable import WakeAtStation

@MainActor
final class DeepLinkRouterTests: XCTestCase {
    private func makeRepository(_ stations: [Station]) -> StationRepository {
        let repo = StationRepository()
        repo.overrideAll(stations)
        return repo
    }

    private func station(_ name: String, kana: String? = nil,
                         lat: Double, lng: Double) -> Station {
        Station(id: "\(name)-\(lat)-\(lng)", name: name, nameKana: kana,
                lines: ["テスト線"], latitude: lat, longitude: lng)
    }

    func test_handle_resolvesByName() {
        let router = DeepLinkRouter()
        let repo = makeRepository([
            station("新宿", kana: "しんじゅく", lat: 35.69, lng: 139.70),
            station("池袋", kana: "いけぶくろ", lat: 35.72, lng: 139.71)
        ])
        router.handle(url: URL(string: "wakestation://goto?name=新宿")!,
                      repository: repo)
        XCTAssertEqual(router.pendingStation?.name, "新宿")
    }

    func test_handle_resolvesByKana() {
        let router = DeepLinkRouter()
        let repo = makeRepository([
            station("新宿", kana: "しんじゅく", lat: 35.69, lng: 139.70)
        ])
        router.handle(url: URL(string: "wakestation://goto?name=シンジュク")!,
                      repository: repo)
        XCTAssertEqual(router.pendingStation?.name, "新宿")
    }

    func test_handle_resolvesByCoordinateNearest() {
        let router = DeepLinkRouter()
        let repo = makeRepository([
            station("東京", lat: 35.6812, lng: 139.7671),
            station("品川", lat: 35.6285, lng: 139.7387),
            station("新宿", lat: 35.6896, lng: 139.7006)
        ])
        // Near 東京 (35.681, 139.767)
        router.handle(url: URL(string: "wakestation://goto?lat=35.681&lng=139.767")!,
                      repository: repo)
        XCTAssertEqual(router.pendingStation?.name, "東京")
    }

    func test_handle_nameTakesPriorityOverCoord() {
        let router = DeepLinkRouter()
        let repo = makeRepository([
            station("東京", lat: 35.6812, lng: 139.7671),
            station("品川", lat: 35.6285, lng: 139.7387)
        ])
        // 座標は品川寄り、name=東京 → name優先
        router.handle(url: URL(string: "wakestation://goto?name=東京&lat=35.628&lng=139.738")!,
                      repository: repo)
        XCTAssertEqual(router.pendingStation?.name, "東京")
    }

    func test_handle_invalidScheme_doesNothing() {
        let router = DeepLinkRouter()
        let repo = makeRepository([
            station("新宿", kana: "しんじゅく", lat: 35.69, lng: 139.70)
        ])
        router.handle(url: URL(string: "https://example.com/goto?name=新宿")!,
                      repository: repo)
        XCTAssertNil(router.pendingStation)
    }

    func test_handle_invalidHost_doesNothing() {
        let router = DeepLinkRouter()
        let repo = makeRepository([
            station("新宿", kana: "しんじゅく", lat: 35.69, lng: 139.70)
        ])
        router.handle(url: URL(string: "wakestation://other?name=新宿")!,
                      repository: repo)
        XCTAssertNil(router.pendingStation)
    }

    func test_handle_unknownName_doesNotResolve() {
        let router = DeepLinkRouter()
        let repo = makeRepository([
            station("新宿", kana: "しんじゅく", lat: 35.69, lng: 139.70)
        ])
        router.handle(url: URL(string: "wakestation://goto?name=存在しない駅XYZ")!,
                      repository: repo)
        XCTAssertNil(router.pendingStation)
    }

    func test_consume_returnsAndClears() {
        let router = DeepLinkRouter()
        let s = station("新宿", lat: 35.69, lng: 139.70)
        router.pendingStation = s
        XCTAssertEqual(router.consume()?.name, "新宿")
        XCTAssertNil(router.pendingStation)
        XCTAssertNil(router.consume())
    }
}
