import SwiftUI

struct ExerciseListView: View {
    @State private var store: LibraryStore
    @State private var selectedExercise: Exercise?
    @State private var showFilterSheet: Bool = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(exercises: [Exercise]) {
        _store = State(initialValue: LibraryStore(exercises: exercises))
    }

    var body: some View {
        if horizontalSizeClass == .regular {
            splitLayout
        } else {
            stackLayout
        }
    }

    // MARK: - Layouts

    private var splitLayout: some View {
        NavigationSplitView {
            exerciseList
                .navigationTitle(String(localized: "library.title"))
        } detail: {
            if let exercise = selectedExercise {
                ExerciseDetailView(exercise: exercise)
            } else {
                ContentUnavailableView(
                    String(localized: "library.title"),
                    systemImage: "list.bullet.clipboard",
                    description: Text("種目を選択してください")
                )
            }
        }
    }

    private var stackLayout: some View {
        NavigationStack {
            exerciseList
                .navigationTitle(String(localized: "library.title"))
                .navigationDestination(item: $selectedExercise) { exercise in
                    ExerciseDetailView(exercise: exercise)
                }
        }
    }

    // MARK: - List content

    private var exerciseList: some View {
        Group {
            if store.filtered.isEmpty {
                ContentUnavailableView(
                    String(localized: "library.empty"),
                    systemImage: "magnifyingglass",
                    description: Text("フィルターを変更してください")
                )
            } else {
                groupedList
            }
        }
        .searchable(
            text: $store.searchText,
            prompt: String(localized: "library.search.prompt")
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                filterButton
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheetView(store: store)
        }
    }

    private var groupedList: some View {
        let grouped = Dictionary(grouping: store.filtered, by: \.category)
        let orderedCategories = ExerciseCategory.allCases.filter { grouped[$0] != nil }

        return List(selection: $selectedExercise) {
            ForEach(orderedCategories, id: \.self) { category in
                Section(header: categoryHeader(category)) {
                    ForEach(grouped[category] ?? []) { exercise in
                        ExerciseRow(exercise: exercise)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedExercise = exercise
                            }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func categoryHeader(_ category: ExerciseCategory) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(category.badgeColor)
                .frame(width: 8, height: 8)
            Text(category.localizedName)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(category.badgeColor)
        }
    }

    // MARK: - Filter button

    private var filterButton: some View {
        Button {
            showFilterSheet = true
        } label: {
            Label(
                String(localized: "library.filter.title"),
                systemImage: store.hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"
            )
        }
        .symbolRenderingMode(store.hasActiveFilters ? .hierarchical : .monochrome)
        .tint(store.hasActiveFilters ? .accentColor : .primary)
    }
}

// MARK: - ExerciseRow

private struct ExerciseRow: View {
    let exercise: Exercise

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(exercise.name)
                    .font(.body)
                    .fontWeight(.medium)

                Text(exercise.nameEn)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 4) {
                    if let primary = exercise.primaryMuscles.first {
                        Text(primary.localizedName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    if exercise.primaryMuscles.count > 1 {
                        Text("+\(exercise.primaryMuscles.count - 1)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Spacer()

            Image(systemName: exercise.equipment.iconName)
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - FilterSheetView

private struct FilterSheetView: View {
    @Bindable var store: LibraryStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "library.filter.category")) {
                    Picker(String(localized: "library.filter.category"), selection: $store.selectedCategory) {
                        Text(String(localized: "library.filter.all")).tag(ExerciseCategory?.none)
                        ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                            Text(cat.localizedName).tag(ExerciseCategory?.some(cat))
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }

                Section(String(localized: "library.filter.muscle")) {
                    Picker(String(localized: "library.filter.muscle"), selection: $store.selectedMuscle) {
                        Text(String(localized: "library.filter.all")).tag(MuscleGroup?.none)
                        ForEach(MuscleGroup.allCases, id: \.self) { muscle in
                            Text(muscle.localizedName).tag(MuscleGroup?.some(muscle))
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }

                Section(String(localized: "library.filter.equipment")) {
                    Picker(String(localized: "library.filter.equipment"), selection: $store.selectedEquipment) {
                        Text(String(localized: "library.filter.all")).tag(Equipment?.none)
                        ForEach(Equipment.allCases, id: \.self) { eq in
                            Text(eq.localizedName).tag(Equipment?.some(eq))
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }

                if store.hasActiveFilters {
                    Section {
                        Button(role: .destructive) {
                            store.clearFilters()
                        } label: {
                            Text("フィルターをクリア")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "library.filter.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Preview

#Preview {
    ExerciseListView(exercises: [
        Exercise(
            slug: "bench_press",
            name: "ベンチプレス",
            nameEn: "Bench Press",
            category: .strengthCompound,
            primaryMuscles: [.pectoralisMajor, .triceps],
            secondaryMuscles: [.anteriorDeltoid],
            equipment: .barbell
        ),
        Exercise(
            slug: "squat",
            name: "スクワット",
            nameEn: "Squat",
            category: .strengthCompound,
            primaryMuscles: [.quadriceps, .glutes],
            secondaryMuscles: [.hamstrings],
            equipment: .barbell
        ),
        Exercise(
            slug: "arm_circle",
            name: "アームサークル",
            nameEn: "Arm Circle",
            category: .warmup,
            primaryMuscles: [.deltoid],
            secondaryMuscles: [.shoulders],
            equipment: .bodyweight
        )
    ])
}
