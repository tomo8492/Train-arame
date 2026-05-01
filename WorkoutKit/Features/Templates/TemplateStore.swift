import Foundation
import SwiftData
import Observation

@Observable @MainActor
final class TemplateStore {
    private(set) var templates: [WorkoutTemplate] = []
    private let context: ModelContext
    private let gate: ProFeatureGate

    init(context: ModelContext, gate: ProFeatureGate) {
        self.context = context
        self.gate = gate
        seedPresetsIfNeeded()
        fetchTemplates()
    }

    func create(name: String, exerciseSlugs: [String]) {
        guard gate.check(.customTemplates) else { return }
        let template = WorkoutTemplate(name: name, exerciseSlugs: exerciseSlugs, isPreset: false)
        context.insert(template)
        fetchTemplates()
    }

    func delete(_ template: WorkoutTemplate) {
        guard !template.isPreset else { return }
        context.delete(template)
        fetchTemplates()
    }

    func update(_ template: WorkoutTemplate, name: String, exerciseSlugs: [String]) {
        template.name = name
        template.exerciseSlugs = exerciseSlugs
        fetchTemplates()
    }

    private func fetchTemplates() {
        var descriptor = FetchDescriptor<WorkoutTemplate>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        descriptor.fetchLimit = 200
        let all = (try? context.fetch(descriptor)) ?? []
        templates = all.sorted { ($0.isPreset ? 0 : 1) < ($1.isPreset ? 0 : 1) }
    }

    private func seedPresetsIfNeeded() {
        let descriptor = FetchDescriptor<WorkoutTemplate>(
            predicate: #Predicate { $0.isPreset == true }
        )
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else { return }

        let presets: [(String, [String])] = [
            ("PPL（プッシュ・プル・脚）", [
                "bench_press_barbell", "overhead_press_barbell", "tricep_pushdown_cable",
                "deadlift_barbell", "barbell_row", "bicep_curl_barbell",
                "squat_barbell", "leg_press_machine", "leg_curl_machine"
            ]),
            ("上下分割", [
                "bench_press_barbell", "overhead_press_barbell", "barbell_row",
                "squat_barbell", "deadlift_barbell", "leg_press_machine"
            ]),
            ("全身トレーニング", [
                "squat_barbell", "bench_press_barbell", "deadlift_barbell",
                "barbell_row", "overhead_press_barbell", "bicep_curl_barbell"
            ])
        ]

        for (name, slugs) in presets {
            context.insert(WorkoutTemplate(name: name, exerciseSlugs: slugs, isPreset: true))
        }
    }
}
