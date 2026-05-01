/// SeededGenerator または SystemRandomNumberGenerator を統一的に扱う具体型ラッパー。
/// `any RandomNumberGenerator` は inout で使えないため専用型で解決する。
struct WorkoutRNG: RandomNumberGenerator {
    private var seeded: SeededGenerator?
    private var system = SystemRandomNumberGenerator()

    init(seed: UInt64?) {
        seeded = seed.map { SeededGenerator(seed: $0) }
    }

    mutating func next() -> UInt64 {
        if var s = seeded {
            let value = s.next()
            seeded = s
            return value
        }
        return system.next()
    }
}
