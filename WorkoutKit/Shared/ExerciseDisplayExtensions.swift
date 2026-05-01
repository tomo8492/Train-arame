import SwiftUI

// MARK: - MuscleGroup display helpers

extension MuscleGroup {
    var localizedName: String {
        switch self {
        case .quadriceps:          return String(localized: "muscle.quadriceps",           defaultValue: "大腿四頭筋")
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

// MARK: - Equipment display helpers

extension Equipment {
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

// MARK: - ExerciseCategory display helpers

extension ExerciseCategory {
    var localizedName: String {
        switch self {
        case .warmup:             return String(localized: "category.warmup",              defaultValue: "ウォームアップ")
        case .strengthCompound:   return String(localized: "category.strength_compound",   defaultValue: "複合筋力")
        case .strengthIsolation:  return String(localized: "category.strength_isolation",  defaultValue: "単関節筋力")
        case .calisthenics:       return String(localized: "category.calisthenics",        defaultValue: "自重トレーニング")
        case .stretching:         return String(localized: "category.stretching",          defaultValue: "ストレッチ")
        case .cardio:             return String(localized: "category.cardio",              defaultValue: "有酸素")
        }
    }

    var badgeColor: Color {
        switch self {
        case .warmup:            return .orange
        case .strengthCompound:  return .blue
        case .strengthIsolation: return .indigo
        case .calisthenics:      return .green
        case .stretching:        return .teal
        case .cardio:            return .red
        }
    }
}
