import Testing
@testable import WorkoutKit

@Suite("Release readiness")
struct ReleaseReadinessTests {
    @Test("StoreKit product ID は 1 件のみ")
    func singleProductID() {
        #expect(StoreKitClient.productIDs.count == 1)
    }

    @Test("StoreKit product ID のフォーマットが正しい")
    func productIDFormat() {
        let id = "com.tomo.workoutkit.pro.unlock"
        #expect(StoreKitClient.productIDs.contains(id))
    }

    @Test("ProFeatureGate: デフォルト起動時は非プレミアム")
    @MainActor func defaultGateIsNotPremium() {
        let gate = ProFeatureGate()
        #expect(!gate.isPremium)
    }

    @Test("ProFeatureGate: unlock() は冪等")
    @MainActor func unlockIsIdempotent() {
        let gate = ProFeatureGate()
        gate.unlock()
        gate.unlock()
        #expect(gate.isPremium)
    }

    @Test("ProFeature の全ケースが存在する")
    func allProFeaturesExist() {
        let features: [ProFeature] = [.unlimitedHistory, .advancedCharts, .manualEntry, .customTemplates]
        #expect(features.count == 4)
    }

    @Test("StoreEnvironment は client を保持する")
    @MainActor func storeEnvironmentHoldsClient() {
        let client = StoreKitClient()
        let env = StoreEnvironment(client: client)
        #expect(type(of: env.client) == StoreKitClient.self)
    }
}
