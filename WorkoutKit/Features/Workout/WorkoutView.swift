import SwiftUI
import os

private let logger = Logger(subsystem: "com.tomo.workoutkit", category: "WorkoutView")

struct WorkoutView: View {
    @State private var showBuilder: Bool = false
    @State private var sessionStore: SessionStore?
    @State private var exercises: [Exercise] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                Text("ワークアウト")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("トレーニングセッションをここで開始します。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Button(String(localized: "builder.start.session")) {
                    showBuilder = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                Spacer()
            }
            .navigationTitle("ワークアウト")
            .sheet(isPresented: $showBuilder) {
                if !exercises.isEmpty {
                    BuilderView(exercisePool: exercises) { output in
                        let store = SessionStore(output: output)
                        store.onFinish = { session in
                            logger.info("Session saved: \(session.id)")
                        }
                        sessionStore = store
                    }
                }
            }
            .sheet(item: $sessionStore) { store in
                SessionView(store: store)
            }
            .task {
                do {
                    exercises = try ExerciseSeedLoader.load()
                } catch {
                    logger.error("Failed to load exercises: \(error)")
                }
            }
        }
    }
}

// MARK: - SessionStore + Identifiable for sheet(item:)

extension SessionStore: Identifiable {
    nonisolated var id: ObjectIdentifier { ObjectIdentifier(self) }
}
