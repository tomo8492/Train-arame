import Testing
@testable import WorkoutKit

// MARK: - Shared test fixture (mirrors WorkoutGeneratorTests)

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

private let shuffleTestPool: [Exercise] = {
    var pool: [Exercise] = []
    for i in 1...5 {
        pool.append(makeExercise(slug: "wu_\(i)", category: .warmup, primary: [.shoulders]))
    }
    for i in 1...10 {
        pool.append(makeExercise(slug: "push_\(i)", category: .strengthCompound,
                                 primary: [.pectoralisMajor],
                                 secondary: [.triceps], equipment: .bodyweight))
    }
    for i in 1...10 {
        pool.append(makeExercise(slug: "stretch_\(i)", category: .stretching,
                                 primary: [.pectoralisMajor]))
    }
    return pool
}()

// MARK: - Test Suite

@Suite("ShuffleChooseStore")
struct ShuffleChooseTests {

    // T-1: locked slug persists after regenerate
    @Test("ロックした種目は再生成後も保持される")
    func lockedSlugPersistedAfterRegenerate() async throws {
        let store = await BuilderStore(exercisePool: shuffleTestPool)

        // Initial generation
        await store.confirm()
        let output = await store.output
        guard let firstSlug = output?.main.first?.slug else {
            Issue.record("No main exercises after first generate")
            return
        }

        // Lock a slug via shuffleChooseStore
        await store.shuffleChooseStore.toggleLock(slug: firstSlug)
        let isLockedBefore = await store.shuffleChooseStore.isLocked(firstSlug)
        #expect(isLockedBefore, "Slug should be locked before regenerate")

        // Regenerate — locked slug should remain in lockedSlugs
        await store.regenerate()

        let isLockedAfter = await store.shuffleChooseStore.isLocked(firstSlug)
        #expect(isLockedAfter, "Slug should still be locked after regenerate")
    }

    // T-2: toggleLock adds and removes alternately
    @Test("toggleLock で追加・削除が交互に起きる")
    func toggleLockAddRemove() async {
        let s = await ShuffleChooseStore()
        await s.toggleLock(slug: "push_1")
        let lockedOnce = await s.isLocked("push_1")
        #expect(lockedOnce)
        await s.toggleLock(slug: "push_1")
        let lockedTwice = await s.isLocked("push_1")
        #expect(!lockedTwice)
    }

    // T-3: mode defaults to .shuffle
    @Test("デフォルトモードは shuffle")
    func defaultModeIsShuffle() async {
        let s = await ShuffleChooseStore()
        let mode = await s.mode
        #expect(mode == .shuffle)
    }

    // T-4: multiple slugs can be locked independently
    @Test("複数のスラッグを個別にロックできる")
    func multipleSlugsLocked() async {
        let s = await ShuffleChooseStore()
        await s.toggleLock(slug: "push_1")
        await s.toggleLock(slug: "push_2")
        let locked1 = await s.isLocked("push_1")
        let locked2 = await s.isLocked("push_2")
        let locked3 = await s.isLocked("push_3")
        #expect(locked1)
        #expect(locked2)
        #expect(!locked3)
    }
}
