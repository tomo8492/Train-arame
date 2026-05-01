import Foundation
import SwiftData
import Observation

struct SetEntry: Identifiable {
    var id = UUID()
    var exerciseName: String = ""
    var reps: Int = 0
    var weightKg: Double = 0
}

@Observable @MainActor
final class ManualEntryStore {
    var date: Date = .now
    var setEntries: [SetEntry] = [SetEntry()]

    var isValid: Bool {
        setEntries.contains { !$0.exerciseName.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    func addSetEntry() {
        setEntries.append(SetEntry())
    }

    func removeSetEntry(at offsets: IndexSet) {
        setEntries.remove(atOffsets: offsets)
        if setEntries.isEmpty { setEntries.append(SetEntry()) }
    }

    func save(context: ModelContext) {
        let session = WorkoutSession(startedAt: date, isManualEntry: true)
        session.finishedAt = date
        session.totalSets = setEntries.count
        session.completedSets = setEntries.filter { !$0.exerciseName.isEmpty }.count
        context.insert(session)
    }
}
