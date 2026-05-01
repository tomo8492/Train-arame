import StoreKit
import os

private let logger = Logger(subsystem: "com.tomo.workoutkit", category: "StoreKitClient")

enum StoreKitError: Error, Equatable {
    case verificationFailed
    case productNotFound
    case purchaseFailed(String)
}

actor StoreKitClient {
    static let productIDs: Set<String> = ["com.tomo.workoutkit.pro.unlock"]

    private(set) var products: [Product] = []
    private var transactionListenerTask: Task<Void, Never>?

    func configure(gate: ProFeatureGate) {
        transactionListenerTask?.cancel()
        transactionListenerTask = Task { [weak self] in
            await self?.observeTransactions(gate: gate)
        }
        Task { await updateProStatus(gate: gate) }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: Self.productIDs)
            logger.info("Loaded \(self.products.count) products")
        } catch {
            logger.error("Failed to load products: \(error)")
        }
    }

    @discardableResult
    func purchase(_ product: Product, gate: ProFeatureGate) async throws -> Transaction? {
        let result = try await product.purchase()
        switch result {
        case .success(let verificationResult):
            let transaction = try checkVerified(verificationResult)
            await updateProStatus(gate: gate)
            await transaction.finish()
            logger.info("Purchase completed: \(transaction.productID)")
            return transaction
        case .userCancelled:
            logger.info("Purchase cancelled by user")
            return nil
        case .pending:
            logger.info("Purchase pending")
            return nil
        @unknown default:
            return nil
        }
    }

    func restorePurchases(gate: ProFeatureGate) async {
        do {
            try await AppStore.sync()
            await updateProStatus(gate: gate)
            logger.info("Purchases restored")
        } catch {
            logger.error("Restore failed: \(error)")
        }
    }

    private func observeTransactions(gate: ProFeatureGate) async {
        for await result in Transaction.updates {
            do {
                let transaction = try checkVerified(result)
                await updateProStatus(gate: gate)
                await transaction.finish()
            } catch {
                logger.error("Transaction verification failed: \(error)")
            }
        }
    }

    func updateProStatus(gate: ProFeatureGate) async {
        var isUnlocked = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               Self.productIDs.contains(transaction.productID),
               transaction.revocationDate == nil {
                isUnlocked = true
            }
        }
        await MainActor.run { gate.setIsPremium(isUnlocked) }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.verificationFailed
        case .verified(let value):
            return value
        }
    }
}
