import Testing
import Foundation
@testable import WorkoutKit

@Suite("ProFeatureGate")
@MainActor
struct ProFeatureGateTests {

    @Test("デフォルトは全機能ロック")
    func defaultAllLocked() async throws {
        let gate = ProFeatureGate(isPremium: false)
        let allLocked = ProFeature.allCases.allSatisfy { !gate.check($0) }
        #expect(allLocked)
    }

    @Test("unlock() で全機能解放")
    func unlockAll() async throws {
        let gate = ProFeatureGate(isPremium: false)
        gate.unlock()
        let allUnlocked = ProFeature.allCases.allSatisfy { gate.check($0) }
        #expect(allUnlocked)
    }

    @Test("30日境界で needsPaywall が正しく働く")
    func historyPaywallBoundary() async throws {
        let calendar = Calendar.current
        let recent = WorkoutSession(startedAt: Date.now)
        let old = WorkoutSession(
            startedAt: calendar.date(byAdding: .day, value: -45, to: .now) ?? .now
        )
        let gate = ProFeatureGate(isPremium: false)
        let store = HistoryStore(sessions: [recent, old], gate: gate)
        #expect(store.needsPaywall == true)
        #expect(store.visibleSessions.count == 1)
    }
}
