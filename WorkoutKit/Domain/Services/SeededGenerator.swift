/// Xorshift64 による決定論的な乱数生成器。
/// 同じシードを与えると常に同じ出力列を返す（テスト再現性のため）。
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        // 0 は Xorshift の無効状態なので 1 にフォールバック
        state = seed == 0 ? 1 : seed
    }

    mutating func next() -> UInt64 {
        state ^= state &<< 13
        state ^= state &>> 7
        state ^= state &<< 17
        return state
    }
}
