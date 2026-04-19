import XCTest
@testable import WakeAtStation

final class AlarmTests: XCTestCase {
    private let tokyo = Station(
        id: "jre-yamanote-tokyo",
        name: "東京",
        nameKana: "とうきょう",
        lineName: "JR山手線",
        latitude: 35.681236,
        longitude: 139.767125
    )

    func test_alarmDefaults() {
        let alarm = Alarm(station: tokyo)
        XCTAssertEqual(alarm.radius, .medium)
        XCTAssertTrue(alarm.isArmed)
        XCTAssertTrue(alarm.enableTwoStage)
    }

    func test_innerAndOuterRadius() {
        let alarm = Alarm(station: tokyo, radius: .short)
        XCTAssertEqual(alarm.innerRadiusMeters, 500)
        XCTAssertEqual(alarm.outerRadiusMeters, 1000)
    }

    func test_regionIdentifierIncludesStage() {
        let alarm = Alarm(station: tokyo)
        XCTAssertTrue(alarm.regionIdentifier(for: .arrival).hasSuffix("-arrival"))
        XCTAssertTrue(alarm.regionIdentifier(for: .preAlert).hasSuffix("-preAlert"))
        XCTAssertNotEqual(
            alarm.regionIdentifier(for: .arrival),
            alarm.regionIdentifier(for: .preAlert)
        )
    }

    func test_alarmRoundTripCoding() throws {
        let alarm = Alarm(station: tokyo, radius: .long, enableTwoStage: false)
        let data = try JSONEncoder().encode(alarm)
        let decoded = try JSONDecoder().decode(Alarm.self, from: data)
        XCTAssertEqual(decoded.id, alarm.id)
        XCTAssertEqual(decoded.station, alarm.station)
        XCTAssertEqual(decoded.radius, .long)
        XCTAssertFalse(decoded.enableTwoStage)
    }
}
