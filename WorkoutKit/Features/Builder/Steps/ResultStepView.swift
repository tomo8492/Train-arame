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
        List {
            if !output.warmup.isEmpty {
                Section(String(localized: "result.section.warmup", defaultValue: "ウォームアップ")) {
                    ForEach(output.warmup) { exercise in
                        ExerciseResultRow(exercise: exercise)
                    }
                }
            }

            if !output.main.isEmpty {
                Section(String(localized: "result.section.main", defaultValue: "メインセット")) {
                    ForEach(output.main) { exercise in
                        ExerciseResultRow(exercise: exercise)
                    }
                }
            }

            if !output.cooldown.isEmpty {
                Section(String(localized: "result.section.cooldown", defaultValue: "クールダウン")) {
                    ForEach(output.cooldown) { exercise in
                        ExerciseResultRow(exercise: exercise)
                    }
                }
            }

            Section {
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

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(exercise.name)
                .font(.body)
            Text(exercise.nameEn)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
