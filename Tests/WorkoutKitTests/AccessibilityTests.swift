import Testing
@testable import WorkoutKit

@Suite("ProFeatureGate accessibility (paywall trigger)")
@MainActor
struct ProFeatureGateAccessibilityTests {
    @Test("非プレミアム状態では paywall をトリガーすべき機能が全て false")
    func allGatedFeaturesAreFalseForFree() {
        let gate = ProFeatureGate()
        let gatedFeatures: [ProFeature] = [.unlimitedHistory, .advancedCharts, .manualEntry, .customTemplates]
        for feature in gatedFeatures {
            #expect(!gate.check(feature), "feature \(feature) should be gated for free users")
        }
    }

    @Test("プレミアム状態では全機能が true")
    func allFeaturesOpenForPremium() {
        let gate = ProFeatureGate(isPremium: true)
        #expect(gate.check(.unlimitedHistory))
        #expect(gate.check(.advancedCharts))
        #expect(gate.check(.manualEntry))
        #expect(gate.check(.customTemplates))
    }
}

@Suite("StoreKitClient productIDs")
struct StoreKitProductIDTests {
    @Test("productID は com.tomo.workoutkit.pro.unlock のみ")
    func singleProductID() {
        #expect(StoreKitClient.productIDs == ["com.tomo.workoutkit.pro.unlock"])
    }
}
