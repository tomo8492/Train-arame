import Foundation

/// Brzycki 式による 1RM（最大挙上重量）推定。
///
/// formula: 1RM = weight × (36 / (37 − reps))
///
/// 境界条件:
/// - reps < 1  → nil（無効）
/// - reps >= 37 → nil（式が発散）
/// - weight <= 0 → nil（無効）
/// - reps == 1 → weight をそのまま返す（厳密解）
enum OneRepMaxCalculator {

    /// - Parameters:
    ///   - weight: 挙上重量（kg）。正の値。
    ///   - reps: 反復回数。1〜36 の整数。
    /// - Returns: 推定 1RM (kg)。入力が範囲外の場合は nil。
    static func estimate(weight: Double, reps: Int) -> Double? {
        guard weight > 0 else { return nil }
        guard reps >= 1, reps <= 36 else { return nil }
        if reps == 1 { return weight }
        return weight * (36.0 / Double(37 - reps))
    }
}
