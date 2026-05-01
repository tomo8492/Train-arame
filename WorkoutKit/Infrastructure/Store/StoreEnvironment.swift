import Foundation
import Observation

@Observable @MainActor
final class StoreEnvironment {
    let client: StoreKitClient

    init(client: StoreKitClient) {
        self.client = client
    }
}
