import os

private let logger = Logger(subsystem: "com.tomo.workoutkit", category: "WorkoutGenerator")

/// exercises_seed.json から読み込んだプールを受け取り、
/// GeneratorInput に基づいてワークアウトプランを生成する純粋サービス。
/// 副作用なし・外部依存なし。
struct WorkoutGenerator {
    private let exercisePool: [Exercise]

    init(exercisePool: [Exercise]) {
        self.exercisePool = exercisePool
    }

    // MARK: - Public

    func generate(input: GeneratorInput) throws -> GeneratorOutput {
        var rng = WorkoutRNG(seed: input.randomSeed)

        let warmup = input.includeWarmup ? buildWarmup(rng: &rng) : []
        let main   = try buildMain(input: input, rng: &rng)
        let cooldown = input.includeCooldown
            ? buildCooldown(usedMuscles: Set(main.flatMap(\.primaryMuscles)), rng: &rng)
            : []

        logger.debug("Generated: warmup=\(warmup.count) main=\(main.count) cooldown=\(cooldown.count)")
        return GeneratorOutput(warmup: warmup, main: main, cooldown: cooldown)
    }

    // MARK: - Main block

    private func buildMain(input: GeneratorInput, rng: inout WorkoutRNG) throws -> [Exercise] {
        guard !input.goal.skipMain else { return [] }

        let mainMinutes = availableMainMinutes(input: input)
        let targetCount = max(0, mainMinutes / input.goal.minutesPerExercise)

        let locked      = lockedExercises(slugs: input.lockedExerciseSlugs)
        let lockedSlugs = Set(locked.map(\.slug))

        let candidates = exercisePool.filter { ex in
            ex.category.isMainCategory
            && !lockedSlugs.contains(ex.slug)
            && matchesEquipment(ex, input.equipment)
            && matchesMuscles(ex, input.primaryMuscles)
        }

        let remaining = max(0, targetCount - locked.count)
        let picked = pick(from: candidates, count: remaining,
                         compoundRatio: input.goal.compoundRatio, rng: &rng)

        let main = locked + picked
        guard !main.isEmpty else { throw AppError.generatorEmpty }

        return avoidConsecutiveSameMuscle(main, rng: &rng)
    }

    // MARK: - Warmup / Cooldown

    private func buildWarmup(rng: inout WorkoutRNG) -> [Exercise] {
        var pool = exercisePool.filter { $0.category == .warmup }
        pool.shuffle(using: &rng)
        return Array(pool.prefix(clamp(pool.count, lo: 3, hi: 5)))
    }

    private func buildCooldown(usedMuscles: Set<MuscleGroup>, rng: inout WorkoutRNG) -> [Exercise] {
        let stretches = exercisePool.filter { $0.category == .stretching }
        let relevant  = stretches.filter { !$0.allMuscles.isDisjoint(with: usedMuscles) }
        var pool      = relevant.isEmpty ? stretches : relevant
        pool.shuffle(using: &rng)
        return Array(pool.prefix(clamp(pool.count, lo: 3, hi: 5)))
    }

    // MARK: - Selection helpers

    private func pick(
        from candidates: [Exercise],
        count: Int,
        compoundRatio: Double,
        rng: inout WorkoutRNG
    ) -> [Exercise] {
        guard count > 0 else { return [] }

        var compounds  = candidates.filter {  $0.category.isCompound }.shuffled(using: &rng)
        var isolations = candidates.filter { !$0.category.isCompound }.shuffled(using: &rng)

        let wantCompound  = Int((Double(count) * compoundRatio).rounded())
        let wantIsolation = count - wantCompound

        var picked  = Array(compounds.prefix(wantCompound))
                    + Array(isolations.prefix(wantIsolation))

        // 比率通りに集まらない場合は残り候補で補充
        if picked.count < count {
            let usedSlugs = Set(picked.map(\.slug))
            let leftover  = candidates
                .filter { !usedSlugs.contains($0.slug) }
                .shuffled(using: &rng)
            picked += Array(leftover.prefix(count - picked.count))
        }
        return picked
    }

    /// 同一筋群が連続しないよう貪欲法で並び替え
    private func avoidConsecutiveSameMuscle(
        _ exercises: [Exercise],
        rng: inout WorkoutRNG
    ) -> [Exercise] {
        var remaining = exercises.shuffled(using: &rng)
        var result: [Exercise] = []

        while !remaining.isEmpty {
            let lastPrimary = result.last.map { Set($0.primaryMuscles) } ?? []
            let idx = remaining.firstIndex {
                Set($0.primaryMuscles).isDisjoint(with: lastPrimary)
            } ?? 0
            result.append(remaining.remove(at: idx))
        }
        return result
    }

    // MARK: - Pure helpers

    private func lockedExercises(slugs: [String]) -> [Exercise] {
        exercisePool.filter { slugs.contains($0.slug) }
    }

    private func matchesEquipment(_ ex: Exercise, _ filter: [Equipment]) -> Bool {
        filter.isEmpty || filter.contains(ex.equipment)
    }

    private func matchesMuscles(_ ex: Exercise, _ filter: [MuscleGroup]) -> Bool {
        filter.isEmpty || !ex.allMuscles.isDisjoint(with: Set(filter))
    }

    private func availableMainMinutes(input: GeneratorInput) -> Int {
        let warmupMin   = input.includeWarmup   ? 5 : 0
        let cooldownMin = input.includeCooldown ? 5 : 0
        return max(0, input.minutesAvailable - warmupMin - cooldownMin)
    }

    private func clamp(_ value: Int, lo: Int, hi: Int) -> Int {
        min(hi, max(lo, value))
    }
}
