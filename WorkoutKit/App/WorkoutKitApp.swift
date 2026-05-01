import SwiftUI
import SwiftData

@main
struct WorkoutKitApp: App {
    private let gate = ProFeatureGate()
    private let storeClient = StoreKitClient()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(gate)
                .task { await startStoreKit() }
        }
        .modelContainer(for: WorkoutSession.self)
    }

    private func startStoreKit() async {
        await storeClient.configure(gate: gate)
        await storeClient.loadProducts()
    }
}
