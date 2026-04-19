import XCTest
@testable import WakeAtStation

final class StationRepositoryTests: XCTestCase {
    func test_bundledStationsJSON_decodes() throws {
        guard let url = Bundle(for: Self.self).url(forResource: "stations", withExtension: "json") else {
            throw XCTSkip("stations.json is bundled into the app target, not the test bundle. Validate via app target instead.")
        }
        let data = try Data(contentsOf: url)
        let stations = try JSONDecoder().decode([Station].self, from: data)
        XCTAssertGreaterThan(stations.count, 30)
        XCTAssertTrue(stations.contains(where: { $0.name == "東京" }))
    }

    func test_search_matchesByNameAndLine() {
        let repo = StationRepository()
        repo.overrideAll([
            Station(id: "a", name: "新宿", nameKana: "しんじゅく",
                    lines: ["JR山手線", "京王線"], latitude: 35.69, longitude: 139.70),
            Station(id: "b", name: "池袋", nameKana: "いけぶくろ",
                    lines: ["JR山手線"], latitude: 35.72, longitude: 139.71)
        ])
        XCTAssertEqual(repo.search("新宿").count, 1)
        XCTAssertEqual(repo.search("山手線").count, 2)
        XCTAssertEqual(repo.search("京王線").count, 1)
        XCTAssertEqual(repo.search("").count, 0)
    }

    func test_search_matchesByHiraganaAndKatakana() {
        let repo = StationRepository()
        repo.overrideAll([
            Station(id: "a", name: "新宿", nameKana: "しんじゅく",
                    lines: ["JR山手線"], latitude: 35.69, longitude: 139.70)
        ])
        XCTAssertEqual(repo.search("しんじゅく").count, 1, "hiragana should match")
        XCTAssertEqual(repo.search("シンジュク").count, 1, "katakana should be normalized to hiragana")
    }

    func test_toHiragana_normalizesKatakana() {
        XCTAssertEqual(StationRepository.toHiragana("シンジュク"), "しんじゅく")
        XCTAssertEqual(StationRepository.toHiragana("しんじゅく"), "しんじゅく")
    }
}
