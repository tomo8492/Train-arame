import Testing
import SwiftData
@testable import WorkoutKit

@Suite("TemplateStore")
@MainActor
struct TemplateStoreTests {
    private func makeStore() throws -> (TemplateStore, ModelContext) {
        let schema = Schema([WorkoutTemplate.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)
        let gate = ProFeatureGate(isPremium: true)
        let store = TemplateStore(context: context, gate: gate)
        return (store, context)
    }

    @Test("起動時に3プリセットが生成される")
    func seedsThreePresets() throws {
        let (store, _) = try makeStore()
        let presets = store.templates.filter(\.isPreset)
        #expect(presets.count == 3)
    }

    @Test("2回初期化しても重複しない（冪等）")
    func idempotentSeed() throws {
        let schema = Schema([WorkoutTemplate.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)
        let gate = ProFeatureGate(isPremium: true)
        _ = TemplateStore(context: context, gate: gate)
        let store2 = TemplateStore(context: context, gate: gate)
        let presets = store2.templates.filter(\.isPreset)
        #expect(presets.count == 3)
    }

    @Test("Pro ユーザーはカスタムテンプレートを作成できる")
    func createCustomTemplate() throws {
        let (store, _) = try makeStore()
        let initialCount = store.templates.count
        store.create(name: "マイルーティン", exerciseSlugs: ["squat_barbell"])
        #expect(store.templates.count == initialCount + 1)
    }

    @Test("プリセットは削除できない")
    func cannotDeletePreset() throws {
        let (store, _) = try makeStore()
        guard let preset = store.templates.first(where: \.isPreset) else { return }
        store.delete(preset)
        #expect(store.templates.contains(where: { $0.id == preset.id }))
    }

    @Test("カスタムテンプレートは削除できる")
    func canDeleteCustomTemplate() throws {
        let (store, _) = try makeStore()
        store.create(name: "削除テスト", exerciseSlugs: ["bench_press_barbell"])
        guard let custom = store.templates.first(where: { !$0.isPreset }) else {
            Issue.record("No custom template found")
            return
        }
        let beforeCount = store.templates.count
        store.delete(custom)
        #expect(store.templates.count == beforeCount - 1)
    }

    @Test("Non-Pro ユーザーはカスタムテンプレートを作成できない")
    func nonProCannotCreate() throws {
        let schema = Schema([WorkoutTemplate.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)
        let gate = ProFeatureGate(isPremium: false)
        let store = TemplateStore(context: context, gate: gate)
        let initialCount = store.templates.count
        store.create(name: "試み", exerciseSlugs: ["squat_barbell"])
        #expect(store.templates.count == initialCount)
    }

    @Test("updateでテンプレート名と種目が更新される")
    func updateTemplate() throws {
        let (store, _) = try makeStore()
        store.create(name: "元の名前", exerciseSlugs: ["squat_barbell"])
        guard let custom = store.templates.first(where: { !$0.isPreset }) else {
            Issue.record("No custom template found")
            return
        }
        store.update(custom, name: "更新後の名前", exerciseSlugs: ["deadlift_barbell"])
        #expect(custom.name == "更新後の名前")
        #expect(custom.exerciseSlugs == ["deadlift_barbell"])
    }
}
