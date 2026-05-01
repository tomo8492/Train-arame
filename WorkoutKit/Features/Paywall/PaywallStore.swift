import StoreKit
import Observation
import os

private let logger = Logger(subsystem: "com.tomo.workoutkit", category: "PaywallStore")

@Observable @MainActor
final class PaywallStore {
    private(set) var product: Product?
    private(set) var isLoading = false
    private(set) var purchaseError: String?
    private(set) var didRestoreSuccessfully = false

    private let client: StoreKitClient
    private let gate: ProFeatureGate

    init(client: StoreKitClient, gate: ProFeatureGate) {
        self.client = client
        self.gate = gate
    }

    func loadProducts() async {
        await client.loadProducts()
        let loaded = await client.products
        product = loaded.first
    }

    func purchase() async {
        guard let product else { return }
        isLoading = true
        purchaseError = nil
        do {
            try await client.purchase(product, gate: gate)
            logger.info("Purchase succeeded")
        } catch {
            purchaseError = error.localizedDescription
            logger.error("Purchase failed: \(error)")
        }
        isLoading = false
    }

    func restore() async {
        isLoading = true
        purchaseError = nil
        await client.restorePurchases(gate: gate)
        didRestoreSuccessfully = gate.isPremium
        isLoading = false
    }
}
