import XCTest
@testable import WakeAtStation

final class HapticConfigTests: XCTestCase {
    func test_intensity_intervalsAreOrdered() {
        // 強いほど短い間隔（連打が速い → 起きやすい）
        XCTAssertLessThan(HapticIntensity.strong.watchInterval,
                          HapticIntensity.medium.watchInterval)
        XCTAssertLessThan(HapticIntensity.medium.watchInterval,
                          HapticIntensity.soft.watchInterval)
    }

    func test_intensity_labels() {
        XCTAssertEqual(HapticIntensity.soft.label, "弱")
        XCTAssertEqual(HapticIntensity.medium.label, "標準")
        XCTAssertEqual(HapticIntensity.strong.label, "強")
    }

    func test_intensity_codable_roundTrip() throws {
        for intensity in HapticIntensity.allCases {
            let data = try JSONEncoder().encode(intensity)
            let decoded = try JSONDecoder().decode(HapticIntensity.self, from: data)
            XCTAssertEqual(decoded, intensity)
        }
    }

    func test_intensity_rawValueRoundTrip() {
        for intensity in HapticIntensity.allCases {
            XCTAssertEqual(HapticIntensity(rawValue: intensity.rawValue), intensity)
        }
    }

    func test_duration_secondsMatchesRawValue() {
        for duration in HapticDuration.allCases {
            XCTAssertEqual(duration.seconds, TimeInterval(duration.rawValue))
        }
    }

    func test_duration_orderedByLength() {
        XCTAssertLessThan(HapticDuration.sec30.seconds, HapticDuration.sec60.seconds)
        XCTAssertLessThan(HapticDuration.sec60.seconds, HapticDuration.sec120.seconds)
        XCTAssertLessThan(HapticDuration.sec120.seconds, HapticDuration.sec180.seconds)
    }

    func test_duration_labels() {
        XCTAssertEqual(HapticDuration.sec30.label, "30秒")
        XCTAssertEqual(HapticDuration.sec60.label, "1分")
        XCTAssertEqual(HapticDuration.sec120.label, "2分")
        XCTAssertEqual(HapticDuration.sec180.label, "3分")
    }

    func test_duration_codable_roundTrip() throws {
        for duration in HapticDuration.allCases {
            let data = try JSONEncoder().encode(duration)
            let decoded = try JSONDecoder().decode(HapticDuration.self, from: data)
            XCTAssertEqual(decoded, duration)
        }
    }

    func test_invalidRawValue_returnsNil() {
        XCTAssertNil(HapticIntensity(rawValue: "unknown"))
        XCTAssertNil(HapticDuration(rawValue: 42))
    }
}
