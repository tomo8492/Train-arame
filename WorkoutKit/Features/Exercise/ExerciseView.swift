import SwiftUI
import os

private let logger = Logger(subsystem: "com.tomo.workoutkit", category: "ExerciseView")

struct ExerciseView: View {
    @State private var exercises: [Exercise] = []
    @State private var loadError: Bool = false

    var body: some View {
        if exercises.isEmpty && !loadError {
            ProgressView()
                .task { await loadExercises() }
        } else if loadError {
            ContentUnavailableView(
                "読み込みエラー",
                systemImage: "exclamationmark.triangle",
                description: Text("種目データを読み込めませんでした。")
            )
        } else {
            ExerciseListView(exercises: exercises)
        }
    }

    private func loadExercises() async {
        do {
            exercises = try ExerciseSeedLoader.load()
            logger.info("Loaded \(exercises.count) exercises for library")
        } catch {
            loadError = true
            logger.error("Failed to load exercises: \(error)")
        }
    }
}
