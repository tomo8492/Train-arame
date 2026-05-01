import SwiftUI
import SwiftData

@main
struct WorkoutKitApp: App {
    private let gate = ProFeatureGate()
    private let storeClient = StoreKitClient()
    private let storeEnv: StoreEnvironment

    init() {
        storeEnv = StoreEnvironment(client: storeClient)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(gate)
                .environment(storeEnv)
                .task { await startStoreKit() }
        }
        .modelContainer(for: WorkoutSession.self)
    }

    private func startStoreKit() async {
        await storeClient.configure(gate: gate)
        await storeClient.loadProducts()
    }
}
