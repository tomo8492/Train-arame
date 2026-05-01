import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                musclesSection
                equipmentSection
                descriptionSection
                youtubeSection
            }
            .padding()
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.nameEn)
                .font(.title3)
                .foregroundStyle(.secondary)

            Text(exercise.category.localizedName)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(exercise.category.badgeColor.opacity(0.15))
                .foregroundStyle(exercise.category.badgeColor)
                .clipShape(Capsule())
        }
    }

    // MARK: - Muscles

    private var musclesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            primaryMusclesView

            if !exercise.secondaryMuscles.isEmpty {
                secondaryMusclesView
            }
        }
    }

    private var primaryMusclesView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(String(localized: "library.detail.primary"), systemImage: "flame.fill")
                .font(.headline)
                .foregroundStyle(.primary)

            FlowTagRow(tags: exercise.primaryMuscles.map(\.localizedName), tintColor: .accentColor)
        }
    }

    private var secondaryMusclesView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(String(localized: "library.detail.secondary"), systemImage: "flame")
                .font(.headline)
                .foregroundStyle(.primary)

            FlowTagRow(tags: exercise.secondaryMuscles.map(\.localizedName), tintColor: .secondary)
        }
    }

    // MARK: - Equipment

    private var equipmentSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(String(localized: "library.detail.equipment"), systemImage: "wrench.and.screwdriver")
                .font(.headline)

            HStack(spacing: 8) {
                Image(systemName: exercise.equipment.iconName)
                    .foregroundStyle(.tint)
                Text(exercise.equipment.localizedName)
                    .font(.body)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("説明", systemImage: "text.alignleft")
                .font(.headline)

            Text("詳細説明は準備中です")
                .font(.body)
                .foregroundStyle(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - YouTube (Pro placeholder)

    private var youtubeSection: some View {
        Button {
            // Pro feature — not yet implemented
        } label: {
            Label(String(localized: "library.detail.youtube"), systemImage: "play.rectangle.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .disabled(true)
        .foregroundStyle(.secondary)
    }
}

// MARK: - FlowTagRow

private struct FlowTagRow: View {
    let tags: [String]
    let tintColor: Color

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(tintColor.opacity(0.12))
                        .foregroundStyle(tintColor == .secondary ? AnyShapeStyle(Color.secondary) : AnyShapeStyle(Color.accentColor))
                        .clipShape(Capsule())
                }
            }
        }
    }
}

// Display extensions (localizedName, iconName, badgeColor) live in Shared/ExerciseDisplayExtensions.swift

// MARK: - Preview

#Preview {
    NavigationStack {
        ExerciseDetailView(
            exercise: Exercise(
                slug: "bench_press",
                name: "ベンチプレス",
                nameEn: "Bench Press",
                category: .strengthCompound,
                primaryMuscles: [.pectoralisMajor, .triceps],
                secondaryMuscles: [.anteriorDeltoid],
                equipment: .barbell
            )
        )
    }
}
