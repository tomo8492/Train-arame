import SwiftUI

struct ResultStepView: View {
    let store: BuilderStore
    let onDismiss: () -> Void

    var body: some View {
        Group {
            if store.isLoading {
                loadingView
            } else if let errorMessage = store.errorMessage {
                errorView(message: errorMessage)
            } else if let output = store.output {
                resultList(output: output)
            } else {
                emptyView
            }
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text(String(localized: "result.generating", defaultValue: "生成中..."))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Error

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Button(String(localized: "builder.retry")) {
                Task { await store.confirm() }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty

    private var emptyView: some View {
        ContentUnavailableView(
            String(localized: "result.empty.title", defaultValue: "結果なし"),
            systemImage: "tray",
            description: Text(String(localized: "result.empty.desc",
                                     defaultValue: "ワークアウトが生成されませんでした。"))
        )
    }

    // MARK: - Result list

    private func resultList(output: GeneratorOutput) -> some View {
        let scStore = store.shuffleChooseStore
        return List {
            // Mode toggle
            Section {
                Picker(String(localized: "result.mode.label", defaultValue: "モード"),
                       selection: Bindable(scStore).mode) {
                    Text(String(localized: "result.mode.shuffle")).tag(ResultMode.shuffle)
                    Text(String(localized: "result.mode.choose")).tag(ResultMode.choose)
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            }

            if !output.warmup.isEmpty {
                Section(String(localized: "result.section.warmup", defaultValue: "ウォームアップ")) {
                    ForEach(output.warmup) { exercise in
                        ExerciseResultRow(
                            exercise: exercise,
                            isChooseMode: scStore.mode == .choose,
                            isLocked: scStore.isLocked(exercise.slug),
                            onToggleLock: { scStore.toggleLock(slug: exercise.slug) }
                        )
                    }
                }
            }

            if !output.main.isEmpty {
                Section(String(localized: "result.section.main", defaultValue: "メインセット")) {
                    ForEach(output.main) { exercise in
                        ExerciseResultRow(
                            exercise: exercise,
                            isChooseMode: scStore.mode == .choose,
                            isLocked: scStore.isLocked(exercise.slug),
                            onToggleLock: { scStore.toggleLock(slug: exercise.slug) }
                        )
                    }
                }
            }

            if !output.cooldown.isEmpty {
                Section(String(localized: "result.section.cooldown", defaultValue: "クールダウン")) {
                    ForEach(output.cooldown) { exercise in
                        ExerciseResultRow(
                            exercise: exercise,
                            isChooseMode: scStore.mode == .choose,
                            isLocked: scStore.isLocked(exercise.slug),
                            onToggleLock: { scStore.toggleLock(slug: exercise.slug) }
                        )
                    }
                }
            }

            // Footer actions
            Section {
                if scStore.mode == .shuffle {
                    Button(String(localized: "result.regenerate")) {
                        Task { await store.regenerate() }
                    }
                    .frame(maxWidth: .infinity)
                }
                Button(String(localized: "builder.start.session")) {
                    onDismiss()
                }
                .frame(maxWidth: .infinity)
                .fontWeight(.semibold)
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - ExerciseResultRow

private struct ExerciseResultRow: View {
    let exercise: Exercise
    let isChooseMode: Bool
    let isLocked: Bool
    let onToggleLock: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.body)
                Text(exercise.nameEn)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isChooseMode {
                Button(action: onToggleLock) {
                    Image(systemName: isLocked ? "lock.fill" : "lock.open")
                        .foregroundStyle(isLocked ? .orange : .secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    isLocked
                        ? String(localized: "result.lock.on", defaultValue: "ロック中")
                        : String(localized: "result.lock.off", defaultValue: "ロック解除中")
                )
                .accessibilityHint(String(localized: "result.lock.hint", defaultValue: "タップしてロックを切り替えます"))
            }
        }
        .padding(.vertical, 2)
        .listRowBackground(
            isChooseMode && isLocked
                ? Color.orange.opacity(0.12)
                : Color(uiColor: .secondarySystemGroupedBackground)
        )
    }
}
