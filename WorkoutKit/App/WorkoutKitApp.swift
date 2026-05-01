import SwiftUI
import SwiftData

@main
struct WorkoutKitApp: App {
    private let gate = ProFeatureGate()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(gate)
        }
        .modelContainer(for: [WorkoutSession.self, WorkoutTemplate.self])
    }
}
