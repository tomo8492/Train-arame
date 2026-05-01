import SwiftUI
import SwiftData

@main
struct WorkoutKitApp: App {
    private let gate = ProFeatureGate()
    private let container: ModelContainer

    init() {
        let schema = Schema([WorkoutSession.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(gate)
                .modelContainer(container)
        }
    }
}
