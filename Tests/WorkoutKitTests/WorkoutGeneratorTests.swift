import Testing
@testable import WorkoutKit

// MARK: - Test fixture

private func makeExercise(
    slug: String,
    category: ExerciseCategory,
    primary: [MuscleGroup],
    secondary: [MuscleGroup] = [],
    equipment: Equipment = .bodyweight
) -> Exercise {
    Exercise(slug: slug, name: slug, nameEn: slug,
             category: category, primaryMuscles: primary,
             secondaryMuscles: secondary, equipment: equipment)
}

/// 胸・脚・背中・肩を網羅した 40 種目のテスト用プール
private let testPool: [Exercise] = {
    var pool: [Exercise] = []

    // warmup × 5
    for i in 1...5 {
        pool.append(makeExercise(slug: "wu_\(i)", category: .warmup,
                                 primary: [.shoulders]))
    }
    // strength_compound: 胸 bodyweight × 10
    for i in 1...10 {
        pool.append(makeExercise(slug: "push_\(i)", category: .strengthCompound,
                                 primary: [.pectoralisMajor],
                                 secondary: [.triceps], equipment: .bodyweight))
    }
    // strength_compound: 脚 barbell × 5
    for i in 1...5 {
        pool.append(makeExercise(slug: "squat_\(i)", category: .strengthCompound,
                                 primary: [.quadriceps, .glutes],
                                 equipment: .barbell))
    }
    // strength_isolation: 背中 × 10
    for i in 1...10 {
        pool.append(makeExercise(slug: "row_\(i)", category: .strengthIsolation,
                                 primary: [.latissimusDorsi],
                                 secondary: [.biceps], equipment: .dumbbell))
    }
    // stretching × 10
    for i in 1...10 {
        pool.append(makeExercise(slug: "stretch_\(i)", category: .stretching,
                                 primary: [.pectoralisMajor]))
    }
    return pool
}()

// MARK: - Test Suite

@Suite("WorkoutGenerator")
struct WorkoutGeneratorTests {

    // T-1: 胸 + bodyweight + 45分 → main 5種目以上
    @Test("胸＋自重＋45分でメイン5種目以上生成される")
    func chestBodyweight45min() throws {
        let gen = WorkoutGenerator(exercisePool: testPool)
        let input = GeneratorInput(
            equipment: [.bodyweight],
            primaryMuscles: [.pectoralisMajor],
            goal: .hypertrophy,
            minutesAvailable: 45,
            includeWarmup: true,
            includeCooldown: true,
            randomSeed: 42
        )
        let output = try gen.generate(input: input)
        #expect(output.main.count >= 5)
    }

    // T-2: flexibility 目的 → main 空、cooldown のみ
    @Test("flexibility ゴールはメインが空でクールダウンのみ")
    func flexibilityGoalNoMain() throws {
        let gen = WorkoutGenerator(exercisePool: testPool)
        let input = GeneratorInput(
            goal: .flexibility,
            minutesAvailable: 30,
            includeWarmup: false,
            includeCooldown: true,
            randomSeed: 1
        )
        let output = try gen.generate(input: input)
        #expect(output.main.isEmpty)
        #expect(!output.cooldown.isEmpty)
    }

    // T-3: lockedExerciseSlugs が必ず main に含まれる
    @Test("lockedExerciseSlugs は必ずメインに含まれる")
    func lockedSlugAlwaysInMain() throws {
        let gen = WorkoutGenerator(exercisePool: testPool)
        let lockedSlug = "push_3"
        let input = GeneratorInput(
            lockedExerciseSlugs: [lockedSlug],
            goal: .generalFitness,
            minutesAvailable: 40,
            randomSeed: 7
        )
        let output = try gen.generate(input: input)
        #expect(output.main.contains { $0.slug == lockedSlug })
    }

    // T-4: 同じシードなら同じ出力
    @Test("同じシードは同じ出力を返す（再現性）")
    func sameSeedSameOutput() throws {
        let gen = WorkoutGenerator(exercisePool: testPool)
        let input = GeneratorInput(
            goal: .hypertrophy,
            minutesAvailable: 45,
            randomSeed: 12345
        )
        let out1 = try gen.generate(input: input)
        let out2 = try gen.generate(input: input)
        #expect(out1.main.map(\.slug) == out2.main.map(\.slug))
        #expect(out1.warmup.map(\.slug) == out2.warmup.map(\.slug))
    }

    // T-5: 該当 0 件 → AppError.generatorEmpty
    @Test("マッチする種目がゼロなら generatorEmpty をスロー")
    func emptyPoolThrowsGeneratorEmpty() {
        let gen = WorkoutGenerator(exercisePool: testPool)
        let input = GeneratorInput(
            equipment: [.kettlebell],   // testPool にケトルベル種目なし
            primaryMuscles: [.neck],    // neck 種目もなし
            goal: .strength,
            minutesAvailable: 30,
            includeWarmup: false,
            includeCooldown: false,
            randomSeed: 99
        )
        #expect(throws: AppError.generatorEmpty) {
            try gen.generate(input: input)
        }
    }
}
