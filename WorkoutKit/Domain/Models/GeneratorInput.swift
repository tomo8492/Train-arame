struct GeneratorInput: Sendable {
    /// 必ずメインブロックに含める種目のスラッグ
    let lockedExerciseSlugs: [String]
    /// 使用可能な器具（空 = すべて許可）
    let equipment: [Equipment]
    /// ターゲット筋群（空 = 全筋群）
    let primaryMuscles: [MuscleGroup]
    /// トレーニング目的
    let goal: WorkoutGoal
    /// 合計利用可能時間（分）
    let minutesAvailable: Int
    /// ウォームアップを含めるか
    let includeWarmup: Bool
    /// クールダウンを含めるか
    let includeCooldown: Bool
    /// テスト再現性用のシード（nil = ランダム）
    let randomSeed: UInt64?

    init(
        lockedExerciseSlugs: [String] = [],
        equipment: [Equipment] = [],
        primaryMuscles: [MuscleGroup] = [],
        goal: WorkoutGoal = .generalFitness,
        minutesAvailable: Int = 45,
        includeWarmup: Bool = true,
        includeCooldown: Bool = true,
        randomSeed: UInt64? = nil
    ) {
        self.lockedExerciseSlugs = lockedExerciseSlugs
        self.equipment = equipment
        self.primaryMuscles = primaryMuscles
        self.goal = goal
        self.minutesAvailable = minutesAvailable
        self.includeWarmup = includeWarmup
        self.includeCooldown = includeCooldown
        self.randomSeed = randomSeed
    }
}
