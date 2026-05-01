import Testing
@testable import WorkoutKit

@Suite("StoreKitClient")
struct StoreKitClientTests {
    @Test("正しいプロダクトIDが設定されている")
    func productIDsAreCorrect() {
        #expect(StoreKitClient.productIDs.contains("com.tomo.workoutkit.pro.unlock"))
        #expect(StoreKitClient.productIDs.count == 1)
    }

    @Test("verificationFailed は StoreKitError に属する")
    func verificationFailedError() {
        let err: StoreKitError = .verificationFailed
        #expect(err == .verificationFailed)
    }

    @Test("productNotFound は StoreKitError に属する")
    func productNotFoundError() {
        let err: StoreKitError = .productNotFound
        #expect(err == .productNotFound)
    }
}

@Suite("ProFeatureGate (StoreKit統合)")
@MainActor
struct ProFeatureGateStoreKitTests {
    @Test("デフォルトは非Premium")
    func defaultIsNotPremium() {
        let gate = ProFeatureGate()
        #expect(!gate.isPremium)
        #expect(!gate.check(.unlimitedHistory))
        #expect(!gate.check(.advancedCharts))
        #expect(!gate.check(.manualEntry))
        #expect(!gate.check(.customTemplates))
    }

    @Test("setIsPremium(true) でプレミアム状態になる")
    func setIsPremiumUnlocks() {
        let gate = ProFeatureGate()
        gate.setIsPremium(true)
        #expect(gate.isPremium)
    }

    @Test("setIsPremium(false) で非プレミアム状態になる")
    func setIsPremiumLocks() {
        let gate = ProFeatureGate(isPremium: true)
        gate.setIsPremium(false)
        #expect(!gate.isPremium)
    }

    @Test("isPremium=true のとき全機能が unlock される")
    func allFeaturesUnlockedWhenPremium() {
        let gate = ProFeatureGate(isPremium: true)
        for feature in [ProFeature.unlimitedHistory, .advancedCharts, .manualEntry, .customTemplates] {
            #expect(gate.check(feature))
        }
    }

    @Test("unlock() で isPremium が true になる")
    func unlockSetsIsPremium() {
        let gate = ProFeatureGate()
        gate.unlock()
        #expect(gate.isPremium)
    }
}
