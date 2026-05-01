import Testing
@testable import WorkoutKit

@Suite("OneRepMaxCalculator")
struct OneRepMaxCalculatorTests {

    // MARK: - 正常系

    @Test("1レップは重量をそのまま返す")
    func oneRepReturnsWeight() {
        let result = OneRepMaxCalculator.estimate(weight: 100, reps: 1)
        #expect(result == 100)
    }

    @Test("スクワット 3×100kg の 1RM 推定")
    func squat3x100() throws {
        let result = try #require(OneRepMaxCalculator.estimate(weight: 100, reps: 3))
        // Brzycki: 100 × (36 / 34) ≈ 105.88
        #expect(abs(result - 105.88) < 0.01)
    }

    @Test("ベンチプレス 5×80kg の 1RM 推定")
    func benchPress5x80() throws {
        let result = try #require(OneRepMaxCalculator.estimate(weight: 80, reps: 5))
        // Brzycki: 80 × (36 / 32) = 90.0
        #expect(result == 90.0)
    }

    @Test("デッドリフト 36レップ（最大有効レップ数）")
    func deadlift36Reps() throws {
        let result = try #require(OneRepMaxCalculator.estimate(weight: 60, reps: 36))
        // Brzycki: 60 × (36 / 1) = 2160
        #expect(result == 2160.0)
    }

    // MARK: - 境界値・エラー系

    @Test("レップ数 0 は nil を返す")
    func zeroRepsReturnsNil() {
        let result = OneRepMaxCalculator.estimate(weight: 100, reps: 0)
        #expect(result == nil)
    }

    @Test("レップ数 37 以上は nil を返す（式が発散）")
    func reps37ReturnsNil() {
        let result37 = OneRepMaxCalculator.estimate(weight: 100, reps: 37)
        let result99 = OneRepMaxCalculator.estimate(weight: 100, reps: 99)
        #expect(result37 == nil)
        #expect(result99 == nil)
    }

    @Test("重量 0 以下は nil を返す")
    func zeroOrNegativeWeightReturnsNil() {
        #expect(OneRepMaxCalculator.estimate(weight: 0, reps: 5) == nil)
        #expect(OneRepMaxCalculator.estimate(weight: -10, reps: 5) == nil)
    }
}
