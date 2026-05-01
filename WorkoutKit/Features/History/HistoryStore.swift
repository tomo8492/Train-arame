import Foundation

@Observable @MainActor
final class HistoryStore {
    private let sessions: [WorkoutSession]
    private let gate: ProFeatureGate

    var displayMode: DisplayMode = .list
    var selectedDate: Date = .now

    enum DisplayMode { case list, calendar }

    var visibleSessions: [WorkoutSession] {
        guard gate.check(.unlimitedHistory) else {
            let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: .now) ?? .now
            return sessions.filter { $0.startedAt >= cutoff }
        }
        return sessions
    }

    var needsPaywall: Bool {
        !gate.check(.unlimitedHistory) && sessions.count > visibleSessions.count
    }

    var weeklyVolume: [(week: Date, sets: Int)] {
        let calendar = Calendar.current
        var grouped: [Date: Int] = [:]
        for session in visibleSessions {
            guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: session.startedAt)?.start else { continue }
            grouped[weekStart, default: 0] += session.completedSets
        }
        return grouped
            .map { (week: $0.key, sets: $0.value) }
            .sorted { $0.week < $1.week }
    }

    var sessionsByWeek: [(weekStart: Date, sessions: [WorkoutSession])] {
        let calendar = Calendar.current
        var grouped: [Date: [WorkoutSession]] = [:]
        for session in visibleSessions {
            guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: session.startedAt)?.start else { continue }
            grouped[weekStart, default: []].append(session)
        }
        return grouped
            .map { (weekStart: $0.key, sessions: $0.value.sorted { $0.startedAt > $1.startedAt }) }
            .sorted { $0.weekStart > $1.weekStart }
    }

    var datesWithSessions: Set<Date> {
        let calendar = Calendar.current
        return Set(visibleSessions.compactMap { calendar.startOfDay(for: $0.startedAt) })
    }

    init(sessions: [WorkoutSession], gate: ProFeatureGate) {
        self.sessions = sessions.sorted { $0.startedAt > $1.startedAt }
        self.gate = gate
    }
}
