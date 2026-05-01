import SwiftUI

struct MuscleStepView: View {
    @Bindable var store: BuilderStore

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                clearButton
                    .padding(.horizontal)

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(MuscleGroup.allCases, id: \.self) { muscle in
                        MuscleToggleCell(
                            muscle: muscle,
                            isSelected: store.selectedMuscles.contains(muscle)
                        )
                        .onTapGesture {
                            toggleMuscle(muscle)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    // MARK: - Helpers

    private var clearButton: some View {
        HStack {
            Spacer()
            Button(String(localized: "muscle.clear.all", defaultValue: "すべてクリア")) {
                store.selectedMuscles.removeAll()
            }
            .font(.subheadline)
            .foregroundStyle(store.selectedMuscles.isEmpty ? Color.secondary : Color.accentColor)
            .disabled(store.selectedMuscles.isEmpty)
        }
    }

    private func toggleMuscle(_ muscle: MuscleGroup) {
        if store.selectedMuscles.contains(muscle) {
            store.selectedMuscles.remove(muscle)
        } else {
            store.selectedMuscles.insert(muscle)
        }
    }
}

// MARK: - MuscleToggleCell

private struct MuscleToggleCell: View {
    let muscle: MuscleGroup
    let isSelected: Bool

    var body: some View {
        HStack {
            Text(muscle.localizedName)
                .font(.subheadline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .imageScale(.small)
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(isSelected ? Color.accentColor.opacity(0.15) : Color(.secondarySystemGroupedBackground))
        .foregroundStyle(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(.primary))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
        )
    }
}

// MARK: - MuscleGroup localization

private extension MuscleGroup {
    var localizedName: String {
        switch self {
        case .quadriceps:          return String(localized: "muscle.quadriceps",          defaultValue: "大腿四頭筋")
        case .hamstrings:          return String(localized: "muscle.hamstrings",           defaultValue: "ハムストリング")
        case .glutes:              return String(localized: "muscle.glutes",               defaultValue: "臀部")
        case .calves:              return String(localized: "muscle.calves",               defaultValue: "ふくらはぎ")
        case .hipFlexors:          return String(localized: "muscle.hip_flexors",          defaultValue: "腸腰筋")
        case .pectoralisMajor:     return String(localized: "muscle.pectoralis_major",     defaultValue: "大胸筋")
        case .pectoralisMinor:     return String(localized: "muscle.pectoralis_minor",     defaultValue: "小胸筋")
        case .latissimusDorsi:     return String(localized: "muscle.latissimus_dorsi",     defaultValue: "広背筋")
        case .rhomboids:           return String(localized: "muscle.rhomboids",            defaultValue: "菱形筋")
        case .trapezius:           return String(localized: "muscle.trapezius",            defaultValue: "僧帽筋")
        case .erectorSpinae:       return String(localized: "muscle.erector_spinae",       defaultValue: "脊柱起立筋")
        case .deltoid:             return String(localized: "muscle.deltoid",              defaultValue: "三角筋")
        case .anteriorDeltoid:     return String(localized: "muscle.anterior_deltoid",     defaultValue: "前部三角筋")
        case .rearDeltoid:         return String(localized: "muscle.rear_deltoid",         defaultValue: "後部三角筋")
        case .biceps:              return String(localized: "muscle.biceps",               defaultValue: "上腕二頭筋")
        case .triceps:             return String(localized: "muscle.triceps",              defaultValue: "上腕三頭筋")
        case .brachialis:          return String(localized: "muscle.brachialis",           defaultValue: "上腕筋")
        case .forearms:            return String(localized: "muscle.forearms",             defaultValue: "前腕")
        case .core:                return String(localized: "muscle.core",                 defaultValue: "体幹")
        case .rectusAbdominis:     return String(localized: "muscle.rectus_abdominis",     defaultValue: "腹直筋")
        case .obliques:            return String(localized: "muscle.obliques",             defaultValue: "腹斜筋")
        case .transverseAbdominis: return String(localized: "muscle.transverse_abdominis", defaultValue: "腹横筋")
        case .neck:                return String(localized: "muscle.neck",                 defaultValue: "首")
        case .chest:               return String(localized: "muscle.chest",                defaultValue: "胸")
        case .back:                return String(localized: "muscle.back",                 defaultValue: "背中")
        case .shoulders:           return String(localized: "muscle.shoulders",            defaultValue: "肩")
        case .arms:                return String(localized: "muscle.arms",                 defaultValue: "腕")
        case .legs:                return String(localized: "muscle.legs",                 defaultValue: "脚")
        }
    }
}
