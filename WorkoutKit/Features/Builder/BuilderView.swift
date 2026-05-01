import SwiftUI

struct BuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store: BuilderStore

    /// Called when the user taps "セッション開始" — passes the generated output to the caller.
    var onSessionStart: ((GeneratorOutput) -> Void)?

    init(exercisePool: [Exercise], onSessionStart: ((GeneratorOutput) -> Void)? = nil) {
        _store = State(initialValue: BuilderStore(exercisePool: exercisePool))
        self.onSessionStart = onSessionStart
    }

    var body: some View {
        NavigationStack {
            stepContent
                .navigationTitle(navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(String(localized: "builder.back")) {
                            store.back()
                        }
                        .disabled(!store.canGoBack)
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button(trailingButtonTitle) {
                            handleTrailingTap()
                        }
                        .disabled(!store.canGoNext)
                        .fontWeight(.semibold)
                    }
                }
        }
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch store.currentStep {
        case .goal:
            GoalStepView(store: store)
        case .muscle:
            MuscleStepView(store: store)
        case .equipment:
            EquipmentStepView(store: store)
        case .time:
            TimeStepView(store: store)
        case .result:
            ResultStepView(store: store, onDismiss: {
                if let output = store.output {
                    onSessionStart?(output)
                }
                dismiss()
            })
        }
    }

    // MARK: - Computed helpers

    private var navigationTitle: String {
        switch store.currentStep {
        case .goal:      return String(localized: "builder.step.goal")
        case .muscle:    return String(localized: "builder.step.muscle")
        case .equipment: return String(localized: "builder.step.equipment")
        case .time:      return String(localized: "builder.step.time")
        case .result:    return String(localized: "builder.step.result")
        }
    }

    private var trailingButtonTitle: String {
        switch store.currentStep {
        case .time:   return String(localized: "builder.generate")
        case .result: return ""
        default:      return String(localized: "builder.next")
        }
    }

    private func handleTrailingTap() {
        if store.currentStep == .time {
            store.next()
            Task { await store.confirm() }
        } else {
            store.next()
        }
    }
}
