import Testing
@testable import WorkoutKit

@Suite("WeightUnit")
struct WeightUnitTests {
    @Test("kg → lbs 変換")
    func kgToLbs() {
        let result = WeightUnit.kg.convert(100, to: .lbs)
        #expect(abs(result - 220.462) < 0.01)
    }

    @Test("lbs → kg 変換")
    func lbsToKg() {
        let result = WeightUnit.lbs.convert(220.462, to: .kg)
        #expect(abs(result - 100.0) < 0.01)
    }

    @Test("同じ単位の変換は値が変わらない")
    func sameUnitNoChange() {
        #expect(WeightUnit.kg.convert(80, to: .kg) == 80)
        #expect(WeightUnit.lbs.convert(175, to: .lbs) == 175)
    }

    @Test("formatted で単位付き文字列")
    func formattedString() {
        let s = WeightUnit.kg.formatted(80)
        #expect(s == "80.0 kg")
    }
}
