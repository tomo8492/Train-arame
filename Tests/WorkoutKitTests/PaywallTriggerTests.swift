import Testing
@testable import WorkoutKit

@Suite("PaywallStore")
@MainActor
struct PaywallStoreTests {
    @Test("初期状態: product=nil, isLoading=false, purchaseError=nil")
    func initialState() {
        let gate = ProFeatureGate()
        let client = StoreKitClient()
        let store = PaywallStore(client: client, gate: gate)
        #expect(store.product == nil)
        #expect(!store.isLoading)
        #expect(store.purchaseError == nil)
        #expect(!store.didRestoreSuccessfully)
    }
}

@Suite("ProFeatureGate paywall トリガー")
@MainActor
struct PaywallTriggerTests {
    @Test("非プレミアム時: check(.manualEntry) は false")
    func nonPremiumBlocksManualEntry() {
        let gate = ProFeatureGate()
        #expect(!gate.check(.manualEntry))
    }

    @Test("非プレミアム時: check(.unlimitedHistory) は false")
    func nonPremiumBlocksHistory() {
        let gate = ProFeatureGate()
        #expect(!gate.check(.unlimitedHistory))
    }

    @Test("非プレミアム時: check(.advancedCharts) は false")
    func nonPremiumBlocksCharts() {
        let gate = ProFeatureGate()
        #expect(!gate.check(.advancedCharts))
    }

    @Test("非プレミアム時: check(.customTemplates) は false")
    func nonPremiumBlocksTemplates() {
        let gate = ProFeatureGate()
        #expect(!gate.check(.customTemplates))
    }

    @Test("unlock() 後: 全機能が解放される")
    func unlockOpensAllFeatures() {
        let gate = ProFeatureGate()
        gate.unlock()
        #expect(gate.check(.manualEntry))
        #expect(gate.check(.unlimitedHistory))
        #expect(gate.check(.advancedCharts))
        #expect(gate.check(.customTemplates))
    }

    @Test("setIsPremium(true) 後: isPremium == true")
    func setIsPremiumTrue() {
        let gate = ProFeatureGate()
        gate.setIsPremium(true)
        #expect(gate.isPremium)
    }

    @Test("setIsPremium(false) で非プレミアムに戻る")
    func setIsPremiumFalse() {
        let gate = ProFeatureGate(isPremium: true)
        gate.setIsPremium(false)
        #expect(!gate.isPremium)
        #expect(!gate.check(.manualEntry))
    }

    @Test("init(isPremium: true) でプレミアム状態から起動できる")
    func initWithPremiumTrue() {
        let gate = ProFeatureGate(isPremium: true)
        #expect(gate.isPremium)
        #expect(gate.check(.unlimitedHistory))
    }

    @Test("StoreEnvironment は StoreKitClient を保持する")
    func storeEnvironmentHoldsClient() {
        let client = StoreKitClient()
        let env = StoreEnvironment(client: client)
        // actor identity — just confirm it compiles and holds a reference
        #expect(type(of: env.client) == StoreKitClient.self)
    }
}
