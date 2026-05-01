import SwiftUI

struct GoalStepView: View {
    @Bindable var store: BuilderStore

    var body: some View {
        List(WorkoutGoal.allCases, id: \.self) { goal in
            GoalRow(goal: goal, isSelected: store.selectedGoal == goal)
                .contentShape(Rectangle())
                .onTapGesture {
                    store.selectedGoal = goal
                }
                .accessibilityAddTraits(store.selectedGoal == goal ? [.isButton, .isSelected] : .isButton)
                .accessibilityLabel(goal.localizedName)
                .accessibilityHint(goal.localizedDescription)
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - GoalRow

private struct GoalRow: View {
    let goal: WorkoutGoal
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                .imageScale(.large)

            VStack(alignment: .leading, spacing: 2) {
                Text(goal.localizedName)
                    .font(.body)
                    .fontWeight(isSelected ? .semibold : .regular)

                Text(goal.localizedDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - WorkoutGoal localization helpers

private extension WorkoutGoal {
    var localizedName: String {
        switch self {
        case .strength:       return String(localized: "goal.strength")
        case .hypertrophy:    return String(localized: "goal.hypertrophy")
        case .endurance:      return String(localized: "goal.endurance")
        case .flexibility:    return String(localized: "goal.flexibility")
        case .generalFitness: return String(localized: "goal.general_fitness")
        }
    }

    var localizedDescription: String {
        switch self {
        case .strength:
            return String(localized: "goal.strength.desc",
                          defaultValue: "最大筋力を高める高重量・低回数トレーニング")
        case .hypertrophy:
            return String(localized: "goal.hypertrophy.desc",
                          defaultValue: "筋肉の体積増加を狙った中重量・中回数トレーニング")
        case .endurance:
            return String(localized: "goal.endurance.desc",
                          defaultValue: "持久力向上のための軽重量・高回数トレーニング")
        case .flexibility:
            return String(localized: "goal.flexibility.desc",
                          defaultValue: "可動域と柔軟性を高めるストレッチ中心メニュー")
        case .generalFitness:
            return String(localized: "goal.general_fitness.desc",
                          defaultValue: "バランスよく体力を向上させる総合プログラム")
        }
    }
}
