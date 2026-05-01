import SwiftUI

struct EquipmentStepView: View {
    @Bindable var store: BuilderStore

    var body: some View {
        List(Equipment.allCases, id: \.self) { equipment in
            EquipmentRow(
                equipment: equipment,
                isSelected: store.selectedEquipment.contains(equipment)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                toggleEquipment(equipment)
            }
        }
        .listStyle(.insetGrouped)
    }

    private func toggleEquipment(_ equipment: Equipment) {
        if store.selectedEquipment.contains(equipment) {
            store.selectedEquipment.remove(equipment)
        } else {
            store.selectedEquipment.insert(equipment)
        }
    }
}

// MARK: - EquipmentRow

private struct EquipmentRow: View {
    let equipment: Equipment
    let isSelected: Bool

    private var tintColor: Color { isSelected ? .accentColor : Color.secondary }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: equipment.iconName)
                .foregroundColor(tintColor)
                .frame(width: 24)

            Text(equipment.localizedName)
                .font(.body)
                .fontWeight(isSelected ? .semibold : .regular)

            Spacer()

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(tintColor)
                .imageScale(.large)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Equipment localization & icons

private extension Equipment {
    var localizedName: String {
        switch self {
        case .barbell:        return String(localized: "equipment.barbell",         defaultValue: "バーベル")
        case .dumbbell:       return String(localized: "equipment.dumbbell",        defaultValue: "ダンベル")
        case .cable:          return String(localized: "equipment.cable",           defaultValue: "ケーブル")
        case .machine:        return String(localized: "equipment.machine",         defaultValue: "マシン")
        case .bodyweight:     return String(localized: "equipment.bodyweight",      defaultValue: "自重")
        case .kettlebell:     return String(localized: "equipment.kettlebell",      defaultValue: "ケトルベル")
        case .resistanceBand: return String(localized: "equipment.resistance_band", defaultValue: "レジスタンスバンド")
        case .foamRoller:     return String(localized: "equipment.foam_roller",     defaultValue: "フォームローラー")
        }
    }

    var iconName: String {
        switch self {
        case .barbell:        return "dumbbell.fill"
        case .dumbbell:       return "dumbbell"
        case .cable:          return "cable.coaxial"
        case .machine:        return "gearshape.fill"
        case .bodyweight:     return "figure.strengthtraining.traditional"
        case .kettlebell:     return "circle.hexagongrid.fill"
        case .resistanceBand: return "arrow.left.and.right"
        case .foamRoller:     return "cylinder.fill"
        }
    }
}
